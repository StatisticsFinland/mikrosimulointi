/*******************************************************************
*  Kuvaus: Sairausvakuutuksen p�iv�rahojen simuloimalli		       *
*******************************************************************/

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = SAIRVAK;

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

	%LET AVUOSI = 2023;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2023;		* Lains��d�nt�vuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_SV = sairvak_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	%LET SDATATULO = 0;  * K�ytet��nk� SAIRVAK-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0. 
					       Jos 1, niin k�ytet��n datan tulotietoja TULOSRT_PALKVAH ja TULOPRT_PALKVAH, muuten
			               k�ytet��n k��nteisfunktiolla m��riteltyj� tulotietoja. ;

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

	%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* SAIRVAK-mallin lakimakrotiedoston nimi ;
	%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* TTURVA-mallin lakimakrotiedoston nimi ;	
	%LET PSAIRVAK = psairvak; * K�ytett�v�n SAIRVAK-mallin parametritiedoston nimi ;
	%LET PTTURVA = ptturva; * K�ytett�v�n TTURVA-mallin parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT = saiprva SAIRPR aiprva VANHPR vkpmkyt SAIRPR_TYONANT vkamkyt VANHPR_TYONANT cdmky ERITHOITR; * Taulukoitavat muuttujat (summataulukot) ;
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

	%LET EXCEL = 0; 		 * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

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

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */
%MACRO SairVak_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 M��ritell��n tarvittavat palveluaineiston muuttujat taulukkoon START_SAIRVAK */

	DATA STARTDAT.START_SAIRVAK;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro vkppv vkppvt TULOSRT_PALKVAH TULOPRT_PALKVAH aiprva saiprva vkpmkyt vkamkyt cdmky cdpv
	muuperu aivpvkt aivpvt2 aivpvk aivpv2 aivpv1 aivpvt1

	SAIR_PVX SAIR_PER_PV VANH_PER_PV SAIR_TULO VANH_TULO SAIR_PV_TYONANT
	VANH_PV_TYONANT SAIRTULO_TYONANT VANHTULO_TYONANT ERITHOIT_PER_PV ERITHOIT_TULO ANSPALKKA);

	WHERE vkppv > 0 OR vkppvt > 0 OR TULOSRT_PALKVAH > 0 OR TULOPRT_PALKVAH > 0 OR aiprva > 0
	OR saiprva > 0 OR vkamkyt > 0 OR cdmky > 0 OR cdpv > 0;


	LABEL 
	SAIR_PVX = 'Vakuutetun sairausp�iv�rahap�iv�t, DATA'
	SAIR_PER_PV = 'Vakuutetun sairausp�iv�rahat p�iv�� kohden, DATA'
	VANH_PER_PV = 'Vakuutetun vanhempainp�iv�rahat p�iv�� kohden, DATA'
	SAIR_TULO = 'Laskennallinen vakuutetun sairausp�iv�rahan perusteena oleva tulo (e/v), DATA'
	VANH_TULO = 'Laskennallinen vakuutetun vanhemnpainp�iv�rahan perusteena oleva tulo (e/v), DATA'
	SAIR_PV_TYONANT = 'Ty�nantajalle maksettu sairausp�iv�raha p�iv�� kohden, DATA'
	VANH_PV_TYONANT = 'Ty�nantajalle maksettu vanhempainp�iv�raha p�iv�� kohden, DATA'
	SAIRTULO_TYONANT = 'Laskennallinen ty�nantajalle maksettavan sairausp�iv�rahan perusteena oleva tulo (e/v), DATA'
	VANHTULO_TYONANT = 'Laskennallinen ty�nantajalle maksettavanvanhemnpainp�iv�rahan perusteena oleva tulo (e/v), DATA'
	ERITHOIT_PER_PV = 'Erityishoitoraha p�iv�� kohden, DATA'
	ERITHOIT_TULO = 'Erityishoitorahan perusteena oleva tulo (e/kk), DATA'
	ANSPALKKA = 'Johdettu palkka, kun p�iv�rahan oletetaan perustuvan ty�tt�myysturvaan, DATA';

	RUN;
	
%END;

%MEND SairVak_Muut_Poiminta;

%SairVak_Muut_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

%MACRO SairVak_Simuloi_Data;

/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL SAIRVAK_PARAM SAIRVAK_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(SAIRVAK_PARAM, SAIRVAK);
%HaeLaskettavatLokaalit(SAIRVAK_MUUNNOS, SAIRVAK);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &SAIRVAK_PARAM;

/* TTURVA-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */
%KuukSimul(SAIRVAK);
%KuukSimul(TTURVA);

/* Varsinainen simulointivaihe */

DATA TEMP.&TULOSNIMI_SV;
SET STARTDAT.START_SAIRVAK;

/* 3.1 P�iv�rahojen simulointi */

/* 3.1.1 Sairausp�iv�rahat */

/* Simulointi laskennallisilla tulotiedoilla */
IF &SDATATULO NE 1 OR TULOSRT_PALKVAH = 0 THEN DO;
	%SairVakPRahaVS(SAIRPR, &LVUOSI, &INF, 0, 0, SAIR_TULO);
	%SairVakPRahaVS(SAIRPR_TYONANT, &LVUOSI, &INF, 0, 0, SAIRTULO_TYONANT);
END;

/* Vaihtoehtoisesti simulointi datan tulotiedoilla */
ELSE DO;
	%SairVakPRahaVS(SAIRPR, &LVUOSI, &INF, 0, 0, TULOSRT_PALKVAH);
	%SairVakPRahaVS(SAIRPR_TYONANT, &LVUOSI, &INF, 0, 0, TULOSRT_PALKVAH);
END;

SAIRPR = SAIR_PVX * SAIRPR / &SPaivat;
SAIRPR_TYONANT = vkppvt * SAIRPR_TYONANT / &SPaivat;

/* 3.1.2 Vanhempainp�iv�rahat */

/* Simulointi laskennallisilla tulotiedoilla */
IF &SDATATULO NE 1 OR TULOPRT_PALKVAH = 0 THEN DO;
	/* Vakuutetulle maksetut */
	%VanhPRahaVS(AIT_VANH, &LVUOSI, &INF, 1, 0, 0, 0, VANH_TULO);
	%VanhPRahaVS(KOR_VANH, &LVUOSI, &INF, 0, 1, 0, 0, VANH_TULO);
	%VanhPRahaVS(NORMVANH, &LVUOSI, &INF, 0, 0, 1, 0, VANH_TULO);
	/* Ty�nantajalle maksetut */
	%VanhPRahaVS(AIT_VANH_TYONANT, &LVUOSI, &INF, 1, 0, 0, 0, VANHTULO_TYONANT);
	%VanhPRahaVS(KOR_VANH_TYONANT, &LVUOSI, &INF, 0, 1, 0, 0, VANHTULO_TYONANT);
	%VanhPRahaVS(NORMVANH_TYONANT, &LVUOSI, &INF, 0, 0, 1, 0, VANHTULO_TYONANT);
END;

/* Vaihtoehtoisesti simulointi datan tulotiedoilla */
ELSE DO;
	/* Vakuutetulle maksetut */
	%VanhPRahaVS(AIT_VANH, &LVUOSI, &INF, 1, 0, 0, 0, TULOPRT_PALKVAH);
	%VanhPRahaVS(KOR_VANH, &LVUOSI, &INF, 0, 1, 0, 0, TULOPRT_PALKVAH);
	%VanhPRahaVS(NORMVANH, &LVUOSI, &INF, 0, 0, 1, 0, TULOPRT_PALKVAH);
	/* Ty�nantajalle maksetut */
	%VanhPRahaVS(AIT_VANH_TYONANT, &LVUOSI, &INF, 1, 0, 0, 0, TULOPRT_PALKVAH);
	%VanhPRahaVS(KOR_VANH_TYONANT, &LVUOSI, &INF, 0, 1, 0, 0, TULOPRT_PALKVAH);
	%VanhPRahaVS(NORMVANH_TYONANT, &LVUOSI, &INF, 0, 0, 1, 0, TULOPRT_PALKVAH);
END;


/* Kerrotaan p�ivill� */

AIT_VANH = aivpvk * AIT_VANH;
KOR_VANH = aivpv1 * KOR_VANH;
NORMVANH = aivpv2 * NORMVANH;
AIT_VANH_TYONANT = aivpvkt * AIT_VANH_TYONANT;
KOR_VANH_TYONANT = aivpvt1 * KOR_VANH_TYONANT;
NORMVANH_TYONANT =  aivpvt2 * NORMVANH_TYONANT;

/* 3.1.3 Erityishoitoraha */

IF cdpv > 0 THEN DO;
	%VanhPRahaVS(ERITHOITR, &LVUOSI, &INF, 0, 0, 1, 0, ERITHOIT_TULO);
	ERITHOITR = cdpv * ERITHOITR;
END;

VANHPR = SUM(NORMVANH, AIT_VANH, KOR_VANH);


/* Jos vanhempainp�iv�raha perustuu ty�tt�myysturvaan (muuperu = "TT"), 
   johdetaan p�iv�raha ty�tt�myysp�iv�rahasta k�ytt�m�ll� apumuuttujaa ANSPALKKA.
   Huom! T�m� sivuuttaa mahdollisesti aikaisemmin lasketut muuttujat NORMVANH, AIT_VANH ja KOR_VANH */

IF muuperu = "TT" THEN DO;
	%AnsioSidVS(ANSIOSID, &LVUOSI, &INF, 0, 0, 0, 0, ANSPALKKA, 0, 0, 0);
	VANHPR = SUM(aivpv1, aivpv2, aivpvk) * ANSIOSID / &SPaivat;
END;

VANHPR_TYONANT = SUM(NORMVANH_TYONANT, KOR_VANH_TYONANT, AIT_VANH_TYONANT);

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

ARRAY PISTE 
	saiprva SAIRPR aiprva VANHPR
	vkpmkyt SAIRPR_TYONANT vkamkyt
	VANHPR_TYONANT cdmky ERITHOITR
	AIT_VANH KOR_VANH NORMVANH AIT_VANH_TYONANT KOR_VANH_TYONANT NORMVANH_TYONANT;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 
SAIRPR = 'Vakuutetuille maksetut sairausp�iv�rahat, MALLI'
VANHPR = 'Vakuutetuille maksetut vanhempainp�iv�rahat, MALLI'
AIT_VANH = 'Vakuutetuille maksetut korotetut �itiys-/raskausrahap�iv�rahat, MALLI'
KOR_VANH = 'Vakuutetuille maksetut korotetut vanhempainp�iv�rahat, MALLI'
NORMVANH = 'Vakuutetuille maksetut korottamattomat vanhempainp�iv�rahat, MALLI'
SAIRPR_TYONANT = 'Ty�nantajille maksetut sairausp�iv�rahat, MALLI'
VANHPR_TYONANT = 'Ty�nantajille maksetut vanhempainp�iv�rahat, MALLI'
AIT_VANH_TYONANT = 'Ty�nantajille maksetut korotetut �itiys-/raskausrahap�iv�rahat, MALLI'
KOR_VANH_TYONANT = 'Ty�nantajille maksetut korotetut vanhempainp�iv�rahat, MALLI'
NORMVANH_TYONANT = 'Ty�nantajille maksetut korottamattomat vanhempainp�iv�rahat, MALLI'
ERITHOITR = 'Erityishoitorahat, MALLI';

KEEP hnro SAIRPR VANHPR SAIRPR_TYONANT VANHPR_TYONANT ERITHOITR
	AIT_VANH KOR_VANH NORMVANH AIT_VANH_TYONANT KOR_VANH_TYONANT NORMVANH_TYONANT ;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T�t� vaihetta ei ajeta mik�li osamallia k�ytet��n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet��n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_SV;
		
	/* 3.2.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO saiprva aiprva vkpmkyt vkamkyt cdmky ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_SV;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_SV;
	%END;

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

	ARRAY PISTE 
		saiprva aiprva vkpmkyt vkamkyt cdmky;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	saiprva = 'Vakuutetuille maksetut sairausp�iv�rahat, DATA'
	aiprva = 'Vakuutetuille maksetut vanhempainp�iv�rahat, DATA'
	vkpmkyt = 'Ty�nantajille maksetut sairausp�iv�rahat, DATA'
	vkamkyt = 'Ty�nantajille maksetut vanhempainp�iv�rahat, DATA'
	cdmky = 'Erityishoitorahat, DATA';

	BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_SV._KOTI, TEMP.&TULOSNIMI_SV, &MALLI, &MUUTTUJAT);

		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_SV;
		RUN;
		QUIT;

	%END;

	/* Jos k�ytt�j� m��ritellyt YKSIKKO=1 (henkil�taso) tai YKSIKKO on mit� tahansa muuta kuin 2 (kotitaloustaso)
		niin j�tet��n tulostaulu henkil�tasolle ja nimet��n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_SV._HLO;
			CHANGE &TULOSNIMI_SV=&TULOSNIMI_SV._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_SV._HLO;
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

%MEND SairVak_Simuloi_Data;

%SairVak_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Tulostetaan k�ytt�j�n pyyt�m�t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_SV._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_SV._KOTI,2);
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
