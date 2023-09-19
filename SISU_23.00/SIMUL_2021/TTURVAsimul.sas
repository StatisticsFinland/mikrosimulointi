/************************************************************
* Kuvaus: Työttömyysturvan simulointimalli 					*
************************************************************/ 

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = TTURVA;

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

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;        * Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

	%LET TULOSNIMI_TT = tturva_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

	%LET TTDATATULO = 0;	* Käytetäänkö datan tulotietoja = 1 vai laskennallisia tulotietoja = 0;

	%LET APKESTOSIMUL = 0;	* Leikataanko ansiopäivärahan kestoa käytettävän lainsäädännön mukaan = 1 vai eikö = 0.
							  Leikatut päivät siirretään työmarkkinatukeen;

	%LET VKKESTOSIMUL = 0;	* Leikataanko vuorottelukorvauksen kestoa käytettävän lainsäädännön mukaan = 1 vai eikö = 0.
							  Leikattuja päiviä ei siirretä muihin etuuksiin;

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

	%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakrotiedoston nimi;
	%LET PTTURVA = ptturva; * Käytettävän parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = TMTUKIDAT YHTTMTUKI YPITOKDAT YPITOK PERPRDAT PERUSPR VVVMKQ ANSIOPR 
			         vvvmk3 VUORKORV VVVPVTQ VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilöluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilöluokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
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

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";

%MEND Aloitus;

%Aloitus;


%MACRO TTURVA_Varoitukset;

	%IF &APKESTOSIMUL = 1 OR &VKKESTOSIMUL = 1 %THEN %DO;

		%PUT WARNING: TTURVA-mallissa on keston mallinnus päällä. Suhtauduthan saataviin tuloksiin varovaisesti, %CMPRES(
						) sillä keston mallinnuksessa on havaittu epäselvyyksiä.;

	%END;

%MEND TTURVA_Varoitukset;

%TTURVA_Varoitukset;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO TTurva_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	DATA STARTDAT.START_TTURVA;
	SET POHJADAT.&AINEISTO&AVUOSI (
	KEEP = ykor hnro knro asko ikavu ikakk mkorpvt1
	vvvmk3 vvvpvt3 vvvsopv3 vvvllkm3
	vvvmk5 mkorpvt5
	tmtukimk tmtukipv htyotper palkm ttyotpr dtvpv dttayspv dtospv dtovlkm dtopalkk 
	dttspv dtomapal dtpspv dtpspalk dtyllae dtyllapv dttllkm dtthpv dttspalk 
	dtyhtep dtyllapvp koropvtkg
	koropvpkw korosatkg korosapkw spalkka3 ikavu tklaskr:
	vvvpvt3_ed tyokk_hist lasktyohist ypkotipvt ypkorpvt ypkotimk tyopv:
	
	LAPSKORMAKS DTOMAPALX2 DTOPALKKX2 SOSETUVAH SOVPELK SOVOS
	SOVTARV SOVVAH SOVKOR SOVPALKKATM SOVPALKKAPR SOVKORPA
	PELKTAYSPV3
	SOVKORPV1 SOVKORPV5 TAYSKORPV1
	TAYSKORPV5 LASKPALKKA3
	SOVKORVAH KORVAH PELKVAH PELKKOR SOVPELKP PELKKORP TAYSPVP
	VUORKOR YPITOKORPV PUOLPALK

	VVVPALX3

	VVVPVTQ VVVSOPVQ MKORPVTQ MLISPVTQ VVVMKQ VVVSOMKQ VVVPALQ VVVLLKMQ 
	TAYSKORPVQ SOVKORPVQ PELKTAYSPVQ PELKSOPVQ
	SOVPALKKAQ LASKPALKKAQ AILMKORQDAT

	SOVKERTYMA MUUKERTYMA NETTOPV_AVUOSI SOVSUHDEAP_AVUOSI SOVSUHDETM_AVUOSI APENIMKTAYT
 
	WHERE = (vvvmk5 > 0 OR ttyotpr > 0));

	TMKORPV = koropvtkg;

	TMTUKIDAT = SUM(tmtukimk, korosatkg);
	PERPRDAT = SUM(dtyhtep, korosapkw);

	*Työhistoria-muuttuja ansiopäivärahan enimmäiskeston lyhennystä varten;
	TYOHISTV = ROUND(tyokk_hist/12,0.1);

	*Laskennallinen työhistoriamuuttuja ansiopäivärahan lisäpäiväoikeutta varten;
	LASKTYOHISTV = ROUND(lasktyohist/12,0.1);

	*Henkilön työhistoria koko elämän ajalta ennen vuotta 2017 laskettavia korotusosia varten:
	Koska tyokk_hist-muuttujassa on tietoa vain vuodesta 1997 eteenpäin, korjataan sitä
	lisäämällä kaikille 10 vuotta;
	KOKOTYOHISTV = SUM(ROUND(tyokk_hist/12,0.1), 10);

	TAYSTARV = SUM(dtthpv, -SOVTARV);
	TAYSOS = SUM(dtospv, -SOVOS);

	*Jos työmarkkinatuen taustatiedot ovat tyhjät, täydennetään niitä
	ansiopäivärahan vastaavilla tiedoilla;
	IF VVVPVTQ > 0 THEN DO; 
		IF dttllkm = . THEN dttllkm = VVVLLKMQ;
		IF SOVPALKKATM= . THEN SOVPALKKATM = SOVPALKKAQ;
	END;

	ARRAY PISTE 
	tmtukimk dtyllae htyotper vvvmk3 VVVMKQ VVVPVTQ;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	DROP 
	korosatkg
	vvvmk5 ttyotpr tyokk_hist
	;

	LABEL
	VVVPALQ = 'Ansiopäivärahan perusteena oleva vakuutuspalkka, DATA'
	VVVPALX3 = 'Vuorottelukorvauksen perusteena oleva vakuutuspalkka, DATA'
	dtthpv = 'Työmarkkinatuen tarveharkittujen päivien lkm, DATA'
	dttayspv = 'Työmarkkinatuen täysien päivien lkm, DATA'
	dtospv = 'Työmarkkinatuen ositettujen päivien lkm, DATA'
	dttspv = 'Työmarkkinatuen soviteltujen päivien lkm, DATA'
	dtvpv = 'Työmarkkinatuen muulla sosiaalietuudella vähennettyjen päivien lkm, DATA'
	tmtukipv = 'Työmarkkinatuen päivien lkm, DATA'
	dtyllae = 'Työmarkkinatuen kulukorvaukset, DATA'
	dtyllapv = 'Työmarkkinatuen kulukorvauspäivät, DATA'
	dttllkm = 'Työmarkkinatuen lapsikorotukset, DATA'
	dtovlkm = 'Ositetun työmarkkinatuen huollettavien lkm, DATA'
	PUOLPALK = 'Puolison tulot tarveharkitussa tm-tuessa, DATA'
	dtomapal = 'Omat (pääoma)tulot tarveharkitussa tm-tuessa, DATA'
	dttspalk = 'Omat työtulot sovitellussa tm-tuessa, DATA'
	dtopalkk = 'Vanhehmpien työtulot ositetussa tm-tuessa, DATA'
	TMTUKIDAT = 'Työmarkkinatuki, DATA'
	PERPRDAT = 'Peruspäiväraha, DATA'
	SOVKERTYMA = 'Aineistovuoden sovitellut ansiopäivärahapäivät kertymässä, DATA'
	MUUKERTYMA = 'Muut kuin aineistovuoden sovitellut päivät kertymässä, DATA'
	NETTOPV_AVUOSI = 'Ansiopäivärahapäivät nettona, DATA'
	SOVSUHDEAP_AVUOSI = 'Soviteltu tuki suhteessa täyteen tukeen AP, DATA'
	SOVSUHDETM_AVUOSI = 'Soviteltu tuki suhteessa täyteen tukeen TM, DATA'
	TYOHISTV = 'Työhistoria vuosina ansiopäivärahan enimmäiskestoa varten, DATA'
	KOKOTYOHISTV = 'Työhistoria vuosina, DATA'
	;

RUN;

%END;

%MEND TTurva_Muut_Poiminta;

%TTurva_Muut_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe */

%MACRO TTurva_Simuloi_Data;
/* TTURVA-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */
%KuukSimul(TTURVA);

DATA TEMP.&TULOSNIMI_TT;
SET STARTDAT.START_TTURVA;

IF VVVPVTQ > 0 THEN DO;

/* 3.1.1. Päivien uudelleenjako ansiosidonnaisen päivärahan enimmäiskeston perusteella */

	IF &TTDATATULO = 0 THEN PALKKA = LASKPALKKAQ; 
	ELSE PALKKA = VVVPALQ;

	*Muodostetaan täyden tuen määrä, jota käytetään apuna monessa kohtaa simulointia;
	%AnsioSidVS(TAYSANSPR, &LVUOSI, &INF, VVVLLKMQ, 0, 0, 0, PALKKA, 0);

	*Keston simulointi alkaa;
	IF &APKESTOSIMUL=1 THEN DO;

		*Simuloidaan ansiopäivärahojen kuukausimäärät, joita käytetään mm. nettopäivien määrittämiseen;
		IF VVVSOPVQ > 0 THEN DO;
			%SoviteltuVS(TEMP_SOVAP, &LVUOSI, &INF, 1, 0, VVVLLKMQ, TAYSANSPR, SOVPALKKAQ, PALKKA, 0);
			SOVSUHDEAP_LVUOSI= ROUND(TEMP_SOVAP / TAYSANSPR, 0.01);
		END;
		ANSIOPV_NETTO = SUM(MUUKERTYMA, ROUND(SOVSUHDEAP_LVUOSI * SOVKERTYMA));
		

		*Simuloidaan tm-tuen kuukausimäärät nettopäivien määrittämiseen;
		IF dttspv > 0 THEN DO;
			%TyomTukiVS(TEMP_TAYSTM, &LVUOSI, &INF, 0, 0, 0, dttllkm, 0, 0, 0, 0, 0, 0);
			%SoviteltuVS(TEMP_SOVTM, &LVUOSI, &INF, 0, 0, dttllkm, TEMP_TAYSTM, SOVPALKKATM, 0, 0);
			SOVSUHDETM_LVUOSI= ROUND(TEMP_SOVTM / TEMP_TAYSTM, 0.01);
			DROP TEMP_SOVTM TEMP_TAYSTM;
		END;
		TMPAIVAT_NETTO = SUM(tmtukipv, -dttspv, ROUND(SOVSUHDETM_LVUOSI * dttspv));
	
		*Alustetaan enimmäiskeston täyttymiskuukauden muuttuja;
		IF APENIMKTAYT = 1 THEN TAYTKK = 99; /*Enimmäiskesto täyttynyt aineistovuonna*/
		IF APENIMKTAYT = 2 THEN TAYTKK = -99; /*Enimmäiskesto täyttynyt edellisenä vuonna*/

		*Lasketaan enimmäiskeston täyttymiskuukausi niille joiden ikä sattuu osumaan lisäpäivärajaan. 
		V.2017 sama muuttuja kertoo vaihtoehtoisesti alemman, ns. kestoikärajan täyttymiskuukauden. Oletus on että nämä ikärajat eivät ole samat.
		HUOM. ei taida toimia tilanteessa jossa enimmäiskestoa pitkitetään nykyisestä;
		IF TAYTKK NE -99 AND (ikavu >= &LisaPvAlaIka OR ikavu = &KestoIkaRaja) THEN DO;
			TEMPKESTO = &AnsioSidKesto;
			IF &LVUOSI >=2017 AND ikavu >= &LisaPvAlaIka THEN TEMPKESTO = &AnsioSidKesto3;

			IF tklaskr4_ed >= TEMPKESTO THEN TAYTKK = 0;
			ELSE IF tklaskr1 >= TEMPKESTO THEN TAYTKK = CEIL(3 - (SUM(tklaskr1, -TEMPKESTO) / &TTPaivia));
			ELSE IF tklaskr2 >= TEMPKESTO THEN TAYTKK = MIN( 6, FLOOR( SUM( TEMPKESTO, -tklaskr1) / &TTPaivia) + 4);
			ELSE IF tklaskr3 >= TEMPKESTO THEN TAYTKK = MIN( 9, FLOOR( SUM( TEMPKESTO, -tklaskr2) / &TTPaivia) + 7);
			ELSE IF tklaskr4 >= TEMPKESTO THEN TAYTKK = MIN(12, FLOOR( SUM( TEMPKESTO, -tklaskr3) / &TTPaivia) + 10);
		END;


		*Lasketaan työssäoloehto ensimmäisen ikärajan ylittäneille olettaen että aineistovuonna ei ole kertynyt lisää työviikkoja;
		IF &LVUOSI >=2017 AND ikavu >= &KestoIkaRaja THEN DO;
			IF ikavu = &KestoIkaRaja THEN TYOOLOVKO= ROUND( SUM( tyopv_ed, MIN(12, &TyoEhtoTarkJKK-12-(12-ikakk)) /12 * tyopv_ed2, MAX(0, (&TyoEhtoTarkJKK-24-(12-ikakk))/12 *tyopv_ed3)) / 7);
	
			*59-vuotiaille työssäoloehto lasketaan niin kaukaa kun on dataa. Lasketaan kolme vuoden ajalta, koska oletetaan että viimeisen vuoden mahdolliset työjaksot keskittyy alkuvuoteen;
			ELSE IF ikavu = &KestoIkaRaja +1 THEN TYOOLOVKO = ROUND( SUM( (&TyoEhtoTarkJKK-12-(12-ikakk))/12 *tyopv_ed3, tyopv_ed2, tyopv_ed) / 7);

			*Yli 59-vuotiaille data riittää huonosti, joten heistä kaikkien oletetaan täyttäneen työssäoloehdon yli 58 vuotiaana;
			ELSE TYOOLOVKO = 99;
			TYOOLOEHTO= (TYOOLOVKO >= &TyoEhtoVko);
		END;
		DROP TEMPKESTO TYOOLOVKO;


		*Lasketaan mahdolliset siirtyvät päivät;
		%AnsioSidKestoRaj(SIIRTPV, &LVUOSI, 1, ANSIOPV_NETTO, TYOHISTV, LASKTYOHISTV, TAYTKK, ikavu, ikakk, TMPAIVAT_NETTO, TYOOLOEHTO, 0);

		*Skaalataan ne aineistovuoden päiviin;
		SIIRTPV = MIN(NETTOPV_AVUOSI, SIIRTPV);

		*Jyvitetään siirtyvät ansiopäivärahat työmarkkinatukeen lajeittain vastaten samoja suhteita kuin ansiopäivärahassa; 
		IF SIIRTPV >0 THEN DO;

			*Päivien siirto työmarkkinatukeen;
			dttayspv = SUM(dttayspv, ROUND( SUM(PELKTAYSPVQ, tayskorpv1) / NETTOPV_AVUOSI * SIIRTPV));
			PELKKOR = SUM( PELKKOR, ROUND( tayskorpv5 / NETTOPV_AVUOSI * SIIRTPV));
	
			*Vähennys ansiopäivärahoista;
			ARRAY TAYDET PELKTAYSPVQ TAYSKORPV1 TAYSKORPV5;
			DO OVER TAYDET;
				TAYDET = ROUND( SUM( TAYDET, -(TAYDET / NETTOPV_AVUOSI) * SIIRTPV));
			END;

			*Soviteltujen päivien siirto;
			IF SOVSUHDEAP_LVUOSI > 0 AND  ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) > 0 THEN DO;

				*Painotettu keskiarvo työtuloista;
				dttspalk = SUM(dttspv * dttspalk, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) * SOVPALKKAQ) / SUM(dttspv, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV));
				SOVPALKKATM = SUM(dttspv * SOVPALKKATM, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) * SOVPALKKAQ) / SUM(dttspv, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV));

				*Soviteltujen päivien suhteutuksessa täytyy ottaa huomioon aineistovuoden ja lainsäädäntövuoden sovittelusuhde.;
				SOVPELK = ROUND( SUM( SOVPELK, SOVSUHDEAP_AVUOSI * SUM(PELKSOPVQ, sovkorpv1) / NETTOPV_AVUOSI * SIIRTPV / SOVSUHDEAP_LVUOSI));
				SOVKOR = ROUND( SUM( SOVKOR, SOVSUHDEAP_AVUOSI * sovkorpv5 / NETTOPV_AVUOSI * SIIRTPV  / SOVSUHDEAP_LVUOSI));
	
				*Vähennys sov. ansiopäivärahoista;
				ARRAY SOVITELLUT sovkorpv5 PELKSOPVQ sovkorpv1;
				DO OVER SOVITELLUT;
					SOVITELLUT = ROUND( SUM( SOVITELLUT, -( SOVSUHDEAP_AVUOSI * SOVITELLUT / NETTOPV_AVUOSI) * SIIRTPV / SOVSUHDEAP_LVUOSI));
				END;


			END;

		END;
		IF SIIRTPV < 0 THEN DO;
	
			PELKTAYSPVQ = SUM( PELKTAYSPVQ, ROUND( SUM(dttayspv, PELKVAH, TAYSTARV, TAYSOS) / TMPAIVAT_NETTO * -SIIRTPV));
			TAYSKORPV5 = SUM( TAYSKORPV5, ROUND( SUM(PELKKOR, KORVAH) / TMPAIVAT_NETTO * -SIIRTPV));

			*Vähennys ansiopäivärahoista;
			ARRAY TAYDET_TM dttayspv PELKKOR PELKVAH KORVAH TAYSTARV TAYSOS;
			DO OVER TAYDET_TM;
				TAYDET_TM = ROUND( SUM( TAYDET_TM, (TAYDET_TM / TMPAIVAT_NETTO) * SIIRTPV));
			END;

			IF SOVSUHDETM_LVUOSI > 0 AND ROUND( dttspv/tmtukipv * (-SIIRTPV)) > 0 THEN DO;

				*Painotettu keskiarvo työtuloista;
				SOVPALKKAQ = SUM(ROUND( dttspv/tmtukipv * (-SIIRTPV)) * SOVPALKKATM, VVVSOPVQ * SOVPALKKAQ) / SUM(ROUND( dttspv/tmtukipv * (-SIIRTPV)), VVVSOPVQ);


				*Soviteltujen päivien suhteutuksessa täytyy ottaa huomioon aineistovuoden ja lainsäädäntövuoden sovittelusuhde.;
				PELKSOPVQ = ROUND( SUM( PELKSOPVQ, SOVSUHDETM_AVUOSI * SUM(SOVPELK, SOVVAH, SOVTARV, SOVOS) / TMPAIVAT_NETTO * -SIIRTPV / SOVSUHDETM_LVUOSI));
				SOVKORPV5 = ROUND( SUM( SOVKORPV5, SOVSUHDETM_AVUOSI * SUM(SOVKOR, SOVKORVAH) / TMPAIVAT_NETTO * -SIIRTPV  / SOVSUHDETM_LVUOSI));
		
				*Vähennys sov. ansiopäivärahoista;
				ARRAY SOVITELLUT_TM SOVPELK SOVVAH SOVTARV SOVOS SOVKOR SOVKORVAH;
				DO OVER SOVITELLUT_TM;
					SOVITELLUT_TM = ROUND( SUM( SOVITELLUT_TM, ( SOVSUHDETM_AVUOSI * SOVITELLUT_TM / TMPAIVAT_NETTO) * SIIRTPV / SOVSUHDETM_LVUOSI));
				END;
			END;
		END;
		
		*DROP TEMP_SOVAP TEMP_TAYSTM TEMP_SOVTM APENIMKTAYT TAYTKK SOVSUHDEAP_LVUOSI SOVSUHDETM_LVUOSI SOVSUHDEAP_AVUOSI SOVSUHDETM_AVUOSI tklaskr1-tklaskr4 TMPAIVAT_NETTO ANSIOPV_NETTO;
	END;

	VVVPVTQ_SIMUL = SUM(PELKTAYSPVQ, PELKSOPVQ, TAYSKORPV5, SOVKORPV5, TAYSKORPV1, SOVKORPV1);

/* 3.1.2. Ansiopäivärahan simulointi */

	 * Lasketaan ei-korotetut päivärahat;
	IF PELKTAYSPVQ > 0 THEN TAYSAPR = PELKTAYSPVQ * TAYSANSPR / &TTPaivia;
		
	IF PELKSOPVQ > 0 THEN DO;
		%SoviteltuVS(SOVANSPR, &LVUOSI, &INF, 1, 0, VVVLLKMQ, TAYSANSPR, SOVPALKKAQ, PALKKA, 0);
		SOVAPR = PELKSOPVQ * SOVANSPR / &TTPaivia;
	END;
	
	* Lasketaan korotetut päivärahat ;
	IF SOVKORPV1 OR TAYSKORPV1 THEN DO;
		%AnsioSidVS(TAYSKORPR1, &LVUOSI, &INF, VVVLLKMQ, (&LVUOSI < 2017 AND KOKOTYOHISTV > &KorEhtoV), 0, 0, PALKKA, 0);

		IF SOVKORPV1 > 0 THEN DO;
			%SoviteltuVS(SOVKORPR1, &LVUOSI, &INF, 1, (&LVUOSI < 2017 AND KOKOTYOHISTV > &KorEhtoV), VVVLLKMQ, TAYSKORPR1, SOVPALKKAQ, PALKKA, 0);
			SOVKORPR1 = SOVKORPV1 * SOVKORPR1 / &TTPaivia;
		END;

		TAYSKORPR1 = TAYSKORPV1 * TAYSKORPR1 / &TTPaivia;
	END;


	* Lasketaan korotetut päivärahat ;
	IF SOVKORPV5 OR TAYSKORPV5 > 0 THEN DO;
		%AnsioSidVS(TAYSKORPR5, &LVUOSI, &INF, VVVLLKMQ, 1, 0, 0, PALKKA, 0);


		IF SOVKORPV5 > 0 THEN DO;
			%SoviteltuVS(SOVKORPR5, &LVUOSI, &INF, 1, 1, VVVLLKMQ, TAYSKORPR5,  SOVPALKKAQ, PALKKA, 1);

			SOVKORPR5 = SOVKORPV5 * SOVKORPR5 / &TTPaivia;
		END;

		TAYSKORPR5 = TAYSKORPV5 * TAYSKORPR5 / &TTPaivia;
	END;


	ANSIOPR = SUM(TAYSAPR, SOVAPR, SOVKORPR1, SOVKORPR5, TAYSKORPR1, TAYSKORPR5);
	ANSIOILMKOR = SUM(TAYSAPR, SOVAPR, SOVKORPR1, SOVKORPV5 * SOVANSPR / &TTPaivia, TAYSKORPR1, TAYSKORPV5 * TAYSANSPR / &TTPaivia);

	DROP SOVAPR TAYSAPR SOVKORPR5 TAYSKORPR5 SOVKORPR1 TAYSKORPR1;
END;

/* 3.1.3. Työmarkkinatuen simulointi */
TMTUKIPV_SIMUL = SUM(PELKKOR, KORVAH, SOVKOR, SOVKORVAH, TAYSTARV, TAYSOS, SOVTARV, SOVOS, SOVPELK, SOVVAH, PELKVAH, dttayspv);

IF TMTUKIPV_SIMUL > 0 THEN DO;

	* Tarveharkitut työmarkkinatuet ;
	IF TAYSTARV OR SOVTARV THEN DO;

		IF &TTDATATULO NE 0 THEN DO;
			%TyomTukiVS(THTMTUKI, &LVUOSI, &INF, 1, 0, PUOLPALK, dttllkm, 0, dtomapal, PUOLPALK, 0, 0, 0);
			IF SOVTARV > 0 THEN DO; %SoviteltuVS(SOVTARVTUKI, &LVUOSI, &INF, 0, 0, dttllkm, THTMTUKI, dttspalk, 0, 0); END;
		END;
	
		ELSE DO;
			%TyomTukiVS(THTMTUKI, &LVUOSI, &INF, 1, 0, PUOLPALK, dttllkm, 0, DTOMAPALX2, PUOLPALK, 0, 0, 0);
			IF SOVTARV > 0 THEN DO; %SoviteltuVS(SOVTARVTUKI, &LVUOSI, &INF, 0, 0, dttllkm, THTMTUKI, SOVPALKKATM, 0, 0); END;
		END;
	
		THTMTUKI = SUM(TAYSTARV * THTMTUKI, SOVTARV * SOVTARVTUKI) / &TTPaivia;
		DROP SOVTARVTUKI;
	END;

	* Osittaiset työmarkkinatuet ;
	IF TAYSOS OR SOVOS THEN DO;
	
		IF &TTDATATULO NE 0 THEN DO;
			%TyomTukiVS(OSTMTUKI, &LVUOSI, &INF, 0, 1, 0, dttllkm, dtovlkm, 0, 0, dtopalkk, 0, 0);
			IF SOVOS > 0 THEN DO; %SoviteltuVS(SOVOSTUKI, &LVUOSI, &INF, 0, 0, dttllkm, OSTMTUKI, dttspalk, 0, 0); END;
		END;
	
		ELSE DO;
			%TyomTukiVS(OSTMTUKI, &LVUOSI, &INF, 0, 1, 0, dttllkm, dtovlkm, 0, 0, DTOPALKKX2, 0, 0);
			IF SOVOS > 0 THEN DO; %SoviteltuVS(SOVOSTUKI, &LVUOSI, &INF, 0, 0, dttllkm, OSTMTUKI, SOVPALKKATM, 0, 0); END;
		END;
	
		OSTMTUKI = SUM(TAYSOS * OSTMTUKI, SOVOS * SOVOSTUKI) / &TTPaivia;
		DROP SOVOSTUKI;
	END;

	* Korotetut työmarkkinatuet;
	IF PELKKOR OR KORVAH OR SOVKOR OR SOVKORVAH THEN DO;
		IF PELKKOR > 0 OR SOVKOR > 0 THEN DO;
			%TyomTukiVS(KRTMTUKI, &LVUOSI, &INF, 0, 0, 0, dttllkm, 0, 0, 0, 0, 1, 0);
		END;
		IF KORVAH > 0 OR SOVKORVAH > 0 THEN DO;
			%TyomTukiVS(KRSTMTUKI, &LVUOSI, &INF, 0, 0, 0, dttllkm, 0, 0, 0, 0, 1, SOSETUVAH);
			IF KRSTMTUKI > &KorotusOsa * &TTPaivia THEN KRSTILMKOR = KRSTMTUKI - &KorotusOsa * &TTPaivia;
		END;
		IF SOVKOR > 0 OR SOVKORVAH > 0 THEN DO; 
			IF &TTDATATULO NE 0 OR SOVKORVAH > 0 THEN DO;
				IF SOVKORVAH > 0 THEN DO;
					%SoviteltuVS(SOVKORVTUKI, &LVUOSI, &INF, 0, 0, dttllkm, KRSTMTUKI, dttspalk, 0, 0); 
					IF SOVKORVTUKI > &KorotusOsa * &TTPaivia THEN SOVKVILMKOR = SOVKORVTUKI - &KorotusOsa * &TTPaivia;
				END;
					ELSE DO;
					%SoviteltuVS(SOVKORTUKI, &LVUOSI, &INF, 0, 0, dttllkm, KRTMTUKI, dttspalk, 0, 0);
				END;
			END;
			ELSE DO;
				%SoviteltuVS(SOVKORTUKI, &LVUOSI, &INF, 0, 0, dttllkm, KRTMTUKI, SOVPALKKATM, 0, 0); 
			END;
			IF SOVKORTUKI > &KorotusOsa * &TTPaivia THEN SOVKILMKOR = SOVKORTUKI - &KorotusOsa * &TTPaivia;
		END;
	
		KORTMTUKI = SUM(PELKKOR * KRTMTUKI, SOVKOR * SOVKORTUKI, KORVAH * KRSTMTUKI, SOVKORVAH * SOVKORVTUKI) / &TTPaivia;
		TMILMKOR = SUM(PELKKOR * SUM(KRTMTUKI, -&KorotusOsa * &TTPaivia), KORVAH * KRSTILMKOR, SOVKORVAH * SOVKVILMKOR, SOVKOR * SOVKILMKOR) / &TTPaivia;
		DROP KRTMTUKI SOVKORVTUKI SOVKORTUKI SOVKILMKOR SOVKVILMKOR KRSTILMKOR;
	END;

	* Sovitellut täydet tmtuet ;
	IF SOVPELK > 0 THEN DO;

		IF &TTDATATULO NE 0 THEN DO;
			%TyomTukiVS(TAYSPRAHA, &LVUOSI, &INF, ikavu < &TarvHarkIka AND NOT MAX(HTYOTPER,VVVMKQ), 0, PUOLPALK, dttllkm, 0, 0, PUOLPALK, 0, 0, 0);
			%SoviteltuVS(SOVTMTUKI, &LVUOSI, &INF, 0, 0, dttllkm, TAYSPRAHA, dttspalk, 0, 0);
		END;
	
		ELSE DO;
			%TyomTukiVS(TAYSPRAHA, &LVUOSI, &INF, ikavu < &TarvHarkIka AND NOT MAX(HTYOTPER,VVVMKQ), 0, PUOLPALK, dttllkm, 0, 0, PUOLPALK, 0, 0, 0);
			%SoviteltuVS(SOVTMTUKI, &LVUOSI, &INF, 0, 0, dttllkm, TAYSPRAHA, SOVPALKKATM, 0, 0);
		END;
	
		SOVTMTUKI = SOVPELK * SOVTMTUKI / &TTPaivia;
		DROP TAYSPRAHA;
	
	END;

	* Täydet tmtuet ;
	IF dttayspv > 0 THEN DO;
		%TyomTukiVS(TAYSTMTUKI, &LVUOSI, &INF, ikavu < &TarvHarkIka AND NOT MAX(HTYOTPER,VVVMKQ), 0, PUOLPALK, dttllkm, 0, 0, PUOLPALK, 0, 0, 0);
		TAYSTMTUKI = dttayspv * TAYSTMTUKI / &TTPaivia;
	END;
	
	* Tuet joista on vähennetty muuta sosiaalietuutta ;
	IF PELKVAH > 0 OR SOVVAH > 0 THEN DO; 
		%TyomTukiVS(VAHTMTUKI, &LVUOSI, &INF, 0, 0, 0, dttllkm, 0, 0, 0, 0, 0, SOSETUVAH); 
	
		IF SOVVAH > 0 THEN DO;
			%SoviteltuVS(SVAHTMTUKI, &LVUOSI, &INF, 0, 0, dttllkm, VAHTMTUKI, dttspalk, 0, 0);
		END;

		VAHTMTUKI = SUM(VAHTMTUKI * PELKVAH, SVAHTMTUKI * SOVVAH) / &TTPaivia;
		DROP SVAHTMTUKI;
	END;
	
	YHTTMTUKI = SUM(THTMTUKI, OSTMTUKI, SOVTMTUKI, TAYSTMTUKI, VAHTMTUKI, KORTMTUKI);
	TMTUKILMKOR = SUM(THTMTUKI, OSTMTUKI, SOVTMTUKI, TAYSTMTUKI, VAHTMTUKI, TMILMKOR);
	
END;


/* 3.1.4. Peruspäiväraha */

IF palkm > 0 THEN DO;
	%PerusPRahaVS(PERUSPR, &LVUOSI, &INF, 0, 0, 0, LAPSKORMAKS, 0, 0, 0);
	IF koropvpkw > 0 THEN DO;
		%PerusPRahaVS(PERKORPRA, &LVUOSI, &INF, 0, 1, 0, LAPSKORMAKS, 0, 0, 0);
	END;

	IF dtpspv > 0 THEN DO;
		IF &TTDATATULO NE 0 THEN DO; 
			IF SOVPELKP > 0 THEN DO; %SoviteltuVS(SOVPERUSPR, &LVUOSI, &INF, 0, 0, LAPSKORMAKS, PERUSPR, dtpspalk, 0, 0); END;
			IF SOVKORPA > 0 THEN DO; %SoviteltuVS(SOVKPERUSPRA, &LVUOSI, &INF, 0, 0, LAPSKORMAKS, PERKORPRA, dtpspalk, 0, 0); END;
		END;

		ELSE DO;
			IF SOVPELKP > 0 THEN DO; %SoviteltuVS(SOVPERUSPR, &LVUOSI, &INF, 0, 0, LAPSKORMAKS, PERUSPR, SOVPALKKAPR, 0, 0); END;
			IF SOVKORPA > 0 THEN DO; %SoviteltuVS(SOVKPERUSPRA, &LVUOSI, &INF, 0, 0, LAPSKORMAKS, PERKORPRA, SOVPALKKAPR, 0, 0); END;
		END;
		*Sovitellaan ensi perusosa. Jos jää soviteltavaa niin sitten vasta korotusosa;
		IF 0 < SOVKPERUSPRA < &KorotusOsa * &TTPaivia THEN PERILMAKOR = SOVKPERUSPRA; 
		ELSE IF SOVKORPA > 0 THEN PERILMAKOR = SOVKPERUSPRA - &KorotusOsa * &TTPaivia;
	END;
	PERUSPR = SUM(TAYSPVP * PERUSPR, SUM(koropvpkw, -SOVKORPA) * PERKORPRA, SOVPELKP * SOVPERUSPR, SOVKORPA * SOVKPERUSPRA) / &TTPaivia;
	PERILMAKOR = SUM(PERUSPR, -SUM(koropvpkw, -SOVKORPA) * &KorotusOsa, (-PERILMAKOR / &TTPaivia) * SOVKORPA);

END;

/* 3.1.5. Kulukorvaukset */

IF dtyllapv > 0 OR dtyllapvp > 0 OR ypkotipvt > 0 THEN DO;
	IF YPITOKORPV > 0 THEN DO;
		%YPitoKorvS(YPITOKOR, &LVUOSI, 1, &INF, 1);
	END;
	IF SUM(dtyllapv, dtyllapvp, ypkotipvt) > YPITOKORPV THEN DO;
		%YPitoKorvS(YPITOK, &LVUOSI, 1, &INF, 0);
	END;
	YPITOK = SUM(YPITOK * SUM(dtyllapv, dtyllapvp, ypkotipvt, -YPITOKORPV), YPITOKOR * YPITOKORPV) / &TTPaivia;
END;


/* 3.1.6. Ansiosidonnaiset vuorottelukorvaukset */

IF vvvpvt3 > 0 THEN DO;
	IF &TTDATATULO = 0 THEN PALKKA3 = LASKPALKKA3; 
	ELSE PALKKA3 = VVVPALX3;
	%VuorVapKorvVS(VKORV, &LVUOSI, &INF, 0, VUORKOR, PALKKA3);
	* Soviteltu vuorottelukorvaus;
	IF vvvsopv3 > 0 THEN DO;
	%VuorVapKorvVS(SOVVKORV, &LVUOSI, &INF, 0, VUORKOR, PALKKA3, spalkka=spalkka3);
	END;
	* Jos on valittu vuorottelukorvauksen keston simulointi, leikataan päiviä lainsäädännön mukaan;
	IF &VKKESTOSIMUL=1 THEN DO;
		%AnsioSidKestoRaj(VSIIRTPV, &LVUOSI, 1, SUM(vvvpvt3, vvvpvt3_ed), TYOHISTV, LASKTYOHISTV, 0, 0, 0, 0, 0, 1);
	END;
	ELSE DO;
		VSIIRTPV = 0;
	END;

	VUORKORV = (SUM(vvvpvt3,-VSIIRTPV)/ vvvpvt3) * SUM(PELKTAYSPV3 * VKORV, vvvsopv3 * SOVVKORV) / &TTPaivia;
	DROP SOVVKORV VKORV VUORKOR;
END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
TMTUKIDAT YHTTMTUKI TMTUKILMKOR YPITOK 
PERPRDAT PERUSPR PERILMAKOR VVVMKQ ANSIOPR ANSIOILMKOR VUORKORV
VVVPVTQ VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 
YHTTMTUKI = 'Työmarkkinatuki, MALLI'
TMTUKILMKOR = 'Työmarkkinatuki ilman korotusosia, MALLI'
YPITOK = 'Ylläpitokorvaukset, MALLI'
PERILMAKOR = 'Peruspäiväraha ilman korotusosia, MALLI'
PERUSPR = 'Peruspäiväraha, MALLI'
ANSIOPR = 'Ansiopäiväraha, MALLI'
ANSIOILMKOR = 'Ansiopäiväraha ilman aktiiviajan korotusosia, MALLI'
VUORKORV = 'Vuorottelukorvaukset, MALLI'
VVVPVTQ_SIMUL = 'Maksetut ansiopäivärahapäivät, MALLI'
TMTUKIPV_SIMUL = 'Työmarkkinatuen päivien lkm, MALLI';

KEEP hnro knro TMTUKIDAT YHTTMTUKI TMTUKILMKOR YPITOK 
PERPRDAT PERUSPR PERILMAKOR VVVMKQ ANSIOPR ANSIOILMKOR VUORKORV
VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistetään tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_TT;
		
	/* 3.2.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO tmtukimk YPITOKDAT dtyhtep AILMKORQDAT VVVMKQ vvvmk3 VVVPVTQ
			ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_TT;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_TT;
	%END;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

	ARRAY PISTE 
	tmtukimk YPITOKDAT dtyhtep AILMKORQDAT VVVMKQ vvvmk3 VVVPVTQ ;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	tmtukimk = 'Työmarkkinatuki ilman korotusosia, DATA'
	dtyhtep = 'Peruspäiväraha ilman korotusosia, DATA'
	VVVMKQ = 'Ansiopäiväraha, DATA'
	AILMKORQDAT = 'Ansiopäiväraha ilman aktiiviajan korotusosia, DATA'
	vvvmk3 = 'Vuorottelukorvaukset, DATA'
	YPITOKDAT = 'Ylläpitokorvaukset, DATA';

	BY hnro;

	RUN;


	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_TT._KOTI, TEMP.&TULOSNIMI_TT, &MALLI, &MUUTTUJAT);

		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_TT;
		RUN;
		QUIT;
	%END;

	/* Jos käyttäjä määritellyt YKSIKKO=1 (henkilötaso) tai YKSIKKO on mitä tahansa muuta kuin 2 (kotitaloustaso)
		niin jätetään tulostaulu henkilötasolle ja nimetään se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_TT._HLO;
			CHANGE &TULOSNIMI_TT=&TULOSNIMI_TT._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_TT._HLO;
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

%MEND TTurva_Simuloi_Data;

%TTurva_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Tulostetaan käyttäjän pyytämät taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_TT._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_TT._KOTI,2);
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
