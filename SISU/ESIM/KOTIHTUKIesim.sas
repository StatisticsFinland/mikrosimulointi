/***********************************************************
* Kuvaus: Kotihoidontuen esimerkkilaskelmien pohja         *
* Viimeksi p‰ivitetty: 10.3.2021			     		   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KT = kotihtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET AVUOSI = 2021; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K‰ytett‰v‰ indeksien parametritaulukko ;

* K‰ytett‰vien tiedostojen nimet;

%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PKOTIHTUKI = pkotihtuki; * K‰ytett‰v‰n parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lains‰‰d‰ntˆvuosi (1985-);
%LET MINIMI_KOTIHTUKI_VUOSI = 2021;
%LET MAKSIMI_KOTIHTUKI_VUOSI = 2021;

* Lains‰‰d‰ntˆkuukausi (1-12);
%LET MINIMI_KOTIHTUKI_KUUK = 12;
%LET MAKSIMI_KOTIHTUKI_KUUK = 12;

* Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰;
* HUOM! Jos arvo = 0, alle 3-vuotiaita lapsia on siis yksi!;
%LET MINIMI_KOTIHTUKI_SISARIA = 0; 
%LET MAKSIMI_KOTIHTUKI_SISARIA = 0; 

* Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰;
%LET MINIMI_KOTIHTUKI_MUUALLEKOULUIK = 0; 
%LET MAKSIMI_KOTIHTUKI_MUUALLEKOULUIK = 0;

* Aikuisten lukum‰‰r‰ perheess‰ (1/2);
%LET MINIMI_KOTIHTUKI_AIKLKM = 1; 
%LET MAKSIMI_KOTIHTUKI_AIKLKM = 2; 

* Bruttotulo, (e/kk) (k‰ytˆss‰ 1.1.1991 l‰htien);
%LET MINIMI_KOTIHTUKI_BRUTTOTULO = 0; 
%LET MAKSIMI_KOTIHTUKI_BRUTTOTULO = 2500;  
%LET KYNNYS_KOTIHTUKI_BRUTTOTULO = 2500;

* Nettotulo, (e/kk) (k‰ytˆss‰ ennen 1.1.1991);
%LET MINIMI_KOTIHTUKI_NETTOTULO = 0;
%LET MAKSIMI_KOTIHTUKI_NETTOTULO = 2500;
%LET KYNNYS_KOTIHTUKI_NETTOTULO = 2500;

* Tukikuukaudet vuodessa;
%LET MINIMI_KOTIHTUKI_TUKIAIKA = 2 ; 
%LET MAKSIMI_KOTIHTUKI_TUKIAIKA = 2 ;

* Osittaisen tai joustavan hoitorahan kohteena olevan lapsen ik‰luokka: 1 = alle 3-vuotias, 2 = 1-2-luokkalainen;
%LET MINIMI_KOTIHTUKI_OSITTIKA = 1;
%LET MAKSIMI_KOTIHTUKI_OSITTIKA = 1;

* Osittaista tai joustavaa hoitorahaa hakevan henkilˆn tyˆtuntien m‰‰r‰ viikossa;
%LET MINIMI_KOTIHTUKI_VIIKKOTUN = 15; 
%LET MAKSIMI_KOTIHTUKI_VIIKKOTUN = 15; 
%LET KYNNYS_KOTIHTUKI_VIIKKOTUN = 15; 

%END;

/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KT;

DO KOTIHTUKI_VUOSI = &MINIMI_KOTIHTUKI_VUOSI TO &MAKSIMI_KOTIHTUKI_VUOSI;
DO KOTIHTUKI_KUUK = &MINIMI_KOTIHTUKI_KUUK TO &MAKSIMI_KOTIHTUKI_KUUK;
DO KOTIHTUKI_SISARIA = &MINIMI_KOTIHTUKI_SISARIA TO &MAKSIMI_KOTIHTUKI_SISARIA;
DO KOTIHTUKI_MUUALLEKOULUIK = &MINIMI_KOTIHTUKI_MUUALLEKOULUIK TO &MAKSIMI_KOTIHTUKI_MUUALLEKOULUIK; 
DO KOTIHTUKI_AIKLKM = &MINIMI_KOTIHTUKI_AIKLKM TO &MAKSIMI_KOTIHTUKI_AIKLKM;
DO KOTIHTUKI_BRUTTOTULO = &MINIMI_KOTIHTUKI_BRUTTOTULO TO &MAKSIMI_KOTIHTUKI_BRUTTOTULO BY &KYNNYS_KOTIHTUKI_BRUTTOTULO;
DO KOTIHTUKI_NETTOTULO = &MINIMI_KOTIHTUKI_NETTOTULO TO &MAKSIMI_KOTIHTUKI_NETTOTULO BY &KYNNYS_KOTIHTUKI_NETTOTULO;
DO KOTIHTUKI_TUKIAIKA = &MINIMI_KOTIHTUKI_TUKIAIKA TO &MAKSIMI_KOTIHTUKI_TUKIAIKA;
DO KOTIHTUKI_OSITTIKA = &MINIMI_KOTIHTUKI_OSITTIKA TO &MAKSIMI_KOTIHTUKI_OSITTIKA; 
DO KOTIHTUKI_VIIKKOTUN = &MINIMI_KOTIHTUKI_VIIKKOTUN TO &MAKSIMI_KOTIHTUKI_VIIKKOTUN BY &KYNNYS_KOTIHTUKI_VIIKKOTUN; 

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, KOTIHTUKI_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;
RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO KotihTuki_Simuloi_Esimerkki;
/* KOTIHTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL KOTIHTUKI_PARAM KOTIHTUKI_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(KOTIHTUKI_PARAM, KOTIHTUKI);
%HaeLaskettavatLokaalit(KOTIHTUKI_MUUNNOS, KOTIHTUKI);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KOTIHTUKI_PARAM;

DATA OUTPUT.&TULOSNIMI_KT;
SET OUTPUT.&TULOSNIMI_KT;

/* 3.2.1 Lasketaan kotihoidontuki */

* Muodostetaan muuttuja perheen j‰senten lukum‰‰r‰lle ;

KOTIHTUKI_KOKO = SUM(1, KOTIHTUKI_AIKLKM, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK);

IF &VUOSIKA = 2 THEN DO;
	%KotihTukiKS(KTUKI, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK, KOTIHTUKI_KOKO, KOTIHTUKI_BRUTTOTULO, KOTIHTUKI_NETTOTULO);
END;
ELSE DO;
	%KotihTukiVS(KTUKI, KOTIHTUKI_VUOSI, INF, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK, KOTIHTUKI_KOKO, KOTIHTUKI_BRUTTOTULO, KOTIHTUKI_NETTOTULO);
END;
	
/* Kuukausitaso */
KOTIHTUKIK = KTUKI;
/* Vuositaso */ 
KOTIHTUKIV = KTUKI * KOTIHTUKI_TUKIAIKA;

DROP KTUKI;

/* 3.2.2 Lasketaan osittainen ja joustava hoitoraha */

IF KOTIHTUKI_VUOSI >= 2014 THEN DO; 
	IF KOTIHTUKI_OSITTIKA = 1 THEN DO;
		IF &VUOSIKA = 2 THEN DO;
			ORAHA = 0;
			%JoustHoitRahaTunnS(JRAHA, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF, KOTIHTUKI_VIIKKOTUN);
		END;
		ELSE DO;
			ORAHA = 0;
			%JoustHoitRahaTunnVS(JRAHA, KOTIHTUKI_VUOSI, INF, KOTIHTUKI_VIIKKOTUN);
		END;
	END;
	ELSE IF KOTIHTUKI_OSITTIKA = 2 THEN DO;
		IF &VUOSIKA = 2 THEN DO;
			%OsitHoitRahaTunnS(ORAHA, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF, KOTIHTUKI_VIIKKOTUN);
			JRAHA = 0;
		END;
		ELSE DO;
			%OsitHoitRahaTunnVS(ORAHA, KOTIHTUKI_VUOSI, INF, KOTIHTUKI_VIIKKOTUN);
			JRAHA = 0;
		END;
	END;
	ELSE DO;
		JRAHA = 0;
		ORAHA = 0;
	END;
END;  
ELSE DO; 
	IF (KOTIHTUKI_OSITTIKA = 1 OR KOTIHTUKI_OSITTIKA = 2) THEN DO;
		IF &VUOSIKA = 2 THEN DO;
			%OsitHoitRahaTunnS(ORAHA, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF, KOTIHTUKI_VIIKKOTUN);
			JRAHA = 0;
		END;
		ELSE DO;
			%OsitHoitRahaTunnVS(ORAHA, KOTIHTUKI_VUOSI, INF, KOTIHTUKI_VIIKKOTUN);
			JRAHA = 0;
		END;
	END;
	ELSE DO;
		ORAHA = 0;
		JRAHA = 0;
	END;
END; 

/* Kuukausitaso */
OHRAHAK = ORAHA;
/* Vuositaso */ 
OHRAHAV = ORAHA * KOTIHTUKI_TUKIAIKA;
/* Kuukausitaso */
JHRAHAK = JRAHA; 
/* Vuositaso */ 
JHRAHAV = JRAHA * KOTIHTUKI_TUKIAIKA;  

DROP ORAHA JRAHA kuuknro kkuuk w y z testi kuuid taulu_&PKOTIHTUKI;

/* 3.3 M‰‰ritell‰‰n muuttujille selkokieliset selitteet */

LABEL 
KOTIHTUKI_VUOSI = 'Lains‰‰d‰ntˆvuosi'
KOTIHTUKI_KUUK = 'Lains‰‰d‰ntˆkuukausi'
KOTIHTUKI_SISARIA = 'Kotihoidossa olevien alle 3-vuotiaiden sisarten lkm'
KOTIHTUKI_MUUALLEKOULUIK = 'Muiden alle kouluik‰isten hoitolasten lkm'
KOTIHTUKI_AIKLKM = 'Aikuisten lkm perheess‰'
KOTIHTUKI_KOKO = 'Perheenj‰senten lkm' 
KOTIHTUKI_BRUTTOTULO = 'Bruttotulo, (e/kk) (1.1.1991 l‰htien)'
KOTIHTUKI_NETTOTULO = 'Nettotulo, (e/kk) (ennen 1.1.1991)'
KOTIHTUKI_TUKIAIKA = 'Tukikuukaudet vuodessa, (kk)'

KOTIHTUKI_OSITTIKA = 'Osittaisen tai joustavan hoitorahan kohteena olevan lapsen ik‰luokka: 1 = alle 3-vuotias, 2 = 1-2-luokkalainen' 
KOTIHTUKI_VIIKKOTUN = 'Osittaista tai joustavaa hoitorahaa hakevan henkilˆn tyˆtuntien m‰‰r‰ viikossa, (t)' 

INF = 'Inflaatiokorjauksessa k‰ytett‰v‰ kerroin'

KOTIHTUKIK = 'Kotihoidon tuki, (e/kk)' 
KOTIHTUKIV = 'Kotihoidon tuki, (e/v)' 
OHRAHAK = 'Osittainen hoitoraha, (e/kk)' 
OHRAHAV = 'Osittainen hoitoraha, (e/v)'
JHRAHAK = 'Joustava hoitoraha, (e/kk) (1.1.2014 l‰htien)' 
JHRAHAV = 'Joustava hoitoraha, (e/v) (1.1.2014 l‰htien)'; 

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

FORMAT KOTIHTUKI_VUOSI KOTIHTUKI_KUUK KOTIHTUKI_SISARIA KOTIHTUKI_MUUALLEKOULUIK KOTIHTUKI_AIKLKM KOTIHTUKI_KOKO 
KOTIHTUKI_TUKIAIKA KOTIHTUKI_OSITTIKA 8.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP KOTIHTUKI_KUUK;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_KT, KOTIHTUKI);

%MEND KotihTuki_Simuloi_Esimerkki;

%KotihTuki_Simuloi_Esimerkki;
