/********************************************************
* Kuvaus: Kotihoidon tuen simulointimalli 2018          *
* Viimeksi p‰ivitetty: 28.5.2020 		    		    *
********************************************************/ 

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */

%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = KOTIHTUKI;

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

	%LET TULOSNIMI_KT = kotihtuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

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

	%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET PKOTIHTUKI = pkotihtuki; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT =  tkotihtu kthr HOITORAHA kthl HOITOLISA KOTIHTUKI_DATA KOTIHTUKI oshr OSHOIT lgjhhr JSHOIT ; * Taulukoitavat muuttujat (summataulukot) ; 
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

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KotihTuki_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO; 

	/* 2.1 M‰‰ritell‰‰n tarvittavat pohja-aineiston muuttujat starttidatoihin */

	*Jos selvitet‰‰n suhdetta yksityisen hoidon tukeen ja kunnalliseen kotihoidon tukeen voidaan ottaa mukaan
	muuttujat ytku hkotihm ktku *
	*Muuttajat apv amyky selitt‰isiv‰t suhdetta vanhempainp‰iv‰rahoihin;

	* Summataan tarvittavia muuttujia kotitaloustasolle ;

	PROC SUMMARY DATA = POHJADAT.&AINEISTO&AVUOSI;
	BY knro; 
	ID elivtu hnro;
	OUTPUT OUT = TEMP.KOTIHTUKI_T1 (DROP = _TYPE_ _FREQ_
	WHERE = (kthr > 0 OR kthl > 0 OR htkk > 0 OR oshr > 0 OR lgjhhr > 0
	OR hltulo >= 0 OR hlkk NE . OR  la1 NE . OR la2 NE . OR la3 NE . OR la4 NE . OR la5 NE . OR 
	la6 NE . OR la7 NE . OR la8 NE . OR la9 NE .)) 
	SUM(kthr kthl tkotihtu htkk oshr lgjhhr hltulo hlkk la1 la2 la3 la4 la5 la6 la7 la8 la9 
		PTULO OSTUKIKUUK JSTUKIKUUK) = MIN(JSHRTUN) = SUM(TAYSIHR TAYSIHR_1 TAYSIHR_0_1 TAYSIHR_0_2 
		VAJAAHR VAHENNYS VAHENNYS2) = ;
	RUN;
	
	* Poimitaan aineiston tiedot eri tukilajeista kotitalouden sis‰ist‰ jakoa varten;

	DATA STARTDAT.START_KOTIHTUKI_kotihtu;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro kthr kthl); 
	WHERE SUM(kthr, kthl) > 0;
	KOTIHTU = SUM(kthr, kthl);
	RUN;

	DATA STARTDAT.START_KOTIHTUKI_oshr;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro oshr ostukikuuk); 
	WHERE oshr > 0; 
	RUN;

	DATA STARTDAT.START_KOTIHTUKI_lgjhhr;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro lgjhhr jstukikuuk); 
	WHERE lgjhhr > 0; 
	RUN;
	
	/* 2.2 Lis‰t‰‰n aineistoon apumuuttujia */

	DATA STARTDAT.START_KOTIHTUKI;
	SET TEMP.KOTIHTUKI_T1;
	
	* P‰‰tell‰‰n perheen koko hoitolis‰‰ varten: 2, 3 tai 4 muuttujaan PKOKO ;

	IF (elivtu >= 40 AND elivtu <= 60) OR elivtu = 82 THEN OSAKOKO1 = 2; 
	ELSE OSAKOKO1 = 1;
	IF la2 > 0 THEN OSAKOKO2 = 2; 
	ELSE OSAKOKO2 = 1;
	PKOKO = SUM(OSAKOKO1, OSAKOKO2);

	RUN;

%END;

%MEND KotihTuki_Muutt_Poiminta;

%KotihTuki_Muutt_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe */

%MACRO KotihTuki_Simuloi_Data;
/* KOTIHTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL KOTIHTUKI_PARAM KOTIHTUKI_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(KOTIHTUKI_PARAM, KOTIHTUKI);
%HaeLaskettavatLokaalit(KOTIHTUKI_MUUNNOS, KOTIHTUKI);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KOTIHTUKI_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */
%KuukSimul(KOTIHTUKI);

DATA TEMP.&TULOSNIMI_KT; 
SET STARTDAT.START_KOTIHTUKI;

* Lasketaan tapaukset, jotka edell‰ oli m‰‰ritelty t‰ysiksi hoitorahoiksi, HOITORAHA ;

IF TAYSIHR = 1 OR TAYSIHR_1 = 1 OR TAYSIHR_0_1 = 1 OR TAYSIHR_0_2 = 1 THEN DO;
	SISARK = 0;
	MUUKOR = 0;
	IF TAYSIHR_1 = 1 THEN SISARK = 1;
	IF TAYSIHR_0_1 = 1 THEN MUUKOR = 1;
	IF TAYSIHR_0_2 = 1 THEN MUUKOR = 2;

    %HoitoRahaVS(HOITOR, &LVUOSI, &INF, SISARK, MUUKOR);

	HOITORAHA = la1 * HOITOR; 
END;

* Lasketaan tapaukset, jotka oli todettu vajaiksi ja tekem‰ll‰ v‰hennys;

%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 0, 0);
IF VAJAAHR = 1 THEN HOITORAHA = la1 * SUM(HOITOR, -VAHENNYS); 	

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on vain 1 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
SUM(la2, la3, la4, la5, la6) = 0 THEN DO;
    HOITORAHA = SUM(la1 * hoitor, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 2 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la1 >= la2 AND SUM(la3, la4, la5, la6) = 0 THEN DO;
	%HoitoRahaVS(hoitor, &LVUOSI, &INF, 1, 0);
	HOITORAHA = la2 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 3;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la1 >= la2 AND la1 >= la3 AND SUM(la4, la5, la6) = 0 THEN DO;
	%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 1, 1);
	HOITORAHA = la3 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 4;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la4 > 0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND SUM(la5, la6) = 0 THEN DO;
	%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 1, 2);
	HOITORAHA = la4 * SUM(HOITOR, -VAHENNYS2); 
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 5 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la4 > 0 AND la5 > 0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND la1 >= la5 AND SUM(la6) = 0 THEN DO;
	%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 1, 3);
	HOITORAHA = la5 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 6 ;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la4 > 0 AND la5 > 0 AND la6 > 0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND la1 >= la5 AND la1 >= la6 THEN DO;
	%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 1, 4);
	HOITORAHA = la6 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitorahat muissa kuin edell‰ k‰sitellyiss‰ tapauksissa;
IF HOITORAHA = . THEN DO;

	IF KTHR > 0 THEN DO;

		LAMAX1 = MAX(la2, la1); 
		LAMAX2 = MAX(la3, LAMAX1);
		LAMAX3 = MAX(la4, LAMAX2);
		LAMAX4 = MAX(la5, LAMAX3);
		LAMAX5 = MAX(la6, LAMAX4);

		IF la6 > 0 THEN ALLEKOULUIKAISIA = 5; 
		ELSE IF la5 > 0 THEN ALLEKOULUIKAISIA = 4;
		ELSE IF la4 > 0 THEN ALLEKOULUIKAISIA = 3;
		ELSE IF la3 > 0 THEN ALLEKOULUIKAISIA = 2;
		ELSE IF la2 > 0 THEN ALLEKOULUIKAISIA = 1;
		ELSE ALLEKOULUIKAISIA = 0; * Muu alle kouluik‰inen ;

		%HoitoRahaVS(HOITOR, &LVUOSI, &INF, 0, ALLEKOULUIKAISIA);

		HOITORAHA = LAMAX5 * HOITOR;

	END;
END;

* Lasketaan hoitolis‰ muuttujaan HOITOLISA, k‰ytet‰‰n makroa HoitoLisaV ;

IF HOITORAHA > 0 THEN DO;
%HoitoLisaVS(HOITOL, &LVUOSI, &INF, 0, 0, PKOKO, PTULO, 0); 
IF hlkk NE . THEN HOITOLISA  = MIN(12, hlkk) * HOITOL; 
END;

* Lasketaan hoitoraha ja hoitolis‰ yhteen, muuttuja TUKI ;

TUKI = SUM(HOITORAHA, HOITOLISA);

* Lains‰‰d‰ntˆvuodesta 2014 eteenp‰in lasketaan osittainen hoitoraha makrolla OsitHoitRaha, muuttuja OSHOIT, 
ja joustava hoitoraha makrolla JoustHoitRahaTunn, muuttuja JSHOIT ; 

%LOCAL JOUSTAVA; 

%IF &LVUOSI >= 2014 %THEN %DO;
	%OsitHoitRahaVS(OSHOITR, &LVUOSI, &INF);
	OSHOIT = OSTUKIKUUK * OSHOITR;
	%JoustHoitRahaTunnVS(JSHOITR, &LVUOSI, &INF, min(30, JSHRTUN));
	JSHOIT = JSTUKIKUUK * JSHOITR;
	%LET JOUSTAVA = 1;
%END;

* Ennen lains‰‰d‰ntˆvuotta 2014 lasketaan vain osittainen hoitoraha makrolla OsitHoitRahaTunn, muuttuja OSHOIT (JSHOIT = .) ;
* Oletetaan, ett‰ kaikki datassa joustavalla hoitorahalla olleet saavat osittaista hoitorahaa ja k‰ytet‰‰n joustavan hoitorahan tunteja jos ne ovat olemassa;

%IF &LVUOSI < 2014 %THEN %DO;
	%OsitHoitRahaTunnVS(OSHOITR, &LVUOSI, &INF, min(30, JSHRTUN));
	OSHOIT = SUM(OSTUKIKUUK, JSTUKIKUUK) * OSHOITR; 
	JSHOITR = .;
	JSHOIT = .;
	%LET JOUSTAVA = 0; 
%END;

DROP SISARK MUUKOR HOITOR LAMAX1-LAMAX5 temp1 temp2 ALLEKOULUIKAISIA HOITOL OSHOITR JSHOITR; 

RUN;

* Lasketaan kotitalouksien eri henkilˆille suhteellinen osuus maksetusta kotihoidon tuesta (hoitoraha + hoitolis‰):
  lasketaan ensin summa kotitalouksittain tiedostoon KOTIHTUKI_kotihtux ;

PROC SUMMARY DATA = STARTDAT.START_KOTIHTUKI_kotihtu;
BY knro;
WHERE (KOTIHTU > 0);
OUTPUT OUT = TEMP.KOTIHTUKI_kotihtux (DROP = _TYPE_ _FREQ_) SUM(KOTIHTU) = KOTIHTU_SUM;
RUN;

* Lasketaan henkilˆiden osuudet kotihoidon tuesta, tiedosto KOTIHTUKI_HENK_OSUUDET ja muuttuja OSUUS ;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET_kotihtu;
MERGE STARTDAT.START_KOTIHTUKI_kotihtu TEMP.KOTIHTUKI_kotihtux (KEEP = knro KOTIHTU_SUM);
BY knro;
OSUUS = SUM(KOTIHTU) / SUM(KOTIHTU_SUM);
RUN;

* Lasketaan kotitalouksien eri henkilˆille suhteellinen osuus osittaisesta hoitorahasta ja tukikuukausista: 
  lasketaan ensin summa kotitalouksittain tiedostoon KOTIHTUKI_oshrx ;

PROC SUMMARY DATA = STARTDAT.START_KOTIHTUKI_oshr;
BY knro; 
WHERE (oshr > 0);
OUTPUT OUT = TEMP.KOTIHTUKI_oshrx (DROP = _TYPE_ _FREQ_) SUM(oshr) = oshr_SUM SUM(ostukikuuk) = ostukikuuk_SUM; 
RUN;

* Lasketaan henkilˆiden osuudet osittaisesta hoitorahasta, tiedosto KOTIHTUKI_HENK_OSUUDET_oshr ja muuttujat OSUUS_oshr OSUUS_ostukikuuk;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET_oshr;
MERGE STARTDAT.START_KOTIHTUKI_oshr TEMP.KOTIHTUKI_oshrx (KEEP = knro oshr_SUM ostukikuuk_SUM); 
BY knro;
OSUUS_oshr = SUM(oshr) / SUM(oshr_SUM);
IF SUM(ostukikuuk_SUM) > 0 THEN DO;
	OSUUS_ostukikuuk = SUM(ostukikuuk) / SUM(ostukikuuk_SUM) ; 
END; 
ELSE DO; 
	OSUUS_ostukikuuk = 0; 
END;
RUN;

* Lasketaan kotitalouksien eri henkilˆille suhteellinen osuus joustavasta hoitorahasta ja tukikuukausista: 
  lasketaan ensin summa kotitalouksittain tiedostoon KOTIHTUKI_lgjhhrx ;

PROC SUMMARY DATA = STARTDAT.START_KOTIHTUKI_lgjhhr;
BY knro; 
WHERE (lgjhhr > 0);
OUTPUT OUT = TEMP.KOTIHTUKI_lgjhhrx (DROP = _TYPE_ _FREQ_) SUM(lgjhhr) = lgjhhr_SUM SUM(jstukikuuk) = jstukikuuk_SUM; 
RUN;

* Lasketaan henkilˆiden osuudet osittaisesta hoitorahasta, tiedosto KOTIHTUKI_HENK_OSUUDET_oshr ja muuttujat OSUUS_lgjhhr OSUUS_jstukikuuk;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET_lgjhhr;
MERGE STARTDAT.START_KOTIHTUKI_lgjhhr TEMP.KOTIHTUKI_lgjhhrx (KEEP = knro lgjhhr_SUM jstukikuuk_SUM); 
BY knro;
OSUUS_lgjhhr = SUM(lgjhhr) / SUM(lgjhhr_SUM);
IF SUM(jstukikuuk_SUM) > 0 THEN DO; 
	OSUUS_jstukikuuk = SUM(jstukikuuk) / SUM(jstukikuuk_SUM) ; 
END; 
ELSE DO; 
	OSUUS_jstukikuuk = 0; 
END;
RUN;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET;
MERGE TEMP.KOTIHTUKI_HENK_OSUUDET_kotihtu(KEEP = hnro knro OSUUS)
	TEMP.KOTIHTUKI_HENK_OSUUDET_oshr(KEEP = hnro knro OSUUS_oshr OSUUS_ostukikuuk ostukikuuk ostukikuuk_SUM)
	TEMP.KOTIHTUKI_HENK_OSUUDET_lgjhhr(KEEP = hnro knro OSUUS_lgjhhr OSUUS_jstukikuuk jstukikuuk jstukikuuk_SUM);
BY hnro;
RUN;

* Jaetaan muuttujat HOITORAHA, HOITOLISA, TUKI, OSHOIT ja JSHOIT kotitalouden sis‰ll‰ ottamalla huomioon 
  henkilˆiden osuudet ja siirret‰‰n samalla tulokset tiedostoon TEMP.&TULOSNIMI_KT.
  TUKI-muuttujan nimeksi muutetaan KOTIHTUKI; 

DATA TEMP.&TULOSNIMI_KT;
MERGE TEMP.&TULOSNIMI_KT(KEEP = hnro knro HOITORAHA HOITOLISA TUKI OSHOIT JSHOIT oshr lgjhhr tkotihtu) 
	TEMP.KOTIHTUKI_HENK_OSUUDET;
BY knro;
RUN;

DATA TEMP.&TULOSNIMI_KT; 
SET TEMP.&TULOSNIMI_KT; 
HOITORAHA = OSUUS * HOITORAHA;
HOITOLISA = OSUUS * HOITOLISA;
KOTIHTUKI = OSUUS * TUKI;

JSHOIT = OSUUS_jstukikuuk * JSHOIT;

IF &JOUSTAVA = 1 THEN DO;
	OSHOIT = OSUUS_ostukikuuk * OSHOIT;
END;

* Jos kyse on lains‰‰d‰nnˆst‰, jossa ei ole joustavaa hoitorahaa, lasketaan osittaisen hoitorahan henkilˆ-osuudet
  osittaisen ja joustavan hoitorahan kuukausien summan avulla;

ELSE DO;
	IF SUM(ostukikuuk_SUM, jstukikuuk_SUM) > 0 THEN DO;
		OSUUS_sumtukikuuk = SUM(ostukikuuk, jstukikuuk) / SUM(ostukikuuk_SUM, jstukikuuk_SUM); 
	END;
	ELSE DO;
		OSUUS_sumtukikuuk = 0;
	END;
	OSHOIT = OSUUS_sumtukikuuk * OSHOIT; 
END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

ARRAY PISTE 
KOTIHTUKI OSHOIT JSHOIT HOITORAHA HOITOLISA; 
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 	
OSUUS = 'Henkilˆn osuus kotihoidon tuesta, MALLI'
OSUUS_oshr = 'Henkilˆn osuus osittaisesta hoitorahasta, MALLI'
OSUUS_ostukikuuk = 'Henkilˆn osuus osittaisen hoitorahan kuukausista, MALLI'
OSUUS_lgjhhr = 'Henkilˆn osuus joustavasta hoitorahasta, MALLI'
OSUUS_jstukikuuk = 'Henkilˆn osuus joustavan hoitorahan kuukausista, MALLI'
KOTIHTUKI = 'Lasten kotihoidon tuki, MALLI'
HOITORAHA = 'Lasten kotihoidon tuen hoitoraha, MALLI'
HOITOLISA = 'Lasten kotihoidon tuen hoitolis‰, MALLI'
OSHOIT = 'Osittainen hoitoraha, MALLI'
JSHOIT = 'Joustava hoitoraha, MALLI';

KEEP knro hnro HOITORAHA HOITOLISA KOTIHTUKI OSHOIT JSHOIT OSUUS OSUUS_oshr OSUUS_ostukikuuk OSUUS_lgjhhr OSUUS_jstukikuuk;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T‰t‰ vaihetta ei ajeta mik‰li osamallia k‰ytet‰‰n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet‰‰n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_KT;
		
	/* 3.2.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO tkotihtu kthr kthl oshr lgjhhr ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_KT;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_KT;
	%END;

	/* Muokataan datan muuttujia */

	KOTIHTUKI_DATA = SUM(kthr, kthl);

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

	ARRAY PISTE 
	tkotihtu kthr kthl KOTIHTUKI_DATA oshr lgjhhr; 
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Annetaan datan muuttujille selitteet;

	LABEL
	tkotihtu = 'Lasten kotihoidon tuki yhteens‰ verotuksessa, DATA'
	kthr = 'Lasten kotihoidon tuen hoitoraha, DATA'
	kthl = 'Lasten kotihoidon tuen hoitolis‰, DATA'
	KOTIHTUKI_DATA = 'Lasten kotihoidon tuki, DATA'
	oshr = 'Osittainen hoitoraha, DATA'
	lgjhhr = 'Joustava hoitoraha, DATA';

	BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_KT._KOTI, TEMP.&TULOSNIMI_KT, &MALLI, &MUUTTUJAT);
		
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KT;
		RUN;
		QUIT;
	%END;

	/* Jos k‰ytt‰j‰ m‰‰ritellyt YKSIKKO=1 (henkilˆtaso) tai YKSIKKO on mit‰ tahansa muuta kuin 2 (kotitaloustaso)
		niin j‰tet‰‰n tulostaulu henkilˆtasolle ja nimet‰‰n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KT._HLO;
			CHANGE &TULOSNIMI_KT=&TULOSNIMI_KT._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_KT._HLO;
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

%MEND KotihTuki_Simuloi_Data;

%KotihTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(time());


/* 4. Tulostetaan k‰ytt‰j‰n pyyt‰m‰t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KT._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KT._KOTI,2);
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