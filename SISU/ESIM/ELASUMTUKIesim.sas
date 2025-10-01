/****************************************************************
* Kuvaus: Eläkkeensaajan asumistuen esimerkkilaskelmien pohja   *
****************************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_EA = elasumtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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

%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;	* Lakimakrotiedoston nimi ;
%LET PELASUMTUKI = pelasumtuki; * Käytettävän parametritiedoston nimi ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.1 Fiktiivinen data */

* Lainsäädäntövuosi (1990-);
%LET MINIMI_ELASUMTUKI_VUOSI = 2025;
%LET MAKSIMI_ELASUMTUKI_VUOSI = 2025;

* Lainsäädäntökuukausi (1-12); 
%LET MINIMI_ELASUMTUKI_KUUK = 12; 
%LET MAKSIMI_ELASUMTUKI_KUUK = 12;  

* Asunnon tyyppi (1 = Vuokra-asunto, 2 = Omakotitalo, 3 = Osakehuoneisto);
%LET MINIMI_ELASUMTUKI_ASTYYPPI = 1;
%LET MAKSIMI_ELASUMTUKI_ASTYYPPI = 1;

* Perheenjäsenten lukumäärä (1, 2...);
%LET MINIMI_ELASUMTUKI_PERHE = 0;
%LET MAKSIMI_ELASUMTUKI_PERHE = 1;

* Onko kyse puolisoista (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_PUOLISO = 0;
%LET MAKSIMI_ELASUMTUKI_PUOLISO = 0;

* Onko puolisolla oikeus el.saaj. asumistukeen (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_PUOLOIKAT = 0;
%LET MAKSIMI_ELASUMTUKI_PUOLOIKAT = 0;

* Onko leskeneläkkeen saaja (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_LESKENELAKE = 0;
%LET MAKSIMI_ELASUMTUKI_LESKENELAKE = 0;

* Saako rintamasotilaseläkettä (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_RINTSOTELAKE = 0;
%LET MAKSIMI_ELASUMTUKI_RINTSOTELAKE = 0;

/* Alle 16-vuotiaiden lasten lukumäärä.
HUOM! 1.1.2015 alkaen lapsiperheet ovat yleisen asumistuen piirissä. */
%LET MINIMI_ELASUMTUKI_LAPSIA = 0;
%LET MAKSIMI_ELASUMTUKI_LAPSIA = 0;

* Eläkkeensaajan asumistuen lämmitysryhmä, voi saada arvoja 1-3.
Huom. Kuntien ryhmittely voi muuttua vuosien välillä
eikä ryhmien numerointi välttämättä vastaa
lainsäädännön mukaista numerointia.
Seuraava ryhmittely on voimassa vuosina 2015-2017:
1 = Askola, Aura, Espoo, Eura, Eurajoki, Hamina, Hanko,
Harjavalta, Helsinki, Honkajoki, Huittinen, Hyvinkää,
Iitti, Imatra, Inkoo, Jämijärvi, Järvenpää, Kaarina,
Kankaanpää, Karkkila, Karvia, Kauniainen, Kemiönsaari,
Kerava, Kirkkonummi, Kokemäki, Koski, Kotka, Kouvola,
Kustavi, Köyliö, Laitila, Lapinjärvi, Lappeenranta, Lemi,
Lieto, Lohja, Loimaa, Loviisa, Luumäki, Luvia, Marttila,
Masku, Merikarvia, Miehikkälä, Mynämäki, Myrskylä, Mäntsälä,
Naantali, Nakkila, Nousiainen, Nurmijärvi, Orimattila,
Oripää, Paimio, Parainen, Parikkala, Pomarkku, Pori,
Pornainen, Porvoo, Pukkila, Punkalaidun, Pyhtää, Pyhäranta,
Pöytyä, Raasepori, Raisio, Rauma, Rautjärvi, Ruokolahti,
Rusko, Salo, Sastamala, Sauvo, Savitaipale, Siikainen,
Sipoo, Siuntio, Somero, Säkylä, Taipalsaari, Taivassalo,
Turku, Tuusula, Ulvila, Uusikaupunki, Vantaa, Vehmaa,
Vihti, Virolahti sekä Ahvenanmaan maakunnan kunnat
2 = Akaa, Alajärvi, Alavus, Asikkala, Enonkoski,
Evijärvi, Forssa, Halsua, Hartola, Hattula, Hausjärvi,
Heinola, Heinävesi, Hirvensalmi, Hollola, Humppila,
Hämeenkoski, Hämeenkyrö, Hämeenlinna, Ikaalinen,
Ilmajoki, Isojoki, Isokyrö, Jalasjärvi, Janakkala,
Jokioinen, Joroinen, Juupajoki, Juva, Kangasala,
Kangasniemi, Kannus, Karijoki, Kaskinen, Kauhajoki,
Kauhava, Kaustinen, Kihniö, Kokkola, Korsnäs,
Kristiinankaupunki, Kruunupyy, Kuortane, Kurikka,
Kärkölä, Lahti, Laihia, Lappajärvi, Lapua, Lempäälä,
Lestijärvi, Loppi, Luoto, Maalahti, Mikkeli, Mustasaari,
Mänttä-Vilppula, Mäntyharju, Nastola, Nokia, Närpiö,
Orivesi, Padasjoki, Parkano, Pedersören kunta, Perho,
Pertunmaa, Pieksämäki, Pietarsaari, Pirkkala, Puumala,
Pälkäne, Rantasalmi, Riihimäki, Ruovesi, Savonlinna,
Seinäjoki, Soini, Sulkava, Sysmä, Tammela, Tampere,
Teuva, Toholampi, Urjala, Uusikaarlepyy, Vaasa,
Valkeakoski, Vesilahti, Veteli, Vimpeli, Virrat,
Vöyri, Ylöjärvi, Ypäjä ja Ähtäri
3 = Muut kunnat;
%LET MINIMI_ELASUMTUKI_LAMMRYHMA = 1;
%LET MAKSIMI_ELASUMTUKI_LAMMRYHMA = 1;

* Keskuslämmitys (1 = tosi, 0 = epätosi) ;
%LET MINIMI_ELASUMTUKI_KESKLAMM = 1;
%LET MAKSIMI_ELASUMTUKI_KESKLAMM = 1;

* Vesijohto (1 = tosi, 0 = epätosi) ;
%LET MINIMI_ELASUMTUKI_VESIJOHTO = 1;
%LET MAKSIMI_ELASUMTUKI_VESIJOHTO= 1;	

* Vesimaksu ei sisälly vuokraan (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_EIVESI = 0;
%LET MAKSIMI_ELASUMTUKI_EIVESI = 0;

* Lämmitys ei sisälly vuokraan (1 = tosi, 0 = epätosi);
%LET MINIMI_ELASUMTUKI_EILAMM = 0;
%LET MAKSIMI_ELASUMTUKI_EILAMM = 0;

* Asunnon pinta-ala, m2;
%LET MINIMI_ELASUMTUKI_ALA = 40;
%LET MAKSIMI_ELASUMTUKI_ALA = 40;
%LET KYNNYS_ELASUMTUKI_ALA = 10;

* Eläkkeensaajan asumistuen kuntaryhmä, voi saada arvoja 1-4.
Huom. Kuntien ryhmittely voi muuttua vuosien välillä
eikä ryhmien numerointi välttämättä vastaa
lainsäädännön mukaista numerointia.
Seuraava ryhmittely on voimassa 2015-2017:
1 = Helsinki
2 = Espoo, Kauniainen ja Vantaa
3 = Hyvinkää, Hämeenlinna, Joensuu, Jyväskylä, Järvenpää,
Kerava, Kirkkonummi, Kouvola, Kuopio, Lahti,
Lappeenranta, Lohja, Nurmijärvi, Oulu,
Pori, Porvoo, Raisio, Riihimäki, Rovaniemi, Seinäjoki,
Sipoo, Tampere, Turku, Tuusula, Vaasa ja Vihti
4 = Muut kunnat;
%LET MINIMI_ELASUMTUKI_KRYHMA = 1;
%LET MAKSIMI_ELASUMTUKI_KRYHMA = 1;

* Hakijan tulot tai puolisoiden tulot yhteensä (e/kk);
%LET MINIMI_ELASUMTUKI_TULOT = 700;
%LET MAKSIMI_ELASUMTUKI_TULOT = 1700;
%LET KYNNYS_ELASUMTUKI_TULOT = 100;

* Hakijan omaisuus tai puolisoiden omaisuus yhteensä (e);
%LET MINIMI_ELASUMTUKI_OMAISUUS = 0;
%LET MAKSIMI_ELASUMTUKI_OMAISUUS = 0;
%LET KYNNYS_ELASUMTUKI_OMAISUUS = 1000;

* Vuokra (e/kk);
%LET MINIMI_ELASUMTUKI_VUOKRA = 500;
%LET MAKSIMI_ELASUMTUKI_VUOKRA = 500;
%LET KYNNYS_ELASUMTUKI_VUOKRA = 100;

* Asunnon valmistumisvuosi;
%LET MINIMI_ELASUMTUKI_VALMVUOSI = 1994;
%LET MAKSIMI_ELASUMTUKI_VALMVUOSI = 1994;

* Asuntolainan korot (e/v);
%LET MINIMI_ELASUMTUKI_ASKOROT = 0;
%LET MAKSIMI_ELASUMTUKI_ASKOROT = 0;
%LET KYNNYS_ELASUMTUKI_ASKOROT = 100;

%END;


/* 3. Fiktiivisen aineiston luominen ja simulointi */

/* 3.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_EA;

DO ELASUMTUKI_VUOSI = &MINIMI_ELASUMTUKI_VUOSI TO &MAKSIMI_ELASUMTUKI_VUOSI;
DO ELASUMTUKI_KUUK = &MINIMI_ELASUMTUKI_KUUK TO &MAKSIMI_ELASUMTUKI_KUUK;
DO ELASUMTUKI_ASTYYPPI = &MINIMI_ELASUMTUKI_ASTYYPPI TO &MAKSIMI_ELASUMTUKI_ASTYYPPI;
DO ELASUMTUKI_PERHE = &MINIMI_ELASUMTUKI_PERHE TO &MAKSIMI_ELASUMTUKI_PERHE;
DO ELASUMTUKI_PUOLISO = &MINIMI_ELASUMTUKI_PUOLISO TO &MAKSIMI_ELASUMTUKI_PUOLISO;
DO ELASUMTUKI_PUOLOIKAT = &MINIMI_ELASUMTUKI_PUOLOIKAT TO &MAKSIMI_ELASUMTUKI_PUOLOIKAT;
DO ELASUMTUKI_LESKENELAKE = &MINIMI_ELASUMTUKI_LESKENELAKE TO &MAKSIMI_ELASUMTUKI_LESKENELAKE;
DO ELASUMTUKI_RINTSOTELAKE = &MINIMI_ELASUMTUKI_RINTSOTELAKE TO &MAKSIMI_ELASUMTUKI_RINTSOTELAKE;
DO ELASUMTUKI_LAPSIA = &MINIMI_ELASUMTUKI_LAPSIA TO &MAKSIMI_ELASUMTUKI_LAPSIA;
DO ELASUMTUKI_LAMMRYHMA = &MINIMI_ELASUMTUKI_LAMMRYHMA TO &MAKSIMI_ELASUMTUKI_LAMMRYHMA;
DO ELASUMTUKI_KESKLAMM = &MINIMI_ELASUMTUKI_KESKLAMM TO &MAKSIMI_ELASUMTUKI_KESKLAMM;
DO ELASUMTUKI_VESIJOHTO = &MINIMI_ELASUMTUKI_VESIJOHTO TO &MAKSIMI_ELASUMTUKI_VESIJOHTO;
DO ELASUMTUKI_EIVESI = &MINIMI_ELASUMTUKI_EIVESI TO &MAKSIMI_ELASUMTUKI_EIVESI;
DO ELASUMTUKI_EILAMM = &MINIMI_ELASUMTUKI_EILAMM TO &MAKSIMI_ELASUMTUKI_EILAMM;
DO ELASUMTUKI_ALA = &MINIMI_ELASUMTUKI_ALA TO &MAKSIMI_ELASUMTUKI_ALA BY &KYNNYS_ELASUMTUKI_ALA;
DO ELASUMTUKI_KRYHMA = &MINIMI_ELASUMTUKI_KRYHMA TO &MAKSIMI_ELASUMTUKI_KRYHMA;
DO ELASUMTUKI_TULOT = &MINIMI_ELASUMTUKI_TULOT TO &MAKSIMI_ELASUMTUKI_TULOT BY &KYNNYS_ELASUMTUKI_TULOT;
DO ELASUMTUKI_OMAISUUS = &MINIMI_ELASUMTUKI_OMAISUUS TO &MAKSIMI_ELASUMTUKI_OMAISUUS BY &KYNNYS_ELASUMTUKI_OMAISUUS;
DO ELASUMTUKI_VUOKRA = &MINIMI_ELASUMTUKI_VUOKRA TO &MAKSIMI_ELASUMTUKI_VUOKRA BY &KYNNYS_ELASUMTUKI_VUOKRA;
DO ELASUMTUKI_VALMVUOSI = &MINIMI_ELASUMTUKI_VALMVUOSI TO &MAKSIMI_ELASUMTUKI_VALMVUOSI;
DO ELASUMTUKI_ASKOROT = &MINIMI_ELASUMTUKI_ASKOROT TO &MAKSIMI_ELASUMTUKI_ASKOROT BY &KYNNYS_ELASUMTUKI_ASKOROT;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, ELASUMTUKI_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 3.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO ElAsumTuki_Simuloi_Esimerkki;
/* ELASUMTUKI-mallin parametrit */

/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
%LOCAL ELASUMTUKI_PARAM ELASUMTUKI_MUUNNOS;

/* Haetaan mallin käyttämien lakiparametrien nimet */
%HaeLokaalit(ELASUMTUKI_PARAM, ELASUMTUKI);
%HaeLaskettavatLokaalit(ELASUMTUKI_MUUNNOS, ELASUMTUKI);

/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &ELASUMTUKI_PARAM;

DATA OUTPUT.&TULOSNIMI_EA;
SET OUTPUT.&TULOSNIMI_EA;


/* 3.2.1 Lasketaan eläkkeensaajan asumistuki  */

%IF &VUOSIKA = 1 %THEN %DO;

	/* Vuokra-asunto */
	IF ELASUMTUKI_ASTYYPPI = 1 THEN DO;

		%ElakAsumTukiVS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			12 * ELASUMTUKI_VUOKRA, 0);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;

	END;

	/* Omakotitalo */
	ELSE IF ELASUMTUKI_ASTYYPPI = 2 THEN DO;

		%ElakAsumTukiVS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 1, ELASUMTUKI_LAMMRYHMA,ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			0, ELASUMTUKI_ASKOROT);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;

	END;

	/* Osakehuoneisto */
	ELSE IF ELASUMTUKI_ASTYYPPI = 3 THEN DO;

		%ElakAsumTukiVS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			12 * ELASUMTUKI_VUOKRA, ELASUMTUKI_ASKOROT);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;	

	END;

%END;

%ELSE %IF &VUOSIKA = 2 %THEN %DO;

	/* Vuokra-asunto */
	IF ELASUMTUKI_ASTYYPPI = 1 THEN DO;

		%ElakAsumTukiKS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			12 * ELASUMTUKI_VUOKRA, 0);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;

	END;

	/* Omakotitalo */
	ELSE IF ELASUMTUKI_ASTYYPPI = 2 THEN DO;

		%ElakAsumTukiKS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 1, ELASUMTUKI_LAMMRYHMA,ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			0, ELASUMTUKI_ASKOROT);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;

	END;

	/* Osakehuoneisto */
	ELSE IF ELASUMTUKI_ASTYYPPI = 3 THEN DO;

		%ElakAsumTukiKS(ELASUMTUKI_MAARAK, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
			ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
			ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
			12 * ELASUMTUKI_VUOKRA, ELASUMTUKI_ASKOROT);

		ELASUMTUKI_MAARAV = 12 * ELASUMTUKI_MAARAK;	

	END;
	

%END;

/* 3.2.2 Vesi- ja lämmitysnormit ja omakotitalon hoitonormi eläkkeensaajien asumistuessa */

/* Omakotitalo (koko normi lasketaan) */
IF ELASUMTUKI_ASTYYPPI = 1 THEN DO;

	%EHoitonormiS(ELASUMTUKI_HOITONORMIK, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_PERHE, ELASUMTUKI_LAMMRYHMA,
		1, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI, ELASUMTUKI_EILAMM, ELASUMTUKI_ALA,
		ELASUMTUKI_VALMVUOSI);

END;

/* Vuokra-asunnot ja osakehuoneistot (lasketaan vain vesi- ja/tai lämmitysnormi) */
ELSE DO;

	%EHoitonormiS(ELASUMTUKI_HOITONORMIK, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_PERHE, ELASUMTUKI_LAMMRYHMA,
		0, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI, ELASUMTUKI_EILAMM, ELASUMTUKI_ALA,
		ELASUMTUKI_VALMVUOSI);

END;

/* 3.2.3 Enimmäisasumismeno eläkkeensaajien asumistuessa */

%EnimmAsMenoS(ELASUMTUKI_ENIMMAISMENOV, ELASUMTUKI_VUOSI, ELASUMTUKI_KUUK, INF, ELASUMTUKI_LAPSIA, ELASUMTUKI_KRYHMA);

ELASUMTUKI_ENIMMAISMENOK = ELASUMTUKI_ENIMMAISMENOV / 12;

DROP kuuknro taulu_&pelasumtuki kkuuk w y z testi;

/* 3.3 Määritellään muuttujille selkokieliset selitteet */

LABEL
ELASUMTUKI_VUOSI = 'Lainsäädäntövuosi'
ELASUMTUKI_KUUK = 'Lainsäädäntökuukausi'
ELASUMTUKI_ASTYYPPI = 'Asunnon tyyppi (1=Vuokra-asunto, 2=Omakotitalo, 3=Osakehuoneisto)'
ELASUMTUKI_PERHE = 'Perheenjäsenten lkm'
ELASUMTUKI_PUOLISO = 'Onko kyse puolisoista, (0/1)'
ELASUMTUKI_PUOLOIKAT = 'Onko puolisolla oikeus eläkkeensaajan asumistukeen, (0/1)'
ELASUMTUKI_LESKENELAKE = 'Onko leskeneläkkeen saaja, (0/1)'
ELASUMTUKI_RINTSOTELAKE = 'Saako rintamasotilaseläkettä, (0/1)'
ELASUMTUKI_LAPSIA = 'Alle 16-v. lasten lkm'
ELASUMTUKI_LAMMRYHMA = 'Hoitonormien kuntaryhmä (1, 2 tai 3)'
ELASUMTUKI_KESKLAMM = 'Keskuslämmitys, (0/1)'
ELASUMTUKI_VESIJOHTO = 'Vesijohto, (0/1)'
ELASUMTUKI_EIVESI = 'Vesimaksu ei sisälly vuokraan, (0/1)'
ELASUMTUKI_EILAMM = 'Lämmitys ei sisälly vuokraan, (0/1)'
ELASUMTUKI_ALA = 'Asunnon pinta-ala, (m2)'
ELASUMTUKI_KRYHMA = 'Alueryhmitys (1, 2, 3 tai 4)'
ELASUMTUKI_TULOT = 'Hakijan tulot tai puolisoiden tulot yhteensä, e/kk'
ELASUMTUKI_OMAISUUS = 'Hakijan omaisuus tai puolisoiden omaisuus yhteensä, (e)'
ELASUMTUKI_VUOKRA = 'Vuokra, (e/kk)'
ELASUMTUKI_VALMVUOSI = 'Asunnon valmistumisvuosi'
ELASUMTUKI_ASKOROT = 'Asuntolainan korot, (e/v)'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'
ELASUMTUKI_MAARAK = 'Eläkkeensaajan asumistuki, (e/kk)'
ELASUMTUKI_MAARAV = 'Eläkkeensaajan asumistuki, (e/v)'
ELASUMTUKI_HOITONORMIK = 'Hoitonormi, (e/kk)'
ELASUMTUKI_ENIMMAISMENOV = 'Enimmäisasumismenot, (e/v)'
ELASUMTUKI_ENIMMAISMENOK = 'Enimmäisasumismenot, (e/kk)'
;

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

FORMAT ELASUMTUKI_VUOSI ELASUMTUKI_KUUK ELASUMTUKI_ASTYYPPI ELASUMTUKI_PERHE ELASUMTUKI_PUOLISO ELASUMTUKI_PUOLOIKAT ELASUMTUKI_LESKENELAKE
ELASUMTUKI_RINTSOTELAKE ELASUMTUKI_LAPSIA ELASUMTUKI_LAMMRYHMA ELASUMTUKI_KESKLAMM ELASUMTUKI_VESIJOHTO ELASUMTUKI_EIVESI 
ELASUMTUKI_EILAMM ELASUMTUKI_KRYHMA ELASUMTUKI_VALMVUOSI 8.;

KEEP &VALITUT;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_EA, ELASUMTUKI);

%MEND ElAsumTuki_Simuloi_Esimerkki;

%ElAsumTuki_Simuloi_Esimerkki;
