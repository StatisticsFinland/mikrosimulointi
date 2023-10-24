/* ******************************************************************
* Kuvaus: Simulointiohjelmien k‰ytt‰mien formaattien m‰‰ritt‰minen	*
*		  OHJAUS-kansioon.											*
* Viimeksi p‰ivitetty: 13.1.2021									*
********************************************************************/

/* Formaatit luodaan seuraavalla koodilla */
PROC FORMAT;

/* TUHATEROTIN */

PICTURE tuhat (ROUND)
low - <0 = '0 000 000 000 000 009' (DECSEP=',' PREFIX='-')
0 - high = '0 000 000 000 000 009' (DECSEP=',');

/* TUHATEROTIN kahdella desimaalilla */

PICTURE tuhatdec
low - <0 = '00 000 000 000 000,09' (DECSEP=',' PREFIX='-')
0 - high = '00 000 000 000 000,09' (DECSEP=',');

/* Miljoona formaatti yhdell‰ desimaalilla */

picture miljoona low-high='000 000 000 009,9M' 
       (mult=.00001);

/* DESIILIT */

VALUE desmod (NOTSORTED MULTILABEL)
0 = '01. desiili'
1 = '02. desiili'
2 = '03. desiili'
3 = '04. desiili'
4 = '05. desiili'
5 = '06. desiili'
6 = '07. desiili'
7 = '08. desiili'
8 = '09. desiili'
9 = '10. desiili'
low-high = 'Yhteens‰';

VALUE desmod_malli (NOTSORTED MULTILABEL)
0 = '01. desiili'
1 = '02. desiili'
2 = '03. desiili'
3 = '04. desiili'
4 = '05. desiili'
5 = '06. desiili'
6 = '07. desiili'
7 = '08. desiili'
8 = '09. desiili'
9 = '10. desiili'
low-high = 'Yhteens‰';

/* IKƒLUOKITUS */

VALUE ikavu (NOTSORTED MULTILABEL)
low-24 = '0-24'
25-34 = '25-34'
35-44 = '35-44'
45-54 = '45-54'
55-64 = '55-64'
65-74 = '65-74'
75-high = '75-'
low-high = 'Yhteens‰' ;

VALUE ikavuV (NOTSORTED MULTILABEL)
low-24 = '0-24'
25-34 = '25-34'
35-44 = '35-44'
45-54 = '45-54'
55-64 = '55-64'
65-74 = '65-74'
75-high = '75-'
low-high = 'Yhteens‰' ;

/* SOSIOEKONOMINEN ASEMA (KOTITALOUS) */

VALUE paasoss (NOTSORTED MULTILABEL)
10-29 = '1. Yritt‰j‰t ja maatalousyritt‰j‰t'
10-19 = '1.1 Maatalousyritt‰j‰t'
20-29 = '1.2 Muut yritt‰j‰t'
30-59 = '2. Palkansaajat'
30-39 = '2.1. Ylemm‰t toimihenkilˆt'
40-49 = '2.2. Alemmat toimihenkilˆt'
50-59 = '2.3. Tyˆntekij‰t'
60 = '3. Opiskelijat ja koululaiset'
70-79 = '4. El‰kel‰iset'
80,81,82 = '5. Tyˆttˆm‰t ja muut'
90-99 = '6. Tuntemattomat'
low-high = 'Yhteens‰';

/* SOSIOEKONOMINEN ASEMA (HENKIL÷) */

VALUE soss (NOTSORTED MULTILABEL)
10-29 = '1. Yritt‰j‰t ja maatalousyritt‰j‰t'
10-19 = '1.1 Maatalousyritt‰j‰t'
20-29 = '1.2 Muut yritt‰j‰t'
30-59 = '2. Palkansaajat'
30-39 = '2.1. Ylemm‰t toimihenkilˆt'
40-49 = '2.2. Alemmat toimihenkilˆt'
50-59 = '2.3. Tyˆntekij‰t'
60 = '3. Opiskelijat ja koululaiset'
70-79 = '4. El‰kel‰iset'
80,81,82 = '5. Tyˆttˆm‰t ja muut'
90-99 = '6. Tuntemattomat'
low-high = 'Yhteens‰';

VALUE elivtu (NOTSORTED MULTILABEL)
11-16 = '1. Yhden hengen taloudet'
11,12 = '1.1 Yhden hengen talous, ik‰<35'
13,14,15 = '1.2 Yhden hengen talous, ik‰ 35-64'
16 = '1.3 Yhden hengen talous, ik‰ 65-'
20,84 = '2. Yksinhuoltajataloudet'
31-36 = '3. Lapsettomat parit'
31,32 = '3.1 Lapsettomat parit, ik‰ <35'
33,34,35 = '3.2 Lapsettomat parit, ik‰ 35-64'
36 = '3.3 Lapsettomat parit, ik‰ 65-'
40-70,82 = '4. Parit, joilla lapsia'
40 = '4.1 Parit, joilla lapsia, kaikki alle 7v'
50 = '4.2 Parit, joilla lapsia, nuorin alle 7v'
60 = '4.3 Parit, joilla lapsia, nuorin 7-12'
70 = '4.4 Parit, joilla lapsia, nuorin 13-17'
82 = '4.5 Parit, joilla sek‰ alle ett‰ yli 18-v lapsia'
81,83,90,99 = '5. Muut taloudet'
20,40-70,82,84 = 'Taloudet, joissa lapsia'
low-high = 'Yhteens‰';

/* KOULUTUSASTE (KOULUTUSLUOKITUS 2016) */

VALUE koulas (NOTSORTED MULTILABEL)
0 = '1. Perusaste, ei suoritettua tutkintoa tai tuntematon'
3 = '2. Keskiaste'
4 = '3. Erikoisammattikoulutusaste'
5 = '4. Alin korkea-aste'
6 = '5. Alempi korkeakouluaste'
7 = '6. Ylempi korkeakouluaste'
8 = '7. Tutkijakoulutusaste'
low-high = 'Yhteens‰';

/* VIITEHENKIL÷N KOULUTUSASTE */

VALUE koulasv (NOTSORTED MULTILABEL)
0 = '1. Perusaste, ei suoritettua tutkintoa tai tuntematon'
3 = '2. Keskiaste'
4 = '3. Erikoisammattikoulutusaste'
5 = '4. Alin korkea-aste'
6 = '5. Alempi korkeakouluaste'
7 = '6. Ylempi korkeakouluaste'
8 = '7. Tutkijakoulutusaste'
low-high = 'Yhteens‰';

/* KOTITALOUDEN RAKENNE */

VALUE rake (NOTSORTED MULTILABEL)
10 = '1 aikuinen'
22 = '2 aikuista'
33 = '3 aikuista'
44 = '4 aikuista'
21 = '1 aikuinen, 1 lapsi'
31 = '1 aikuinen, 2 lasta'
32 = '2 aikuista, 1 lapsi'
42 = '2 aikuista, 2 lasta'
52 = '2 aikuista, 3 lasta'
62 = '2 aikuista, v‰hint‰‰n 4 lasta'
43 = '3 aikuista, 1 lapsi'
53 = '3 aikuista, 2 lasta'
63 = '3 aikuista, v‰hint‰‰n 3 lasta'
54 = '4 aikuista, 1 lapsi'
41,51,55,61,64,65,66,99 = 'Muut'
low-high = 'Yhteens‰';

/* SYNTYPERƒ */

VALUE $syntypera (NOTSORTED MULTILABEL)
'11' = 'Suomalaistaustainen, syntynyt Suomessa'
'12' = 'Suomalaistaustainen, syntynyt ulkomailla'
'22' = 'Ulkomaalaistaustainen, syntynyt ulkomailla'
'21' = 'Ulkomaalaistaustainen, syntynyt Suomessa';

/* MAAKUNTA NUMEERISENA */

VALUE maakunta (NOTSORTED MULTILABEL)
1 = 'Uusimaa'
2 = 'Varsinais-Suomi'
4 = 'Satakunta'
5 = 'Kanta-H‰me'
6 = 'Pirkanmaa'
7 = 'P‰ij‰t-H‰me'
8 = 'Kymenlaakso'
9 = 'Etel‰-Karjala'
10 = 'Etel‰-Savo'
11 = 'Pohjois-Savo'
12 = 'Pohjois-Karjala'
13 = 'Keski-Suomi'
14 = 'Etel‰-Pohjanmaa'
15 = 'Pohjanmaa'
16 = 'Keski-Pohjanmaa'
17 = 'Pohjois-Pohjanmaa'
18 = 'Kainuu'
19 = 'Lappi'
21 = 'Ahvenanmaa - ≈land'
low-high = 'Yhteens‰';

/* MAAKUNTA TEKSTIMUOTOISENA */

VALUE $maakunta (NOTSORTED MULTILABEL)
'01' = 'Uusimaa'
'02' = 'Varsinais-Suomi'
'04' = 'Satakunta'
'05' = 'Kanta-H‰me'
'06' = 'Pirkanmaa'
'07' = 'P‰ij‰t-H‰me'
'08' = 'Kymenlaakso'
'09' = 'Etel‰-Karjala'
'10' = 'Etel‰-Savo'
'11' = 'Pohjois-Savo'
'12' = 'Pohjois-Karjala'
'13' = 'Keski-Suomi'
'14' = 'Etel‰-Pohjanmaa'
'15' = 'Pohjanmaa'
'16' = 'Keski-Pohjanmaa'
'17' = 'Pohjois-Pohjanmaa'
'18' = 'Kainuu'
'19' = 'Lappi'
'21' = 'Ahvenanmaa - ≈land';

/* ASLAJI */

PROC FORMAT;
VALUE aslaji (NOTSORTED MULTILABEL)
1 = "Omakotitalo omalla tontilla"
2 = "Omakotitalo vuokratontilla"
3 = "Omistusasunto"
4 = "Vuokra-asunto"
6 = "Asumisoikeusasunto"
8 = "Muu tai tuntematon asumismuoto"
low-high = 'Yhteens‰';

/* SUORITUSLAJI */

VALUE $suorlaji (NOTSORTED MULTILABEL)
'P'  = 'Palkka p‰‰toimesta'
'1'  = 'Palkka sivutomesta'
'PT' = 'Tyˆpanokseen perustuva osinko tai ylij‰‰m‰ (palkkaa)'
'P3' = 'Kunnallisen perhep‰iv‰hoitajan palkka'
'PU' = 'Urheilijarahastosta maksettava palkka'
'PY' = 'Yritt‰j‰n palkka p‰‰toimesta (palkka teht‰v‰st‰, josta saaja on YEL- tai MYELvakuutettu)'
'YT' = 'YEL/MYEL-vakuutetun yritt‰j‰n tyˆpanokseen perustuva osinko tai ylij‰‰m‰ (palkkaa)'
'1Y' = 'Yritt‰j‰n palkka sivutoimesta (palkka teht‰v‰st‰, josta saaja on YEL- tai MYELvakuutettu)'
'SA' = 'Sairauskassan t‰ydennysp‰iv‰raha'
'5'  = 'Ns. 6 kuukauden s‰‰nnˆn alainen vakuutuspalkka'
'5Y' = 'Yritt‰j‰n 6 kk:n s‰‰nnˆn alainen palkka'
'6'  = 'Sijaismaksajan maksama palkka ja palkkaturva (EPL 9 ß 2 mom.)'
'61' = 'Sijaismaksajan maksama 6 kk:n s‰‰nnˆn alainen palkka'
'2'  = 'Merityˆtulo'
'2Y' = 'Yritt‰j‰n merityˆtulo'
'H'  = 'Tyˆkorvaus'
'HT' = 'Tyˆpanokseen perustuva osinko tai ylij‰‰m‰ (tyˆkorvausta)'
'H1' = 'Henkilˆstˆrahaston rahasto-osuus'
'H2' = 'Urheilijan palkkio'
'H3' = 'Perhehoitajan tai omaishoitajan palkkio ja kulukorvaus'
'H4' = 'Muu veronalaista ansiotuloa oleva suoritus'
'H5' = 'Yleishyˆdyllisen yhteisˆn maksama korvaus'
'H6' = 'Sovittelijan kulukorvaus'
'B'  = 'Tyˆnantajan maksama el‰ke'
'G'  = 'Ansiotuloa oleva k‰yttˆkorvaus'
'G1' = 'P‰‰omatulot (k‰yttˆkorvaus, palkkasaatavan korko tms.)'
'7K' = 'Tyˆnantajan (kiinte‰ toimipaikka Suomessa) maksama palkka tyˆntekij‰lle, joka ei ole Suomessa vakuutettu'
'7L' = 'Ulkomaisen tyˆnantajan (ei kiinte‰‰ toimipaikkaa Suomessa) maksama palkka tyˆntekij‰lle, joka ei ole Suomessa vakuutettu'
'7M' = 'Ulkomaisen tyˆnantajan (ei kiinte‰‰ toimipaikkaa Suomessa) maksama palkka Suomessa vakuutetulle tyˆntekij‰lle'
'7N' = 'Ulkomaisen tyˆnantajan (ei kiinte‰‰ toimipaikkaa Suomessa) maksama palkka tyˆntekij‰lle, kun tyˆnantaja maksaa tyˆntekij‰n puolesta verot (nettopalkkasopimus)'
'7Q' = 'Ulkomaisen tyˆnantajan (ei kiinte‰‰ toimipaikkaa Suomessa) maksama palkka tyˆntekij‰lle, joka on oleskellut Suomessa enint‰‰n 183 p‰iv‰‰ verosopimuksessa tarkoitettuna ajanjaksona';

/* TY÷NANTAJASEKTORI */

VALUE tsekt (NOTSORTED MULTILABEL)
1 = 'Yritykset'
2 = 'Rahoitus- ja vakuutuslaitokset'
3 = 'Kunnat ja kuntayhtym‰t'
4 = 'Kotitalouksia palvelevat voittoa tavoittelemattomat yhteisˆt'
5 = 'Kotitaloudet'
6 = 'Ulkomaat'
8 = 'Valtionhallinto ja sosiaaliturvarahastot'
9 = 'Asuntoyhteisˆt';

/* SUKUPUOLI */

VALUE $sp (NOTSORTED MULTILABEL)
'1' = 'Mies'
'2' = 'Nainen';

/* SIVIILISƒƒTY */

VALUE $sivs (NOTSORTED MULTILABEL)
'1' = 'Naimaton'
'2' = 'Avioliitossa, rekisterˆidyss‰ parisuhteessa tai asumuserossa'
'4' = 'Eronnut tai eronnut rekisterˆidyst‰ parisuhteesta'
'5' = 'Leski tai leski rekisterˆidyst‰ parisuhteesta';

/* TALOTYYPPI */

VALUE $talotyyp (NOTSORTED MULTILABEL)
'1' = 'Yhden asunnon pientalo'
'2' = 'Kahden asunnon pientalo'
'3' = 'Rivitalo tai ketjutalo'
'4' = 'Kerrostalo'
'5' = 'Muu rakennus (liike-, toimisto- ym.)'
'9' = 'Tuntematon';

/* SIVIILISƒƒTY (VEROREKISTERI) */

VALUE $csivs (NOTSORTED MULTILABEL)
'1' = 'Naimaton'
'2' = 'Avio- tai avoliitossa'
'3' = 'Asumuserossa'
'4' = 'Leski, tieto vain verovuonna leskeytyneill‰';

/* OPINTOTUEN TUKIAIKA */

VALUE $tukiaika (NOTSORTED MULTILABEL)
'1' = 'Syksy'
'2' = 'Kev‰t'
'3' = 'Kev‰t ja syksy';

/* ASUMISTUEN LAJI ASUMISTUKIREKISTERISSƒ */

VALUE $tt_asturek (NOTSORTED MULTILABEL)
'E' = 'El‰kkeensaajan asumistuki'
'O' = 'Opintotuen asumislis‰'
'Y' = 'Yleinen asumistuki';

/* ELƒKELAJI */

VALUE elakelaji (NOTSORTED MULTILABEL)
0 = 'Ei el‰kelajitietoa'
1 = 'Vanhuusel‰ke'
2 = 'Tyˆkyvyttˆmyysel‰ke (t‰ysi ja osael‰ke)'
3 = 'Perhe-el‰ke (edunsaajan mukaan)'
4 = 'Tyˆttˆmyysel‰ke'
5 = 'Maatalouden erityisel‰kkeet'
6 = 'Osa-aikael‰ke'
7 = 'Varhennettu vanhuusel‰ke'
8 = 'Yksilˆllinen varhaisel‰ke (tyˆkyvyttˆmyysel‰ke)'
9 = 'Kuntoutustuki (m‰‰r‰aikainen tyˆkyvyttˆmyysel‰ke)';

/* VUOKRA-ASUNNON HALLINTAPERUSTE */

VALUE vuoksaan (NOTSORTED MULTILABEL)
1 = 'Aravavuokra-asunto'
2 = 'Korkotukivuokra-asunto'
3 = 'Muu (vapaarahoitteinen) vuokra-asunto';

/* SUHDE VIITEHENKIL÷÷N */

VALUE asko (NOTSORTED MULTILABEL)
1 = 'Viitehenkilˆ'
2 = 'Viitehenkilˆn puoliso'
3 = 'Viitehenkilˆn tai puolison lapsi'
4 = 'Viitehenkilˆn tai puolison vanhempi'
5 = 'Muu sukulainen (sisar, veli, isovanhempi tai lapsenlapsi)'
6 = 'Muu henkilˆ';

/* PERHESUHDE KANSANELƒKKEESSƒ */

VALUE $tluokke (NOTSORTED MULTILABEL)
1 = 'Yksin asuva'
2 = 'Puolison kanssa asuva';

/* TY÷TT÷MYYSLAJI */

VALUE ttlaji (NOTSORTED MULTILABEL)
0 = 'Ei lajitietoa'
1 = 'Kokonaan tyˆtˆn'
2 = 'Kokonaan lomautettu'
3 = 'Lyhennetty tyˆviikko'
4 = 'Lyhennetty tyˆp‰iv‰'
5 = 'Osa-aikatyˆ'
6 = 'Satunnainen tyˆ'
7 = 'Yritystoiminta'
8 = 'Useita sovitteluperusteita'
9 = 'Soviteltu tai v‰hennetty etuus'
10 = 'S‰‰estep‰iv‰'
11 = 'T‰yten‰ maksettu etuus';

/* ELƒKKEENSAAJAN HOITOTUEN TASO */

VALUE ehtm (NOTSORTED MULTILABEL)
0 = 'Ei hoitotukea'
1 = 'Perushoitotuki'
2 = 'Korotettu hoitotuki'
3 = 'Ylin hoitotuki';

/* VAMMAISTUEN TASO */

VALUE lhtm (NOTSORTED MULTILABEL)
0 = 'Ei vammaistukea'
1 = 'Perusvammaistuki'
2 = 'Korotettu vammaistuki'
3 = 'Ylin vammaistuki';

RUN;

/* Haetaan pidemm‰t formaatit OHJAUS-kansion datoista */

/* ASUINKUNTA (luokitus tilastovuosi) */

DATA _ftemp_kunta_vanha;
	SET OHJAUS.fkunta(keep=koodi kunta rename=(koodi=start kunta=label));
	fmtname = '$kunta_vanha';
RUN;

PROC FORMAT CNTLIN=_ftemp_kunta_vanha;
RUN;

/* ASUINKUNTA (luokitus tilastovuosi + 1) */

DATA _ftemp_kunta_uusi;
	SET OHJAUS.fkunta(keep=koodi kunta rename=(koodi=start kunta=label));
	fmtname = '$kunta_uusi';
RUN;

PROC FORMAT CNTLIN=_ftemp_kunta_uusi;
RUN;

/* VALTIO */

DATA _ftemp_valtio;
	SET OHJAUS.fvaltio(keep=koodi maa rename=(koodi=start maa=label));
	fmtname = '$valtio';
RUN;

PROC FORMAT CNTLIN=_ftemp_valtio;
RUN;

/* MAANOSA */
/* Kolme luokitusta: maanosa = v‰hiten tarkka, maanosab = keskitaso, maanosac = tarkin */

DATA _ftemp_maanosa;
	SET OHJAUS.fvaltio(keep=koodi maanosa rename=(koodi=start maanosa=label));
	fmtname = '$maanosa';
RUN;

PROC FORMAT CNTLIN=_ftemp_maanosa;
RUN;

DATA _ftemp_maanosab;
	SET OHJAUS.fvaltio(keep=koodi maanosab rename=(koodi=start maanosab=label));
	fmtname = '$maanosab';
RUN;

PROC FORMAT CNTLIN=_ftemp_maanosab;
RUN;

DATA _ftemp_maanosac;
	SET OHJAUS.fvaltio(keep=koodi maanosac rename=(koodi=start maanosac=label));
	fmtname = '$maanosac';
RUN;

PROC FORMAT CNTLIN=_ftemp_maanosac;
RUN;

/* TARKKA KOULUTUSLUOKITUS */
/* Kolme luokitusta: koulaspitka = tarkin taso, koulutus2nro = kaksinumerotaso, koulutus1nro = yksinumerotaso (sama kuin muuttuja koulas) */

DATA _ftemp_koulaspitka;
	SET OHJAUS.fkoulutus(keep=koodi koulaspitka rename=(koodi=start koulaspitka=label));
	fmtname = '$koulaspitka';
RUN;

PROC FORMAT CNTLIN=_ftemp_koulaspitka;
RUN;

DATA _ftemp_koulutus2;
	SET OHJAUS.fkoulutus(keep=koodi koulutus2nro rename=(koodi=start koulutus2nro=label));
	fmtname = '$koulutus2nro';
RUN;

PROC FORMAT CNTLIN=_ftemp_koulutus2;
RUN;

DATA _ftemp_koulutus1;
	SET OHJAUS.fkoulutus(keep=koodi koulutus1nro rename=(koodi=start koulutus1nro=label));
	fmtname = '$koulutus1nro';
RUN;

PROC FORMAT CNTLIN=_ftemp_koulutus1;
RUN;

/* AMMATTIKOODI */
/* Kolme luokitusta: ammattikoodi = tarkin taso, ammatti2nro = kaksinumerotaso, ammatti1nro = yksinumerotaso */

DATA _ftemp_ammatti;
	SET OHJAUS.fammatti(keep=koodi ammattikoodi rename=(koodi=start ammattikoodi=label));
	fmtname = '$ammattikoodi';
RUN;

PROC FORMAT CNTLIN=_ftemp_ammatti;
RUN;

DATA _ftemp_ammatti2;
	SET OHJAUS.fammatti(keep=koodi ammatti2nro rename=(koodi=start ammatti2nro=label));
	fmtname = '$ammatti2nro';
RUN;

PROC FORMAT CNTLIN=_ftemp_ammatti2;
RUN;

DATA _ftemp_ammatti1;
	SET OHJAUS.fammatti(keep=koodi ammatti1nro rename=(koodi=start ammatti1nro=label));
	fmtname = '$ammatti1nro';
RUN;

PROC FORMAT CNTLIN=_ftemp_ammatti1;
RUN;

/* Poistetaan v‰liaikaistaulut */

PROC DATASETS LIB=WORK NOLIST;
	DELETE _ftemp:;
RUN;
QUIT;