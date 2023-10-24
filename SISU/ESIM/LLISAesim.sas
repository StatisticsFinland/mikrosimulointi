/***********************************************************
* Kuvaus: Lapsilis�n esimerkkilaskelmien pohja             *
* Viimeksi p�ivitetty: 12.1.2021                           *
***********************************************************/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_LL = llisa_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains��d�nt� ;
%LET VALITUT = _ALL_;	* Tulostaulukossa n�ytett�v�t muuttujat ;
%LET EROTIN = 2;		* Tulosteessa k�ytett�v� desimaalierotin, 1 = piste tai 2 = pilkku;
%LET DESIMAALIT = 2;	* Tulosteessa k�ytett�v� desimaalien m��r� (0-9);
%LET EXCEL = 1;			* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

* Inflaatiokorjaus. Euro- tai markkam��r�isten parametrien haun yhteydess� suoritettavassa
  deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse INF-makromuuttujaan
  (HUOM! desimaalit erotettava pisteell� .). Esim. jos yksi lains��d�nt�vuoden euro on
  peruvuoden rahassa 95 sentti�, sy�t� arvoksi 0.95.
  Simuloinnin tulokset ilmoitetaan aina perusvuoden rahassa.
  Jos puolestaan haluaa k�ytt�� automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

%LET INF = 1.00; * Sy�t� lukuarvo, KHI tai ATI;
%LET AVUOSI = 2021; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko ;

* K�ytett�vien tiedostojen nimet;

%LET LAKIMAK_TIED_LL = LLISAlakimakrot; * Lakimakrotiedoston nimi ;
%LET PLLISA = pllisa; * K�ytett�v�n parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1948-);
%LET MINIMI_LLISA_VUOSI = 2021;
%LET MAKSIMI_LLISA_VUOSI = 2021;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_LLISA_KUUK = 12;
%LET MAKSIMI_LLISA_KUUK = 12;

* Onko puolisoa (0 = ei puolisoa, 1 = on puoliso) ;
%LET MINIMI_LLISA_PUOLISO = 0;
%LET MAKSIMI_LLISA_PUOLISO = 0;

* Alle 3-v. lasten lukum��r�;
%LET MINIMI_LLISA_LAPSIA_ALLE_3_V = 1 ;
%LET MAKSIMI_LLISA_LAPSIA_ALLE_3_V = 1 ;

* 3-15-v. lasten lukum��r�;
%LET MINIMI_LLISA_LAPSIA_3_15_V = 0;
%LET MAKSIMI_LLISA_LAPSIA_3_15_V = 0;

* 16-v. lasten lukum��r�;
%LET MINIMI_LLISA_LAPSIA_16_V = 0;
%LET MAKSIMI_LLISA_LAPSIA_16_V = 0;

* Syntyneiden tai adoptoitujen lasten lukum��r�;
%LET MINIMI_LLISA_AITAVLAPSIA = 1;
%LET MAKSIMI_LLISA_AITAVLAPSIA = 1;

* Elatustukeen oikeuttavien lasten lukum��r�;
%LET MINIMI_LLISA_ELATLAPSIA = 1;
%LET MAKSIMI_LLISA_ELATLAPSIA = 1;

* Tukikuukaudet vuodessa;
%LET MINIMI_LLISA_TUKIAIKA = 12 ;
%LET MAKSIMI_LLISA_TUKIAIKA = 12 ;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */

DATA OUTPUT.&TULOSNIMI_LL;

DO LLISA_VUOSI = &MINIMI_LLISA_VUOSI TO &MAKSIMI_LLISA_VUOSI;
DO LLISA_KUUK = &MINIMI_LLISA_KUUK TO &MAKSIMI_LLISA_KUUK;
DO LLISA_PUOLISO = &MINIMI_LLISA_PUOLISO TO &MAKSIMI_LLISA_PUOLISO;
DO LLISA_LAPSIA_ALLE_3_V = &MINIMI_LLISA_LAPSIA_ALLE_3_V TO &MAKSIMI_LLISA_LAPSIA_ALLE_3_V ;
DO LLISA_LAPSIA_3_15_V = &MINIMI_LLISA_LAPSIA_3_15_V TO &MAKSIMI_LLISA_LAPSIA_3_15_V;
DO LLISA_LAPSIA_16_V = &MINIMI_LLISA_LAPSIA_16_V TO &MAKSIMI_LLISA_LAPSIA_16_V;
DO LLISA_AITAVLAPSIA = &MINIMI_LLISA_AITAVLAPSIA TO &MAKSIMI_LLISA_AITAVLAPSIA;
DO LLISA_ELATLAPSIA = &MINIMI_LLISA_ELATLAPSIA TO &MAKSIMI_LLISA_ELATLAPSIA;
DO LLISA_TUKIAIKA = &MINIMI_LLISA_TUKIAIKA TO &MAKSIMI_LLISA_TUKIAIKA;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, LLISA_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 6.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO LLisa_Simuloi_Esimerkki;
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL LLISA_PARAM LLISA_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(LLISA_PARAM, LLISA);
%HaeLaskettavatLokaalit(LLISA_MUUNNOS, LLISA);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &LLISA_PARAM;

DATA OUTPUT.&TULOSNIMI_LL;
SET OUTPUT.&TULOSNIMI_LL;

/* 3.2.1 Lasketaan lapsilis� */

IF &VUOSIKA = 2 THEN DO;
    %LLisaKS(LAPSILIS, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_PUOLISO, LLISA_LAPSIA_ALLE_3_V, LLISA_LAPSIA_3_15_V, LLISA_LAPSIA_16_V);
END;
ELSE DO;
    %LLisaVS(LAPSILIS, LLISA_VUOSI, INF, LLISA_PUOLISO, LLISA_LAPSIA_ALLE_3_V, LLISA_LAPSIA_3_15_V, LLISA_LAPSIA_16_V);
END;

/* Kuukausitaso */
LLISAK = LAPSILIS;
/* Vuositaso */
LLISAV = LAPSILIS * LLISA_TUKIAIKA;

DROP LAPSILIS;

/* 3.2.2 Lasketaan �itiysavustus */

IF &VUOSIKA = 2 THEN DO;
    %AitAvustKS(AITIYSAV, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_AITAVLAPSIA);
END;
ELSE DO;
    %AitAvustVS(AITIYSAV, LLISA_VUOSI, INF, LLISA_AITAVLAPSIA);
END;

/* 3.2.3 Lasketaan elatustuki */

IF &VUOSIKA = 2 THEN DO;
    %ElatTukiKS(ELATTUKI, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_PUOLISO, LLISA_ELATLAPSIA);
END;
ELSE DO;
    %ElatTukiVS(ELATTUKI, LLISA_VUOSI, INF, LLISA_PUOLISO, LLISA_ELATLAPSIA);
END;

/* Kuukausitaso */
ELATUSTUKIK = ELATTUKI;
/* Vuositaso */
ELATUSTUKIV = ELATTUKI * LLISA_TUKIAIKA;

DROP ELATTUKI;

DROP kuuknro taulu_&PLLISA w y z testi kuuid lapsia kkuuk;

/* 3.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL
LLISA_VUOSI = 'Lains��d�nt�vuosi'
LLISA_KUUK = 'Lains��d�nt�kuukausi'
LLISA_PUOLISO = 'Onko puolisoa, (0/1)'
LLISA_LAPSIA_ALLE_3_V = 'Alle 3-v. lasten lkm'
LLISA_LAPSIA_3_15_V = '3-15-v. lasten lkm'
LLISA_LAPSIA_16_V = '16-v. lasten lkm'
LLISA_AITAVLAPSIA = 'Syntyneiden tai adoptoitujen lasten lkm'
LLISA_ELATLAPSIA = 'Elatustukeen oikeuttavien lasten lkm'
LLISA_TUKIAIKA = 'Tukikuukaudet vuodessa, (kk)'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

LLISAK = 'Lapsilis�, (e/kk)'
AITIYSAV = '�itiysavustus, (e)'
ELATUSTUKIK = 'Elatustuki, (e/kk)'
LLISAV = 'Lapsilis�, (e/v)'
ELATUSTUKIV = 'Elatustuki, (e/v)' ;

/* M��ritell��n formaatilla haluttu desimaalierotin  */
/* ja n�ytett�vien desimaalien lukum��r� */

%IF &EROTIN = 1 %THEN %DO;
	FORMAT _NUMERIC_ 1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF 8.5;
%END;

%IF &EROTIN = 2 %THEN %DO;
	FORMAT _NUMERIC_ NUMx1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF NUMx8.5;
%END;

/* Kokonaislukuina ne muuttujat, joissa ei haluta k�ytt�� desimaalierotinta */

FORMAT LLISA_VUOSI LLISA_VUOSI LLISA_KUUK LLISA_PUOLISO LLISA_LAPSIA_ALLE_3_V LLISA_LAPSIA_3_15_V LLISA_LAPSIA_16_V 
LLISA_AITAVLAPSIA LLISA_ELATLAPSIA LLISA_TUKIAIKA 8.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
    DROP LLISA_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
    ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_LL..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_LL;
TITLE "ESIMERKKILASKELMA, LLISA";
RUN;

%IF &EXCEL = 1 %THEN %DO;
    ODS HTML3 CLOSE;
%END;


%MEND LLisa_Simuloi_Esimerkki;

%LLisa_Simuloi_Esimerkki;



