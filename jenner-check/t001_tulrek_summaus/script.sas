/******************************************************************************************************

Tulorekisterin palkka- ja etuustietojen summaussaannot.

Tama on SISU-mallin tiedoston SISU/DATA/POHJADAT/tulrek_summaus.sas aktiivinen
TTURVA_KK-osio, jolla muodostetaan tyottomyysturvan kuukausimallissa tarvittavat
summaerat tulorekisterin aineistoista. Logiikka on sailytetty sellaisenaan;
ainoastaan POHJADAT-kirjasto ja lahdeaineistot on korvattu pienella
esimerkkiaineistolla (ks. autoexec.sas).

******************************************************************************************************/

%let avuosi = 2024; /* Aineistovuosi */

proc sql;
create table POHJADAT.tturva_tulrek&avuosi. as
	/*** 1. TTURVA_KK ***/
	/* 1.1 Tyottomyysturvan sovittelussa huomioon otettavat palkkatulot bruttona
	   https://www.finlex.fi/fi/lainsaadanto/2002/1290#part_3__chp_7__sec_6 */
    select
        hnro,
		kk		length=3,
        "tturva_palkka" as tuloera,
        sum(
            case when transactionCode not in (
				319, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410,
				411, 412, 413, 414, 415, 416, 417, 418, 419, 420)
            then summa
            else 0 end
        ) as summa
    from POHJADAT.tulrek_palkka&avuosi.
    group by hnro, kk

	/* 1.2 Tyottomyysturvan tarveharkinnassa huomioon otettavat etuustulot bruttona
	   https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2026/48#OT3_OT1 */
    union all
    select
        hnro,
		kk		length=3,
        "tturva_etuus_tarveharkinta" as tuloera,
		sum(
			case when transactionCode not in (
               	1006, 1007, 1008, 1015, 1016, 1017, 1018, 1019, 1020, 1021,
				1028, 1030, 1041, 1042, 1054, 1055, 1056, 1058, 1060, 1159,
				1160, 1263, 1264, 1266, 1267, 1268, 1269, 1310, 1311, 1312,
				1313, 1314, 1315, 1343, 1344, 1361, 1362, 1363, 1364)
			then summa
			else 0 end
		) as summa
    from POHJADAT.tulrek_etuus&avuosi.
	group by hnro, kk

	/* 1.3 Tyottomyysturvasta vahennettava sosiaalietuus
	   https://www.finlex.fi/fi/lainsaadanto/2002/1290#part_1__chp_4__sec_7 */
	union all
    select
        hnro,
		kk		length=3,
        "tturva_etuus_vahennettava" as tuloera,
		sum(
			case when transactionCode not in (
				1015, 1016, 1017, 1018, 1019, 1020, 1021, 1028, 1029, 1030,
				1031, 1032, 1041, 1042, 1054, 1055, 1056, 1058, 1060, 1077,
				1080, 1105, 1122, 1123, 1133, 1159, 1160, 1179, 1182, 1221,
				1255, 1263, 1264, 1266, 1267, 1268, 1269, 1271, 1280, 1281,
				1296, 1310, 1311, 1312, 1313, 1314, 1315, 1318, 1319, 1322,
				1324, 1325, 1328, 1333, 1343, 1344, 1355, 1360, 1361, 1362,
				1363, 1364, 1426)
			then summa
			else 0 end
		) as summa
    from POHJADAT.tulrek_etuus&avuosi.
	group by hnro, kk
;
quit;

/* Tulostetaan muodostettu summataulu tarkistusta varten */
proc print data=POHJADAT.tturva_tulrek&avuosi. label noobs;
    title "TTURVA_KK summaerat henkilon ja kuukauden mukaan (esimerkkiaineisto)";
run;
