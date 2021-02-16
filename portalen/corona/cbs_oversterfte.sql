DROP TABLE IF EXISTS sd_cbs_oversterfte;
CREATE TABLE sd_cbs_oversterfte AS 
SELECT  t0.*
,       avg(t1."Overledenen") FILTER (WHERE t1."Weeknummer" = t0."Weeknummer" AND t1."Datum" BETWEEN t0."Datum" - INTERVAL '5 years' AND t0."Datum") as "Gemiddelde in deze week afgelopen 5 jaar"
FROM    bi_cbs_oversterfte t0 
JOIN    bi_cbs_oversterfte t1 
ON      t0."Geslacht" = t1."Geslacht"
AND     t0."Leeftijd" = t1."Leeftijd"
GROUP BY 1,2,3,4,5,6,7
;