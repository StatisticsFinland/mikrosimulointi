/********************************************************************
* Kuvaus: Sairausvakuutuksen päivärahojen esimerkkilaskelmien pohja	*
* Viimeksi päivitetty: 10.3.2021			     		   			*
********************************************************************/  

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_SV = sairvak_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET AVUOSI = 2021; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko ;

* Käytettävien tiedostojen nimet;
* HUOM! Tulonhakkimiskulujen vähentämistä varten tarvitaan myös VERO-mallin makroja ja parametreja; 

%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* SAIRVAK-lakimakrotiedoston nimi ;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;		* VERO-lakimakrotiedoston nimi ;
%LET PSAIRVAK = psairvak; * Käytettävän SAIRVAK-parametritiedoston nimi ;
%LET PVERO = pvero;		  * Käytettävän VERO-parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_SAIRVAK_VUOSI = 2021;
%LET MAKSIMI_SAIRVAK_VUOSI = 2021;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_SAIRVAK_KUUK = 12;
%LET MAKSIMI_SAIRVAK_KUUK = 12;

* Onko kyse vanhempainrahasta (1 = tosi, 0 = epätosi));
%LET MINIMI_SAIRVAK_VANHRAHA = 0;
%LET MAKSIMI_SAIRVAK_VANHRAHA = 0;

* Onko kyse korotetusta äitiyspäivärahasta (1 = tosi, 0 = epätosi)
  (tarkoittaa 90 ensimmäiseltä äitiyslomapäivältä maksettavaa päivärahaa (2007-2015))
  (tarkoittaa 56 ensimmäiseltä äitiyslomapäivältä maksettavaa päivärahaa (2016-07/2022))
  (tarkoittaa 40 raskausrahapäivältä maksettavaa päivärahaa (08/2022-));
%LET MINIMI_SAIRVAK_KORAIT = 0;
%LET MAKSIMI_SAIRVAK_KORAIT = 0;

* Onko kyse korotetusta vanhempainrahasta (1 = tosi, 0 = epätosi)
  (tarkoittaa 56 päivältä maksettavaa korotettua päivärahaa (2007-2015))
  (tarkoittaa 16 päivältä maksettavaa korotettua päivärahaa (08/2022-));;
%LET MINIMI_SAIRVAK_KORVANH = 0;
%LET MAKSIMI_SAIRVAK_KORVANH = 0;

*Alle 18-v. lasten lukumäärä (Huom! Lapsikorotuksia ei ole laissa vuoden 1993 jälkeen);
%LET MINIMI_SAIRVAK_LAPSIA = 0;
%LET MAKSIMI_SAIRVAK_LAPSIA = 0; 

*Päivärahan perusteena oleva bruttopalkka ennen vähennyksiä (e/kk);
%LET MINIMI_SAIRVAK_KUUKPALK = 1000; 
%LET MAKSIMI_SAIRVAK_KUUKPALK = 1000;
%LET KYNNYS_SAIRVAK_KUUKPALK = 1000;

*Päivärahan perusteena oleva YEL- tai MYEL-työtulo (e/kk);
%LET MINIMI_SAIRVAK_YRIT = 0; 
%LET MAKSIMI_SAIRVAK_YRIT= 0;
%LET KYNNYS_SAIRVAK_YRIT = 1000;

* Tulonhankkimiskulut (e/kk);
%LET MINIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET MAKSIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET KYNNYS_SAIRVAK_TULONHANKKULUT = 100;

* Ay-jäsenmaksut (e/kk);
%LET MINIMI_SAIRVAK_AYMAKSUT = 0;
%LET MAKSIMI_SAIRVAK_AYMAKSUT = 0; 
%LET KYNNYS_SAIRVAK_AYMAKSUT = 10;

* Työmatkakulut (e/kk);
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
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL SAIRVAK_PARAM SAIRVAK_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(SAIRVAK_PARAM, SAIRVAK);
%HaeLaskettavatLokaalit(SAIRVAK_MUUNNOS, SAIRVAK);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &SAIRVAK_PARAM;

/* VERO-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL VERO_PARAM VERO_MUUNNOS VERO2_PARAM VERO2_MUUNNOS VERO_JOHDETUT;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(VERO_PARAM, VERO);
%HaeLaskettavatLokaalit(VERO_MUUNNOS, VERO);

/* Haetaan varallisuusveron käyttämien lakiparametrien nimet */
%HaeLokaalit(VERO2_PARAM, VERO_VARALL);
%HaeLaskettavatLokaalit(VERO2_MUUNNOS, VERO_VARALL, indikaattori='z');

/* Haetaan johdettavien muuttujien nimet */
%HaeLaskettavatLokaalit(VERO_JOHDETUT, VERO, indikaattori='j');

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &VERO_PARAM &VERO2_PARAM &VERO_JOHDETUT;
DATA OUTPUT.&TULOSNIMI_SV;
SET OUTPUT.&TULOSNIMI_SV;

/* Lakimakroissa tulokäsitteenä on vuositulo */

SAIRVAK_VUOSITULO = MAX(SUM(12 * SAIRVAK_KUUKPALK), 0);
SAIRVAK_YRITTULO = MAX(SUM(12 * SAIRVAK_YRIT), 0);

/* Korotetut vanhempainrahat lasketaan vain, jos SAIRVAK_VANHRAHA = 1 */

IF SAIRVAK_VANHRAHA = 0 THEN DO;
	SAIRVAK_KORVANH = 0;
	SAIRVAK_KORAIT = 0;
END;

/* Koska ei voi olla yhtä aikaa SAIRVAK_KORAIT = 1 ja SAIRVAK_KORVANH = 1,
   suljetaan ristiriitaiset tapaukset pois */

IF SAIRVAK_KORAIT = 1 THEN SAIRVAK_KORVANH = 0;

IF SAIRVAK_KORVANH = 1 THEN SAIRVAK_KORAIT = 0;

/* Lasketaan tulonhankkimiskulut muuttujaan SVHANKVAH */

%TulonHankKulutS(SVHANKVAH, SAIRVAK_VUOSI, INF, SAIRVAK_VUOSITULO,
	12*SAIRVAK_TULONHANKKULUT, 12*SAIRVAK_AYMAKSUT, 12*SAIRVAK_TYOMATKAKULUT, 0);

/* Vuodesta 2020 eteenpäin päivärahan laskennassa ei huomioida tulonhankkimiskuluja */

IF SAIRVAK_VUOSI >= 2020 THEN DO;
	SVHANKVAH = 0;
END;

/* 3.2.1 Tavalliset päivärahat */

IF SAIRVAK_KORAIT = 0 AND SAIRVAK_KORVANH = 0 THEN DO;

	IF &VUOSIKA = 1 THEN DO;
		%SairVakPrahaVS (SPRAHAK, SAIRVAK_VUOSI, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
 	END;
	ELSE DO;
		%SairVakPrahaKS (SPRAHAK, SAIRVAK_VUOSI, SAIRVAK_KUUK, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO, yrittaja = SAIRVAK_YRITTULO, tulonhankk = SVHANKVAH);
	END;
	
END;

/* 3.2.2 Korotetut päivärahat */

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

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
SAIRVAK_VUOSI = 'Lainsäädäntövuosi'
SAIRVAK_KUUK = 'Lainsäädäntökuukausi'
SAIRVAK_LAPSIA = 'Alle 18-v. lasten lkm'
SAIRVAK_KUUKPALK = 'Päivärahan perusteena oleva kuukausipalkka, (e)'
SAIRVAK_YRIT = 'Päivärahan perusteena oleva YEL- tai MYEL-työtulo (e/kk)'
SAIRVAK_TULONHANKKULUT = 'Tulonhankkimiskulut, (e/kk)'
SAIRVAK_AYMAKSUT = 'Ay-jäsenmaksut, (e/kk)'
SAIRVAK_TYOMATKAKULUT = 'Työmatkakulut, (e/kk)'
SAIRVAK_VUOSITULO = 'Päivärahan perusteena oleva bruttovuositulo ennen vähennyksiä, (e)'
SAIRVAK_YRITTULO = 'Päivärahan perusteena oleva YEL- tai MYEL-työtulo ennen vähennyksiä, (e)'
SVHANKVAH = 'Päivärahan laskennassa vähennetyt tulonhankkimiskulut (e/v)'
SAIRVAK_VANHRAHA = 'Onko vanhempainpäiväraha, (0/1)'
SAIRVAK_KORAIT = 'Onko korotettu äitiyspäiväraha, (0/1)'
SAIRVAK_KORVANH = 'Onko korotettu vanhempainraha, (0/1)'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

SPRAHAK = 'Päiväraha, (e/kk)'
SPRAHAV = 'Päiväraha, (e/v)'
SPRAHAP = 'Päiväraha, (e/pv)';

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


