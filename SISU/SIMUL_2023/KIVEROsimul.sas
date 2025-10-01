/*************************************************************
*  Kuvaus: Kiinteist�verotuksen simulointimalli			     *
* ***********************************************************/

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = KIVERO;

%LET TYYPPI = SIMUL;	

%LET alkoi1&malli = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, k�ytet��n siell� m��riteltyj� ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, k�ytet��n alla sy�tettyj� ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;
	
	%LET AVUOSI = 2023;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2023;		* Lains��d�nt�vuosi (vvvv);

	%LET AINEISTO = REK; 	* K�ytett�v� aineisto;

	%LET TULOSNIMI_KV = kivero_simul_&SYSDATE._1;  * Simuloidun tulostiedoston nimi;

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

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;	* Lakimakrotiedoston nimi;
	%LET PKIVERO = pkivero; * K�ytett�v�n parametritiedoston nimi;
		
	/* Tulostaulukoiden esivalinnat */

	%LET TULOSLAAJ = 1; 	* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat));
	%LET MUUTTUJAT = VALOPULLINENPT valopullinenptd VALOPULLINENVA valopullinenvad VALOLLINENTAL valopullinentald
					 RAK_KVEROPT rak_kveroptd RAK_KVEROVA rak_kverovad RAK_KVEROTAL rak_kverotald
					 verotusarvo KVTONTTIS kvtontti 
					 ASOYKIVERO VERARVODATA omakkiiv KIVEDATA KIVEROYHT2 KIVEROYHT;		* Taulukoitavat muuttujat (summataulukot);
	%LET YKSIKKO = 2;		* Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous);
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

	%LET EXCEL = 0; 		* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei);

	/* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	* N eli lukum��r�t;
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

	%LET PAINO = ykor; 	* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana);
	%LET RAJAUS = ; 	* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia);

	%END;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

	%LET KIVERO_AINEISTO = KIVE_&AINEISTO&AVUOSI; 	* K�ytett�v� kiinteist�verorekisterin aineisto (aina KIVE_&AINEISTO&AVUOSI);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KV..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KiVero_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 M��ritell��n tarvittavat muuttujat taulukoihin START_KIVERO_REK ja START_KIVERO_ASOY */

	/* Kiinteist�veroaineiston muuttujat */

	DATA STARTDAT.START_KIVERO_REK;
	SET POHJADAT.&KIVERO_AINEISTO
	(KEEP = hnro raktyyppi kvkayttokoodi valmispvm ikavuosi 
	kantarakenne rakennuspa kellaripa vesik lammitysk sahkok 
	talviask viemarik wck saunak verotusarvo valopullinen rak_kvero
	kiintpros veropros kvtontti jhvalarvokoodi omosoittaja omnimittaja kuntanro valmiusaste kuistipa 
	Rakennus_on_autokatos Lampoeristys);

	/* Lis�t��n aineistoon apumuuttujaksi omistusosuus kiinteist�st� */

	IF omnimittaja = 0 THEN omnimittaja = 1;

	OMOSUUS = omosoittaja / SUM(omnimittaja);

	LABEL 	
	OMOSUUS = 'Omistusosuus, DATA';

	/* M��ritell��n verotusarvo ja kiinteist�vero eri rakennustyypeille
	ja luodaan niille summamuuttujat */

	IF raktyyppi = 1 THEN valopullinenptd = valopullinen;
	IF raktyyppi = 7 THEN valopullinenvad = valopullinen;
	IF raktyyppi in (8, 9) THEN valopullinentald = valopullinen;

	IF raktyyppi = 1 THEN rak_kveroptd = rak_kvero;
	IF raktyyppi = 7 THEN rak_kverovad = rak_kvero;
	IF raktyyppi in (8, 9) THEN rak_kverotald = rak_kvero;
	
	VERARVODATA = SUM(valopullinen, verotusarvo);
	KIVEDATA = SUM(rak_kvero, kvtontti);

	/* Lasketaan datan arvot uudelleen henkil�iden omistusosuuksien suhteen */

	valopullinen = valopullinen * OMOSUUS;
	valopullinenptd = valopullinenptd * OMOSUUS;
	valopullinenvad = valopullinenvad * OMOSUUS;
	valopullinentald = valopullinentald * OMOSUUS;
	rak_kvero = rak_kvero * OMOSUUS;
	rak_kveroptd = rak_kveroptd * OMOSUUS; 
	rak_kverovad = rak_kverovad * OMOSUUS;
	rak_kverotald = rak_kverotald * OMOSUUS;
	verotusarvo = verotusarvo * OMOSUUS;
	kvtontti = kvtontti * OMOSUUS; 
	VERARVODATA = VERARVODATA * OMOSUUS; 
	KIVEDATA = KIVEDATA * OMOSUUS;


	/* Luodaan datan muuttujille selitteet */

	LABEL
	valopullinen = 'Rakennusten verotusarvo yhteens�, DATA'
	valopullinenptd = 'Pientalojen verotusarvo, DATA'
	valopullinenvad = 'Vapaa-ajan asuntojen verotusarvo, DATA'
	valopullinentald = 'Talousrakennusten verotusarvo, DATA'
	rak_kvero = 'Rakennusten kiinteist�vero yhteens� (e/v), DATA'
	rak_kveroptd = 'Pientalojen kiinteist�vero (e/v), DATA'
	rak_kverovad = 'Vapaa-ajan asuntojen kiinteist�vero (e/v), DATA'
	rak_kverotald = 'Talousrakennusten kiinteist�vero (e/v), DATA'
	verotusarvo = 'Maapohjan verotusarvo, DATA'
	kvtontti = 'Maapohjan kiinteist�vero (e/v), DATA'
	VERARVODATA = 'Verotusarvo (pl. asoy) yhteens� (e/v), DATA'
	KIVEDATA = 'Kiinteist�verot (pl. asoy) yhteens� (e/v) (kiinteist�verorek.), DATA';

	RUN;

	/* Pohja-aineiston muuttujat (k�ytet��n asunto-osakeyhti�iden kiinteist�veron laskentaan) */

	DATA STARTDAT.START_KIVERO_ASOY;
	SET POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro aslaji talotyyp rakvuosi 
	hoitvast omakkiiv);
	RUN;

	/* Lis�t��n aineistoon apumuuttujaksi rakennuksen valmistumisvuosi */

	DATA STARTDAT.START_KIVERO_REK; 
	SET STARTDAT.START_KIVERO_REK;

	IF LENGTH(valmispvm) = 4 THEN VALMVUOSI = valmispvm;
	IF LENGTH(valmispvm) = 10 THEN VALMVUOSI = substr(valmispvm, 7, 4);

	LABEL 	
	VALMVUOSI = 'Rakennuksen valmistumisvuosi, DATA';

	RUN;

%END;

%MEND KiVero_Muutt_Poiminta;

%KiVero_Muutt_Poiminta;

/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

%MACRO KiVero_Simuloi_Data;

/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL KIVERO_PARAM KIVERO_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(KIVERO_PARAM, KIVERO);
%HaeLaskettavatLokaalit(KIVERO_MUUNNOS, KIVERO);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KIVERO_PARAM;

/* KIVERO-mallissa (vuositason lains��d�nt�) parametrit luetaan makromuuttujiksi ennen simulontia */
%HaeParamSimul(&LVUOSI, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInfSimul(&LVUOSI, 1, &KIVERO_MUUNNOS, &INF);

DATA TEMP.KIVERO_REK;
SET STARTDAT.START_KIVERO_REK;

/* 3.1 Lasketaan ensin kiinteist�verorekisterin tiedot */

/* Lasketaan pientalon verotusarvo */
%PtVerotusArvoS(VALOPULLINENPT, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, 
	rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, valmiusaste, valopullinen);

/* Lasketaan pientalon kiinteist�vero */
%KiVeroPtS(RAK_KVEROPT, &LVUOSI, &INF, raktyyppi, veropros, VALOPULLINENPT);

/* Lasketaan vapaa-ajan asunnon verotusarvo */
%VapVerotusArvoS(VALOPULLINENVA, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, 
	rakennuspa, talviask, kuistipa, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi, valmiusaste, valopullinen);

/* Lasketaan vapaa-ajan asunnon kiinteist�vero */
%KiVeroVapS(RAK_KVEROVA, &LVUOSI, &INF, raktyyppi, veropros, VALOPULLINENVA);

/* Lasketaan talousrakennuksen verotusarvo */
%TalVerotusArvoS(VALOLLINENTAL, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, 
	rakennuspa, Rakennus_on_autokatos, lampoeristys, jhvalarvokoodi, valmiusaste, valopullinen);

/* Lasketaan talousrakennuksen kiinteist�vero */
%KiVeroTalS(RAK_KVEROTAL, &LVUOSI, &INF, raktyyppi, veropros, VALOLLINENTAL);

/* Lasketaan kiinteist�vero maapohjasta */
%KiVeroMaaS(KVTONTTIS, &LVUOSI, &INF, verotusarvo, kiintpros, kuntanro);

/* Lasketaan verotusarvo ja kiinteist�vero omistusosuuden suhteen */

VALOPULLINENPT = VALOPULLINENPT * OMOSUUS;
RAK_KVEROPT = RAK_KVEROPT * OMOSUUS;
VALOPULLINENVA = VALOPULLINENVA * OMOSUUS;
RAK_KVEROVA = RAK_KVEROVA * OMOSUUS;
VALOLLINENTAL = VALOLLINENTAL * OMOSUUS;
RAK_KVEROTAL = RAK_KVEROTAL * OMOSUUS;

/* Luodaan tulosmuuttujille selitteet */

LABEL
VALOPULLINENPT = 'Pientalojen verotusarvo, MALLI'
RAK_KVEROPT = 'Pientalojen kiinteist�vero (e/v), MALLI'
VALOPULLINENVA = 'Vapaa-ajan asuntojen verotusarvo, MALLI'
RAK_KVEROVA = 'Vapaa-ajan asuntojen kiinteist�vero (e/v), MALLI'
VALOLLINENTAL = 'Talousrakennusten verotusarvo, MALLI'
RAK_KVEROTAL = 'Talousrakennusten kiinteist�vero (e/v), MALLI'
KVTONTTIS = 'Maapohjan kiinteist�vero (e/v), MALLI';
RUN;

/* 3.2 Lasketaan kiinteist�vero asunto-osakeyhti�iss� pohja-aineiston perusteella */

DATA TEMP.KIVERO_ASOY;
SET STARTDAT.START_KIVERO_ASOY (KEEP = hnro knro aslaji talotyyp rakvuosi hoitvast omakkiiv);

/* 	M��ritell��n kiinteist�veron osuus hoitovastikkeista aineistovuoden "Asunto-osakeyhti�iden talous" -raportista
	ja eritell��n kerrostalo- ja rivitaloyhti�ihin asunnon i�n mukaan. Kiinteist�veron osuus jaetaan kohtien 
	3001, 3002, 3003, 3004 ja 3021 summalla. */

IF aslaji = 3 and talotyyp = 3 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0823;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0709;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0742;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0777;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0714;
	IF (2000 LE rakvuosi LT 2010) THEN HOITOSUUS = 0.0931;
	IF rakvuosi GE 2010 THEN HOITOSUUS = 0.1004;
END;
 
IF aslaji = 3 and talotyyp LT 3 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0645;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0597;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0622;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0687;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0744;
	IF (2000 LE rakvuosi LT 2010) THEN HOITOSUUS = 0.0883;
	IF rakvuosi GE 2010 THEN HOITOSUUS = 0.0959;
END;

ASOYKIVERO = (hoitvast * HOITOSUUS) * 12;

LABEL
HOITOSUUS = 'Kiinteist�veron osuus hoitovastikkeesta (%), MALLI'
ASOYKIVERO = 'Kiinteist�vero asunto-osakeyhti�ss� (e/v), MALLI';

RUN;

/* 3.3 Summataan kiinteist�veroaineisto henkil�tasolle, yhdistet��n tulokset pohja-aineistoon 
	ja lasketaan kiinteist�vero yhteens� */

PROC SUMMARY DATA = TEMP.KIVERO_REK ;
VAR VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA KVTONTTIS verotusarvo kvtontti  
    valopullinenptd valopullinenvad valopullinentald VALOLLINENTAL 
	rak_kveroptd rak_kverovad rak_kverotald RAK_KVEROTAL KIVEDATA VERARVODATA ;
BY hnro;
OUTPUT OUT = TEMP.KIVERO_SUMMAT (DROP = _TYPE_ _FREQ_) SUM=;
RUN;

DATA TEMP.&TULOSNIMI_KV;
MERGE TEMP.KIVERO_ASOY TEMP.KIVERO_SUMMAT;
BY hnro;

/*Lasketaan kiinteist�vero yhteens�, ilman asunto-osakeyhti�t�. */
KIVEROYHT2 = SUM(RAK_KVEROPT, RAK_KVEROVA, RAK_KVEROTAL, KVTONTTIS);

/*Pienimm�n m��r�tt�v�n veron alittavat kiinteist�verot nollataan. */
%KiMinimi(KIVEROYHT2, &LVUOSI, &INF, KIVEROYHT2);

/* Nollataan osamuuttujat mik�li verotuksen kokonaissumma on nollattu. */
IF KIVEROYHT2 = 0 THEN DO; 
	RAK_KVEROPT = 0;
	RAK_KVEROVA = 0; 
	RAK_KVEROTAL = 0;
	KVTONTTIS = 0; 
END;

/*Lasketaan kiinteist�vero yhteens� asunto-osakeyhti�t mukaan lukien.*/ 	
KIVEROYHT = SUM(RAK_KVEROPT, RAK_KVEROVA, RAK_KVEROTAL, KVTONTTIS, ASOYKIVERO);

LABEL
KIVEROYHT = 'Kiinteist�verot (ml. asoy) yhteens� (e/v), MALLI'
KIVEROYHT2 = 'Kiinteist�verot (pl. asoy) yhteens� (e/v), MALLI';

/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */

ARRAY PISTE 
	 VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA VALOLLINENTAL RAK_KVEROTAL KVTONTTIS ASOYKIVERO KIVEROYHT KIVEROYHT2
	 valopullinenptd valopullinenvad valopullinentald rak_kveroptd rak_kverovad rak_kverotald
	 verotusarvo kvtontti omakkiiv KIVEDATA VERARVODATA
 ;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

LABEL 
omakkiiv = 'Kiinteist�verot (pl. asoy) yhteens� (e/v) (pohja-aineisto), DATA';

RUN;

/* 3.4 Luodaan tulostiedosto OUTPUT-kansioon */

/* T�t� vaihetta ei ajeta mik�li osamallia k�ytet��n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet��n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_KV;

	/* 3.4.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO;
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO ikavu ikavuv soss paasoss desmod koulas koulasv elivtu rake maakunta)
		TEMP.&TULOSNIMI_KV;
	%END;

	/* 3.4.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO;
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_KV;
	%END;

	BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_KV._KOTI, TEMP.&TULOSNIMI_KV, &MALLI,&MUUTTUJAT);
		
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KV;
		RUN;
		QUIT;
	%END;

	/* Jos k�ytt�j� m��ritellyt YKSIKKO=1 (henkil�taso) tai YKSIKKO on mit� tahansa muuta kuin 2 (kotitaloustaso)
		niin j�tet��n tulostaulu henkil�tasolle ja nimet��n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KV._HLO;
			CHANGE &TULOSNIMI_KV=&TULOSNIMI_KV._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_KV._HLO;
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

%MEND KiVero_Simuloi_data;

%KiVero_Simuloi_data;

%LET loppui2&malli = %SYSFUNC(TIME());

/* 4. Tulostetaan k�ytt�j�n pyyt�m�t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KV._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KV._KOTI,2);
	%END;

	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START^=1 and &EG = 1 %THEN %DO;
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