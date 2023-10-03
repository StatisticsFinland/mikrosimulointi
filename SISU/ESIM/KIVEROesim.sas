/***********************************************************
* Kuvaus: Kiinteistöverotuksen esimerkkilaskelmien pohja   *
* Viimeksi päivitetty: 10.3.2021		     		       *
***********************************************************/

/*
ESIMERKKILASKENNASSA LASKETAAN PIENTALOILLE, MAAPOHJALLE JA VAPAA-AJAN ASUNNOILLE KIINTEISTÖVERO. 
*/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; 			* Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KV = kivero_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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

%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PKIVERO = pkivero; * Käytettävän parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KV..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (2009-);
%LET MINIMI_KIVERO_VUOSI = 2021;
%LET MAKSIMI_KIVERO_VUOSI = 2021;

/******************************************************/
/* KÄYTETÄÄN SEKÄ PIENTALOJEN ETTÄ VAPAA-AJAN ASUNTOJEN KIINTEISTÖVERON LASKENNASSA */

* Rakennustyyppi (1 = pientalo, 2 = vapaa-ajan asunto);
%LET MINIMI_KIVERO_RAKTYYPPI = 1; 
%LET MAKSIMI_KIVERO_RAKTYYPPI = 1;

* Rakennuksen valmistumisvuosi;
%LET MINIMI_KIVERO_VALMVUOSI = 2010;
%LET MAKSIMI_KIVERO_VALMVUOSI = 2010; 
%LET KYNNYS_KIVERO_VALMVUOSI = 1;

* Kantava rakenne (1 = puu, 2 = kivi);
%LET MINIMI_KIVERO_KANTARAKENNE = 2; 
%LET MAKSIMI_KIVERO_KANTARAKENNE = 2;
	
* Rakennuksen pinta-ala m2;
%LET MINIMI_KIVERO_RAKENNUSPA = 100; 
%LET MAKSIMI_KIVERO_RAKENNUSPA = 100;
%LET KYNNYS_KIVERO_RAKENNUSPA = 10;		

* Rakennukselle määrätty kiinteistöveroprosentti;
%LET MINIMI_KIVERO_VEROPROS = 0.30; 
%LET MAKSIMI_KIVERO_VEROPROS = 0.8;
%LET KYNNYS_KIVERO_VEROPROS = 0.1;

* Sähkökoodi (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_SAHKOK = 1; 
%LET MAKSIMI_KIVERO_SAHKOK = 1;			

* Vesijohtotieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_VESIK = 1; 
%LET MAKSIMI_KIVERO_VESIK = 1;

/******************************************************/
/* KÄYTETÄÄN VAIN PIENTALOJEN KIINTEISTÖVERON LASKENNASSA */

* Pientalon viimeistelemättömän kellarin pinta-ala (m2);
%LET MINIMI_KIVERO_KELLARIPA = 0; 
%LET MAKSIMI_KIVERO_KELLARIPA = 0;
%LET KYNNYS_KIVERO_KELLARIPA = 10;	
	
* Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys);
%LET MINIMI_KIVERO_LAMMITYSK = 1; 
%LET MAKSIMI_KIVERO_LAMMITYSK = 1;	

/******************************************************/
/* KÄYTETÄÄN VAIN VAPAA-AJAN ASUNTOJEN KIINTEISTÖVERON LASKENNASSA */

* Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_TALVIASK = 0; 
%LET MAKSIMI_KIVERO_TALVIASK = 0;	

* Viemäritieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_VIEMARIK = 0; 
%LET MAKSIMI_KIVERO_VIEMARIK = 0;

* Vapaa-ajan asunnon wc-tieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_WCK = 0; 
%LET MAKSIMI_KIVERO_WCK = 0;	

* Vapaa-ajan asunnon saunatieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_SAUNAK = 0; 
%LET MAKSIMI_KIVERO_SAUNAK = 0;		

/******************************************************/
/* KÄYTETÄÄN VAIN MAAPOHJAN KIINTEISTÖVERON LASKENNASSA */

* Tontin verotusarvo e;
%LET MINIMI_KIVERO_VEROTUSARVO = 50000; 
%LET MAKSIMI_KIVERO_VEROTUSARVO = 50000;
%LET KYNNYS_KIVERO_VEROTUSARVO = 1000;	

* Yleinen kiinteistöveroprosentti;
%LET MINIMI_KIVERO_KIINTPROS = 0.60; 
%LET MAKSIMI_KIVERO_KIINTPROS = 1.4;
%LET KYNNYS_KIVERO_KIINTPROS = 0.1;	

/******************************************************/

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KV;

DO KIVERO_VUOSI = &MINIMI_KIVERO_VUOSI TO &MAKSIMI_KIVERO_VUOSI;
DO KIVERO_RAKTYYPPI = &MINIMI_KIVERO_RAKTYYPPI TO &MAKSIMI_KIVERO_RAKTYYPPI;
DO KIVERO_VALMVUOSI = &MINIMI_KIVERO_VALMVUOSI TO &MAKSIMI_KIVERO_VALMVUOSI BY &KYNNYS_KIVERO_VALMVUOSI; 
DO KIVERO_KANTARAKENNE = &MINIMI_KIVERO_KANTARAKENNE TO &MAKSIMI_KIVERO_KANTARAKENNE;
DO KIVERO_RAKENNUSPA = &MINIMI_KIVERO_RAKENNUSPA TO &MAKSIMI_KIVERO_RAKENNUSPA BY &KYNNYS_KIVERO_RAKENNUSPA; 	
DO KIVERO_VEROPROS = &MINIMI_KIVERO_VEROPROS TO &MAKSIMI_KIVERO_VEROPROS BY &KYNNYS_KIVERO_VEROPROS;
DO KIVERO_SAHKOK = &MINIMI_KIVERO_SAHKOK TO &MAKSIMI_KIVERO_SAHKOK;
DO KIVERO_VESIK = &MINIMI_KIVERO_VESIK TO &MAKSIMI_KIVERO_VESIK;
DO KIVERO_KELLARIPA = &MINIMI_KIVERO_KELLARIPA TO &MAKSIMI_KIVERO_KELLARIPA BY &KYNNYS_KIVERO_KELLARIPA;	
DO KIVERO_LAMMITYSK = &MINIMI_KIVERO_LAMMITYSK TO &MAKSIMI_KIVERO_LAMMITYSK;		
DO KIVERO_TALVIASK = &MINIMI_KIVERO_TALVIASK TO &MAKSIMI_KIVERO_TALVIASK;		
DO KIVERO_VIEMARIK = &MINIMI_KIVERO_VIEMARIK TO &MAKSIMI_KIVERO_VIEMARIK;
DO KIVERO_WCK = &MINIMI_KIVERO_WCK TO &MAKSIMI_KIVERO_WCK;			
DO KIVERO_SAUNAK = &MINIMI_KIVERO_SAUNAK TO &MAKSIMI_KIVERO_SAUNAK;
DO KIVERO_VEROTUSARVO = &MINIMI_KIVERO_VEROTUSARVO TO &MAKSIMI_KIVERO_VEROTUSARVO BY &KYNNYS_KIVERO_VEROTUSARVO;	
DO KIVERO_KIINTPROS = &MINIMI_KIVERO_KIINTPROS TO &MAKSIMI_KIVERO_KIINTPROS BY &KYNNYS_KIVERO_KIINTPROS;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, KIVERO_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO KiVero_Simuloi_Esimerkki;
/* KIVERO-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL KIVERO_PARAM KIVERO_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(KIVERO_PARAM, KIVERO);
%HaeLaskettavatLokaalit(KIVERO_MUUNNOS, KIVERO);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KIVERO_PARAM;

DATA OUTPUT.&TULOSNIMI_KV;
SET OUTPUT.&TULOSNIMI_KV;

IF KIVERO_RAKTYYPPI = 2 THEN KIVERO_RAKTYYPPI2 = 7;
IF KIVERO_RAKTYYPPI = 1 THEN KIVERO_RAKTYYPPI2 = 1;

/* 3.2.1 Lasketaan pientalon verotusarvo */

%PtVerotusArvoS(KIVERO_PTVARVO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, KIVERO_KELLARIPA, 
KIVERO_VESIK, KIVERO_LAMMITYSK, KIVERO_SAHKOK, 1);

/* 3.2.2 Lasketaan pientalon kiinteistövero */

%KiVeroPtS(KIVERO_PTKIVERO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, KIVERO_KELLARIPA, 
KIVERO_VESIK, KIVERO_LAMMITYSK, KIVERO_SAHKOK, 1, KIVERO_VEROPROS);

/* 3.2.3 Lasketaan vapaa-ajan asunnon verotusarvo */

%VapVerotusArvoS(KIVERO_VAPVARVO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, 
KIVERO_TALVIASK, KIVERO_SAHKOK, KIVERO_VIEMARIK, KIVERO_VESIK, KIVERO_WCK, KIVERO_SAUNAK, 1);

/* 3.2.4 Lasketaan vapaa-ajan asunnon kiinteistövero */

%KiVeroVapS(KIVERO_VAPKIVERO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, 
KIVERO_TALVIASK, KIVERO_SAHKOK, KIVERO_VIEMARIK, KIVERO_VESIK, KIVERO_WCK, KIVERO_SAUNAK, 1, KIVERO_VEROPROS);

/* 3.2.5 Lasketaan maapohjan kiinteistövero e/v */

KIVERO_MPKIVE = KIVERO_VEROTUSARVO * (KIVERO_KIINTPROS / 100);

/* 3.2.6 Lasketaan kiinteistöverot yhteensä e/v */

KIVERO_KIVEROYHT = SUM(KIVERO_PTKIVERO, KIVERO_VAPKIVERO, KIVERO_MPKIVE);

/*3.2.7 Pienimmän määrättävän veron alittavat kiinteistöverot nollataan */

%KiMinimi(KIVERO_KIVEROYHT, KIVERO_VUOSI, INF, KIVERO_KIVEROYHT); 

/*3.2.8 Nollataan osamuuttujat mikäli verotuksen kokonaissumma on nollattu */
IF KIVERO_KIVEROYHT = 0 THEN DO; 
KIVERO_PTKIVERO = 0;
KIVERO_VAPKIVERO = 0; 
KIVERO_MPKIVE = 0; 
END;


DROP KIVERO_RAKTYYPPI2 taulu_pkivero kkuuk kuuknro w y z testi VALOPULLINEN;

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
KIVERO_VUOSI = 'Lainsäädäntövuosi'
KIVERO_RAKTYYPPI = 'Rakennustyyppi (1=pientalo, 2=vapaa-ajan asunto)'
KIVERO_VALMVUOSI = 'Rakennuksen valmistumisvuosi'
KIVERO_KANTARAKENNE = 'Kantava rakenne (1=puu, 2=kivi)'
KIVERO_RAKENNUSPA = 'Rakennuksen pinta-ala, (m2)'
KIVERO_VEROPROS = 'Rakennukselle määrätty kiinteistöveroprosentti, (%)'
KIVERO_SAHKOK = 'Sähkökoodi, (0/1)'
KIVERO_VESIK = 'Vesijohtotieto, (0/1)'
KIVERO_KELLARIPA = 'Pientalon viimeistelemättömän kellarin pinta-ala, (m2)'
KIVERO_LAMMITYSK = 'Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys)'
KIVERO_TALVIASK = 'Vapaa-ajan asunnon talviasuttavuus, (0/1)'
KIVERO_VIEMARIK = 'Viemäritieto, (0/1)'
KIVERO_WCK = 'Vapaa-ajan asunnon wc-tieto, (0/1)'
KIVERO_SAUNAK = 'Vapaa-ajan asunnon saunatieto, (0/1)'
KIVERO_VEROTUSARVO = 'Tontin verotusarvo, (e)'	
KIVERO_KIINTPROS = 'Yleinen kiinteistöveroprosentti, (%)'

INF = 'Inflaatiokorjauksessa käytettävä kerroin'

KIVERO_PTVARVO = 'Pientalon verotusarvo, (e)'
KIVERO_PTKIVERO = 'Pientalon kiinteistövero, (e/v)'
KIVERO_VAPVARVO = 'Vapaa-ajan asunnon verotusarvo, (e)'
KIVERO_VAPKIVERO = 'Vapaa-ajan asunnon kiinteistövero, (e/v)'
KIVERO_MPKIVE = 'Maapohjan kiinteistövero, (e/v)'
KIVERO_KIVEROYHT = 'Kiinteistöverot yhteensä, (e/v)';


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

FORMAT KIVERO_VUOSI KIVERO_RAKTYYPPI KIVERO_VALMVUOSI KIVERO_KANTARAKENNE KIVERO_SAHKOK KIVERO_VESIK KIVERO_LAMMITYSK KIVERO_TALVIASK 
KIVERO_VIEMARIK KIVERO_WCK KIVERO_SAUNAK 8.;

KEEP &VALITUT;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_KV, KIVERO);


%MEND Kivero_Simuloi_Esimerkki;

%Kivero_Simuloi_Esimerkki;
