/****************************************************************
* Kuvaus: Yleisen asumistuen esimerkkilaskelmien pohja   		*
* Viimeksi p�ivitetty: 10.3.2021			     		   		*
****************************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; 							* Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_YA = asumtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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

%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;		* Lakimakrotiedoston nimi ;
%LET PASUMTUKI = pasumtuki;						* K�ytett�v�n parametritiedoston nimi ;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;	* Vuokranormiparametrien tiedosto ;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;		* Enimm�isasumismenoparametrien tiedosto ;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";

%MEND Aloitus;

%Aloitus;

/* 2. Luodaan ty�tulomakro */

%MACRO ASUMTUKI_TYOTULOT_MAKRO;
	%GLOBAL ASUMTUKI_TYOTULOT ASUMTUKI_TYOTULOT_KOODI_DO ASUMTUKI_TYOTULOT_KOODI_END ASUMTUKI_TYOTULOT_LABEL;
	%LET ASUMTUKI_TYOTULOT = ;
	%LET ASUMTUKI_TYOTULOT_KOODI_DO = ;
	%LET ASUMTUKI_TYOTULOT_KOODI_END = ;
	%LET ASUMTUKI_TYOTULOT_LABEL = ;
	%DO i = 1 %TO %SYSFUNC(COUNTW(&MINIMI_ASUMTUKI_TYOTULOT, ' '));
		%LET ASUMTUKI_TYOTULOT = &ASUMTUKI_TYOTULOT. ASUMTUKI_TYOTULOT&i;
		%LET MINIMI_ASUMTUKI_TYOTULOT&i = %SYSFUNC(SCAN(&MINIMI_ASUMTUKI_TYOTULOT, &i, ' ')); 
		%LET MAKSIMI_ASUMTUKI_TYOTULOT&i = %SYSFUNC(SCAN(&MAKSIMI_ASUMTUKI_TYOTULOT, &i, ' ')); 
		%LET KYNNYS_ASUMTUKI_TYOTULOT&i = %SYSFUNC(SCAN(&KYNNYS_ASUMTUKI_TYOTULOT, &i, ' '));
		%LET ASUMTUKI_TYOTULOT_KOODI_DO = %STR(&ASUMTUKI_TYOTULOT_KOODI_DO.DO ASUMTUKI_TYOTULOT&i = &&MINIMI_ASUMTUKI_TYOTULOT&i TO &&MAKSIMI_ASUMTUKI_TYOTULOT&i BY &&KYNNYS_ASUMTUKI_TYOTULOT&i;);
		%LET ASUMTUKI_TYOTULOT_KOODI_END = %STR(&ASUMTUKI_TYOTULOT_KOODI_END.END;);
		%LET ASUMTUKI_TYOTULOT_LABEL = &ASUMTUKI_TYOTULOT_LABEL. ASUMTUKI_TYOTULOT&i = "Henkil�n &i ty�tulot, (e/kk)";
	%END;
%MEND ASUMTUKI_TYOTULOT_MAKRO;

/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1990-);
%LET MINIMI_ASUMTUKI_VUOSI = 2021;
%LET MAKSIMI_ASUMTUKI_VUOSI = 2021;

/* UUSI lains��d�nt�vuodesta 2015 l�htien */
* Lains��d�nt�kuukausi (1-12); 
%LET MINIMI_ASUMTUKI_KUUK = 1;
%LET MAKSIMI_ASUMTUKI_KUUK = 1;

* Asunnon tyyppi (1 = Vuokra-asunto, 2 = Omistusasunto, 3 = Osa-asunto (alivuokralaisasunto);
%LET MINIMI_ASUMTUKI_ASTYYPPI = 1;
%LET MAKSIMI_ASUMTUKI_ASTYYPPI = 1;

* Omakotitalo (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ASUMTUKI_OMAKOTI = 0;
%LET MAKSIMI_ASUMTUKI_OMAKOTI = 0;

* Asuntokunnan j�senten lukum��r�;
%LET MINIMI_ASUMTUKI_PERHE = 3;
%LET MAKSIMI_ASUMTUKI_PERHE = 3;

* Onko kyse puolisoista (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ASUMTUKI_PUOLISO = 1;
%LET MAKSIMI_ASUMTUKI_PUOLISO = 1;

* Alle 18-vuotiaiden lasten lukum��r�;
%LET MINIMI_ASUMTUKI_LAPSIA = 1;
%LET MAKSIMI_ASUMTUKI_LAPSIA = 1;

* Asuntokuntaan kuuluu lis�tilaa tarvitseva vammainen (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ASUMTUKI_VAMM = 0;
%LET MAKSIMI_ASUMTUKI_VAMM = 0;

/* UUSI lains��d�nt�vuodesta 2015 l�htien */
* Asuntokunnan vammaisten lukum��r�; 
%LET MINIMI_ASUMTUKI_VAMMLKM = 0;
%LET MAKSIMI_ASUMTUKI_VAMMLKM = 1;

* Yleisen asumistuen kuntaryhm�, voi saada arvoja 1-4.
Huom. Kuntien ryhmittely voi muuttua vuosien v�lill�
eik� ryhmien numerointi v�ltt�m�tt� vastaa
lains��d�nn�n mukaista numerointia.
Seuraava ryhmittely on voimassa vuosina 2015-2017:
1 = Helsinki
2 = Espoo, Kauniainen ja Vantaa
3 = Hyvink��, H�meenlinna, Joensuu, Jyv�skyl�, J�rvenp��,
Kajaani, Kerava, Kirkkonummi, Kouvola, Kuopio, Lahti,
Lappeenranta, Lohja, Mikkeli, Nokia, Nurmij�rvi, Oulu,
Pori, Porvoo, Raisio, Riihim�ki, Rovaniemi, Sein�joki,
Sipoo, Siuntio, Tampere, Turku, Tuusula, Vaasa ja Vihti
4 = Muut kunnat;
%LET MINIMI_ASUMTUKI_KRYHMA = 1;
%LET MAKSIMI_ASUMTUKI_KRYHMA = 1;

* Asunnon valmistumisvuosi;
%LET MINIMI_ASUMTUKI_VALMVUOSI = 2000;
%LET MAKSIMI_ASUMTUKI_VALMVUOSI = 2000;
%LET KYNNYS_ASUMTUKI_VALMVUOSI = 10;

* Yleisen asumistuen l�mmitysryhm�, voi saada arvoja 1-3.
Huom. Kuntien ryhmittely voi muuttua vuosien v�lill�
eik� ryhmien numerointi v�ltt�m�tt� vastaa
lains��d�nn�n mukaista numerointia.
Seuraava ryhmittely on voimassa vuonna 2014:
1 = Askola, Aura, Espoo, Eura, Eurajoki, Hamina, Hanko,
Harjavalta, Helsinki, Honkajoki, Huittinen, Hyvink��,
Iitti, Imatra, Inkoo, J�mij�rvi, J�rvenp��, Kaarina,
Kankaanp��, Karkkila, Karvia, Kauniainen, Kemi�nsaari,
Kerava, Kirkkonummi, Kokem�ki, Koski, Kotka, Kouvola,
Kustavi, K�yli�, Laitila, Lapinj�rvi, Lappeenranta,
Lavia, Lemi, Lito, Lohja, Loimaa, Loviisa, Luum�ki,
Luvia, Marttila, Masku, Merikarvia, Miehikk�l�, Myn�m�ki,
Myrskyl�, M�nts�l�, Naantali, Nakkila, Nousiainen,
Nurmij�rvi, Orimattila, Orip��, Paimio, Parainen,
Parikkala, Pomarkku, Pori, Pornainen, Porvoo,
Pukkila, Punkalaidun, Pyht��, Pyh�ranta, P�yty�,
Raasepori, Raisio, Rauma, Rautj�rvi, Ruokolahti,
Rusko, Salo, Sastamala, Sauvo, Savitaipale, Siikainen,
Sipoo, Siuntio, Somero, S�kyl�, Taipalsaari, Taivassalo,
Tarvasjoki, Turku, Tuusula, Ulvila, Uusikaupunki,
Vantaa, Vehmaa, Vihti ja Virolahti
2 = Akaa, Alaj�rvi, Alavus, Asikkala, Enonkoski, Evij�rvi,
Forssa, Halsua, Hartola, Hattula, Hausj�rvi, Heinola,
Hein�vesi, Hirvensalmi, Hollola, Humppila, H�meenkoski,
H�meenkyr�, H�meenlinna, Ikaalinen, Ilmajoki, Isojoki,
Isokyr�, Jalasj�rvi, Janakkala, Jokioinen, Joroinen,
Juupajoki, Juva, Kangasala, Kangasniemi, Kannus, Karijoki,
Kaskinen, Kauhajoki, Kauhava, Kaustinen, Kihni�, Kokkola,
Korsn�s, Kristiinankaupunki, Kruunupyy, Kuortane, Kurikka,
K�rk�l�, Lahti, Laihia, Lappaj�rvi, Lapua, Lemp��l�,
Lestij�rvi, Loppi, Luoto, Maalahti, Mikkeli, Mustasaari,
M�ntt�-Vilppula, M�ntyharju, Nastola, Nokia, N�rpi�,
Orivesi, Padasjoki, Parkano, Peders�ren kunta, Perho,
Pertunmaa, Pieks�m�ki, Pietarsaari, Pirkkala, Puumala,
P�lk�ne, Rantasalmi, Riihim�ki, Ruovesi, Savonlinna,
Sein�joki, Soini, Sulkava, Sysm�, Tammela, Tampere, Teuva,
Toholampi, Urjala, Uusikaarlepyy, Vaasa, Valkeakoski,
Vesilahti, Veteli, Vimpeli, Virrat, V�yri, Yl�j�rvi,
Yp�j� ja �ht�ri
3 = Muut kunnat;
%LET MINIMI_ASUMTUKI_LAMMRYHMA = 1;
%LET MAKSIMI_ASUMTUKI_LAMMRYHMA = 1;

* Keskusl�mmitys (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_ASUMTUKI_KESKLAMM = 0;
%LET MAKSIMI_ASUMTUKI_KESKLAMM = 1;

* Vesijohto (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_ASUMTUKI_VESIJOHTO = 0;
%LET MAKSIMI_ASUMTUKI_VESIJOHTO = 1;	

* Asunnon pinta-ala, m2;
%LET MINIMI_ASUMTUKI_ALA = 40;
%LET MAKSIMI_ASUMTUKI_ALA = 40;
%LET KYNNYS_ASUMTUKI_ALA = 10;

/* UUSI lains��d�nt�vuodesta 2015 l�htien */
* Yleisen asumistuen maakuntaryhm�, voi saada arvoja 0-2.
Ryhmittely kertoo, miss� maakunnissa asuvat saavat
korotuksen hyv�ksytt�viin l�mmitysmenoihin ja
omistusasunnon hoitonormeihin. 
0 = ei korotusta
1 = Etel�-Savo, Pohjois-Savo ja Pohjois-Karjala
2 = Pohjois-Pohjanmaa, Kainuu ja Lappi;
%LET MINIMI_ASUMTUKI_LKRYHMA = 0;
%LET MAKSIMI_ASUMTUKI_LKRYHMA = 1;

* Asuntokunnan asumistukeen vaikuttavat tulot yhteens� (e/kk);
%LET MINIMI_ASUMTUKI_TULOT = 2000;
%LET MAKSIMI_ASUMTUKI_TULOT = 2000;
%LET KYNNYS_ASUMTUKI_TULOT = 100;

/* UUSI lains��d�nt�vuodesta 2015 l�htien */
* Ruokakunnan v�hint��n 18-vuotiaiden henkil�iden ty�tulot henkil�itt�in (e/kk). 
Huomaa, ett� ty�tulot tulee sis�llytt�� Asuntokunnan asumistukeen vaikuttaviin tuloihin yhteens� (e/kk)
,jotta laskelma ottaa ty�tulot  huomioon.
Mukana my�s tuen hakija ja h�nen puolisonsa, vaikka he olisivatkin alle 18-vuotiaita.
HUOM. Sy�t� myodossa: luku1 luku2 luku3 ...;
%LET MINIMI_ASUMTUKI_TYOTULOT = 200 0;
%LET MAKSIMI_ASUMTUKI_TYOTULOT = 200 0;
%LET KYNNYS_ASUMTUKI_TYOTULOT = 100 100;

%END;
%ASUMTUKI_TYOTULOT_MAKRO;
%IF &EG NE 1 %THEN %DO;
* Hakijan omaisuus tai puolisoiden omaisuus yhteens� (e);
%LET MINIMI_ASUMTUKI_OMAISUUS = 0;
%LET MAKSIMI_ASUMTUKI_OMAISUUS = 0;
%LET KYNNYS_ASUMTUKI_OMAISUUS = 1000;

* Vuokra tai yhti�vastike (e/kk);
%LET MINIMI_ASUMTUKI_VUOKRA = 600;
%LET MAKSIMI_ASUMTUKI_VUOKRA = 1000;
%LET KYNNYS_ASUMTUKI_VUOKRA = 100;

* Vesimaksu (e/kk);
%LET MINIMI_ASUMTUKI_VESI = 0;
%LET MAKSIMI_ASUMTUKI_VESI = 0;
%LET KYNNYS_ASUMTUKI_VESI = 10;

* Erilliset l�mmityskustannukset (e/kk);
%LET MINIMI_ASUMTUKI_LAMM = 0;
%LET MAKSIMI_ASUMTUKI_LAMM = 0;
%LET KYNNYS_ASUMTUKI_LAMM = 10;

* Asuntolainan korot (e/kk);
%LET MINIMI_ASUMTUKI_ASKOROT = 0;
%LET MAKSIMI_ASUMTUKI_ASKOROT = 0;
%LET KYNNYS_ASUMTUKI_ASKOROT = 100;

/* UUSI lains��d�nt�vuodesta 2015 l�htien */
* Alivuokralaisen maksama vuokra (e/kk);
%LET MINIMI_ASUMTUKI_ALIVUOKRA = 0;
%LET MAKSIMI_ASUMTUKI_ALIVUOKRA = 0;
%LET KYNNYS_ASUMTUKI_ALIVUOKRA = 100;

%END;

 
/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_YA;

DO ASUMTUKI_VUOSI = &MINIMI_ASUMTUKI_VUOSI TO &MAKSIMI_ASUMTUKI_VUOSI;
DO ASUMTUKI_KUUK = &MINIMI_ASUMTUKI_KUUK TO &MAKSIMI_ASUMTUKI_KUUK;
DO ASUMTUKI_ASTYYPPI = &MINIMI_ASUMTUKI_ASTYYPPI TO &MAKSIMI_ASUMTUKI_ASTYYPPI;
DO ASUMTUKI_OMAKOTI = &MINIMI_ASUMTUKI_OMAKOTI TO &MAKSIMI_ASUMTUKI_OMAKOTI;
DO ASUMTUKI_PERHE = &MINIMI_ASUMTUKI_PERHE TO &MAKSIMI_ASUMTUKI_PERHE;
DO ASUMTUKI_PUOLISO = &MINIMI_ASUMTUKI_PUOLISO TO &MAKSIMI_ASUMTUKI_PUOLISO;
DO ASUMTUKI_VAMM = &MINIMI_ASUMTUKI_VAMM TO &MAKSIMI_ASUMTUKI_VAMM;
DO ASUMTUKI_VAMMLKM = &MINIMI_ASUMTUKI_VAMMLKM TO &MAKSIMI_ASUMTUKI_VAMMLKM;
DO ASUMTUKI_LAPSIA = &MINIMI_ASUMTUKI_LAPSIA TO &MAKSIMI_ASUMTUKI_LAPSIA;
DO ASUMTUKI_LAMMRYHMA = &MINIMI_ASUMTUKI_LAMMRYHMA TO &MAKSIMI_ASUMTUKI_LAMMRYHMA;
DO ASUMTUKI_KESKLAMM = &MINIMI_ASUMTUKI_KESKLAMM TO &MAKSIMI_ASUMTUKI_KESKLAMM;
DO ASUMTUKI_VESIJOHTO = &MINIMI_ASUMTUKI_VESIJOHTO TO &MAKSIMI_ASUMTUKI_VESIJOHTO;
DO ASUMTUKI_ALA = &MINIMI_ASUMTUKI_ALA TO &MAKSIMI_ASUMTUKI_ALA BY &KYNNYS_ASUMTUKI_ALA;
DO ASUMTUKI_KRYHMA = &MINIMI_ASUMTUKI_KRYHMA TO &MAKSIMI_ASUMTUKI_KRYHMA;
DO ASUMTUKI_LKRYHMA = &MINIMI_ASUMTUKI_LKRYHMA TO &MAKSIMI_ASUMTUKI_LKRYHMA;
DO ASUMTUKI_TULOT = &MINIMI_ASUMTUKI_TULOT TO &MAKSIMI_ASUMTUKI_TULOT BY &KYNNYS_ASUMTUKI_TULOT;
&ASUMTUKI_TYOTULOT_KOODI_DO;
DO ASUMTUKI_OMAISUUS = &MINIMI_ASUMTUKI_OMAISUUS TO &MAKSIMI_ASUMTUKI_OMAISUUS BY &KYNNYS_ASUMTUKI_OMAISUUS;
DO ASUMTUKI_VUOKRA = &MINIMI_ASUMTUKI_VUOKRA TO &MAKSIMI_ASUMTUKI_VUOKRA BY &KYNNYS_ASUMTUKI_VUOKRA;
DO ASUMTUKI_VALMVUOSI = &MINIMI_ASUMTUKI_VALMVUOSI TO &MAKSIMI_ASUMTUKI_VALMVUOSI BY &KYNNYS_ASUMTUKI_VALMVUOSI;
DO ASUMTUKI_ASKOROT = &MINIMI_ASUMTUKI_ASKOROT TO &MAKSIMI_ASUMTUKI_ASKOROT BY &KYNNYS_ASUMTUKI_ASKOROT;
DO ASUMTUKI_VESI = &MINIMI_ASUMTUKI_VESI TO &MAKSIMI_ASUMTUKI_VESI BY &KYNNYS_ASUMTUKI_VESI;
DO ASUMTUKI_LAMM = &MINIMI_ASUMTUKI_LAMM TO &MAKSIMI_ASUMTUKI_LAMM BY &KYNNYS_ASUMTUKI_LAMM;
DO ASUMTUKI_ALIVUOKRA = &MINIMI_ASUMTUKI_ALIVUOKRA TO &MAKSIMI_ASUMTUKI_ALIVUOKRA BY &KYNNYS_ASUMTUKI_ALIVUOKRA;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, ASUMTUKI_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;
&ASUMTUKI_TYOTULOT_KOODI_END;
END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO AsumTuki_Simuloi_Esimerkki;
/* ASUMTUKI-mallin parametrit */
/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL ASUMTUKI_PARAM ASUMTUKI_MUUNNOS;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(ASUMTUKI_PARAM, ASUMTUKI);
%HaeLaskettavatLokaalit(ASUMTUKI_MUUNNOS, ASUMTUKI);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &ASUMTUKI_PARAM;

%HaeParam_VuokraNormit(2011)

DATA OUTPUT.&TULOSNIMI_YA;
SET OUTPUT.&TULOSNIMI_YA;

IF ASUMTUKI_ASTYYPPI = 1 OR ASUMTUKI_ASTYYPPI = 3 THEN ASUMTUKI_OMAKOTI = 0;

***********************************
*  Asumistuki ennen vuotta 2015.  *
***********************************;

IF ASUMTUKI_VUOSI < 2015 THEN DO;

	IF ASUMTUKI_PUOLISO = 0 AND ASUMTUKI_LAPSIA > 0 THEN ASUMTUKI_YKSHUOLT = 1;
	ELSE ASUMTUKI_YKSHUOLT = 0;

	/* 4.2.1 Normipinta-ala */

	%NormiNeliotS(ASUMTUKI_NELIOT, ASUMTUKI_VUOSI, ASUMTUKI_PERHE, ASUMTUKI_VAMM);

	/* 4.2.2 Enimm�isasumismeno neli�metri� kohden */

	%NormiVuokraESIM(ASUMTUKI_NVUOKRA, ASUMTUKI_VUOSI,  INF, ASUMTUKI_KRYHMA, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA);

	/* 4.2.3 Normimeno (normipinta-ala * normivuokra) */

	%NormiVuokraESIM(NMVUOKRA, ASUMTUKI_VUOSI,  INF, ASUMTUKI_KRYHMA, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_VALMVUOSI, ASUMTUKI_NELIOT);

	ASUMTUKI_NORMIMENO = ASUMTUKI_NELIOT * NMVUOKRA;

	DROP NMVUOKRA;

	/* 4.2.4 Enimm�isasumismeno osa-asunnossa */

	%EnimmVuokraESIM(ASUMTUKI_ENIMMMENO, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE);

	/* 4.2.5 Hoitonormi */

	%HoitoNormiS(ASUMTUKI_HNORMI, ASUMTUKI_VUOSI, INF, ASUMTUKI_OMAKOTI, ASUMTUKI_LAMMRYHMA, ASUMTUKI_PERHE, ASUMTUKI_ALA);

	/* 4.2.6 Perusomavastuu */

	%TuloMuokkausS(ASUMTUKI_POVTULO, ASUMTUKI_VUOSI, INF, ASUMTUKI_YKSHUOLT, ASUMTUKI_PERHE, ASUMTUKI_OMAISUUS, ASUMTUKI_TULOT);
	%PerusOmaVastS(ASUMTUKI_PERUSOMV, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE, ASUMTUKI_POVTULO);

	/* 4.2.7 Yleisen asumistuen m��r� */

	SELECT(ASUMTUKI_ASTYYPPI);
		WHEN (1) DO;
			%AsumTukiVuokS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, 1,
				ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_PERHE, ASUMTUKI_VAMM, 
				ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI, ASUMTUKI_LAMM);
		END;
		WHEN (2) DO;
			%AsumTukiOmS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_LAMMRYHMA, ASUMTUKI_OMAKOTI, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO,
				ASUMTUKI_PERHE, ASUMTUKI_VAMM, ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI, ASUMTUKI_LAMM, ASUMTUKI_ASKOROT, 0);
		END;
		WHEN (3) DO;
			%AsumTukiOsaS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE, ASUMTUKI_VAMM, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI)
		END;
		OTHERWISE ASUMTUKI_MAARAK = 0;
	END;

END;

********************************************
*  Asumistuki vuonna 2015 ja sen j�lkeen.  *
********************************************;

ELSE DO;

	IF ASUMTUKI_VESI > 0 THEN ASUMTUKI_EVESI = 1;
	ELSE ASUMTUKI_EVESI = 0;

	IF ASUMTUKI_LAMM > 0 THEN ASUMTUKI_ELAMM = 1;
	ELSE ASUMTUKI_ELAMM = 0;

	ARRAY ASUMTUKI_TYOTULOT{*} &ASUMTUKI_TYOTULOT;

	ASUMTUKI_AIKUISIA = ASUMTUKI_PERHE - ASUMTUKI_LAPSIA;

	%IF &VUOSIKA = 2 %THEN %DO;
		IF ASUMTUKI_ASTYYPPI IN (1,3) THEN DO;
			%As2015AsumistukiVuokraKS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, ASUMTUKI_KUUK, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_VUOKRA, ASUMTUKI_ALIVUOKRA, ASUMTUKI_EVESI, ASUMTUKI_ELAMM, ASUMTUKI_LKRYHMA, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
		ELSE IF ASUMTUKI_ASTYYPPI = 2 AND ASUMTUKI_OMAKOTI = 0 THEN DO;
			%As2015AsumistukiOmaOsakeKS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, ASUMTUKI_KUUK, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_VUOKRA, ASUMTUKI_ALIVUOKRA, ASUMTUKI_EVESI, ASUMTUKI_ELAMM, ASUMTUKI_LKRYHMA, ASUMTUKI_ASKOROT, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
		ELSE DO;
			%As2015AsumistukiOmaTaloKS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, ASUMTUKI_KUUK, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_ALIVUOKRA, ASUMTUKI_LKRYHMA, ASUMTUKI_ASKOROT, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
	%END;
	%ELSE %DO;
		IF ASUMTUKI_ASTYYPPI IN (1,3) THEN DO;
			%As2015AsumistukiVuokraVS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_VUOKRA, ASUMTUKI_ALIVUOKRA, ASUMTUKI_EVESI, ASUMTUKI_ELAMM, ASUMTUKI_LKRYHMA, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
		ELSE IF ASUMTUKI_ASTYYPPI = 2 AND ASUMTUKI_OMAKOTI = 0 THEN DO;
			%As2015AsumistukiOmaOsakeVS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_VUOKRA, ASUMTUKI_ALIVUOKRA, ASUMTUKI_EVESI, ASUMTUKI_ELAMM, ASUMTUKI_LKRYHMA, ASUMTUKI_ASKOROT, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
		ELSE DO;
			%As2015AsumistukiOmaTaloVS(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_VAMMLKM, ASUMTUKI_ALIVUOKRA, ASUMTUKI_LKRYHMA, ASUMTUKI_ASKOROT, ASUMTUKI_TULOT, ASUMTUKI_TYOTULOT, ASUMTUKI_AIKUISIA, ASUMTUKI_LAPSIA);
		END;
	%END;

END;

ASUMTUKI_MAARAV = 12 * ASUMTUKI_MAARAK;
	
DROP nvuosi taulu_ns w taulu_vn sarake taulu_ev 
	 povnimi1 povnimi2 povnimi3 povnimi4 
	 taulu_pov1 taulu_pov2 taulu_pov3 taulu_pov4
	 tunnus1 tunnus2 tunnus3 tunnus4 kuuknro taulu_&pasumtuki kkuuk y z;	

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL
ASUMTUKI_VUOSI = 'Lains��d�nt�vuosi'
ASUMTUKI_KUUK = 'Lains��d�nt�kuukausi'
ASUMTUKI_ASTYYPPI = 'Asunnon tyyppi (1=Vuokra-asunto, 2=Omistusasunto, 3=Osa-asunto(alivuokralaisasunto)'
ASUMTUKI_OMAKOTI = 'Omakotitalo, (0/1)'
ASUMTUKI_PERHE = 'Perheenj�senten lkm'
ASUMTUKI_PUOLISO = 'Onko kyse puolisoista, (0/1)'
ASUMTUKI_LAPSIA = 'Alle 18-v. lasten lkm'
ASUMTUKI_VAMM = 'Asuntokuntaan kuuluu lis�tilaa tarvitseva vammainen, (0/1)'
ASUMTUKI_VAMMLKM = 'Asuntokunnan vammaisten lukum��r�'
ASUMTUKI_LAMMRYHMA = 'L�mmitysryhm� (1, 2 tai 3)'
ASUMTUKI_KESKLAMM = 'Keskusl�mmitys, (0/1)'
ASUMTUKI_VESIJOHTO = 'Vesijohto, (0/1)'
ASUMTUKI_ALA = 'Asunnon pinta-ala, (m2)'
ASUMTUKI_LKRYHMA = 'Lis�kustannusryhm�, m��r�ytyy maakunnittain (1, 2 tai 3)' 
ASUMTUKI_KRYHMA = 'Alueryhmitys (1, 2, 3 tai 4)'
ASUMTUKI_TULOT = 'Hakijan tulot tai puolisoiden tulot yhteens�, (e/kk)'
&ASUMTUKI_TYOTULOT_LABEL
ASUMTUKI_OMAISUUS = 'Hakijan omaisuus tai puolisoiden omaisuus yhteens�, (e)'
ASUMTUKI_VUOKRA = 'Vuokra, (e/kk)'
ASUMTUKI_VESI = 'Erillinen vesimaksu, (e/kk)'
ASUMTUKI_LAMM = 'Asunnon erilliset l�mmityskustannukset, (e/kk)'
ASUMTUKI_VALMVUOSI = 'Asunnon valmistumisvuosi'
ASUMTUKI_ASKOROT = 'Asuntolainan korot, (e/kk)'
ASUMTUKI_ALIVUOKRA = 'Alivuokralaisen maksama vuokra, (e/kk)'

INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

ASUMTUKI_YKSHUOLT = 'Yksinhuoltaja, (0/1)'
ASUMTUKI_NELIOT = 'Normipinta-ala, (m2)'
ASUMTUKI_NVUOKRA = 'Normivuokra, (e/m2/kk)'
ASUMTUKI_NORMIMENO = 'Normineli�it� vastaava normivuokra, (e/kk)'
ASUMTUKI_ENIMMMENO = 'Enimm�isasumismeno osa-asunnossa, (e/kk)'
ASUMTUKI_HNORMI = 'Omakotitalon hoitonormi tai l�mmitysnormi, (e/kk)'
ASUMTUKI_POVTULO = 'Perusomavastuun laskemista varten muokattu tulo, (e/kk)'
ASUMTUKI_PERUSOMV = 'Perusomavastuu, (e/kk)'

ASUMTUKI_EVESI = 'Erillinen vesimaksu, (0/1)'
ASUMTUKI_ELAMM = 'Erillinen l�mmitysmaksu, (0/1)'
ASUMTUKI_AIKUISIA = 'Aikuisten lukum��r�'

ASUMTUKI_MAARAK = 'Asumistuki, (e/kk)'
ASUMTUKI_MAARAV = 'Asumistuki, (e/v)';

KEEP &VALITUT;

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

FORMAT ASUMTUKI_VUOSI ASUMTUKI_KUUK ASUMTUKI_ASTYYPPI ASUMTUKI_OMAKOTI ASUMTUKI_PERHE ASUMTUKI_PUOLISO ASUMTUKI_LAPSIA
ASUMTUKI_VAMM ASUMTUKI_VAMMLKM ASUMTUKI_LAMMRYHMA ASUMTUKI_KESKLAMM ASUMTUKI_VESIJOHTO ASUMTUKI_LKRYHMA ASUMTUKI_KRYHMA
ASUMTUKI_VALMVUOSI ASUMTUKI_YKSHUOLT ASUMTUKI_EVESI ASUMTUKI_ELAMM ASUMTUKI_AIKUISIA ASUMTUKI_YKSHUOLT 8.;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
    DROP ASUMTUKI_KUUK;
%END;

RUN;

* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_YA, ASUMTUKI);


%MEND AsumTuki_Simuloi_Esimerkki;

%AsumTuki_Simuloi_Esimerkki;

%LET EG = 0;
