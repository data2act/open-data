--bi_covid_rivm_gemeente is data van stichting NICE.
--Deze set verrijken we met CBS data.
DROP        TABLE IF EXISTS sd_covid19_per_gemeente
;

CREATE      TABLE sd_covid19_per_gemeente AS 
SELECT      t0.*
,           t3."GGD-regio code"
,           t3."GGD-regio"
,           t3."COROP-gebied code"
,           t3."COROP-gebied"
,           t3."COROP-subgebied code"
,           t3."COROP-subgebied"
,           t3."COROP-plusgebied code"
,           t3."COROP-plusgebied"
,           t3."Veiligheidsregio"
,           t3."Veiligheidsregio code"
,           t2."Bevolking aan einde periode" AS "Aantal inwoners"
,           "Positief" - LAG
            (           "Positief"
            )           OVER 
            (           PARTITION 
            BY          t0."Gemeentecode"
            ,           t0."Gemeente"
            ,           t0."Provincie" 
            ORDER BY    t0."Datum" ASC
            )           AS "Nieuw positief"
,           "Overleden" - LAG
            (           "Overleden"
            )           OVER 
            (           PARTITION 
            BY          t0."Gemeentecode"
            ,           t0."Gemeente"
            ,           t0."Provincie" 
            ORDER BY    t0."Datum" ASC
            )           AS "Nieuw overleden"
,           "Ziekenhuisopnames" - LAG
            (           "Ziekenhuisopnames"
            )           OVER 
            (           PARTITION 
            BY          t0."Gemeentecode"
            ,           t0."Gemeente"
            ,           t0."Provincie" 
            ORDER BY    t0."Datum" ASC
            )           AS "Nieuw ziekenhuisopnames"
,           "Positief" / t2."Bevolking aan einde periode" * 100000 AS "Positief per 100.000 inwoners"
,           "Overleden" / t2."Bevolking aan einde periode" * 100000 AS "Overleden per 100.000 inwoners"
,           "Ziekenhuisopnames" / t2."Bevolking aan einde periode" * 100000 AS "Ziekenhuisopnames per 100.000 inwoners"
,           
            (           "Positief" - LAG
                        (           "Positief"
                        )           OVER 
                        (           PARTITION 
                        BY          t0."Gemeentecode"
                        ,           t0."Gemeente"
                        ,           t0."Provincie" 
                        ORDER BY    t0."Datum" ASC
                        )           
            )           / t2."Bevolking aan einde periode" * 100000 AS "Nieuw positief per 100.000 inwoners"
,           
            (           "Overleden" - LAG
                        (           "Overleden"
                        )           OVER 
                        (           PARTITION 
                        BY          t0."Gemeentecode"
                        ,           t0."Gemeente"
                        ,           t0."Provincie" 
                        ORDER BY    t0."Datum" ASC
                        )           
            )           / t2."Bevolking aan einde periode" * 100000 AS "Nieuw overleden per 100.000 inwoners"
,           
            (           "Ziekenhuisopnames" - LAG
                        (           "Ziekenhuisopnames"
                        )           OVER 
                        (           PARTITION 
                        BY          t0."Gemeentecode"
                        ,           t0."Gemeente"
                        ,           t0."Provincie" 
                        ORDER BY    t0."Datum" ASC
                        )           
            )           / t2."Bevolking aan einde periode" * 100000 AS "Nieuw ziekenhuisopnames per 100.000 inwoners"
FROM        bi_covid_rivm_gemeente t0
LEFT JOIN   bi_cbs_bevolkingsontwikkeling t2
ON          t2."Datum" = 
            (           
            SELECT      MAX("Datum") 
            FROM        bi_cbs_bevolkingsontwikkeling
            )           
AND         COALESCE (SPLIT_PART(t2."Gemeente", ' (', 1), t2."Gemeente") = COALESCE (SPLIT_PART(t0."Gemeente", ' (', 1), t0."Gemeente")
AND         CASE        
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'ZH.)'
                        THEN        t0."Provincie" = 'Zuid-Holland'
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'NH.)'
                        THEN        t0."Provincie" = 'Noord-Holland'
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'Z.)'
                        THEN        t0."Provincie" = 'Zeeland' 
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'L.)'
                        THEN        t0."Provincie" = 'Limburg'
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'Gld.)'
                        THEN        t0."Provincie" = 'Gelderland' 
                        WHEN        SPLIT_PART(t2."Gemeente", ' (', 2) = 'O.)'
                        THEN        t0."Provincie" = 'Overijssel' 
                        ELSE        TRUE 
            END 
LEFT JOIN   
            (           
            SELECT      DISTINCT 
            ON          
                        (           "Gemeentecode"
                        )           *
            FROM        bi_cbs_gemeente_regio
            )           t3
ON          t3."Gemeentecode" = t0."Gemeentecode"
WHERE       t0."Gemeentecode" IS NOT NULL 
;

ANALYZE sd_covid19_per_gemeente
;


--GRANT ALL ON TABLE sd_covid19_per_gemeente TO d2aportal;

