/************************************************************
* Kuvaus: Vanhempainpäivärahojen esimerkkilaskelmien pohja	*
* Viimeksi päivitetty: 10.3.2021							*
************************************************************/  

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_VR = vanhraha_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lainsäädäntö ;
%LET VALITUT = _ALL_;	* Tulostaulukossa näytettävät muuttujat ;
%LET EROTIN = 2;		* Tulosteessa käytettävä desimaalierotin, 1 = piste tai 2 = pilkku;
%LET DESIMAALIT = 2;	* Tulosteessa käytettävä desimaalien määrä (0-9);
%LET EXCEL = 1;			* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;

* Inflaatiokorjaus. Euro- tai markkamääräisten parametrien haun yhteydessä suoritettavassa
  deflatoinnissa käytettävän kertoimen voi syöttää itse INF-makromuuttujaan
  (HUOM! desimaalit erotettava pisteellä .). Esim. jos yksi lainsäädäntövuoden euro on
  peruvuoden rahassa 95 senttiä, syötä arvoksi 0.95.
  Simuloinnin tulokset ilmoitetaan aina perusvuoden rahassa.
  Jos puolestaan haluaa käyttää automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

%LET INF = 1.00; * Syötä lukuarvo, KHI tai ATI;
%LET AVUOSI = 2021; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko ;

%LET ATIMUUNNOS = 0;	* Tehdäänkö palkoille ansiotasomuunnos ;
%LET PALKTASOV = 2021;  * Palkkatason referenssivuosi ;

* Seuraavalla optiolla voidaan laskea vuositulot niin, että vanhempainpäivärahapäiville
  annetaan keskimääräinen vanhempainpäiväraha ja muille päiville käytetään päivärahan perusteena
  olevaa palkkaa. Lisäksi lasketaan verotus ja nettotulot. Tuottaa erimuotoisen tulostaulukon
  kuin normaali simulointi. ;

%LET VRAHA_LASKE_VUOSITULOT = 0; * 0 = Lasketaan vain eri vanhempainrahajaksojen tiedot;
								 * 1 = Tehdään vuositulolaskenta ;

* Käytettävien tiedostojen nimet;
* HUOM! Tulonhakkimiskulujen vähentämistä varten tarvitaan myös VERO-mallin makroja ja parametreja; 

%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* SAIRVAK-lakimakrotiedoston nimi ;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;		* VERO-lakimakrotiedoston nimi ;
%LET PSAIRVAK = psairvak; * Käytettävän SAIRVAK-parametritiedoston nimi ;
%LET PVERO = pvero;		  * Käytettävän VERO-parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_VANHRAHA_VUOSI = 2021;
%LET MAKSIMI_VANHRAHA_VUOSI = 2021;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_VANHRAHA_KUUK = 12;
%LET MAKSIMI_VANHRAHA_KUUK = 12;

*Päivärahan perusteena oleva bruttopalkka ennen vähennyksiä (e/kk);
%LET MINIMI_VANHRAHA_PALKKA_AITI = 0; 
%LET MAKSIMI_VANHRAHA_PALKKA_AITI = 2000; 
%LET KYNNYS_VANHRAHA_PALKKA_AITI = 1000; 

*Onko yksinhuoltaja (0/1);
%LET VANHRAHA_YHAITI = 0;

*Isän pitämät isyysrahapäivät päällekkäin äidin kanssa (pv);
%LET VANHRAHA_ISAPAALPV = 0;

*Isän pitämät vanhempainrahapäivät (pv);
%LET VANHRAHA_ISAVANHPV = 0;

*Puolison palkka (e/kk);
%LET MINIMI_VANHRAHA_PALKKA_ISA = 0; 
%LET MAKSIMI_VANHRAHA_PALKKA_ISA = 2000; 
%LET KYNNYS_VANHRAHA_PALKKA_ISA = 1000; 

/* Tulonhankkimiskulut, ay-jäsenmaksut ja työmatkakulut vanhempainrahan perusteena olevan palkan laskemista varten */

/* Tulonhankkimiskulut (e/kk) */
%LET MINIMI_VANHRAHA_THANKKULUT_AITI = 0;
%LET MAKSIMI_VANHRAHA_THANKKULUT_AITI = 0;
%LET KYNNYS_VANHRAHA_THANKKULUT_AITI = 100;

/* Tulonhankkimiskulut, puoliso (e/kk) */
%LET MINIMI_VANHRAHA_THANKKULUT_ISA = 0;
%LET MAKSIMI_VANHRAHA_THANKKULUT_ISA = 0;
%LET KYNNYS_VANHRAHA_THANKKULUT_ISA = 100;

/* Ay-jäsenmaksut (e/kk) */
%LET MINIMI_VANHRAHA_AYMAKSUT_AITI = 0;
%LET MAKSIMI_VANHRAHA_AYMAKSUT_AITI = 0; 
%LET KYNNYS_VANHRAHA_AYMAKSUT_AITI = 10;

/* Ay-jäsenmaksut (e/kk), puoliso */
%LET MINIMI_VANHRAHA_AYMAKSUT_ISA = 0;
%LET MAKSIMI_VANHRAHA_AYMAKSUT_ISA = 0; 
%LET KYNNYS_VANHRAHA_AYMAKSUT_ISA = 10;

/* Työmatkakulut (e/kk) */
%LET MINIMI_VANHRAHA_TMKULUT_AITI = 0;
%LET MAKSIMI_VANHRAHA_TMKULUT_AITI = 0; 
%LET KYNNYS_VANHRAHA_TMKULUT_AITI = 200;

/* Työmatkakulut (e/kk), puoliso */
%LET MINIMI_VANHRAHA_TMKULUT_ISA = 0;
%LET MAKSIMI_VANHRAHA_TMKULUT_ISA = 0; 
%LET KYNNYS_VANHRAHA_TMKULUT_ISA = 200;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_VR;

DO VANHRAHA_VUOSI = &MINIMI_VANHRAHA_VUOSI TO &MAKSIMI_VANHRAHA_VUOSI;
DO VANHRAHA_KUUK = &MINIMI_VANHRAHA_KUUK TO &MAKSIMI_VANHRAHA_KUUK;
DO VANHRAHA_PALKKA_AITI = &MINIMI_VANHRAHA_PALKKA_AITI TO &MAKSIMI_VANHRAHA_PALKKA_AITI BY &KYNNYS_VANHRAHA_PALKKA_AITI;
DO VANHRAHA_THANKKULUT_AITI = &MINIMI_VANHRAHA_THANKKULUT_AITI TO &MAKSIMI_VANHRAHA_THANKKULUT_AITI BY &KYNNYS_VANHRAHA_THANKKULUT_AITI;
DO VANHRAHA_AYMAKSUT_AITI = &MINIMI_VANHRAHA_AYMAKSUT_AITI TO &MAKSIMI_VANHRAHA_AYMAKSUT_AITI BY &KYNNYS_VANHRAHA_AYMAKSUT_AITI;
DO VANHRAHA_TMKULUT_AITI = &MINIMI_VANHRAHA_TMKULUT_AITI TO &MAKSIMI_VANHRAHA_TMKULUT_AITI BY &KYNNYS_VANHRAHA_TMKULUT_AITI;
VANHRAHA_YHAITI = &VANHRAHA_YHAITI;

%IF &VANHRAHA_YHAITI = 0 %THEN %DO;
	DO HENKILO = 1 TO 2;
	DO VANHRAHA_ISAVANHPV = &VANHRAHA_ISAVANHPV;
	DO VANHRAHA_ISAPAALPV = &VANHRAHA_ISAPAALPV;
	DO VANHRAHA_PALKKA_ISA = &MINIMI_VANHRAHA_PALKKA_ISA TO &MAKSIMI_VANHRAHA_PALKKA_ISA BY &KYNNYS_VANHRAHA_PALKKA_ISA;
	DO VANHRAHA_THANKKULUT_ISA = &MINIMI_VANHRAHA_THANKKULUT_ISA TO &MAKSIMI_VANHRAHA_THANKKULUT_ISA BY &KYNNYS_VANHRAHA_THANKKULUT_ISA;
	DO VANHRAHA_AYMAKSUT_ISA = &MINIMI_VANHRAHA_AYMAKSUT_ISA TO &MAKSIMI_VANHRAHA_AYMAKSUT_ISA BY &KYNNYS_VANHRAHA_AYMAKSUT_ISA;
	DO VANHRAHA_TMKULUT_ISA = &MINIMI_VANHRAHA_TMKULUT_ISA TO &MAKSIMI_VANHRAHA_TMKULUT_ISA BY &KYNNYS_VANHRAHA_TMKULUT_ISA;
%END;
%ELSE %DO;
	HENKILO = 1;
	VANHRAHA_ISAVANHPV = 0;
	VANHRAHA_PALKKA_ISA = 0;
	VANHRAHA_THANKKULUT_ISA = 0;
	VANHRAHA_AYMAKSUT_ISA = 0;
	VANHRAHA_TMKULUT_ISA = 0;
%END;

DO TYYPPI= 1 TO 5;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, VANHRAHA_VUOSI, &INF);

/* Lasketaan mahdollinen palkkojen ansiotasomuunnos */
%IF &ATIMUUNNOS = 1 %THEN %DO;
	%InfKerroin_ESIM(&PALKTASOV, VANHRAHA_VUOSI, ATI, infnimi = ATI);
%END;
%ELSE %DO; 
	ATI = 1;
%END;

OUTPUT;

END;END;END;END;END;END;END;

%IF &VANHRAHA_YHAITI=0 %THEN %DO;
	END;END;END;END;END;END;END;
%END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO Vanhraha_Simuloi_Esimerkki;
/* SAIRVAK-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL SAIRVAK_PARAM SAIRVAK_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(SAIRVAK_PARAM, SAIRVAK);
%HaeLaskettavatLokaalit(SAIRVAK_MUUNNOS, SAIRVAK);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &SAIRVAK_PARAM;

/* VERO-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL VERO_PARAM VERO_MUUNNOS VERO2_PARAM VERO2_MUUNNOS VERO_JOHDETUT;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(VERO_PARAM, VERO);
%HaeLaskettavatLokaalit(VERO_MUUNNOS, VERO);

/* Haetaan varallisuusveron käyttämien lakiparametrien nimet */
%HaeLokaalit(VERO2_PARAM, VERO_VARALL);
%HaeLaskettavatLokaalit(VERO2_MUUNNOS, VERO_VARALL, indikaattori='z');

/* Haetaan johdettavien muuttujien nimet */
%HaeLaskettavatLokaalit(VERO_JOHDETUT, VERO, indikaattori='j');

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &VERO_PARAM &VERO2_PARAM &VERO_JOHDETUT;
DATA OUTPUT.&TULOSNIMI_VR;
SET OUTPUT.&TULOSNIMI_VR;
where henkilo=2 or tyyppi ne 5;

/* Lakimakroissa tulokäsitteenä on vuositulo */
IF HENKILO = 1 THEN VANHRAHA_PALKKA = VANHRAHA_PALKKA_AITI/ATI;
ELSE VANHRAHA_PALKKA = VANHRAHA_PALKKA_ISA/ATI;

/* 3.2.1 Lasketaan tulonhankkimiskulut vuositasolla */

IF HENKILO = 1 THEN DO;
%TulonHankKulutS(SVHANKVAH, VANHRAHA_VUOSI, INF, 12*SUM(VANHRAHA_PALKKA),
		12*VANHRAHA_THANKKULUT_AITI, 12*VANHRAHA_AYMAKSUT_AITI, 12*VANHRAHA_TMKULUT_AITI, 0);
END;

IF HENKILO = 2 THEN DO;
%TulonHankKulutS(SVHANKVAH, VANHRAHA_VUOSI, INF, 12*SUM(VANHRAHA_PALKKA),
		12*VANHRAHA_THANKKULUT_ISA, 12*VANHRAHA_AYMAKSUT_ISA, 12*VANHRAHA_TMKULUT_ISA, 0);
END;

/* Vuodesta 2020 eteenpäin päivärahan laskennassa ei huomioida tulonhankkimiskuluja */

IF VANHRAHA_VUOSI >= 2020 THEN DO;
	SVHANKVAH = 0;
END;

/* 3.2.2 Päivärahojen laskenta */

IF HENKILO = 1 THEN DO;
	IF &VUOSIKA = 1 THEN DO;
		%VanhPRahaVS (PAIVARAHA, VANHRAHA_VUOSI, INF, (TYYPPI=1), (TYYPPI=3), (TYYPPI IN (2,4)), 0, VANHRAHA_PALKKA*12, tulonhankk=SVHANKVAH);
	END;
	ELSE DO;
		%VanhPRahaKS (PAIVARAHA, VANHRAHA_VUOSI, VANHRAHA_KUUK, INF, (TYYPPI=1), (TYYPPI=3), (TYYPPI IN (2,4)), 0, VANHRAHA_PALKKA*12, tulonhankk=SVHANKVAH);
	END;
END;

IF HENKILO=2 THEN DO;
	IF &VUOSIKA = 1 THEN DO;
		%VanhPRahaVS (PAIVARAHA, VANHRAHA_VUOSI, INF, 0, (TYYPPI IN (2,4)), (TYYPPI in (1,3,5)), 0, VANHRAHA_PALKKA*12, tulonhankk=SVHANKVAH);
	END;
	ELSE DO;
		%VanhPRahaKS (PAIVARAHA, VANHRAHA_VUOSI, VANHRAHA_KUUK, INF, 0, (TYYPPI IN (2,4)), (TYYPPI in (1,3,5)), 0, VANHRAHA_PALKKA*12, tulonhankk=SVHANKVAH);
	END;
END;

IF HENKILO=1 THEN DO;
	HENK='ÄITI';
	select (tyyppi);
		WHEN (1) PAIVLKM = &Aitkorpv;
		WHEN (2) PAIVLKM = &Aitiysrpv-&Aitkorpv;
		WHEN (3) PAIVLKM = MAX(0,MIN(&Vanhkorpv,&Vanhemrpv-VANHRAHA_ISAVANHPV));
		WHEN (4) PAIVLKM = MAX(0,&Vanhemrpv-VANHRAHA_ISAVANHPV-&Vanhkorpv);
	END;
	select (tyyppi);
		WHEN (1) SELITE='KOR. ÄITIYSRAHA';
		WHEN (2) SELITE='NOR. ÄITIYSRAHA';
		WHEN (3) SELITE='KOR. VANHEMPAINRAHA';
		WHEN (4) SELITE='NOR. VANHEMPAINRAHA';
	END;
END;
ELSE DO;
	HENK='ISÄ';
	IF TYYPPI=1 THEN PAIVLKM=MIN(VANHRAHA_ISAPAALPV,&Isyjaetpv);
	ELSE IF TYYPPI=2 THEN PAIVLKM=MAX(0,MIN(&Vanhkorpv,VANHRAHA_ISAVANHPV));
	ELSE IF TYYPPI=3 THEN PAIVLKM=MAX(0,MIN(VANHRAHA_ISAVANHPV,&Vanhemrpv)-&Vanhkorpv);
	ELSE IF TYYPPI=4 THEN DO;
		IF VANHRAHA_VUOSI>=2013 THEN PAIVLKM=(VANHRAHA_ISAVANHPV>=&Isyehtopv) * MIN(SUM(&Isyysrpv,-MIN(VANHRAHA_ISAPAALPV,&Isyjaetpv)),MAX(0,&Vanhkorpv-VANHRAHA_ISAVANHPV));
		ELSE PAIVLKM=(VANHRAHA_ISAVANHPV>=&Isyehtopv) * MIN(SUM(&Isyysrpv,-&Isyjaetpv),MAX(0,&Vanhkorpv-VANHRAHA_ISAVANHPV));
	END;
	ELSE IF TYYPPI=5 THEN DO;
		IF VANHRAHA_VUOSI>=2013 THEN PAIVLKM=(VANHRAHA_ISAVANHPV>=&Isyehtopv) * MAX(0, SUM(&Isyysrpv,-MIN(VANHRAHA_ISAPAALPV,&Isyjaetpv),-MAX(0,&Vanhkorpv-VANHRAHA_ISAVANHPV)));
		ELSE PAIVLKM=(VANHRAHA_ISAVANHPV>=&Isyehtopv) * MAX(0, SUM(&Isyysrpv,-&Isyjaetpv,-MAX(0,&Vanhkorpv-VANHRAHA_ISAVANHPV)));
	END;
	select (tyyppi);
		WHEN (1) SELITE='ISYYSRAHA';
		WHEN (2) SELITE='KOR. VANHEMPAINRAHA';
		WHEN (3) SELITE='NOR. VANHEMPAINRAHA';
		WHEN (4) SELITE='KOR. ISYYSRAHA2';
		WHEN (5) SELITE='ISYYSRAHA2';
	END;
END;

FORMAT PAIVARAHA ATI INF 10.2 VANHRAHA_PALKKA 10.0;
IF NOT PAIVLKM THEN DELETE;

DROP kuuknro w y z testi kkuuk taulu_&PSAIRVAK taulu_&PVERO HENKILO tyyppi VANHRAHA_ISAVANHPV VANHRAHA_ISAPAALPV;

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
HENK = 'Henkilö, (isä/äiti)'
VANHRAHA_VUOSI = 'Lainsäädäntövuosi'
VANHRAHA_KUUK = 'Lainsäädäntökuukausi'
VANHRAHA_PALKKA_AITI = 'Äidin syötetty bruttopalkka ennen vähennyksiä, (e/kk)'
VANHRAHA_THANKKULUT_AITI = 'Äidin tulonhankkimiskulut, (e/kk)'
VANHRAHA_AYMAKSUT_AITI = 'Äidin ay-maksut, (e/kk)'
VANHRAHA_TMKULUT_AITI = 'Äidin työmatkakulut, (e/kk)'
VANHRAHA_YHAITI = 'Onko yksinhuoltaja, (0/1)'
VANHRAHA_ISAPAALPV = 'Isän pitämät isyysrahapäivät päällekkäin äidin kanssa, (pv)'
VANHRAHA_ISAVANHPV = 'Isän pitämät vanhempainrahapäivät, (pv)'
VANHRAHA_PALKKA_ISA = 'Puolison syötetty bruttopalkka ennen vähennyksiä, (e/kk)'
VANHRAHA_THANKKULUT_ISA = 'Puolison tulonhankkimiskulut, (e/kk)'
VANHRAHA_AYMAKSUT_ISA = 'Puolison ay-maksut, (e/kk)'
VANHRAHA_TMKULUT_ISA = 'Puolison työmatkakulut, (e/kk)'
SVHANKVAH = 'Päivärahan laskennassa vähennetyt tulonhankkimiskulut (e/v)'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'
PAIVARAHA = 'Päiväraha, (e/pv)'
SELITE = 'Päivärahan tyyppi';

KEEP &VALITUT;

%IF &VRAHA_LASKE_VUOSITULOT = 1 %THEN %DO;

PROC SUMMARY DATA =OUTPUT.&TULOSNIMI_VR NWAY;
	CLASS HENK VANHRAHA_VUOSI VANHRAHA_KUUK VANHRAHA_PALKKA_AITI VANHRAHA_THANKKULUT_AITI VANHRAHA_AYMAKSUT_AITI VANHRAHA_TMKULUT_AITI
		VANHRAHA_PALKKA_ISA VANHRAHA_THANKKULUT_ISA VANHRAHA_AYMAKSUT_ISA VANHRAHA_TMKULUT_ISA;
	WEIGHT PAIVLKM;
	ID VANHRAHA_YHAITI ATI INF VANHRAHA_PALKKA SVHANKVAH;
	OUTPUT OUT=OUTPUT.&TULOSNIMI_VR(DROP=_TYPE_ _FREQ_) MEAN(PAIVARAHA)= SUMWGT(PAIVARAHA)=PAIVLKM;
RUN;

DATA OUTPUT.&TULOSNIMI_VR; SET OUTPUT.&TULOSNIMI_VR;

%TuloVerot_Simple_PRahTyoS(VEROT, VANHRAHA_VUOSI, 1, PAIVLKM*PAIVARAHA, (300-PAIVLKM)/25*VANHRAHA_PALKKA, VANHRAHA_YHAITI, 1);

VUOSITULO_BRUTTO=PAIVLKM*PAIVARAHA+(300-PAIVLKM)/25*VANHRAHA_PALKKA;
VUOSITULO_NETTO=VUOSITULO_BRUTTO-VEROT;
VEROPROS=100*VEROT/VUOSITULO_BRUTTO;

PAIVARAHA=PAIVARAHA*INF;
VUOSITULO_BRUTTO=VUOSITULO_BRUTTO*INF;
VUOSITULO_NETTO=VUOSITULO_NETTO*INF;

DROP kuuknro--testi  VANHRAHA_YHAITI;
%END;

LABEL
ATI = 'Ansiotasoindeksi'
VUOSITULO_BRUTTO = 'Bruttotulot, (e/v)'
VUOSITULO_NETTO = 'Nettotulo, (e/v)'
VEROT = 'Maksetut verot, (e/v)'
VEROPROS = 'Veroprosentti, (%)'
PAIVLKM = 'Päivärahapäivien lukumäärä, (pv)'
VANHRAHA_PALKKA = 'Päivärahan perusteena oleva bruttopalkka ennen vähennyksiä, (e/kk)'
SVHANKVAH = 'Päivärahan laskennassa vähennetyt tulonhankkimiskulut, (e/v)';
;

/* Määritellään formaatilla haluttu desimaalierotin  */
/* ja näytettävien desimaalien lukumäärä */

%IF &EROTIN = 1 %THEN %DO;
	FORMAT _NUMERIC_ 1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF ATI 8.5;
%END;

%IF &EROTIN = 2 %THEN %DO;
	FORMAT _NUMERIC_ NUMx1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF ATI NUMx8.5;
%END;

/* Kokonaislukuina ne muuttujat, joissa ei haluta käyttää desimaalierotinta */

FORMAT VANHRAHA_VUOSI VANHRAHA_KUUK PAIVLKM 8.;

KEEP &VALITUT;

%IF &VUOSIKA NE 2 %THEN %DO;
	DROP VANHRAHA_KUUK;
%END;

%IF &VRAHA_LASKE_VUOSITULOT = 0 %THEN %DO;
	DROP VUOSITULO_BRUTTO VUOSITULO_NETTO VEROT VEROPROS;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_VR, VANHRAHA);

%MEND Vanhraha_Simuloi_Esimerkki;

%Vanhraha_Simuloi_Esimerkki;
