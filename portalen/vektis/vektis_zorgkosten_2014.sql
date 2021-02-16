DROP        TABLE IF EXISTS sd_vektis_zorgkosten_2014
;

CREATE      TABLE sd_vektis_zorgkosten_2014 AS 
SELECT      v."Kosten Huisarts Overig"
,           v."Kosten Eerstelijns Ondersteuning"
,           v."Aantal verzekerdejaren"
,           v."Aantal BSN"
,           v."Kosten Hulpmiddelen"
,           v."Kosten Huisarts Inschrijftarief"
,           v."Kosten Medisch Specialistische Zorg"
,           v."Kosten Huisarts Consult"
,           v."Kosten Grensoverschrijdende Zorg"
,           v."Kosten Geriatrische Revalidatiezorg"
,           v."Kosten Generalistische Basis Ggz"
,           v."Kosten Farmacie"
,           v."Kosten Kraamzorg"
,           v."Kosten Overig"
,           v."Kosten Paramedische Zorg Overig"
,           v."Kosten Mondzorg"
,           v."Kosten Ziekenvervoer Liggend"
,           v."Kosten Paramedische Zorg Fysiotherapie"
,           v."Kosten Ziekenvervoer Zittend"
,           v."Kosten Verloskundige Zorg"
,           v."Kosten Specialistische Ggz"
,           v."Geslacht"
,           v."Leeftijdscategorie"
,           r."Gemeente"
,           r."Gemeentecode"
,           r."Provincie"
,           r."Landsdeel"
,           r."Provinciecode"
,           r."Landsdeelcode"
,           v."Jaar"
,           v."Type kosten"
,           v."Kosten"
FROM        
            (           
            SELECT      * 
            ,           2014 AS "Jaar"
            FROM        bi_vektis_2014
CROSS 
            JOIN        LATERAL 
                        (           VALUES 
                                    (           'Overig'
                                    ,           "Kosten Overig"
                                    )           
                        ,           
                                    (           'Paramedische Zorg Overig'
                                    ,           "Kosten Paramedische Zorg Overig"
                                    )           
                        ,           
                                    (           'Ziekenvervoer Zittend'
                                    ,           "Kosten Ziekenvervoer Zittend"
                                    )           
                        ,           
                                    (           'Ziekenvervoer Liggend'
                                    ,           "Kosten Ziekenvervoer Liggend"
                                    )           
                        ,           
                                    (           'Kraamzorg'
                                    ,           "Kosten Kraamzorg"
                                    )           
                        ,           
                                    (           'Verloskundige Zorg'
                                    ,           "Kosten Verloskundige Zorg"
                                    )           
                        ,           
                                    (           'Generalistische Basis Ggz'
                                    ,           "Kosten Generalistische Basis Ggz"
                                    )           
                        ,           
                                    (           'Grensoverschrijdende Zorg'
                                    ,           "Kosten Grensoverschrijdende Zorg"
                                    )           
                        ,           
                                    (           'Eerstelijns Ondersteuning'
                                    ,           "Kosten Eerstelijns Ondersteuning"
                                    )           
                        ,           
                                    (           'Geriatrische Revalidatiezorg'
                                    ,           "Kosten Geriatrische Revalidatiezorg"
                                    )           
                        ,           
                                    (           'Medisch Specialistische Zorg'
                                    ,           "Kosten Medisch Specialistische Zorg"
                                    )           
                        ,           
                                    (           'Farmacie'
                                    ,           "Kosten Farmacie"
                                    )           
                        ,           
                                    (           'Specialistische Ggz'
                                    ,           "Kosten Specialistische Ggz"
                                    )           
                        ,           
                                    (           'Huisarts Inschrijftarief'
                                    ,           "Kosten Huisarts Inschrijftarief"
                                    )           
                        ,           
                                    (           'Huisarts Consult'
                                    ,           "Kosten Huisarts Consult"
                                    )           
                        ,           
                                    (           'Huisarts Overig'
                                    ,           "Kosten Huisarts Overig"
                                    )           
                        ,           
                                    (           'Hulpmiddelen'
                                    ,           "Kosten Hulpmiddelen"
                                    )           
                        ,           
                                    (           'Mondzorg'
                                    ,           "Kosten Mondzorg"
                                    )           
                        ,           
                                    (           'Paramedische Zorg Fysiotherapie'
                                    ,           "Kosten Paramedische Zorg Fysiotherapie"
                                    )           
                        )           AS t
                        (           "Type kosten"
                        ,           "Kosten"
                        )           
            )           v
JOIN        bi_vektis_ref_gemeente r
ON          v."Gemeente" = r."Gemeente_vektis"
;

ANALYZE sd_vektis_zorgkosten_2014
;

--GRANT ALL 
--ON          TABLE sd_vektis_zorgkosten_2014 TO d2aportal
--;
