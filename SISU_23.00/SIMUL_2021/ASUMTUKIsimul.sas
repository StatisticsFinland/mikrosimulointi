/****************************************************
* Kuvaus: Yleisen asumistuen simulointimalli		*
****************************************************/ 

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = ASUMTUKI;

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

	%LET AVUOSI = 2021;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2021;		* Lainsäädäntövuosi (vvvv);
							* HUOM! Jos käytät vuotta 2017, valitse TYYPPI = SIMULX;
							* ja haluamasi lainsäädäntökuukausi;

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK; 	* Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_YA = asumtuki_simul_&SYSDATE._1;	* Simuloidun tulostiedoston nimi ;

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

	%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET PASUMTUKI = pasumtuki; * Parametritaulukon nimi ;
	%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit; * Vuokranormitaulukon nimi ;
	%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot; * Enimmäisasumismenotaulukon nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT = TUKIVUOK TUKIOMOS TUKIOMTA TUKIOM TUKIOSA TUKISUMMA hastuki; * Taulukoitavat muuttujat (summataulukot) ;
	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavuv (viitehenkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilön koulutusaste)
							     paasoss (viitehenkilön sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		  * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukumäärät ;
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

	%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

	%END;

	/* VERO-osamallin ohjausparametrin arvo asetetaan nollaksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET VERO = 0;

	/* Tarkistetaan onko ELASUMTUKIsimul ajettuna (kyllä/ei (1/0)) */

	%LET TARKISTUS_ASUMTUKI = 1; 

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO AsumTuki_Muutt_Poiminta;

* Annetaan ERROR jos käyttäjä on valinnut lainsäädäntövuodelle 2017 simulointityypin SIMUL;
%IF &LVUOSI = 2017 AND %UPCASE(&TYYPPI) = SIMUL %THEN %DO;
	%PUT ERROR: Lainsäädäntövuodelle 2017 ei voi käyttää ASUMTUKI-mallissa simulointityyppiä SIMUL;
	%PUT ERROR: Valitse TYYPPI = SIMULX ja haluamasi lainsäädäntökuukausi (LKUUK)!;
	%ABORT CANCEL;
%END;

*Tarkistetaan, löytyykö STARTDAT-kirjastosta dataa START_ELASUMTUKI_HENKI;

%IF &TARKISTUS_ASUMTUKI = 1 %THEN %DO;

%Tarkistus(STARTDAT.start_elasumtuki_henki, ELASUMTUKIsimul, 7); 

%END;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 Määritellään tarvittavat muuttujat ja havainnot taulukkoon START_ASUMTUKI_HENKI */

	/* Poimitaan tarvittavat muuttujat pohja-aineistosta */
	DATA STARTDAT.START_ASUMTUKI_HENKI;
   		SET POHJADAT.&AINEISTO&AVUOSI
		(KEEP = hnro knro jasenia elivtu yastukikr astukikr_l15
		aslaji halpinta maksvuok kaytkorv yhtiovas hastuki hasuli
		lisalamm lisamaks omalamm omamaks rakvuosi aslaikor svatva
		svatvp opirake opirako tnoosvvb teinovvb tuosvvap toyjmyvvap toyjmavvap
		tepalkat toptiot tosinktp teinovv hulkpa vlamm ikavu maakunta tulkp
		telps43 tmuukust tepalk tmerile tpalv trespa tepertyok1 tepertyok2 telps41 telps42 telps8 telps1 
		telps2 telps5 ttyoltuk tutmp235 tutmp4 tmtatt 
		tpjta tyhtat anstukor astukivu astukiom
		tmaat1evyr tmaat1pevyr tliik1evyr tliikpevyr tporo1evyr 
		tyhtmatevyr tyhtateevyr tyhtmat tyhtate yrvah);
	RUN;

	/* Jyvitetään pinta-ala ja asumiskustannusten muuttujat tasan asuntokunnan jäsenille */
	PROC SQL;
	CREATE TABLE TEMP.TEMP_ASUMTUKI_APU0
		AS SELECT hnro,
			halpinta/jasenia AS halpinta,
			SUM(maksvuok)/jasenia AS maksvuok,
			SUM(yhtiovas)/jasenia AS yhtiovas,
			SUM(lisalamm)/jasenia AS lisalamm,
			SUM(lisamaks)/jasenia AS lisamaks,
			SUM(omalamm)/jasenia AS omalamm,
			SUM(omamaks)/jasenia AS omamaks,
			SUM(kaytkorv)/jasenia AS kaytkorv,
			SUM(aslaikor)/jasenia AS aslaikor
		FROM STARTDAT.START_ASUMTUKI_HENKI
		GROUP BY knro
		ORDER BY hnro;
	QUIT;

	/* Yhdistetään jyvitetyt tiedot taulukkoon START_ELASUMTUKI_HENKI */
	DATA STARTDAT.START_ASUMTUKI_HENKI;
		UPDATE STARTDAT.START_ASUMTUKI_HENKI TEMP.TEMP_ASUMTUKI_APU0;
		BY hnro;
	RUN;

    /*Rajataan ennen vuoden 2017 elokuuta pois henkilöt jotka ovat saaneet
	opintotuen asumislisää, kuitenkin vain jos yleinen asumistuki = 0*/
	%IF (&LVUOSI < 2017) OR (&LVUOSI = 2017 AND %UPCASE(&TYYPPI) = SIMULX AND &LKUUK < 8) %THEN %DO;
	DATA STARTDAT.START_ASUMTUKI_HENKI;
		SET STARTDAT.START_ASUMTUKI_HENKI;
   		WHERE NOT (hasuli > 0 AND hastuki = 0);
	RUN;
	%END;

   	* Käytetään ELASUMTUKI-mallissa tuotettua START_ELASUMTUKI_HENKI taulukkoa sen selvittämiseen,
   	ketkä asuntokunnista ovat oikeutettuja eläkkeensaajien asumistukeen, ja poistetaan nämä;
	PROC SQL;
		DELETE FROM STARTDAT.START_ASUMTUKI_HENKI
		WHERE knro IN (SELECT DISTINCT knro FROM STARTDAT.START_ELASUMTUKI_HENKI);
	QUIT;
 
	DATA STARTDAT.START_ASUMTUKI_HENKI;
   		SET STARTDAT.START_ASUMTUKI_HENKI;
		BY knro;
		RETAIN AIKNROAPU;
		TYOTULOKK = SUM(tepalkat, toptiot, tosinktp, tulkp, telps43, tmuukust, tepalk,
			tmerile, tpalv, trespa, tepertyok1, tepertyok2, telps41, telps42, telps8, telps1, telps2, telps5,
			ttyoltuk, tutmp235, tutmp4, 
			tmaat1evyr, tmaat1pevyr, tpjta, tliik1evyr, 
			tliikpevyr, tporo1evyr, tyhtmatevyr, tyhtateevyr,
			SUM(tyhtat, -tyhtmat, -tyhtate), tmtatt,
			anstukor, hulkpa) / 12;
		IF FIRST.knro THEN AIKNROAPU = 0;
		IF ikavu >= 18 THEN DO;
			AIKNROAPU = AIKNROAPU + 1;
			AIKNRO = AIKNROAPU;
		END;
		DROP AIKNROAPU;
	RUN;

   	/* 2.2 Summataan kotitaloustasolle taulukkoon START_ASUMTUKI_KOTI */

	PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI SUM N MIN NOPRINT;	
	VAR svatva svatvp kaytkorv 	
	maksvuok yhtiovas halpinta
	lisamaks omalamm lisalamm
	omamaks aslaikor opirake opirako
	tnoosvvb teinovvb tuosvvap 
	toyjmyvvap toyjmavvap teinovv hulkpa hastuki yrvah hnro;	
	ID elivtu yastukikr astukikr_l15 aslaji
	rakvuosi maakunta vlamm astukivu astukiom;
   	BY knro;	
   	OUTPUT OUT = TEMP.TEMP_ASUMTUKI_KOTI1(DROP = _TYPE_ _FREQ_)
	SUM (svatva svatvp kaytkorv	
	lisamaks omalamm lisalamm
	maksvuok yhtiovas halpinta
	omamaks aslaikor opirake opirako
	tnoosvvb teinovvb tuosvvap 
	toyjmyvvap toyjmavvap teinovv hulkpa hastuki yrvah) = N(hnro) = HENKIL MIN(hnro) = hnro;	
   	RUN;

	PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI(WHERE=(ikavu >= 18)) SUM N MIN NOPRINT;	
	VAR svatva svatvp 	
	opirake opirako
	tnoosvvb teinovvb tuosvvap 
	toyjmyvvap toyjmavvap teinovv hulkpa yrvah
	hnro;	
   	BY knro;	
   	OUTPUT OUT = TEMP.TEMP_ASUMTUKI_KOTI2(DROP = _TYPE_ _FREQ_)
	SUM (svatva svatvp
	opirake opirako
	tnoosvvb teinovvb tuosvvap 
	toyjmyvvap toyjmavvap teinovv hulkpa yrvah) 
	= svatva18 svatvp18
	opirake18 opirako18
	tnoosvvb18 teinovvb18 tuosvvap18 
	toyjmyvvap18 toyjmavvap18 teinovv18 hulkpa18 yrvah18
	N(hnro) = AIK;	
   	RUN;

	PROC SQL;
		CREATE TABLE TEMP.TEMP_ASUMTUKI_KOTI3(drop=knro_temp)
		AS SELECT *
		FROM TEMP.TEMP_ASUMTUKI_KOTI1 AS a
		LEFT JOIN TEMP.TEMP_ASUMTUKI_KOTI2(rename=(knro=knro_temp)) AS b ON (a.knro = b.knro_temp);
	QUIT;

	PROC SQL NOPRINT;
		SELECT MAX(AIK) INTO :AIKMAX
		FROM TEMP.TEMP_ASUMTUKI_KOTI3;
	QUIT;
	%DO i=1 %TO &AIKMAX;
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ASUMTUKI_KOTI%EVAL(3 + &i)
			AS SELECT a.*, b.TYOTULOKK AS TYOTULOKK&i
			FROM TEMP.TEMP_ASUMTUKI_KOTI%EVAL(3 + &i - 1) AS a
			LEFT JOIN STARTDAT.START_ASUMTUKI_HENKI AS b ON (a.knro = b.knro AND b.AIKNRO = &i);
		QUIT;
	%END;
	DATA STARTDAT.START_ASUMTUKI_KOTI;
		SET TEMP.TEMP_ASUMTUKI_KOTI%EVAL(3 + &AIKMAX);
	RUN;

	/* 2.3 Lisätään aineistoon apumuuttujia ja summataan kotitaloustasolle taulukkoon START_ASUMTUKI_KOTI */

   	DATA STARTDAT.START_ASUMTUKI_KOTI;
   	SET STARTDAT.START_ASUMTUKI_KOTI;

	ARRAY TUL{12} svatva18 svatvp18 opirake18 opirako18 tnoosvvb18 teinovvb18 tuosvvap18 toyjmyvvap18 toyjmavvap18 teinovv18 hulkpa18 yrvah18;
	DO I=1 TO 12;
		IF TUL{I} = . THEN TUL{I} = 0;
	END;

   	LISALAMM = lisalamm / 12;
   	LISAMAKS = lisamaks / 12;
   	OMALAMM = omalamm / 12;
   	OMAMAKS = omamaks / 12;
   	ASLAIKOR = aslaikor / 12;
	OSVEROVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, toyjmyvvap, toyjmavvap, teinovv);
   	KUUKTULO_DATA = MAX(SUM(svatva, svatvp, yrvah, -opirake, -opirako, OSVEROVAP_DATA, hulkpa) / 12, 0);
	OPTUKI_DATA = MAX(SUM(opirake, opirako) / 12, 0);
	OSVEROVAP_DATA18 = SUM(tnoosvvb18, teinovvb18, tuosvvap18, toyjmyvvap18, toyjmavvap18, teinovv18);
   	KUUKTULO_DATA18 = MAX(SUM(svatva18, svatvp18, yrvah18, -opirake18, -opirako18, OSVEROVAP_DATA18, hulkpa18) / 12, 0);
	OPTUKI_DATA18 = MAX(SUM(opirake18, opirako18) / 12, 0);
	IF maksvuok > 0 THEN VUOKRA_AS = 1;
   	ELSE VUOKRA_AS = 0;
   	IF OMALAMM > 0 THEN KESKLAMM = 0;
   	ELSE KESKLAMM = 1;
   	IF aslaji = 1 OR aslaji = 2 THEN OMAKOTI = 1;
   	ELSE OMAKOTI = 0;
   	IF elivtu = 20 OR elivtu = 84 THEN YKSH = 1;
   	ELSE YKSH = 0;

	IF AIK = . THEN DO;
		AIK = 1;
	END;

   	* Lämmitysryhmä ;
   	LAMMR = vlamm;

	/* Lämmityskustannusten ja hoitonormien alueellinen korotus */
	LKRYHMA = 0;
	IF maakunta IN ('10','11','12') THEN LKRYHMA = 1;
	ELSE IF maakunta IN ('17','18','19') THEN LKRYHMA = 2; 

	KEEP knro LISALAMM LISAMAKS OMALAMM OMAMAKS ASLAIKOR KUUKTULO_DATA OPTUKI_DATA maksvuok VUOKRA_AS KESKLAMM 
		 aslaji OMAKOTI YKSH LAMMR yastukikr astukikr_l15 hulkpa hulkpa18 HENKIL rakvuosi halpinta yhtiovas maksvuok kaytkorv
		 hastuki AIK TYOTULOKK1-TYOTULOKK%EVAL(&AIKMAX) KUUKTULO_DATA18 OPTUKI_DATA18 LKRYHMA astukivu astukiom;  

	LABEL
	HENKIL = 'Henkilöiden lukumäärä kotitaloudessa, DATA'
	LISALAMM = 'Lämmityskulut hoitovastikkeen sijasta (e/kk), DATA'
	LISAMAKS = 'Vesi- yms. maksut hoitovastikkeen sijasta (e/kk), DATA'
	OMALAMM = 'Omakotitalon lämmityskustannukset sähkön lisäksi (e/kk), DATA'
	OMAMAKS = 'Omakotitalon vesi- yms. maksut (e/kk), DATA'
	ASLAIKOR = 'Asuntolainojen korot (e/kk), DATA'
	KUUKTULO_DATA = 'Perusomavastuun tulokäsitteen määrittelyssä huomioon otettava tulo (e/kk), DATA'
	OPTUKI_DATA = 'Ruokakunnan yhteenlaskettu opintoraha (e/kk), DATA'
	VUOKRA_AS = 'Asuu vuokralla (0/1), DATA'
	KESKLAMM = 'Asunnossa keskuslämmitys (0/1), DATA'
	OMAKOTI = 'Asuu omakotitaloussa (0/1), DATA'
	YKSH = 'Yksinhuoltaja (0/1), DATA'
	LAMMR = 'Lämmitysryhmä (1,2,3), DATA'
	KUUKTULO_DATA18 = 'Kuukausitulot (ilman opintorahaa), ruokakunnan täysi-ikäiset e/kk, DATA'
	OPTUKI_DATA18 = 'Opintoraha, ruokakunnan täysi-ikäiset e/kk, DATA'
	LKRYHMA = 'Alueryhmä lämmityskustannusten ja hoitonormien korottamista varten (0,1,2), DATA';
	RUN;

%END;

%MEND AsumTuki_Muutt_Poiminta;

%AsumTuki_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());


/* 3. Makro hakee tietoja muista osamalleista ja liittää ne mallin dataan */

%MACRO OsaMallit_AsumTuki;

%IF &OPINTUKI = 1 OR &VERO = 1 %THEN %DO;

	DATA STARTDAT.START_ASUMTUKI_HENKI;
		MERGE STARTDAT.START_ASUMTUKI_HENKI (IN = C)

		%IF &OPINTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_OT
			(KEEP = hnro TUKIKESK TUKIKESK_ILMHUOLT TUKIKESK_ILMHUOLTOP TUKIKOR TUKIKOR_ILMHUOLT TUKIKOR_ILMHUOLTOP)
		%END;

		%IF &VERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_VE
			(KEEP = hnro ANSIOT POTULOT OSINKOVAP)
		%END;

		;
		BY hnro;
		IF C;
	RUN;

	%IF &OPINTUKI = 1 %THEN %DO;

		PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI SUM NOPRINT;
		BY knro;
		VAR TUKIKESK TUKIKOR;
		OUTPUT OUT = TEMP.TEMP_ASUMTUKI_OPINTUKI_KOTI1 SUM(TUKIKESK TUKIKOR) = ;
		RUN;

		PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI (WHERE=(ikavu >= 18)) SUM NOPRINT;
		BY knro;
		VAR TUKIKESK TUKIKESK_ILMHUOLT TUKIKESK_ILMHUOLTOP TUKIKOR TUKIKOR_ILMHUOLT TUKIKOR_ILMHUOLTOP;
		OUTPUT OUT = TEMP.TEMP_ASUMTUKI_OPINTUKI_KOTI2 SUM(TUKIKESK TUKIKESK_ILMHUOLT TUKIKESK_ILMHUOLTOP TUKIKOR TUKIKOR_ILMHUOLT TUKIKOR_ILMHUOLTOP) = TUKIKESK18 TUKIKESK_ILMHUOLT18 TUKIKESK_ILMHUOLTOP18 TUKIKOR18 TUKIKOR_ILMHUOLT18 TUKIKOR_ILMHUOLTOP18;
		RUN;

		DATA STARTDAT.START_ASUMTUKI_KOTI;
		MERGE STARTDAT.START_ASUMTUKI_KOTI (IN = C)
		TEMP.TEMP_ASUMTUKI_OPINTUKI_KOTI1 (KEEP = knro TUKIKESK TUKIKOR)
		TEMP.TEMP_ASUMTUKI_OPINTUKI_KOTI2 (KEEP = knro TUKIKESK18 TUKIKESK_ILMHUOLT18 TUKIKESK_ILMHUOLTOP18 TUKIKOR18 TUKIKOR_ILMHUOLT18 TUKIKOR_ILMHUOLTOP18);
		IF C;
		BY knro;
		RUN;

	%END;

	%IF &VERO = 1 %THEN %DO;

		PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI SUM NOPRINT;
		BY knro;
		VAR ANSIOT POTULOT OSINKOVAP;
		OUTPUT OUT = TEMP.TEMP_ASUMTUKI_VERO_KOTI1 SUM(ANSIOT POTULOT OSINKOVAP) = ;
		RUN;

		PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI (WHERE=(ikavu >= 18)) SUM NOPRINT;
		BY knro;
		VAR ANSIOT POTULOT OSINKOVAP;
		OUTPUT OUT = TEMP.TEMP_ASUMTUKI_VERO_KOTI2 SUM(ANSIOT POTULOT OSINKOVAP) = ANSIOT18 POTULOT18 OSINKOVAP18;
		RUN;

		DATA STARTDAT.START_ASUMTUKI_KOTI;
		MERGE STARTDAT.START_ASUMTUKI_KOTI (IN = C)
		TEMP.TEMP_ASUMTUKI_VERO_KOTI1 (KEEP = knro ANSIOT POTULOT OSINKOVAP)
		TEMP.TEMP_ASUMTUKI_VERO_KOTI2 (KEEP = knro ANSIOT18 POTULOT18 OSINKOVAP18);
		IF C;
		BY knro;
		RUN;
	
	%END;

%END;

%MEND OsaMallit_AsumTuki;

%OsaMallit_AsumTuki;

/* 4. Simulointivaihe */

/* 4.1 Varsinainen simulointivaihe */

%MACRO AsumTuki_Simuloi_Data;

/* ASUMTUKI-mallin parametrit */

/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL ASUMTUKI_PARAM ASUMTUKI_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(ASUMTUKI_PARAM, ASUMTUKI);
%HaeLaskettavatLokaalit(ASUMTUKI_MUUNNOS, ASUMTUKI);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &ASUMTUKI_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulointia, ajetaan tämä makro, erillisajossa */
%KuukSimul(ASUMTUKI);

/* Haetaan vuokranormit. Vuoden 2015 lainsäädännöstä eteenpäin nämä eivät ole käytössä, joten hakua ei tarvita */
%IF &LVUOSI < 2015 %THEN %DO;
	%HaeParam_VuokraNormit(&LVUOSI);
	%HaeParam_EnimmVuokra(&LVUOSI);
%END;

%IF &POIMINTA = 0 %THEN %DO; 
	PROC SQL NOPRINT;
		SELECT MAX(AIK) INTO :AIKMAX
		FROM STARTDAT.START_ASUMTUKI_KOTI;
	QUIT;
%END;

DATA TEMP.&TULOSNIMI_YA;
SET STARTDAT.START_ASUMTUKI_KOTI;

* Päätellään käytetäänkö simuloituja tietoja muista osamalleista vai alkuperäisen datan tietoja ;

%IF &OPINTUKI = 1 %THEN %DO;
	%IF &LVUOSI < 2015 %THEN %DO;
		OPINTUKI = SUM(TUKIKESK, TUKIKOR);
		OPINTUKI_HUOM = SUM(TUKIKESK, TUKIKOR) / 12;
	%END;
	%ELSE %IF &LVUOSI < 2018 %THEN %DO;
		OPINTUKI = SUM(TUKIKESK18, TUKIKOR18);
		OPINTUKI_HUOM = SUM(TUKIKESK18, TUKIKOR18) / 12;
	%END;
	%ELSE %IF &LVUOSI < 2019 OR (%UPCASE(&TYYPPI) = SIMULX AND &LVUOSI = 2019 AND &LKUUK < 8) %THEN %DO;
		OPINTUKI = SUM(TUKIKESK18, TUKIKOR18);
		OPINTUKI_HUOM = SUM(TUKIKESK_ILMHUOLT18, TUKIKOR_ILMHUOLT18) / 12;
	%END;
	%ELSE %DO;
		OPINTUKI = SUM(TUKIKESK18, TUKIKOR18);
		OPINTUKI_HUOM = SUM(TUKIKESK_ILMHUOLTOP18, TUKIKOR_ILMHUOLTOP18) / 12;
	%END;
%END;
%ELSE %DO;
	%IF &LVUOSI < 2015 %THEN %DO; 
		OPINTUKI = OPTUKI_DATA;
		OPINTUKI_HUOM = OPTUKI_DATA / 12;
	%END;
	%ELSE %DO;
		OPINTUKI = OPTUKI_DATA18;
		OPINTUKI_HUOM = OPTUKI_DATA18 / 12;
	%END;
%END;

%IF &VERO = 1 %THEN %DO;
	%IF &LVUOSI < 2015 %THEN %DO;
		KUUKTULO = SUM(ANSIOT, POTULOT, -OPINTUKI, OSINKOVAP, hulkpa) / 12;
	%END;
	%ELSE %DO;
		KUUKTULO = SUM(ANSIOT18, POTULOT18, -OPINTUKI, OSINKOVAP18, hulkpa18) / 12;
	%END;
%END;
%ELSE %DO;
	%IF &LVUOSI < 2015 %THEN %DO; 
		KUUKTULO = KUUKTULO_DATA;
	%END;
	%ELSE %DO;
		KUUKTULO = KUUKTULO_DATA18;
	%END;
%END;

%IF &LVUOSI < 2015 %THEN %DO;
	* Muokataan tulo perusomavastuun laskentaa varten  ;
	%TuloMuokkausS(MUOKTULO, &LVUOSI, &INF, YKSH, HENKIL, 0, KUUKTULO);
	* Lasketaan perusomavastuu ;
	%PerusomavastS(OMAVAST, &LVUOSI, &INF, yastukikr, HENKIL, MUOKTULO);
	* Asumistuki vuokra-asunnoissa ;
	IF VUOKRA_AS NE 0 and aslaji NE 5 THEN DO;
		%AsumTukiVuokS(TUKIVUOK, &LVUOSI, &INF, yastukikr, LAMMR, KESKLAMM, 1, HENKIL, 0,
		rakvuosi, halpinta, OMAVAST, maksvuok, SUM(kaytkorv, OMAMAKS, LISAMAKS), SUM(OMALAMM, LISALAMM));
	END;
	* Asumistuki omistusasunnoissa ;
	IF VUOKRA_AS = 0 THEN DO;
		%AsumTukiOmS(TUKIOM, &LVUOSI, &INF, yastukikr, LAMMR, OMAKOTI, KESKLAMM, 1, HENKIL, 0,
		rakvuosi, halpinta, OMAVAST, yhtiovas, SUM(OMAMAKS, LISAMAKS), SUM(OMALAMM, LISALAMM), ASLAIKOR, 0);
	END;
	* Asumistuki osa-asunnoissa (alivuokralaisasunnoissa) ;
	IF aslaji = 5 THEN DO;
		%AsumtukiOsaS(TUKIOSA, &LVUOSI, &INF, yastukikr, HENKIL, 0, OMAVAST, maksvuok, 0);
	END;
	TUKIVUOK = 12 * TUKIVUOK;
	TUKIOM = 12 * TUKIOM;
	TUKIOSA = 12 * TUKIOSA;
	TUKISUMMA = SUM(TUKIVUOK , TUKIOM , TUKIOSA);
	TUKIOMOS = 0;
	TUKIOMTA = 0;
%END;
%ELSE %DO;
	ARRAY TYOTULO_ARRAY{*} TYOTULOKK1-TYOTULOKK%EVAL(&AIKMAX);
	* Asumistuki vuokra-asunnossa ;
	IF maksvuok > 0 AND aslaji NE 6 THEN DO;
		%As2015AsumistukiVuokraVS(TUKIVUOK, &LVUOSI, &INF, astukikr_l15, 0, maksvuok, 0, (SUM(kaytkorv, OMAMAKS, LISAMAKS) > 0), (SUM(OMALAMM, LISALAMM) > 0), LKRYHMA, KUUKTULO, TYOTULO_ARRAY, AIK, SUM(HENKIL, -AIK), opinraha=OPINTUKI_HUOM);
	END;
	* Asumistuki omassa asunto-osakeasunnossa ;
	ELSE IF aslaji = 3 OR (aslaji = 6 AND maksvuok > 0) THEN DO;
		%As2015AsumistukiOmaOsakeVS(TUKIOMOS, &LVUOSI, &INF, astukikr_l15, 0, SUM(yhtiovas, maksvuok), 0, (SUM(OMAMAKS, LISAMAKS) > 0), (SUM(OMALAMM, LISALAMM) > 0), LKRYHMA, ASLAIKOR, KUUKTULO, TYOTULO_ARRAY, AIK, SUM(HENKIL, -AIK), opinraha=OPINTUKI_HUOM);
	END;
	* Asumistuki omassa omakotitalossa ;
	ELSE IF aslaji = 1 OR aslaji = 2 THEN DO;
		%As2015AsumistukiOmaTaloVS(TUKIOMTA, &LVUOSI, &INF, astukikr_l15, 0, 0, LKRYHMA, ASLAIKOR, KUUKTULO, TYOTULO_ARRAY, AIK, SUM(HENKIL, -AIK), opinraha=OPINTUKI_HUOM);
	END;
	TUKIVUOK = 12 * TUKIVUOK;
	TUKIOMOS = 12 * TUKIOMOS;
	TUKIOMTA = 12 * TUKIOMTA;
	TUKISUMMA = SUM(TUKIVUOK, TUKIOMOS, TUKIOMTA);
	MUOKTULO = 0;
	OMAVAST = 0;
	TUKIOM = 0;
	TUKIOSA = 0;
%END;

RUN;

* Siirretään asumistuki talouden viitehenkilölle (asko = 1) ;

PROC SQL UNDO_POLICY=NONE;
CREATE TABLE TEMP.&TULOSNIMI_YA
AS SELECT a.hnro, a.knro, b.TUKIVUOK, b.TUKIOM, b.TUKIOSA, b.TUKIOMOS, b.TUKIOMTA, b.TUKISUMMA, b.KUUKTULO, b.OPINTUKI_HUOM, b.MUOKTULO, b.OMAVAST
FROM POHJADAT.&AINEISTO&AVUOSI AS a 
INNER JOIN TEMP.&TULOSNIMI_YA AS b ON a.knro = b.knro AND a.asko = 1
ORDER BY knro, hnro;
QUIT;

DATA TEMP.&TULOSNIMI_YA;
SET TEMP.&TULOSNIMI_YA;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
TUKIVUOK TUKIOM TUKIOSA TUKISUMMA TUKIOMOS TUKIOMTA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 

KUUKTULO = 'Ruokakunnan huomioon otettavat tulot (ilman opintorahaa) (e/kk), MALLI'
OPINTUKI_HUOM = 'Ruokakunnan yhteenlasketut opintorahat (e/kk), MALLI'
MUOKTULO = 'Perusomavastuun määrittelyssä tarvittava tulo (e/kk), MALLI'
OMAVAST = 'Perusomavastuu (e/kk), MALLI'
TUKIVUOK = 'Asumistuki vuokra-asunnoissa, MALLI'
TUKIOM = 'Asumistuki omistusasunnoissa, ennen vuotta 2015, MALLI'
TUKIOMOS = 'Asumistuki omassa osakeasunnossa, vuonna 2015 tai sen jälkeen, MALLI'
TUKIOMTA = 'Asumistuki omassa omakotitalossa, vuonna 2015 tai sen jälkeen, MALLI'
TUKIOSA = 'Asumistuki osa-asunnoissa, ennen vuotta 2015, MALLI'
TUKISUMMA = 'Yleinen asumistuki yhteensä, MALLI'; 

KEEP hnro KUUKTULO OPINTUKI_HUOM MUOKTULO OMAVAST TUKIVUOK TUKIOM TUKIOMOS TUKIOMTA TUKIOSA TUKISUMMA;

RUN;

/* 4.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistetään tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_YA;
		
	/* 4.2.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO hastuki ikavuv desmod paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_YA;
	%END;

	/* 4.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_YA;
	%END;

	BY hnro;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

	ARRAY PISTE 
	hastuki;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	hastuki = 'Yleinen asumistuki yhteensä, DATA'; 

	RUN;

	* Nimetään tulosdata selvyyden vuoksi uudelleen, koska se on kotitaloustasolla;

	PROC DATASETS LIBRARY=TEMP NOLIST;
		DELETE &TULOSNIMI_YA._KOTI;
		CHANGE &TULOSNIMI_YA=&TULOSNIMI_YA._KOTI;
		COPY OUT=OUTPUT MOVE;
		SELECT &TULOSNIMI_YA._KOTI;
	RUN;
	QUIT;

	* Tyhjennetään TEMP-kirjasto;

	%IF &TEMPTYHJ = 1 %THEN %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST KILL;
		RUN;
		QUIT;
	%END;

%END;

%MEND AsumTuki_Simuloi_Data;

%AsumTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) 
	  HUOM! Yleisessä asumistuessa aina kotitaloustasolla viitehenkilön mukaan */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_YA._KOTI,2);
	%END;

	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND;
%KutsuTulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;