/*********************************************************
* Kuvaus: El�kkeensaajan asumistuen simulointimalli 	 *
*********************************************************/ 

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = ELASUMTUKI;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, k�ytet��n siell� m��riteltyj� ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, k�ytet��n alla sy�tettyj� ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2023;								/* Aineistovuosi (vvvv) */

	%LET LVUOSI = 2023;								/* Lains��d�nt�vuosi (vvvv) */

	%LET TYYPPI = SIMUL;							/* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);*/

	%LET LKUUK = 12;       							/* Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;*/

	%LET AINEISTO = REK;							/* K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) */

	%LET TULOSNIMI_EA = elasumtuki_simul_&SYSDATE._1;	/* Simuloidun tulostiedoston nimi */

	%LET VARALLISUUSDATA = 0; * K�ytet��nk� ELASUMTUKI-mallissa datan varallisuustietoja (1 = Kyll�, 0 = Ei). 
								Varallisuustiedot eiv�t ole kattavat, niist� puuttuvat mm. talletukset. T�m�n takia oletusarvo = 0;

	* Inflaatiokorjaus. Euro- tai markkam��r�isten parametrien haun yhteydess� suoritettavassa
	  deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse INF-makromuuttujaan
	  (HUOM! desimaalit erotettava pisteell� .). Esim. jos yksi lains��d�nt�vuoden euro on
	  aineistovuoden rahassa 95 sentti�, sy�t� arvoksi 0.95.
	  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
	  Jos puolestaan haluaa k�ytt�� automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
	  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
	  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

	%LET INF = 1.00; * Sy�t� lukuarvo, KHI tai ATI;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;		

	/* Ajettavat osavaiheet */ 
	%LET POIMINTA = 1;  							/* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) */
	%LET TULOKSET = 1;								/* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei) */

	%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;	/* Lakimakrotiedoston nimi */
	%LET PELASUMTUKI = pelasumtuki; 				/* K�ytett�v�n parametritiedoston nimi */

	/* Tulosten valinnat */ 
	%LET TULOSLAAJ = 1; 	 						/* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) */
	%LET YKSIKKO = 1;		 						/* Mikrotason tulosaineiston ja summataulukoiden yksikk� (1 = henkil�, 2 = kotitalous) */
	%LET MUUTTUJAT = eastuki ELAKASUMTUKI; 			/* Summataulukoissa taulukoitavat muuttujat */
	%LET LUOK_HLO1 = ; 		 						/* Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   						   Vaihtoehtoina: 
							     					    desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     						ikavu (ik�ryhm�t)
							     						elivtu (kotitalouden elinvaihe)
							     						koulas (koulutusaste)
							     						soss (sosioekonominen asema)
							     						rake (kotitalouden rakenne)
								 						maakunta (NUTS3-aluejaon mukainen maakuntajako) */
	%LET LUOK_HLO2 = ;		 						/* Taulukoinnin 2. henkil�luokitus */
	%LET LUOK_HLO3 = ;		 						/* Taulukoinnin 3. henkil�luokitus */
	%LET LUOK_KOTI1 = ; 							/* Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2)  
							    					   Vaihtoehtoina: 
							     						desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
													    ikavuv (viitehenkil�n mukaiset ik�ryhm�t)
													    elivtu (kotitalouden elinvaihe)
													    koulasv (viitehenkil�n koulutusaste)
													    paasoss (viitehenkil�n sosioekonominen asema)
													    rake (kotitalouden rakenne)
														maakunta (NUTS3-aluejaon mukainen maakuntajako) */
	%LET LUOK_KOTI2 = ; 	  						/* Taulukoinnin 2. kotitalousluokitus */
	%LET LUOK_KOTI3 = ; 	  						/* Taulukoinnin 3. kotitalousluokitus */

	%LET EXCEL = 0; 		 						/* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) */

	/* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa) */
	%LET SUMWGT = SUMWGT; 							/* N eli lukum��r�t */
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

	%LET PAINO = ykor ; 							/* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana) */
	%LET RAJAUS =  ; 								/* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia) */

	%END;

	/* VERO-osamallin ohjausparametrin arvo asetetaan nollaksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */
 
	%LET VERO = 0;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja muokkaus (optio) */

%MACRO ElAsumTuki_Muut_Poiminta;

	%IF &POIMINTA = 1 %THEN %DO;

		/* 2.1 M��ritell��n tarvittavat havainnot ja muuttujat henkil�tasolla tauluun STARTDAT.START_ELASUMTUKI_HENKI */

		/* Poimitaan tarvittavat muuttujat pohja-aineistosta tauluun TEMP.TEMP_ELASUMTUKI_PERUS */

		DATA TEMP.TEMP_ELASUMTUKI_PERUS; 
			SET POHJADAT.&AINEISTO&AVUOSI
			(KEEP = hnro knro jasen puoliso aiti isa
			halpinta maksvuok hoitvast omamaks omalamm aslaikor jasenia
			ikavu tkansel leelake velake tkelake tperhel tansel tklaji velaji ttapel tlapel takuuel tulkelvp aslaji
			eastukikr yastukikr elak svatva svatvp teinova tpeito einotpyjatva tnoosvab einotptosva tuosvv einotyjptva varhp
			teinovv tnoosvvb teinovvb tuosvvap toyjmyvvap toyjmavvap evlamm rakvuosi yrvah
			odorsyko odorkeko odorsyke odorkeke
			psiraho pulkyso karvo posake_arvo_yht_AOT mtnetvaosvv elyosnetvvv pliikpos pmaatpos valopullinenvad);
		RUN;

		/* Jyvitet��n pinta-ala ja asumiskustannukset tasan kotitalouden j�senille
		ja muutetaan kaikki tiedot vuositasoisiksi tauluun TEMP.TEMP_ELASUMTUKI_ASUMISKUST */

		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ASUMISKUST
			AS SELECT hnro,
				halpinta/jasenia AS HALPINTAJ,
				(SUM(maksvuok)/jasenia)*12 AS MAKSVUOKJ12,
				(SUM(hoitvast)/jasenia)*12 AS HOITVASTJ12,
				SUM(omamaks)/jasenia AS OMAMAKSJ,
				SUM(omalamm)/jasenia AS OMALAMMJ,
				SUM(aslaikor)/jasenia AS ASLAIKORJ
			FROM TEMP.TEMP_ELASUMTUKI_PERUS
			GROUP BY knro
			ORDER BY hnro;
		QUIT;

		/* M��ritell��n el�kkeensaajan asumistukeen yksin asuessaan oikeutetut tauluun TEMP.TEMP_ELASUMTUKI_ONOIKEUSYKS */

		DATA TEMP.TEMP_ELASUMTUKI_ONOIKEUSYKS;
			SET TEMP.TEMP_ELASUMTUKI_PERUS;
			WHERE (

				/* ENNEN VUOTTA 2015: */
				%IF &LVUOSI < 2015 %THEN %DO;
					/* v�hint��n 65-vuotias */	
					(ikavu >= 65)
					OR
					(
						/* 16-64 -vuotias */	
						((16 <= ikavu) AND (ikavu < 65))
						AND
						(
							/* saa kansanel�kelain mukaista ty�kyvytt�myysel�kett�, ty�tt�myysel�kett�, yksil�llist� varhaisel�kett� tai leskenel�kett� */
							(((tkansel > 0) AND (velake > 0)) OR ((tperhel > 0) AND (leelake > 0))))
							OR
							/* saa kansanel�kelain mukaista vanhuusel�kett� el�ketuen perusteella. Tietoa ei aineistossa 2020 l�htien */
							/*((tkansel > 0) AND (omalaji = 10))
							OR*/
							/* saa ty�- tai virkasuhteen perusteella maksettavaa ty�kyvytt�myysel�kett� tai leskenel�kett� */
							((tansel > 0) AND ((tklaji IN (2,9)) OR ((ikavu >= 18) AND (tklaji = 0) AND (velaji = 0))))
							OR
							/* saa el�kett� perustuen lakis��teiseen tapaturmavakuutukseen tai liikennevakuutukseen */	
							((ttapel > 0) AND (tlapel > 0))
						)
					)
				%END;

				/* VUODESTA 2015 L�HTIEN: */
				%ELSE %DO;
					/* v�hint��n 16-vuotias */	
					(ikavu >= 16)
					AND
					(
						(
							/* saa kansanel�kelain mukaista ty�kyvytt�myysel�kett�, vanhuusel�kett� tai leskenel�kett� */
							((tkansel > 0) OR ((tperhel > 0) AND (leelake > 0)))
							OR
							/* saa takuuel�kett� */
							(takuuel > 0)
							OR
							/* saa ty�- tai virkasuhteen perusteella maksettavaa ty�kyvytt�myysel�kett�, vanhuusel�kett� tai leskenel�kett� */
							(tansel > 0)
							OR
							/* saa el�kett� perustuen lakis��teiseen tapaturmavakuutukseen tai liikennevakuutukseen */
							((ttapel > 0) OR (tlapel > 0))
							OR
							/* saa vastaavaa ulkomailta maksettavaa etuutta */	
							(tulkelvp > 0)
						)
						AND	
						/* ei saa pelk�st��n osa-aikael�kett� */
						(NOT ((velaji = 6) AND ((tperhel = 0) AND (leelake > 0))))
					)
				%END;

			);

			ONOIKEUSYKS = 1;

			KEEP hnro knro ONOIKEUSYKS;	
		RUN;

		/* M��ritell��n el�kkeensaajan asumistukeen oikeutetut tauluun TEMP.TEMP_ELASUMTUKI_ONOIKEUS */

		/* Niiden kotitalouksien kaikki j�senet, joissa on ainakin yksi el�kkeensaajan asumistukeen
		yksin asuessaan oikeutettu */
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU1
			AS SELECT a.hnro, a.knro, a.jasen, a.puoliso, a.aiti, a.isa, a.ikavu, a.jasenia 
			FROM TEMP.TEMP_ELASUMTUKI_PERUS AS a 
			WHERE a.knro IN 
				(SELECT DISTINCT b.knro
				FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUSYKS AS b); 
		QUIT;

		/* Merkit��n henkil�t, jotka ovat yksin asuessaan oikeutettuja el�kkeensaajan asumistukeen */
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU2
			AS SELECT a.*, MAX(b.ONOIKEUSYKS,0) AS ONOIKEUSYKS
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU1 AS a
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUSYKS AS b ON (a.hnro = b.hnro);
		QUIT;

		/* Merkit��n henkil�t, jotka eiv�t ole yksin asuessaan oikeutettuja el�kkeensaajan asumistukeen
		mutta heid�n puolisonsa ovat */
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU3
			AS SELECT a.*, MAX(b.ONOIKEUSYKS,0) AS PONOIKEUSYKS
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU2 AS a
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU2 AS b ON (a.ONOIKEUSYKS = 0 AND a.knro = b.knro AND a.puoliso = b.jasen);
		QUIT;

		/* ENNEN VUOTTA 2015 el�kkeensaajan asumistukea voitiin my�nt�� lapsiperheille;
		VUODESTA 2015 L�HTIEN lapsiperheet ovat oikeutettuja vain yleiseen asumistukeen.
		ENNEN VUOTTA 2008 lapsen ik�raja oli 16 ja VUOSINA 2008-2014 ik�raja oli 18. */
		%IF &LVUOSI < 2008 %THEN %DO;
			%LET ELASUMTUKI_LAPSIRAJA = 16;
		%END;
		%ELSE %IF &LVUOSI < 2015 %THEN %DO;
			%LET ELASUMTUKI_LAPSIRAJA = 18;
		%END;
		%ELSE %DO;
			%LET ELASUMTUKI_LAPSIRAJA = 0;
		%END;
		
		/* Merkit��n henkil�t, jotka eiv�t ole eiv�tk� heid�n puolisonsa ole yksin asuessaan
		oikeutettuja el�kkeensaajan asumistukeen mutta ainakin toinen heid�n vanhemmistaan on */
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU4
			AS SELECT a.*, MAX(b.ONOIKEUSYKS,c.ONOIKEUSYKS,0) AS VONOIKEUSYKS
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU3 AS a
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU3 AS b ON (a.ONOIKEUSYKS = 0 AND a.PONOIKEUSYKS = 0 AND a.ikavu NE . AND a.ikavu < &ELASUMTUKI_LAPSIRAJA AND a.knro = b.knro AND a.aiti = b.jasen)
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU3 AS c ON (a.ONOIKEUSYKS = 0 AND a.PONOIKEUSYKS = 0 AND a.ikavu NE . AND a.ikavu < &ELASUMTUKI_LAPSIRAJA AND a.knro = c.knro AND a.isa = c.jasen);
		QUIT;

		/* Summataan kotitalouksittain yhteen eri kautta el�kkeensaajan asumistukeen oikeutettujen m��r�t */
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU5
			AS SELECT knro, MAX(SUM(ONOIKEUSYKS),0) AS ONOIKEUSYKSS, MAX(SUM(PONOIKEUSYKS),0) AS PONOIKEUSYKSS, MAX(SUM(VONOIKEUSYKS),0) AS VONOIKEUSYKSS 
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU4
			GROUP BY knro;
		QUIT;
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU6
			AS SELECT a.*, b.ONOIKEUSYKSS, b.PONOIKEUSYKSS, b.VONOIKEUSYKSS		
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU4 AS a, TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU5 AS b
			WHERE (a.knro = b.knro);
		QUIT;

		/* Rajataan mukaan vain ne kotitaloudet, jotka ovat oikeutettuja el�kkeensaajan asumistukeen */
		DATA TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU7;
			SET TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU6;
			WHERE 
				(
				(jasenia = 1 AND ONOIKEUSYKSS = 1)									/* yksin asuvat */
				OR 
				(jasenia = 2 AND SUM(ONOIKEUSYKSS,PONOIKEUSYKSS) = 2)				/* puolison kanssa asuvat siten, ett� ainakin toinen puolisoista olisi oikeutettu tukeen yksin asuessaan */
				%IF &LVUOSI < 2015 %THEN %DO;
				OR																	/* ENNEN VUOTTA 2015: */
				(SUM(jasenia,-SUM(ONOIKEUSYKSS,PONOIKEUSYKSS)) = VONOIKEUSYKSS) 	/* yksin asuvat ja puolison kanssa asuvat sek� heid�n lapsensa, my�s useampi yksikk� samassa kotitaloudessa */	
				%END;
				%ELSE %DO;
				OR																	/* VUODESTA 2015 L�HTIEN */
				(jasenia = ONOIKEUSYKSS)											/* kaikki kotitaloudessa asuvat olisivat oikeutettuja el�kkeensaajan asumistukeen my�s yksin asuessaan */	
				%END;
				);		
		RUN;

		/* Jaetaan el�kkeensaajan asumistukeen oikeutetut kotitaloudet simulointiyksik�ihin */
		DATA TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU8;
			SET TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU7;
			IF puoliso = 0 THEN ELASUMTUKI_YKSIKKO_APU = jasen;
			ELSE IF puoliso NE 0 THEN ELASUMTUKI_YKSIKKO_APU = MIN(jasen,puoliso);
			ELSE ELASUMTUKI_YKSIKKO_APU = 0; 
		RUN;
		PROC SQL;
			CREATE TABLE TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU9
			AS SELECT a.*, MAX(b.ELASUMTUKI_YKSIKKO_APU,0) AS A_ELASUMTUKI_YKSIKKO_APU, MAX(c.ELASUMTUKI_YKSIKKO_APU,0) AS I_ELASUMTUKI_YKSIKKO_APU
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU8 AS a
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU8 AS b ON (a.VONOIKEUSYKS = 1 AND a.knro = b.knro AND a.aiti = b.jasen)
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU8 AS c ON (a.VONOIKEUSYKS = 1 AND a.knro = c.knro AND a.isa = c.jasen);
		QUIT;
		DATA TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU10;
			SET TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU9;
			IF VONOIKEUSYKS = 1 THEN DO;
				ELASUMTUKI_YKSIKKO_APU = MIN(A_ELASUMTUKI_YKSIKKO_APU, I_ELASUMTUKI_YKSIKKO_APU);
			END;
		RUN;
		PROC SORT DATA = TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU10;
			BY knro ELASUMTUKI_YKSIKKO_APU;
		RUN;
		DATA TEMP.TEMP_ELASUMTUKI_ONOIKEUS;
			RETAIN ELASUMTUKI_YKSIKKO 0;
			SET TEMP.TEMP_ELASUMTUKI_ONOIKEUS_APU10;
			BY knro ELASUMTUKI_YKSIKKO_APU;
			IF FIRST.knro OR FIRST.ELASUMTUKI_YKSIKKO_APU THEN ELASUMTUKI_YKSIKKO = ELASUMTUKI_YKSIKKO + 1;
			KEEP hnro knro ELASUMTUKI_YKSIKKO ONOIKEUSYKS PONOIKEUSYKS VONOIKEUSYKS;
		RUN;

		/* Yhdistet��n edelliset taulut tarvittavilta osin tauluun STARTDAT.START_ELASUMTUKI_HENKI */ 

		PROC SQL;
			CREATE TABLE STARTDAT.START_ELASUMTUKI_HENKI
			AS SELECT a.hnro, a.knro, a.ELASUMTUKI_YKSIKKO, a.ONOIKEUSYKS, a.PONOIKEUSYKS, a.VONOIKEUSYKS,
				b.HALPINTAJ, b.MAKSVUOKJ12, b.HOITVASTJ12, b.OMAMAKSJ, b.OMALAMMJ, b.ASLAIKORJ,
				c.puoliso, c.tperhel, c.leelake, c.tkansel, c.velake, c.tkelake, c.ikavu, c.aslaji, c.eastukikr, c.yastukikr, c.elak,
				c.svatva, c.svatvp,	c.teinova, c.tpeito, c.einotpyjatva, c.tnoosvab, c.einotptosva, c.tuosvv, c.einotyjptva,
				c.teinovv, c.tnoosvvb, c.teinovvb, c.tuosvvap, c.toyjmyvvap, c.toyjmavvap, c.odorsyko, c.odorkeko, c.odorsyke, c.odorkeke,
				c.evlamm, c.rakvuosi, c.yrvah, c.varhp,
				c.psiraho, c.pulkyso, c.karvo, c.posake_arvo_yht_AOT, c.mtnetvaosvv, c.elyosnetvvv, c.pliikpos, c.pmaatpos, c.valopullinenvad	
			FROM TEMP.TEMP_ELASUMTUKI_ONOIKEUS AS a
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_ASUMISKUST AS b ON (a.hnro = b.hnro)
			LEFT JOIN TEMP.TEMP_ELASUMTUKI_PERUS AS c ON (a.hnro = c.hnro);
		QUIT;

		/* Luodaan tarvittavat uudet muuttujat tauluun STARTDAT.START_ELASUMTUKI_HENKI */ 

		DATA STARTDAT.START_ELASUMTUKI_HENKI;
			SET STARTDAT.START_ELASUMTUKI_HENKI;

			/* Asuu puolison kanssa (0/1) */
			ONPUOLISO = (puoliso > 0);

			/* El�kkeensaajan asumistukeen yksin asuessaan oikeutettu saa yleisen perhe-el�kkeen leskenel�kett� (0/1) */
			SAAYLLESK = ((ONOIKEUSYKS = 1) AND ((tperhel > 0) AND (leelake > 0)));	

			/* El�kkeensaajan asumistukeen vain puolison kautta oikeutettu saa alle 65-vuotiaalle maksettavaa kansanel�kelain mukaista varhennettua vanhuusel�kett� (0/1) */
			PSAAVARVANH = ((PONOIKEUSYKS = 1) AND (((tkansel > 0) AND (varhp > 0)) AND ((16 <= ikavu) AND (ikavu < 65))));  	

			/* Omakotitalo (0/1) */
			OMAKOTITALO = (aslaji IN (1,2));
			
			/* El�kkeensaajan asumistuen kuntaryhm� (1-4) 
			HUOM. Vuonna 2015 laissa ja pohja-aineistossa on m��ritelty kolme el�kkeensaajan asumistuen kuntaryhm��,
			mutta malli k�ytt�� nelj�� kuntaryhm�� siten, ett� "virallinen" kuntaryhm� 1 (Helsinki, Espoo, Kauniainen ja Vantaa)
			on jaettu kahdeksi kuntaryhm�ksi: 1 (Helsinki) ja 2 (Espoo, Kauniainen ja Vantaa) */
			IF eastukikr = 1 AND yastukikr = 1 THEN KAYTKRYHMA = 1;
			ELSE IF eastukikr = 1 AND yastukikr = 2 THEN KAYTKRYHMA = 2;
			ELSE IF eastukikr = 2 THEN KAYTKRYHMA = 3;
			ELSE IF eastukikr = 3 THEN KAYTKRYHMA = 4;
			
			/* Kuukausien lukum��r�, jolloin oikeutettu el�kkeensaajan asumistukeen yksin asuessaan (1-12):
			Jos kyseess� on yleisen perhe-el�kkeen leskenel�kkeen saaja, kuukausia oletetaan olevan 12,
			sill� elak-muuttuja ei sis�ll� niit� kuukausia, kun henkil� on saanut pelkk�� perhe-el�kett�. */
			IF ONOIKEUSYKS = 1 AND SAAYLLESK = 1 THEN ELAKEKUUKAUDET = 12;
			ELSE IF ONOIKEUSYKS = 1 AND SAAYLLESK = 0 THEN ELAKEKUUKAUDET = MAX(elak, 0);

			/* Saadut veronalaiset tulot (e/v); vanhempiensa kautta oikeutetuille 0 (yritt�j�v�hennyst� ei ole tehty) */
			VERONAL_DATA = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(svatva, svatvp, yrvah, 0), 0);

			/* Saadut veronalaiset osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0 */
			VERONALOSINGOT_DATA = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(teinova, tpeito, einotpyjatva, tnoosvab, einotptosva, tuosvv, einotyjptva, 0), 0);

			/* Saadut verovapaat osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0 */
			VEROTTOSINGOT_DATA = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(teinovv, tnoosvvb, teinovvb, tuosvvap, toyjmyvvap, toyjmavvap, 0), 0);
			
			/* Saatu opintoraha (e/v); vanhempiensa kautta oikeutetuille 0 */
			OPRAHA_DATA = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(odorsyko, odorkeko, odorsyke, odorkeke, 0), 0);

			/* Varallisuuden m��r� (euroa, vuoden lopussa) */
			VARALLISUUS_DATA = IFN(&VARALLISUUSDATA=1, SUM(psiraho, pulkyso, karvo*0.7, posake_arvo_yht_AOT*0.7, mtnetvaosvv, elyosnetvvv, pliikpos, pmaatpos, valopullinenvad), 0);

			LABEL
				ELASUMTUKI_YKSIKKO = 'El�kkeensaajan asumistukeen oikeutetun yksik�n tunnus, DATA' 
				ONOIKEUSYKS = 'Oikeutettu el�kkeensaajan asumistukeen yksin asuessaan (0/1), DATA'
				PONOIKEUSYKS = 'Oikeutettu el�kkeensaajan asumistukeen vain puolisonsa kautta (0/1), DATA'
				VONOIKEUSYKS = 'Oikeutettu el�kkeensaajan asumistukeen vain vanhempiensa kautta (0/1), DATA'
				HALPINTAJ = 'Asunnon pinta-ala kotitalouden j�sent� kohden (m2), DATA'
				MAKSVUOKJ12 = 'Vuokra-asunnon vuokra kotitalouden j�sent� kohden (e/v), DATA'
				HOITVASTJ12 = 'Osakeasunnon hoitovastike kotitalouden j�sent� kohden (e/v), DATA'
				OMAMAKSJ = 'Omakotitalon vesi, j�te ym. maksut kotitalouden j�sent� kohden (e/v), DATA'
				OMALAMMJ = 'Omakotitalon l�mmityskulut kotitalouden j�sent� kohden (e/v), DATA'
				ASLAIKORJ = 'Asuntolainan korot kotitalouden j�sent� kohden (e/v), DATA'
				ONPUOLISO = 'Asuu puolison kanssa (0/1), DATA'
				SAAYLLESK = 'El�kkeensaajan asumistukeen yksin asuessaan oikeutettu saa yleisen perhe-el�kkeen leskenel�kett� (0/1), DATA'
				PSAAVARVANH = 'El�kkeensaajan asumistukeen vain puolison kautta oikeutettu saa alle 65-vuotiaalle maksettavaa kansanel�kelain mukaista varhennettua vanhuusel�kett� (0/1), DATA'
				OMAKOTITALO = 'Omakotitalo (0/1), DATA'
				KAYTKRYHMA = 'El�kkeensaajan asumistuen kuntaryhm� (1-4), DATA'
				ELAKEKUUKAUDET = 'Kuukausien lukum��r�, jolloin oikeutettu el�kkeensaajan asumistukeen yksin asuessaan (1-12)'
				VERONAL_DATA = 'Saadut veronalaiset tulot (e/v); vanhempiensa kautta oikeutetuille 0, DATA'
				VERONALOSINGOT_DATA = 'Saadut veronalaiset osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0, DATA'
				VEROTTOSINGOT_DATA = 'Saadut verovapaat osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0, DATA'
				OPRAHA_DATA = 'Saatu opintoraha (e/v); vanhempiensa kautta oikeutetuille 0, DATA'
				VARALLISUUS_DATA = "Varallisuuden m��r� (euroa, vuoden lopussa), DATA";

			KEEP hnro knro ELASUMTUKI_YKSIKKO
				ONOIKEUSYKS PONOIKEUSYKS VONOIKEUSYKS
				HALPINTAJ MAKSVUOKJ12 HOITVASTJ12 OMAMAKSJ OMALAMMJ ASLAIKORJ
				ONPUOLISO SAAYLLESK PSAAVARVANH OMAKOTITALO KAYTKRYHMA ELAKEKUUKAUDET
				VERONAL_DATA VERONALOSINGOT_DATA VEROTTOSINGOT_DATA OPRAHA_DATA VARALLISUUS_DATA
				evlamm rakvuosi;

		RUN;

		/* 2.2 Muodostetaan tiedot simulointiyksik�iden tasolle tauluun STARTDAT.START_ELASUMTUKI_YKSIKKO */

		/* Vied��n henkil�tasoiset tiedot simulointiyksik�n tasolle */
		PROC SQL;
			CREATE TABLE STARTDAT.START_ELASUMTUKI_YKSIKKO
			AS SELECT 
				knro,
				ELASUMTUKI_YKSIKKO,
				MAX(SAAYLLESK) AS SAAYLLESKY,
				MAX(ONPUOLISO) AS ONPUOLISOY,
				MAX(PONOIKEUSYKS) AS PONOIKEUSY,
				MAX(PSAAVARVANH) AS PSAAVARVANHY,
				SUM(VONOIKEUSYKS) AS VONOIKEUSYKSYS,
				MAX(OMAKOTITALO) AS OMAKOTITALOY,
				MAX(KAYTKRYHMA) AS KAYTKRYHMAY,
				SUM(HALPINTAJ) AS HALPINTAJYS,
				SUM(MAKSVUOKJ12) AS MAKSVUOKJ12YS,
				SUM(HOITVASTJ12) AS HOITVASTJ12YS,
				SUM(OMAMAKSJ) AS OMAMAKSJYS,
				SUM(OMALAMMJ) AS OMALAMMJYS,
				SUM(ASLAIKORJ) AS ASLAIKORJYS,
				MAX(ELAKEKUUKAUDET) AS ELAKEKUUKAUDETY,
				SUM(VERONAL_DATA) AS VERONALYS_DATA,
				SUM(VERONALOSINGOT_DATA) AS VERONALOSINGOTYS_DATA,
				SUM(VEROTTOSINGOT_DATA) AS VEROTTOSINGOTYS_DATA,
				SUM(OPRAHA_DATA) AS OPRAHAYS_DATA,
				SUM(VARALLISUUS_DATA) AS VARALLISUUSYS_DATA,
				MAX(evlamm) AS EVLAMMY,
				MAX(rakvuosi) AS RAKVUOSIY
			FROM STARTDAT.START_ELASUMTUKI_HENKI
			GROUP BY knro, ELASUMTUKI_YKSIKKO;
		QUIT;

		/* Luodaan tarvittavat uudet muuttujat */
		DATA STARTDAT.START_ELASUMTUKI_YKSIKKO;
			SET STARTDAT.START_ELASUMTUKI_YKSIKKO;
			
			/* Kumpikin puoliso oikeutettu el�kkeensaajan asumistukeen yksin asuessaan (0/1) */
			MOLEOIK = (ONPUOLISOY = 1 AND PONOIKEUSY = 0);

			/* Kumpikin puoliso oikeutettu el�kkeensaajan asumistukeen yksin asuessaan
			tai toinen oikeutettu el�kkeensaajan asumistukeen yksin asuessaan
			ja toinen saa alle 65-vuotiaalle maksettavaa kansanel�kelain mukaista
			varhennettua vanhuusel�kett� (0/1) */
			IF PSAAVARVANHY = 1 THEN MOLEOIKV = 1;
			ELSE MOLEOIKV = MOLEOIK;	

			/* Yksikk� maksaa asunnosta erillisi� vesimaksuja (0/1) 
			HUOM. P��ttelyss� k�ytett�v�t muuttujat sis�lt�v�t my�s muita maksueri� kuin vain vesimaksuja. */
			ERILVESI = (OMAMAKSJYS > 0);

			/* Yksikk� maksaa asunnosta erillisi� l�mmitysmaksuja (0/1) */
			ERILLAMPO = (OMALAMMJYS > 0);

			/* Yksik�n maksama vuokra tai yhti�vastike ja mahdollinen tontinvuokra yhteens� (e/v) */
			VUVATO = SUM(MAKSVUOKJ12YS, HOITVASTJ12YS, 0);

			LABEL 
				ELASUMTUKI_YKSIKKO = 'El�kkeensaajan asumistukeen oikeutetun yksik�n tunnus, DATA'
				SAAYLLESKY = 'Yksik�ss� on ainakin yksi el�kkeensaajan asumistukeen yksin asuessaan oikeutettu, joka saa yleisen perhe-el�kkeen leskenel�kett� (0/1), DATA'
				ONPUOLISOY = 'Yksikk� koostuu puolisoista (ja mahdollisista lapsista) (0/1), DATA'
				VONOIKEUSYKSYS = 'Niiden henkil�iden lukum��r�, jotka ovat oikeutettuja el�kkeensaajan asumistukeen vain vanhempiensa kautta (0/1), DATA'
				OMAKOTITALOY = 'Omakotitalo (0/1), DATA'
				KAYTKRYHMAY = 'El�kkeensaajan asumistuen kuntaryhm� (1-4), DATA'
				HALPINTAJYS = 'Yksik�n hallussa oleva asunnon pinta-ala  (m2), DATA'
				ASLAIKORJYS = 'Yksik�n asuntolainan korot (e/v), DATA'
				ELAKEKUUKAUDETY = 'Kuukausien lukum��r�, jolloin oikeutettu el�kkeensaajan asumistukeen yksin asuessaan, (1-12)'
				VERONALYS_DATA = 'Yksik�n saamat veronalaiset tulot (e/v), DATA'
				VERONALOSINGOTYS_DATA = 'Yksik�n saamat veronalaiset osinkotulot (e/v), DATA'
				VEROTTOSINGOTYS_DATA = 'Yksik�n saamat verovapaat osinkotulot (e/v), DATA'
				OPRAHAYS_DATA = 'Yksik�n saamat opintorahat (e/v), DATA'
				VARALLISUUSYS_DATA = 'Yksik�n varallisuus (euroa, vuoden lopussa), DATA'
				EVLAMMY = 'El�kkeensaajan asumistuen l�mmitysryhm� (1-3), DATA'
				RAKVUOSIY = 'Asunnon rakennus/peruskorjausvuosi, DATA'
				MOLEOIK = 'Kumpikin puoliso oikeutettu el�kkeensaajan asumistukeen yksin asuessaan (0/1), DATA' 
				MOLEOIKV = 'Kumpikin puoliso oikeutettu el�kkeensaajan asumistukeen yksin asuessaan tai toinen saa kansanel�kelain mukaista varhennettua vanhuusel�kett� (0/1), DATA' 
				ERILVESI = 'Yksikk� maksaa asunnosta erillisi� vesimaksuja (0/1), DATA'
				ERILLAMPO = 'Yksikk� maksaa asunnosta erillisi� l�mmitysmaksuja (0/1), DATA'
				VUVATO = 'Yksik�n maksama vuokra tai hoitovastike ja mahdollinen tontinvuokra yhteens� (e/v), DATA';

			KEEP knro ELASUMTUKI_YKSIKKO
				SAAYLLESKY ONPUOLISOY VONOIKEUSYKSYS
				OMAKOTITALOY KAYTKRYHMAY HALPINTAJYS ASLAIKORJYS
				ELAKEKUUKAUDETY
				VERONALYS_DATA VERONALOSINGOTYS_DATA VEROTTOSINGOTYS_DATA OPRAHAYS_DATA VARALLISUUSYS_DATA
				EVLAMMY RAKVUOSIY
				MOLEOIK MOLEOIKV ERILVESI ERILLAMPO VUVATO; 

		RUN;

		/* J�rjestet��n havainnot simulointiyksik�n numeron mukaiseen j�rjestykseen */
		PROC SORT DATA = STARTDAT.START_ELASUMTUKI_YKSIKKO;
			BY ELASUMTUKI_YKSIKKO;
		RUN;

	%END;

%MEND ElAsumTuki_Muut_Poiminta;

%ElAsumTuki_Muut_Poiminta;


%LET alkoi2&malli = %SYSFUNC(TIME());


/* 3. Makro hakee tietoja muista osamalleista ja liitt�� ne dataan */

%MACRO OsaMallit_ElAsumTuki;

	/* Jos veronalaisia tulonsiirtoja tai veroja on simuloitu,
	haetaan	veronalaiset tulot ja verottomat osinkotulot VERO-mallista */

	%IF &VERO = 1 %THEN %DO;

		/* J�rjestet��n havainnot henkil�numeron mukaiseen j�rjestykseen taulussa STARTDAT.START_ELASUMTUKI_HENKI */

		PROC SORT DATA = STARTDAT.START_ELASUMTUKI_HENKI;
			BY hnro;
		RUN;

		/* 3.1. Haetaan tiedot henkil�tasolla tauluun STARTDAT.START_ELASUMTUKI_HENKI */

		DATA STARTDAT.START_ELASUMTUKI_HENKI;
			UPDATE STARTDAT.START_ELASUMTUKI_HENKI (IN = A)
			TEMP.&TULOSNIMI_VE (KEEP = hnro ANSIOT POTULOT OSINKOA OSINKOP OSINKOVAP OPTUKI_SIMUL)
			UPDATEMODE=NOMISSINGCHECK;
			BY hnro;
			IF A;

			VERONAL_MALLI = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(ANSIOT, POTULOT, 0), 0);
			VERONALOSINGOT_MALLI = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(OSINKOA, OSINKOP, 0), 0);
			VEROTTOSINGOT_MALLI = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(OSINKOVAP, 0), 0);
			OPRAHA_MALLI = IFN(((ONOIKEUSYKS = 1) OR (PONOIKEUSYKS = 1)), SUM(OPTUKI_SIMUL, 0), 0);

			LABEL
				VERONAL_MALLI = 'Saadut veronalaiset tulot (e/v); vanhempiensa kautta oikeutetuille 0, MALLI'
				VERONALOSINGOT_MALLI = 'Saadut veronalaiset osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0, MALLI'
				VEROTTOSINGOT_MALLI = 'Saadut verovapaat osinkotulot (e/v); vanhempiensa kautta oikeutetuille 0, MALLI'
				OPRAHA_MALLI = 'Saatu opintoraha (e/v); vanhempiensa kautta oikeutetuille 0, MALLI';
				
		RUN;

		/* 3.2. Muodostetaan tiedot simulointiyksik�iden tasolle tauluun STARTDAT.START_ELASUMTUKI_YKSIKKO */

		PROC SORT DATA = STARTDAT.START_ELASUMTUKI_HENKI;
			BY ELASUMTUKI_YKSIKKO;
		RUN;

		PROC MEANS DATA = STARTDAT.START_ELASUMTUKI_HENKI SUM NOPRINT;
			BY ELASUMTUKI_YKSIKKO;
			VAR VERONAL_MALLI VERONALOSINGOT_MALLI VEROTTOSINGOT_MALLI OPRAHA_MALLI;
			OUTPUT OUT = TEMP.TEMP_ELASUMTUKI_YKSIKKO_VE 
				SUM(VERONAL_MALLI) = VERONALYS_MALLI
				SUM(VERONALOSINGOT_MALLI) = VERONALOSINGOTYS_MALLI
				SUM(VEROTTOSINGOT_MALLI) = VEROTTOSINGOTYS_MALLI
				SUM(OPRAHA_MALLI) = OPRAHAYS_MALLI;
		RUN;

		DATA STARTDAT.START_ELASUMTUKI_YKSIKKO;
			UPDATE STARTDAT.START_ELASUMTUKI_YKSIKKO (IN = A) TEMP.TEMP_ELASUMTUKI_YKSIKKO_VE (KEEP = ELASUMTUKI_YKSIKKO VERONALYS_MALLI VERONALOSINGOTYS_MALLI VEROTTOSINGOTYS_MALLI OPRAHAYS_MALLI)
			UPDATEMODE=NOMISSINGCHECK;
			BY ELASUMTUKI_YKSIKKO;
			IF A;

			LABEL
				VERONALYS_MALLI = 'Yksik�n saamat veronalaiset tulot (e/v), MALLI'
				VERONALOSINGOTYS_MALLI = 'Yksik�n saamat veronalaiset osinkotulot (e/v), MALLI'
				VEROTTOSINGOTYS_MALLI = 'Yksik�n saamat verovapaat osinkotulot (e/v), MALLI'
				OPRAHAYS_MALLI = 'Yksik�n saamat opintorahat (e/v), MALLI';

		RUN;
		
	%END;

%MEND Osamallit_ElAsumTuki;

%OsaMallit_ElAsumTuki;


/* 4. Simulointi */

%MACRO ElAsumTuki_Simuloi_Data;

	/* Luodaan makromuuttujat, joihin haetaan mallin k�ytt�mien lakiparametrien nimilistat */
	%LOCAL ELASUMTUKI_PARAM ELASUMTUKI_MUUNNOS;

	/* Haetaan kaikkien mallin k�ytt�mien lakiparametrien nimilista */
	%HaeLokaalit(ELASUMTUKI_PARAM, ELASUMTUKI);

	/* Haetaan niiden mallin k�ytt�mien lakiparametrien nimilista, joille tehd��n valuutta- ja inflaatiomuuunnos */ 
	%HaeLaskettavatLokaalit(ELASUMTUKI_MUUNNOS, ELASUMTUKI);

	/* Luodaan makromuuttujat, joihin haetaan lakiparametrien arvot */
	%LOCAL &ELASUMTUKI_PARAM;

	/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */
	%KuukSimul(ELASUMTUKI);
	
	/* 4.1 Simuloitu el�kkeensaajan asumistuki lasketaan tauluun TEMP.&TULOSNIMI_EA */

	DATA TEMP.TEMP_ELASUMTUKI_YKSIKKO_TULOS;
		SET STARTDAT.START_ELASUMTUKI_YKSIKKO;

		/* Valitaan, k�ytet��nk� simuloituja tietoja muista osamalleista vai alkuper�isen datan tietoja */
		%IF &VERO = 1 %THEN %DO;
			VERONALYS = VERONALYS_MALLI;
			VERONALOSINGOTYS = VERONALOSINGOTYS_MALLI;
			VEROTTOSINGOTYS = VEROTTOSINGOTYS_MALLI;
			OPRAHAYS = OPRAHAYS_MALLI;
		%END;
		%ELSE %DO;
			VERONALYS = VERONALYS_DATA;
			VERONALOSINGOTYS = VERONALOSINGOTYS_DATA;
			VEROTTOSINGOTYS = VEROTTOSINGOTYS_DATA;
			OPRAHAYS = OPRAHAYS_DATA;
		%END;

		/* Jos korot ja osinkotulot ovat yhteens� yli 60 euroa vuodessa, ne otetaan kokonaisuudessaan tulona huomioon.
		Jos korot ja osinkotulot ovat korkeintaan 60 euroa vuodessa, niit� ei oteta lainkaan tulona huomioon */
		IF SUM(VERONALOSINGOTYS, VEROTTOSINGOTYS) > 60 THEN HUOMTULOT = SUM(VERONALYS, VEROTTOSINGOTYS, -OPRAHAYS);
		ELSE HUOMTULOT = SUM(VERONALYS, -VERONALOSINGOTYS, -OPRAHAYS);

		/* Varsinainen simulointi */
		%ElakAsumTukiVS(ELAKASUMTUKI, &LVUOSI, &INF, ONPUOLISOY, MOLEOIKV, SAAYLLESKY, 0, VONOIKEUSYKSYS,
			OMAKOTITALOY, EVLAMMY, 1, 1, ERILVESI, ERILLAMPO, HALPINTAJYS, RAKVUOSIY, KAYTKRYHMAY,
			HUOMTULOT, VARALLISUUSYS_DATA, VUVATO, ASLAIKORJYS);

		/* Tuki vain el�kekuukausille */
		ELAKASUMTUKI = ELAKEKUUKAUDETY * ELAKASUMTUKI;

		/* Jos molemmilla puolisoilla olisi oikeus tukeen yksin asuessaan, niin jaetaan tuki puoliksi */
		IF MOLEOIK = 1 THEN ELAKASUMTUKI = ELAKASUMTUKI / 2;

	RUN;

	/* Simuloitu el�kkeensaajan asumistuki vied��n kaikille henkil�ille, joilla ONOIKEUSYKS = 1 */
	PROC SQL;
		CREATE TABLE TEMP.&TULOSNIMI_EA
		AS SELECT a.hnro, MAX(b.ELAKASUMTUKI,0) AS ELAKASUMTUKI
		FROM STARTDAT.START_ELASUMTUKI_HENKI AS a
		LEFT JOIN TEMP.TEMP_ELASUMTUKI_YKSIKKO_TULOS AS b 
		ON (a.ELASUMTUKI_YKSIKKO = b.ELASUMTUKI_YKSIKKO AND a.ONOIKEUSYKS = 1)
		ORDER BY hnro;
	QUIT;

	DATA TEMP.&TULOSNIMI_EA;
		SET TEMP.&TULOSNIMI_EA;

		/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */
		ARRAY PISTE
			ELAKASUMTUKI;
		DO OVER PISTE;
			IF PISTE <= 0 THEN PISTE = .;
		END;

		/* Annetaan simuloiduille muuttujille selitteet */
		LABEL 
		ELAKASUMTUKI = 'El�kkeensaajan asumistuki, MALLI';

	RUN;

	/* 4.2 Luodaan tulostiedosto OUTPUT-kansioon */

	/* T�t� vaihetta ei ajeta mik�li osamallia k�ytet��n KOKO-mallin kautta. */

	%IF &START NE 1 %THEN %DO;

		/* Yhdistet��n tulokset pohja-aineistoon */

		DATA TEMP.&TULOSNIMI_EA;
			
			/* 4.2.1 Suppea tulostaulu (vain t�rkeimm�t pohja-aineiston luokittelumuuttujat) */

			%IF &TULOSLAAJ = 1 %THEN %DO; 
				MERGE POHJADAT.&AINEISTO&AVUOSI
				(KEEP = hnro knro &PAINO eastuki ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
				TEMP.&TULOSNIMI_EA;
			%END;

			/* 4.2.2 Laaja tulostaulu (kaikki pohja-aineiston muuttujat) */

			%IF &TULOSLAAJ = 2 %THEN %DO; 
				MERGE POHJADAT.&AINEISTO&AVUOSI
				TEMP.&TULOSNIMI_EA;
			%END;

			/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */
			ARRAY PISTE
				eastuki;
			DO OVER PISTE;
				IF PISTE <= 0 THEN PISTE = .;
			END;

			/* Annetaan simuloiduille muuttujille selitteet */
			LABEL 
			eastuki = 'El�kkeensaajan asumistuki, DATA';

			BY hnro;

		RUN;

		/* Jos k�ytt�j� on m��ritellyt YKSIKKO = 2 eli pyyt�nyt tulokset kotitaloustasolla,
		niin summataan tulokset kotitaloustasolle tauluun OUTPUT.&TULOSNIMI_EA._KOTI
		ja poistetaan sen j�lkeen taulu TEMP.&TULOSNIMI_EA */
		%IF &YKSIKKO=2 AND &START^=1 %THEN %DO;
			%SumKotitT(OUTPUT.&TULOSNIMI_EA._KOTI, TEMP.&TULOSNIMI_EA, &MALLI, &MUUTTUJAT);
			PROC DATASETS LIBRARY=TEMP NOLIST;
				DELETE &TULOSNIMI_EA;
			RUN;
			QUIT;
		%END;

		/* Jos k�ytt�j� on m��ritellyt YKSIKKO = 1 eli pyyt�nyt tulokset henkil�tasolla, tai YKSIKKO on mit� tahansa muuta kuin 2,
		niin j�tet��n tulostaulu henkil�tasolle ja nimet��n se uudelleen nimelle OUTPUT.&TULOSNIMI_EA._HLO */
		%ELSE %DO;
			PROC DATASETS LIBRARY=TEMP NOLIST;
				DELETE &TULOSNIMI_EA._HLO;
				CHANGE &TULOSNIMI_EA=&TULOSNIMI_EA._HLO;
				COPY OUT=OUTPUT MOVE;
				SELECT &TULOSNIMI_EA._HLO;
			RUN;
			QUIT;
		%END;

		/* Tyhjennet��n TEMP-kirjasto */
		%IF &TEMPTYHJ = 1 %THEN %DO;
			PROC DATASETS LIBRARY=TEMP NOLIST KILL;
			RUN;
			QUIT;
		%END;

	%END;

%MEND ElAsumTuki_Simuloi_Data;

%ElAsumTuki_Simuloi_Data;


%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Tulostetaan k�ytt�j�n pyyt�m�t taulukot */

%MACRO KutsuTulokset;

	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_EA._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_EA._KOTI,2);
	%END;
	
	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START^=1 and &EG = 1 %THEN %DO;
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