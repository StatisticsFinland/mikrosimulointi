/*************************************************
* TY�TT�MYYSTURVAN AINEISTOSIMULOINTI			 *
* KUUKAUSITASOISELLA TY�TT�MYYSTURVA-AINEISTOLLA * 
*************************************************/


/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = TTURVA;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO S_TTURVA_KK_Aloitus;

	/* Jos ohjelma ajetaan KOKO-mallin kautta, k�ytet��n siell� m��riteltyj� ohjaavien makromuuttujien arvoja muokattuna kk-malliin sopiviksi*/

	%IF &START = 1 %THEN %DO;
		%IF &TYYPPI_KOKO = SIMUL %THEN %DO;
			%LET TYYPPI = ESIM;
		%END;
		%IF &TYYPPI_KOKO = SIMULX %THEN %DO;
			%LET TYYPPI = SIMULX;
		%END;
		%LET TULOKSET = 0;
		%LET AINEISTO_KK = TTURVA_KK;
	%END;

	/* Jos ohjelma ajetaan erillisajossa, k�ytet��n alla sy�tettyj� ohjaavien makromuuttujien arvoja */

	%IF &START NE 1 %THEN %DO;

		/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

		%IF &EG NE 1 %THEN %DO;

			%LET AVUOSI = 2023;		* Aineistovuosi (vvvv);

			%LET LVUOSI = 2023;		* Lains��d�nt�vuosi (vvvv);

			%LET TYYPPI = ESIM;		* Parametrien hakutyyppi: ESIM (parametrit datan kuukausille) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

			%LET LKUUK = 12;        * Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

			%LET AINEISTO_KK = TTURVA_KK;	* K�ytett�v� aineisto (TTURVA_KK = Kuukausitason rekisteriaineisto);

			%LET TULOSNIMI_TT = tturva_kk_simul_&SYSDATE.; * Simuloidun tulostiedoston nimi;

			* Inflaatiokorjaus. Euro- tai markkam��r�isten parametrien haun yhteydess� suoritettavassa
			  deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse INF-makromuuttujaan
			  (HUOM! desimaalit erotettava pisteell� .). Esim. jos yksi lains��d�nt�vuoden euro on
			  aineistovuoden rahassa 95 sentti�, sy�t� arvoksi 0.95.
			  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
			  Jos puolestaan haluaa k�ytt�� automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
			  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
			  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

			%LET INF = KHI; * Sy�t� lukuarvo, KHI tai ATI;
			%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;

			* Ajettavat osavaiheet ; 

			%LET POIMINTA = 1;  	
			%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

			%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakrotiedoston nimi;
			%LET PTTURVA = ptturva; 					* Lakiparametritiedoston nimi ; 

			%LET APKESTOSIMUL = 0;	* Leikataanko ansiop�iv�rahan kestoa k�ytett�v�n lains��d�nn�n mukaan = 1 vai eik� = 0.
							  Leikatut p�iv�t siirret��n ty�markkinatukeen;

* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja) ;
	%LET MUUTTUJAT = 				/*Taulukoitavat muuttujat (summataulukot)*/
					 ANSIOPR_DATA		/*Ansiop�iv�raha, data*/
					 ANSIOPR			/*Ansiop�iv�raha, simul*/
					 TMTUKI_DATA		/*Ty�markkinatuki, data*/
					 YHTTMTUKI			/*Ty�markkinatuki, simul*/
					 PERUSPR_DATA		/*Perusp�iv�raha, data*/
					 PERUSPR			/*Perusp�iv�raha, simul*/
					 VUORKORV_DATA		/*Vuorottelukorvaukset, data*/
					 ANSIOPRPV_DATA		/*Ansiop�iv�rahap�iv�t, data*/
					 ANSIOPRPV_SIMUL	/*Ansiop�iv�rahap�iv�t, simul*/
					 TMTUKIPV_DATA		/*Ty�markkinatukip�iv�t, data*/
					 TMTUKIPV_SIMUL		/*Ty�markkinatukip�iv�t, simul*/
					 PERUSPRPV_DATA		/*Perusp�iv�rahap�iv�t, data*/
					 PERUSPRPV_SIMUL	/*Perusp�iv�rahap�iv�t, simul*/
					 ;


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

%MEND S_TTURVA_KK_Aloitus;

%S_TTURVA_KK_Aloitus;


/* 2. Aineiston muokkaus simulointivalmiiksi */

%MACRO S_TTURVA_KK_Muokkaa;

%IF &POIMINTA = 1 %THEN %DO;

	/* TTURVA-mallin parametrit */
	/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
	%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

	/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
	%HaeLokaalit(TTURVA_PARAM, TTURVA);
	%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

	/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
	%LOCAL &TTURVA_PARAM &TTURVA_MUUNNOS;

	/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */
	%KuukSimul(TTURVA);
    
	/* V�hennet��n takaisinperinn�t ansiop�iv�rahoista ja -p�ivist� kuukausittain */
	PROC SORT DATA = POHJADAT.&AINEISTO_KK&AVUOSI
		OUT = TEMP.TTURVA_KK&avuosi._SORT;
		BY hnro akuuk;
	RUN;
	
	PROC SUMMARY DATA = TEMP.TTURVA_KK&avuosi._SORT NWAY;
    	CLASS hnro akuuk;
    	ID &PAINO avuosi lomautettu lapsimaara pepalkkavteke tmedvuosi ppedvuosi apedvuosi;
		VAR sovipalkka tmomattulot--APPOAPTAPPLISAP appertayspvt--yllanordeur;
    	OUTPUT OUT = TEMP.TTURVA_KK&avuosi._NETTOKK (DROP = _:) SUM = ;
	RUN;
    
	/* Rajataan starttidataan vain ty�tt�myysturvaa saaneet ja tarvittavat muuttujat */
	DATA STARTDAT.START_TTURVA_KK;

	SET TEMP.TTURVA_KK&avuosi._NETTOKK
 		(WHERE = (SUM(appertayspvt, appersovipvt, apkortayspvt, apkorsovipvt,
					pppertayspvt, pppersovipvt, ppkortayspvt, ppkorsovipvt,
					tmpertayspvt, tmpersovipvt, tmkortayspvt, tmkorsovipvt,
					vvappertayspvt, vvappersovipvt, vvpppertayspvt, vvpppersovipvt)) 

		KEEP = hnro ykor akuuk lapsimaara sovipalkka pepalkkavteke
				tmomattulot tmosvanhlapsimaara tmosvanhtulot sosetulot appoaptapplisap
				appertayspvt appertayspvt_eikor appertayseur appersovipvt appersovipvt_eikor appersovieur
				apkortayspvt apkortayseur apkorsovipvt apkorsovieur
				pppertayspvt pppertayspvt_eikor pppertayseur pppersovipvt pppersovipvt_eikor pppersovieur
				ppkortayspvt ppkortayseur ppkorsovipvt ppkorsovieur
				tmpertayspvt tmpertayspvt_eikor tmpertayseur tmpersovipvt tmpersovipvt_eikor tmpersovieur
				tmkortayspvt tmkortayseur tmkorsovipvt tmkorsovieur
				vvappertayseur vvappersovieur vvpppertayseur vvpppersovieur
				vvappertayspvt vvappersovipvt vvpppertayspvt vvpppersovipvt
				tmedvuosi ppedvuosi apedvuosi);

		/* Lasketaan sovitellut p�iv�rahat suhteessa t�yteen p�iv�rahaan keston m��rityst� varten.
		T�m� perustuu nyt aineistovuoteen, vaikka tarkkaan ottaen t�m� tulisi siirt�� simulointiin.
		Se kuitenkin monimutkaistaisi koodia hieman */
		IF SUM(appersovipvt_eikor, apkorsovipvt) THEN DO;
			%AnsioSidKS(TAYSANSPR, &AVUOSI, akuuk, 1, lapsimaara, 0, 0, 0, pepalkkavteke, 0, 0, 0);
			%SoviteltuKS(TEMP_SOVAP, &AVUOSI, akuuk, 1, 1, 0, lapsimaara, TAYSANSPR, sovipalkka, pepalkkavteke, 0);
			tayspv_suhde = ROUND(TEMP_SOVAP / TAYSANSPR, 0.001);
		END;
		ELSE tayspv_suhde = 1;

	/* P�iv�summia. Huom. ansiop�iv�rahap�iv�t on muunnettu t�ysty�tt�myysp�iviksi, tm-tukip�iv�t eiv�t */
	appvtnetto_yht = SUM(appertayspvt_eikor, apkortayspvt, ROUND(tayspv_suhde*SUM(appersovipvt_eikor, apkorsovipvt), 0.1)); /* Ansiop�iv�rahan luokat yhteens� */
	tmpvt_yht = SUM(tmpertayspvt_eikor, tmkortayspvt, tmpersovipvt_eikor, tmkorsovipvt); /* Ty�markkinatuen luokat yhteens� */
	pppvt_yht = SUM(pppertayspvt_eikor, ppkortayspvt, pppersovipvt_eikor, ppkorsovipvt); /* Perusp�iv�rahan luokat yhteens� */
	
	DROP TEMP_SOVAP TAYSANSPR;
	RUN;

	/* Haetaan vuosirekisterist� mukaan muuttujia */
	DATA STARTDAT.START_TTURVA_KK;
		MERGE STARTDAT.START_TTURVA_KK(IN=b) 
			  POHJADAT.REK&AVUOSI.(IN=a
				KEEP = hnro ikavu tyopv_ed tyopv_ed2 tyopv_ed3 tklaskr4_ed tklaskr1-tklaskr4
					   tyokk_hist lasktyohist ikakk vvvpvtq knro dtyhtep vvvmkq vanh_omaishoitohp);
		BY hnro;
		IF a AND b;

	/* Ty�historia-muuttuja ansiop�iv�rahan enimm�iskeston lyhennyst� varten */
	TYOHISTV = ROUND(tyokk_hist / 12, 0.1);

	/* Laskennalliset ty�vuodet 20 vuoden ajalta
	Datamuuttuja lasktyohist (laskennalliset ty�kuukaudet) on laskettu jakamalla viimeisen 20 vuoden ty�tulot vuositasolla 510 eurolla */
	LASKTYOHISTV = ROUND(lasktyohist / 12, 0.1);

	/* Nollataan seuraavan kvartaalin kertym�, jos tklaskr pienentynyt edelliseen kvartaaliin n�hden mutta ei nollaantunut (ansiosidonnaisen laskuri alkanut alusta) */
	IF (akuuk>3 AND 0<tklaskr1<tklaskr4_ed) OR (akuuk>6 AND 0<tklaskr2<tklaskr1) OR (akuuk>9 AND 0<tklaskr3<tklaskr2) THEN nollaus=1;

	/* Nollataan kertym� my�s kvartaalilta, jossa tklaskr kasvaa nollasta positiiviseksi (ansiosidonnaisen laskuri alkanut alusta) */
	IF (akuuk>3 AND tklaskr1=0 and tklaskr2>0) OR (akuuk>6 AND tklaskr2=0 AND tklaskr3>0) OR (akuuk>9 AND tklaskr3=0 AND tklaskr4>0) THEN nollaus=1;

	/* Datassa ik� on vuoden lopun tilanteen mukaan. Lains��d�nn�ss� ik�vuosiin on sidottuja rajoja.
	Selvitet��n juoksevasti ik�vuosien t�yttyminen ikakk juoksevaksi
	ikakk2 on apumuuttuja: Maksukuukausi (akuuk)-12- Kuukaudet vuoden lopussa (ikakk)) */
	ikakk2 = SUM(akuuk, -SUM(12, -ikakk));

	/* Ik�vuodet py�ristet��n alasp�in (floor) */
	ikavu2 = FLOOR(SUM(ikavu, (ikakk2 / 12)));
	syntv = SUM(&AVUOSI., -ikavu);

	/* Muodostetaan datan summamuuttujat */
	ANSIOPR_DATA = SUM(appertayseur, apkorsovieur, appersovieur, apkortayseur);
	TMTUKI_DATA = SUM(tmpertayseur, tmkorsovieur, tmpersovieur, tmkortayseur);
	PERUSPR_DATA = SUM(pppertayseur, ppkorsovieur, pppersovieur, ppkortayseur);
	VUORKORV_DATA =	SUM(vvappertayseur, vvappersovieur, vvpppertayseur, vvpppersovieur);

	ANSIOPRPV_DATA = SUM(appertayspvt_eikor, apkorsovipvt, appersovipvt_eikor, apkortayspvt);
	TMTUKIPV_DATA = SUM(tmpertayspvt_eikor, tmkorsovipvt, tmpersovipvt_eikor, tmkortayspvt);
	PERUSPRPV_DATA = SUM(pppertayspvt_eikor, ppkorsovipvt, pppersovipvt_eikor, ppkortayspvt);

	/* Pudotetaan turhat muuttujat pois ja sortataan */
	DROP
		appertayseur apkorsovieur appersovieur apkortayseur
		tmpertayseur tmkorsovieur tmpersovieur tmkortayseur
		pppertayseur ppkorsovieur pppersovieur ppkortayseur
		vvappertayseur vvappersovieur vvpppertayseur vvpppersovieur;
	RUN;

	PROC SORT DATA = STARTDAT.START_TTURVA_KK;
		BY hnro akuuk nollaus;
	RUN;
%END;

%MEND S_TTURVA_KK_Muokkaa;

%S_TTURVA_KK_Muokkaa;


/* 3. Simulointi */

%LET alkoi2&malli = %SYSFUNC(TIME());

%MACRO TTURVA_KK_Simuloi;

	/* TTURVA-mallin parametrit */
	/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
	%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

	/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
	%HaeLokaalit(TTURVA_PARAM, TTURVA);
	%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

	/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
	%LOCAL &TTURVA_PARAM &TTURVA_MUUNNOS;

	/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */
	%KuukSimul(TTURVA);

	%IF %UPCASE(&TYYPPI) = ESIM %THEN %LET KUUK=akuuk;
	%ELSE %IF %UPCASE(&TYYPPI) = SIMULX %THEN %LET KUUK=&LKUUK;

/* 3.1 KK-simuloinnin alustus */ 

DATA TEMP.&TULOSNIMI_TT._KK;
SET STARTDAT.START_TTURVA_KK;
BY hnro;

RETAIN kertyma; 

/* Tehd��n omavastuup�ivien v�hennys vain, jos ty�tt�myys ei ole alkanut edellisen vuoden aikana */
IF tmedvuosi = 0 AND ppedvuosi = 0 AND apedvuosi = 0 THEN DO;

	/* T�ss� muodostetaan aineistovuoden omavastuup�iv�t alkaville jaksoille omavastuup�ivien simulointia varten. 
	Se on nyt kovakoodattu dataan, mutta voi tehd� toisinkin */
	IF first.hnro THEN DO; 

		/* Omavastuup�ivien simulointi */
		%Omavastuupv(omav_muutos, &LVUOSI, &KUUK, &AVUOSI, AKUUK);

		/* Jos omavastuup�iv�t on erit kuin aineistossa, jyvitet��n muutos olemassaoleville ty�tt�myysp�iville */
		IF omav_muutos THEN DO;
			IF appertayspvt_eikor > 0 THEN appertayspvt_eikor = SUM(appertayspvt_eikor, -omav_muutos);
			ELSE IF apkortayspvt > 0 THEN apkortayspvt = SUM(apkortayspvt, -omav_muutos);
			ELSE IF appersovipvt_eikor > 0 THEN appersovipvt_eikor = SUM(appersovipvt_eikor, -omav_muutos);
			ELSE IF apkorsovipvt > 0 THEN apkorsovipvt = SUM(apkorsovipvt, -omav_muutos);
			ELSE IF tmpertayspvt_eikor > 0 THEN tmpertayspvt_eikor = SUM(tmpertayspvt_eikor, -omav_muutos);
			ELSE IF tmkortayspvt > 0 THEN tmkortayspvt = SUM(tmkortayspvt, -omav_muutos);
			ELSE IF tmpersovipvt_eikor > 0 THEN tmpersovipvt_eikor = SUM(tmpersovipvt_eikor, -omav_muutos);
			ELSE IF tmkorsovipvt > 0 THEN tmkorsovipvt = SUM(tmkorsovipvt, -omav_muutos);
			ELSE IF pppertayspvt_eikor > 0 THEN pppertayspvt_eikor = SUM(pppertayspvt_eikor, -omav_muutos);
			ELSE IF ppkortayspvt > 0 THEN ppkortayspvt = SUM(ppkortayspvt, -omav_muutos);
			ELSE IF pppersovipvt_eikor > 0 THEN pppersovipvt_eikor = SUM(pppersovipvt_eikor, -omav_muutos);
			ELSE IF ppkorsovipvt > 0 THEN ppkorsovipvt = SUM(ppkorsovipvt, -omav_muutos);
		END;
	END;
END;

/* Lasketaan kertym� keston simulointia varten */
appvtnetto_yht = SUM(appertayspvt_eikor, apkortayspvt, ROUND(tayspv_suhde*SUM(appersovipvt_eikor, apkorsovipvt), 0.1)); /* Ansiop�iv�rahan luokat yhteens� */
IF first.hnro THEN kertyma = tklaskr4_ed; /* Ansiop�iv�rahan Fiva-kertym� edellisen vuoden lopussa */
IF nollaus AND NOT LAG(nollaus) THEN kertyma = 0; /* Suoritetaan jakson nollaus, jos laskurimuuttuja on nollaantunut */
IF SUM(kertyma, appvtnetto_yht) >= 0 THEN kertyma = SUM(kertyma, appvtnetto_yht);
ELSE kertyma = 0;

/* Simuloidaan vuoden sis�ll� kestorajojen perusteella tapahtuvat siirtym�t ansiosidonnaisen ja ty�markkinatuen v�lill�
Huom. t�ss� t�rke� k�ytt�� vvvpvtq-muuttujaa, jolla valitaan kaikki jolla ansiop�iv�rahap�ivi� vuoden aikana */
IF vvvpvtq > 0 AND &APKESTOSIMUL = 1 THEN DO;
	%AnsioSidKestoRajKK(kestomuutos, &LVUOSI, &KUUK, kertyma, tyohistv, lasktyohistv, appoaptapplisap, syntv, ikavu2, tmpvt_yht, appvtnetto_yht, tyopv_ed, tyopv_ed2, tyopv_ed3);

	/* Siirret��n ansiop�iv�raha ty�markkinatueksi */
	IF kestomuutos < 0 AND appvtnetto_yht > 0 THEN DO;

		/* Lis�t��n ty�markkinatukea */
		IF appertayspvt_eikor THEN tmpertayspvt_eikor = SUM(tmpertayspvt_eikor, ROUND((-kestomuutos/appvtnetto_yht) * appertayspvt_eikor));
		IF apkortayspvt THEN tmkortayspvt = SUM(tmkortayspvt, ROUND((-kestomuutos/appvtnetto_yht) * apkortayspvt));
		IF appersovipvt_eikor THEN tmpersovipvt_eikor = SUM(tmpersovipvt_eikor, ROUND((-kestomuutos/appvtnetto_yht) * appersovipvt_eikor));
		IF apkorsovipvt THEN tmkorsovipvt = SUM(tmkorsovipvt, ROUND((-kestomuutos/appvtnetto_yht) * apkorsovipvt));

		*V�hennet��n ansiop�iv�rahoja vastaavasti;
		ARRAY ansio apkorsovipvt apkortayspvt appersovipvt_eikor appertayspvt_eikor;
		DO OVER ansio;
			ansio = ROUND(SUM(ansio, (kestomuutos/appvtnetto_yht) * ansio));
		END;
	END;

	/* Siirret��n ty�markkinatuki ansiop�iv�rahaksi */
	IF kestomuutos > 0 AND tayspv_suhde > 0 AND tmpvt_yht > 0 THEN DO;

		/* Lis�t��n ansiop�iv�rahoja */
		IF tmpertayspvt_eikor then appertayspvt_eikor = SUM(appertayspvt_eikor, ROUND((kestomuutos/tayspv_suhde/tmpvt_yht) * tmpertayspvt_eikor));
		IF tmkortayspvt then apkortayspvt = SUM(apkortayspvt, ROUND((kestomuutos/tayspv_suhde/tmpvt_yht) * tmkortayspvt));
		IF tmpersovipvt_eikor then appersovipvt_eikor = SUM(appersovipvt_eikor, ROUND((kestomuutos/tayspv_suhde/tmpvt_yht) * tmpersovipvt_eikor));
		IF tmkorsovipvt then apkorsovipvt = SUM(apkorsovipvt, ROUND((kestomuutos/tayspv_suhde/tmpvt_yht) * tmkorsovipvt));

		/* V�hennet��n ty�markkinatukea */
		ARRAY tmtuk tmpertayspvt_eikor tmkortayspvt tmpersovipvt_eikor tmkorsovipvt;
		DO OVER tmtuk;
			tmtuk = ROUND(SUM(tmtuk,(-kestomuutos/tayspv_suhde/tmpvt_yht) * tmtuk));
		END;
	END;
END;

/* Summataan p�iv�t uudelleen yhteen, jos muuttuneet kestosimuloinnin takia */
appvtnetto_yht = SUM(appertayspvt_eikor, apkortayspvt, ROUND(tayspv_suhde*SUM(appersovipvt_eikor, apkorsovipvt), 0.1)); /* Ansiop�iv�rahan luokat yhteens� */
tmpvt_yht = SUM(tmpertayspvt_eikor, tmkortayspvt, tmpersovipvt_eikor, tmkorsovipvt);

/* 3.2 Simuloidaan ansiop�iv�raha, perusp�iv�raha ja ty�markkinatuki */

	/* Ansiop�iv�raha */
	IF appvtnetto_yht THEN DO;

		/* Perus */
		%AnsioSidKS(SIMUL_APPERTAYSEURKK, &LVUOSI, &KUUK, &INF, 
					lapsimaara, 0, 0, LISAPAIVOIK, pepalkkavteke, sosetulot, kertyma, sum(kertyma, -appvtnetto_yht));
		SIMUL_APPERTAYSEUR = appertayspvt_eikor * (SIMUL_APPERTAYSEURKK / &TTPaivia);
				
		/* Korotettu */
		IF apkortayspvt OR apkorsovipvt THEN DO;

			%AnsioSidKS(SIMUL_APKORTAYSEURKK, &LVUOSI, &KUUK, &INF, 
						lapsimaara, 1, 0, LISAPAIVOIK, pepalkkavteke, sosetulot, kertyma, sum(kertyma, -appvtnetto_yht));
			/* Korotusosa erikseen! */
			SIMUL_APKORILMTAYS = apkortayspvt * (SIMUL_APPERTAYSEURKK / &TTPaivia);
			SIMUL_APKORTAYSEUR = apkortayspvt * (SIMUL_APKORTAYSEURKK / &TTPaivia);
		END;

		/* Soviteltu, perus */
		IF appersovipvt_eikor OR apkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_APPERSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 1, 0, lapsimaara, SIMUL_APPERTAYSEURKK, sovipalkka, pepalkkavteke, 0);
			SIMUL_APPERSOVIEUR = appersovipvt_eikor * (SIMUL_APPERSOVIEURKK / &TTPaivia);
		END;

		/* Soviteltu, korotettu */
		IF apkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_APKORSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 1, 1, lapsimaara, SIMUL_APKORTAYSEURKK, sovipalkka, pepalkkavteke, 0);
			SIMUL_APKORILMSOVI = apkorsovipvt * (SIMUL_APPERSOVIEURKK / &TTPaivia);
			SIMUL_APKORSOVIEUR = apkorsovipvt * (SIMUL_APKORSOVIEURKK / &TTPaivia);
		END;
	END; 

	/* Perusp�iv�raha, HUOM. ei simuloida tarveharkintaa, joka voimassa ennen vuotta 1994 */
	IF pppvt_yht THEN DO;

		/* Perus */
		%PerusPRahaKS(SIMUL_PPPERTAYSEURKK, &LVUOSI, &KUUK, &INF,
					  0, 0, 0, lapsimaara, 0, 0, sosetulot);
		SIMUL_PPPERTAYSEUR = pppertayspvt_eikor * (SIMUL_PPPERTAYSEURKK / &TTPaivia);

		/* Korotettu */
		IF ppkortayspvt OR ppkorsovipvt THEN DO;

			%PerusPRahaKS(SIMUL_PPKORTAYSEURKK, &LVUOSI, &KUUK, &INF,
						  0, 1, 0, lapsimaara, 0, 0, sosetulot);
			SIMUL_PPKORTAYSEUR = ppkortayspvt * (SIMUL_PPKORTAYSEURKK / &TTPaivia);
			SIMUL_PPKORILMTAYS = ppkortayspvt * (SIMUL_PPPERTAYSEURKK / &TTPaivia);
		END;

		/* Soviteltu, perus */
		IF pppersovipvt_eikor OR ppkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_PPPERSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 0, 0, lapsimaara, SIMUL_PPPERTAYSEURKK, sovipalkka, 0, 0);
			SIMUL_PPPERSOVIEUR = pppersovipvt_eikor * (SIMUL_PPPERSOVIEURKK / &TTPaivia);
		END;

		/* Soviteltu, korotettu */
		IF ppkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_PPKORSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 0, 1, lapsimaara, SIMUL_PPKORTAYSEURKK, sovipalkka, 0, 0);
			SIMUL_PPKORSOVIEUR = ppkorsovipvt * (SIMUL_PPKORSOVIEURKK / &TTPaivia);
			SIMUL_PPKORILMSOVI = ppkorsovipvt * (SIMUL_PPPERSOVIEURKK / &TTPaivia);
		END;
	END;

	/* Ty�markkinatuki, HUOM. ei simuloida puolison tulojen tarveharkintaa joka voimassa ennen v.2013 */
	IF tmpvt_yht THEN DO;

		/* Perus */
		%TyomTukiKS(SIMUL_TMPERTAYSEURKK, &LVUOSI, &KUUK, &INF,
				   (ikavu2 < &TarvHarkIka.) or not max(dtyhtep, vvvmkq), tmosvanhtulot, 0, lapsimaara, tmosvanhlapsimaara,
				   tmomattulot, 0, tmosvanhtulot, vanh_omaishoitohp, 0, sosetulot);
		SIMUL_TMPERTAYSEUR = tmpertayspvt_eikor * (SIMUL_TMPERTAYSEURKK / &TTPaivia);  

		/* Korotettu */
		IF tmkortayspvt OR tmkorsovipvt THEN DO;

			%TyomTukiKS(SIMUL_TMKORTAYSEURKK, &LVUOSI, &KUUK, &INF,
					   (ikavu2 < &TarvHarkIka.) or not max(dtyhtep, vvvmkq), tmosvanhtulot, 0, lapsimaara, tmosvanhlapsimaara,
					   tmomattulot, 0, tmosvanhtulot, vanh_omaishoitohp, 1, sosetulot);
			SIMUL_TMKORTAYSEUR = tmkortayspvt * (SIMUL_TMKORTAYSEURKK / &TTPaivia);
			SIMUL_TMKORILMTAYS = tmkortayspvt * (SIMUL_TMPERTAYSEURKK / &TTPaivia);
		END;

		/* Soviteltu, perus */
		IF tmpersovipvt_eikor OR tmkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_TMPERSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 0, 0, lapsimaara, SIMUL_TMPERTAYSEURKK, sovipalkka, 0, 0);
			SIMUL_TMPERSOVIEUR = tmpersovipvt_eikor * (SIMUL_TMPERSOVIEURKK / &TTPaivia);
		END;

		/* Soviteltu, korotettu */
		IF tmkorsovipvt THEN DO;

			%SoviteltuKS(SIMUL_TMKORSOVIEURKK, &LVUOSI, &KUUK, &INF, 
						 0, 1, lapsimaara, SIMUL_TMKORTAYSEURKK, sovipalkka, 0, 0);
			SIMUL_TMKORSOVIEUR = tmkorsovipvt * (SIMUL_TMKORSOVIEURKK / &TTPaivia);
			SIMUL_TMKORILMSOVI = tmkorsovipvt * (SIMUL_TMPERSOVIEURKK / &TTPaivia);
		END;
	END;

/* Summataan karkeammalle tasolle*/
/* Eurot */	
YHTTMTUKI = SUM(SIMUL_TMPERTAYSEUR, SIMUL_TMKORTAYSEUR, SIMUL_TMKORSOVIEUR, SIMUL_TMPERSOVIEUR);
TMTUKILMKOR = SUM(SIMUL_TMPERTAYSEUR, SIMUL_TMKORILMTAYS, SIMUL_TMKORILMSOVI, SIMUL_TMPERSOVIEUR);
PERUSPR = SUM(SIMUL_PPPERTAYSEUR, SIMUL_PPKORTAYSEUR, SIMUL_PPKORSOVIEUR, SIMUL_PPPERSOVIEUR);
PERILMAKOR = SUM(SIMUL_PPPERTAYSEUR, SIMUL_PPKORILMTAYS, SIMUL_PPKORILMSOVI, SIMUL_PPPERSOVIEUR);
ANSIOPR = SUM(SIMUL_APPERTAYSEUR, SIMUL_APKORTAYSEUR, SIMUL_APKORSOVIEUR, SIMUL_APPERSOVIEUR);
ANSIOILMKOR = SUM(SIMUL_APPERTAYSEUR, SIMUL_APKORILMTAYS, SIMUL_APKORILMSOVI, SIMUL_APPERSOVIEUR);

TTURVA_SIMUL = SUM(YHTTMTUKI, PERUSPR, ANSIOPR, IFN(&LVUOSI <= 2024, VUORKORV_DATA, 0));
TTURVA_DATA = SUM(TMTUKI_DATA, PERUSPR_DATA, ANSIOPR_DATA, IFN(&LVUOSI <= 2024, VUORKORV_DATA, 0));

/* P�iv�t */
TMTUKIPV_SIMUL = SUM(TMPERTAYSPVT_EIKOR, TMKORTAYSPVT, TMKORSOVIPVT, TMPERSOVIPVT_EIKOR);
PERUSPRPV_SIMUL = SUM(PPPERTAYSPVT_EIKOR, PPKORTAYSPVT, PPKORSOVIPVT, PPPERSOVIPVT_EIKOR);
ANSIOPRPV_SIMUL = SUM(APPERTAYSPVT_EIKOR, APKORTAYSPVT, APKORSOVIPVT, APPERSOVIPVT_EIKOR);

TTURVA_PV_SIMUL = SUM(TMTUKIPV_SIMUL, PERUSPRPV_SIMUL, ANSIOPRPV_SIMUL);
TTURVA_PV_DATA = SUM(TMTUKIPV_DATA, PERUSPRPV_DATA, ANSIOPRPV_DATA);

/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */
ARRAY PISTE 
TMTUKI_DATA YHTTMTUKI TMTUKILMKOR
PERUSPR_DATA PERUSPR PERILMAKOR ANSIOPR_DATA ANSIOPR ANSIOILMKOR TTURVA_SIMUL TTURVA_DATA
TMTUKIPV_DATA PERUSPRPV_DATA ANSIOPRPV_DATA 
TMTUKIPV_SIMUL PERUSPRPV_SIMUL ANSIOPRPV_SIMUL 
TTURVA_PV_DATA TTURVA_PV_SIMUL
SIMUL_APPERTAYSEUR SIMUL_APKORTAYSEUR SIMUL_APPERSOVIEUR SIMUL_APKORSOVIEUR
SIMUL_PPPERTAYSEUR SIMUL_PPKORTAYSEUR SIMUL_PPPERSOVIEUR SIMUL_PPKORSOVIEUR
SIMUL_TMPERTAYSEUR SIMUL_TMKORTAYSEUR SIMUL_TMPERSOVIEUR SIMUL_TMKORSOVIEUR
VUORKORV_DATA;

DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

LABEL

	SIMUL_APPERTAYSEUR  = "Ansiop�iv�raha, euro, perustaso, KK-MALLI"
	SIMUL_APKORTAYSEUR  = "Ansiop�iv�raha, euro, korotettu, KK-MALLI"
	SIMUL_APPERSOVIEUR  = "Ansiop�iv�raha, euro, soviteltu, KK-MALLI"
	SIMUL_APKORSOVIEUR  = "Ansiop�iv�raha, euro, korotettu soviteltu, KK-MALLI"
	SIMUL_PPPERTAYSEUR  = "Perusp�iv�raha, euro, perustaso, KK-MALLI"
	SIMUL_PPKORTAYSEUR  = "Perusp�iv�raha, euro, korotettu, KK-MALLI"
	SIMUL_PPPERSOVIEUR  = "Perusp�iv�raha, euro, soviteltu, KK-MALLI"
	SIMUL_PPKORSOVIEUR  = "Perusp�iv�raha, euro, korotettu soviteltu, KK-MALLI"
	SIMUL_TMPERTAYSEUR  = "Ty�markkinatuki, euro, perustaso, KK-MALLI"
	SIMUL_TMKORTAYSEUR  = "Ty�markkinatuki, euro, korotettu, KK-MALLI"
	SIMUL_TMPERSOVIEUR	= "Ty�markkinatuki, euro, soviteltu, KK-MALLI"
	SIMUL_TMKORSOVIEUR	= "Ty�markkinatuki, euro, korotettu soviteltu, KK-MALLI"

	YHTTMTUKI			= "Ty�markkinatuki, euro, KK-malli"
	TMTUKILMKOR			= "Ty�markkinatuki ilman korotuksia, euro, KK-malli"
	PERUSPR				= "Perusp�iv�raha, euro, KK-malli"
	PERILMAKOR			= "Perusp�iv�raha ilman korotuksia, euro, KK-malli"
	ANSIOPR				= "Ansiop�iv�raha, euro, KK-malli"
	ANSIOILMKOR 		= "Ansiop�iv�raha ilman korotuksia, euro, KK-malli"

	ANSIOPR_DATA		= "Ansiop�iv�raha, euro, KK-data"
	TMTUKI_DATA			= "Ty�markkinatuki, euro, KK-data"
	PERUSPR_DATA		= "Perusp�iv�raha, euro, KK-data"
	VUORKORV_DATA		= "Vuorottelukorvaukset, euro, KK-data"

	TTURVA_SIMUL		= "Ty�tt�myysturva yhteens�, euro, simuloitu"
	TTURVA_DATA			= "Ty�tt�myysturva yhteens�, euro, data"

	TMTUKIPV_SIMUL		= "Ty�markkinatukip�iv�t, KK-malli"
	PERUSPRPV_SIMUL		= "Perusp�iv�rahap�iv�t, KK-malli"
	ANSIOPRPV_SIMUL		= "Ansiop�iv�rahap�iv�t, KK-malli"
	ANSIOPRPV_DATA		= "Ansiop�iv�rahap�iv�t, KK-data"
	TMTUKIPV_DATA		= "Ty�markkinatukip�iv�t, KK-data"
	PERUSPRPV_DATA		= "Perusp�iv�rahap�iv�t, KK-data"

	TTURVA_PV_SIMUL		= "Ty�tt�myysturvap�iv�t yhteens�, simuloitu"
	TTURVA_PV_DATA		= "Ty�tt�myysturvap�iv�t yhteens�, data";

RUN;

/* Summataan vuositasolle */
PROC SUMMARY DATA = TEMP.&TULOSNIMI_TT._KK NWAY;
	CLASS hnro;
	ID &PAINO;
	VAR YHTTMTUKI TMTUKILMKOR PERILMAKOR PERUSPR ANSIOPR ANSIOILMKOR ANSIOPR_DATA
		TMTUKI_DATA PERUSPR_DATA TTURVA_SIMUL TTURVA_DATA
		TMTUKIPV_SIMUL PERUSPRPV_SIMUL ANSIOPRPV_SIMUL
		TMTUKIPV_DATA PERUSPRPV_DATA ANSIOPRPV_DATA
		TTURVA_PV_SIMUL TTURVA_PV_DATA
		VUORKORV_DATA;
	OUTPUT OUT = TEMP.&TULOSNIMI_TT. (DROP = _:) SUM = ;
RUN;

%IF &START NE 1 %THEN %DO;

	/* Tallennetaan kk-tason mikrodata outputiin */		
	DATA OUTPUT.&TULOSNIMI_TT._HLO_KK;
	SET TEMP.&TULOSNIMI_TT._KK;
	RUN;

	/* Yhdistet��n tulokset vuositason pohja-aineistoon */
	DATA TEMP.&TULOSNIMI_TT;
		
	/* 3.2.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */
	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.REK&AVUOSI 
		(KEEP = hnro knro &PAINO ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_TT;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki vuosiaineiston muuttujat) */
	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.REK&AVUOSI TEMP.&TULOSNIMI_TT;
	%END;

	BY hnro;
	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_TT._KOTI, TEMP.&TULOSNIMI_TT, &MALLI, &MUUTTUJAT);
		RUN;

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

%MEND TTurva_kk_Simuloi;

%TTurva_kk_Simuloi;

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