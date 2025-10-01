/***********************************************************
* Kuvaus: Opintotuen esimerkkilaskelmien pohja             *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_OT = opintuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 2;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains‰‰d‰ntˆ ;
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

%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
%LET POPINTUKI = popintuki; * K‰ytett‰v‰n parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lains‰‰d‰ntˆvuosi (1992-);
%LET MINIMI_OPINTUKI_VUOSI = 2025;
%LET MAKSIMI_OPINTUKI_VUOSI = 2025;

* Lains‰‰d‰ntˆkuukausi ;
%LET MINIMI_OPINTUKI_KUUK = 12;
%LET MAKSIMI_OPINTUKI_KUUK = 12;

* Aikuiskoulutusopiskelija (1 = tosi, 0 = ep‰tosi) ;
%LET MINIMI_OPINTUKI_AIKKOUL = 0; 
%LET MAKSIMI_OPINTUKI_AIKKOUL = 0; 

* Aikuiskoulutustuen perusteena oleva tulo (e/v);
%LET MINIMI_OPINTUKI_AIKKOUL_TULO = 12000; 
%LET MAKSIMI_OPINTUKI_AIKKOUL_TULO = 24000; 
%LET KYNNYS_OPINTUKI_AIKKOUL_TULO = 12000;

*Sovitellun aikuiskoulutustuen perusteena oleva tulo, (e/kk);
%LET MINIMI_OPINTUKI_AIKKOUL_SOVTULO = 0;
%LET MAKSIMI_OPINTUKI_AIKKOUL_SOVTULO = 0;
%LET KYNNYS_OPINTUKI_AIKKOUL_SOVTULO = 200;

* On alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi);
%LET MINIMI_OPINTUKI_ONHUOLTAJA = 0;
%LET MAKSIMI_OPINTUKI_ONHUOLTAJA = 0;

* Asuu vanhempien luona (1 = tosi, 0 = ep‰tosi);
%LET MINIMI_OPINTUKI_KOTONA_AS = 0; 
%LET MAKSIMI_OPINTUKI_KOTONA_AS = 0;

* Opiskeluaste (0 = keskiasteen opiskelija,1 = korkeakouluopiskelija,  
  2 = 1.8.2014 j‰lkeen aloittanut korkea-asteen opiskelija) ;
%LET MINIMI_OPINTUKI_KORK = 1; 
%LET MAKSIMI_OPINTUKI_KORK = 1; 

* Opintokuukausien m‰‰r‰ vuodessa 
  HUOM! Mik‰li k‰ytt‰j‰ syˆtt‰‰ enemm‰n opintokuukausia kuin milt‰ esimerkkihenkilˆ on oikeuttetu nostamaan opintotukea,
  k‰ytet‰‰n laskennassa maksimi tukikuukausien m‰‰r‰, jotka esimerkkihenkilˆ voi saada;
%LET MINIMI_OPINTUKI_KK = 12; 
%LET MAKSIMI_OPINTUKI_KK= 12;  

* Henkilˆn ik‰ vuosina ;
%LET MINIMI_OPINTUKI_IKA = 25;
%LET MAKSIMI_OPINTUKI_IKA = 25;
%LET KYNNYS_OPINTUKI_IKA = 1;

* Henkilˆn omat veronalaiset tulot ja apurahat (e/v) ;
%LET MINIMI_OPINTUKI_OMA_TULO = 0;
%LET MAKSIMI_OPINTUKI_OMA_TULO = 0;
%LET KYNNYS_OPINTUKI_OMA_TULO = 10;

* Asumiskustannukset (e/kk) ;
%LET MINIMI_OPINTUKI_ASKUST = 0;
%LET MAKSIMI_OPINTUKI_ASKUST = 0;
%LET KYNNYS_OPINTUKI_ASKUST = 100;

* Puolison veronalaiset tulot (e/v) ;
%LET MINIMI_OPINTUKI_PUOL_TULO = 0;
%LET MAKSIMI_OPINTUKI_PUOL_TULO = 0;
%LET KYNNYS_OPINTUKI_PUOL_TULO = 1000;

* Vanhempien veronalaiset tulot (e/v) 
  HUOM! Muutos vanhempien tulok‰sitteess‰ 1.1.2019 ; 
%LET MINIMI_OPINTUKI_VANH_TULO = 0;
%LET MAKSIMI_OPINTUKI_VANH_TULO = 0;
%LET KYNNYS_OPINTUKI_VANH_TULO = 1000;

* Vanhempien veronalainen varallisuus (e) ;
%LET MINIMI_OPINTUKI_VANH_VARALL = 0;
%LET MAKSIMI_OPINTUKI_VANH_VARALL = 0;
%LET KYNNYS_OPINTUKI_VANH_VARALL = 1000;

* Kuntaryhm‰, voi saada arvoja 1-3.

	Seuraava ryhmittely on voimassa vuosina 2025-:
	1 = Helsinki, Espoo, Kauniainen ja Vantaa
	2 = Hyvink‰‰, H‰meenlinna, Joensuu, Jyv‰skyl‰, J‰rvenp‰‰, Kerava, Kirkkonummi, 
	Kuopio, Lahti, Lohja, Nokia, Nurmij‰rvi, Oulu, Porvoo, Raisio, Riihim‰ki, Rovaniemi, 
	Sein‰joki, Sipoo, Siuntio, Tampere, Turku, Tuusula ja Vihti
	3 = Muut kunnat;

%LET MINIMI_OPINTUKI_KRYHMA = 1;
%LET MAKSIMI_OPINTUKI_KRYHMA = 1;

%END;

/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_OT;

DO OPINTUKI_VUOSI = &MINIMI_OPINTUKI_VUOSI TO &MAKSIMI_OPINTUKI_VUOSI;
DO OPINTUKI_KUUK = &MINIMI_OPINTUKI_KUUK TO &MAKSIMI_OPINTUKI_KUUK;
DO OPINTUKI_AIKKOUL = &MINIMI_OPINTUKI_AIKKOUL TO &MAKSIMI_OPINTUKI_AIKKOUL;
DO OPINTUKI_AIKKOUL_TULO = &MINIMI_OPINTUKI_AIKKOUL_TULO TO &MAKSIMI_OPINTUKI_AIKKOUL_TULO BY &KYNNYS_OPINTUKI_AIKKOUL_TULO;
DO OPINTUKI_AIKKOUL_SOVTULO = &MINIMI_OPINTUKI_AIKKOUL_SOVTULO TO &MAKSIMI_OPINTUKI_AIKKOUL_SOVTULO BY &KYNNYS_OPINTUKI_AIKKOUL_SOVTULO;
DO OPINTUKI_ONHUOLTAJA = &MINIMI_OPINTUKI_ONHUOLTAJA TO &MAKSIMI_OPINTUKI_ONHUOLTAJA;
DO OPINTUKI_KOTONA_AS = &MINIMI_OPINTUKI_KOTONA_AS TO &MAKSIMI_OPINTUKI_KOTONA_AS; 
DO OPINTUKI_KORK = &MINIMI_OPINTUKI_KORK TO &MAKSIMI_OPINTUKI_KORK;
DO OPINTUKI_KK = &MINIMI_OPINTUKI_KK TO &MAKSIMI_OPINTUKI_KK;
DO OPINTUKI_IKA = &MINIMI_OPINTUKI_IKA TO &MAKSIMI_OPINTUKI_IKA BY &KYNNYS_OPINTUKI_IKA; 
DO OPINTUKI_OMA_TULO = &MINIMI_OPINTUKI_OMA_TULO TO &MAKSIMI_OPINTUKI_OMA_TULO BY &KYNNYS_OPINTUKI_OMA_TULO ; 
DO OPINTUKI_ASKUST = &MINIMI_OPINTUKI_ASKUST TO &MAKSIMI_OPINTUKI_ASKUST BY &KYNNYS_OPINTUKI_ASKUST ; 
DO OPINTUKI_PUOL_TULO = &MINIMI_OPINTUKI_PUOL_TULO TO &MAKSIMI_OPINTUKI_PUOL_TULO BY &KYNNYS_OPINTUKI_PUOL_TULO ;
DO OPINTUKI_VANH_TULO = &MINIMI_OPINTUKI_VANH_TULO TO &MAKSIMI_OPINTUKI_VANH_TULO BY &KYNNYS_OPINTUKI_VANH_TULO ;
DO OPINTUKI_VANH_VARALL = &MINIMI_OPINTUKI_VANH_VARALL TO &MAKSIMI_OPINTUKI_VANH_VARALL BY &KYNNYS_OPINTUKI_VANH_VARALL ;
DO OPINTUKI_KRYHMA = &MINIMI_OPINTUKI_KRYHMA TO &MAKSIMI_OPINTUKI_KRYHMA;

IF OPINTUKI_KORK = 2 THEN ALOITUSPVM = MDY(8,1,2014);
ELSE ALOITUSPVM = .;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, OPINTUKI_VUOSI, &INF);

OUTPUT;

END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO OpinTuki_Simuloi_Esimerkki;

/* OPINTUKI-mallin parametrit */

/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL OPINTUKI_PARAM OPINTUKI_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(OPINTUKI_PARAM, OPINTUKI);
%HaeLaskettavatLokaalit(OPINTUKI_MUUNNOS, OPINTUKI);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &OPINTUKI_PARAM;

DATA OUTPUT.&TULOSNIMI_OT;
SET OUTPUT.&TULOSNIMI_OT;

FORMAT ALOITUSPVM DDMMYYP10.;

/* 3.2.1 Tukikuukausien m‰‰r‰ tulojen perusteella */

%TukiKuukOik (TUKIAIKA, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_OMA_TULO, OPINTUKI_KK);

/*Nollataan aikuiskoulutusopiskelijoiden opintotuki*/
IF OPINTUKI_AIKKOUL = 1 THEN TUKIAIKA = 0; 

/* M‰‰ritell‰‰n, onko henkilˆ opintotuen saaja (tukikuukaudet > 0) */
IF TUKIAIKA = 0 THEN DO;
	SAA_TUKEA = 0;
END;
ELSE DO; 
	SAA_TUKEA = 1;
END;

/* 3.2.2 Lasketaan opintoraha */

IF &VUOSIKA = 2 THEN DO;
	%OpRahaKS(OPIR, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, (OPINTUKI_KORK NE 0), OPINTUKI_KOTONA_AS, OPINTUKI_IKA, 0, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_VARALL, aloituspvm = ALOITUSPVM, huoltaja = OPINTUKI_ONHUOLTAJA);
END;
ELSE DO;
	%OpRahaVS(OPIR, OPINTUKI_VUOSI, INF, (OPINTUKI_KORK NE 0), OPINTUKI_KOTONA_AS, OPINTUKI_IKA, 0, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_VARALL, aloituspvm = ALOITUSPVM, huoltaja = OPINTUKI_ONHUOLTAJA);
END;

/* Kuukausitaso */
OPRAHAK = OPIR * SAA_TUKEA;
/* Vuositaso */ 
OPRAHAV = OPIR * TUKIAIKA;

DROP OPIR;

/* 3.2.3 Lasketaan opintotuen asumislis‰ */

IF OPINTUKI_KOTONA_AS = 0 AND OPINTUKI_ONHUOLTAJA = 0 THEN DO;
	IF &VUOSIKA = 2 THEN DO;
		%AsumLisaKS(ASLIS, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_IKA, 0, OPINTUKI_ASKUST, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_TULO, OPINTUKI_PUOL_TULO, OPINTUKI_KRYHMA);
	END;
	ELSE DO;
		%AsumLisaVS(ASLIS, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_IKA, 0, OPINTUKI_ASKUST, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_TULO, OPINTUKI_PUOL_TULO, OPINTUKI_KRYHMA);
	END;
END;

/* Kuukausitaso */
ASUMLISAK = ASLIS*SAA_TUKEA;
/* Vuositaso */ 
ASUMLISAV = ASLIS * TUKIAIKA;

DROP ASLIS;

/* 3.2.4 Lasketaan (potentiaalinen) opintolainan valtiontakaus */

IF &VUOSIKA = 2 THEN DO;
	%OpLainaKS(OPLAI, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_AIKKOUL, OPINTUKI_IKA);
END;
ELSE DO;
	%OpLainaVS(OPLAI, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_AIKKOUL, OPINTUKI_IKA);
END;

/* Kuukausitaso */
OPLAINAK = OPLAI * SAA_TUKEA;
/* Vuositaso */ 
OPLAINAV = OPLAI * TUKIAIKA;

DROP OPLAI;

/* 3.2.5 Lasketaan aikuisopintoraha */

IF &VUOSIKA = 2 THEN DO;
	%AikOpinRahaKS (AIKOPRAHA, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_OMA_TULO);
END;
ELSE DO; 
	%AikOpinRahaVS (AIKOPRAHA, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_OMA_TULO);
END;

/* Kuukausitaso */
AIKOPRAHAK = AIKOPRAHA * SAA_TUKEA;
/* Vuositaso */ 
AIKOPRAHAV = AIKOPRAHA * TUKIAIKA;

DROP AIKOPRAHA;

/* 3.2.6 Lasketaan aikuiskoulutustuki */

IF &VUOSIKA = 2 THEN DO;
	%AikKoulTukiKS (AIKKOULTUKI, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_AIKKOUL_TULO);
END;
ELSE DO;
	%AikKoulTukiVS (AIKKOULTUKI, OPINTUKI_VUOSI, INF, OPINTUKI_AIKKOUL_TULO);
END;

IF OPINTUKI_AIKKOUL_SOVTULO > 0 THEN DO;
		IF &VUOSIKA = 2 THEN DO;
			%AikKoulSoviteltuKS(AIKKOULTUKI, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, AIKKOULTUKI, OPINTUKI_AIKKOUL_SOVTULO, OPINTUKI_AIKKOUL_TULO);
		END;
		ELSE DO;
			%AikKoulSoviteltuVS(AIKKOULTUKI, OPINTUKI_VUOSI, INF, AIKKOULTUKI, OPINTUKI_AIKKOUL_SOVTULO, OPINTUKI_AIKKOUL_TULO);
		END;
END;

/* Kuukausitaso */
AIKKOULTUKIK = AIKKOULTUKI * OPINTUKI_AIKKOUL;

/* Vuositaso */ 
AIKKOULTUKIV = AIKKOULTUKI * OPINTUKI_KK * OPINTUKI_AIKKOUL;

DROP AIKKOULTUKI SAA_TUKEA;

DROP kuuknro w y z testi kuuid kkuuk taulu_&POPINTUKI;

/* 3.3 M‰‰ritell‰‰n muuttujille selkokieliset selitteet */

LABEL 
OPINTUKI_VUOSI = 'Lains‰‰d‰ntˆvuosi'
OPINTUKI_KUUK = 'Lains‰‰d‰ntˆkuukausi'
OPINTUKI_AIKKOUL = 'Aikuiskoulutusopiskelija, (0/1)'
OPINTUKI_AIKKOUL_TULO = 'Aikuiskoulutustuen perusteena oleva tulo, (e/v)'
OPINTUKI_AIKKOUL_SOVTULO = 'Sovitellun aikuiskoulutustuen perusteena oleva tulo, (e/kk)'
OPINTUKI_ONHUOLTAJA = "On alaik‰isen lapsen huoltaja (0/1)"
OPINTUKI_KOTONA_AS = 'Asuu vanhempien luona, (0/1)'
OPINTUKI_KORK = 'Opiskeluaste (0=keskiaste, 1=korkeakoulu, 2=uusi korkeakoulu)'
OPINTUKI_KK = 'Syˆtetyt opintokuukaudet'
OPINTUKI_IKA = 'Ik‰ vuosina'
OPINTUKI_OMA_TULO = 'Omat veronalaiset tulot ja apurahat, (e/v)'
OPINTUKI_ASKUST = 'Asumiskustannukset, (e/kk)'
OPINTUKI_PUOL_TULO = 'Puolison veronalaiset tulot, (e/v)'
OPINTUKI_VANH_TULO = 'Vanhempien veronalaiset tulot, (e/v)'
OPINTUKI_VANH_VARALL = 'Vanhempien varallisuus, (e)'
INF = 'Inflaatiokorjauksessa k‰ytett‰v‰ kerroin'
ALOITUSPVM = 'Opiskelun aloituspvm'
OPINTUKI_KRYHMA = 'Kuntaryhm‰ (lains‰‰d‰nnˆss‰ 8/2025 l‰htien)'

TUKIAIKA = 'Opintorahan ja asumislis‰n laskennassa k‰ytetyt tukikuukaudet vuodessa'
OPRAHAK = 'Opintoraha, (e/tukikk)' 
ASUMLISAK = 'Opintotuen asumislis‰, (e/tukikk)' 
OPLAINAK = 'Opintolainan valtiontakaus, (e/tukikk)' 
OPRAHAV = 'Opintoraha, (e/v)' 
ASUMLISAV = 'Opintotuen asumislis‰, (e/v)' 
OPLAINAV = 'Opintolainan valtiontakaus, (e/v)' 
AIKOPRAHAK = 'Aikuisopintoraha, (e/kk)' 
AIKOPRAHAV = 'Aikuisopintoraha, (e/v)' 
AIKKOULTUKIK = 'Aikuiskoulutustuki, (e/kk)' 
AIKKOULTUKIV = 'Aikuiskoulutustuki, (e/v)';

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

FORMAT OPINTUKI_VUOSI OPINTUKI_KUUK OPINTUKI_AIKKOUL OPINTUKI_ONHUOLTAJA OPINTUKI_KOTONA_AS OPINTUKI_KORK TUKIAIKA OPINTUKI_KK OPINTUKI_IKA OPINTUKI_KRYHMA 8.;

/* Muiden muuttujien alustaminen haluttuun tulostusmuotoon */

FORMAT ALOITUSPVM DDMMYYP10.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP OPINTUKI_KUUK;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_OT, OPINTUKI);

%MEND OpinTuki_Simuloi_Esimerkki;

%OpinTuki_Simuloi_Esimerkki;
