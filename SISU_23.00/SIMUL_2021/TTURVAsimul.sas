/************************************************************
* Kuvaus: Ty�tt�myysturvan simulointimalli 					*
************************************************************/ 

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = TTURVA;

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

	%LET AVUOSI = 2021;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2021;		* Lains��d�nt�vuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;        * Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

	%LET TULOSNIMI_TT = tturva_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

	%LET TTDATATULO = 0;	* K�ytet��nk� datan tulotietoja = 1 vai laskennallisia tulotietoja = 0;

	%LET APKESTOSIMUL = 0;	* Leikataanko ansiop�iv�rahan kestoa k�ytett�v�n lains��d�nn�n mukaan = 1 vai eik� = 0.
							  Leikatut p�iv�t siirret��n ty�markkinatukeen;

	%LET VKKESTOSIMUL = 0;	* Leikataanko vuorottelukorvauksen kestoa k�ytett�v�n lains��d�nn�n mukaan = 1 vai eik� = 0.
							  Leikattuja p�ivi� ei siirret� muihin etuuksiin;

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

	* Ajettavat osavaiheet ; 

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakrotiedoston nimi;
	%LET PTTURVA = ptturva; * K�ytett�v�n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = TMTUKIDAT YHTTMTUKI YPITOKDAT YPITOK PERPRDAT PERUSPR VVVMKQ ANSIOPR 
			         vvvmk3 VUORKORV VVVPVTQ VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavu (ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkil�luokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkil�luokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavuv (viitehenkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkil�n koulutusaste)
							     paasoss (viitehenkil�n sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		  * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukum��r�t ;
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

	%LET PAINO = ykor ; 	* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia);

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

		%PUT WARNING: TTURVA-mallissa on keston mallinnus p��ll�. Suhtauduthan saataviin tuloksiin varovaisesti, %CMPRES(
						) sill� keston mallinnuksessa on havaittu ep�selvyyksi�.;

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

	*Ty�historia-muuttuja ansiop�iv�rahan enimm�iskeston lyhennyst� varten;
	TYOHISTV = ROUND(tyokk_hist/12,0.1);

	*Laskennallinen ty�historiamuuttuja ansiop�iv�rahan lis�p�iv�oikeutta varten;
	LASKTYOHISTV = ROUND(lasktyohist/12,0.1);

	*Henkil�n ty�historia koko el�m�n ajalta ennen vuotta 2017 laskettavia korotusosia varten:
	Koska tyokk_hist-muuttujassa on tietoa vain vuodesta 1997 eteenp�in, korjataan sit�
	lis��m�ll� kaikille 10 vuotta;
	KOKOTYOHISTV = SUM(ROUND(tyokk_hist/12,0.1), 10);

	TAYSTARV = SUM(dtthpv, -SOVTARV);
	TAYSOS = SUM(dtospv, -SOVOS);

	*Jos ty�markkinatuen taustatiedot ovat tyhj�t, t�ydennet��n niit�
	ansiop�iv�rahan vastaavilla tiedoilla;
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
	VVVPALQ = 'Ansiop�iv�rahan perusteena oleva vakuutuspalkka, DATA'
	VVVPALX3 = 'Vuorottelukorvauksen perusteena oleva vakuutuspalkka, DATA'
	dtthpv = 'Ty�markkinatuen tarveharkittujen p�ivien lkm, DATA'
	dttayspv = 'Ty�markkinatuen t�ysien p�ivien lkm, DATA'
	dtospv = 'Ty�markkinatuen ositettujen p�ivien lkm, DATA'
	dttspv = 'Ty�markkinatuen soviteltujen p�ivien lkm, DATA'
	dtvpv = 'Ty�markkinatuen muulla sosiaalietuudella v�hennettyjen p�ivien lkm, DATA'
	tmtukipv = 'Ty�markkinatuen p�ivien lkm, DATA'
	dtyllae = 'Ty�markkinatuen kulukorvaukset, DATA'
	dtyllapv = 'Ty�markkinatuen kulukorvausp�iv�t, DATA'
	dttllkm = 'Ty�markkinatuen lapsikorotukset, DATA'
	dtovlkm = 'Ositetun ty�markkinatuen huollettavien lkm, DATA'
	PUOLPALK = 'Puolison tulot tarveharkitussa tm-tuessa, DATA'
	dtomapal = 'Omat (p��oma)tulot tarveharkitussa tm-tuessa, DATA'
	dttspalk = 'Omat ty�tulot sovitellussa tm-tuessa, DATA'
	dtopalkk = 'Vanhehmpien ty�tulot ositetussa tm-tuessa, DATA'
	TMTUKIDAT = 'Ty�markkinatuki, DATA'
	PERPRDAT = 'Perusp�iv�raha, DATA'
	SOVKERTYMA = 'Aineistovuoden sovitellut ansiop�iv�rahap�iv�t kertym�ss�, DATA'
	MUUKERTYMA = 'Muut kuin aineistovuoden sovitellut p�iv�t kertym�ss�, DATA'
	NETTOPV_AVUOSI = 'Ansiop�iv�rahap�iv�t nettona, DATA'
	SOVSUHDEAP_AVUOSI = 'Soviteltu tuki suhteessa t�yteen tukeen AP, DATA'
	SOVSUHDETM_AVUOSI = 'Soviteltu tuki suhteessa t�yteen tukeen TM, DATA'
	TYOHISTV = 'Ty�historia vuosina ansiop�iv�rahan enimm�iskestoa varten, DATA'
	KOKOTYOHISTV = 'Ty�historia vuosina, DATA'
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
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */
%KuukSimul(TTURVA);

DATA TEMP.&TULOSNIMI_TT;
SET STARTDAT.START_TTURVA;

IF VVVPVTQ > 0 THEN DO;

/* 3.1.1. P�ivien uudelleenjako ansiosidonnaisen p�iv�rahan enimm�iskeston perusteella */

	IF &TTDATATULO = 0 THEN PALKKA = LASKPALKKAQ; 
	ELSE PALKKA = VVVPALQ;

	*Muodostetaan t�yden tuen m��r�, jota k�ytet��n apuna monessa kohtaa simulointia;
	%AnsioSidVS(TAYSANSPR, &LVUOSI, &INF, VVVLLKMQ, 0, 0, 0, PALKKA, 0);

	*Keston simulointi alkaa;
	IF &APKESTOSIMUL=1 THEN DO;

		*Simuloidaan ansiop�iv�rahojen kuukausim��r�t, joita k�ytet��n mm. nettop�ivien m��ritt�miseen;
		IF VVVSOPVQ > 0 THEN DO;
			%SoviteltuVS(TEMP_SOVAP, &LVUOSI, &INF, 1, 0, VVVLLKMQ, TAYSANSPR, SOVPALKKAQ, PALKKA, 0);
			SOVSUHDEAP_LVUOSI= ROUND(TEMP_SOVAP / TAYSANSPR, 0.01);
		END;
		ANSIOPV_NETTO = SUM(MUUKERTYMA, ROUND(SOVSUHDEAP_LVUOSI * SOVKERTYMA));
		

		*Simuloidaan tm-tuen kuukausim��r�t nettop�ivien m��ritt�miseen;
		IF dttspv > 0 THEN DO;
			%TyomTukiVS(TEMP_TAYSTM, &LVUOSI, &INF, 0, 0, 0, dttllkm, 0, 0, 0, 0, 0, 0);
			%SoviteltuVS(TEMP_SOVTM, &LVUOSI, &INF, 0, 0, dttllkm, TEMP_TAYSTM, SOVPALKKATM, 0, 0);
			SOVSUHDETM_LVUOSI= ROUND(TEMP_SOVTM / TEMP_TAYSTM, 0.01);
			DROP TEMP_SOVTM TEMP_TAYSTM;
		END;
		TMPAIVAT_NETTO = SUM(tmtukipv, -dttspv, ROUND(SOVSUHDETM_LVUOSI * dttspv));
	
		*Alustetaan enimm�iskeston t�yttymiskuukauden muuttuja;
		IF APENIMKTAYT = 1 THEN TAYTKK = 99; /*Enimm�iskesto t�yttynyt aineistovuonna*/
		IF APENIMKTAYT = 2 THEN TAYTKK = -99; /*Enimm�iskesto t�yttynyt edellisen� vuonna*/

		*Lasketaan enimm�iskeston t�yttymiskuukausi niille joiden ik� sattuu osumaan lis�p�iv�rajaan. 
		V.2017 sama muuttuja kertoo vaihtoehtoisesti alemman, ns. kestoik�rajan t�yttymiskuukauden. Oletus on ett� n�m� ik�rajat eiv�t ole samat.
		HUOM. ei taida toimia tilanteessa jossa enimm�iskestoa pitkitet��n nykyisest�;
		IF TAYTKK NE -99 AND (ikavu >= &LisaPvAlaIka OR ikavu = &KestoIkaRaja) THEN DO;
			TEMPKESTO = &AnsioSidKesto;
			IF &LVUOSI >=2017 AND ikavu >= &LisaPvAlaIka THEN TEMPKESTO = &AnsioSidKesto3;

			IF tklaskr4_ed >= TEMPKESTO THEN TAYTKK = 0;
			ELSE IF tklaskr1 >= TEMPKESTO THEN TAYTKK = CEIL(3 - (SUM(tklaskr1, -TEMPKESTO) / &TTPaivia));
			ELSE IF tklaskr2 >= TEMPKESTO THEN TAYTKK = MIN( 6, FLOOR( SUM( TEMPKESTO, -tklaskr1) / &TTPaivia) + 4);
			ELSE IF tklaskr3 >= TEMPKESTO THEN TAYTKK = MIN( 9, FLOOR( SUM( TEMPKESTO, -tklaskr2) / &TTPaivia) + 7);
			ELSE IF tklaskr4 >= TEMPKESTO THEN TAYTKK = MIN(12, FLOOR( SUM( TEMPKESTO, -tklaskr3) / &TTPaivia) + 10);
		END;


		*Lasketaan ty�ss�oloehto ensimm�isen ik�rajan ylitt�neille olettaen ett� aineistovuonna ei ole kertynyt lis�� ty�viikkoja;
		IF &LVUOSI >=2017 AND ikavu >= &KestoIkaRaja THEN DO;
			IF ikavu = &KestoIkaRaja THEN TYOOLOVKO= ROUND( SUM( tyopv_ed, MIN(12, &TyoEhtoTarkJKK-12-(12-ikakk)) /12 * tyopv_ed2, MAX(0, (&TyoEhtoTarkJKK-24-(12-ikakk))/12 *tyopv_ed3)) / 7);
	
			*59-vuotiaille ty�ss�oloehto lasketaan niin kaukaa kun on dataa. Lasketaan kolme vuoden ajalta, koska oletetaan ett� viimeisen vuoden mahdolliset ty�jaksot keskittyy alkuvuoteen;
			ELSE IF ikavu = &KestoIkaRaja +1 THEN TYOOLOVKO = ROUND( SUM( (&TyoEhtoTarkJKK-12-(12-ikakk))/12 *tyopv_ed3, tyopv_ed2, tyopv_ed) / 7);

			*Yli 59-vuotiaille data riitt�� huonosti, joten heist� kaikkien oletetaan t�ytt�neen ty�ss�oloehdon yli 58 vuotiaana;
			ELSE TYOOLOVKO = 99;
			TYOOLOEHTO= (TYOOLOVKO >= &TyoEhtoVko);
		END;
		DROP TEMPKESTO TYOOLOVKO;


		*Lasketaan mahdolliset siirtyv�t p�iv�t;
		%AnsioSidKestoRaj(SIIRTPV, &LVUOSI, 1, ANSIOPV_NETTO, TYOHISTV, LASKTYOHISTV, TAYTKK, ikavu, ikakk, TMPAIVAT_NETTO, TYOOLOEHTO, 0);

		*Skaalataan ne aineistovuoden p�iviin;
		SIIRTPV = MIN(NETTOPV_AVUOSI, SIIRTPV);

		*Jyvitet��n siirtyv�t ansiop�iv�rahat ty�markkinatukeen lajeittain vastaten samoja suhteita kuin ansiop�iv�rahassa; 
		IF SIIRTPV >0 THEN DO;

			*P�ivien siirto ty�markkinatukeen;
			dttayspv = SUM(dttayspv, ROUND( SUM(PELKTAYSPVQ, tayskorpv1) / NETTOPV_AVUOSI * SIIRTPV));
			PELKKOR = SUM( PELKKOR, ROUND( tayskorpv5 / NETTOPV_AVUOSI * SIIRTPV));
	
			*V�hennys ansiop�iv�rahoista;
			ARRAY TAYDET PELKTAYSPVQ TAYSKORPV1 TAYSKORPV5;
			DO OVER TAYDET;
				TAYDET = ROUND( SUM( TAYDET, -(TAYDET / NETTOPV_AVUOSI) * SIIRTPV));
			END;

			*Soviteltujen p�ivien siirto;
			IF SOVSUHDEAP_LVUOSI > 0 AND  ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) > 0 THEN DO;

				*Painotettu keskiarvo ty�tuloista;
				dttspalk = SUM(dttspv * dttspalk, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) * SOVPALKKAQ) / SUM(dttspv, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV));
				SOVPALKKATM = SUM(dttspv * SOVPALKKATM, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV) * SOVPALKKAQ) / SUM(dttspv, ROUND((VVVSOPVQ / VVVPVTQ) * SIIRTPV));

				*Soviteltujen p�ivien suhteutuksessa t�ytyy ottaa huomioon aineistovuoden ja lains��d�nt�vuoden sovittelusuhde.;
				SOVPELK = ROUND( SUM( SOVPELK, SOVSUHDEAP_AVUOSI * SUM(PELKSOPVQ, sovkorpv1) / NETTOPV_AVUOSI * SIIRTPV / SOVSUHDEAP_LVUOSI));
				SOVKOR = ROUND( SUM( SOVKOR, SOVSUHDEAP_AVUOSI * sovkorpv5 / NETTOPV_AVUOSI * SIIRTPV  / SOVSUHDEAP_LVUOSI));
	
				*V�hennys sov. ansiop�iv�rahoista;
				ARRAY SOVITELLUT sovkorpv5 PELKSOPVQ sovkorpv1;
				DO OVER SOVITELLUT;
					SOVITELLUT = ROUND( SUM( SOVITELLUT, -( SOVSUHDEAP_AVUOSI * SOVITELLUT / NETTOPV_AVUOSI) * SIIRTPV / SOVSUHDEAP_LVUOSI));
				END;


			END;

		END;
		IF SIIRTPV < 0 THEN DO;
	
			PELKTAYSPVQ = SUM( PELKTAYSPVQ, ROUND( SUM(dttayspv, PELKVAH, TAYSTARV, TAYSOS) / TMPAIVAT_NETTO * -SIIRTPV));
			TAYSKORPV5 = SUM( TAYSKORPV5, ROUND( SUM(PELKKOR, KORVAH) / TMPAIVAT_NETTO * -SIIRTPV));

			*V�hennys ansiop�iv�rahoista;
			ARRAY TAYDET_TM dttayspv PELKKOR PELKVAH KORVAH TAYSTARV TAYSOS;
			DO OVER TAYDET_TM;
				TAYDET_TM = ROUND( SUM( TAYDET_TM, (TAYDET_TM / TMPAIVAT_NETTO) * SIIRTPV));
			END;

			IF SOVSUHDETM_LVUOSI > 0 AND ROUND( dttspv/tmtukipv * (-SIIRTPV)) > 0 THEN DO;

				*Painotettu keskiarvo ty�tuloista;
				SOVPALKKAQ = SUM(ROUND( dttspv/tmtukipv * (-SIIRTPV)) * SOVPALKKATM, VVVSOPVQ * SOVPALKKAQ) / SUM(ROUND( dttspv/tmtukipv * (-SIIRTPV)), VVVSOPVQ);


				*Soviteltujen p�ivien suhteutuksessa t�ytyy ottaa huomioon aineistovuoden ja lains��d�nt�vuoden sovittelusuhde.;
				PELKSOPVQ = ROUND( SUM( PELKSOPVQ, SOVSUHDETM_AVUOSI * SUM(SOVPELK, SOVVAH, SOVTARV, SOVOS) / TMPAIVAT_NETTO * -SIIRTPV / SOVSUHDETM_LVUOSI));
				SOVKORPV5 = ROUND( SUM( SOVKORPV5, SOVSUHDETM_AVUOSI * SUM(SOVKOR, SOVKORVAH) / TMPAIVAT_NETTO * -SIIRTPV  / SOVSUHDETM_LVUOSI));
		
				*V�hennys sov. ansiop�iv�rahoista;
				ARRAY SOVITELLUT_TM SOVPELK SOVVAH SOVTARV SOVOS SOVKOR SOVKORVAH;
				DO OVER SOVITELLUT_TM;
					SOVITELLUT_TM = ROUND( SUM( SOVITELLUT_TM, ( SOVSUHDETM_AVUOSI * SOVITELLUT_TM / TMPAIVAT_NETTO) * SIIRTPV / SOVSUHDETM_LVUOSI));
				END;
			END;
		END;
		
		*DROP TEMP_SOVAP TEMP_TAYSTM TEMP_SOVTM APENIMKTAYT TAYTKK SOVSUHDEAP_LVUOSI SOVSUHDETM_LVUOSI SOVSUHDEAP_AVUOSI SOVSUHDETM_AVUOSI tklaskr1-tklaskr4 TMPAIVAT_NETTO ANSIOPV_NETTO;
	END;

	VVVPVTQ_SIMUL = SUM(PELKTAYSPVQ, PELKSOPVQ, TAYSKORPV5, SOVKORPV5, TAYSKORPV1, SOVKORPV1);

/* 3.1.2. Ansiop�iv�rahan simulointi */

	 * Lasketaan ei-korotetut p�iv�rahat;
	IF PELKTAYSPVQ > 0 THEN TAYSAPR = PELKTAYSPVQ * TAYSANSPR / &TTPaivia;
		
	IF PELKSOPVQ > 0 THEN DO;
		%SoviteltuVS(SOVANSPR, &LVUOSI, &INF, 1, 0, VVVLLKMQ, TAYSANSPR, SOVPALKKAQ, PALKKA, 0);
		SOVAPR = PELKSOPVQ * SOVANSPR / &TTPaivia;
	END;
	
	* Lasketaan korotetut p�iv�rahat ;
	IF SOVKORPV1 OR TAYSKORPV1 THEN DO;
		%AnsioSidVS(TAYSKORPR1, &LVUOSI, &INF, VVVLLKMQ, (&LVUOSI < 2017 AND KOKOTYOHISTV > &KorEhtoV), 0, 0, PALKKA, 0);

		IF SOVKORPV1 > 0 THEN DO;
			%SoviteltuVS(SOVKORPR1, &LVUOSI, &INF, 1, (&LVUOSI < 2017 AND KOKOTYOHISTV > &KorEhtoV), VVVLLKMQ, TAYSKORPR1, SOVPALKKAQ, PALKKA, 0);
			SOVKORPR1 = SOVKORPV1 * SOVKORPR1 / &TTPaivia;
		END;

		TAYSKORPR1 = TAYSKORPV1 * TAYSKORPR1 / &TTPaivia;
	END;


	* Lasketaan korotetut p�iv�rahat ;
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

/* 3.1.3. Ty�markkinatuen simulointi */
TMTUKIPV_SIMUL = SUM(PELKKOR, KORVAH, SOVKOR, SOVKORVAH, TAYSTARV, TAYSOS, SOVTARV, SOVOS, SOVPELK, SOVVAH, PELKVAH, dttayspv);

IF TMTUKIPV_SIMUL > 0 THEN DO;

	* Tarveharkitut ty�markkinatuet ;
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

	* Osittaiset ty�markkinatuet ;
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

	* Korotetut ty�markkinatuet;
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

	* Sovitellut t�ydet tmtuet ;
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

	* T�ydet tmtuet ;
	IF dttayspv > 0 THEN DO;
		%TyomTukiVS(TAYSTMTUKI, &LVUOSI, &INF, ikavu < &TarvHarkIka AND NOT MAX(HTYOTPER,VVVMKQ), 0, PUOLPALK, dttllkm, 0, 0, PUOLPALK, 0, 0, 0);
		TAYSTMTUKI = dttayspv * TAYSTMTUKI / &TTPaivia;
	END;
	
	* Tuet joista on v�hennetty muuta sosiaalietuutta ;
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


/* 3.1.4. Perusp�iv�raha */

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
		*Sovitellaan ensi perusosa. Jos j�� soviteltavaa niin sitten vasta korotusosa;
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
	* Jos on valittu vuorottelukorvauksen keston simulointi, leikataan p�ivi� lains��d�nn�n mukaan;
	IF &VKKESTOSIMUL=1 THEN DO;
		%AnsioSidKestoRaj(VSIIRTPV, &LVUOSI, 1, SUM(vvvpvt3, vvvpvt3_ed), TYOHISTV, LASKTYOHISTV, 0, 0, 0, 0, 0, 1);
	END;
	ELSE DO;
		VSIIRTPV = 0;
	END;

	VUORKORV = (SUM(vvvpvt3,-VSIIRTPV)/ vvvpvt3) * SUM(PELKTAYSPV3 * VKORV, vvvsopv3 * SOVVKORV) / &TTPaivia;
	DROP SOVVKORV VKORV VUORKOR;
END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

ARRAY PISTE 
TMTUKIDAT YHTTMTUKI TMTUKILMKOR YPITOK 
PERPRDAT PERUSPR PERILMAKOR VVVMKQ ANSIOPR ANSIOILMKOR VUORKORV
VVVPVTQ VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 
YHTTMTUKI = 'Ty�markkinatuki, MALLI'
TMTUKILMKOR = 'Ty�markkinatuki ilman korotusosia, MALLI'
YPITOK = 'Yll�pitokorvaukset, MALLI'
PERILMAKOR = 'Perusp�iv�raha ilman korotusosia, MALLI'
PERUSPR = 'Perusp�iv�raha, MALLI'
ANSIOPR = 'Ansiop�iv�raha, MALLI'
ANSIOILMKOR = 'Ansiop�iv�raha ilman aktiiviajan korotusosia, MALLI'
VUORKORV = 'Vuorottelukorvaukset, MALLI'
VVVPVTQ_SIMUL = 'Maksetut ansiop�iv�rahap�iv�t, MALLI'
TMTUKIPV_SIMUL = 'Ty�markkinatuen p�ivien lkm, MALLI';

KEEP hnro knro TMTUKIDAT YHTTMTUKI TMTUKILMKOR YPITOK 
PERPRDAT PERUSPR PERILMAKOR VVVMKQ ANSIOPR ANSIOILMKOR VUORKORV
VVVPVTQ_SIMUL tmtukipv TMTUKIPV_SIMUL;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T�t� vaihetta ei ajeta mik�li osamallia k�ytet��n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet��n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_TT;
		
	/* 3.2.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

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

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

	ARRAY PISTE 
	tmtukimk YPITOKDAT dtyhtep AILMKORQDAT VVVMKQ vvvmk3 VVVPVTQ ;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	tmtukimk = 'Ty�markkinatuki ilman korotusosia, DATA'
	dtyhtep = 'Perusp�iv�raha ilman korotusosia, DATA'
	VVVMKQ = 'Ansiop�iv�raha, DATA'
	AILMKORQDAT = 'Ansiop�iv�raha ilman aktiiviajan korotusosia, DATA'
	vvvmk3 = 'Vuorottelukorvaukset, DATA'
	YPITOKDAT = 'Yll�pitokorvaukset, DATA';

	BY hnro;

	RUN;


	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_TT._KOTI, TEMP.&TULOSNIMI_TT, &MALLI, &MUUTTUJAT);

		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_TT;
		RUN;
		QUIT;
	%END;

	/* Jos k�ytt�j� m��ritellyt YKSIKKO=1 (henkil�taso) tai YKSIKKO on mit� tahansa muuta kuin 2 (kotitaloustaso)
		niin j�tet��n tulostaulu henkil�tasolle ja nimet��n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_TT._HLO;
			CHANGE &TULOSNIMI_TT=&TULOSNIMI_TT._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_TT._HLO;
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

%MEND TTurva_Simuloi_Data;

%TTurva_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Tulostetaan k�ytt�j�n pyyt�m�t taulukot */

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
