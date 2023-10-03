/************************************************************************
* Kuvaus: Toimeentulotuen simulointimalli 2019							*
* Viimeksi päivitetty: 29.5.2020 										*
************************************************************************/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = TOIMTUKI;

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

			%LET LKUUK = 12;        * Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

			%LET AINEISTO = REK;  	* Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

			%LET TULOSNIMI_TO = toimtuki_simul_&SYSDATE._1; * Simuloidun tulostiedoston nimi;

			* Simuloidaanko toimeentulotuki myös yrittäjätalouksille.
	  	   	Jos toimeentulotukea ei simuloida yrittäjätalouksille, tämä on 0.
	       	Jos toimeentulotuki simuloidaan yrittäjätalouksille, tämä on 1.;
			%LET YRIT = 0;

			%LET ASUMKUST_MAKS = 0; *Käytetäänkö simuloinnissa Kelan ohjeellisia asumiskustannusten maksimiarvoja (1 käytetään, 0 ei käytetä);

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
			%LET POIMINTA = 1;  						* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
			%LET TULOKSET = 1;							* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

			* Käytettävien tiedostojen nimet ;
			%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakrotiedoston nimi;
			%LET PTOIMTUKI = ptoimtuki;

			* Tulostaulukoiden esivalinnat ; 
			%LET TULOSLAAJ = 1; 	 					* Mikrotason tulosaineiston laajuus (1=suppea, 2 = laaja (kaikki pohja-aineiston muuttujat));
			%LET MUUTTUJAT = TOIMTUKI htoimtuk; 		* Taulukoitavat muuttujat (summataulukot) ;
			%LET YKSIKKO = 1;		 					* Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
			%LET LUOK_HLO1 = desmod; 					* Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
									   					Vaihtoehtoina: 
									     				desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
									     				ikavu (ikäryhmät)
									     				elivtu (kotitalouden elinvaihe)
									     				koulas (koulutusaste)
									     				soss (sosioekonominen asema)
									     				rake (kotitalouden rakenne)
														maakunta (NUTS3-aluejaon mukainen maakuntajako);
			%LET LUOK_HLO2 = ;		 					* Taulukoinnin 2. henkilöluokitus ;
			%LET LUOK_HLO3 = ;		 					* Taulukoinnin 3. henkilöluokitus ;
			%LET LUOK_KOTI1 = desmod; 					* Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
												    	Vaihtoehtoina: 
												     	desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
													    ikavuv (viitehenkilön mukaiset ikäryhmät)
													    elivtu (kotitalouden elinvaihe)
													    koulasv (viitehenkilön koulutusaste)
													    paasoss (viitehenkilön sosioekonominen asema)
													    rake (kotitalouden rakenne)
														maakunta (NUTS3-aluejaon mukainen maakuntajako);
			%LET LUOK_KOTI2 = ; 	  					* Taulukoinnin 2. kotitalousluokitus ;
			%LET LUOK_KOTI3 = ; 	  					* Taulukoinnin 3. kotitalousluokitus ;
			%LET EXCEL = 0; 		  					* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei);

			* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);
			%LET SUMWGT = SUMWGT; 	* N eli lukumäärät ;
			%LET SUM = SUM; 
			%LET MIN = ; 
			%LET MAX = ;
			%LET RANGE =  ;
			%LET MEAN = ;
			%LET MEDIAN = ;
			%LET MODE =  ;
			%LET VAR = ;
			%LET CV =  ;
			%LET STD =  ;

			%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana);
			%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

		%END;

		/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

		%LET TTURVA = 0; 
		%LET KANSEL = 0; 
		%LET OPINTUKI = 0; 
		%LET VERO = 0; 
		%LET KIVERO = 0;
		%LET LLISA = 0;
		%LET ELASUMTUKI = 0;  
		%LET ASUMTUKI = 0; 
		%LET PHOITO = 0; 

		/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

		%InfKerroin(&AVUOSI, &LVUOSI, &INF);

	%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";

%MEND Aloitus;

%Aloitus;

%put &asumkust_maks;
%put &poiminta;

/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO ToimTuki_Muutt_Poiminta;

	%IF &POIMINTA = 1 %THEN %DO;

/* 2.1 Poimitaan tarvittavat palveluaineiston muuttujat taulukkoon STARTDAT.START_TOIMTUKI */

		DATA STARTDAT.START_TOIMTUKI;
			SET POHJADAT.&AINEISTO&AVUOSI
			(KEEP = hnro knro asko ikakk ikavu svatva svatvp verot ltvp lahdever omakkiiv elama korotv
			llmk kokorve kellaps rili riyl amstipe lbeltuki lbdpperi hsotav hasepr elasa rahsa
			ulkelve ulkelmuu hsotvkor hastuki hasuli maksvuok kaytkorv yhtiovas lisalamm omalamm omamaks
			tontvuok aslaikor sahko apuraha hlakav vtyomj vthmp vmatk vevm lpvma tnoosvvb teinovvb tuosvvap
			toyjmyvvap toyjmavvap teinovv lassa muusa paasoss hulkpa tulkp tepalkat toptiot tosinktp telps43 tmuukust
			tepalk tmerile tpalv trespa tepertyok1 tepertyok2 telps41 telps42 telps8 telps1 telps2 tutmp235 tutmp4 tmtatt
			telps5 ttyoltuk tyhtat hoiaikak hoimaksk hoiaikao
			hoimakso hoiaikay hoimaksy hopila opirake opirako tukiaika optukk tpjta aemkm hoiaikap hoimaksp
			varm lveru anstukor yrtukor vvvmk1 vvvmk3 vvvmk5 dtyhtep korosapks korosapkw yhtez korosazkg
			korosazkf tmtukimk korosatkg korosatkf tmaat1evyr tmaat1pevyr tliik1evyr tliikpevyr tporo1evyr
			tyhtmatevyr tyhtateevyr tyhtmat	tyhtate yrvahan yrvahpo kuntakoodi jasenia AILMKORQDAT);
		RUN;

/* 2.2 Muodostetaan laskennassa tarvittavat yksilötason muuttujat taulukkoon STARTDAT.START_TOIMTUKI */

		DATA STARTDAT.START_TOIMTUKI;
			SET STARTDAT.START_TOIMTUKI;

			IKAKUUKAUSINA = SUM(ikavu * 12, ikakk);

			* Niiden kuukausien osuus, jona henkilö ei ole ollut armeijassa tai siviilipalveluksessa;
			EIAMSI = (12-varm)/12;

			* Perheaseman määrittely;
			IF (asko = 1) OR (asko = 2) OR (asko = 3 AND IKAKUUKAUSINA <= 0) OR (asko NE 1 AND asko NE 2 AND asko NE 3) THEN ONAIK = 1;
			ELSE ONAIK = 0;
			IF asko = 3 AND IKAKUUKAUSINA >= 216 THEN ONAIKLAPSI = 1;
			ELSE ONAIKLAPSI = 0;
			IF asko = 3 AND IKAKUUKAUSINA >= 204 AND IKAKUUKAUSINA < 216 THEN ONLAPSI17 = 1;
			ELSE ONLAPSI17 = 0;
			IF asko = 3 AND IKAKUUKAUSINA >= 120 AND IKAKUUKAUSINA < 204 THEN ONLAPSI10_16 = 1;
			ELSE ONLAPSI10_16 = 0;
			IF asko = 3 AND IKAKUUKAUSINA > 0 AND IKAKUUKAUSINA < 120 THEN ONLAPSIALLE10 = 1;
			ELSE ONLAPSIALLE10 = 0;

			* Veronalainen työtulo;
			VERTYOTULO = SUM(tepalkat,toptiot,tosinktp, tulkp, telps43, tmuukust,
					tepalk, tmerile, tpalv, trespa, tepertyok1, tepertyok2, telps41, telps42, telps8, telps1,
					tutmp235, tutmp4, telps2, telps5, ttyoltuk, 
					tmaat1evyr, tmaat1pevyr, tpjta, tliik1evyr, tliikpevyr, tporo1evyr,
					tyhtmatevyr, tyhtateevyr, SUM(tyhtat, -tyhtmat, -tyhtate),
					tmtatt, anstukor, yrtukor);

			* Verovapaa työtulo;
			VEROTTYOTULO = SUM(hulkpa);

			* Toimeentulotukeen vaikuttavat muut verovapaat tulot;
			VEROTTUL_MUU = SUM(kokorve, -lahdever, amstipe, apuraha, hlakav,	
					hsotvkor, hsotav, elasa, rahsa, lassa, muusa,
					hasepr, ulkelve, ulkelmuu);

			* Sekalaisia veroja;
			SEKALVERO = korotv;

			* Työmatkamatkakulut. 
			Rajoitetaan ilmoitetut matkakulut verotuksessa hyväksyttävään maksimiin
			(ml. omavastuu) rekisteriaineiston poikkeavien havaintojen vuoksi;
			VMATKR = MIN(SUM(vmatk, 0), 7600);

			* Tulonhankkimiskulut;
			THANKK = SUM(VMATKR, vtyomj, vthmp);

			* Asumiskustannukset kuukautta kohden;
			ASUMISKULUT_KK = SUM(maksvuok, kaytkorv, yhtiovas, aslaikor / 12, lisalamm / 12,
					omalamm / 12, omamaks / 12, tontvuok / 12, sahko / 12);

			* Yksityiset päivähoitomaksut;
			PHOITO_YKS = SUM(hoiaikay * hoimaksy, hoiaikap * hoimaksp);

			*Maksetut elatusmaksut;
			ELMAKSUT = elama;

			* Eläkkeenlisät;
			ELLISAT_DATA = SUM(kellaps, rili, riyl);

		 	*Opiskelijan asumislisä;
			ASUMLISA_DATA = hasuli;
				
			* Potentiaalinen opintolaina;
			OPINTOLAINA_DATA = hopila;

			* Veronalaiset ansiotulot (yrittäjävähennystä ei ole tehty);
			ANSIOT_DATA = SUM(svatva, yrvahan);

			* Veronalaiset pääomatulot (yrittäjävähennystä ei ole tehty);
			POTULOT_DATA = SUM(svatvp, yrvahpo);

			* Toimeentulotukeen vaikuttavat verottomat osinkotulot;
			OSINGOT_VEROVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, toyjmyvvap, toyjmavvap, teinovv);	

			* Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu;
			MAKSVEROT_DATA = SUM(verot, -PRAHAMAKSU_DATA, lveru);

			* Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu;
			ANSIOVEROT_DATA = SUM(MAKSVEROT_DATA, -ltvp);

			* Sairausvakuutuksen päivärahamaksu;
			PRAHAMAKSU_DATA = lpvma;

			*Työeläke- ja työttömyysvakuutusmaksut;
			PALKVAK_DATA = vevm;

			* Kiinteistövero;
			KIVERO_DATA = omakkiiv;

			* Lapsilisä;
			LLISAT_DATA = llmk;

			* Elatustuki;
			ELTUKI_DATA = SUM(lbeltuki, lbdpperi);

			* Eläkkeensaajan asumistuki;
			ELASUMTUKI_DATA = aemkm; 

			* Yleinen asumistuki;
			ASUMTUKI_DATA = hastuki;

			* Päivähoitomaksut yhteensä;
			PHOITO_DATA = SUM(hoiaikak * hoimaksk, hoiaikao * hoimakso, PHOITO_YKS);
			
			* Harkinnanvaraiset menot;
			HARKINMENOT_DATA = SUM(ELMAKSUT, PHOITO_DATA);

			* Työttömyysturva korotusosilla ja ilman;
			TYOTTURVA_DATA = SUM(MAX(vvvmk1, 0), MAX(vvvmk3, 0), MAX(vvvmk5, 0),
				MAX(0, SUM(dtyhtep, korosapks, korosapkw)), MAX(SUM(yhtez, korosazkg, korosazkf), 0),
				MAX(SUM(tmtukimk, korosatkg, korosatkf), 0));
			TYOTTURVA_ILMKOR_DATA = SUM(MAX(AILMKORQDAT, 0), MAX(vvvmk3, 0),
				MAX(SUM(dtyhtep, korosapks), 0), MAX(yhtez, 0), MAX(tmtukimk, 0));
			
			* Opintoraha;
			OPINRAHA_DATA = SUM(opirake, opirako);
		
			KEEP hnro knro paasoss kuntakoodi jasenia
				EIAMSI
				ONAIK ONAIKLAPSI ONLAPSI17 ONLAPSI10_16 ONLAPSIALLE10
				VERTYOTULO VEROTTYOTULO VEROTTUL_MUU SEKALVERO THANKK ASUMISKULUT_KK PHOITO_YKS ELMAKSUT 
				ELLISAT_DATA ASUMLISA_DATA OPINTOLAINA_DATA
				ANSIOT_DATA POTULOT_DATA OSINGOT_VEROVAP_DATA MAKSVEROT_DATA ANSIOVEROT_DATA PRAHAMAKSU_DATA PALKVAK_DATA KIVERO_DATA
				LLISAT_DATA ELTUKI_DATA	ELASUMTUKI_DATA ASUMTUKI_DATA HARKINMENOT_DATA TYOTTURVA_DATA TYOTTURVA_ILMKOR_DATA OPINRAHA_DATA;
	 
		RUN;

		PROC SORT DATA=STARTDAT.START_TOIMTUKI;
			BY knro;
		RUN;

		DATA STARTDAT.START_TOIMTUKI;
			SET STARTDAT.START_TOIMTUKI;
			BY knro;
			RETAIN JARJ;
			IF FIRST.knro THEN JARJ = 0;
			JARJ = JARJ + 1;
			LABEL
				EIAMSI = "Niiden kuukausien osuus, jona henkilö ei ole ollut armeijassa tai siviilipalveluksessa, DATA"	
				ONAIK = "Aikuinen (0/1), DATA"
				ONAIKLAPSI = "18-vuotias tai vanhempi lapsi (0/1), DATA"
				ONLAPSI17 = "17-vuotias lapsi (0/1), DATA"
				ONLAPSI10_16 = "10-16-vuotias lapsi (0/1), DATA"
				ONLAPSIALLE10 = "Alle 10-vuotias lapsi (0/1), DATA"
				VERTYOTULO = "Veronalainen työtulo (e/v), DATA"
				VEROTTYOTULO = "Verovapaa työtulo (e/v), DATA"
				VEROTTUL_MUU = "Toimeentulotukeen vaikuttavat muut verovapaat tulot (e/v), DATA"
				SEKALVERO = "Sekalaisia veroja (e/v), DATA"
				THANKK = "Tulonhankkimiskulut (e/v), DATA"
				ASUMISKULUT_KK = "Asumiskulut (e/kk), DATA"
				PHOITO_YKS = "Yksityiset päivähoitomaksut (e/v), DATA"
				ELMAKSUT = "Elatusmaksut (e/v), DATA"
				ELLISAT_DATA = "Eläkkeenlisät (e/v), DATA"
				ASUMLISA_DATA = "Opiskelijan asumislisä (e/v), DATA"
				OPINTOLAINA_DATA = "Potentiaalinen opintolaina (e/v), DATA"
				ANSIOT_DATA = "Veronalaiset ansiotulot (e/v), DATA"
				POTULOT_DATA = "Veronalaiset pääomatulot (e/v), DATA"
				OSINGOT_VEROVAP_DATA = "Toimeentulotukeen vaikuttavat verovapaat osinkotulot (e/v), DATA"
				MAKSVEROT_DATA = "Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
				ANSIOVEROT_DATA = "Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
				PRAHAMAKSU_DATA = "Sairausvakuutuksen päivärahamaksu (e/v), DATA"
				PALKVAK_DATA = "Työeläke- ja työttömyysvakuutusmaksut (e/v), DATA"
				KIVERO_DATA = "Kiinteistövero (e/v), DATA"
				LLISAT_DATA = "Lapsilisä (e/v), DATA"
				ELTUKI_DATA = "Elatustuki (e/v), DATA"
				ELASUMTUKI_DATA = "Eläkkeensaajan asumistuki (e/v), DATA"
				ASUMTUKI_DATA = "Yleinen asumistuki (e/v), DATA"
				HARKINMENOT_DATA = "Harkinnanvaraiset menot (e/v), DATA"
				TYOTTURVA_DATA = "Työttömyysturvaetuudet (e/v), DATA"
				TYOTTURVA_ILMKOR_DATA = "Työttömyysturvaetuudet ilman korotusosia (e/v), DATA"
				JARJ = "Henkilön järjestysnumero kotitaloudessa, DATA";
		RUN;

	%END;

%MEND ToimTuki_Muutt_Poiminta;

%ToimTuki_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());


/* 3. Makro hakee tietoja muista osamalleista ja liittää ne mallin dataan */

%MACRO OsaMallit_ToimTuki;

%IF &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &VERO = 1 OR &KIVERO = 1 OR &LLISA = 1 OR &ELASUMTUKI = 1
	OR &ASUMTUKI = 1 OR &PHOITO = 1 %THEN %DO;

	DATA STARTDAT.START_TOIMTUKI;
		MERGE STARTDAT.START_TOIMTUKI (IN = C)

		/* 3.1 Työttömyysturva */
		%IF &TTURVA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_TT
			(KEEP = hnro YHTTMTUKI PERUSPR ANSIOPR VUORKORV TMTUKILMKOR PERILMAKOR ANSIOILMKOR)
		%END;

		/* 3.2 Eläkkeen lisiä ja maahanmuuttajan erityistuki */
		%IF &KANSEL = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KE
			(KEEP = hnro LAPSIKOROT RILISA YLIMRILI MMTUKI)
		%END;

		/* 3.3 Opintoraha, asumislisä ja potentiaalinen opintolaina */
		%IF &OPINTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_OT
			(KEEP = hnro TUKIKESK TUKIKESK_ILMOP TUKIKOR TUKIKOR_ILMOP ASUMLISA OPLAIN)
		%END;

		/* 3.4 Veromalli */
		%IF &VERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_VE
			(KEEP = hnro ANSIOT POTULOT OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROC YLEVERO)
		%END;

		/* 3.5 Kiinteistöverotus */
		%IF &KIVERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KV
			(KEEP = hnro KIVEROYHT2)
		%END;

		/* 3.6 Lapsilisä ja elatustuki */
		%IF &LLISA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_LL
			(KEEP = hnro LLISA_HH ELATUSTUET_HH)
		%END;

		/* 3.7 Eläkkeensaajien asumistuki */
		%IF &ELASUMTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_EA
			(KEEP = hnro ELAKASUMTUKI)
		%END;

		/* 3.8 Yleinen asumistuki */
		%IF &ASUMTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_YA
			(KEEP = hnro TUKISUMMA)
		%END;

		/* 3.9 Lasten päivähoitomaksut */
		%IF &PHOITO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_PH
			(KEEP = hnro PHMAKSU_KOK PHMAKSU_OS)
		%END;

		;
		BY hnro;
		IF C;
	RUN;

%END;

%MEND OsaMallit_ToimTuki;

%OsaMallit_ToimTuki;


/* 4. Simulointivaihe */

/* 4.1 Varsinainen simulointivaihe */

%MACRO ToimTuki_Simuloi_Data;

	* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä;
	%LOCAL TOIMTUKI_PARAM TOIMTUKI_MUUNNOS;
	* Haetaan mallin käyttämien lakiparametrien nimet;
	%HaeLokaalit(TOIMTUKI_PARAM, TOIMTUKI);
	%HaeLaskettavatLokaalit(TOIMTUKI_MUUNNOS, TOIMTUKI);
	* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten;
	%LOCAL &TOIMTUKI_PARAM;

	/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */
	%KuukSimul(TOIMTUKI);

	DATA TEMP.TEMP_TOIMTUKI_HENKI;
		SET STARTDAT.START_TOIMTUKI;

/* 4.1.1 Päätellään, käytetäänkö simuloituja tietoja muista osamalleista vai alkuperäisen datan tietoja */

		* Toimeentulotukeen vaikuttavat verottomat eläkkeenlisät ja maahanmuuttajan erityistuki: data vs. simuloitu;
		%IF &KANSEL = 1 %THEN %DO;
			ELLISAT_SIMUL = SUM(LAPSIKOROT,  RILISA, YLIMRILI);
			MAMUTUKI_SIMUL = MMTUKI;
		%END;
		%ELSE %DO; 
			ELLISAT_SIMUL = ELLISAT_DATA;
			MAMUTUKI_SIMUL = .;
		%END;

		* Opintoraha, asumislisä ja potentiaalinen opintolaina: data vs. simuloitu;
		%IF &OPINTUKI = 1 %THEN %DO;
			OPINRAHA_SIMUL = SUM(TUKIKESK, TUKIKOR);
			OPINRAHA_ILMOP_SIMUL = SUM(TUKIKESK_ILMOP, TUKIKOR_ILMOP);
			ASUMLISA_SIMUL = ASUMLISA;
			OPINTOLAINA_SIMUL = OPLAIN;
		%END;
		%ELSE %DO;
			OPINRAHA_SIMUL = OPINRAHA_DATA;
			OPINRAHA_ILMOP_SIMUL = OPINRAHA_DATA; 
			ASUMLISA_SIMUL = ASUMLISA_DATA;
			OPINTOLAINA_SIMUL = OPINTOLAINA_DATA;
		%END;
		* Nollataan laskennan perusteena oleva opintolaina alle 18-vuotiailta, koska heitä ei STM:n ohjeiden
		  mukaan edellytetä ottamaan opintolainaa ennen toimeentulotuen saamista;
		IF ONLAPSI17=1 OR ONLAPSI10_16=1 OR ONLAPSIALLE10=1 THEN OPINTOLAINA_SIMUL = 0;

		* Veronalaiset tulonsiirtojen vaikutus tulee VERO-mallin kautta.
		  VERO-mallista haetaan myös veronalaiset pääomatulot, verottomat osinkotulot sekä eri verolajit;	
		%IF &VERO = 1 %THEN %DO; 
			* Veronalaiset ansiotulot VERO-mallista;
			ANSIOT_SIMUL = ANSIOT;
			* Veronalaiset pääomatulot VERO-mallista;
			POTULOT_SIMUL = POTULOT;
			* Verottomat osinkotulot;
			OSINGOT_VEROVAP_SIMUL = OSINKOVAP;
			* Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu;
			MAKSVEROT_SIMUL = SUM(ANSIOVEROT, POVEROC, YLEVERO);
			* Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu;
			ANSIOVEROT_SIMUL = ANSIOVEROT;
			* Sairausvakuutuksen päivärahamaksut;
			PRAHAMAKSU_SIMUL = PRAHAMAKSU;
			* Työeläke- ja työttömyysvakuutusmaksut;
			PALKVAK_SIMUL = PALKVAK;
		%END;
		%ELSE %DO;
			* Jos veronalaisten tulonsiirtojen malleja tai VERO-mallia ei
			  ole ajettu, vastaavat tiedot otetaan datasta;	
			ANSIOT_SIMUL = ANSIOT_DATA;
			POTULOT_SIMUL = POTULOT_DATA;
			OSINGOT_VEROVAP_SIMUL = OSINGOT_VEROVAP_DATA;
			MAKSVEROT_SIMUL = MAKSVEROT_DATA;
			ANSIOVEROT_SIMUL = ANSIOVEROT_DATA;
			PRAHAMAKSU_SIMUL = PRAHAMAKSU_DATA;
			PALKVAK_SIMUL = PALKVAK_DATA;
		%END;

		* Kiinteistövero: data vs. simuloitu;
		%IF &KIVERO = 1 %THEN %DO;
			KIVERO_SIMUL = KIVEROYHT2;
		%END;
		%ELSE %DO; 
			KIVERO_SIMUL = KIVERO_DATA; 
		%END;

		* Toimeentulotukeen vaikuttavat lapsilisät ja elatustuet: data vs. simuloitu;
		%IF &LLISA = 1 %THEN %DO;
			LLISAT_SIMUL = LLISA_HH;
			ELTUKI_SIMUL = ELATUSTUET_HH;
		%END;
		%ELSE %DO; 
			LLISAT_SIMUL = LLISAT_DATA;
			ELTUKI_SIMUL = ELTUKI_DATA;
		%END;

		* Eläkkeensaajien asumistuki: data vs. simuloitu;
		%IF &ELASUMTUKI = 1 %THEN %DO;
		 	ELASUMTUKI_SIMUL = ELAKASUMTUKI;
		%END;
		%ELSE %DO; 
			ELASUMTUKI_SIMUL = ELASUMTUKI_DATA;
		%END;

		* Yleinen asumistuki: data vs. simuloitu;
		%IF &ASUMTUKI = 1 %THEN %DO;
			ASUMTUKI_SIMUL = TUKISUMMA;
		%END;
		%ELSE %DO;
			ASUMTUKI_SIMUL = ASUMTUKI_DATA;
		%END;

		* Harkinnanvaraiset menot (elatusmaksut ja lasten päivähoitomaksut): data vs. simuloitu;
		%IF &PHOITO = 1 %THEN %DO;
			HARKINMENOT_SIMUL = SUM(ELMAKSUT, SUM(PHMAKSU_KOK, PHMAKSU_OS), PHOITO_YKS);
		%END;
		%ELSE %DO;
			HARKINMENOT_SIMUL = HARKINMENOT_DATA;
		%END;

		* Työttömyysturva korotusosilla ja ilman veronalaisten ei-työtulojen nettomäärän laskentaa varten;
		%IF &TTURVA = 1 %THEN %DO;
			TYOTTURVA_SIMUL = SUM(YHTTMTUKI, PERUSPR,  ANSIOPR, VUORKORV);
			TYOTTURVA_ILMKOR_SIMUL = SUM(TMTUKILMKOR, PERILMAKOR, ANSIOILMKOR, VUORKORV);
		%END;
		%ELSE %DO;
			TYOTTURVA_SIMUL = TYOTTURVA_DATA;
			TYOTTURVA_ILMKOR_SIMUL = TYOTTURVA_ILMKOR_DATA;
		%END;

/* 4.1.2 Tehdään simulointia varten tarvittavat laskutoimitukset */

		* Lapsilisät kuukaudessa;
		LLISAT_KK = MAX(LLISAT_SIMUL / 12, 0);

		* Verojen suhteellinen osuus eri veronalaisista tuloista:
		arvioidaan suhteuttamalla ansiotuloista perityt verot ansiotulojen määrään;
		IF ANSIOT_SIMUL > 0 AND ANSIOVEROT_SIMUL > 0 THEN ANSIOVEROPROS = ANSIOVEROT_SIMUL / ANSIOT_SIMUL;
		ELSE ANSIOVEROPROS = 0;

		* Työtulojen nettomäärä kuukaudessa;
		TYOTULONETTO_KK = MAX(SUM((1-ANSIOVEROPROS) * VERTYOTULO, -PALKVAK_SIMUL, -PRAHAMAKSU_SIMUL, -THANKK, VEROTTYOTULO) / 12, 0);

		* Veronalaisten ei-työtulojen nettomäärä vuodessa;
		* Vuodesta 2013 lähtien työttömyysturvan korotusosat ovat toimeentulotuessa etuoikeutettua tuloa;
		* Elokuusta 2019 lähtien opintorahan oppimateriaalilisä on toimeentulotuessa etuoikeutettua tuloa;
		%IF &LVUOSI < 2013 %THEN %DO;
			MUUTVERTULOTNETTO = SUM(ANSIOT_SIMUL, POTULOT_SIMUL, -MAKSVEROT_SIMUL, -(1-ANSIOVEROPROS) * VERTYOTULO);
		%END;
		%ELSE %IF &LVUOSI < 2019 OR (%UPCASE(&TYYPPI) = SIMULX AND &LVUOSI = 2019 AND &LKUUK < 8) %THEN %DO;
			MUUTVERTULOTNETTO = SUM(ANSIOT_SIMUL, POTULOT_SIMUL, -MAKSVEROT_SIMUL, -(1-ANSIOVEROPROS) * VERTYOTULO,
									-(1-ANSIOVEROPROS) * TYOTTURVA_SIMUL, (1-ANSIOVEROPROS)  * TYOTTURVA_ILMKOR_SIMUL);
		%END;
		%ELSE %DO;
			MUUTVERTULOTNETTO = SUM(ANSIOT_SIMUL, POTULOT_SIMUL, -MAKSVEROT_SIMUL, -(1-ANSIOVEROPROS) * VERTYOTULO,
									-(1-ANSIOVEROPROS) * TYOTTURVA_SIMUL, (1-ANSIOVEROPROS) * TYOTTURVA_ILMKOR_SIMUL,
									-(1-ANSIOVEROPROS) * OPINRAHA_SIMUL, (1-ANSIOVEROPROS) * OPINRAHA_ILMOP_SIMUL);
		%END;

		* Verovapaiden ei-työtulojen nettomäärä vuodessa;
		VEROTTUL = SUM(VEROTTUL_MUU, ASUMLISA_SIMUL, OPINTOLAINA_SIMUL, ELLISAT_SIMUL, MAMUTUKI_SIMUL, ELTUKI_SIMUL, OSINGOT_VEROVAP_SIMUL, ELASUMTUKI_SIMUL, ASUMTUKI_SIMUL);

		* Ei-työtulojen nettomäärä kuukaudessa;
		MUUTTULOTNETTO_KK =  MAX(SUM(MUUTVERTULOTNETTO, VEROTTUL, -SEKALVERO, -KIVERO_SIMUL) / 12, 0);
		
		* Harkinnanvaraiset menot kuukaudessa;
		HARKINMENOT_KK = MAX(HARKINMENOT_SIMUL / 12, 0);

		* Tulonhankkimiskulut kuukaudessa;
		THANKK_KK = MAX(THANKK / 12, 0);

		KEEP hnro knro paasoss kuntakoodi jasenia
			EIAMSI ONAIK ONAIKLAPSI ONLAPSI17 ONLAPSI10_16 ONLAPSIALLE10
			LLISAT_KK TYOTULONETTO_KK MUUTTULOTNETTO_KK ASUMISKULUT_KK HARKINMENOT_KK
			THANKK_KK JARJ;

	RUN;


	*Lasketaan asumismenojen maksimi kelan normien mukaan;

	%IF &ASUMKUST_MAKS = 1 AND &lvuosi >= 2022 %THEN %DO;
	%AsumMenoRajat(&lvuosi, &lkuuk);

	data TEMP.TEMP_TOIMTUKI_HENKI; 
	set TEMP.TEMP_TOIMTUKI_HENKI;
	ASUMISKULUT_KK = min(ASUMNORMIT, ASUMISKULUT_KK);
	run;

	%END;

	*Summataan kotitaloustasolle;

	PROC SQL;
		CREATE TABLE TEMP.TEMP_TOIMTUKI_KOTI1
		AS SELECT knro, paasoss,
			SUM(EIAMSI) AS EIAMSIS,
			COUNT(hnro) AS KOTITALOUSKOKO,
			SUM(ONAIK) AS ONAIKS,
			SUM(ONAIKLAPSI) AS ONAIKLAPSIS,
			SUM(ONLAPSI17) AS ONLAPSI17S,
			SUM(ONLAPSI10_16) AS ONLAPSI10_16S,
			SUM(ONLAPSIALLE10) AS ONLAPSIALLE10S,
			SUM(LLISAT_KK) AS LLISAT_KKS,
			SUM(MUUTTULOTNETTO_KK) AS MUUTTULOTNETTO_KKS,
			SUM(ASUMISKULUT_KK) AS ASUMISKULUT_KKS,
			SUM(HARKINMENOT_KK) AS HARKINMENOT_KKS
		FROM TEMP.TEMP_TOIMTUKI_HENKI
		GROUP BY knro, paasoss;
	QUIT;

	%LET KOTITALOUSKOKO_MAX = 0;
	PROC SQL NOPRINT;
		SELECT MAX(KOTITALOUSKOKO) INTO :KOTITALOUSKOKO_MAX
		FROM TEMP.TEMP_TOIMTUKI_KOTI1;
	QUIT;
	%DO i=1 %TO &KOTITALOUSKOKO_MAX;
		PROC SQL;
			CREATE TABLE TEMP.TEMP_TOIMTUKI_KOTI%EVAL(1 + &i)
			AS SELECT a.*, b.TYOTULONETTO_KK AS TYOTULONETTO_KK_&i, b.THANKK_KK AS THANKK_KK_&i
			FROM TEMP.TEMP_TOIMTUKI_KOTI&i AS a
			LEFT JOIN TEMP.TEMP_TOIMTUKI_HENKI AS b ON (a.knro = b.knro AND b.JARJ = &i);
		QUIT;
	%END;
	DATA TEMP.TEMP_TOIMTUKI_KOTI;
		SET TEMP.TEMP_TOIMTUKI_KOTI%EVAL(1 + &KOTITALOUSKOKO_MAX);
	RUN;
	%LET TYOTULONETTO_KK_MAX = TYOTULONETTO_KK_%EVAL(&KOTITALOUSKOKO_MAX);
	%LET THANKK_KK_MAX = THANKK_KK_%EVAL(&KOTITALOUSKOKO_MAX);



	DATA TEMP.&TULOSNIMI_TO;
		SET TEMP.TEMP_TOIMTUKI_KOTI;

		*Toimeentulotuen määrän kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat.;
		KERROIN = EIAMSIS / KOTITALOUSKOKO;

		ARRAY TYOTULONETTO_KK_ARRAY{*} TYOTULONETTO_KK_1-&TYOTULONETTO_KK_MAX;
		ARRAY THANKK_KK_ARRAY{*} THANKK_KK_1-&THANKK_KK_MAX;

/* 4.1.3 Lasketaan toimeentulotuki kotitalouksittain */

		%ToimtukiVS(TOIMTUKIV, &LVUOSI, &INF, 1, 1, ONAIKS, ONAIKLAPSIS,
		ONLAPSI17S, ONLAPSI10_16S, ONLAPSIALLE10S, LLISAT_KKS, TYOTULONETTO_KK_ARRAY,
		MUUTTULOTNETTO_KKS, ASUMISKULUT_KKS, HARKINMENOT_KKS, THANKK_KK_ARRAY);

		TOIMTUKI = KERROIN * (12 * TOIMTUKIV);

		KEEP knro paasoss KERROIN ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI10_16S ONLAPSIALLE10S
			LLISAT_KKS TYOTULONETTO_KK_1-&TYOTULONETTO_KK_MAX MUUTTULOTNETTO_KKS
			ASUMISKULUT_KKS HARKINMENOT_KKS THANKK_KK_1-&THANKK_KK_MAX TOIMTUKI;
			
		LABEL	
			KERROIN = "Toimeentulotuen määrän kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat, DATA"
			ONAIKS = "Aikuisten lukumäärä kotitaloudessa, DATA"
			ONAIKLAPSIS = "18-vuotiaiden tai vanhempien lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSI17S = "17-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSI10_16S = "10-16-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSIALLE10S = "Alle 10-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			LLISAT_KKS = "Kotitalouden saama lapsilisä (e/kk)"
			MUUTTULOTNETTO_KKS = "Kotitalouden ei-työtulojen nettomäärä (e/kk)"
			ASUMISKULUT_KKS = "Kotitalouden asumiskulut (e/kk)"
			HARKINMENOT_KKS = "Kotitalouden harkinnanvaraiset menot (e/kk)"
			TOIMTUKI = "Kotitalouden saama toimeentulotuki (e/v), MALLI";

		%DO i=1 %TO &KOTITALOUSKOKO_MAX;
			LABEL
				TYOTULONETTO_KK_&i = "Henkilön saamien työtulojen nettomäärä (e/kk)"
				THANKK_KK_&i = "Henkilön tulonhankkimiskulut (e/kk), DATA";
		%END;

	RUN;

	* Siirretään simuloitu toimeentulotuki talouden viitehenkilölle (asko = 1) ;
	PROC SQL UNDO_POLICY=NONE;
		CREATE TABLE TEMP.&TULOSNIMI_TO
		AS SELECT a.hnro, a.knro, b.*
		FROM POHJADAT.&AINEISTO&AVUOSI AS a 
		INNER JOIN TEMP.&TULOSNIMI_TO(rename=(knro=knro_temp)) AS b ON a.knro = b.knro_temp AND a.asko = 1
		ORDER BY knro, hnro;
	QUIT;
	
	DATA TEMP.&TULOSNIMI_TO;
		SET TEMP.&TULOSNIMI_TO;

		* Poistetaan toimeentulotuki yrittäjiltä tarvittaessa ;
		%IF &YRIT = 0 %THEN %DO;
			IF paasoss < 30 THEN TOIMTUKI = 0;
		%END;

		* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan;
		ARRAY PISTE 
			TOIMTUKI;
		DO OVER PISTE;
			IF PISTE <= 0 THEN PISTE = .;
		END;

		LABEL	
			KERROIN = "Toimeentulotuen määrän kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat, DATA"
			ONAIKS = "Aikuisten lukumäärä kotitaloudessa, DATA"
			ONAIKLAPSIS = "18-vuotiaiden tai vanhempien lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSI17S = "17-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSI10_16S = "10-16-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			ONLAPSIALLE10S = "Alle 10-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
			LLISAT_KKS = "Kotitalouden saama lapsilisä (e/kk)"
			MUUTTULOTNETTO_KKS = "Kotitalouden ei-työtulojen nettomäärä (e/kk)"
			ASUMISKULUT_KKS = "Kotitalouden asumiskulut (e/kk)"
			HARKINMENOT_KKS = "Kotitalouden harkinnanvaraiset menot (e/kk)"
			TOIMTUKI = "Kotitalouden saama toimeentulotuki (e/v), MALLI";
			
		%DO i=1 %TO &KOTITALOUSKOKO_MAX;
			LABEL
				TYOTULONETTO_KK_&i = "Henkilön saamien työtulojen nettomäärä (e/kk)"
				THANKK_KK_&i = "Henkilön tulonhankkimiskulut (e/kk), DATA";
		%END;

	RUN;

/* 4.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

	%IF &START NE 1 %THEN %DO;

		/* Yhdistetään tulokset pohja-aineistoon */

		DATA TEMP.&TULOSNIMI_TO;
			
		/* 4.2.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

			%IF &TULOSLAAJ = 1 %THEN %DO; 
				MERGE POHJADAT.&AINEISTO&AVUOSI 
				(KEEP = hnro knro asko &PAINO htoimtuk ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
				TEMP.&TULOSNIMI_TO;
			%END;

		/* 4.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

			%IF &TULOSLAAJ = 2 %THEN %DO; 
				MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_TO;
			%END;

		/* Muokataan pohja-aineiston muuttujia */

			* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan;
			ARRAY PISTE 
				htoimtuk;
			DO OVER PISTE;
				IF PISTE <= 0 THEN PISTE = .;
			END;

			LABEL
			htoimtuk = "Kotitalouden saama toimeentulotuki (e/v), DATA";

			BY hnro;

		RUN;

		%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
			%SumKotitT(OUTPUT.&TULOSNIMI_TO._KOTI, TEMP.&TULOSNIMI_TO, &MALLI, &MUUTTUJAT);
		
			PROC DATASETS LIBRARY=TEMP NOLIST;
				DELETE &TULOSNIMI_TO;
			RUN;
			QUIT;
		%END;

		/* Jos käyttäjä määritellyt YKSIKKO=1 (henkilötaso) tai YKSIKKO on mitä tahansa muuta kuin 2 (kotitaloustaso)
		niin jätetään tulostaulu henkilötasolle ja nimetään se uudelleen */

		%ELSE %DO;
			PROC DATASETS LIBRARY=TEMP NOLIST;
				DELETE &TULOSNIMI_TO._HLO;
				CHANGE &TULOSNIMI_TO=&TULOSNIMI_TO._HLO;
				COPY OUT=OUTPUT MOVE;
				SELECT &TULOSNIMI_TO._HLO;
			RUN;
			QUIT;
		%END;

		/* Tyhjennetään TEMP-kirjasto */

		%IF &TEMPTYHJ = 1 %THEN %DO;
			PROC DATASETS LIBRARY=TEMP NOLIST KILL;
			RUN;
			QUIT;
		%END;

	%END;

%MEND ToimTuki_Simuloi_Data;

%ToimTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());

/* 5. Tulostetaan käyttäjän pyytämät taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_TO._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_TO._KOTI,2);
	%END;

	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND KutsuTulokset;
%KutsuTulokset;

/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());
%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);
%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);
%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));
%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));
%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;
%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;