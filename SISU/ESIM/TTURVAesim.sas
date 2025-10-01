/***********************************************************
* Kuvaus: Työttömyysturvan esimerkkilaskelmien pohja       *
***********************************************************/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TT = tturva_esim_&SYSDATE._1; * Simuloidun tulostiedoston nimi ;
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

%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PTTURVA = ptturva; * Käytettävän parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_TTURVA_VUOSI = 2025;
%LET MAKSIMI_TTURVA_VUOSI = 2025;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_TTURVA_KUUK = 12;
%LET MAKSIMI_TTURVA_KUUK = 12;

*Alle 18-v. lasten lkm;
%LET MINIMI_TTURVA_LAPSIA = 0;
%LET MAKSIMI_TTURVA_LAPSIA = 0; 

*Toimintastatus (1 = työtön, 2 = vuorotteluvapaalla);
%LET MINIMI_TTURVA_TOIMINTA = 1; 
%LET MAKSIMI_TTURVA_TOIMINTA = 1;

*Täyttääkö työssäoloehdon (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_TYOSSAOLO = 1; 
%LET MAKSIMI_TTURVA_TYOSSAOLO = 1;

*Onko oikeutettu ansiosidonnaiseen työttömyysturvaan (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_TYOTKASS = 1; 
%LET MAKSIMI_TTURVA_TYOTKASS = 1;

*Onko työvoimapoliittisessa aikuiskoulutuksessa (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_KOULTUKI = 0; 
%LET MAKSIMI_TTURVA_KOULTUKI = 0;

* Oikeus korotettuihin päivärahoihin  
0 = ei oikeutta
1 = Oikeus ansiopäivärahojen korotettuun ansio-osaan / työmarkkinatuen tai peruspäivärahan korotusosaan / korotettuun vuorottelukorvaukseen
2 = Oikeus ansiopäivärahojen muutosturvaan
3 = Oikeus ansiopäivärahojen korotettuihin lisäpäiviin (voimassa 2003-2009);
%LET MINIMI_TTURVA_OIKEUSKOR = 0; 
%LET MAKSIMI_TTURVA_OIKEUSKOR = 0;

*Työttömyyttä edeltävä palkka (e/kk);
%LET MINIMI_TTURVA_KUUKPALK = 2000; 
%LET MAKSIMI_TTURVA_KUUKPALK = 2000;
%LET KYNNYS_TTURVA_KUUKPALK =  100; 

*Onko puolisoa (1 = tosi, 0 = epätosi) ;
%LET MINIMI_TTURVA_PUOLISO = 0; 
%LET MAKSIMI_TTURVA_PUOLISO = 0; 

*Puolison veronalaiset tulot (e/kk);
%LET MINIMI_TTURVA_PUOLTULO = 0; 
%LET MAKSIMI_TTURVA_PUOLTULO = 0;
%LET KYNNYS_TTURVA_PUOLTULO = 1000; 

*Omat pääomatulot (e/kk) (tarveharkitussa työmarkkinatuessa);
%LET MINIMI_TTURVA_OMATULO = 0; 
%LET MAKSIMI_TTURVA_OMATULO = 0;
%LET KYNNYS_TTURVA_OMATULO = 1000; 

*Asuuko saaja vanhempien luona (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_OSITT = 0; 
%LET MAKSIMI_TTURVA_OSITT = 0; 

*Alle 18-vuotiaiden lkm vanhempien perheessä;
%LET MINIMI_TTURVA_HUOLL = 0;
%LET MAKSIMI_TTURVA_HUOLL = 0; 

* Vanhempien veronalaiset tulot (e/kk) ;
%LET MINIMI_TTURVA_VANHTULO = 0;
%LET MAKSIMI_TTURVA_VANHTULO = 0;
%LET KYNNYS_TTURVA_VANHTULO = 1000;

*Sovittelun perusteena oleva tulo (e/kk) (työttömyysaikana saatu työtulo);
%LET MINIMI_TTURVA_SOVTULO = 0;
%LET MAKSIMI_TTURVA_SOVTULO = 0;
%LET KYNNYS_TTURVA_SOVTULO = 100;

*Vähennettävä muu sosiaalietuus (e/kk);
%LET MINIMI_TTURVA_VAHSOSET = 0; 
%LET MAKSIMI_TTURVA_VAHSOSET = 0;
%LET KYNNYS_TTURVA_VAHSOSET = 100; 

*Aktiivimallin alennettu työttömyyspäiväraha (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_AKTIIVI = 0;
%LET MAKSIMI_TTURVA_AKTIIVI = 0;

*Maksettujen työttömyyspäivärahapäivien lukumäärä (kertymä);
%LET MINIMI_TTURVA_PAIVAT = 0; 
%LET MAKSIMI_TTURVA_PAIVAT = 0;
%LET KYNNYS_TTURVA_PAIVAT = 10;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_TT;

DO TTURVA_VUOSI = &MINIMI_TTURVA_VUOSI TO &MAKSIMI_TTURVA_VUOSI;
DO TTURVA_KUUK = &MINIMI_TTURVA_KUUK TO &MAKSIMI_TTURVA_KUUK;

DO TTURVA_TOIMINTA = &MINIMI_TTURVA_TOIMINTA TO &MAKSIMI_TTURVA_TOIMINTA;
DO TTURVA_LAPSIA = &MINIMI_TTURVA_LAPSIA TO &MAKSIMI_TTURVA_LAPSIA;
DO TTURVA_PUOLISO = &MINIMI_TTURVA_PUOLISO TO &MAKSIMI_TTURVA_PUOLISO;
DO TTURVA_TYOSSAOLO = &MINIMI_TTURVA_TYOSSAOLO TO &MAKSIMI_TTURVA_TYOSSAOLO;
DO TTURVA_TYOTKASS = &MINIMI_TTURVA_TYOTKASS TO &MAKSIMI_TTURVA_TYOTKASS;

DO TTURVA_KUUKPALK = &MINIMI_TTURVA_KUUKPALK TO &MAKSIMI_TTURVA_KUUKPALK BY &KYNNYS_TTURVA_KUUKPALK;
DO TTURVA_SOVTULO = &MINIMI_TTURVA_SOVTULO TO &MAKSIMI_TTURVA_SOVTULO BY &KYNNYS_TTURVA_SOVTULO ; 
DO TTURVA_OIKEUSKOR = &MINIMI_TTURVA_OIKEUSKOR TO &MAKSIMI_TTURVA_OIKEUSKOR;
DO TTURVA_KOULTUKI = &MINIMI_TTURVA_KOULTUKI TO &MAKSIMI_TTURVA_KOULTUKI;
DO TTURVA_VAHSOSET = &MINIMI_TTURVA_VAHSOSET TO &MAKSIMI_TTURVA_VAHSOSET BY &KYNNYS_TTURVA_VAHSOSET ;
DO TTURVA_AKTIIVI = &MINIMI_TTURVA_AKTIIVI TO &MAKSIMI_TTURVA_AKTIIVI;

DO TTURVA_OMATULO = &MINIMI_TTURVA_OMATULO TO &MAKSIMI_TTURVA_OMATULO BY &KYNNYS_TTURVA_OMATULO ;
DO TTURVA_OSITT = &MINIMI_TTURVA_OSITT TO &MAKSIMI_TTURVA_OSITT; 
DO TTURVA_HUOLL = &MINIMI_TTURVA_HUOLL TO &MAKSIMI_TTURVA_HUOLL;
DO TTURVA_VANHTULO = &MINIMI_TTURVA_VANHTULO TO &MAKSIMI_TTURVA_VANHTULO BY &KYNNYS_TTURVA_VANHTULO ;
DO TTURVA_PAIVAT = &MINIMI_TTURVA_PAIVAT TO &MAKSIMI_TTURVA_PAIVAT BY &KYNNYS_TTURVA_PAIVAT;

%IF &MAKSIMI_TTURVA_PUOLISO = 1 %THEN %DO;
	DO TTURVA_PUOLTULO = &MINIMI_TTURVA_PUOLTULO TO &MAKSIMI_TTURVA_PUOLTULO BY &KYNNYS_TTURVA_PUOLTULO;
%END;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, TTURVA_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

%IF &MAKSIMI_TTURVA_PUOLISO = 1 %THEN %DO;
	END;
%END;

%IF &MINIMI_TTURVA_PUOLISO = 0 %THEN %DO;

	DATA OUTPUT.&TULOSNIMI_TT; 
	SET OUTPUT.&TULOSNIMI_TT;

	IF TTURVA_PUOLISO = 0 THEN TTURVA_PUOLTULO = .;
	RUN;

%END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;



/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO TTurva_Simuloi_Esimerkki;
/* TTURVA-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

DATA OUTPUT.&TULOSNIMI_TT;
SET OUTPUT.&TULOSNIMI_TT;

/* 3.2.1 Työmarkkinatuki */

IF TTURVA_TOIMINTA = 1 THEN DO;

	IF TTURVA_TYOSSAOLO = 0 THEN DO;

		IF &VUOSIKA = 2 THEN DO;
			%TyomTukiKS(TMTUKIK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), TTURVA_OSITT, TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_HUOLL, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VANHTULO, 0, (TTURVA_OIKEUSKOR = 1), TTURVA_VAHSOSET, aktiivi=TTURVA_AKTIIVI);
		END;
		ELSE DO;
			%TyomTukiVS(TMTUKIK, TTURVA_VUOSI, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), TTURVA_OSITT, TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_HUOLL, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VANHTULO, 0, (TTURVA_OIKEUSKOR = 1), TTURVA_VAHSOSET, aktiivi=TTURVA_AKTIIVI);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			TMTUKIK = TMTUKIK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuKS(TMTUKIK, TTURVA_VUOSI, TTURVA_KUUK, INF, 0, 0, TTURVA_LAPSIA, TMTUKIK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET );
			END;
			ELSE DO;
				%SoviteltuVS(TMTUKIK, TTURVA_VUOSI, INF, 0, 0, TTURVA_LAPSIA, TMTUKIK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET);
			END;
		END;

		TMTUKIP = TMTUKIK / &TTPaivia;
		TMTUKIV = TMTUKIK * 12;
	
	END;

/* 3.2.2 Peruspäiväraha */

	ELSE IF (TTURVA_TYOSSAOLO = 1 OR TTURVA_VUOSI < 1994) AND TTURVA_TYOTKASS = 0 THEN DO;

		IF &VUOSIKA = 2 THEN DO;
			%PerusPRahaKS(PERUSPRAHAK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), (TTURVA_OIKEUSKOR = 1), TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VAHSOSET, aktiivi=TTURVA_AKTIIVI);
		END;
		ELSE DO;
			%PerusPRahaVS(PERUSPRAHAK, TTURVA_VUOSI, INF,(TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), (TTURVA_OIKEUSKOR = 1), TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VAHSOSET, aktiivi=TTURVA_AKTIIVI);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			PERUSPRAHAK = PERUSPRAHAK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuKS(PERUSPRAHAK, TTURVA_VUOSI, TTURVA_KUUK, INF, 0, 0, TTURVA_LAPSIA, PERUSPRAHAK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET);
			END;
			ELSE DO;
				%SoviteltuVS(PERUSPRAHAK, TTURVA_VUOSI, INF, 0, 0, TTURVA_LAPSIA, PERUSPRAHAK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET);
			END;
		END;

		PERUSPRAHAP = PERUSPRAHAK / &TTPaivia;
		PERUSPRAHAV = PERUSPRAHAK * 12;

	END;

/* 3.2.3 Ansiosidonnainen päiväraha */

	ELSE IF TTURVA_TYOSSAOLO = 1 AND TTURVA_TYOTKASS = 1 THEN DO; 

		IF &VUOSIKA = 2 THEN DO;
			%AnsioSidKS(ANSIOSIDK, TTURVA_VUOSI, TTURVA_KUUK, INF, TTURVA_LAPSIA, (TTURVA_OIKEUSKOR = 1), (TTURVA_OIKEUSKOR = 2), (TTURVA_OIKEUSKOR = 3), TTURVA_KUUKPALK, TTURVA_VAHSOSET, TTURVA_PAIVAT, 0, aktiivi=TTURVA_AKTIIVI);
		END;
		ELSE DO;
			%AnsioSidVS(ANSIOSIDK, TTURVA_VUOSI, INF, TTURVA_LAPSIA, (TTURVA_OIKEUSKOR = 1), (TTURVA_OIKEUSKOR = 2), (TTURVA_OIKEUSKOR = 3), TTURVA_KUUKPALK, TTURVA_VAHSOSET, TTURVA_PAIVAT, 0, aktiivi=TTURVA_AKTIIVI);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			ANSIOSIDK = ANSIOSIDK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuKS(ANSIOSIDK, TTURVA_VUOSI, TTURVA_KUUK, INF, 1, (TTURVA_OIKEUSKOR IN (1,2)), TTURVA_LAPSIA, ANSIOSIDK, TTURVA_SOVTULO, TTURVA_KUUKPALK, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET);
			END;
			ELSE DO;
				%SoviteltuVS(ANSIOSIDK, TTURVA_VUOSI, INF, 1, (TTURVA_OIKEUSKOR IN (1,2)), TTURVA_LAPSIA, ANSIOSIDK, TTURVA_SOVTULO, TTURVA_KUUKPALK, TTURVA_KOULTUKI, aktiivi=TTURVA_AKTIIVI, vahsosetuus=TTURVA_VAHSOSET);
			END;
		END;

		ANSIOSIDP = ANSIOSIDK / &TTPaivia;
		ANSIOSIDV = ANSIOSIDK * 12;

	END;
END;



/* 3.2.4 Vuorottelukorvaus */

ELSE IF TTURVA_TOIMINTA = 2 AND TTURVA_TYOSSAOLO = 1 THEN DO;

	IF &VUOSIKA = 2 THEN DO;
		%VuorVapKorvKS(VUORKORVK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK, vahsosetuus=TTURVA_VAHSOSET);
	END;
	ELSE DO;
		%VuorVapKorvVS(VUORKORVK, TTURVA_VUOSI, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK, vahsosetuus=TTURVA_VAHSOSET);
	END;
	IF TTURVA_SOVTULO > 0 THEN DO;
		IF &VUOSIKA = 2 THEN DO;
			%VuorVapKorvKS(VUORKORVK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK, spalkka=TTURVA_SOVTULO, vahsosetuus=TTURVA_VAHSOSET);	
		END;
		ELSE DO;
			%VuorVapKorvVS(VUORKORVK, TTURVA_VUOSI, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK, spalkka=TTURVA_SOVTULO, vahsosetuus=TTURVA_VAHSOSET);
		END;
	END;

VUORKORVP = VUORKORVK / &TTPaivia;
VUORKORVV = VUORKORVK * 12;

END;

DROP kuuknro taulu_&PTTURVA w y z testi kuuid kkuuk;

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
TTURVA_VUOSI = 'Lainsäädäntövuosi'
TTURVA_KUUK = 'Lainsäädäntökuukausi'
TTURVA_LAPSIA = 'Alle 18-v. lasten lkm'
TTURVA_OIKEUSKOR = 'Oikeus korotettuun päivärahaan, (0-3)'
TTURVA_TYOTKASS = 'Oikeus ansiosidonnaiseen työttömyysturvaan, (0/1)'
TTURVA_TOIMINTA = 'Toimintastatus, (1/2)'
TTURVA_TYOSSAOLO = 'Työssäoloehdon täyttyminen, (0/1)'
TTURVA_KOULTUKI = 'Työvoimapoliittinen koulutus, (0/1)' 
TTURVA_KUUKPALK = 'Työttömyyttä edeltävä palkka, (e/kk)'
TTURVA_SOVTULO = 'Työttömyyden aikana saadut työtulot, (e/kk)'
TTURVA_VANHTULO = 'Vanhempien veronalaiset tulot, (e/kk)'
TTURVA_OMATULO = 'Omat (pääoma)tulot, (e/kk)'
TTURVA_PUOLTULO = 'Puolison veronalaiset tulot, (e/kk)'
TTURVA_PUOLISO = 'Onko puolisoa, (0/1)'
TTURVA_OSITT = 'Asuu vanhempien luona, (0/1)'
TTURVA_VAHSOSET = 'Vähennettävä muu sosiaalietuus, (e/kk)'
TTURVA_AKTIIVI = 'Aktiivimallin työttömyysturvan alennus'
TTURVA_HUOLL = 'Alle 18-v. lasten lkm vanhempien perheessä'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

TMTUKIK = 'Työmarkkinatuki, (e/kk)'
TMTUKIV = 'Työmarkkinatuki, (e/v)'
TMTUKIP = 'Työmarkkinatuki, (e/pv)'
PERUSPRAHAP = 'Peruspäiväraha, (e/pv)'
PERUSPRAHAK = 'Peruspäiväraha, (e/kk)'
PERUSPRAHAV = 'Peruspäiväraha, (e/v)'
ANSIOSIDK = 'Ansiosidonnainen päiväraha, (e/kk)'
ANSIOSIDP = 'Ansiosidonnainen päiväraha, (e/pv)'
ANSIOSIDV = 'Ansiosidonnainen päiväraha, (e/v)'
VUORKORVV = 'Vuorottelukorvaus, (e/v)'
VUORKORVK = 'Vuorottelukorvaus, (e/kk)'
VUORKORVP = 'Vuorottelukorvaus, (e/pv)';

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

FORMAT TTURVA_VUOSI TTURVA_KUUK TTURVA_LAPSIA TTURVA_OIKEUSKOR TTURVA_TYOTKASS TTURVA_TOIMINTA TTURVA_TYOSSAOLO 
TTURVA_KOULTUKI TTURVA_PUOLISO TTURVA_OSITT TTURVA_HUOLL TTURVA_AKTIIVI TTURVA_PAIVAT 8.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP TTURVA_KUUK;
%END;

IF TTURVA_TYOSSAOLO = 0 AND TTURVA_TOIMINTA = 2 THEN DELETE;
RUN;


* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_TT, TTURVA);

%MEND TTurva_Simuloi_Esimerkki;

%TTurva_Simuloi_Esimerkki;