/*************************************************************
*  Kuvaus: Kiinteistöverotuksen simulointimalli	2018	     * 
*  Viimeksi päivitetty: 10.1.2021			 				 * 
* ***********************************************************/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = KIVERO;

%LET TYYPPI = SIMUL;	

%LET alkoi1&malli = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, käytetään siellä määriteltyjä ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, käytetään alla syötettyjä ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;
	
	%LET AVUOSI = 2018;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2018;		* Lainsäädäntövuosi (vvvv);

	%LET AINEISTO = REK; 	* Käytettävä aineisto;

	%LET TULOSNIMI_KV = kivero_simul_&SYSDATE._1;  * Simuloidun tulostiedoston nimi;

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

	/* Ajettavat osavaiheet */

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;	* Lakimakrotiedoston nimi;
	%LET PKIVERO = pkivero; * Käytettävän parametritiedoston nimi;
		
	/* Tulostaulukoiden esivalinnat */

	%LET TULOSLAAJ = 1; 	* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat));
	%LET MUUTTUJAT = VALOPULLINENPT valopullinenptd VALOPULLINENVA valopullinenvad 
					 RAK_KVEROPT rak_kveroptd RAK_KVEROVA rak_kverovad
					 verotusarvo KVTONTTIS kvtontti 
					 ASOYKIVERO VERARVODATA omakkiiv KIVEDATA KIVEROYHT2 KIVEROYHT; 	* Taulukoitavat muuttujat (summataulukot);
	%LET YKSIKKO = 2;		* Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous);
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

	%LET EXCEL = 0; 		* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei);

	/* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	* N eli lukumäärät;
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

	%LET PAINO = ykor; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana);
	%LET RAJAUS = ; 	* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

	%END;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

	%LET KIVERO_AINEISTO = KIVE_&AINEISTO&AVUOSI; 	* Käytettävä kiinteistöverorekisterin aineisto (aina KIVE_&AINEISTO&AVUOSI);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KV..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KiVero_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 Määritellään tarvittavat muuttujat taulukoihin START_KIVERO_REK ja START_KIVERO_ASOY */

	/* Kiinteistöveroaineiston muuttujat */

	DATA STARTDAT.START_KIVERO_REK;
	SET POHJADAT.&KIVERO_AINEISTO
	(KEEP = hnro raktyyppi kvkayttokoodi valmispvm ikavuosi 
	kantarakenne rakennuspa kellaripa vesik lammitysk sahkok 
	talviask viemarik wck saunak verotusarvo valopullinen rak_kvero
	kiintpros veropros kvtontti jhvalarvokoodi omosoittaja omnimittaja);

	/* Lisätään aineistoon apumuuttujaksi omistusosuus kiinteistöstä */

	IF omnimittaja = 0 THEN omnimittaja = 1;

	OMOSUUS = omosoittaja / SUM(omnimittaja);

	LABEL 	
	OMOSUUS = 'Omistusosuus, DATA';

	/* Määritellään verotusarvo ja kiinteistövero eri rakennustyypeille
	ja luodaan niille summamuuttujat */

	IF raktyyppi = 1 THEN valopullinenptd = valopullinen;
	IF raktyyppi = 7 THEN valopullinenvad = valopullinen;

	IF raktyyppi = 1 THEN rak_kveroptd = rak_kvero;
	IF raktyyppi = 7 THEN rak_kverovad = rak_kvero;
	
	KIVEDATA = SUM(rak_kveroptd, rak_kverovad, kvtontti);
	VERARVODATA = SUM(valopullinenptd, valopullinenvad, verotusarvo);

	/* Lasketaan datan arvot uudelleen henkilöiden omistusosuuksien suhteen */

	valopullinen = valopullinen * OMOSUUS;
	valopullinenptd = valopullinenptd * OMOSUUS;
	valopullinenvad = valopullinenvad * OMOSUUS;
	rak_kvero = rak_kvero * OMOSUUS;
	rak_kveroptd = rak_kveroptd * OMOSUUS; 
	rak_kverovad = rak_kverovad * OMOSUUS;
	verotusarvo = verotusarvo * OMOSUUS;
	kvtontti = kvtontti * OMOSUUS; 
	VERARVODATA = VERARVODATA * OMOSUUS; 
	KIVEDATA = KIVEDATA * OMOSUUS;

	/* Luodaan datan muuttujille selitteet */

	LABEL
	valopullinen = 'Rakennusten verotusarvo yhteensä, DATA'
	valopullinenptd = 'Pientalojen verotusarvo, DATA'
	valopullinenvad = 'Vapaa-ajan asuntojen verotusarvo, DATA'
	rak_kvero = 'Rakennusten kiinteistövero yhteensä (e/v), DATA'
	rak_kveroptd = 'Pientalojen kiinteistövero (e/v), DATA'
	rak_kverovad = 'Vapaa-ajan asuntojen kiinteistövero (e/v), DATA'
	verotusarvo = 'Maapohjan verotusarvo, DATA'
	kvtontti = 'Maapohjan kiinteistövero (e/v), DATA'
	VERARVODATA = 'Verotusarvo (pl. asoy) yhteensä (e/v), DATA'
	KIVEDATA = 'Kiinteistöverot (pl. asoy) yhteensä (e/v) (kiinteistöverorek.), DATA';

	RUN;

	/* Pohja-aineiston muuttujat (käytetään asunto-osakeyhtiöiden kiinteistöveron laskentaan) */

	DATA STARTDAT.START_KIVERO_ASOY;
	SET POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro aslaji talotyyp rakvuosi 
	hoitvast omakkiiv);
	RUN;

	/* Lisätään aineistoon apumuuttujaksi rakennuksen valmistumisvuosi */

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

/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL KIVERO_PARAM KIVERO_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(KIVERO_PARAM, KIVERO);
%HaeLaskettavatLokaalit(KIVERO_MUUNNOS, KIVERO);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KIVERO_PARAM;

/* KIVERO-mallissa (vuositason lainsäädäntö) parametrit luetaan makromuuttujiksi ennen simulontia */
%HaeParamSimul(&LVUOSI, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInfSimul(&LVUOSI, 1, &KIVERO_MUUNNOS, &INF);

DATA TEMP.KIVERO_REK;
SET STARTDAT.START_KIVERO_REK;

/* 3.1 Lasketaan ensin kiinteistöverorekisterin tiedot */

/* Lasketaan pientalon verotusarvo */
%PtVerotusArvoS(VALOPULLINENPT, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi);

/* Lasketaan pientalon kiinteistövero */

%KiVeroPtS(RAK_KVEROPT, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, veropros);

/* Lasketaan vapaa-ajan asunnon verotusarvo */

%VapVerotusArvoS(VALOPULLINENVA, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi);

/* Lasketaan vapaa-ajan asunnon kiinteistövero */

%KiVeroVapS(RAK_KVEROVA, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, talviask, sahkok, 
viemarik, vesik, wck, saunak, jhvalarvokoodi, veropros);

/* Lasketaan kiinteistövero maapohjasta */

KVTONTTIS = verotusarvo * (kiintpros / 100);

/* Lasketaan verotusarvo ja kiinteistövero omistusosuuden suhteen */

VALOPULLINENPT = VALOPULLINENPT * OMOSUUS;
RAK_KVEROPT = RAK_KVEROPT * OMOSUUS;
VALOPULLINENVA = VALOPULLINENVA * OMOSUUS;
RAK_KVEROVA = RAK_KVEROVA * OMOSUUS;

/* Luodaan tulosmuuttujille selitteet */

LABEL
VALOPULLINENPT = 'Pientalojen verotusarvo, MALLI'
RAK_KVEROPT = 'Pientalojen kiinteistövero (e/v), MALLI'
VALOPULLINENVA = 'Vapaa-ajan asuntojen verotusarvo, MALLI'
RAK_KVEROVA = 'Vapaa-ajan asuntojen kiinteistövero (e/v), MALLI'
KVTONTTIS = 'Maapohjan kiinteistövero (e/v), MALLI';
RUN;

/* 3.2 Lasketaan kiinteistövero asunto-osakeyhtiöissä pohja-aineiston perusteella */

DATA TEMP.KIVERO_ASOY;
SET STARTDAT.START_KIVERO_ASOY (KEEP = hnro knro aslaji talotyyp rakvuosi hoitvast omakkiiv);

/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan
   Kiinteistöveron osuus kohtien 3001, 3002, 3003, 3004 ja 3021 summasta. */

%IF &AVUOSI >= 2018 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2018" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0833;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0743;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0671;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0759;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0823;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.108;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0674;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0574;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0557;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0706;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0693;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0881;
END;
%END;
%ELSE %IF &AVUOSI = 2017 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2017" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0816;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0721;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0699;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0785;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0913;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.113;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0667;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0757;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0602;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0737;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0784;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.1024;
END;
%END;
%ELSE %IF &AVUOSI = 2016 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2016" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0734;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0750;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0676;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0744;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0776;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.1075;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0585;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0641;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0629;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0688;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0764;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0962;
END;
%END;
%ELSE %IF &AVUOSI = 2015 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2015" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0776;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0723;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0699;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0811;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0774;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.1077;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0890;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0576;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0606;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0719;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0714;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0959;
END;
%END;
%ELSE %IF &AVUOSI = 2014 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2014" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0776;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0683;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0665;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0760;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0748;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0949;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0525;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0522;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0631;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0700;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0652;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0929;
END;
%END;
%ELSE %IF &AVUOSI = 2013 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2013" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */
IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0709;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0695;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0643;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0705;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0707;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0941;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0591;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0549;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0531;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0635;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0695;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0827;
END;
%END;
%ELSE %IF &AVUOSI = 2012 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2012" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */

IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0769;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0647;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0615;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0697;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0701;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0959;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0405;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0544;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0578;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0664;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0745;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0939;
END;
%END;
%ELSE %IF &AVUOSI <= 2011 %THEN %DO;
/* Määritellään kiinteistöveron osuus hoitovastikkeista "Asunto-osakeyhtiöiden talous 2010" -raportin mukaan
   ja eritellään kerrostalo- ja rivitaloyhtiöihin asunnon iän mukaan. */

IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0580;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0557;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0562;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0673;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0640;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0946;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0548;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0471;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0470;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0613;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0665;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0842;
END;

%END;
ASOYKIVERO =(hoitvast * HOITOSUUS) * 12;

LABEL
HOITOSUUS = 'Kiinteistöveron osuus hoitovastikkeesta (%), MALLI'
ASOYKIVERO = 'Kiinteistövero asunto-osakeyhtiössä (e/v), MALLI';

RUN;

/* 3.3 Summataan kiinteistöveroaineisto henkilötasolle, yhdistetään tulokset pohja-aineistoon 
	ja lasketaan kiinteistövero yhteensä */

PROC SUMMARY DATA = TEMP.KIVERO_REK ;
VAR VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA KVTONTTIS verotusarvo kvtontti  
    valopullinenptd valopullinenvad rak_kveroptd rak_kverovad KIVEDATA VERARVODATA;
BY hnro;
OUTPUT OUT = TEMP.KIVERO_SUMMAT (DROP = _TYPE_ _FREQ_) SUM=;
RUN;

DATA TEMP.&TULOSNIMI_KV;
MERGE TEMP.KIVERO_ASOY TEMP.KIVERO_SUMMAT;
BY hnro;

/*Lasketaan kiinteistövero yhteensä, ilman asunto-osakeyhtiötä. */
KIVEROYHT2 = SUM(RAK_KVEROPT, RAK_KVEROVA, KVTONTTIS);

/*Pienimmän määrättävän veron alittavat kiinteistöverot nollataan. */
%KiMinimi(KIVEROYHT2, &LVUOSI, &INF, KIVEROYHT2);

/* Nollataan osamuuttujat mikäli verotuksen kokonaissumma on nollattu. */
IF KIVEROYHT2 = 0 THEN DO; 
RAK_KVEROPT = 0;
RAK_KVEROVA = 0; 
KVTONTTIS = 0; 
END;

/*Lasketaan kiinteistövero yhteensä asunto-osakeyhtiöt mukaan lukien.*/ 	
KIVEROYHT = SUM(RAK_KVEROPT, RAK_KVEROVA, KVTONTTIS, ASOYKIVERO);

LABEL
KIVEROYHT = 'Kiinteistöverot (ml. asoy) yhteensä (e/v), MALLI'
KIVEROYHT2 = 'Kiinteistöverot (pl. asoy) yhteensä (e/v), MALLI';

/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan */

ARRAY PISTE 
	 VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA KVTONTTIS ASOYKIVERO KIVEROYHT KIVEROYHT2
	 valopullinenptd valopullinenvad rak_kveroptd rak_kverovad  
	 verotusarvo kvtontti omakkiiv KIVEDATA VERARVODATA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

LABEL 
omakkiiv = 'Kiinteistöverot (pl. asoy) yhteensä (e/v) (pohja-aineisto), DATA';

RUN;

/* 3.4 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistetään tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_KV;

	/* 3.4.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

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

	/* Jos käyttäjä määritellyt YKSIKKO=1 (henkilötaso) tai YKSIKKO on mitä tahansa muuta kuin 2 (kotitaloustaso)
		niin jätetään tulostaulu henkilötasolle ja nimetään se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KV._HLO;
			CHANGE &TULOSNIMI_KV=&TULOSNIMI_KV._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_KV._HLO;
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

%MEND KiVero_Simuloi_data;

%KiVero_Simuloi_data;

%LET loppui2&malli = %SYSFUNC(TIME());

/* 4. Tulostetaan käyttäjän pyytämät taulukot */

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