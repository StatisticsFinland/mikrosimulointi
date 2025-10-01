/***********************************************************
* Kuvaus: Ty�tt�myysturvan esimerkkilaskelmien pohja       *
***********************************************************/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TT = tturva_esim_&SYSDATE._1; * Simuloidun tulostiedoston nimi ;
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
%LET AVUOSI = 2025; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko ;

* K�ytett�vien tiedostojen nimet; 

%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PTTURVA = ptturva; * K�ytett�v�n parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1985-);
%LET MINIMI_TTURVA_VUOSI = 2025;
%LET MAKSIMI_TTURVA_VUOSI = 2025;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_TTURVA_KUUK = 12;
%LET MAKSIMI_TTURVA_KUUK = 12;

*Alle 18-v. lasten lkm;
%LET MINIMI_TTURVA_LAPSIA = 0;
%LET MAKSIMI_TTURVA_LAPSIA = 0; 

*Toimintastatus (1 = ty�t�n, 2 = vuorotteluvapaalla);
%LET MINIMI_TTURVA_TOIMINTA = 1; 
%LET MAKSIMI_TTURVA_TOIMINTA = 1;

*T�ytt��k� ty�ss�oloehdon (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_TYOSSAOLO = 1; 
%LET MAKSIMI_TTURVA_TYOSSAOLO = 1;

*Onko oikeutettu ansiosidonnaiseen ty�tt�myysturvaan (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_TYOTKASS = 1; 
%LET MAKSIMI_TTURVA_TYOTKASS = 1;

*Onko ty�voimapoliittisessa aikuiskoulutuksessa (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_KOULTUKI = 0; 
%LET MAKSIMI_TTURVA_KOULTUKI = 0;

* Oikeus korotettuihin p�iv�rahoihin  
0 = ei oikeutta
1 = Oikeus ansiop�iv�rahojen korotettuun ansio-osaan / ty�markkinatuen tai perusp�iv�rahan korotusosaan / korotettuun vuorottelukorvaukseen
2 = Oikeus ansiop�iv�rahojen muutosturvaan
3 = Oikeus ansiop�iv�rahojen korotettuihin lis�p�iviin (voimassa 2003-2009);
%LET MINIMI_TTURVA_OIKEUSKOR = 0; 
%LET MAKSIMI_TTURVA_OIKEUSKOR = 0;

*Ty�tt�myytt� edelt�v� palkka (e/kk);
%LET MINIMI_TTURVA_KUUKPALK = 2000; 
%LET MAKSIMI_TTURVA_KUUKPALK = 2000;
%LET KYNNYS_TTURVA_KUUKPALK =  100; 

*Onko puolisoa (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_TTURVA_PUOLISO = 0; 
%LET MAKSIMI_TTURVA_PUOLISO = 0; 

*Puolison veronalaiset tulot (e/kk);
%LET MINIMI_TTURVA_PUOLTULO = 0; 
%LET MAKSIMI_TTURVA_PUOLTULO = 0;
%LET KYNNYS_TTURVA_PUOLTULO = 1000; 

*Omat p��omatulot (e/kk) (tarveharkitussa ty�markkinatuessa);
%LET MINIMI_TTURVA_OMATULO = 0; 
%LET MAKSIMI_TTURVA_OMATULO = 0;
%LET KYNNYS_TTURVA_OMATULO = 1000; 

*Asuuko saaja vanhempien luona (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_OSITT = 0; 
%LET MAKSIMI_TTURVA_OSITT = 0; 

*Alle 18-vuotiaiden lkm vanhempien perheess�;
%LET MINIMI_TTURVA_HUOLL = 0;
%LET MAKSIMI_TTURVA_HUOLL = 0; 

* Vanhempien veronalaiset tulot (e/kk) ;
%LET MINIMI_TTURVA_VANHTULO = 0;
%LET MAKSIMI_TTURVA_VANHTULO = 0;
%LET KYNNYS_TTURVA_VANHTULO = 1000;

*Sovittelun perusteena oleva tulo (e/kk) (ty�tt�myysaikana saatu ty�tulo);
%LET MINIMI_TTURVA_SOVTULO = 0;
%LET MAKSIMI_TTURVA_SOVTULO = 0;
%LET KYNNYS_TTURVA_SOVTULO = 100;

*V�hennett�v� muu sosiaalietuus (e/kk);
%LET MINIMI_TTURVA_VAHSOSET = 0; 
%LET MAKSIMI_TTURVA_VAHSOSET = 0;
%LET KYNNYS_TTURVA_VAHSOSET = 100; 

*Aktiivimallin alennettu ty�tt�myysp�iv�raha (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_AKTIIVI = 0;
%LET MAKSIMI_TTURVA_AKTIIVI = 0;

*Maksettujen ty�tt�myysp�iv�rahap�ivien lukum��r� (kertym�);
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
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

DATA OUTPUT.&TULOSNIMI_TT;
SET OUTPUT.&TULOSNIMI_TT;

/* 3.2.1 Ty�markkinatuki */

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

/* 3.2.2 Perusp�iv�raha */

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

/* 3.2.3 Ansiosidonnainen p�iv�raha */

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

/* 3.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
TTURVA_VUOSI = 'Lains��d�nt�vuosi'
TTURVA_KUUK = 'Lains��d�nt�kuukausi'
TTURVA_LAPSIA = 'Alle 18-v. lasten lkm'
TTURVA_OIKEUSKOR = 'Oikeus korotettuun p�iv�rahaan, (0-3)'
TTURVA_TYOTKASS = 'Oikeus ansiosidonnaiseen ty�tt�myysturvaan, (0/1)'
TTURVA_TOIMINTA = 'Toimintastatus, (1/2)'
TTURVA_TYOSSAOLO = 'Ty�ss�oloehdon t�yttyminen, (0/1)'
TTURVA_KOULTUKI = 'Ty�voimapoliittinen koulutus, (0/1)' 
TTURVA_KUUKPALK = 'Ty�tt�myytt� edelt�v� palkka, (e/kk)'
TTURVA_SOVTULO = 'Ty�tt�myyden aikana saadut ty�tulot, (e/kk)'
TTURVA_VANHTULO = 'Vanhempien veronalaiset tulot, (e/kk)'
TTURVA_OMATULO = 'Omat (p��oma)tulot, (e/kk)'
TTURVA_PUOLTULO = 'Puolison veronalaiset tulot, (e/kk)'
TTURVA_PUOLISO = 'Onko puolisoa, (0/1)'
TTURVA_OSITT = 'Asuu vanhempien luona, (0/1)'
TTURVA_VAHSOSET = 'V�hennett�v� muu sosiaalietuus, (e/kk)'
TTURVA_AKTIIVI = 'Aktiivimallin ty�tt�myysturvan alennus'
TTURVA_HUOLL = 'Alle 18-v. lasten lkm vanhempien perheess�'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

TMTUKIK = 'Ty�markkinatuki, (e/kk)'
TMTUKIV = 'Ty�markkinatuki, (e/v)'
TMTUKIP = 'Ty�markkinatuki, (e/pv)'
PERUSPRAHAP = 'Perusp�iv�raha, (e/pv)'
PERUSPRAHAK = 'Perusp�iv�raha, (e/kk)'
PERUSPRAHAV = 'Perusp�iv�raha, (e/v)'
ANSIOSIDK = 'Ansiosidonnainen p�iv�raha, (e/kk)'
ANSIOSIDP = 'Ansiosidonnainen p�iv�raha, (e/pv)'
ANSIOSIDV = 'Ansiosidonnainen p�iv�raha, (e/v)'
VUORKORVV = 'Vuorottelukorvaus, (e/v)'
VUORKORVK = 'Vuorottelukorvaus, (e/kk)'
VUORKORVP = 'Vuorottelukorvaus, (e/pv)';

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