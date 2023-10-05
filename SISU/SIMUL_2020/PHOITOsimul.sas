/***********************************************************
* Kuvaus: Lasten p‰iv‰hoitomaksujen simulointimalli 2018   *
* Viimeksi p‰ivitetty: 28.5.2020 		     	           *
***********************************************************/ 

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = PHOITO;

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
	
	%LET AVUOSI = 2020;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2020;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* K‰ytett‰v‰ aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_PH = phoito_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

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

	%LET LAKIMAK_TIED_PH = PHOITOlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET PPHOITO = pphoito; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT =  HMAKSU_KOKO PHMAKSU_KOK HMAKSU_OSA PHMAKSU_OS HMAKSU PHMAKSU_TOT; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkˆ (1 = henkilˆ, 2 = kotitalous) ;
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

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET OPINTUKI = 0; 
	%LET KOTIHTUKI = 0; 
	%LET VERO = 0; 
	%LET LLISA = 0;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";

%MEND Aloitus;

%Aloitus;


%MACRO PHOITO_Varoitukset;

	%IF &AVUOSI = 2018 %THEN %DO;

		%PUT WARNING: PHOITO-mallissa aineistovuonna 2018 k‰ytett‰v‰t lasten kunnallisen varhaiskasvatuksen %CMPRES(
						) osallistumiskuukausien m‰‰r‰t on p‰‰telty perustuen suurelta osin vanhempien tyˆllisyystietoihin.;

	%END;

%MEND PHOITO_Varoitukset;

%PHOITO_Varoitukset;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO PHoito_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_PHOITO_LAPSET */

		* Datasta poimittuja tietoja, p‰iv‰hoitomaksut ym.;
		* Jos halutaan tutkia suhdetta yksityiseen hoitoon ym.
		voidaan valita myˆs muuttujat hoiaikay hoimaksy hoisum;

	DATA STARTDAT.START_PHOITO_LAPSET;
		SET POHJADAT.&AINEISTO&AVUOSI
		(WHERE = (hoiaikak > 0 OR hoiaikao > 0)
		KEEP = hnro knro ykor desmod ikavu syvu syntkk asko hoimaksk hoiaikak hoimakso hoiaikao);
	RUN;

	/* 2.2 Poimitaan tietoja p‰iv‰hoitolapsien perheist‰ taulukkoon START_PHOITO_PERHEET */

	DATA TEMP.PHOITO_PERHEET;
		MERGE STARTDAT.START_PHOITO_LAPSET(IN = A KEEP = knro)
			POHJADAT.&AINEISTO&AVUOSI(KEEP = hnro knro asko syvu syntkk ikavu ikakk svatva 
			svatvp tkotihtu lbeltuki elasa elama opis tkopira ktku yrvah);
		BY knro;
		IF A;
	RUN;

	*Lajitellaan lapset ik‰j‰rjestykeen;

	PROC SORT DATA = STARTDAT.START_PHOITO_LAPSET;
		BY knro syvu syntkk; 
	RUN;

	*Lasketaan hoitolapsille j‰rjestysnumero;
	
	DATA STARTDAT.START_PHOITO_LAPSET;
		SET STARTDAT.START_PHOITO_LAPSET (WHERE = (hoiaikak > 0 OR hoiaikao > 0));
    	RETAIN SISAR;
		BY knro;
   		
		IF FIRST.knro THEN SISAR = 1;
		ELSE SISAR = SISAR + 1;

		LABEL SISAR = 'Hoitolapsen j‰rjestysnumero, DATA';
  
	RUN;

	PROC SORT DATA = STARTDAT.START_PHOITO_LAPSET;
		BY knro hnro; 
	RUN;

	* Lasketaan lapsille ik‰kuukausia muuttujiin LAPSI_KUUK_17, LAPSI_KUUK_7, LAPSI_KUUK_1_5 ja PHOITO_LAPSI.
	  K‰ytet‰‰n laskennassa apumakroa Ika_Kuuk;

	DATA TEMP.PHOITO_PERHEET;
		MERGE TEMP.PHOITO_PERHEET (KEEP = knro hnro asko ikavu ikakk opis svatva svatvp tkotihtu lbeltuki elasa elama tkopira ktku yrvah)
		STARTDAT.START_PHOITO_LAPSET (KEEP = knro hnro hoiaikak hoiaikao);
		BY knro hnro;

		%IkaKuuk(IKA_KUUK1, 0, 16, SUM(12 * ikavu, ikakk));
		LAPSI_KUUK_17 = IKA_KUUK1;

		%IkaKuuk(IKA_KUUK2, 0, 6, SUM(12 * ikavu, ikakk));
		LAPSI_KUUK_7 = MAX(SUM(IKA_KUUK2, -opis), 0);

		%IkaKuuk(IKA_KUUK3, 0, 17, SUM(12 * ikavu, ikakk));
		LAPSI_KUUK_18 = IKA_KUUK3;

		KEEP hnro knro asko svatva svatvp lbeltuki elasa elama tkotihtu LAPSI_KUUK_18 LAPSI_KUUK_17 LAPSI_KUUK_7 tkopira ktku yrvah;

		LABEL
		LAPSI_KUUK_18 = 'Kuukausien lukum‰‰r‰ vuoden aikana, jolloin alle 18-vuotias, DATA'
		LAPSI_KUUK_17 = 'Kuukausien lukum‰‰r‰ vuoden aikana, jolloin alle 17-vuotias, DATA'
		LAPSI_KUUK_7 = 'Kuukausien lukum‰‰r‰ vuoden aikana, jolloin alle 7-vuotias, DATA';
	RUN;

	* Luodaan aputaulu, jossa kaikki asuntokunnan elatusavut on viety viitehenkilˆlle (datassa tiedot lapsilla);

	PROC SUMMARY DATA = TEMP.PHOITO_PERHEET;
		BY knro;
		OUTPUT OUT = TEMP.PHOITO_ELASA(DROP = _TYPE_ _FREQ_) 
		SUM(elasa) = ELASA_PERHE;
	RUN;

	PROC SQL;
		CREATE TABLE TEMP.PHOITO_ELASA_VH
			AS SELECT a.hnro, b.ELASA_PERHE
			FROM TEMP.PHOITO_PERHEET as a INNER JOIN TEMP.PHOITO_ELASA as b
			ON a.knro = b.knro AND a.asko = 1;
	QUIT;

	PROC SORT DATA = TEMP.PHOITO_ELASA_VH;
		by hnro;
	RUN;

	* Summataan ik‰kuukausia kotitalouksittain taulukkoon PHOITO_PERH_LAPSET ;

	PROC SUMMARY DATA = TEMP.PHOITO_PERHEET;
		BY knro;
		OUTPUT OUT = TEMP.PHOITO_PERH_LAPSET(DROP = _TYPE_ _FREQ_) 
		SUM(LAPSI_KUUK_18 LAPSI_KUUK_17 LAPSI_KUUK_7) = ;
	RUN;

	* Lasketaan eri-ik‰isten lasten lukum‰‰r‰t ;

	DATA STARTDAT.START_PHOITO_PERH_LAPSET;
		SET TEMP.PHOITO_PERH_LAPSET;
		LUKUM_18 = ROUND(LAPSI_KUUK_18 / 12, 1); 
		LUKUM_17 = ROUND(LAPSI_KUUK_17 / 12, 1); 
		LUKUM_7  = ROUND(LAPSI_KUUK_7 / 12, 1);

		LABEL 
		LUKUM_18 = 'Alle 18-vuotiaiden lasten lkm, DATA'
		LUKUM_17 = 'Alle 17-vuotiaiden lasten lkm, DATA'
		LUKUM_7 = 'Alle 7-vuotiaiden lasten lkm, DATA';	
	RUN;

	* Luodaan lapsen vanhempina olevista puolisoista tiedosto START_PHOITO_PERH_PUOLISOT ;

 	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT (KEEP = hnro knro asko VEROT_TULOT_DATA KOTIHTULO_DATA ELATTUKI_DATA ELAMAKSUT_DATA ELATAPU_DATA tkopira);
		MERGE TEMP.PHOITO_PERHEET(WHERE = (asko = 1 OR asko = 2)) TEMP.PHOITO_ELASA_VH;
		BY hnro;

		VEROT_TULOT_DATA = MAX(SUM(svatva, svatvp, yrvah) / 12, 0);
		ELATTUKI_DATA = lbeltuki / 12;
		KOTIHTULO_DATA = SUM(tkotihtu, ktku) / 12;
		ELAMAKSUT_DATA = elama / 12;
		ELATAPU_DATA = ELASA_PERHE / 12;

		LABEL 
		VEROT_TULOT_DATA = 'Veronalaiset tulot (e/kk), DATA'
		ELATTUKI_DATA = 'Elatustuki (e/kk), DATA'
		KOTIHTULO_DATA = 'Kotihoidon tuki (e/kk), DATA'
		ELAMAKSUT_DATA = 'Maksetut elatusavut (e/kk), DATA'
		ELATAPU_DATA = 'Elatusapu (e/kk), DATA';
	RUN;

%END;
	
%MEND PHoito_Muutt_Poiminta;

%PHoito_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(time());


/* 3. Makro hakee tietoja muista osamalleista ja liitt‰‰ ne mallin dataan */

%MACRO OsaMallit_PHoito;

%IF &VERO = 1 OR &KOTIHTUKI = 1 OR &LLISA = 1 OR &OPINTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT;
		MERGE STARTDAT.START_PHOITO_PERH_PUOLISOT (IN = A)

		/* 3.1 Veromalli */
		%IF &VERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_VE
			(KEEP = hnro ANSIOT POTULOT)
		%END;

		/* 3.2 Kotihoidontuki */
		%IF &KOTIHTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KT
			(KEEP = hnro KOTIHTUKI OSHOIT JSHOIT)
		%END;

		/* 3.3 Elatustuki LLISA-mallista */
		%IF &LLISA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_LL
			(KEEP = hnro ELATUSTUET_HH)
		%END;

		/* 3.4 Opintotuki OPINTUKI-mallista */
		%IF &OPINTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_OT
			(KEEP = hnro TUKIKESK TUKIKOR)
		%END;

		;
		BY hnro;
		IF A;
	RUN;

%END;

%MEND OsaMallit_PHoito;

%OsaMallit_PHoito;


/* 4. Simulointivaihe */

%MACRO PHoito_Simuloi_Data;
/* KOTIHTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL PHOITO_PARAM PHOITO_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(PHOITO_PARAM, PHOITO);
%HaeLaskettavatLokaalit(PHOITO_MUUNNOS, PHOITO);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &PHOITO_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */
%KuukSimul(PHOITO);

/* 4.1 Varsinainen simulointivaihe */

DATA TEMP.PHOITO_PERH_PUOLISOT (KEEP = hnro knro asko OPTUKI VEROT_TULOT KOTIHTULO ELMAKSUT ELTUKI ELAPU);
	SET STARTDAT.START_PHOITO_PERH_PUOLISOT;

	%IF &VERO = 1 %THEN %DO;
		VEROT_TULOT = SUM(ANSIOT, POTULOT) / 12;
	%END;

	%ELSE %DO;
		VEROT_TULOT = VEROT_TULOT_DATA;
	%END;

	%IF &OPINTUKI = 1 %THEN %DO;
		OPTUKI = SUM(TUKIKESK, TUKIKOR)/12;
	%END;

	%ELSE %DO;
		OPTUKI = tkopira/12;
	%END;

	%IF &KOTIHTUKI = 1 %THEN %DO;
		KOTIHTULO = SUM(KOTIHTUKI, OSHOIT, JSHOIT) / 12;
	%END;

	%ELSE %DO;
		KOTIHTULO = KOTIHTULO_DATA;
	%END;

	%IF &LLISA = 1 %THEN %DO;
		ELTUKI = ELATUSTUET_HH / 12;
	%END;

	%ELSE %DO;
		ELTUKI = ELATTUKI_DATA;
	%END;

	ELAPU = ELATAPU_DATA;
	ELMAKSUT = ELAMAKSUT_DATA;

	LABEL 
	OPTUKI = 'Opintotuki e/kk, DATA'
	VEROT_TULOT = 'Veronalaiset tulot e/kk, DATA'
	KOTIHTULO ='Kotihoidon tuki e/kk, DATA'
	ELTUKI = 'Elatustuki e/kk, DATA'
	ELMAKSUT = 'Maksetut elatusavut e/kk, DATA'
	ELAPU = 'Elatusapu e/kk, DATA';
RUN;

PROC SORT DATA = TEMP.PHOITO_PERH_PUOLISOT;
	BY knro;
RUN;

PROC SUMMARY DATA = TEMP.PHOITO_PERH_PUOLISOT;
	BY knro;
	OUTPUT OUT = TEMP.PHOITO_PERH_PUOL_YHT (DROP = _TYPE_ _FREQ_)
	SUM(asko)=SASKO SUM(OPTUKI VEROT_TULOT KOTIHTULO ELMAKSUT ELTUKI ELAPU) = ;
RUN;

DATA TEMP.&TULOSNIMI_PH;
	MERGE STARTDAT.START_PHOITO_LAPSET STARTDAT.START_PHOITO_PERH_LAPSET;
	BY knro;
RUN;

DATA TEMP.&TULOSNIMI_PH;
	MERGE TEMP.&TULOSNIMI_PH TEMP.PHOITO_PERH_PUOL_YHT;
	BY knro;



	IF LUKUM_18 > 0 THEN DO;
		ELTUKI_PER_LAPSI = ELTUKI/LUKUM_18;
		ELAPU_PER_LAPSI = ELAPU/LUKUM_18;
	END;
	ELSE DO;
		ELTUKI_PER_LAPSI = 0;
		ELAPU_PER_LAPSI = 0;
	END;



	TULOT_YHT = MAX(SUM(VEROT_TULOT, ELTUKI_PER_LAPSI, ELAPU_PER_LAPSI, -ELMAKSUT, -KOTIHTULO, -OPTUKI), 0);

	LABEL TULOT_YHT = 'Tulot yhteens‰ e/kk';

	IF SASKO = 3 THEN PUOLISO = 1;
	ELSE PUOLISO = 0;

	MUITA_LAPSIA = SUM(LUKUM_17, -LUKUM_7);

	%PHoitoMaksuVS(TULOSP, &LVUOSI, &INF, PUOLISO, LUKUM_7, SISAR, MUITA_LAPSIA, TULOT_YHT);

	* Kokoaikaisen hoidon maksut;
	IF hoiaikak > 0 THEN PHMAKSU_KOK = min(hoiaikak,11) * TULOSP;
	ELSE PHMAKSU_KOK = 0;

	* Osa-aikaisen hoidon maksut;
	IF hoiaikao > 0 THEN PHMAKSU_OS = 0.6 * min(hoiaikao,11) * TULOSP;
	ELSE PHMAKSU_OS = 0;

	* Maksut yhteens‰;
	PHMAKSU_TOT = SUM(PHMAKSU_KOK, PHMAKSU_OS);

	DROP koko TULOSP ;

	LABEL 
	PUOLISO = 'Onko puolisoa (0/1), DATA'
	MUITA_LAPSIA = 'Perheen muiden alaik‰isten lasten lukum‰‰r‰, DATA';

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

	ARRAY PISTE 
	PHMAKSU_KOK PHMAKSU_OS PHMAKSU_TOT;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan simuloiduille muuttujille selitteet ;

	LABEL 

	PHMAKSU_KOK = 'Hoitomaksu kokop‰iv‰hoidossa, MALLI'
	PHMAKSU_OS  = 'Hoitomaksu osap‰iv‰hoidossa, MALLI'
	PHMAKSU_TOT = 'P‰iv‰hoitomaksut yhteens‰, MALLI';
RUN;

PROC SORT DATA = TEMP.&TULOSNIMI_PH;
	BY hnro;
RUN;

/* 4.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T‰t‰ vaihetta ei ajeta mik‰li osamallia k‰ytet‰‰n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet‰‰n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_PH;
		
	/* 4.2.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO hoiaikak hoimaksk hoiaikao hoimakso ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_PH;
	%END;

	/* 4.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_PH;
	%END;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

	HMAKSU_KOKO = hoiaikak * hoimaksk;
	HMAKSU_OSA = hoiaikao * hoimakso;
	HMAKSU = SUM(HMAKSU_KOKO, HMAKSU_OSA);

	ARRAY PISTE 
	hoiaikak hoimaksk hoiaikao hoimakso HMAKSU_KOKO HMAKSU_OSA HMAKSU;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 

	hoiaikak = 'Hoitoaika kunnallisessa kokop‰iv‰hoidossa, DATA'
	hoimaksk = 'Hoitomaksu kunnallisessa kokop‰iv‰hoidossa, DATA'
	hoiaikao = 'Hoitoaika kunnallisessa osap‰iv‰hoidossa, DATA'
	hoimakso = 'Hoitomaksu kunnallisessa osap‰iv‰hoidossa, DATA'
	HMAKSU_KOKO = 'Hoitomaksu kokop‰iv‰hoidossa, DATA'
	HMAKSU_OSA  = 'Hoitomaksu osap‰iv‰hoidossa, DATA'
	HMAKSU  = 'P‰iv‰hoitomaksut yhteens‰, DATA';

	BY hnro;
		
	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_PH._KOTI, TEMP.&TULOSNIMI_PH, &MALLI, &MUUTTUJAT);
		
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_PH;
		RUN;
		QUIT;
	%END;

	/* Jos k‰ytt‰j‰ m‰‰ritellyt YKSIKKO=1 (henkilˆtaso) tai YKSIKKO on mit‰ tahansa muuta kuin 2 (kotitaloustaso)
		niin j‰tet‰‰n tulostaulu henkilˆtasolle ja nimet‰‰n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_PH._HLO;
			CHANGE &TULOSNIMI_PH=&TULOSNIMI_PH._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_PH._HLO;
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

%MEND PHoito_Simuloi_Data;

%PHoito_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(time());


/* 5. Tulostetaan k‰ytt‰j‰n pyyt‰m‰t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_PH._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_PH._KOTI,2);
	%END;
	
	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND;
%KutsuTulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));

%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;