/****************************************************
* VVERO-mallin simulointiohjelma 2016          		*
* Viimeksi päivitetty: 23.7.2018 			  		*
****************************************************/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET START = &OUT;

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2016;		/* Aineistovuosi (vvvv)*/

	%LET LVUOSI = 2016;		/* Lainsäädäntövuosi (vvvv) */

	%LET AINEISTO = AIKASA; /* Käytettävä aineisto:
							   AIKASA = kulutustutkimuksen aineisto
							   ALV = kulutustutkimuksen aineisto liitettynä mikrosimuloinnin lisätiedoilla (vain aineistovuonna 2012) */

	%LET TULOSNIMI_VVE = vvero_simul_&SYSDATE._1; /* Simuloidun tulostiedoston nimi */

	/* Tulokäsitteet ja desiilien muodostus */

	%LET KULUYKS = oecdmod; /* Kulutusyksikön määritelmä:
							Kulutustutkimuksen aineisto (AINEISTO = AIKASA):
							- kulyksik (oecd:n vanha luokitus)
							- oecdkor (oecd:n vanha)
							- oecdmod (oecd:n nyk.suositus)
							SISU-muuttujat (AINEISTO = ALV):
							- kulyks (OECD:n kulutusyksikkömääritelmä) 
							- modoecd (Modifioitu OECD:n kulutusyksikkömääritelmä) */
	%LET TULO = rahatumk; /* Käytettävissä olevien tulojen käsite:
							- kaytetmk (Käytettävissä olevat tulot)
							- rahatumk (Käytettävissä olevat tulot – laskennalliset erät  = rahatulot)
							Muuttujasta muodostetaan TULOKÄSITE: &TULO._ALV = SUM(&TULO, -ALV)
							Tulokäsitettä TULO._ALV käytetään köyhyysindikaattorien laskennassa. */

	/* Ajettavat osavaiheet */

	%LET POIMINTA = 1;  	/* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) */
	%LET TULOKSET = 1;		/* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei) */

	/* Käytettävien tiedostojen nimet */

	%LET LAKIMAK_TIED_VVE = VVEROlakimakrot;	/* Lakimakrotiedoston nimi */
	%LET PVVERO = PVVERO; /* Alv-kantojen parametritaulun nimi */
	%LET PVVERO_TUOTTEET = PVVERO_TUOTTEET; /* Tuotteiden parametritaulun nimi */

	/* Kulutuksen tason kiinnittäminen */
	%LET KULUTUS = 0; /* 0 = Kiinnitetään tuoteluokittainen nettokulutus (alv-prosentin nostaminen kasvattaa bruttokulutusta)
						 1 = Kiinnitetään tuoteluokittainen bruttokulutus (alv-prosentin nostaminen vähentää nettokulutusta) */

	/* Kulutuskertoimien käyttö */
	%LET KULUTUS_KOROTUS = 0; /* 0 = Ei huomioida tuotteiden parametritaulussa määriteltyjä korotuskertoimia
								 1 = Kasvatetaan kaikkea tuoteluokittaista kulutusta tuotteiden parametritaulussa määritellyillä kertoimilla
								 - Jos KULUTUS = 0, kasvatetaan kunkin tuoteluokan nettokulutusta
								 - Jos KULUTUS = 1, kasvatetaan kunkin tuoteluokan bruttokulutusta */
			
	/* Tulostaulukoiden esivalinnat */

	%LET MUUTTUJAT = ALV KULUTUS /* ALV ja kulutus summatasolla */
			&TULO &TULO._ALV /* Taulukoitavat tulokäsitteet */
			KANTA_R1 KANTA_R2 KANTA_S1 KANTA_S0 KANTA_M /* Taulukoitavat verokannat */
			KULUTUS_R1 KULUTUS_R2 KULUTUS_S1 KULUTUS_S0 KULUTUS_M /* Taulukoitava kulutus verokannoittain */
			A01_KULUTUS A01_ALV /* Kulutus ja ALV tuoteluokittain, esimerkkinä elintarvikkeet (tuoteluokka A01) */
			;

	%LET LUOK_KOTI1 = ; /* Taulukoinnin 1. kotitalousluokitus
								Kulutustutkimuksen aineisto, vaihtoehtoina:
								 - deskkk (Desiililuokat kotitalouksista kotitaloutta kohti
										laskettujen käytettävissä olevien tulojen perus-teella)
								 - deskuk (Desiililuokat kotitalouksista  kulutusyksikköä (oecdkor)
										kohti laskettujen käytettävissä olevien tulojen perusteella)
								 - deskmk (Desiililuokat kotitalouksista kulutusyksikköä (oecdmod)
										kohti laskettujen käytettävissä olevien tulojen perusteella)
								 - aliv (Kotitaloustyyppi, suppea)
								 - elelinva (Kotitalouden elinvaihe, el-harmonisoitu)
								 - kuelinva (Kotitalouden elinvaihe, el-harmonisoitu)
							     - rakenne (kotitalouden rakenne)
								 SISU-muuttujat (kun AINESTO = ALV), vaihtoehtoina:
							     - ikavuv (viitehenkilön mukaiset ikäryhmät)
							     - elivtu (kotitalouden elinvaihe)
							     - koulasv (viitehenkilön koulutusaste)
							     - paasoss (viitehenkilön sosioekonominen asema)
							     - rake (kotitalouden rakenne)
								 - maakunta (NUTS3-aluejaon mukainen maakuntajako)*/

	%LET LUOK_KOTI2 = ; 	  /* Taulukoinnin 2. kotitalousluokitus */
	%LET LUOK_KOTI3 = ; 	  /* Taulukoinnin 3. kotitalousluokitus */

	%LET EXCEL = 0; 		/* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) */

	/* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	/* N eli lukumäärät */
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

	%LET RAJAUS = ; 		/* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia) */

	/* Yhdistetäminen KOKOsimul tuloksiin (mahdollista vain kun AINEISTO = ALV) */

	%LET KOKOSIMUL = ; /* Tyhjä jos ei yhdistetä */
	%LET KOKOSIMUL_MUUTTUJAT = BRUTTORAHATULO_SIMUL BRUTTORAHATULO_DATA KAYTRAHATULO_DATA KAYTRAHATULO_SIMUL MAKSP_VEROT_DATA MAKSP_VEROT_SIMUL MAKSP_VEROT_SIMUL KAYTTULO_DATA ktu KAYTTULO_SIMUL; /* Taulukoitavat KOKO- tai VERO-mallin tulosmuuttujat (summataulukot) */

	%END;
	%ELSE %DO;
	/* Lisätään taulukoitavia muuttujia */
	%LET MUUTTUJAT = &TULO &TULO._ALV &MUUTTUJAT;
	%END;

	%LET PAINO = koraika; /* Käytettävä painokerroin. Jos AINEISTO = AIKASA, niin koraika. Jos AINEISTO = ALV, niin ykor tai koraika. */

	/* Yhdistetään valitut tunnusluvut yhdeksi ohjausmuuttujaksi */
	%LET TUNNUSLUVUT = &SUMWGT &SUM &MIN &MAX &MEAN &MEDIAN &MODE &VAR &CV &STD;

	/* Ajetaan lakimakrot ja tallennetaan ne */
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VVE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO Alv_Muutt_Poiminta;

	%GLOBAL HAETTAVA_BRUTTO;

	PROC SQL NOPRINT;
	select Tuote into :HAETTAVA_BRUTTO SEPARATED BY ' '
	from PARAM.&PVVERO_TUOTTEET;

	QUIT;

	%IF &POIMINTA %THEN %DO;

	%LOCAL &HAETTAVA_BRUTTO %PASTE(&HAETTAVA_BRUTTO,_KERROIN);

	/* Haetaan tarvittavat muuttujat: Muodostetaan STARTDAT */
	DATA STARTDAT.STARTDAT_ALV;
		SET POHJADAT.&AINEISTO&AVUOSI (KEEP = jasenia &PAINO &KULUYKS A01_12 konu &HAETTAVA_BRUTTO
			kulyksik oecdkor oecdmod
			/* Jos aineistossa, niin pidä */
			%VarExist(hnro knro asko ikavu sp soss &TULO &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3, POHJADAT.&AINEISTO&AVUOSI)
			);
			/* Jos aineistossa ei ole taulukoinnissa käytettäviä muuttujia, asetetaan täytearvot */
			%IF %UPCASE(&AINEISTO) NE ALV %THEN %DO;
			ikavu = 18;
			soss = .;
			sp = "";
			hnro = _N_;
			%END;
			/* Kulutustutkimuksen aineiston kulutusyksiköt vastaamaan KoyhInd- ja Desiilit-makroja*/
			kulyksik = kulyksik*10;
			oecdkor = oecdkor*10;
			oecdmod = oecdmod*10;
	RUN;

	/* Tiputetaan pois muut perheenjäsenet */
	PROC SORT DATA = STARTDAT.STARTDAT_ALV; BY konu %VarExist(asko, STARTDAT.STARTDAT_ALV); RUN;

	DATA STARTDAT.STARTDAT_ALV;
		set STARTDAT.STARTDAT_ALV;
		BY konu;
		IF FIRST.konu;
	RUN;

	%IF %LENGTH(&KOKOSIMUL) > 0 %THEN %DO;
		PROC SORT DATA = OUTPUT.&KOKOSIMUL; BY knro; RUN;

		DATA STARTDAT.STARTDAT_ALV;
			MERGE STARTDAT.STARTDAT_ALV OUTPUT.&KOKOSIMUL (DROP=DESMOD);
			BY knro;
		RUN;
	%END;
	%ELSE %DO;
		%LET KOKOSIMUL_MUUTTUJAT = ;
	%END;

	/* Lasketaan desiilit dataan */
	%Desiilit(konu, &TULO, jasenia, &KULUYKS, &PAINO, STARTDAT.STARTDAT_ALV, luokittelu = DESMOD);

	/* # Laske alviton makro: # */
	%IF &KULUTUS NE 1 %THEN %DO;

		/* Haetaan aineistovuoden alv-prosentit */
		%ParamTuotteet(Ain&AVUOSI, PARAM.&PVVERO_TUOTTEET)

		/* ##### ALVITTOMIEN HINTOJEN LASKEMINEN ##### */
		DATA STARTDAT.STARTDAT_ALVITON;
			SET STARTDAT.STARTDAT_ALV;
			/* Lasketaan tuotteille aineistovuode nettohinnat */
			%DO i = 1 %TO %SYSFUNC(COUNTW(&HAETTAVA_BRUTTO));
				%LET TUOTE = %SCAN(&HAETTAVA_BRUTTO, &i);
				
				&TUOTE._NETTO = &TUOTE/(1+&&&TUOTE/100);
			%END;
		RUN;
	%END;

	%END;

%MEND Alv_Muutt_Poiminta;

%Alv_Muutt_Poiminta;

/* 3. Simulointivaihe */

%MACRO Alv_Simuloi_Data;

	/* Tyhjien makromuuttujien luominen */
	%LOCAL &HAETTAVA_BRUTTO;
	%GLOBAL %PASTE(&HAETTAVA_BRUTTO,_KERROIN);
	%LOCAL S1 R1 R2 S0 M1 M2;

	/* JOS KULUTUS KIINNITETTY */
	%IF &KULUTUS %THEN %DO;

		/* Lakiparametrien haku */
		%HaeParamSimul(&LVUOSI, 1, S1 R1 R2 S0 M1 M2, PARAM.&PVVERO);
		%ParamTuotteet(&LVUOSI, PARAM.&PVVERO_TUOTTEET)

		/* Alvittomien hintojen laskenta */	
		DATA TEMP.TEMP_ALV;
			SET STARTDAT.STARTDAT_ALV;

			%IF &KULUTUS_KOROTUS %THEN %DO;
				%DO i = 1 %TO %SYSFUNC(COUNTW(&HAETTAVA_BRUTTO));
					%LET TUOTE = %SCAN(&HAETTAVA_BRUTTO, &i);
					
					&TUOTE = &TUOTE * &&&TUOTE._KERROIN;

				%END;
			%END; 

			%LaskeNetto(&HAETTAVA_BRUTTO)
		RUN;

	%END;
	%ELSE %DO;

		%HaeParamSimul(&LVUOSI, 1, S1 R1 R2 S0 M1 M2, PARAM.&PVVERO);
		%ParamTuotteet(&LVUOSI, PARAM.&PVVERO_TUOTTEET)

		DATA TEMP.TEMP_ALV;
			SET STARTDAT.STARTDAT_ALVITON;

			%IF &KULUTUS_KOROTUS %THEN %DO;
				%DO i = 1 %TO %SYSFUNC(COUNTW(&HAETTAVA_BRUTTO));
					%LET TUOTE = %SCAN(&HAETTAVA_BRUTTO, &i);
					
					&TUOTE._NETTO = &TUOTE._NETTO * &&&TUOTE._KERROIN;

				%END;
			%END; 

			%LaskeAlv(&HAETTAVA_BRUTTO);
		RUN;
	%END;

	PROC SQL NOPRINT;
        /* Yleiseen verokantaan ja alennettuihin kantoihin kuuluvat tuotteet, kulutus */
        SELECT COMPRESS(Tuote) into :TAULUKOI_R1 SEPARATED BY ' '
        FROM PARAM.&PVVERO_TUOTTEET
        WHERE v&LVUOSI EQ 'R1';

        SELECT COMPRESS(Tuote) into :TAULUKOI_R2 SEPARATED BY ' '
        FROM PARAM.&PVVERO_TUOTTEET
        WHERE v&LVUOSI EQ 'R2';

        SELECT COMPRESS(Tuote) into :TAULUKOI_S1 SEPARATED BY ' '
        FROM PARAM.&PVVERO_TUOTTEET
        WHERE v&LVUOSI EQ 'S1';

        SELECT COMPRESS(Tuote) into :TAULUKOI_S0 SEPARATED BY ' '
        FROM PARAM.&PVVERO_TUOTTEET
        WHERE v&LVUOSI EQ 'S0';

        /* Muut verokannat */
        SELECT COMPRESS(Tuote) into :TAULUKOI_M SEPARATED BY ' '
        FROM PARAM.&PVVERO_TUOTTEET
        WHERE v&LVUOSI NOT IN('S1','S0','R1','R2');
	QUIT;

	DATA OUTPUT.&TULOSNIMI_VVE;
		SET TEMP.TEMP_ALV;

		/* Summataan verot, kulutus ja verot verokannoittain kotitalouksittain: */
		ALV = sum(of %PASTE(&HAETTAVA_BRUTTO, _ALV));
		KULUTUS = sum(of %PASTE(&HAETTAVA_BRUTTO, _KULUTUS));
		&TULO._ALV = sum(&TULO, -ALV);
		OSUUS_ALV = ALV / KULUTUS;
		OSUUS_&TULO = OSUUS_ALV / &TULO;

		KANTA_R1 = sum(of %PASTE(&TAULUKOI_R1, _ALV));
		KANTA_R2 = sum(of %PASTE(&TAULUKOI_R2, _ALV));
		KANTA_S1 = sum(of %PASTE(&TAULUKOI_S1, _ALV));
		KANTA_S0 = sum(of %PASTE(&TAULUKOI_S0, _ALV));
		KANTA_M = sum(of %PASTE(&TAULUKOI_M, _ALV));


		KULUTUS_R1 = sum(of %PASTE(&TAULUKOI_R1, _KULUTUS));
		KULUTUS_R2 = sum(of %PASTE(&TAULUKOI_R2, _KULUTUS));
		KULUTUS_S1 = sum(of %PASTE(&TAULUKOI_S1, _KULUTUS));
		KULUTUS_S0 = sum(of %PASTE(&TAULUKOI_S0, _KULUTUS));
		KULUTUS_M = sum(of %PASTE(&TAULUKOI_M, _KULUTUS));


		LABEL
			ALV = 'Arvonlisäveron osuus kulutuksesta'
			KULUTUS = 'Kulutus yhteensä (sis. ALV)'
			&TULO = "Käytettävissä olevat tulot (&TULO)"
			&TULO._ALV = "Käytettävissä olevat tulot (&TULO) ALV:n jälkeen"
			KANTA_R1 = 'ALV, 1. Alennettu kanta'
			KANTA_R2 = 'ALV, 2. Alennettu kanta'
			KANTA_S1 = 'ALV, Yleinen verokanta'
			KANTA_S0 = 'ALV, Nollaverokanta ja veroton'
			KANTA_M = 'ALV, Muut verokannat'
			KULUTUS_R1 = 'Kulutus, 1. Alennettu kanta (sis. ALV)'
			KULUTUS_R2 = 'Kulutus, 2. Alennettu kanta (sis. ALV)'
			KULUTUS_S1 = 'Kulutus, Yleinen verokanta (sis. ALV)'
			KULUTUS_S0 = 'Kulutus, Nollaverokanta ja alviton (sis. ALV)'
			KULUTUS_M = 'Kulutus, Muut verokannat (sis. ALV)'
		
			/* Labelit tuotteittain */
			%DO i = 1 %TO %SYSFUNC(COUNTW(&HAETTAVA_BRUTTO));
				%SCAN(&HAETTAVA_BRUTTO, &i)_KULUTUS = "Kulutus tuoteluokassa %SCAN(&HAETTAVA_BRUTTO, &i) (sis. ALV)"
				%SCAN(&HAETTAVA_BRUTTO, &i)_ALV = "Arvonlisäveron osuus kulutuksesta tuoteluokassa %SCAN(&HAETTAVA_BRUTTO, &i)"
			%END;
			;
	RUN;

	%Desiilit(konu, &TULO._ALV, jasenia, &KULUYKS, &PAINO, OUTPUT.&TULOSNIMI_VVE);

%MEND Alv_Simuloi_Data;

%Alv_Simuloi_Data;

/* 4. Tulostetaan käyttäjän pyytämät taulukot */

%MACRO KutsuTulokset;

	ODS NOPROCTITLE;

	TITLE "TUNNUSLUVUT, VVERO";

	%IF &KULUTUS %THEN %DO;
	TITLE2 'Bruttokulutus kiinnitetty';
	%END;
	%ELSE %DO;
	TITLE2 'Nettokulutus kiinnitetty';
	%END;

	%IF &TULOKSET %THEN %DO;

	%IF &EXCEL %THEN %DO;

	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO.tulos_S.xls" STYLE = MINIMAL;

	%END;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_VVE &TUNNUSLUVUT NONOBS ORDER=DATA NWAY MAXDEC = 0 STACKODS;
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF /*PRELOADFMT*/ ORDER=formatted;
		VAR &MUUTTUJAT &KOKOSIMUL_MUUTTUJAT;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			%IF %UPCASE("&&LUOK_KOTI&I") EQ "DESKKK" %THEN %DO;
			FORMAT &&LUOK_KOTI&I DESMOD.;
			%END;
			%ELSE %IF %UPCASE("&&LUOK_KOTI&I") EQ "MAAKUNTA" %THEN %DO;
			FORMAT &&LUOK_KOTI&I $maakunta.;
			%END;
			%ELSE %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
			%END;
		%END;
		%END;
		WEIGHT &PAINO;
		WHERE &RAJAUS;
		ODS OUTPUT SUMMARY = OUTPUT.&TULOSNIMI_VVE._s;
	RUN;

	%IF &EXCEL = 1 %THEN %DO;

	ODS HTML3 CLOSE;

	%END;

	%END;

	/* Gini ja desiilit*/

	/* Käytettävissä olevat rahatulot - alv tapauksissa BASELINE ja REFORMI */

	%LET TULOSNIMI_KOKO = %SCAN(OUTPUT.&TULOSNIMI_VVE, -1);
	%KoyhInd(3, 40, 50, 60, OUTPUT.&TULOSNIMI_VVE, jasenia, &PAINO, &TULO._ALV, &KULUYKS, konu, DESMOD_MALLI, 1);

	/* Tulostetaan indikaattorit */
	%IF &TULOKSET %THEN %DO;
	TITLE "Tulonjakoindikaattoreita, VVERO-malli";
	TITLE2 "Tulokäsite &TULO._ALV, Kulutusyksikkö &KULUYKS";
	PROC PRINT DATA = OUTPUT.&TULOSNIMI_VVE._IND NOOBS LABEL;
	FORMAT AOSU commax15.2 RLKM tuhat.;
	RUN;
	%END;

	TITLE;
	TITLE2;

	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START^=1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;

	ODS PROCTITLE;

%MEND KutsuTulokset;
%KutsuTulokset;
