/***********************************************************
* Kuvaus: Opintotuen simulointimalli 2018             	   *
* Viimeksi p‰ivitetty: 06.01.2021 			   		       *
***********************************************************/ 

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = OPINTUKI;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, k‰ytet‰‰n siell‰ m‰‰riteltyj‰ ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, k‰ytet‰‰n alla syˆtettyj‰ ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2019;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2019;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;
							* Huomaa kuitenkin, ett‰ asumislis‰n laskemisessa k‰ytet‰‰n oletuksena sek‰ lains‰‰d‰ntˆvuoden alun
							  ett‰ lopun parametriarvoja;

	%LET AINEISTO = REK;	* K‰ytett‰v‰ aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_OT = opintuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Euro- tai markkam‰‰r‰isten parametrien haun yhteydess‰ suoritettavassa
	  deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse INF-makromuuttujaan
	  (HUOM! desimaalit erotettava pisteell‰ .). Esim. jos yksi lains‰‰d‰ntˆvuoden euro on
	  aineistovuoden rahassa 95 sentti‰, syˆt‰ arvoksi 0.95.
	  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
	  Jos puolestaan haluaa k‰ytt‰‰ automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
	  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
	  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

	%LET INF = 1.00; * Syˆt‰ lukuarvo, KHI tai ATI;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;

	* Ajettavat osavaiheet ; 

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET POPINTUKI = popintuki; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT = TUKIKESK opirake TUKIKOR opirako ASUMLISA hasuli OPLAIN hopila; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 2;		 * Tulostaulukoiden yksikkˆ (1 = henkilˆ, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilˆluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavu (ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilˆluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilˆluokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavuv (viitehenkilˆn mukaiset ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilˆn koulutusaste)
							     paasoss (viitehenkilˆn sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		 * Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhj‰, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukum‰‰r‰t ;
	%LET SUM = SUM; 
	%LET MIN = ; 
	%LET MAX = ;
	%LET RANGE = ;
	%LET MEAN = ;
	%LET MEDIAN = ;
	%LET MODE = ;
	%LET VAR = ;
	%LET CV =  ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	* K‰ytett‰v‰ painokerroin (jos tyhj‰, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj‰, niin ei rajauksia);

	%END;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO OpinTuki_Muutt_Poiminta; 

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_OPINTUKI */

	DATA STARTDAT.START_OPINTUKI; 
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro ikavu ikakk tkopira opirako opirake hasuli svatva svatvp apuraha tukiaika optukk
	aloituspvm cllkm ASKUST_LASK TUKIAIKA_KESK TUKIAIKA_KOR TAYSIM_KESK TAYSIM_KOR KOTONA_AS yrvah
	);

	WHERE (tkopira > 0 OR opirako NE 0 OR opirake NE 0 OR hasuli NE 0);

	/* 2.2 Lis‰t‰‰n aineistoon apumuuttujia */ 

	* M‰‰ritell‰‰n opintotuen ik‰luokka;

	%IkaKuuk(IALLE17KUUK, 0, 16, SUM(12 * ikavu, ikakk));
	%IkaKuuk(I17KUUK, 17, 17, SUM(12 * ikavu, ikakk));
	%IkaKuuk(I18KUUK, 18, 18, SUM(12 * ikavu, ikakk));
	%IkaKuuk(I19KUUK, 19, 19, SUM(12 * ikavu, ikakk));

	IF IALLE17KUUK > 6 THEN IKA = 16;
	ELSE IF I17KUUK > 6 THEN IKA = 17;
	ELSE IF I18KUUK > 6 THEN IKA = 18;
	ELSE IF I19KUUK > 6 THEN IKA = 19;
	ELSE IKA = ikavu;

	* Lasketaan datasta opiskelijan omat veronalaiset tulot ja apurahat ; 

	OMA_TULO = SUM(svatva, svatvp, apuraha, yrvah);

	DROP IALLE17KUUK I17KUUK I18KUUK I19KUUK ikavu ikakk tkopira svatva svatvp apuraha yrvah;

	RUN;

	/* 2.2.2 Lasketaan vanhempien veronalaiset tulot yhteen taulukkoon OPINTUKI_VANH */ 

	PROC SQL; 
	CREATE TABLE TEMP.OPINTUKI_VANH AS SELECT knro, SUM(SUM(svatva, svatvp, yrvah, 0)) AS VANH_TULO1,	/* 1.8.2019 j‰lkeen k‰ytett‰v‰ tulok‰site (veronalaiset ansio- ja p‰‰omatulot) */
													SUM(SUM(svatvap, svatpp, 0)) AS VANH_TULO2	/* Ennen 1.8.2019 k‰ytetty tulok‰site (puhtaat ansio- ja p‰‰omatulot) */
	FROM POHJADAT.&AINEISTO&AVUOSI
	WHERE asko IN (1, 2) AND knro IN (SELECT knro FROM STARTDAT.START_OPINTUKI WHERE KOTONA_AS = 1)
	GROUP BY knro;
	QUIT;

	/* 2.2.3 Siirret‰‰n tieto vanhempien tuloista takaisin taulukkoon START_OPINTUKI */
	DATA STARTDAT.START_OPINTUKI ;
	MERGE STARTDAT.START_OPINTUKI TEMP.OPINTUKI_VANH;
	BY knro;
	IF VANH_TULO1 = . THEN VANH_TULO1 = 0;
	IF VANH_TULO2 = . THEN VANH_TULO2 = 0;

	/* 2.2.4 Lasketaan opiskelijoille uusi opiskelun aloitusp‰iv‰m‰‰r‰ LVUOSI-AVUOSI erotuksesta*/
	aloituspvm = MDY(Month(aloituspvm), 1, (Year(aloituspvm) + &LVUOSI - &AVUOSI));

	/* 2.2.5 Luodaan ONHUOLTAJA-muuttuja, joka kertoo, onko henkilˆ alaik‰isen lapsen huoltaja vai ei */
	ONHUOLTAJA = IFN(cllkm > 0, 1, 0);

	/* 2.3 Luodaan uusille apumuuttujille selkokieliset kuvaukset */

	LABEL
	KOTONA_AS = 'Vanhempien luona asuminen (0/1), DATA'
	IKA = 'Opintotuen ik‰luokka, DATA'
	TUKIAIKA_KESK = 'Keskiasteen tukikuukaudet, DATA'
	TUKIAIKA_KOR ='Korkeakouluopintojen opintojen tukikuukaudet, DATA'
	TAYSIM_KESK ='Keskiasteen tuen t‰ysi‰ monikertoja vastaavat tukikuukaudet, DATA'
	TAYSIM_KOR ='Korkea-asteen tuen t‰ysi‰ monikertoja vastaavat tukikuukaudet, DATA'
	OMA_TULO = 'Opiskelijan omat veronalaiset tulot ja apurahat (e/v), DATA'
	VANH_TULO1 = 'Vanhempien veronalaiset ansio- ja p‰‰omatulot (e/v), DATA'
	VANH_TULO2 = 'Vanhempien puhtaat ansio- ja p‰‰omatulot (e/v), DATA'
	ONHUOLTAJA = "Alaik‰isen lapsen huoltaja (0/1), DATA";

	RUN;

%END;

%MEND OpinTuki_Muutt_Poiminta;

%OpinTuki_Muutt_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe */

%MACRO OpinTuki_Simuloi_Data;

/* OPINTUKI-mallin parametrit */
%LOCAL OPINTUKI_PARAM OPINTUKI_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(OPINTUKI_PARAM, OPINTUKI);
%HaeLaskettavatLokaalit(OPINTUKI_MUUNNOS, OPINTUKI);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &OPINTUKI_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */
%KuukSimul(OPINTUKI);

DATA TEMP.&TULOSNIMI_OT;
SET STARTDAT.START_OPINTUKI;

* Keskiasteen opiskelijan opintoraha;

* Huomioidaan vanhempien tulot vain jos opiskelija ei ole saanut tukea t‰ysim‰‰r‰isen‰;
VANH_TULO_KESK1 = IFN(TAYSIM_KESK = 1, 0, VANH_TULO1);
VANH_TULO_KESK2 = IFN(TAYSIM_KESK = 1, 0, VANH_TULO2);

IF opirake > 0 THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaVS(OPRAHAKES, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, VANH_TULO_KESK1, VANH_TULO_KESK2, 0, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKESK = TUKIAIKA_KESK * OPRAHAKES;

	/* Ilman huoltajakorotusta */
	%OpRahaVS(OPRAHAKES_ILMHUOLT, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, VANH_TULO_KESK1, VANH_TULO_KESK2, 0, huoltaja=0, oppimateriaali=1);
	TUKIKESK_ILMHUOLT = TUKIAIKA_KESK * OPRAHAKES_ILMHUOLT;

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKES_ILMOP, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, VANH_TULO_KESK1, VANH_TULO_KESK2, 0, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKESK_ILMOP = TUKIAIKA_KESK * OPRAHAKES_ILMOP;

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKES_ILMHUOLTOP, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, VANH_TULO_KESK1, VANH_TULO_KESK2, 0, huoltaja=0, oppimateriaali=0);
	TUKIKESK_ILMHUOLTOP = TUKIAIKA_KESK * OPRAHAKES_ILMHUOLTOP;

END;


* Korkeakouluopiskelijan opintoraha;

* Huomioidaan vanhempien tulot vain jos opiskelija ei ole saanut tukea t‰ysim‰‰r‰isen‰;
VANH_TULO_KOR1 = IFN(TAYSIM_KOR = 1, 0, VANH_TULO1);
VANH_TULO_KOR2 = IFN(TAYSIM_KOR = 1, 0, VANH_TULO2);

* Lasketaan korkeakouluopiskelijan opintoraha (jos 9 kk);

IF  (opirako > 0 AND TUKIAIKA_KOR = 9) THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaKS(OPRAHAKOR1, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR2, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR3, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKOR = SUM(5 * OPRAHAKOR1, 2 * OPRAHAKOR2, 2 * OPRAHAKOR3);

	/* Ilman huoltajakorotusta */
	%OpRahaKS(OPRAHAKOR1_ILMHUOLT, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR2_ILMHUOLT, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR3_ILMHUOLT, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	TUKIKOR_ILMHUOLT = SUM(5 * OPRAHAKOR1_ILMHUOLT, 2 * OPRAHAKOR2_ILMHUOLT, 2 * OPRAHAKOR3_ILMHUOLT);

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR1_ILMOP, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR2_ILMOP, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR3_ILMOP, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKOR_ILMOP = SUM(5 * OPRAHAKOR1_ILMOP, 2 * OPRAHAKOR2_ILMOP, 2 * OPRAHAKOR3_ILMOP);

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR1_ILMHUOLTOP, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR2_ILMHUOLTOP, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR3_ILMHUOLTOP, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	TUKIKOR_ILMHUOLTOP = SUM(5 * OPRAHAKOR1_ILMHUOLTOP, 2 * OPRAHAKOR2_ILMHUOLTOP, 2 * OPRAHAKOR3_ILMHUOLTOP);

END;

* Lasketaan korkeakouluopiskelijan opintoraha (jos ei 9 kk, keskiarvo) ;

ELSE IF (opirako > 0 AND tukiaika = 3) THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaVS(OPRAHAKOR4, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKOR = TUKIAIKA_KOR * OPRAHAKOR4;

	/* Ilman huoltajakorotusta */
	%OpRahaVS(OPRAHAKOR4_ILMHUOLT, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	TUKIKOR_ILMHUOLT = TUKIAIKA_KOR * OPRAHAKOR4_ILMHUOLT;

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKOR4_ILMOP, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKOR_ILMOP = TUKIAIKA_KOR * OPRAHAKOR4_ILMOP;

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKOR4_ILMHUOLTOP, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	TUKIKOR_ILMHUOLTOP = TUKIAIKA_KOR * OPRAHAKOR4_ILMHUOLTOP;

END;

* Lasketaan korkeakouluopiskelijan opintoraha (kev‰tlukukausi) ;

ELSE IF (opirako > 0 AND tukiaika = 2) THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaKS(OPRAHAKOR5, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKOR = TUKIAIKA_KOR * OPRAHAKOR5;

	/* Ilman huoltajakorotusta */
	%OpRahaKS(OPRAHAKOR5_ILMHUOLT, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	TUKIKOR_ILMHUOLT = TUKIAIKA_KOR * OPRAHAKOR5_ILMHUOLT;

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR5_ILMOP, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKOR_ILMOP = TUKIAIKA_KOR * OPRAHAKOR5_ILMOP;

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR5_ILMHUOLTOP, &LVUOSI, 1, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	TUKIKOR_ILMHUOLTOP = TUKIAIKA_KOR * OPRAHAKOR5_ILMHUOLTOP;

END;

* Lasketaan korkeakouluopiskelijan opintoraha (4 kk syyslukukausi) ;

ELSE IF (opirako > 0 AND TUKIAIKA_KOR = 4 AND tukiaika = 1) THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaKS(OPRAHAKOR6, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR7, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKOR = SUM(2 * OPRAHAKOR6, 2 * OPRAHAKOR7);

	/* Ilman huoltajakorotusta */
	%OpRahaKS(OPRAHAKOR6_ILMHUOLT, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	%OpRahaKS(OPRAHAKOR7_ILMHUOLT, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	TUKIKOR_ILMHUOLT = SUM(2 * OPRAHAKOR6_ILMHUOLT, 2 * OPRAHAKOR7_ILMHUOLT);

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR6_ILMOP, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR7_ILMOP, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKOR_ILMOP = SUM(2 * OPRAHAKOR6_ILMOP, 2 * OPRAHAKOR7_ILMOP);

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaKS(OPRAHAKOR6_ILMHUOLTOP, &LVUOSI, 9, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	%OpRahaKS(OPRAHAKOR7_ILMHUOLTOP, &LVUOSI, 11, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	TUKIKOR_ILMHUOLTOP = SUM(2 * OPRAHAKOR6_ILMHUOLTOP, 2 * OPRAHAKOR7_ILMHUOLTOP);

END;

* Lasketaan korkeakouluopiskelijan opintoraha (syyslukukausi, ei 4 kk);

ELSE IF (opirako > 0 AND TUKIAIKA_KOR > 0 AND TUKIAIKA_KOR NE 4 AND tukiaika = 1) THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpRahaVS(OPRAHAKOR8, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=1);
	TUKIKOR = TUKIAIKA_KOR * OPRAHAKOR8;

	/* Ilman huoltajakorotusta */
	%OpRahaVS(OPRAHAKOR8_ILMHUOLT, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=1);
	TUKIKOR_ILMHUOLT = TUKIAIKA_KOR * OPRAHAKOR8_ILMHUOLT;

	/* Ilman oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKOR8_ILMOP, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=ONHUOLTAJA, oppimateriaali=0);
	TUKIKOR_ILMOP = TUKIAIKA_KOR * OPRAHAKOR8_ILMOP;

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpRahaVS(OPRAHAKOR8_ILMHUOLTOP, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO_KOR1, VANH_TULO_KOR2, 0, aloituspvm=aloituspvm, huoltaja=0, oppimateriaali=0);
	TUKIKOR_ILMHUOLTOP = TUKIAIKA_KOR * OPRAHAKOR8_ILMHUOLTOP;

END;


* Opintotuen asumislis‰;

* Lasketaan opintotuen asumislis‰ (jos 9 kk) ;

IF TUKIKOR > 0 THEN TUKIKORAPU = 1;
ELSE TUKIKORAPU = 0;

IF (hasuli NE 0 AND optukk = 9) THEN DO;

	%AsumLisaKS(ASLIS1, &LVUOSI, 1, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0); 
	%AsumLisaKS(ASLIS2, &LVUOSI, 9, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0); 
	%AsumLisaKS(ASLIS3, &LVUOSI, 11, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);

	ASUMLISA = SUM(5 * ASLIS1, 2 * ASLIS2, 2 * ASLIS3);

END;

* Lasketaan opintotuen asumislis‰ (jos ei 9 kk, keskiarvo) ;

ELSE IF (hasuli NE 0 AND tukiaika = 3) THEN DO;

	%AsumLisaVS(ASLIS4, &LVUOSI, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);

	ASUMLISA = optukk * ASLIS4;

END;

* Lasketaan opintotuen asumislis‰ (kev‰tlukukausi) ;

ELSE IF (hasuli NE 0 AND tukiaika = 2) THEN DO;

	%AsumLisaKS(ASLIS5, &LVUOSI, 1, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);

	ASUMLISA = optukk * ASLIS5;

END;

* Lasketaan opintotuen asumislis‰ (4 kk syyslukukausi) ;

ELSE IF (hasuli NE 0 AND optukk = 4 AND tukiaika = 1) THEN DO;

	%AsumLisaKS(ASLIS6, &LVUOSI, 9, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);
	%AsumLisaKS(ASLIS7, &LVUOSI, 11, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);

	ASUMLISA = SUM(2 * ASLIS6, 2 * ASLIS7);

END;

* Lasketaan opintotuen asumislis‰ (syyslukukausi, ei 4 kk);

ELSE IF hasuli NE 0 AND optukk > 0 AND optukk NE 4 AND tukiaika = 1 THEN DO;

	%AsumLisaKS(ASLIS8, &LVUOSI, 9, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0, 0);

	ASUMLISA = optukk * ASLIS8;

END;


* Lasketaan mahdollinen (potentiaalinen) opintolainan valtiontakaus ;

%OpLainaVS(OPLAIV1, &LVUOSI, &INF, 0, 0, IKA);
%OpLainaVS(OPLAIV2, &LVUOSI, &INF, 1, 0, IKA);

OPLAIN = SUM(TUKIAIKA_KESK * OPLAIV1, TUKIAIKA_KOR * OPLAIV2);

* Lasketaan opintotuen takaisinperint‰ ; 

IF tukiaika < 3 THEN DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpTukiTakaisinS(TUKIKESK_TAK, &LVUOSI, 1, &INF, TUKIAIKA_KESK, 0.5 * SUM(OMA_TULO, -TUKIKESK), TUKIKESK);
	%OpTukiTakaisinS(TUKIKOR_TAK, &LVUOSI, 1, &INF, TUKIAIKA_KOR, 0.5 * SUM(OMA_TULO, -TUKIKOR), TUKIKOR);

	/* Ilman huoltajakorotusta */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMHUOLT, &LVUOSI, 1, &INF, TUKIAIKA_KESK, 0.5 * SUM(OMA_TULO, -TUKIKESK_ILMHUOLT), TUKIKESK_ILMHUOLT);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMHUOLT, &LVUOSI, 1, &INF, TUKIAIKA_KOR, 0.5 * SUM(OMA_TULO, -TUKIKOR_ILMHUOLT), TUKIKOR_ILMHUOLT);

	/* Ilman oppimateriaalilis‰‰ */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMOP, &LVUOSI, 1, &INF, TUKIAIKA_KESK, 0.5 * SUM(OMA_TULO, -TUKIKESK_ILMOP), TUKIKESK_ILMOP);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMOP, &LVUOSI, 1, &INF, TUKIAIKA_KOR, 0.5 * SUM(OMA_TULO, -TUKIKOR_ILMOP), TUKIKOR_ILMOP);

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMHUOLTOP, &LVUOSI, 1, &INF, TUKIAIKA_KESK, 0.5 * SUM(OMA_TULO, -TUKIKESK_ILMHUOLTOP), TUKIKESK_ILMHUOLTOP);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMHUOLTOP, &LVUOSI, 1, &INF, TUKIAIKA_KOR, 0.5 * SUM(OMA_TULO, -TUKIKOR_ILMHUOLTOP), TUKIKOR_ILMHUOLTOP);

	%OpTukiTakaisinS(ASUMLISA_TAK, &LVUOSI, 1, &INF, optukk, 0.5 * SUM(OMA_TULO, -TUKIKOR, -TUKIKESK), ASUMLISA);

END;

ELSE DO;

	/* Mahdollisen huoltajakorotuksen ja oppimateriaalilis‰n kanssa */
	%OpTukiTakaisinS(TUKIKESK_TAK, &LVUOSI, 1, &INF, TUKIAIKA_KESK, SUM(OMA_TULO, -TUKIKESK), TUKIKESK);
	%OpTukiTakaisinS(TUKIKOR_TAK, &LVUOSI, 1, &INF, TUKIAIKA_KOR, SUM(OMA_TULO, -TUKIKOR), TUKIKOR);

	/* Ilman huoltajakorotusta */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMHUOLT, &LVUOSI, 1, &INF, TUKIAIKA_KESK, SUM(OMA_TULO, -TUKIKESK_ILMHUOLT), TUKIKESK_ILMHUOLT);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMHUOLT, &LVUOSI, 1, &INF, TUKIAIKA_KOR, SUM(OMA_TULO, -TUKIKOR_ILMHUOLT), TUKIKOR_ILMHUOLT);

	/* Ilman oppimateriaalilis‰‰ */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMOP, &LVUOSI, 1, &INF, TUKIAIKA_KESK, SUM(OMA_TULO, -TUKIKESK_ILMOP), TUKIKESK_ILMOP);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMOP, &LVUOSI, 1, &INF, TUKIAIKA_KOR, SUM(OMA_TULO, -TUKIKOR_ILMOP), TUKIKOR_ILMOP);

	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	%OpTukiTakaisinS(TUKIKESK_TAK_ILMHUOLTOP, &LVUOSI, 1, &INF, TUKIAIKA_KESK, SUM(OMA_TULO, -TUKIKESK_ILMHUOLTOP), TUKIKESK_ILMHUOLTOP);
	%OpTukiTakaisinS(TUKIKOR_TAK_ILMHUOLTOP, &LVUOSI, 1, &INF, TUKIAIKA_KOR, SUM(OMA_TULO, -TUKIKOR_ILMHUOLTOP), TUKIKOR_ILMHUOLTOP);

	%OpTukiTakaisinS(ASUMLISA_TAK, &LVUOSI, 1, &INF, optukk, SUM(OMA_TULO, -TUKIKOR, -TUKIKESK), ASUMLISA);

END;

* V‰hennet‰‰n opintotuen takaisinperint‰ (keskiaste) ; 

IF (opirake > 0 AND TAYSIM_KESK NE 1) THEN DO;
	/* Mahdollisen huoltajakorotuksen kanssa */
	TUKIKESK = SUM(TUKIKESK, -TUKIKESK_TAK);
	/* Ilman huoltajakorotusta */
	TUKIKESK_ILMHUOLT = SUM(TUKIKESK_ILMHUOLT, -TUKIKESK_TAK_ILMHUOLT);
	/* Ilman oppimateriaalilis‰‰ */
	TUKIKESK_ILMOP = SUM(TUKIKESK_ILMOP, -TUKIKESK_TAK_ILMOP);
	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	TUKIKESK_ILMHUOLTOP = SUM(TUKIKESK_ILMHUOLTOP, -TUKIKESK_TAK_ILMHUOLTOP);
END;

* V‰hennet‰‰n opintotuen takaisinperint‰ (korkea-aste) ; 

IF(opirako > 0 AND TAYSIM_KOR NE 1) THEN DO;
	/* Mahdollisen huoltajakorotuksen kanssa */
	TUKIKOR = SUM(TUKIKOR, -TUKIKOR_TAK);
	/* Ilman huoltajakorotusta */
	TUKIKOR_ILMHUOLT = SUM(TUKIKOR_ILMHUOLT, -TUKIKOR_TAK_ILMHUOLT);
	/* Ilman oppimateriaalilis‰‰ */
	TUKIKOR_ILMOP = SUM(TUKIKOR_ILMOP, -TUKIKOR_TAK_ILMOP);
	/* Ilman huoltajakorotusta ja oppimateriaalilis‰‰ */
	TUKIKOR_ILMHUOLTOP = SUM(TUKIKOR_ILMHUOLTOP, -TUKIKOR_TAK_ILMHUOLTOP);
END;

* V‰hennet‰‰n asumislis‰n takaisinperint‰ ; 

IF hasuli > 0 THEN ASUMLISA = SUM(ASUMLISA, -ASUMLISA_TAK);

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

ARRAY PISTE 
opirake opirako hasuli hopila TUKIKESK TUKIKESK_ILMHUOLT TUKIKESK_ILMOP TUKIKESK_ILMHUOLTOP TUKIKOR TUKIKOR_ILMHUOLT TUKIKOR_ILMOP TUKIKOR_ILMHUOLTOP ASUMLISA OPLAIN TUKIKESK_TAK TUKIKOR_TAK ASUMLISA_TAK;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 
TUKIKESK = 'Keskiasteen opiskelijan opintoraha, MALLI'
opirake = 'Keskiasteen opiskelijan opintoraha, DATA'
TUKIKESK_ILMHUOLT = "Keskiasteen opiskelijan opintoraha ilman huoltajakorotusta, MALLI"
TUKIKESK_ILMOP = "Keskiasteen opiskelijan opintoraha ilman oppimateriaalilis‰‰, MALLI"
TUKIKESK_ILMHUOLTOP = "Keskiasteen opiskelijan opintoraha ilman huoltajakorotusta ja oppimateriaalilis‰‰, MALLI" 
TUKIKOR = 'Korkeakouluopiskelijan opintoraha, MALLI'
opirako = 'Korkeakouluopiskelijan opintoraha, DATA'
TUKIKOR_ILMHUOLT = "Korkeakouluopiskelijan opintoraha ilman huoltajakorotusta, MALLI"
TUKIKOR_ILMOP = "Korkeakouluopiskelijan opintoraha ilman oppimateriaalilis‰‰, MALLI"
TUKIKOR_ILMHUOLTOP = "Korkeakouluopiskelijan opintoraha ilman huoltajakorotusta ja oppimateriaalilis‰‰, MALLI"
ASUMLISA = 'Opintotuen asumislis‰, MALLI'
hasuli = 'Opintotuen asumislis‰, DATA'
OPLAIN = 'Opintolainan valtiontakaus, MALLI'
hopila = 'Opintolainan valtiontakaus, DATA'
TUKIKESK_TAK = 'Keskiasteen opintorahan takaisinperint‰, MALLI'
TUKIKOR_TAK = 'Korkea-asteen opintorahan takaisinperint‰, MALLI' 
ASUMLISA_TAK = 'Asumislis‰n takaisinperint‰, MALLI';

KEEP hnro knro TUKIKESK TUKIKESK_ILMHUOLT TUKIKESK_ILMOP TUKIKESK_ILMHUOLTOP TUKIKOR TUKIKOR_ILMHUOLT TUKIKOR_ILMOP TUKIKOR_ILMHUOLTOP ASUMLISA OPLAIN TUKIKESK_TAK TUKIKOR_TAK ASUMLISA_TAK;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T‰t‰ vaihetta ei ajeta mik‰li osamallia k‰ytet‰‰n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet‰‰n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_OT;
		
	/* 3.2.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO opirake opirako hasuli hopila ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_OT;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_OT;
	%END;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

	ARRAY PISTE 
	opirake opirako hasuli hopila;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	opirake = 'Keskiasteen opiskelijan opintoraha, DATA'
	opirako = 'Korkeakouluopiskelijan opintoraha, DATA'
	hasuli = 'Opintotuen asumislis‰, DATA'
	hopila = 'Opintolainan valtiontakaus, DATA';

	BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_OT._KOTI, TEMP.&TULOSNIMI_OT, &MALLI, &MUUTTUJAT);
		
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_OT;
		RUN;
		QUIT;
	%END;

	/* Jos k‰ytt‰j‰ m‰‰ritellyt YKSIKKO=1 (henkilˆtaso) tai YKSIKKO on mit‰ tahansa muuta kuin 2 (kotitaloustaso)
		niin j‰tet‰‰n tulostaulu henkilˆtasolle ja nimet‰‰n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_OT._HLO;
			CHANGE &TULOSNIMI_OT=&TULOSNIMI_OT._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_OT._HLO;
		RUN;
		QUIT;
	%END;

	/* Tyhjennet‰‰n TEMP-kirjasto */

	%IF &TEMPTYHJ = 1 %THEN %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST KILL;
		RUN;
		QUIT;
	%END;

%END;

%MEND OpinTuki_Simuloi_Data;

%OpinTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Tulostetaan k‰ytt‰j‰n pyyt‰m‰t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_OT._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_OT._KOTI,2);
	%END;

	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND;
%KutsuTulokset;

/* 5. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));

%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;