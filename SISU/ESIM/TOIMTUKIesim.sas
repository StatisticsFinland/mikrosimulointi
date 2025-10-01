/***********************************************************
* Kuvaus: Toimentulotuen esimerkkilaskelmien pohja         *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM;	* Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TO = toimtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains‰‰d‰ntˆ ;
%LET VALITUT = _ALL_;	* Tulostaulukossa n‰ytett‰v‰t muuttujat ;
%LET EROTIN = 2;		* Tulosteessa k‰ytett‰v‰ desimaalierotin, 1 = piste tai 2 = pilkku;
%LET DESIMAALIT = 2;	* Tulosteessa k‰ytett‰v‰ desimaalien m‰‰r‰ (0-9);
%LET EXCEL = 1;			* Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;

* Inflaatiokorjaus. Euro- tai markkam‰‰r‰isten parametrien haun yhteydess‰ suoritettavassa
  deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse INF-makromuuttujaan
  (HUOM! desimaalit erotettava pisteell‰ .). Esim. jos yksi lains‰‰d‰ntˆvuoden euro on
  peruvuoden rahassa 95 sentti‰, syˆt‰ arvoksi 0.95.
  Simuloinnin tulokset ilmoitetaan aina perusvuoden rahassa.
  Jos puolestaan haluaa k‰ytt‰‰ automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

%LET INF = 1.00; * Syˆt‰ lukuarvo, KHI tai ATI;
%LET AVUOSI = 2025; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K‰ytett‰v‰ indeksien parametritaulukko ;

* K‰ytett‰vien tiedostojen nimet;

%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
%LET LAKIMAK_TIED_EP = EPIDEMlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PTOIMTUKI = ptoimtuki;	* TOIMTUKI-parametritaulun nimi ;
%LET POPINTUKI = popintuki; * OPINTUKI-parametritaulun nimi ;
%LET PEPIDEM = pepidem; * EPIDEM-parametritaulun nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EP..sas";

%MEND Aloitus;

%Aloitus;


/* 2. M‰‰ritell‰‰n datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1. Esimerkiss‰ k‰ytett‰v‰ data */

* Lains‰‰d‰ntˆvuosi (1989-);
%LET MINIMI_TOIMTUKI_VUOSI = 2025;
%LET MAKSIMI_TOIMTUKI_VUOSI = 2025;

* Lains‰‰d‰ntˆkuukausi (1-12);
%LET MINIMI_TOIMTUKI_KUUK = 12;
%LET MAKSIMI_TOIMTUKI_KUUK = 12;

* Toimeentulotuen kuntaryhm‰ (1/2);
%LET MINIMI_TOIMTUKI_KRYHMA = 1;
%LET MAKSIMI_TOIMTUKI_KRYHMA = 1;

* 18-v. t‰ytt‰neiden lkm (pl. 18-v. t‰ytt‰neet lapset);
%LET MINIMI_TOIMTUKI_AIK = 1;
%LET MAKSIMI_TOIMTUKI_AIK = 1;

* 18-v. t‰ytt‰neiden lasten lkm;
%LET MINIMI_TOIMTUKI_AIKLAPSIA = 0;
%LET MAKSIMI_TOIMTUKI_AIKLAPSIA = 0;

* 17-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIA17 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIA17 = 0;

* 10-16-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIA10_16 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIA10_16 = 0;

* Alle 10-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIAALLE10 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIAALLE10 = 0;

* Lapsilis‰n m‰‰r‰ (e/kk) ;
%LET MINIMI_TOIMTUKI_LAPSILISAT = 0;
%LET MAKSIMI_TOIMTUKI_LAPSILISAT = 0;
%LET KYNNYS_TOIMTUKI_LAPSILISAT = 10;

* Palkkatulot (e/kk) ;
%LET MINIMI_TOIMTUKI_TYOTULO = 0;
%LET MAKSIMI_TOIMTUKI_TYOTULO = 0;
%LET KYNNYS_TOIMTUKI_TYOTULO = 500;

* Muut tulot (e/kk) ;
%LET MINIMI_TOIMTUKI_MUUTTULOT = 0;
%LET MAKSIMI_TOIMTUKI_MUUTTULOT = 0;
%LET KYNNYS_TOIMTUKI_MUUTTULOT = 200;

* Asumismenot (e/kk) ;
%LET MINIMI_TOIMTUKI_ASMENOT = 0;
%LET MAKSIMI_TOIMTUKI_ASMENOT = 0;
%LET KYNNYS_TOIMTUKI_ASMENOT = 100;

* Harkinnanvaraiset menot (e/kk)  ;
%LET MINIMI_TOIMTUKI_HARKMENOT = 0;
%LET MAKSIMI_TOIMTUKI_HARKMENOT = 0;
%LET KYNNYS_TOIMTUKI_HARKMENOT = 100;

* Tulonhankkimiskulut (e/kk);
%LET MINIMI_TOIMTUKI_TULONHANK = 0;
%LET MAKSIMI_TOIMTUKI_TULONHANK = 0;
%LET KYNNYS_TOIMTUKI_TULONHANK = 50;

* Tukikuukaudet vuodessa ;
%LET MINIMI_TOIMTUKI_TUKIAIKA = 12;
%LET MAKSIMI_TOIMTUKI_TUKIAIKA = 12;

* Epidemiakorvauksen kuukaudet vuodessa;
%LET MINIMI_TOIMTUKI_EPIDEMKORVAIKA = 0; 
%LET MAKSIMI_TOIMTUKI_EPIDEMKORVAIKA = 0;

%END;


/* 3. Luodaan esimerkiss‰ k‰ytett‰v‰ data ja simuloidaan sen pohjalta. */

/* 3.1. Generoidaan esimerkiss‰ k‰ytett‰v‰ data makromuuttujien arvojen mukaisesti. */ 

DATA OUTPUT.&TULOSNIMI_TO;

DO TOIMTUKI_VUOSI = &MINIMI_TOIMTUKI_VUOSI TO &MAKSIMI_TOIMTUKI_VUOSI;
DO TOIMTUKI_KUUK = &MINIMI_TOIMTUKI_KUUK TO &MAKSIMI_TOIMTUKI_KUUK;
DO TOIMTUKI_KRYHMA = &MINIMI_TOIMTUKI_KRYHMA TO &MAKSIMI_TOIMTUKI_KRYHMA;
DO TOIMTUKI_AIK = &MINIMI_TOIMTUKI_AIK TO &MAKSIMI_TOIMTUKI_AIK;
DO TOIMTUKI_AIKLAPSIA = &MINIMI_TOIMTUKI_AIKLAPSIA TO &MAKSIMI_TOIMTUKI_AIKLAPSIA;
DO TOIMTUKI_LAPSIA17 = &MINIMI_TOIMTUKI_LAPSIA17 TO &MAKSIMI_TOIMTUKI_LAPSIA17;
DO TOIMTUKI_LAPSIA10_16 = &MINIMI_TOIMTUKI_LAPSIA10_16 TO &MAKSIMI_TOIMTUKI_LAPSIA10_16;
DO TOIMTUKI_LAPSIAALLE10 = &MINIMI_TOIMTUKI_LAPSIAALLE10 TO &MAKSIMI_TOIMTUKI_LAPSIAALLE10;
DO TOIMTUKI_LAPSILISAT = &MINIMI_TOIMTUKI_LAPSILISAT TO &MAKSIMI_TOIMTUKI_LAPSILISAT BY &KYNNYS_TOIMTUKI_LAPSILISAT;
DO TOIMTUKI_TYOTULO = &MINIMI_TOIMTUKI_TYOTULO TO &MAKSIMI_TOIMTUKI_TYOTULO BY &KYNNYS_TOIMTUKI_TYOTULO;
DO TOIMTUKI_MUUTTULOT = &MINIMI_TOIMTUKI_MUUTTULOT TO &MAKSIMI_TOIMTUKI_MUUTTULOT BY &KYNNYS_TOIMTUKI_MUUTTULOT;
DO TOIMTUKI_ASMENOT = &MINIMI_TOIMTUKI_ASMENOT TO &MAKSIMI_TOIMTUKI_ASMENOT BY &KYNNYS_TOIMTUKI_ASMENOT;
DO TOIMTUKI_HARKMENOT = &MINIMI_TOIMTUKI_HARKMENOT TO &MAKSIMI_TOIMTUKI_HARKMENOT BY &KYNNYS_TOIMTUKI_HARKMENOT;
DO TOIMTUKI_TULONHANK = &MINIMI_TOIMTUKI_TULONHANK TO &MAKSIMI_TOIMTUKI_TULONHANK BY &KYNNYS_TOIMTUKI_TULONHANK;
DO TOIMTUKI_TUKIAIKA = &MINIMI_TOIMTUKI_TUKIAIKA TO &MAKSIMI_TOIMTUKI_TUKIAIKA;
DO TOIMTUKI_EPIDEMKORVAIKA = &MINIMI_TOIMTUKI_EPIDEMKORVAIKA TO &MAKSIMI_TOIMTUKI_EPIDEMKORVAIKA;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, TOIMTUKI_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2. Simuloidaan valitut muuttujat esimerkkidatalla. */

%MACRO ToimTuki_Simuloi_Esimerkki;
/* TOIMTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL TOIMTUKI_PARAM TOIMTUKI_MUUNNOS OPINTUKI_PARAM OPINTUKI_MUUNNOS EPIDEM_PARAM EPIDEM_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(TOIMTUKI_PARAM, TOIMTUKI);
%HaeLaskettavatLokaalit(TOIMTUKI_MUUNNOS, TOIMTUKI);

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(OPINTUKI_PARAM, OPINTUKI);
%HaeLaskettavatLokaalit(OPINTUKI_MUUNNOS, OPINTUKI);

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(EPIDEM_PARAM, EPIDEM);
%HaeLaskettavatLokaalit(EPIDEM_MUUNNOS, EPIDEM);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametrien hakua varten */
%LOCAL &TOIMTUKI_PARAM;
%LOCAL &EPIDEM_PARAM;

/* Asumtuki-mallin NormivuokraS ja NormineliotS -makrojen parametrit */
%LOCAL EnimmN1 EnimmN2 EnimmN3 EnimmN4 EnimmN5 EnimmN6 EnimmN7 EnimmN8 EnimmNPlus;

DATA OUTPUT.&TULOSNIMI_TO;
SET OUTPUT.&TULOSNIMI_TO;

array TOIMTUKI_TYOTULO_ARR{1};
array TOIMTUKI_TULONHANK_ARR{1};

TOIMTUKI_TYOTULO_ARR{1} = TOIMTUKI_TYOTULO;
TOIMTUKI_TULONHANK_ARR{1} = TOIMTUKI_TULONHANK;

IF &VUOSIKA = 1 THEN DO;

	%ToimTukiVS(TOIMTUKIKK, TOIMTUKI_VUOSI, INF, TOIMTUKI_KRYHMA, 1, 
			TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10,
			TOIMTUKI_LAPSILISAT, TOIMTUKI_TYOTULO_ARR, TOIMTUKI_MUUTTULOT, TOIMTUKI_ASMENOT, TOIMTUKI_HARKMENOT, TOIMTUKI_TULONHANK_ARR);

	*Epidemiakorvaus;
	IF TOIMTUKI_EPIDEMKORVAIKA > 0 THEN DO;
		%EpidemKorvVS(EPIDEMKORVKK, TOIMTUKI_VUOSI, INF, SUM(TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10));
	END;
	ELSE DO;
		EPIDEMKORVKK = 0;
	END;
	
END;

IF &VUOSIKA = 2 THEN DO;

	%ToimTukiKS(TOIMTUKIKK, TOIMTUKI_VUOSI, TOIMTUKI_KUUK, INF, TOIMTUKI_KRYHMA, 1, 
			TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10,
			TOIMTUKI_LAPSILISAT, TOIMTUKI_TYOTULO_ARR, TOIMTUKI_MUUTTULOT, TOIMTUKI_ASMENOT, TOIMTUKI_HARKMENOT, TOIMTUKI_TULONHANK_ARR);

	*Epidemiakorvaus;
	IF TOIMTUKI_EPIDEMKORVAIKA > 0 THEN DO;
		%EpidemKorvKS(EPIDEMKORVKK, TOIMTUKI_VUOSI, TOIMTUKI_KUUK, INF, SUM(TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10));
	END;
	ELSE DO;
		EPIDEMKORVKK = 0;
	END;

END;

TOIMEPIDKK = SUM(TOIMTUKIKK, EPIDEMKORVKK); *Toimeentulotuki ja epidemiakorvaus yhteens‰ kuukaudessa;

TOIMTUKIV = TOIMTUKI_TUKIAIKA * TOIMTUKIKK; *Toimeentulotuki vuodessa;

EPIDEMKORVAIKAKORJ = MIN(TOIMTUKI_TUKIAIKA, TOIMTUKI_EPIDEMKORVAIKA); *Sovelletaan ehtoa ett‰ epidemiakorvausta voi saada vain yht‰ monelta kuukaudelta kuin on saanut toimeentulotukea;

EPIDEMKORVV = EPIDEMKORVAIKAKORJ * EPIDEMKORVKK; *Epidemiakorvaus vuodessa;

TOIMEPIDV = SUM(TOIMTUKIV, EPIDEMKORVV); *Toimeentulotuki ja epidemiakorvaus yhteens‰ vuodessa;

DROP kuuknro w y z testi kkuuk taulu_: /* Kaikki taulu_-alkuiset */ ;

DROP TOIMTUKI_TYOTULO_ARR1 TOIMTUKI_TULONHANK_ARR1 i;

/* 3.3 M‰‰ritell‰‰n muuttujille selkokieliset selitteet. */

LABEL
TOIMTUKI_VUOSI = 'Lains‰‰d‰ntˆvuosi'
TOIMTUKI_KUUK = 'Lains‰‰d‰ntˆkuukausi'
TOIMTUKI_KRYHMA = 'Toimeentulotuen kuntaryhm‰, (1/2)'
TOIMTUKI_AIK = '18-v. t‰ytt‰neiden lkm (pl. 18-v. t‰ytt‰neet lapset)'
TOIMTUKI_AIKLAPSIA = '18-v. t‰ytt‰neiden lasten lkm'
TOIMTUKI_LAPSIA17 = '17-v. lasten lkm'
TOIMTUKI_LAPSIA10_16 = '10-16-v. lasten lkm'
TOIMTUKI_LAPSIAALLE10 = 'Alle 10-v. lasten lkm'
TOIMTUKI_LAPSILISAT = 'Lapsilis‰n m‰‰r‰, (e/kk)'
TOIMTUKI_TYOTULO = 'Tˆist‰ saadut tulot, (e/kk)'
TOIMTUKI_MUUTTULOT = 'Muut tulot, (e/kk)'
TOIMTUKI_ASMENOT = 'Asumismenot, (e/kk)'
TOIMTUKI_HARKMENOT = 'Harkinnanvaraiset menot, (e/kk)'
TOIMTUKI_TULONHANK = 'Tulonhankkimismenot, (e/kk)'
TOIMTUKI_TUKIAIKA = 'Tukikuukaudet vuodessa, (kk)'
TOIMTUKI_EPIDEMKORVAIKA = 'Epidemiakorvauksen kuukaudet vuodessa, (kk)'
INF = 'Inflaatiokorjauksessa k‰ytett‰v‰ kerroin'

TOIMTUKIKK = 'Toimeentulotuki, (e/kk)'
EPIDEMKORVKK = 'Epidemiakorvaus, (e/kk)'
TOIMEPIDKK = 'Toimeentulotuki ja epidemiakorvaus yhteens‰, (e/kk)'
TOIMTUKIV = 'Toimeentulotuki, (e/v)'
EPIDEMKORVAIKAKORJ = 'Laskennassa k‰ytetyt epidemiakorvauksen kuukaudet vuodessa, (kk)'
EPIDEMKORVV = 'Epidemiakorvaus, (e/v)'
TOIMEPIDV = 'Toimeentulotuki ja epidemiakorvaus yhteens‰, (e/v)';

/* M‰‰ritell‰‰n formaatilla haluttu desimaalierotin  */
/* ja n‰ytett‰vien desimaalien lukum‰‰r‰ */

%IF &EROTIN = 1 %THEN %DO;
	FORMAT _NUMERIC_ 1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF 8.5;
%END;

%IF &EROTIN = 2 %THEN %DO;
	FORMAT _NUMERIC_ NUMx1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF NUMx8.5;
%END;

/* Kokonaislukuina ne muuttujat, joissa ei haluta k‰ytt‰‰ desimaalierotinta */

FORMAT TOIMTUKI_VUOSI TOIMTUKI_KUUK TOIMTUKI_KRYHMA TOIMTUKI_AIK TOIMTUKI_AIKLAPSIA TOIMTUKI_LAPSIA17 
TOIMTUKI_LAPSIA10_16 TOIMTUKI_LAPSIAALLE10 TOIMTUKI_TUKIAIKA TOIMTUKI_EPIDEMKORVAIKA EPIDEMKORVAIKAKORJ 8.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP TOIMTUKI_KUUK;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_TO, TOIMTUKI);

%MEND ToimTuki_Simuloi_Esimerkki;

%ToimTuki_Simuloi_Esimerkki;
