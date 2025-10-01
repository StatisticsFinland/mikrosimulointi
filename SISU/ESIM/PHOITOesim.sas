/***********************************************************
* Kuvaus: Päivähoidon esimerkkilaskelmien pohja   	       *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_PH = phoito_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lainsäädäntö ;
%LET VALITUT = _ALL_;	* Tulostaulukossa näytettävät muuttujat ;
%LET EROTIN = 2;		* Tulosteessa käytettävä desimaalierotin, 1 = piste tai 2 = pilkku;
%LET DESIMAALIT = 2;	* Tulosteessa käytettävä desimaalien määrä (0-9);
%LET EXCEL = 1;			* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

* Inflaatiokorjaus. Euro- tai markkamääräisten parametrien haun yhteydessä suoritettavassa
  deflatoinnissa käytettävän kertoimen voi syöttää itse INF-makromuuttujaan
  (HUOM! desimaalit erotettava pisteellä .). Esim. jos yksi lainsäädäntövuoden euro on
  peruvuoden rahassa 95 senttiä, syötä arvoksi 0.95.
  Simuloinnin tulokset ilmoitetaan aina perusvuoden rahassa.
  Jos puolestaan haluaa käyttää automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

%LET INF = 1.00; * Syötä lukuarvo, KHI tai ATI;
%LET AVUOSI = 2025; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko ;

* Käytettävien tiedostojen nimet;  

%LET LAKIMAK_TIED_PH = PHOITOlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PPHOITO = pphoito; * Käytettävän parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_PHOITO_VUOSI = 2025;
%LET MAKSIMI_PHOITO_VUOSI = 2025;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_PHOITO_KUUK = 12;
%LET MAKSIMI_PHOITO_KUUK = 12;

* Tukikuukaudet vuodessa;
%LET MINIMI_PHOITO_TUKIAIKA = 12 ; 
%LET MAKSIMI_PHOITO_TUKIAIKA = 12 ;

* Onko puolisoa (0 = ei puolisoa, 1 = on puoliso);
%LET MINIMI_PHOITO_PUOLISO = 1;
%LET MAKSIMI_PHOITO_PUOLISO = 1;

* Päivähoitoikäisten lasten lkm; 
%LET MINIMI_PHOITO_PHLAPSIA = 1; 
%LET MAKSIMI_PHOITO_PHLAPSIA = 3;  

* Monesko sisar päivähoidossa (nuorin = 1);
%LET MINIMI_PHOITO_SISAR = 1; 
%LET MAKSIMI_PHOITO_SISAR = 1;  

* Muiden lasten lkm; 
%LET MINIMI_PHOITO_MUITALAPSIA = 1; 
%LET MAKSIMI_PHOITO_MUITALAPSIA = 1;  

* Päivähoitomaksujen perusteena oleva tulo, e/kk;
%LET MINIMI_PHOITO_TULO = 3500; 
%LET MAKSIMI_PHOITO_TULO = 3500;  
%LET KYNNYS_PHOITO_TULO = 500;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_PH;

DO PHOITO_VUOSI = &MINIMI_PHOITO_VUOSI TO &MAKSIMI_PHOITO_VUOSI;
DO PHOITO_KUUK = &MINIMI_PHOITO_KUUK TO &MAKSIMI_PHOITO_KUUK;
DO PHOITO_PUOLISO = &MINIMI_PHOITO_PUOLISO TO &MAKSIMI_PHOITO_PUOLISO;
DO PHOITO_PHLAPSIA = &MINIMI_PHOITO_PHLAPSIA TO &MAKSIMI_PHOITO_PHLAPSIA; 
DO PHOITO_SISAR = &MINIMI_PHOITO_SISAR TO &MAKSIMI_PHOITO_SISAR;
DO PHOITO_MUITALAPSIA = &MINIMI_PHOITO_MUITALAPSIA TO &MAKSIMI_PHOITO_MUITALAPSIA;
DO PHOITO_TULO = &MINIMI_PHOITO_TULO TO &MAKSIMI_PHOITO_TULO BY &KYNNYS_PHOITO_TULO;
DO PHOITO_TUKIAIKA = &MINIMI_PHOITO_TUKIAIKA TO &MAKSIMI_PHOITO_TUKIAIKA;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, PHOITO_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO PHoito_Simuloi_Esimerkki;
/* KOTIHTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL PHOITO_PARAM PHOITO_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(PHOITO_PARAM, PHOITO);
%HaeLaskettavatLokaalit(PHOITO_MUUNNOS, PHOITO);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &PHOITO_PARAM;

DATA OUTPUT.&TULOSNIMI_PH;
SET OUTPUT.&TULOSNIMI_PH;

/* 3.2.1 Lasketaan päivähoitomaksu (yhdestä lapsesta) */

IF &VUOSIKA = 2 THEN DO;
	%PHoitomaksuS(PMAKSU, PHOITO_VUOSI, PHOITO_KUUK, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_SISAR, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;
ELSE DO; 
	%PHoitomaksuVS(PMAKSU, PHOITO_VUOSI, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_SISAR, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;

/* Kuukausitaso */
PHOITOMAKSUK = PMAKSU;
/* Vuositaso */ 
PHOITOMAKSUV = PMAKSU * PHOITO_TUKIAIKA;

DROP PMAKSU;

/* 3.2.2 Lasketaan päivähoitomaksu (useasta lapsesta) */

IF &VUOSIKA = 2 THEN DO;
	%SumPHoitoMaksuS(SUMPMAKSU, PHOITO_VUOSI, PHOITO_KUUK, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;
ELSE DO;
	%SumPHoitoMaksuVS(SUMPMAKSU, PHOITO_VUOSI, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;

/* Kuukausitaso */
SUMPHOITOMAKSUK = SUMPMAKSU;
/* Vuositaso */ 
SUMPHOITOMAKSUV = SUMPMAKSU * PHOITO_TUKIAIKA;

DROP SUMPMAKSU;

DROP kuuknro kkuuk w y z testi kuuid koko taulu_&PPHOITO;

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
PHOITO_VUOSI = 'Lainsäädäntövuosi'
PHOITO_KUUK = 'Lainsäädäntökuukausi'
PHOITO_PUOLISO = 'Onko puolisoa, (0/1)'
PHOITO_PHLAPSIA = 'Päivähoitoikäisten lasten lkm'
PHOITO_SISAR = 'Monesko sisar päivähoidossa (nuorin = 1)' 
PHOITO_MUITALAPSIA = 'Muiden lasten lkm'
PHOITO_TULO = 'Päivähoitomaksujen perusteena oleva tulo, (e/kk)'
PHOITO_TUKIAIKA = 'Tukikuukaudet vuodessa, (kk)'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

PHOITOMAKSUK = 'Päivähoitomaksu (yhdestä lapsesta), (e/kk)' 
PHOITOMAKSUV = 'Päivähoitomaksu (yhdestä lapsesta), (e/v)' 
SUMPHOITOMAKSUK = 'Päivähoitomaksu (useammasta lapsesta), (e/kk)' 
SUMPHOITOMAKSUV = 'Päivähoitomaksu (useammasta lapsesta), (e/v)' ;

/* Määritellään formaatilla haluttu desimaalierotin  */
/* ja näytettävien desimaalien lukumäärä */

%IF &EROTIN = 1 %THEN %DO;
	FORMAT _NUMERIC_ 1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF 8.5;
%END;

%IF &EROTIN = 2 %THEN %DO;
	FORMAT _NUMERIC_ NUMx1&DESIMAALIT..&DESIMAALIT;
	FORMAT INF NUMx8.5;
%END;

/* Kokonaislukuina ne muuttujat, joissa ei haluta käyttää desimaalierotinta */

FORMAT PHOITO_VUOSI PHOITO_KUUK PHOITO_PUOLISO PHOITO_PHLAPSIA PHOITO_SISAR PHOITO_MUITALAPSIA PHOITO_TUKIAIKA 8.;

KEEP &VALITUT;

%IF &VUOSIKA NE 2 %THEN %DO;
	DROP PHOITO_KUUK;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_PH, PHOITO);

%MEND PHoito_Simuloi_Esimerkki;

%PHoito_Simuloi_Esimerkki;

