/***********************************************************
* Kuvaus: Lapsilisän simulointimalli 2019            	   *
* Viimeksi päivitetty: 28.5.2020 				 	       *
***********************************************************/ 

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = LLISA;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, käytetään siellä määriteltyjä ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, käytetään alla syötettyjä ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2019;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2023;		* Lainsäädäntövuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_LL = llisa_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Euro- tai markkamääräisten parametrien haun yhteydessä suoritettavassa
	  deflatoinnissa käytettävän kertoimen voi syöttää itse INF-makromuuttujaan
	  (HUOM! desimaalit erotettava pisteellä .). Esim. jos yksi lainsäädäntövuoden euro on
	  aineistovuoden rahassa 95 senttiä, syötä arvoksi 0.95.
	  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
	  Jos puolestaan haluaa käyttää automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
	  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
	  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

	%LET INF = 1.00; * Syötä lukuarvo, KHI tai ATI;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;

	* Ajettavat osavaiheet ; 

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_LL = LLISAlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET PLLISA = pllisa; * Käytettävän parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ;	* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT = llmk LLISA_HH lbeltuki ELATUSTUET_HH aitav AITAVUST ; * Taulukoitavat muuttujat (summataulukot) ;
	%LET LUOK_KOTI1 = ;		* Taulukoinnin 1. kotitalousluokitus
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavuv (viitehenkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilön koulutusaste)
							     paasoss (viitehenkilön sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ;		* Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ;		* Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0;			* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukumäärät ;
	%LET SUM = SUM; 
	%LET MIN = ; 
	%LET MAX = ;
	%LET RANGE = ;
	%LET MEAN = ;
	%LET MEDIAN = ;
	%LET MODE =  ;
	%LET VAR = ;
	%LET CV =  ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

	%END;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";

%MEND Aloitus;

%Aloitus;

/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO LLisa_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	* Määritellään tarvittavat muuttujat taulukkoihin START_LLISA, START_AITAV, START_ELTUKI;

	DATA STARTDAT.START_LLISA; 
  	SET POHJADAT.&AINEISTO&AVUOSI
  	(KEEP = hnro knro asko llmk elivtu ikavu ikakk);

	* Lisätään tieto puolisosta;
	IF elivtu IN (20, 83, 84) THEN ONPUOLISO = 0; 
	ELSE ONPUOLISO = 1;

	RUN;

	PROC SUMMARY DATA = POHJADAT.&AINEISTO&AVUOSI(KEEP = knro aitav AITAVLUKUM
		WHERE = (aitav > 0));
	VAR aitav AITAVLUKUM;
	BY knro;
	OUTPUT OUT = STARTDAT.START_AITAV(KEEP = knro aitav AITAVLUKUM) SUM=;
	RUN;

	DATA STARTDAT.START_ELTUKI;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro elivtu elasa lbeltuki ELTUKIKUUK);
	WHERE ELTUKIKUUK > 0;
	IF elivtu IN (20, 83, 84) THEN APUOLISO = 0; ELSE APUOLISO = 1;
	LABEL 	
	APUOLISO = 'Puoliso (0/1), DATA'
	RUN;

%END;

%MEND LLisa_Muutt_Poiminta;

%LLisa_Muutt_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe */

%MACRO LLisa_Simuloi_Data;
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL LLISA_PARAM LLISA_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(LLISA_PARAM, LLISA);
%HaeLaskettavatLokaalit(LLISA_MUUNNOS, LLISA);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &LLISA_PARAM;

/* Haetaan lainsäädäntövuoden alun lapsilisän ikäraja
(käytetään rajauksessa jos simulointi tehdään vuositasolla) */
%HaeParamSimul(&LVUOSI, 1, IRaja, PARAM.&PLLISA); 

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */
%KuukSimul(LLISA);

/* 3.1.1 Lapsilisät */

DATA TEMP.LLISA_HH;
	SET STARTDAT.START_LLISA;

	* Lapsilisäkuukaudet tarkasteluvuoden aikana uuteen muuttujaan LLKUUK ;
	%IkaKuuk(LLKUUK, 0, SUM(&IRaja, -1), SUM(12 * ikavu, ikakk));
RUN;

* Järjestetään ne lapset, joilla lapsilisäkuukausia kotitalouden sisällä iän mukaan laskevaan järjestykseen ;

PROC SORT DATA = TEMP.LLISA_HH OUT = TEMP.LLISA_HH;
	BY knro DESCENDING ikavu ikakk;
	WHERE LLKUUK > 0;
RUN;

* Lasketaan kullekin lapselle eri kuukausille seuraavat tiedot;
** onko oikeutettu lapsilisaan (LAPS);
** järjestysluku jos oikeutettu (JARJ);
** onko alle 3-vuotias (ALLE3_);
** onko 16-vuotias (V16_);

DATA TEMP.LLISA_HH;
	SET TEMP.LLISA_HH;
	BY KNRO;
	RETAIN JARJ1 - JARJ12;
	ARRAY JARJ(12) JARJ1 - JARJ12 ;
	ARRAY LAPS(12) LAPS1 - LAPS12 ;
	ARRAY ALLE3_(12) ALLE3_1 - ALLE3_12 ;
	ARRAY V16_(12) V16_1 - V16_12 ;

	IF FIRST.knro THEN DO i = 1 TO 12;
		JARJ(i) = 0;
	END;

	DO j = 1 TO 12;
		 IKA = SUM(12 * ikavu, ikakk ,-(12 - j));
		 IF IKA > 0 AND IKA <= 12 * &IRaja THEN DO;
		     LAPS(j) = 1;
			 JARJ(j) = SUM(JARJ(j), 1);
		 END;
		 ELSE LAPS(j) = 0;
		 IF IKA > 0 AND IKA <= 3 * 12 THEN ALLE3_(j) = 1;
		 ELSE ALLE3_(j) = 0;
		 IF IKA > 12 * 16 AND IKA <= 12 * 17 THEN V16_(j) = 1;
		 ELSE V16_(j) = 0;

	 	* Käytetään taulukon LAPS tietoja oikean järjestysluvun hiomiseen ;
		JARJ(j) = LAPS(j) * JARJ(j);
	END;

	DROP IKA i j LAPS1-LAPS12;

	LABEL 	

	JARJ1 	= 'Lapsen järjestysluku tammikuussa, DATA' 		
	JARJ2  	= 'Lapsen järjestysluku helmikuussa, DATA'
	JARJ3  	= 'Lapsen järjestysluku maaliskuussa, DATA'		
	JARJ4  	= 'Lapsen järjestysluku huhtikuussa, DATA'
	JARJ5  	= 'Lapsen järjestysluku toukokuussa, DATA'		
	JARJ6  	= 'Lapsen järjestysluku kesäkuussa, DATA'
	JARJ7  	= 'Lapsen järjestysluku heinäkuussa, DATA'		
	JARJ8  	= 'Lapsen järjestysluku elokuussa, DATA'
	JARJ9  	= 'Lapsen järjestysluku syyskuussa, DATA'		
	JARJ10 	= 'Lapsen järjestysluku lokakuussa, DATA'
	JARJ11 	= 'Lapsen järjestysluku marraskuussa, DATA'		
	JARJ12 	= 'Lapsen järjestysluku joulukuussa, DATA'
	ALLE3_1	= 'Alle 3-vuotias tammikuussa, DATA'			
	ALLE3_2	= 'Alle 3-vuotias helmikuussa, DATA'
	ALLE3_3	= 'Alle 3-vuotias maaliskuussa, DATA'			
	ALLE3_4 = 'Alle 3-vuotias huhtikuussa, DATA'
	ALLE3_5	= 'Alle 3-vuotias toukokuussa, DATA'			
	ALLE3_6	= 'Alle 3-vuotias kesäkuussa, DATA'
	ALLE3_7	= 'Alle 3-vuotias heinäkuussa, DATA'			
	ALLE3_8	= 'Alle 3-vuotias elokuussa, DATA'
	ALLE3_9	= 'Alle 3-vuotias syyskuussa, DATA'				
	ALLE3_10= 'Alle 3-vuotias lokakuussa, DATA'
	ALLE3_11= 'Alle 3-vuotias marraskuussa, DATA'			
	ALLE3_12= 'Alle 3-vuotias joulukuussa, DATA'
	V16_1	= '16-vuotias tammikuussa, DATA'				
	V16_2	= '16-vuotias helmikuussa, DATA'
	V16_3	= '16-vuotias maaliskuussa, DATA'				
	V16_4	= '16-vuotias huhtikuussa, DATA'
	V16_5	= '16-vuotias toukokuussa, DATA'				
	V16_6	= '16-vuotias kesäkuussa, DATA'
	V16_7	= '16-vuotias heinäkuussa, DATA'				
	V16_8	= '16-vuotias elokuussa, DATA'
	V16_9	= '16-vuotias syyskuussa, DATA'					
	V16_10  = '16-vuotias lokakuussa, DATA'
	V16_11	= '16-vuotias marraskuussa, DATA'				
	V16_12	= '16-vuotias joulukuussa, DATA'
	ONPUOLISO = 'Puoliso (0/1), DATA'
	LLKUUK = 'Lapsilisäkuukaudet tarkasteluvuoden aikana, DATA';

RUN;

* Lasketaan lapsilisä kaikille kuukausille erikseen järjestysluvun mukaan ;

DATA TEMP.LLISA_HH; 
	SET TEMP.LLISA_HH;

	ARRAY JARJ(12) JARJ1 - JARJ12;
	ARRAY ALLE3_(12) ALLE3_1 - ALLE3_12;
	ARRAY V16_ (12) V16_1 - V16_12;
	LLISAK1 = 0;
	LLISA = 0;

	%DO K = 1 %TO 12;
		%LLisaK1S(LLISAK1, &LVUOSI, &K, &INF, ONPUOLISO, ALLE3_(&K), V16_(&K), JARJ{&K}); 
		LLISA = SUM(LLISA, LLISAK1);
	%END;

	KEEP knro LLISA;
RUN;

* Lapsilisät kotitaloustasolla ;

PROC SUMMARY DATA = TEMP.LLISA_HH;
	BY knro;
	OUTPUT OUT = TEMP.LLISA_HH (KEEP = knro LLISA_HH) SUM(LLISA) = LLISA_HH;
RUN;

/* 3.1.2 Elatustuki */

DATA TEMP.ELTUKI_HH;
	SET STARTDAT.START_ELTUKI;

	* Lasketaan elatustuki kertomalla elatustukikuukausilla mallilla laskettu elatustuki,
	josta vähennetään elatusapu;

	%ElatTukiVS(ELATUSV, &LVUOSI, &INF, APUOLISO, 1);
	ELATUSTUET_HH = MAX(SUM(ELTUKIKUUK * ELATUSV, -elasa), 0);

	KEEP knro elasa lbeltuki ELTUKIKUUK APUOLISO ELATUSTUET_HH;
RUN;

* Elatustuet kotitaloustasolla ;

PROC SUMMARY DATA = TEMP.ELTUKI_HH;
	BY knro;
	OUTPUT OUT = TEMP.ELTUKI_HH (KEEP = knro ELATUSTUET_HH) SUM(ELATUSTUET_HH) = ELATUSTUET_HH;
RUN;

/* 3.1.3 Äitiysavustus */

* Lasketaan mallinnettu äitiysavustus muuttujaan AITAVUST makrolla AitAvutV;

DATA TEMP.AITAV_HH;
	SET STARTDAT.START_AITAV;
	%AitAvustVS(AITAVUST, &LVUOSI, &INF, AITAVLUKUM);
	KEEP knro aitav AITAVLUKUM AITAVUST;
RUN;

* Yhdistetään laskelmat;

DATA TEMP.&TULOSNIMI_LL;
	MERGE TEMP.LLISA_HH TEMP.ELTUKI_HH TEMP.AITAV_HH;
	BY knro;
RUN;

* Siirretään lapsilisä talouden viitehenkilölle (asko = 1) ;

PROC SQL UNDO_POLICY=NONE;
CREATE TABLE TEMP.&TULOSNIMI_LL
AS SELECT a.hnro, a.knro, b.LLISA_HH, b.ELATUSTUET_HH, b.AITAVUST
FROM POHJADAT.&AINEISTO&AVUOSI AS a 
INNER JOIN TEMP.&TULOSNIMI_LL AS b ON a.knro = b.knro AND a.asko = 1
ORDER BY knro, hnro;
QUIT;

DATA TEMP.&TULOSNIMI_LL;
SET TEMP.&TULOSNIMI_LL;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
	LLISA_HH ELATUSTUET_HH AITAVUST;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 	
LLISA_HH = 'Lapsilisät, MALLI'
ELATUSTUET_HH = 'Elatustuet, MALLI'
AITAVUST = 'Äitiysavustukset, MALLI';

KEEP hnro knro LLISA_HH ELATUSTUET_HH AITAVUST;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistetään tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_LL;
		
	/* 3.2.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO llmk lbeltuki aitav ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_LL;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_LL;
	%END;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

	ARRAY PISTE 
		llmk lbeltuki aitav;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 	
	llmk = 'Lapsilisät, DATA'
	lbeltuki = 'Elatustuet, DATA'
	aitav = 'Äitiysavustukset, DATA';

	BY hnro;

	RUN;

	* Nimetään tulosdata selvyyden vuoksi uudelleen, koska se on kotitaloustasolla;

	PROC DATASETS LIBRARY=TEMP NOLIST;
		DELETE &TULOSNIMI_LL._KOTI;
		CHANGE &TULOSNIMI_LL=&TULOSNIMI_LL._KOTI;
		COPY OUT=OUTPUT MOVE;
		SELECT &TULOSNIMI_LL._KOTI;
	RUN;
	QUIT;

	* Tyhjennetään TEMP-kirjasto;

	%IF &TEMPTYHJ = 1 %THEN %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST KILL;
		RUN;
		QUIT;
	%END;

%END;

%MEND LLisa_Simuloi_Data;

%LLisa_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Luodaan summatason tulostaulukot (optio) 
	  HUOM! Lapsilisä-mallissa aina kotitaloustasolla viitehenkilön mukaan */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_LL._KOTI,2);
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

