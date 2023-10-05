/********************************************************************
* Kuvaus: Sairausvakuutuksen p�iv�rahojen esimerkkilaskelmien pohja	*
* Viimeksi p�ivitetty: 10.3.2021			     		   			*
********************************************************************/  

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_SV = sairvak_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
* HUOM! Tulonhakkimiskulujen v�hent�mist� varten tarvitaan my�s VERO-mallin makroja ja parametreja; 

%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* SAIRVAK-lakimakrotiedoston nimi ;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;		* VERO-lakimakrotiedoston nimi ;
%LET PSAIRVAK = psairvak; * K�ytett�v�n SAIRVAK-parametritiedoston nimi ;
%LET PVERO = pvero;		  * K�ytett�v�n VERO-parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1985-);
%LET MINIMI_SAIRVAK_VUOSI = 2021;
%LET MAKSIMI_SAIRVAK_VUOSI = 2021;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_SAIRVAK_KUUK = 12;
%LET MAKSIMI_SAIRVAK_KUUK = 12;

* Onko kyse vanhempainrahasta (1 = tosi, 0 = ep�tosi));
%LET MINIMI_SAIRVAK_VANHRAHA = 0;
%LET MAKSIMI_SAIRVAK_VANHRAHA = 0;

* Onko kyse korotetusta �itiysp�iv�rahasta (1 = tosi, 0 = ep�tosi)
  (tarkoittaa 90 ensimm�iselt� �itiyslomap�iv�lt� maksettavaa p�iv�rahaa (2007-2015))
  (tarkoittaa 56 ensimm�iselt� �itiyslomap�iv�lt� maksettavaa p�iv�rahaa (2016-07/2022))
  (tarkoittaa 40 raskausrahap�iv�lt� maksettavaa p�iv�rahaa (08/2022-));
%LET MINIMI_SAIRVAK_KORAIT = 0;
%LET MAKSIMI_SAIRVAK_KORAIT = 0;

* Onko kyse korotetusta vanhempainrahasta (1 = tosi, 0 = ep�tosi)
  (tarkoittaa 56 p�iv�lt� maksettavaa korotettua p�iv�rahaa (2007-2015))
  (tarkoittaa 16 p�iv�lt� maksettavaa korotettua p�iv�rahaa (08/2022-));;
%LET MINIMI_SAIRVAK_KORVANH = 0;
%LET MAKSIMI_SAIRVAK_KORVANH = 0;

*Alle 18-v. lasten lukum��r� (Huom! Lapsikorotuksia ei ole laissa vuoden 1993 j�lkeen);
%LET MINIMI_SAIRVAK_LAPSIA = 0;
%LET MAKSIMI_SAIRVAK_LAPSIA = 0; 

*P�iv�rahan perusteena oleva bruttopalkka ennen v�hennyksi� (e/kk);
%LET MINIMI_SAIRVAK_KUUKPALK = 1000; 
%LET MAKSIMI_SAIRVAK_KUUKPALK = 1000;
%LET KYNNYS_SAIRVAK_KUUKPALK = 1000;

*P�iv�rahan perusteena oleva YEL- tai MYEL-ty�tulo (e/kk);
%LET MINIMI_SAIRVAK_YRIT = 0; 
%LET MAKSIMI_SAIRVAK_YRIT= 0;
%LET KYNNYS_SAIRVAK_YRIT = 1000;

* Tulonhankkimiskulut (e/kk);
%LET MINIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET MAKSIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET KYNNYS_SAIRVAK_TULONHANKKULUT = 100;

* Ay-j�senmaksut (e/kk);
%LET MINIMI_SAIRVAK_AYMAKSUT = 0;
%LET MAKSIMI_SAIRVAK_AYMAKSUT = 0; 
%LET KYNNYS_SAIRVAK_AYMAKSUT = 10;

* Ty�matkakulut (e/kk);
%LET MINIMI_SAIRVAK_TYOMATKAKULUT = 0;
%LET MAKSIMI_SAIRVAK_TYOMATKAKULUT = 0; 
%LET KYNNYS_SAIRVAK_TYOMATKAKULUT = 100;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_SV;

DO SAIRVAK_VUOSI = &MINIMI_SAIRVAK_VUOSI TO &MAKSIMI_SAIRVAK_VUOSI;
DO SAIRVAK_KUUK = &MINIMI_SAIRVAK_KUUK TO &MAKSIMI_SAIRVAK_KUUK;
DO SAIRVAK_LAPSIA = &MINIMI_SAIRVAK_LAPSIA TO &MAKSIMI_SAIRVAK_LAPSIA;
DO SAIRVAK_KUUKPALK = &MINIMI_SAIRVAK_KUUKPALK TO &MAKSIMI_SAIRVAK_KUUKPALK BY &KYNNYS_SAIRVAK_KUUKPALK;
DO SAIRVAK_YRIT = &MINIMI_SAIRVAK_YRIT TO &MAKSIMI_SAIRVAK_YRIT BY &KYNNYS_SAIRVAK_YRIT;  
DO SAIRVAK_VANHRAHA = &MINIMI_SAIRVAK_VANHRAHA TO &MAKSIMI_SAIRVAK_VANHRAHA;
DO SAIRVAK_KORAIT = &MINIMI_SAIRVAK_KORAIT TO &MAKSIMI_SAIRVAK_KORAIT;
DO SAIRVAK_KORVANH = &MINIMI_SAIRVAK_KORVANH TO &MAKSIMI_SAIRVAK_KORVANH;
DO SAIRVAK_TULONHANKKULUT = &MINIMI_SAIRVAK_TULONHANKKULUT TO &MAKSIMI_SAIRVAK_TULONHANKKULUT BY &KYNNYS_SAIRVAK_TULONHANKKULUT;
DO SAIRVAK_AYMAKSUT = &MINIMI_SAIRVAK_AYMAKSUT TO &MAKSIMI_SAIRVAK_AYMAKSUT BY &KYNNYS_SAIRVAK_AYMAKSUT;
DO SAIRVAK_TYOMATKAKULUT = &MINIMI_SAIRVAK_TYOMATKAKULUT TO &MAKSIMI_SAIRVAK_TYOMATKAKULUT BY &KYNNYS_SAIRVAK_TYOMATKAKULUT;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, SAIRVAK_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO SairVak_Simuloi_Esimerkki;
/* SAIRVAK-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL SAIRVAK_PARAM SAIRVAK_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(SAIRVAK_PARAM, SAIRVAK);
%HaeLaskettavatLokaalit(SAIRVAK_MUUNNOS, SAIRVAK);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &SAIRVAK_PARAM;

/* VERO-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL VERO_PARAM VERO_MUUNNOS VERO2_PARAM VERO2_MUUNNOS VERO_JOHDETUT;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(VERO_PARAM, VERO);
%HaeLaskettavatLokaalit(VERO_MUUNNOS, VERO);

/* Haetaan varallisuusveron k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(VERO2_PARAM, VERO_VARALL);
%HaeLaskettavatLokaalit(VERO2_MUUNNOS, VERO_VARALL, indikaattori='z');

/* Haetaan johdettavien muuttujien nimet */
%HaeLaskettavatLokaalit(VERO_JOHDETUT, VERO, indikaattori='j');

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &VERO_PARAM &VERO2_PARAM &VERO_JOHDETUT;
DATA OUTPUT.&TULOSNIMI_SV;
SET OUTPUT.&TULOSNIMI_SV;

/* Lakimakroissa tulok�sitteen� on vuositulo */

SAIRVAK_VUOSITULO = MAX(SUM(12 * SAIRVAK_KUUKPALK), 0);
SAIRVAK_YRITTULO = MAX(SUM(12 * SAIRVAK_YRIT), 0);

/* Korotetut vanhempainrahat lasketaan vain, jos SAIRVAK_VANHRAHA = 1 */

IF SAIRVAK_VANHRAHA = 0 THEN DO;
	SAIRVAK_KORVANH = 0;
	SAIRVAK_KORAIT = 0;
END;

/* Koska ei voi olla yht� aikaa SAIRVAK_KORAIT = 1 ja SAIRVAK_KORVANH = 1,
   suljetaan ristiriitaiset tapaukset pois */

IF SAIRVAK_KORAIT = 1 THEN SAIRVAK_KORVANH = 0;

IF SAIRVAK_KORVANH = 1 THEN SAIRVAK_KORAIT = 0;

/* Lasketaan tulonhankkimiskulut muuttujaan SVHANKVAH */

%TulonHankKulutS(SVHANKVAH, SAIRVAK_VUOSI, INF, SAIRVAK_VUOSITULO,
	12*SAIRVAK_TULONHANKKULUT, 12*SAIRVAK_AYMAKSUT, 12*SAIRVAK_TYOMATKAKULUT, 0);

/* Vuodesta 2020 eteenp�in p�iv�rahan laskennassa ei huomioida tulonhankkimiskuluja */

IF SAIRVAK_VUOSI >= 2020 THEN DO;
	SVHANKVAH = 0;
END;

/* 3.2.1 Tavalliset p�iv�rahat */

IF SAIRVAK_KORAIT = 0 AND SAIRVAK_KORVANH = 0 THEN DO;

	IF &VUOSIKA = 1 THEN DO;
		%SairVakPrahaVS (SPRAHAK, SAIRVAK_VUOSI, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
 	END;
	ELSE DO;
		%SairVakPrahaKS (SPRAHAK, SAIRVAK_VUOSI, SAIRVAK_KUUK, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
	END;
	
END;

/* 3.2.2 Korotetut p�iv�rahat */

ELSE DO;

	IF &VUOSIKA = 1 THEN DO;
		%KorVanhRahaVS (SPRAHAK, SAIRVAK_VUOSI, INF, SAIRVAK_KORAIT, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
	END;
	ELSE DO;
		%KorVanhRahaKS (SPRAHAK, SAIRVAK_VUOSI, SAIRVAK_KUUK, INF, SAIRVAK_KORAIT, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
	END;

END;	


SPRAHAP = SPRAHAK / &SPaivat;
		
SPRAHAV = 12 *  SPRAHAK;

DROP kuuknro w y z testi kkuuk taulu_&PSAIRVAK taulu_&PVERO;

/* 3.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
SAIRVAK_VUOSI = 'Lains��d�nt�vuosi'
SAIRVAK_KUUK = 'Lains��d�nt�kuukausi'
SAIRVAK_LAPSIA = 'Alle 18-v. lasten lkm'
SAIRVAK_KUUKPALK = 'P�iv�rahan perusteena oleva kuukausipalkka, (e)'
SAIRVAK_YRIT = 'P�iv�rahan perusteena oleva YEL- tai MYEL-ty�tulo (e/kk)'
SAIRVAK_TULONHANKKULUT = 'Tulonhankkimiskulut, (e/kk)'
SAIRVAK_AYMAKSUT = 'Ay-j�senmaksut, (e/kk)'
SAIRVAK_TYOMATKAKULUT = 'Ty�matkakulut, (e/kk)'
SAIRVAK_VUOSITULO = 'P�iv�rahan perusteena oleva bruttovuositulo ennen v�hennyksi�, (e)'
SAIRVAK_YRITTULO = 'P�iv�rahan perusteena oleva YEL- tai MYEL-ty�tulo ennen v�hennyksi�, (e)'
SVHANKVAH = 'P�iv�rahan laskennassa v�hennetyt tulonhankkimiskulut (e/v)'
SAIRVAK_VANHRAHA = 'Onko vanhempainp�iv�raha, (0/1)'
SAIRVAK_KORAIT = 'Onko korotettu �itiysp�iv�raha, (0/1)'
SAIRVAK_KORVANH = 'Onko korotettu vanhempainraha, (0/1)'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

SPRAHAK = 'P�iv�raha, (e/kk)'
SPRAHAV = 'P�iv�raha, (e/v)'
SPRAHAP = 'P�iv�raha, (e/pv)';

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

FORMAT SAIRVAK_VUOSI SAIRVAK_KUUK SAIRVAK_LAPSIA SAIRVAK_VANHRAHA SAIRVAK_KORAIT SAIRVAK_KORVANH 8.;

KEEP &VALITUT;

%IF &VUOSIKA NE 2 %THEN %DO;
	DROP SAIRVAK_KUUK;
%END;

RUN;


* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_SV, SAIRVAK);


%MEND SairVak_Simuloi_Esimerkki;

%SairVak_Simuloi_Esimerkki;


