/******************************************************************************************************

Tulorekisterin palkka- ja etuustietojen summaussäännöt.

Tällä koodilla muodostetaan KK-ajoissa tarvittavat summaerät Tulorekisterin aineistoista.
Muodostuskoodi mahdollistaa summamuuttujien joustavan muodostuksen sekä läpinäkyvän tarkastelun.
Koodissa muodostetaan seuraavat erät:

1. TTURVA_KK (Vaaditaan työttömyysturvan kuukausimallilla tehtäviin simulointeihin)
	1.1 Työttömyysturvan sovittelussa huomioon otettavat palkkatulot bruttona
	1.2 Työttömyysturvan tarveharkinnassa huomioon otettavat etuustulot bruttona
	1.3 Työttömyysturvasta vähennettävä sosiaalietuus

2. TOIMTUKI (ESIMERKKI: vaatii käyttäjältä huolellista läpikäyntiä)
	2.1 Toimeentulotuessa huomioon otettavat palkkatulot nettona
	2.2 Toimeentulotuessa huomioon otettavat etuustulot nettona

3. ASUMTUKI & ELASUMTUKI (ESIMERKKI: vaatii käyttäjältä huolellista läpikäyntiä)
	3.1 Yleisessä ja eläkkeensaajan asumistuessa huomioon otettavat palkkatulot bruttona
	3.2 Yleisessä asumistuessa huomioon otettavat etuustulot bruttona
	3.3 Eläkkeensaajan asumistuessa huomioon otettavat etuustulot bruttona
		3.3.2 Oikeus eläkkeensaajan asumistukeen

Muodostettavat aineistot ovat:
	POHJADAT.tturva_tulrek2023.sas7bdat
	POHJADAT.toimtuki_tulrek2023.sas7bdat
	POHJADAT.asumtuki_tulrek2023.sas7bdat

Tarkempi kuvaus aineiston muodostuksesta löytyy tiedostosta tulrek_readme.txt.
	
******************************************************************************************************/

proc sql;
create table POHJADAT.tturva_tulrek2023 as
	/*** 1. TTURVA_KK ***/
	/* 1.1 Työttömyysturvan sovittelussa huomioon otettavat palkkatulot bruttona
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
    from POHJADAT.tulrek_palkka2023
    group by hnro, kk

	/* 1.2 Työttömyysturvan tarveharkinnassa huomioon otettavat etuustulot bruttona
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
    from POHJADAT.tulrek_etuus2023
	group by hnro, kk

	/* 1.3 Työttömyysturvasta vähennettävä sosiaalietuus
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
    from POHJADAT.tulrek_etuus2023
	group by hnro, kk
;
quit;

/*
proc sql;
create table POHJADAT.toimtuki_tulrek2023 as
	/*** 2. TOIMTUKI ***/
	/* 2.1 Toimeentulotuessa huomioon otettavat palkkatulot nettona *//*
    select
        hnro, 
		kk,
        "toimtuki_palkka" as tuloera,
        sum(
            case when transactionCode not in (
                209, 304, 311, 331, 341, 342, 353, 357, 358, 401,
				403, 405, 406, 409, 410, 411, 419, 402, 404, 407,
				408, 412, 413, 414, 415, 416, 417, 418, 420) 
            then summa
            when transactionCode in (
                402, 404, 407, 408, 412, 413, 414, 415, 416, 417,
				418, 420) 
            then -summa
            else 0 end
        ) as summa
    from POHJADAT.tulrek_palkka2023
    group by hnro, kk

	/* 2.2 Toimeentulotuessa huomioon otettavat etuustulot nettona
	   https://www.finlex.fi/fi/lainsaadanto/1997/1412#chp_2__sec_11 *//*
    union all
    select
        hnro, 
		kk,
        "toimtuki_etuus" as tuloera,
        sum(
            case when transactionCode not in (
                1017, 1018, 1019, 1021, 1023, 1055, 1312, 1362, 1387, 1388,
				1389, 1396, 1397, 1266, 1267, 1268, 1269)
            then summa
            when transactionCode in (
                1266, 1267, 1268, 1269)
            then -summa
            else 0 end
        ) as summa
    from POHJADAT.tulrek_etuus2023
    group by hnro, kk
;
quit;

proc sql;
create table POHJADAT.asumtuki_tulrek2023 as
	/*** 3. ASUMTUKI & ELASUMTUKI ***/
	/* 3.1 Yleisessä ja eläkkeensaajan asumistuessa huomioon otettavat palkkatulot bruttona *//*
    union all
    select
        hnro, 
		kk,
        "astuki_palkka" as tuloera,
        sum(
            case when transactionCode not in (
				401, 402, 403, 404, 405, 406, 407, 408, 409, 410,
				411, 412, 413, 414, 415, 416, 417, 418, 419, 420)
            then summa
			else 0 end
        ) as summa
    from POHJADAT.tulrek_palkka2023
    group by hnro, kk

	/* 3.2 Yleisessä asumistuessa huomioon otettavat etuustulot bruttona
	   https://www.finlex.fi/fi/lainsaadanto/2014/938#chp_2__sec_15 *//*
    union all
    select
        hnro,
		kk,
        "yastuki_etuus" as tuloera,
		sum(
			case when transactionCode not in (
				1014, 1024, 1027, 1032, 1036, 1037, 1038, 1041, 1042, 1133,
				1159, 1160, 1161, 1162, 1176, 1242, 1274, 1304, 1305, 1306,
				1343, 1344, 1372, 1387, 1388, 1389, 1396, 1397, 1408,
				1266, 1267, 1268, 1269)
			then summa
			else 0 end
		) as summa
    from POHJADAT.tulrek_etuus2023
	group by hnro, kk

	/* 3.3 Eläkkeensaajan asumistuessa huomioon otettavat etuustulot bruttona
	   https://www.finlex.fi/fi/lainsaadanto/2007/571#chp_2__sec_14 *//*
    union all
    select
        hnro, 
		kk,
        "eastuki_etuus" as tuloera,
		sum(
			case when transactionCode not in (
				1014, 1018, 1019, 1021, 1024, 1025, 1027, 1036, 1037, 1038,
				1041, 1042, 1043, 1094, 1097, 1133, 1159, 1176, 1239, 1242,
				1304, 1305, 1306, 1343, 1330, 1365, 1372, 1387, 1388, 1389,
				1396, 1397, 1408, 1266, 1267, 1268, 1269)
			then summa
			else 0 end
		) as summa
    from POHJADAT.tulrek_etuus2023
	group by hnro, kk

	/* 3.3.2 Oikeus eläkkeensaajan asumistukeen
	   https://www.finlex.fi/fi/lainsaadanto/2007/571#chp_2__sec_8 *//*
    union all
    select
        hnro, 
		kk,
        "eastuki_oikeus" as tuloera,
		sum(
			case when transactionCode in (
				1026, 1028, 1029, 1031, 1033, 1034, 1077, 1078, 1081, 1086,
				1122, 1123, 1124, 1131, 1132, 1159, 1161, 1174, 1179, 1182,
				1183, 1390, 1398)
			then summa
			else 0 end
		) as summa
    from POHJADAT.tulrek_etuus2023
	group by hnro, kk
;
quit;