/**********************************************************************
* Kuvaus: P��mallin (KOKO) esimerkkilaskelmien pohja 			      *
**********************************************************************/ 

/*
Lasketaan etuuksia ja ansiotulojen veroja       		
henkil�lle ja puolisolle sek� lapsilisi�, elatustukea 
asumistukia, p�iv�hoitomaksuja ja toimeentulotukea    
kotitalouksille.

1) Makro "Aloitus": Yhteisi� oletuksia makromuuttujina.
   Jos oletukset annetaan t�m�n ohjelman ulkopuolelta, t�t� ei ajeta.
2) Makro "Generoi_Muuttujat": Fiktiivisen datan generointi, makromuuttujien johdonmukaisuutta tarkistetaan.
   Jos oletukset annetaan t�m�n ohjelman ulkopuolelta, t�t� ei ajeta.
3) Makro KOKO_LASKENTA yksil�tason laskentaa varten.
	KOKO_LASKENTA (0) laskee henkil�lle
	KOKO_LASKENTA (1) laskee puolisolle.
	Puolisot erotetaan suff-makromuuttujan avulla antamalla muuttujille nimet muodossa NIMI ja NIMI_PUOL.
4) Makro KOKO_LASKENTA_KOTIT kotitaloustason laskentaa varten
5) Ajetaan kuusi makroa: Aloitus, TeeMakrot, KOKO_LASKENTA (0), KOKO_LASKENTA (1) ja KOKO_LASKENTA_KOTIT
   ja lasketaan marginaaliveroasteet.
6) Kootaan ja tulostetaan tulokset
*/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KOKO = koko_esim_&SYSDATE._1; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 2;		* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains��d�nt� ;
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
%LET AVUOSI = 2023; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko ;

* Simuloinnissa k�ytett�vien lakimakrotiedostojen nimet ;

%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;
%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;
%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;
%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;
%LET LAKIMAK_TIED_LL = LLISAlakimakrot;
%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;
%LET LAKIMAK_TIED_KE = KANSELlakimakrot;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;
%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;
%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;
%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;
%LET LAKIMAK_TIED_PH = PHOITOlakimakrot;
%LET LAKIMAK_TIED_EP = EPIDEMlakimakrot;

* Simuloinnissa k�ytett�vien parametritaulukoiden nimet ;

%LET POPINTUKI = popintuki;
%LET PTTURVA = ptturva;
%LET PSAIRVAK = psairvak;
%LET PKOTIHTUKI = pkotihtuki;
%LET PLLISA = pllisa;
%LET PTOIMTUKI = ptoimtuki;
%LET PKANSEL = pkansel;
%LET PVERO = pvero;
%LET PVERO_VARALL = pvero_varall;
%LET PASUMTUKI = pasumtuki;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;
%LET PELASUMTUKI = pelasumtuki;
%LET PPHOITO = pphoito;
%LET PEPIDEM = pepidem;

%END;

* Ajetaan lakimakrot ja tallennetaan ne;

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KE..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";
%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EP..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan t�m�n koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

/* 2.0 Lains��d�nt�vuosi ja -kuukausi*/

%LET MINIMI_KOKO_VUOSI = 2022;
%LET MAKSIMI_KOKO_VUOSI = 2023;

%LET MINIMI_KOKO_KUUK = 12;
%LET MAKSIMI_KOKO_KUUK = 12;

/* 2.1 Perhett� koskevia tietoja */

/*
PUOLISO = 0 tai 1
LAPSIA_ALLE3: Alle 3-vuotiaiden lasten lukum��r�
LAPSIA_3_6: 3-6-vuotiaiden lasten lukum��r�
LAPSIA_7_9: 7-9-vuotiaiden lasten lukum��r�
LAPSIA_10_15: 10-15-vuotiaiden lasten lukum��r�
LAPSIA_16: 16-vuotiaiden lasten lukum��r�
LAPSIA_17: 17-vuotiaiden lasten lukum��r�

Eri ik�ryhmiin kuuluvien lasten lukum��r�t:
 - Alle 3-vuotiaiden ja 3-6-vuotiaden lasten lukum��r�t tarvitaan
   lasten kotihoidon tuen ja p�iv�hoitomaksujen laskentaan.
 - Alle 10-vuotiaat ja 10 v t�ytt�neet lapset on eritelt�v� toimeentulotukea varten.
 - 16-vuotiaiden ja 17-vuotiaiden lasten lukum��r� tarvitaan, jos
   eri j�rjestelmien (lapsilis�t, asumistuki, el�kkeensaajien
   lapsikorotus, verotus, ty�tt�myysturva) ik�rajat ja niiden muutokset
   1990-luvulta l�htien halutaan ottaa huomioon.
 - Jos kiinnostus liittyy vain normaalin nykyisen lain 
   lapsilis��n riitt�� esim. muuttuja lapsia_10_15.
 - 18 vuotta t�ytt�neit� lapsia ei oteta malliin.
 - Jos TILANNE = 3, alle 3-vuotiaat lapset ovat hoitolapsia.
*/

%LET MINIMI_KOKO_PUOLISO = 0;
%LET MINIMI_KOKO_LAPSIA_ALLE3 = 0;
%LET MINIMI_KOKO_LAPSIA_3_6 = 0;
%LET MINIMI_KOKO_LAPSIA_7_9 = 0;
%LET MINIMI_KOKO_LAPSIA_10_15 = 0;
%LET MINIMI_KOKO_LAPSIA_16 = 0;
%LET MINIMI_KOKO_LAPSIA_17 = 0;

/* 2.2 Ik� */

/*
IKA: Henkil�n ik�
IKA_PUOL: Puolison ik�
Vaikuttaa mm. opintotukeen, ty�el�ke- ja ty�tt�myysvakuutusmaksuihin
sek� sairausvakuutuksen p�iv�rahamaksuun. 
*/

%LET MINIMI_KOKO_IKA = 32;
%LET MINIMI_KOKO_IKA_PUOL = 32;

/* 2.3 Asuinpaikkaan kytkeytyvi� tietoja */

/*
Yleisen asumistuen m��r�ytymiseen liittyv�t tiedot:

YAKRYHMA:
Yleisen asumistuen kuntaryhm�, voi saada arvoja 1-4.
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
4 = Muut kunnat

YALISAKRYHMA (2015->): 
Yleisen asumistuen maakuntaryhm�, voi saada arvoja 0-2.
Ryhmittely kertoo, miss� maakunnissa asuvat saavat
korotuksen hyv�ksytt�viin l�mmitysmenoihin ja
omistusasunnon hoitonormeihin. 
0 = ei korotusta
1 = Etel�-Savo, Pohjois-Savo ja Pohjois-Karjala
2 = Pohjois-Pohjanmaa, Kainuu ja Lappi

YALAMMRYHMA (<-2014):
Yleisen asumistuen l�mmitysryhm�, voi saada arvoja 1-3.
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
3 = Muut kunnat

El�kkeensaajan asumistuen m��r�ytymiseen liittyv�t tiedot:

EAKRYHMA:
El�kkeensaajan asumistuen kuntaryhm�, voi saada arvoja 1-4.
Huom. Kuntien ryhmittely voi muuttua vuosien v�lill�
eik� ryhmien numerointi v�ltt�m�tt� vastaa
lains��d�nn�n mukaista numerointia.
Seuraava ryhmittely on voimassa 2015-2017:
1 = Helsinki
2 = Espoo, Kauniainen ja Vantaa
3 = Hyvink��, H�meenlinna, Joensuu, Jyv�skyl�, J�rvenp��,
Kerava, Kirkkonummi, Kouvola, Kuopio, Lahti,
Lappeenranta, Lohja, Nurmij�rvi, Oulu,
Pori, Porvoo, Raisio, Riihim�ki, Rovaniemi, Sein�joki,
Sipoo, Tampere, Turku, Tuusula, Vaasa ja Vihti
4 = Muut kunnat

EALAMMRYHMA:
El�kkeensaajan asumistuen l�mmitysryhm�, voi saada arvoja 1-3.
Huom. Kuntien ryhmittely voi muuttua vuosien v�lill�
eik� ryhmien numerointi v�ltt�m�tt� vastaa
lains��d�nn�n mukaista numerointia.
Seuraava ryhmittely on voimassa vuosina 2015-2017:
1 = Askola, Aura, Espoo, Eura, Eurajoki, Hamina, Hanko,
Harjavalta, Helsinki, Honkajoki, Huittinen, Hyvink��,
Iitti, Imatra, Inkoo, J�mij�rvi, J�rvenp��, Kaarina,
Kankaanp��, Karkkila, Karvia, Kauniainen, Kemi�nsaari,
Kerava, Kirkkonummi, Kokem�ki, Koski, Kotka, Kouvola,
Kustavi, K�yli�, Laitila, Lapinj�rvi, Lappeenranta, Lemi,
Lieto, Lohja, Loimaa, Loviisa, Luum�ki, Luvia, Marttila,
Masku, Merikarvia, Miehikk�l�, Myn�m�ki, Myrskyl�, M�nts�l�,
Naantali, Nakkila, Nousiainen, Nurmij�rvi, Orimattila,
Orip��, Paimio, Parainen, Parikkala, Pomarkku, Pori,
Pornainen, Porvoo, Pukkila, Punkalaidun, Pyht��, Pyh�ranta,
P�yty�, Raasepori, Raisio, Rauma, Rautj�rvi, Ruokolahti,
Rusko, Salo, Sastamala, Sauvo, Savitaipale, Siikainen,
Sipoo, Siuntio, Somero, S�kyl�, Taipalsaari, Taivassalo,
Turku, Tuusula, Ulvila, Uusikaupunki, Vantaa, Vehmaa,
Vihti, Virolahti sek� Ahvenanmaan maakunnan kunnat
2 = Akaa, Alaj�rvi, Alavus, Asikkala, Enonkoski,
Evij�rvi, Forssa, Halsua, Hartola, Hattula, Hausj�rvi,
Heinola, Hein�vesi, Hirvensalmi, Hollola, Humppila,
H�meenkoski, H�meenkyr�, H�meenlinna, Ikaalinen,
Ilmajoki, Isojoki, Isokyr�, Jalasj�rvi, Janakkala,
Jokioinen, Joroinen, Juupajoki, Juva, Kangasala,
Kangasniemi, Kannus, Karijoki, Kaskinen, Kauhajoki,
Kauhava, Kaustinen, Kihni�, Kokkola, Korsn�s,
Kristiinankaupunki, Kruunupyy, Kuortane, Kurikka,
K�rk�l�, Lahti, Laihia, Lappaj�rvi, Lapua, Lemp��l�,
Lestij�rvi, Loppi, Luoto, Maalahti, Mikkeli, Mustasaari,
M�ntt�-Vilppula, M�ntyharju, Nastola, Nokia, N�rpi�,
Orivesi, Padasjoki, Parkano, Peders�ren kunta, Perho,
Pertunmaa, Pieks�m�ki, Pietarsaari, Pirkkala, Puumala,
P�lk�ne, Rantasalmi, Riihim�ki, Ruovesi, Savonlinna,
Sein�joki, Soini, Sulkava, Sysm�, Tammela, Tampere,
Teuva, Toholampi, Urjala, Uusikaarlepyy, Vaasa,
Valkeakoski, Vesilahti, Veteli, Vimpeli, Virrat,
V�yri, Yl�j�rvi, Yp�j� ja �ht�ri
3 = Muut kunnat

Kuntien kalleusluokitukseen liittyv� tieto
(merkityst� vuonna 2007 ja sit� ennen):

KELRYHMA (<-2007):
Kunnan kalleusluokka, 1/2. 
Huom. Kuntien ryhmittely voi muuttua vuosien v�lill�.
Seuraava ryhmittely on voimassa vuonna 2007:
1 = Br�nd�, Ecker�, Enonteki�, Espoo, Finstr�m, F�gl�,
Geta, Hammarland, Helsinki, Houtskari, Hyrynsalmi,
Hyvink��, H�meenlinna, Ii, Inari, Ini�, Joensuu,
Jomala, Jyv�skyl�, J�rvenp��, Kauniainen, Kemi,
Kemij�rvi, Keminmaa, Kerava, Kirkkonummi, Kittil�,
Kolari, Korppoo, Kumlinge, Kuopio, Kuusamo,
K�kar, Lempland, Lumparland, Maarianhamina, Muonio,
Nauvo, Oulu, Pelkosenniemi, Pello, Posio, Ranua,
Ristij�rvi, Rovaniemi, Salla, Saltvik, Savukoski
Simo, Sodankyl�, Sottunga, Sund, Tampere, Tervola,
Tornio, Utsjoki, Vaasa, Vantaa, V�rd�, Ylitornio,
2 = Muut kunnat

Alueellisiin veroihin liittyv�t tiedot:

KUNNVERO: 
Kunnallinen veroprosentti desimaaliprosenttilukuna, > 0, esim. 19.30
999 = sovelletaan keskim��r�ist� veroprosenttia

KIKRVERO: 
Kirkollinen veroprosentti desimaaliprosenttilukuna, >= 0, esim. 1.20
0 = kirkollisveroa ei lasketa
999 = sovelletaan keskim��r�ist� veroprosenttia
*/

%LET MINIMI_KOKO_YAKRYHMA = 1;
%LET MINIMI_KOKO_YALISAKRYHMA = 0;
%LET MINIMI_KOKO_YALAMMRYHMA = 1;
%LET MINIMI_KOKO_EAKRYHMA = 1;
%LET MINIMI_KOKO_EALAMMRYHMA = 1;	
%LET MINIMI_KOKO_KELRYHMA = 1;
%LET MINIMI_KOKO_KUNNVERO = 18.00;
%LET MINIMI_KOKO_KIRKVERO = 0;

/* 2.4 Asuntoon liittyvi� tietoja */

/*
VALMVUOSI: Asunnon valmistumis- tai perusparannusvuosi
PINTALA: Asunnon pinta-ala, (m2)
OMISTUS: Omistusasunto: 0 tai 1: jos 0 asunto tulkitaan vuokra-asunnoksi
OMAKOTI: Omakotitalo: 0 tai 1: jos OMISTUS = 0, ei vaikutusta.
VUOKRA_VASTIKE: e/kk, tulkitaan vuokraksi tai yhti�vasikkeeksi makromuuttujan OMISTUS mukaisesti;
VESI: Vesimaksu, (e/kk)
ASKORKO = Asuntolainan korko e/kk; Jos OMISTUS = 0, t�ll� ei ole vaikutusta
*/

%LET MINIMI_KOKO_VALMVUOSI = 1970;
%LET MINIMI_KOKO_PINTALA = 55;
%LET MINIMI_KOKO_OMISTUS = 0;
%LET MINIMI_KOKO_OMAKOTI = 0;
%LET MINIMI_KOKO_VUOKRA_VASTIKE = 750;
%LET MINIMI_KOKO_VESI = 0;
%LET MINIMI_KOKO_ASKOROT = 0;

/* 2.5 Henkil�iden el�m�ntilanne (suluissa olevia vaihtoehtoja ei ole viel� otettu huomioon)  */ 

/* 2.5.1 Henkil�n status */

/*
1 Palkansaaja
2 Ty�t�n (oletus: ansiosidonnainen)
21 Perusp�iv�raha
22 Ty�markkinatuki
3 Sairausvakuutuksen p�iv�raha (oletus: normaali)
31 Vanhempainp�iv�raha (oletus: normaali)
311 Korotettu �itiys-/raskausraha
312 Korotettu vanhempainraha
(32 Osap�iv�raha)
4 Lasten kotihoidon tuki
(41 Osittainen kotihoidon tuki)
5 Opiskelija (oletus: korkeakoulu, itsen�isesti asuva, ennen vuoden 2014 syyslukukautta aloittanut)
51 Uusi opiskelija: korkeakoulu, itsen�inen (vuoden 2014 syyslukukaudella ja sen j�lkeen aloittaneet)
52 Opiskelija: keskiaste, itsen�inen
6 El�kel�inen 
7 Leski (lesken jatkoel�ke ja mahdollinen lapsenel�ke)

Huomautuksia TILANNE-makromuuttujasta:
 - Jos TILANNE = 1 ja palkkatulot = 0, malli laskee tulottoman
   henkil�n tai kotitalouden lapsietuudet, yleisen asumistuen ja toimeentulotuen.
 - Eri tilanteet ovat toisensa poissulkevia.
   Se ei kuitenkaan tarkoita kaikilta osin eri tyyppisten tulojen poissulkevuutta:
	- ty�tt�m�ll�, lasten kotihoidon tuen saajalla, el�kel�isell� ja opiskelijalla voi olla palkkatuloa
	- sairaus- tai vanhempainp�iv�rahan saajalla ei voi olla palkkatuloa
 - Jos tilanteessa 6 on kyse ty�kyvytt�myysel�kel�isest�, on huomiotava, ett� h�nen ty�tulonsa eiv�t
   saa ylitt�� tietty� rajaa (KANSEL-mallin lakiparametri RajaTyotulo, 737.45 e/kk vuonna 2018)
   tai kansanel�ke ja takuuel�ke on j�tett�v� lep��m��n. T�t� huomiointia ei ole esimerkkilaskelmissa
   mukana automaattisesti.
*/

%LET MINIMI_KOKO_TILANNE = 1;

/* 2.5.2 Puolison status */

/*
Jos PUOLISO = 0, ei vaikutusta.
Samat arvot kuin TILANNE-muuttujassa.
*/

%LET MINIMI_KOKO_TILANNE_PUOL = 1;

/* 2.5.3 Lis�oletuksia ty�tt�myysturvaa varten */

/*
KOROTUS: Korotusosa, 0 tai 1
MTURVA: Muutosturvalis�/ty�llist�misohjelmalis�, 0 tai 1
Huom. Korotusosa tulee kummallekin puolisolle, jos kummatkin ty�tt�mi�.
AKTIIVI: Aktiivimallin leikkuri, 0 tai 1
*/

%LET MINIMI_KOKO_KOROTUS = 0;
%LET MINIMI_KOKO_MTURVA = 0;
%LET MINIMI_KOKO_AKTIIVI = 0;

/* 2.5.4 Lis�oletus toimeentulotukea varten */

/* Toimeentulotukea saaville lis�ehto koskien sit�, lasketaanko my�s mahdollinen epidemiakorvaus (0/1) */ 
%LET MINIMI_KOKO_EPIDEMKORVL = 0;

/* 2.6 Palkkatulo (e/kk) */

/*
- Jos TILANNE = 2, t�m� tulkitaan ty�tt�myysajan ty�tuloksi eli sovitelluksi ty�tuloksi
- Jos TILANNE = 3, t�t� ei oteta huomioon 
- Jos TILANNE = 4, t�m� palkka on mahdollinen samanaikaisesti  lasten kotihoidon tuen kanssa.
- Jos TILANNE = 5, t�m� on opintotukikuukausien aikana saatua palkkaa.
- Jos TILANNE = 6 tai 7, t�m� on el�kekuukausien aikana saatua palkkaa.
*/

%LET MINIMI_KOKO_PALKKA = 0;
%LET MAKSIMI_KOKO_PALKKA = 2500; 
%LET KYNNYS_KOKO_PALKKA = 500;

/* Sama puolisolle. Ei vaikutusta, jos puoliso = 0 */

%LET MINIMI_KOKO_PALKKA_PUOL = 0;
%LET MAKSIMI_KOKO_PALKKA_PUOL = 0; 
%LET KYNNYS_KOKO_PALKKA_PUOL = 500;

/* 2.6.1 Tulonhankkimiskulut, Ay-maksut ja ty�matkakulut */

/* Tulonhankkimiskulut (e/kk) */
%LET MINIMI_KOKO_TULONHANKKULUT = 0;
%LET MAKSIMI_KOKO_TULONHANKKULUT = 0;
%LET KYNNYS_KOKO_TULONHANKKULUT = 100;

/* Tulonhankkimiskulut, puoliso (e/kk) */
%LET MINIMI_KOKO_TULONHANKKULUT_PUOL = 0;
%LET MAKSIMI_KOKO_TULONHANKKULUT_PUOL = 0;
%LET KYNNYS_KOKO_TULONHANKKULUT_PUOL = 100;

/* Ay-j�senmaksut (e/kk) */
%LET MINIMI_KOKO_AYMAKSUT = 0;
%LET MAKSIMI_KOKO_AYMAKSUT = 0; 
%LET KYNNYS_KOKO_AYMAKSUT = 10;

/* Ay-j�senmaksut (e/kk), puoliso */
%LET MINIMI_KOKO_AYMAKSUT_PUOL = 0;
%LET MAKSIMI_KOKO_AYMAKSUT_PUOL = 0; 
%LET KYNNYS_KOKO_AYMAKSUT_PUOL = 10;

/* Ty�matkakulut (e/kk) */
%LET MINIMI_KOKO_TYOMATKAKULUT = 0;
%LET MAKSIMI_KOKO_TYOMATKAKULUT = 0; 
%LET KYNNYS_KOKO_TYOMATKAKULUT = 200;

/* Ty�matkakulut (e/kk), puoliso */
%LET MINIMI_KOKO_TYOMATKAKULUT_PUOL = 0;
%LET MAKSIMI_KOKO_TYOMATKAKULUT_PUOL = 0; 
%LET KYNNYS_KOKO_TYOMATKAKULUT_PUOL = 200;

/* 2.6.2 Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa (e/kk) */

%LET MINIMI_KOKO_ASKEL = 1;
%LET MAKSIMI_KOKO_ASKEL = 1; 
%LET KYNNYS_KOKO_ASKEL = 1;

/* 2.7 Ty�el�ke (e/kk) */

/* T�ll� on vaikutusta vain, jos tilanne = 6 tai 7 */

%LET MINIMI_KOKO_ELAKE = 0;
%LET MAKSIMI_KOKO_ELAKE = 0; 
%LET KYNNYS_KOKO_ELAKE = 250;

/* Sama puolisolle. Ei vaikutusta, jos puoliso = 0 */

%LET MINIMI_KOKO_ELAKE_PUOL = 0;
%LET MAKSIMI_KOKO_ELAKE_PUOL = 0; 
%LET KYNNYS_KOKO_ELAKE_PUOL = 250;

/* 2.8 P�iv�rahan perusteena oleva bruttopalkka ennen v�hennyksi� (e/kk) */

/*
- Jos TILANNE = 2 tai 3, t�m� tulkitaan tukijaksoa edelt�v�ksi palkaksi, johon p�iv�rahan suuruus perustuu. 
  T�ll�in jos EDPALKKA = 0, lasketaan perusp�iv�raha tai vanhenpainrahan tapauksessa minimip�iv�raha.
  Sairausp�iv�rahan tapauksessa t�m�n tulee olla suurempi kuin 0 tai muuten sairausp�iv�rahaa ei lasketa.
- Jos TILANNE = 1, 4, 5, 6 tai 7, t�t� ei oteta huomioon
- P�iv�rahan laskuvaiheessa t�st� palkasta v�hennet��n vakuutusmaksuv�hennys ja tulonhankkimisv�hennys, jonka
  arvoksi oletetaan viran puolesta v�hennett�v� minimim��r�.
*/

%LET MINIMI_KOKO_EDPALKKA = 0;
%LET MAKSIMI_KOKO_EDPALKKA = 0;
%LET KYNNYS_KOKO_EDPALKKA = 100;

/* Sama puolisolle. Ei vaikutusta, jos PUOLISO = 0 */

%LET MINIMI_KOKO_EDPALKKA_PUOL = 0;
%LET MAKSIMI_KOKO_EDPALKKA_PUOL = 0;
%LET KYNNYS_KOKO_EDPALKKA_PUOL = 100;

%END;

/* 2.9 Muuttujien johdonmukaisuuden varmistaminen, varoitukset */

/* Asuntolainan korot otetaan huomioon vain omistusasunnosa */

%IF &MINIMI_KOKO_OMISTUS = 0 AND &MINIMI_KOKO_ASKOROT NE 0 %THEN %PUT WARNING: Asuntolainan korot otetaan huomioon vain omistusasunnosa;

/* Helsinki on aina kuulunut kalleusluokkaan 1 */

%IF (&MINIMI_KOKO_YAKRYHMA = 1 AND &MINIMI_KOKO_EAKRYHMA = 1) AND &MINIMI_KOKO_KELRYHMA NE 1 %THEN %PUT WARNING: Helsinki on aina kuulunut kalleusluokkaan 1 (KELRYHMA);

/* Kotihoidon tukea voi saada puolisoista vain toinen */
/* Jos kyse on puolisoista, viitehenkil� ei voi saada kotihoidon tukea */

%IF &MINIMI_KOKO_PUOLISO = 1 AND &MINIMI_KOKO_TILANNE = 4 AND &MINIMI_KOKO_TILANNE_PUOL = 4 %THEN %PUT WARNING: Kotihoidon tukea voi saada puolisoista vain toinen;

/* Korotusosa ja muutosturva eiv�t p�de yht�aikaa */

%IF &MINIMI_KOKO_KOROTUS = 1 AND &MINIMI_KOKO_MTURVA = 1 %THEN %PUT WARNING: Korotusosa ja muutosturva eiv�t p�de yht�aikaa;

/* Vuonna 2017 vuosikeskiarvoistaminen ei huomioi oikein opiskelijoiden siirtoa yleiseen asumistukeen */

%IF &VUOSIKA = 1 AND (%SUBSTR(&MINIMI_KOKO_TILANNE, 1, 1) = 5 OR (&MINIMI_KOKO_PUOLISO = 1 AND %SUBSTR(&MINIMI_KOKO_TILANNE_PUOL, 1, 1) = 5)) AND &MINIMI_KOKO_VUOSI <= 2017 AND &MAKSIMI_KOKO_VUOSI >= 2017 %THEN %DO;
	%PUT WARNING: Vuonna 2017 vuosikeskiarvoistaminen ei huomioi oikein opiskelijoiden siirtoa yleiseen asumistukeen;
	%PUT WARNING: Valitse VUOSIKA = 2 ja haluamasi lains��d�nt�kuukausi!;
%END;

/* 2.10 Generoidaan data makromuuttujien arvojen mukaisesti ja tarkastetaan johdonmukaisuus */ 

DATA OUTPUT.&TULOSNIMI_KOKO;

DO KOKO_VUOSI = &MINIMI_KOKO_VUOSI TO &MAKSIMI_KOKO_VUOSI;
DO KOKO_KUUK = &MINIMI_KOKO_KUUK TO &MAKSIMI_KOKO_KUUK;
 KOKO_PUOLISO = &MINIMI_KOKO_PUOLISO ;
 KOKO_LAPSIA_ALLE3 = &MINIMI_KOKO_LAPSIA_ALLE3;
 KOKO_LAPSIA_3_6 = &MINIMI_KOKO_LAPSIA_3_6;
 KOKO_LAPSIA_7_9 = &MINIMI_KOKO_LAPSIA_7_9;
 KOKO_LAPSIA_10_15 = &MINIMI_KOKO_LAPSIA_10_15;
 KOKO_LAPSIA_16 = &MINIMI_KOKO_LAPSIA_16;
 KOKO_LAPSIA_17 = &MINIMI_KOKO_LAPSIA_17;
 KOKO_IKA = &MINIMI_KOKO_IKA;
 KOKO_IKA_PUOL = &MINIMI_KOKO_IKA_PUOL;
 KOKO_YAKRYHMA = &MINIMI_KOKO_YAKRYHMA;
 KOKO_YALISAKRYHMA = &MINIMI_KOKO_YALISAKRYHMA;
 KOKO_YALAMMRYHMA = &MINIMI_KOKO_YALAMMRYHMA;
 KOKO_EAKRYHMA = &MINIMI_KOKO_EAKRYHMA;
 KOKO_EALAMMRYHMA = &MINIMI_KOKO_EALAMMRYHMA;
 KOKO_KELRYHMA = &MINIMI_KOKO_KELRYHMA;
 KOKO_KUNNVERO = &MINIMI_KOKO_KUNNVERO;
 KOKO_KIRKVERO = &MINIMI_KOKO_KIRKVERO;
 KOKO_VALMVUOSI = &MINIMI_KOKO_VALMVUOSI;
 KOKO_PINTALA = &MINIMI_KOKO_PINTALA;
 KOKO_OMISTUS = &MINIMI_KOKO_OMISTUS;
 KOKO_OMAKOTI = &MINIMI_KOKO_OMAKOTI;
 KOKO_VUOKRA_VASTIKE = &MINIMI_KOKO_VUOKRA_VASTIKE;
 KOKO_VESI = &MINIMI_KOKO_VESI;
 KOKO_ASKOROT = &MINIMI_KOKO_ASKOROT;
 KOKO_TILANNE = &MINIMI_KOKO_TILANNE;
 KOKO_TILANNE_PUOL = &MINIMI_KOKO_TILANNE_PUOL;
 KOKO_KOROTUS = &MINIMI_KOKO_KOROTUS;
 KOKO_MTURVA = &MINIMI_KOKO_MTURVA;
 KOKO_AKTIIVI = &MINIMI_KOKO_AKTIIVI;
 KOKO_EPIDEMKORVL = &MINIMI_KOKO_EPIDEMKORVL;

DO KOKO_PALKKA = &MINIMI_KOKO_PALKKA TO &MAKSIMI_KOKO_PALKKA BY &KYNNYS_KOKO_PALKKA;
DO KOKO_TULONHANKKULUT = &MINIMI_KOKO_TULONHANKKULUT TO &MAKSIMI_KOKO_TULONHANKKULUT BY &KYNNYS_KOKO_TULONHANKKULUT;
DO KOKO_AYMAKSUT = &MINIMI_KOKO_AYMAKSUT TO &MAKSIMI_KOKO_AYMAKSUT BY &KYNNYS_KOKO_AYMAKSUT;
DO KOKO_TYOMATKAKULUT = &MINIMI_KOKO_TYOMATKAKULUT TO &MAKSIMI_KOKO_TYOMATKAKULUT BY &KYNNYS_KOKO_TYOMATKAKULUT;
DO KOKO_ELAKE = &MINIMI_KOKO_ELAKE TO &MAKSIMI_KOKO_ELAKE BY &KYNNYS_KOKO_ELAKE;
DO KOKO_EDPALKKA = &MINIMI_KOKO_EDPALKKA TO &MAKSIMI_KOKO_EDPALKKA BY &KYNNYS_KOKO_EDPALKKA;
DO KOKO_ASKEL = &MINIMI_KOKO_ASKEL TO &MAKSIMI_KOKO_ASKEL BY &KYNNYS_KOKO_ASKEL;
DO KOKO_PALKKA_PUOL = &MINIMI_KOKO_PALKKA_PUOL TO &MAKSIMI_KOKO_PALKKA_PUOL BY &KYNNYS_KOKO_PALKKA_PUOL;
DO KOKO_TULONHANKKULUT_PUOL = &MINIMI_KOKO_TULONHANKKULUT_PUOL TO &MAKSIMI_KOKO_TULONHANKKULUT_PUOL BY &KYNNYS_KOKO_TULONHANKKULUT_PUOL;
DO KOKO_AYMAKSUT_PUOL = &MINIMI_KOKO_AYMAKSUT_PUOL TO &MAKSIMI_KOKO_AYMAKSUT_PUOL BY &KYNNYS_KOKO_AYMAKSUT_PUOL;
DO KOKO_TYOMATKAKULUT_PUOL = &MINIMI_KOKO_TYOMATKAKULUT_PUOL TO &MAKSIMI_KOKO_TYOMATKAKULUT_PUOL BY &KYNNYS_KOKO_TYOMATKAKULUT_PUOL;
DO KOKO_EDPALKKA_PUOL = &MINIMI_KOKO_EDPALKKA_PUOL TO &MAKSIMI_KOKO_EDPALKKA_PUOL BY &KYNNYS_KOKO_EDPALKKA_PUOL;
DO KOKO_ELAKE_PUOL = &MINIMI_KOKO_ELAKE_PUOL TO &MAKSIMI_KOKO_ELAKE_PUOL BY &KYNNYS_KOKO_ELAKE_PUOL;

/* 2.11 Inflaatiokerron */

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */
%InfKerroin_ESIM(&AVUOSI, KOKO_VUOSI, &INF);

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;

%MACRO Tarkista_Muuttujat;

/* 3. Tarkastetaan generoitu data */
DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;

/* 3.1 Tarkistuksia TILANNE-muuttujan mukaisesti */

/* Jos TILANNE ei ole 2, 3, 31, 311 tai 312, EDPALKKA = 0 */
IF KOKO_TILANNE NE 2 AND KOKO_TILANNE NE 3 AND KOKO_TILANNE NE 31 AND KOKO_TILANNE NE 311
	AND KOKO_TILANNE NE 312 THEN KOKO_EDPALKKA = 0;

IF KOKO_TILANNE_PUOL NE 2 AND KOKO_TILANNE_PUOL NE 3 AND KOKO_TILANNE_PUOL NE 31 AND KOKO_TILANNE_PUOL NE 311
	AND KOKO_TILANNE_PUOL NE 312 THEN KOKO_EDPALKKA_PUOL = 0;

/* Jos TILANNE on 3, 31, 311 tai 312, PALKKA = 0 */
IF KOKO_TILANNE = 3 OR KOKO_TILANNE = 31 OR KOKO_TILANNE = 311
	OR KOKO_TILANNE = 312 THEN KOKO_PALKKA = 0;

IF KOKO_TILANNE_PUOL = 3 OR KOKO_TILANNE_PUOL = 31 OR KOKO_TILANNE_PUOL = 311
	OR KOKO_TILANNE_PUOL = 312 THEN KOKO_PALKKA_PUOL = 0;

/* El�ketuloa vain, jos TILANNE = 6 tai 7 */
IF KOKO_TILANNE NE 6 AND KOKO_TILANNE NE 7 THEN KOKO_ELAKE = 0;

IF KOKO_TILANNE_PUOL NE 6 AND KOKO_TILANNE NE 7 THEN KOKO_ELAKE_PUOL = 0;

/* Jos PUOLISO = 0, puolison tulot nollataan varmuuden vuoksi */
	
IF KOKO_PUOLISO = 0 THEN DO;
	KOKO_PALKKA_PUOL = 0;
	KOKO_EDPALKKA_PUOL = 0;
	KOKO_ELAKE_PUOL = 0;
	KOKO_TULONHANKKULUT_PUOL = 0;
	KOKO_AYMAKSUT_PUOL = 0;
	KOKO_TYOMATKAKULUT_PUOL = 0;
END;

/* 3.2 Muuttujien johdonmukaisuuden varmistaminen */

/* Asuntolainan korot otetaan huomioon vain omistusasunnosa */

IF KOKO_OMISTUS = 0 THEN KOKO_ASKOROT = 0;

/* Helsinki on aina kuulunut kalleusluokkaan 1 */

IF (KOKO_YAKRYHMA = 1 AND KOKO_EAKRYHMA = 1) THEN KOKO_KELRYHMA = 1;

/* Kotihoidon tukea voi saada puolisoista vain toinen */
/* Jos kyse on puolisoista, viitehenkil� ei voi saada kotihoidon tukea */

IF KOKO_PUOLISO = 1 AND KOKO_TILANNE = 4 THEN KOKO_TILANNE = 1;

/* Korotusosa ja muutosturva eiv�t p�de yht�aikaa */

IF KOKO_KOROTUS = 1 THEN KOKO_MTURVA = 0;

/* Opiskelun aloitusajankohdan m��ritteleminen lakimakroja varten */

IF KOKO_TILANNE = 51 THEN KOKO_ALOITUSPVM = MDY(8,1,2014);
ELSE KOKO_ALOITUSPVM = .;
IF KOKO_TILANNE_PUOL = 51 THEN KOKO_ALOITUSPVM_PUOL = MDY(8,1,2014);
ELSE KOKO_ALOITUSPVM_PUOL = .;

RUN;

/* Poistetaan tuplarivit */
PROC SORT DATA = OUTPUT.&TULOSNIMI_KOKO NODUPRECS; BY _ALL_; RUN;

%MEND Tarkista_Muuttujat;

%Tarkista_Muuttujat;

/* 4. Yksil�tason laskenta */

%MACRO KOKO_LASKENTA(onkopuoliso);

/* onkopuoliso-parametri lis�� muuttujien nimeen _puol-liitteen.
   Jos oletusten mukaan puolisoa ei ole, t�ll� ei ole vaikutusta */

%IF &onkopuoliso = 1 %THEN %LET suff = _PUOL;
%ELSE %LET suff = ;

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;

/* Nollataan sellaisia muuttujia, joita ei v�ltt�m�tt� aina tuoteta */
TYOTPR&suff = 0;
SAIRPR&suff = 0;
SVHANKVAH&suff = 0;
KOTIHTU&suff = 0;
OPIR&suff = 0;
OPRAHA&suff = 0;
OPLAI&suff = 0;
OPLAINA&suff = 0;
ASLIS&suff = 0;
ASUMLISA&suff = 0;
KANSEL&suff = 0;
TAKUUEL&suff = 0;
LESKENELAK&suff = 0;
ELAKYHT&suff = 0;
LAPSIKORO&suff = 0;
OPINTUKI_TUKIAIKA&suff = 0;
%IF &onkopuoliso = 0 %THEN %DO;
LAPSENELAK = 0;
KOTIHTULOT = 0;
ELATTUKI = 0;
%END;

/* Jos puolison laskennassa puolisoa ei sittenk��n ole, niin ohitetaan rivi ja menn��n seuraavalle riville */
IF &onkopuoliso = 0 OR (&onkopuoliso = 1 AND KOKO_PUOLISO) THEN DO; /* Puolisocheck */

/* 4.1 Ty�tt�myysp�iv�rahat */

IF SUBSTRN(KOKO_TILANNE&suff, 1, 1) = 2 THEN DO;

	YHTLAPSIATTURVA&suff = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17);

	IF KOKO_TILANNE&suff = 2 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%AnsioSidKS (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, YHTLAPSIATTURVA&suff, KOKO_KOROTUS, KOKO_MTURVA, 0, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
			IF (KOKO_KOROTUS OR KOKO_MTURVA) AND KOKO_VUOSI >= 2013 THEN DO;
				%AnsioSidKS (TYOTPRIK&suff, KOKO_VUOSI, KOKO_KUUK, INF, YHTLAPSIATTURVA&suff, 0, 0, 0, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
				TYOTKOROSA&suff=SUM(TYOTPR&suff,-TYOTPRIK&suff);
			END;
		%END;
		%ELSE %DO;
			%AnsioSidVS (TYOTPR&suff, KOKO_VUOSI, INF, YHTLAPSIATTURVA&suff, KOKO_KOROTUS, KOKO_MTURVA, 0, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
			IF (KOKO_KOROTUS OR KOKO_MTURVA) AND KOKO_VUOSI >= 2013 THEN DO;
				%AnsioSidVS (TYOTPRIK&suff, KOKO_VUOSI, INF, YHTLAPSIATTURVA&suff, 0, 0, 0, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
				TYOTKOROSA&suff=SUM(TYOTPR&suff,-TYOTPRIK&suff);
			END;
		%END;
	END;
	ELSE IF KOKO_TILANNE&suff = 21 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%PerusPRahaKS (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, (KOKO_KOROTUS OR KOKO_MTURVA), KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, 0, aktiivi=KOKO_AKTIIVI);
		%END;
		%ELSE %DO;
			%PerusPRahaVS (TYOTPR&suff, KOKO_VUOSI, INF, 0, (KOKO_KOROTUS OR KOKO_MTURVA), KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, 0, aktiivi=KOKO_AKTIIVI);
		%END;
		IF (KOKO_KOROTUS OR KOKO_MTURVA) AND KOKO_VUOSI >= 2013 THEN TYOTKOROSA&suff = &TTPaivia * &KorotusOsa;
	END;
	ELSE IF KOKO_TILANNE&suff = 22 THEN DO; 

    	%IF &VUOSIKA = 2 %THEN %DO; 
			%IF (&onkopuoliso = 0) %THEN %DO;
               	%TyomTukiKS (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, KOKO_PALKKA_PUOL, 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0, aktiivi=KOKO_AKTIIVI); 
			%END;
			%ELSE %DO;
				%TyomTukiKS (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA, TYOTPR), 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0, aktiivi=KOKO_AKTIIVI); 
            %END; 
		%END;
        %ELSE %DO; 
			%IF (&onkopuoliso = 0) %THEN %DO;
           		%TyomTukiVS (TYOTPR&suff, KOKO_VUOSI, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, KOKO_PALKKA_PUOL , 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0, aktiivi=KOKO_AKTIIVI); 
			%END;
			%ELSE %DO;
				%TyomTukiVS (TYOTPR&suff, KOKO_VUOSI, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA, TYOTPR), 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0, aktiivi=KOKO_AKTIIVI); 
			%END;
		 %END; 
		 IF (KOKO_KOROTUS OR KOKO_MTURVA) AND KOKO_VUOSI >= 2013 THEN TYOTKOROSA&suff = &TTPaivia * &KorotusOsa;
      END;


	/* 4.1.1 Sovitellut p�iv�rahat */

	IF KOKO_PALKKA&suff > 0 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SoviteltuKS (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, IFN(KOKO_TILANNE&suff = 2, 1, 0), (KOKO_KOROTUS OR KOKO_MTURVA), (YHTLAPSIATTURVA&suff > 0), TYOTPR&suff, KOKO_PALKKA&suff, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
		%END;
		%ELSE %DO;
			%SoviteltuVS (TYOTPR&suff, KOKO_VUOSI, INF, IFN(KOKO_TILANNE&suff = 2, 1, 0), (KOKO_KOROTUS OR KOKO_MTURVA), (YHTLAPSIATTURVA&suff > 0), TYOTPR&suff, KOKO_PALKKA&suff, KOKO_EDPALKKA&suff, 0, aktiivi=KOKO_AKTIIVI);
		%END;
	END;
	IF TYOTKOROSA&suff THEN TYOTKOROSA&suff = MAX(0, MIN(TYOTKOROSA&suff, TYOTPR&suff));
END;

/* 4.2 Sairausvakuutuksen p�iv�rahat */

IF SUBSTRN(KOKO_TILANNE&suff, 1, 1) = 3 THEN DO;

	YHTLAPSIASAIRVAK&suff = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15);

	/* Lasketaan tulonhankkimiskulut muuttujaan SVHANKVAH*/

	%TulonHankKulutS(SVHANKVAH&suff, KOKO_VUOSI, INF, 12*SUM(KOKO_EDPALKKA&suff),
		0, 0, 0, 0);

	/* Vuodesta 2020 eteenp�in sairausp�iv�rahan laskennassa ei huomioida tulonhankkimiskuluja */

	IF KOKO_VUOSI >= 2020 THEN DO;
		SVHANKVAH&suff = 0;
	END;

	TULO&suff =  MAX(12 * KOKO_EDPALKKA&suff, 0);

	/* 4.2.1 Tavallinen sairausp�iv�raha tai osap�iv�raha */

	IF KOKO_TILANNE&suff = 3 OR KOKO_TILANNE&suff = 32 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SairVakPrahaKS (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
		%ELSE %DO;
			%SairVakPrahaVS (SAIRPR&suff, KOKO_VUOSI, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
	END;

	/* 4.2.2 Normaali vanhempainp�iv�raha */

	IF KOKO_TILANNE&suff = 31 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SairVakPrahaKS (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
		%ELSE %DO;
			%SairVakPrahavS (SAIRPR&suff, KOKO_VUOSI, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
	END;
	
	/* 4.2.3 Korotettu vanhemnpainp�iv�raha; �itiysraha 56 ensimm�iselt� p�iv�lt� / raskausp�iv�raha 40 p�iv�lt�; 90 %:n kerroin */

	IF KOKO_TILANNE&suff = 311 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%KorVanhRahaKS (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
		%ELSE %DO;
			%KorVanhRahavS (SAIRPR&suff, KOKO_VUOSI, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
	END;

	/* 4.2.4 Korotettu vanhempainraha; muut tapaukset; 75 %:n kerroin 2015 asti. 90 % kerroin 08/2022 alkaen */

	IF KOKO_TILANNE&suff = 312 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			 %KorVanhRahaKS (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
		%ELSE %DO;
			%KorVanhRahaVS (SAIRPR&suff, KOKO_VUOSI, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff, tulonhankk = SVHANKVAH&suff);
		%END;
	END;

	/* 4.2.5 Osap�iv�raha puolet normaalista sairausp�iv�rahasta */

	IF KOKO_TILANNE&suff = 32 THEN DO;

	    SAIRPR&suff = 0.5 * SAIRPR&suff;

	END;

END;

/* 4.3 Opintotuki */

/* 4.3.1 Opintoraha ja -laina */
/*Tuki lasketaan tulojen perusteella niin, ett� laskennassa k�ytet��n maksimim��r� mink� henkil� voisi 
opintukea muiden tulojen j�lkeen nostaa*/
/* Lasketaan my�s opintolaina, jota k�ytet��n toimeentulotuen laskennassa */

IF SUBSTRN(KOKO_TILANNE&suff, 1, 1) = 5 THEN DO;

	ONHUOLTAJA&suff = IFN(SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17) > 0, 1, 0);
	
	/* Tukikuukausien m��r� tulojen perusteella */

	%TukiKuukOik (OPINTUKI_TUKIAIKA&suff, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PALKKA&suff * 12, 12);

	%IF &VUOSIKA = 2 %THEN %DO;
		%OpRahaKS (OPIR&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=ONHUOLTAJA&suff);
		%OpRahaKS (OPIR_ILMHUOLT&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=0);
		%OpRahaKS (OPIR_ILMOP&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=ONHUOLTAJA&suff, oppimateriaali=0);		
		%OpRahaKS (OPIR_ILMHUOLTOP&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=0, oppimateriaali=0);
	%END;
	%ELSE %DO;
		%OpRahaVS (OPIR&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=ONHUOLTAJA&suff);
		%OpRahaVS (OPIR_ILMHUOLT&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=0);
		%OpRahaVS (OPIR_ILMOP&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=ONHUOLTAJA&suff, oppimateriaali=0);
		%OpRahaVS (OPIR_ILMHUOLTOP&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff, 0, 12* KOKO_PALKKA&suff, 0, 0, 0, aloituspvm=KOKO_ALOITUSPVM&suff, huoltaja=0, oppimateriaali=0);
	%END;

	/*Nollataan opintotuki henkil�ilt�, jotka eiv�t siihen ole tulojensa puolesta oikeutettuja*/
	IF OPINTUKI_TUKIAIKA&suff = 0 THEN DO;
		OPIR&suff = 0;
		OPIR_ILMHUOLT&suff = 0;
		OPIR_ILMOP&suff = 0;
		OPIR_ILMHUOLTOP&suff = 0;
	END;
	/* Kuukausikeskiarvo */
	OPRAHA&suff = OPIR&suff * OPINTUKI_TUKIAIKA&suff / 12;
	OPRAHA_ILMHUOLT&suff = OPIR_ILMHUOLT&suff * OPINTUKI_TUKIAIKA&suff / 12;
	OPRAHA_ILMOP&suff = OPIR_ILMOP&suff * OPINTUKI_TUKIAIKA&suff / 12;
	OPRAHA_ILMHUOLTOP&suff = OPIR_ILMHUOLTOP&suff * OPINTUKI_TUKIAIKA&suff / 12;

	%IF &VUOSIKA = 2 %THEN %DO;
		%OpLainaKS (OPLAI&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff);
	%END;
	%ELSE %DO;
		%OpLainaVS (OPLAI&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), 0, KOKO_IKA&suff);
	%END;

	/*Nollataan opintolaina henkil�ilt�, jotka eiv�t siihen ole tulojensa puolesta oikeutettuja*/
	IF OPINTUKI_TUKIAIKA&suff = 0 THEN OPLAI&suff = 0;
	/* Kuukausikeskiarvo */
	OPLAINA&suff = OPLAI&suff * OPINTUKI_TUKIAIKA&suff / 12;
END;

/* 4.3.2 Opintotuen asumislis� */

/* Opintotuen asumislis� lasketaan henkil�kohtaisena tulona, jos TILANNE on  (5, 51),
   jos asunto vuokra-asunto ja jos henkil�ll� tai puolisoilla ei ole lapsia.
   Yhteislaskennassa hyv�ksyt��n puolisoille vain jos kumpikin puoliso on opiskelija.
   Omistusasuntoon asumislis�� ei lasketa. */

IF SUBSTRN(KOKO_TILANNE&suff, 1, 1) = 5 AND KOKO_OMISTUS = 0 AND 
	SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17) = 0
	THEN DO;

	/* Puolisoilla vuokra puolitetaan asumislis�n erikseen laskemista varten */

	IF KOKO_PUOLISO = 1 THEN VUOKRA = KOKO_VUOKRA_VASTIKE/2;
	ELSE VUOKRA = KOKO_VUOKRA_VASTIKE;

	%IF &VUOSIKA = 2 %THEN %DO;
		%AsumLisaKS (ASLIS&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff NE 52), KOKO_IKA&suff, 0, VUOKRA, KOKO_PALKKA&suff, 0, 0, 0);
	%END;
	%ELSE %DO;
		%AsumLisaVS (ASLIS&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff NE 52), KOKO_IKA&suff, 0, VUOKRA, KOKO_PALKKA&suff, 0, 0, 0);
	%END;
	
	/*Nollataan opintotuen asumislis� henkil�ilt�, jotka eiv�t siihen ole tulojensa puolesta oikeutettuja*/
	IF OPINTUKI_TUKIAIKA&suff = 0 THEN ASLIS&suff = 0;
	/* Kuukausikeskiarvo */
	ASUMLISA&suff = ASLIS&suff * OPINTUKI_TUKIAIKA&suff / 12;
END;

/* 4.4 Kansanel�ke, takuuel�ke ja el�kkeensaajan lapsikorotukset */

IF KOKO_TILANNE&suff = 6 THEN DO;

	%IF &VUOSIKA = 2 %THEN %DO;
		%Kansanelake_SimpleKS (KANSEL&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, 12*KOKO_ELAKE&suff, 1);
		%TakuuElakeKS (TAKUUEL&suff, KOKO_VUOSI, KOKO_KUUK, INF, SUM(KOKO_ELAKE&suff, KANSEL&suff), 1);
	%END;
	%ELSE %DO;
		%Kansanelake_SimpleVS (KANSEL&suff, KOKO_VUOSI, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, 12*KOKO_ELAKE&suff, 1);
		%TakuuElakeVS (TAKUUEL&suff, KOKO_VUOSI, INF, SUM(KOKO_ELAKE&suff, KANSEL&suff), 1);

	%END;
	ELAKYHT&suff = SUM(KOKO_ELAKE&suff, KANSEL&suff, TAKUUEL&suff);

	/* Lasketaan el�kkeensaajien lapsikorotukset */
	/* Vain alle 16-vuotiaat lapset otetaan huomioon */

	ELLAPSIA = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15);

	%IF &VUOSIKA = 2 %THEN %DO;
		%KanselLisatKS (LAPSIKORO&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, 0, 0, 0,0, 0, 0, KOKO_KELRYHMA, ELLAPSIA); 
	%END;
	%ELSE %DO;
		%KanselLisatVS (LAPSIKORO&suff, KOKO_VUOSI, INF, 1, 0, 0, 0, 0,0, 0, 0, KOKO_KELRYHMA, ELLAPSIA);
	%END;
END;

/* 4.5 Lesken jatkoel�ke */

IF KOKO_TILANNE&suff = 7 THEN DO;

	LESKLAPSIA = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17);

	%IF &VUOSIKA = 2 %THEN %DO;
		%LeskenElakeAKS(LESKENELAK&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, LESKLAPSIA, KOKO_PALKKA&suff*12, 0, KOKO_ELAKE&suff*12, 0);
		%LapsenelakeAKS(LAPSENELAK, KOKO_VUOSI, KOKO_KUUK, INF, 0, 0, 0);
	%END;
	%ELSE %DO;
		%LeskenElakeAVS(LESKENELAK&suff, KOKO_VUOSI, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, LESKLAPSIA, KOKO_PALKKA&suff*12, 0, KOKO_ELAKE&suff*12, 0);
		%LapsenelakeAVS(LAPSENELAK, KOKO_VUOSI, INF, 0, 0, 0);
	%END;

	LAPSENELAK = LAPSENELAK * LESKLAPSIA;
	ELAKYHT&suff = SUM(KOKO_ELAKE&suff, LESKENELAK&suff);

END;

/* 4.6 Elatustuki */

/* Lasten lukum��r� elatustukea (ja asumistukia) varten */

KOKO_LAPSIAYHT = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17);

/* Jos yksinhuoltaja, lasketaan elatustuki */

IF KOKO_PUOLISO = 0 AND KOKO_LAPSIAYHT > 0 AND KOKO_TILANNE NE 7 THEN DO;

	%IF &VUOSIKA = 2 %THEN %DO;
		%ElatTukiKS (ELATTUKI, KOKO_VUOSI, KOKO_KUUK, INF, 0, KOKO_LAPSIAYHT);
		* Alle 3-vuotiaista maksetut elatustuet kotihoidon tuen hoitolis�n laskemista varten;
		%ElatTukiKS (ELATTUKI_ALLE3, KOKO_VUOSI, KOKO_KUUK, INF, 0, KOKO_LAPSIA_ALLE3);
		* Yhden lapsen elatustuki p�iv�hoitomaksujen laskentaa varten;
		%ElatTukiKS (ELATTUKI_YKSILAPSI, KOKO_VUOSI, KOKO_KUUK, INF, 0, 1);
	%END;
	%ELSE %DO;
		%ElatTukiVS (ELATTUKI, KOKO_VUOSI, INF, 0, KOKO_LAPSIAYHT);
		* Alle 3-vuotiaista maksetut elatustuet kotihoidon tuen hoitolis�n laskemista varten;
		%ElatTukiVS (ELATTUKI_ALLE3, KOKO_VUOSI, INF, 0, KOKO_LAPSIA_ALLE3);
		* Yhden lapsen elatustuki p�iv�hoitomaksujen laskentaa varten;
		%ElatTukiVS (ELATTUKI_YKSILAPSI, KOKO_VUOSI, INF, 0, 1);
	%END;
END;

/* 4.7 Kotihoidon tuki */

/* Kotihoidon tuki voidaan laskea vasta kun kummankin puolison muut veronalaiset tulot ovat tiedossa.
   Jos kyse on puolisoista, laskenta tapahtuu vain kun KOKO_TILANNE_PUOL = 4 ja &onkopuoliso = 1.
   T�ll�in vain puolisolla voi olla kotihoidon tukea, ei viitehenkil�ll�.
   Lis�ksi edellytet��n, ett� kotitaloudessa on alle 3-vuotiaita lapsia */

IF ((KOKO_TILANNE = 4 AND KOKO_PUOLISO = 0 AND &onkopuoliso = 0) OR (KOKO_TILANNE_PUOL = 4 
	AND KOKO_PUOLISO = 1 AND &onkopuoliso = 1)) AND KOKO_LAPSIA_ALLE3 > 0 THEN DO;
		
	* Elatustuet otetaan huomioon hoitolis�n perusteena olevassa tulossa 1.3.2017 eteenp�in;
	IF KOKO_VUOSI > 2017 THEN ELTUKI_HLISA = ELATTUKI_ALLE3;
	ELSE ELTUKI_HLISA = 0;
	%IF &VUOSIKA = 1 %THEN %DO;
		IF KOKO_VUOSI = 2017 THEN ELTUKI_HLISA = 2/12 * ELATTUKI_ALLE3;
	%END;
	%IF &VUOSIKA = 2 %THEN %DO;
		IF KOKO_VUOSI = 2017 AND KOKO_KUUK < 3 THEN ELTUKI_HLISA = ELATTUKI_ALLE3;
	%END;

	* Hoitolis�n perusteena oleva tulo;
	KOTIHTULOT = SUM(KOKO_PALKKA, KOKO_PALKKA_PUOL, SAIRPR, SAIRPR_PUOL, TYOTPR, TYOTPR_PUOL, ELAKYHT, ELAKYHT_PUOL, ELTUKI_HLISA);
	
	SISARIA = MAX(KOKO_LAPSIA_ALLE3 - 1, 0);

	KOKO = SUM(1, KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, IFN(KOKO_PUOLISO, 1, 0));

	%IF &VUOSIKA = 2 %THEN %DO;
		%KotihTukiKS (KOTIHTU&suff, KOKO_VUOSI, KOKO_KUUK, INF, SISARIA, KOKO_LAPSIA_3_6, KOKO, KOTIHTULOT, 0);
	%END;
	%ELSE %DO;
		%KotihTukiVS (KOTIHTU&suff, KOKO_VUOSI, INF, SISARIA, KOKO_LAPSIA_3_6, KOKO, KOTIHTULOT, 0);
	%END;
END;

/* 4.8 Verotus */

/* 4.8.1 El�kevakuutusmaksu ja muut palkasta peritt�v�t maksut */

%TyoelMaksuS (TYOEL&suff, KOKO_VUOSI, INF, KOKO_IKA&suff, 12*KOKO_PALKKA&suff);

%TyotMaksuS (TYOTMAKSU&suff, KOKO_VUOSI, INF, KOKO_IKA&suff, 12*KOKO_PALKKA&suff);

%SvPRahaMaksuS (SVPRMAKSU&suff, KOKO_VUOSI, INF, KOKO_IKA&suff, 12*KOKO_PALKKA&suff);

PALKVAK&suff = SUM(TYOEL&suff, TYOTMAKSU&suff, SVPRMAKSU&suff);

/* 4.8.2 Tulonhankkimisv�hennys */

IF KOKO_PALKKA&suff > 0 THEN DO;
	
	%TulonHankKulutS(HANKVAH&suff, KOKO_VUOSI, INF, 12*KOKO_PALKKA&suff,
		12*KOKO_TULONHANKKULUT&suff, 12*KOKO_AYMAKSUT&suff, 12*KOKO_TYOMATKAKULUT&suff, 0);

END;
ELSE DO;
	HANKVAH&suff = 0;
END;

ANSIOTULO&suff = 12*SUM(KOKO_PALKKA&suff, TYOTPR&suff, SAIRPR&suff, KOTIHTU&suff, OPRAHA&suff, ELAKYHT&suff);

PUHDANSIOTULO&suff = MAX(ANSIOTULO&suff - HANKVAH&suff, 0);

 ************************************************************************************************************************************************************;
 * Ohjelma haarautuu kahteen osaan, joista ensimm�isess� otetaan k�ytt��n sotemuutokset (vuodesta 2023 eteenp�in) ja toisessa noudatetaan vanhaa lains��d�nt��*; 
 ************************************************************************************************************************************************************;
IF KOKO_VUOSI >= 2023 THEN DO; 
	******************************************************************;
	* T�ss� otetaan huomioon sote-uudistuksen aiheuttamat muutokset  *;
	******************************************************************;

	/* 4.8.3 Ansiotulov�hennys */

	%AnsVahS (ANS&suff, KOKO_VUOSI, INF,  PUHDANSIOTULO&suff, 12*KOKO_PALKKA&suff);

	/* 4.8.4 Opintorahav�hennys */

	%OpRahVahS (OPRAHVAH&suff, KOKO_VUOSI, INF, 12*OPRAHA&suff, PUHDANSIOTULO&suff);

	/* 4.8.5 El�ketulov�hennys */

	%ElTulVahS (ELVAH&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, PUHDANSIOTULO&suff);

	/* 4.8.6 Verotettava tulo ennen perusv�hennyst� */

	VERTULO1&suff = MAX(SUM(ANSIOTULO&suff, -PALKVAK&suff, -HANKVAH&suff, -ANS&suff, -OPRAHVAH&suff, -ELVAH&suff), 0);

	/* 4.8.7 Perusv�hennys */

	%PerVahS (PER&suff, KOKO_VUOSI, INF, VERTULO1&suff);

	/* 4.8.8 Verotettava tulo */

	VERTULO2&suff = MAX(VERTULO1&suff - PER&suff, 0);

	/* 4.8.9 Kunnallisvero */

	IF KOKO_KUNNVERO = 999 THEN DO;
		
	  %KunnVeroS (KUNNVERO&suff, KOKO_VUOSI, INF, 1, 18, VERTULO2&suff);

	END;
	ELSE DO;

	  %KunnVeroS (KUNNVERO&suff, KOKO_VUOSI, INF, 0, KOKO_KUNNVERO, VERTULO2&suff);

	END;

	/* 4.8.10 Kirkollisvero */

	IF KOKO_KIRKVERO = 999 THEN DO;
		
	  %KirkVeroS (KIRKVERO&suff, KOKO_VUOSI, INF, 1, 18, VERTULO2&suff);

	END;
	ELSE DO;

	  %KirkVeroS (KIRKVERO&suff, KOKO_VUOSI, INF, 0, KOKO_KIRKVERO, VERTULO2&suff);

	END;

	/* 4.8.11 Sairaanhoitomaksu/sairausvakuutusmaksu */

	%SairVakMaksuS (SAIRVAKM&suff, KOKO_VUOSI, INF, VERTULO2&suff, ELAKYHT&suff, 12*KOKO_PALKKA&suff);

	/* 4.8.12 Kansanel�kevakuutusmaksu */

	%KanselVakMaksuS (KANSELM&suff, KOKO_VUOSI, INF, VERTULO2&suff, 0);

	/* 4.8.13 Valtionverotuksen el�ketulov�hennys */

	*%ValtElTulVahS (VALTELVAH&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, PUHDANSIOTULO&suff, ANSIOTULO&suff);

	/* 4.8.14 Valtionverotuksessa verotettava tulo */

	*VALTVERTULO&suff = MAX(SUM(ANSIOTULO&suff, - PALKVAK&suff, - HANKVAH&suff, -VALTELVAH&suff), 0);

	/* 4.8.15 Valtionvero ennen verosta teht�vi� v�hennyksi� */

	%ValtTuloVeroS (VALTVERO&suff, KOKO_VUOSI, INF, VERTULO2&suff);

	%ElakeLisaVeroS(ELAKELISAVERO&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, ELVAH&suff);

	VALTVERO&suff = SUM(VALTVERO&suff, ELAKELISAVERO&suff);

	/* 4.8.16 Ansiotulov�hennys/ty�tulov�hennys valtionverosta ja sen jako eri verolajeihin */

	%ValtVerTyotVahS_2023 (VALTANS&suff, KOKO_VUOSI, INF, 12*KOKO_PALKKA&suff, PUHDANSIOTULO&suff, KOKO_IKA&suff);

	%VahennJakoS(VALTVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 1, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
	%VahennJakoS(KUNNVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 2, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
	%VahennJakoS(SAIRVAKM_B&suff, KOKO_VUOSI, VALTANS&suff, 3, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
	%VahennJakoS(KANSELM_B&suff, KOKO_VUOSI, VALTANS&suff, 4, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
	%VahennJakoS(KIRKVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 5, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
	
	VALTVERO_C&suff = VALTVERO_B&suff;
	KUNNVERO_C&suff = KUNNVERO_B&suff;
	SAIRVAKM_C&suff = SAIRVAKM_B&suff;
	KANSELM_C&suff = KANSELM_B&suff;
	KIRKVERO_C&suff = KIRKVERO_B&suff;

END;

ELSE DO;
	********************************************************************************************************;
	* T�ss� ei oteta huomioon sote-uudistuksen aiheuttamia muutoksia eli noudatetaan vanhaa lains��d�nt��  *;
	********************************************************************************************************;	
	/* 4.8.3 Kunnallisverotuksen ansiotulov�hennys */

	%KunnAnsVahS (KUNNANS&suff, KOKO_VUOSI, INF,  PUHDANSIOTULO&suff, ANSIOTULO&suff, 12*KOKO_PALKKA&suff, 12*KOKO_PALKKA&suff, ANSIOTULO&suff);

	/* 4.8.4 Opintorahav�hennys */

	%KunnOpRahVahS (OPRAHVAH&suff, KOKO_VUOSI, INF, 1, 12*OPRAHA&suff, ANSIOTULO&suff, PUHDANSIOTULO&suff);

	/* 4.8.5 Kunnallisverotuksen el�ketulov�hennys */

	%KunnElTulVahS (KUNNELVAH&suff, KOKO_VUOSI, INF, KOKO_PUOLISO, 0, 12*ELAKYHT&suff, PUHDANSIOTULO&suff, ANSIOTULO&suff);

	/* 4.8.6 Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst� */

	KUNNVERTULO1&suff = MAX(SUM(ANSIOTULO&suff, -PALKVAK&suff, -HANKVAH&suff, -KUNNANS&suff, -OPRAHVAH&suff, -KUNNELVAH&suff), 0);

	/* 4.8.7 Perusv�hennys */

	%KunnPerVahS (KUNNPER&suff, KOKO_VUOSI, INF, KUNNVERTULO1&suff);

	/* 4.8.8 Kunnallisverotuksessa verotettava tulo */

	KUNNVERTULO2&suff = MAX(KUNNVERTULO1&suff - KUNNPER&suff, 0);

	/* 4.8.9 Kunnallisvero */

	IF KOKO_KUNNVERO = 999 THEN DO;
		
	  %KunnVeroS (KUNNVERO&suff, KOKO_VUOSI, INF, 1, 18, KUNNVERTULO2&suff);

	END;
	ELSE DO;

	  %KunnVeroS (KUNNVERO&suff, KOKO_VUOSI, INF, 0, KOKO_KUNNVERO, KUNNVERTULO2&suff);

	END;

	/* 4.8.10 Kirkollisvero */

	IF KOKO_KIRKVERO = 999 THEN DO;
		
	  %KirkVeroS (KIRKVERO&suff, KOKO_VUOSI, INF, 1, 18, KUNNVERTULO2&suff);

	END;
	ELSE DO;

	  %KirkVeroS (KIRKVERO&suff, KOKO_VUOSI, INF, 0, KOKO_KIRKVERO, KUNNVERTULO2&suff);

	END;

	/* 4.8.11 Sairaanhoitomaksu/sairausvakuutusmaksu */

	%SairVakMaksuS (SAIRVAKM&suff, KOKO_VUOSI, INF, KUNNVERTULO2&suff, ELAKYHT&suff, 12*KOKO_PALKKA&suff);

	/* 4.8.12 Kansanel�kevakuutusmaksu */

	%KanselVakMaksuS (KANSELM&suff, KOKO_VUOSI, INF, KUNNVERTULO2&suff, 0);

	/* 4.8.13 Valtionverotuksen el�ketulov�hennys */

	%ValtElTulVahS (VALTELVAH&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, PUHDANSIOTULO&suff, ANSIOTULO&suff);

	/* 4.8.14 Valtionverotuksessa verotettava tulo */

	VALTVERTULO&suff = MAX(SUM(ANSIOTULO&suff, - PALKVAK&suff, - HANKVAH&suff, -VALTELVAH&suff), 0);

	/* 4.8.15 Valtionvero ennen verosta teht�vi� v�hennyksi� */

	%ValtTuloVeroS (VALTVERO&suff, KOKO_VUOSI, INF, VALTVERTULO&suff);

	%ElakeLisaVeroS(ELAKELISAVERO&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, VALTELVAH&suff);

	VALTVERO&suff = SUM(VALTVERO&suff, ELAKELISAVERO&suff);

	/* 4.8.16 Ansiotulov�hennys/ty�tulov�hennys valtionverosta ja sen jako eri verolajeihin */

	%ValtVerAnsVahS (VALTANS&suff, KOKO_VUOSI, INF, 12*KOKO_PALKKA&suff, PUHDANSIOTULO&suff);

	IF KOKO_VUOSI > 2008 THEN DO;

		%VahennJakoS(VALTVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 1, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
		%VahennJakoS(KUNNVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 2, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
		%VahennJakoS(SAIRVAKM_B&suff, KOKO_VUOSI, VALTANS&suff, 3, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
		%VahennJakoS(KANSELM_B&suff, KOKO_VUOSI, VALTANS&suff, 4, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);
		%VahennJakoS(KIRKVERO_B&suff, KOKO_VUOSI, VALTANS&suff, 5, VALTVERO&suff, KUNNVERO&suff, SAIRVAKM&suff, KANSELM&suff, KIRKVERO&suff, 0);

	END;

	ELSE DO; 

	VALTVERO_B&suff = MAX(VALTVERO&suff - VALTANS&suff, 0);
	KUNNVERO_B&suff = KUNNVERO&suff;
	SAIRVAKM_B&suff = SAIRVAKM&suff;
	KANSELM_B&suff = KANSELM&suff;
	KIRKVERO_B&suff = KIRKVERO&suff;

	END;

	/* 4.8.17 Lapsiv�hennys ja sen jako eri verolajeihin */

	%ValtVerLapsVahS(VALTLAPS&suff, KOKO_VUOSI, INF,  -(KOKO_PUOLISO-1), SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), PUHDANSIOTULO&suff);

	IF KOKO_VUOSI > 2014 THEN DO;
		
		%VahennJakoS(VALTVERO_C&suff, KOKO_VUOSI, VALTLAPS&suff, 1, VALTVERO_B&suff, KUNNVERO_B&suff, SAIRVAKM_B&suff, KANSELM_B&suff, KIRKVERO_B&suff, 0);
		%VahennJakoS(KUNNVERO_C&suff, KOKO_VUOSI, VALTLAPS&suff, 2, VALTVERO_B&suff, KUNNVERO_B&suff, SAIRVAKM_B&suff, KANSELM_B&suff, KIRKVERO_B&suff, 0);
		%VahennJakoS(SAIRVAKM_C&suff, KOKO_VUOSI, VALTLAPS&suff, 3, VALTVERO_B&suff, KUNNVERO_B&suff, SAIRVAKM_B&suff, KANSELM_B&suff, KIRKVERO_B&suff, 0);
		%VahennJakoS(KANSELM_C&suff, KOKO_VUOSI, VALTLAPS&suff, 4, VALTVERO_B&suff, KUNNVERO_B&suff, SAIRVAKM_B&suff, KANSELM_B&suff, KIRKVERO_B&suff, 0);
		%VahennJakoS(KIRKVERO_C&suff, KOKO_VUOSI, VALTLAPS&suff, 5, VALTVERO_B&suff, KUNNVERO_B&suff, SAIRVAKM_B&suff, KANSELM_B&suff, KIRKVERO_B&suff, 0);

	END;

	ELSE DO; 

	VALTVERO_C&suff = VALTVERO_B&suff;
	KUNNVERO_C&suff = KUNNVERO_B&suff;
	SAIRVAKM_C&suff = SAIRVAKM_B&suff;
	KANSELM_C&suff = KANSELM_B&suff;
	KIRKVERO_C&suff = KIRKVERO_B&suff;

	END;
END;

**************************************************************************************************************************;


VARSVEROTYHT&suff = MAX(SUM(VALTVERO_C&suff, KUNNVERO_C&suff, SAIRVAKM_C&suff, KANSELM_C&suff, KIRKVERO_C&suff), 0);
VEROTYHT&suff = SUM(VARSVEROTYHT&suff, PALKVAK&suff);

/* 4.8.18 Yleisradiovero */

%YleVeroS (YLEVERO&suff, KOKO_VUOSI, INF, 50, PUHDANSIOTULO&suff, 0);

/* 4.8.19 Nettokuukausitulo verojen j�lkeen */

VEROTYHT&suff = SUM(VEROTYHT&suff, YLEVERO&suff);

NETTOTULO&suff = MAX(SUM(ANSIOTULO&suff, -VEROTYHT&suff), 0)/12;

/* 4.8.20 Verojen osuus tuloista */

IF ANSIOTULO&suff THEN VEROJENOSUUS&suff = VEROTYHT&suff / ANSIOTULO&suff * 100;
ELSE VEROJENOSUUS&suff = 0;

DROP testi taulu_: /* Pudotetaan kaikki taulu_-alkuiset */ kkuuk
     kuuknro w y z KOKO SISARIA ELAKELISAVERO&suff LESKLAPSIA TYOTPRIK&suff TULO&suff ELATTUKI_ALLE3 ELTUKI_HLISA;  

END; /* Puolisocheck */

RUN;

%MEND KOKO_LASKENTA;

/* 5. Kotitaloustason laskenta */

%MACRO KOKO_LASKENTA_KOTIT;

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;

/* Nollataan muuttujia, joita ei v�ltt�m�tt� aina lasketa */
ASUMLISAYHT = 0;
OIKELASUM = 0;
ELASUMTUKI = 0;
ASUMTULO = 0;
PERUSOM = 0;
ASUMTUKI = 0;
PHTULO = 0;
PHMAKSUT = 0;
TOIMTUKI = 0;
EPIDEMKORV = 0;
LAPSLIS = 0;

/* 5.1 Lapsilis�t */

%IF &VUOSIKA = 2 %THEN %DO;
	%LLisaKS (LAPSLIS, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, SUM(KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15), KOKO_LAPSIA_16);
%END;
%ELSE %DO;
	%LLisaVS (LAPSLIS, KOKO_VUOSI, INF, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, SUM(KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15), KOKO_LAPSIA_16);
%END;

/* 5.2 Asuntolainan korkoihin perustuva alij��m�hvyitys lasketaan kotitaloustasolla.
       N�in v�hennyksen mahdollinen siirto ja optimointi puolisoiden kesken otetaan implisiittisesti huomioon */

/* 5.2.1 V�hennyskelpoiset korot (rajoitus vuodesta 2012 l�htien) */

%VahAsKorotS (VAHKOROT, KOKO_VUOSI, INF, 12*KOKO_ASKOROT);

/* 5.2.2 Lasten lukum��r� vaikuttaa alij��m�hyvityksen. Verotuksessa alle 17-vuotiaat lapset. */

VEROLAPS = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16);
	
%AlijHyvKotitS(ALIJHYV, KOKO_VUOSI, INF, KOKO_PUOLISO, VEROLAPS, 0, 0, 12*KOKO_ASKOROT, 0, 0);

/* 5.3 Muodostetaan kotitalouden verot ottamalla huomioon, ett� alij��m�hyvitys voidaan v�hent��
       vain 'varsinaisista' veroista. */

KOTITVARSVEROT = MAX(SUM(VARSVEROTYHT, VARSVEROTYHT_PUOL, -ALIJHYV), 0);

KOTITVEROTYHT = SUM(KOTITVARSVEROT, YLEVERO, YLEVERO_PUOL, PALKVAK, PALKVAK_PUOL);

/* 5.4 Lopullinen verotettu NETTOTULO kotitaloustasolla */

KOTITNETTOTULO = MAX(SUM(ANSIOTULO, ANSIOTULO_PUOL, (12 * LAPSENELAK), -KOTITVEROTYHT), 0)/12;

/* 5.5 Summataan opintotuen asumislis�t */

ASUMLISAYHT = SUM(ASUMLISA, ASUMLISA_PUOL);

/* 5.6 El�kkeensaajien asumistuki; lasketaan puolisoille vain, jos kumpikin saa el�ketuloa */

IF (KOKO_TILANNE = 6 OR KOKO_TILANNE = 7) AND (KOKO_PUOLISO = 0 OR KOKO_TILANNE = KOKO_TILANNE_PUOL) THEN DO;

	/* Vuodesta 2015 alkaen el�kkeensaajan asumistukea ei voi saada, jos taloudessa on lapsia. */

	IF KOKO_VUOSI < 2015 OR (KOKO_VUOSI >= 2015 AND KOKO_LAPSIAYHT = 0) THEN DO;
		
		OIKELASUM = 1;
		
		%IF &VUOSIKA = 1 %THEN %DO;
			%ElakAsumTukiVS (ELASUMTUKI, KOKO_VUOSI, INF, KOKO_PUOLISO, KOKO_PUOLISO, 0, 0, KOKO_LAPSIAYHT, KOKO_OMAKOTI, 
				KOKO_EALAMMRYHMA, 1, 1, 0, 0, KOKO_PINTALA, KOKO_VALMVUOSI, KOKO_EAKRYHMA, SUM(ANSIOTULO, ANSIOTULO_PUOL), 0, 12*KOKO_VUOKRA_VASTIKE, 12*KOKO_ASKOROT);
		%END;
		%ELSE %IF &VUOSIKA = 2 %THEN %DO;
			%ElakAsumTukiKS (ELASUMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PUOLISO, KOKO_PUOLISO, 0, 0, KOKO_LAPSIAYHT, KOKO_OMAKOTI, 
				KOKO_EALAMMRYHMA, 1, 1, 0, 0, KOKO_PINTALA, KOKO_VALMVUOSI, KOKO_EAKRYHMA, SUM(ANSIOTULO, ANSIOTULO_PUOL), 0, 12*KOKO_VUOKRA_VASTIKE, 12*KOKO_ASKOROT);
		%END;

	END;

END;

/* 5.7 Yleinen asumistuki; ehtona, ett� oikeutta el�kkeensaajien asumistukeen ei ole.
       Lis�ksi ennen vuoden 2017 elokuuta perheille, joissa ainakin toinen on opiskelija, my�nnet��n tukea vain jos perheess� on lapsia */

IF (KOKO_LAPSIAYHT > 0 OR (KOKO_VUOSI > 2017 
	%IF &VUOSIKA = 2 %THEN %DO;
	OR (KOKO_VUOSI = 2017 AND KOKO_KUUK >= 8)
	%END;
	OR (SUBSTRN(KOKO_TILANNE, 1, 1) NE 5 AND (KOKO_PUOLISO = 0 OR SUBSTRN(KOKO_TILANNE_PUOL, 1, 1) NE 5)))) AND (OIKELASUM = 0 OR OIKELASUM = .) THEN DO;

	IF KOKO_VUOSI < 2015 THEN DO;
		/* Kotitalouden henkil�iden lukum��r� */
		HENK = KOKO_LAPSIAYHT + IFN(KOKO_PUOLISO, 2, 1);
		/* Asumistuen perusomavastuun laskemista  varten muodostettu tulo */
		/* Opintorahaa ei oteta huomioon */
		%TuloMuokkausS (ASUMTULO, KOKO_VUOSI, INF, KOKO_LAPSIAYHT , HENK, 0, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0));
		/* Perusomavastuu */
		%PerusOmaVastS (PERUSOM, KOKO_VUOSI, INF, KOKO_YAKRYHMA, HENK, ASUMTULO);
	END;
	ELSE DO;
		IF KOKO_VESI > 0 THEN EVESI = 1;
		ELSE EVESI = 0;
		ARRAY ASTYOTULOT{*} KOKO_PALKKA KOKO_PALKKA_PUOL;
	END;

	IF KOKO_VUOSI < 2018 THEN DO;
		OPINRAHA_YA_HUOM = MAX(SUM(OPRAHA, OPRAHA_PUOL), 0);
	END;
	ELSE IF (&VUOSIKA = 1 AND KOKO_VUOSI < 2019) OR (&VUOSIKA = 2 AND ((KOKO_VUOSI < 2019) OR (KOKO_VUOSI = 2019 AND KOKO_KUUK < 8))) THEN DO;
		OPINRAHA_YA_HUOM = MAX(SUM(OPRAHA_ILMHUOLT, OPRAHA_ILMHUOLT_PUOL), 0);
	END;
	ELSE DO;
		OPINRAHA_YA_HUOM = MAX(SUM(OPRAHA_ILMHUOLTOP, OPRAHA_ILMHUOLTOP_PUOL), 0);
	END;

	IF KOKO_OMISTUS = 0 THEN DO;

		IF KOKO_VUOSI < 2015 THEN DO;
			%AsumTukiVuokS (ASUMTUKI, KOKO_VUOSI, INF, KOKO_YAKRYHMA, 1, 1, 1, HENK, 0, 
			KOKO_VALMVUOSI, KOKO_PINTALA, PERUSOM, KOKO_VUOKRA_VASTIKE, 0, 0);
		END;
		ELSE DO;
			%IF &VUOSIKA = 2 %THEN %DO;
				%As2015AsumistukiVuokraKS(ASUMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_YAKRYHMA, 0, KOKO_VUOKRA_VASTIKE, 0,
				EVESI, 0, KOKO_YALISAKRYHMA, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
			%ELSE %DO;
				%As2015AsumistukiVuokraVS(ASUMTUKI, KOKO_VUOSI, INF, KOKO_YAKRYHMA, 0, KOKO_VUOKRA_VASTIKE, 0,
				EVESI, 0, KOKO_YALISAKRYHMA, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
		END;

	END;

	ELSE DO;
		
		IF KOKO_VUOSI < 2015 THEN DO;
			%AsumTukiOmS (ASUMTUKI, KOKO_VUOSI, INF, KOKO_YAKRYHMA, KOKO_YALAMMRYHMA, KOKO_OMAKOTI, 1, 1, HENK, 0, KOKO_VALMVUOSI, 
			KOKO_PINTALA, PERUSOM, KOKO_VUOKRA_VASTIKE, KOKO_VESI, 0, KOKO_ASKOROT, 0);
		END;
		ELSE IF KOKO_OMAKOTI = 0 THEN DO;
			%IF &VUOSIKA = 2 %THEN %DO;
				%As2015AsumistukiOmaOsakeKS(ASUMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_YAKRYHMA, 0,
				KOKO_VUOKRA_VASTIKE, 0, EVESI, 0, KOKO_YALISAKRYHMA, KOKO_ASKOROT, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
			%ELSE %DO;
				%As2015AsumistukiOmaOsakeVS(ASUMTUKI, KOKO_VUOSI, INF, KOKO_YAKRYHMA, 0,
				KOKO_VUOKRA_VASTIKE, 0, EVESI, 0, KOKO_YALISAKRYHMA, KOKO_ASKOROT, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
		END;
		ELSE DO;
			%IF &VUOSIKA = 2 %THEN %DO;
				%As2015AsumistukiOmaTaloKS(ASUMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_YAKRYHMA, 0,
				0, KOKO_YALISAKRYHMA, KOKO_ASKOROT, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
			%ELSE %DO;
				%As2015AsumistukiOmaTaloVS(ASUMTUKI, KOKO_VUOSI, INF, KOKO_YAKRYHMA, 0,
				0, KOKO_YALISAKRYHMA, KOKO_ASKOROT, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0),
				ASTYOTULOT, IFN(KOKO_PUOLISO, 2, 1), KOKO_LAPSIAYHT, opinraha = OPINRAHA_YA_HUOM);
			%END;
		END;

	END;

END;

/* 5.8 P�iv�hoitomaksut */ 

/* Ehtona on, ett� kotitaloudessa on p�iv�hoitoik�isi� lapsia ja ett� henkil� on palkkaty�ss� (TILANNE = 1)
   tai opiskelija (TILANNE = 5) kun puolisoa ei ole tai kumpikin puoliso on palkkaty�ss� tai opiskelija.
   Lis�ksi perheess� on oltava alle kouluik�isi� lapsia. */

IF (KOKO_PUOLISO = 0 AND (KOKO_TILANNE = 1 OR SUBSTRN(KOKO_TILANNE, 1, 1) = 5)) 
     OR (KOKO_PUOLISO = 1 AND (KOKO_TILANNE = 1 OR KOKO_TILANNE = 5)
     AND (KOKO_TILANNE_PUOL = 1 OR SUBSTRN(KOKO_TILANNE_PUOL, 1, 1) = 5)) THEN DO;
	
	IF SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6) > 0 THEN DO;

		PHTULO = SUM(KOKO_PALKKA, KOKO_PALKKA_PUOL, SAIRPR, SAIRPR_PUOL, TYOTPR, TYOTPR_PUOL, ELAKYHT, ELAKYHT_PUOL, ELATTUKI_YKSILAPSI);

		%IF &VUOSIKA = 2 %THEN %DO;
			%SumPHoitoMaksuS(PHMAKSUT, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PUOLISO, SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6),  
                      SUM(KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), PHTULO);
		%END; 
		%ELSE %DO;
			%SumPHoitoMaksuVS(PHMAKSUT, KOKO_VUOSI, INF, KOKO_PUOLISO, SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6),  
                       SUM(KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), PHTULO);
		%END;
	END;

END;

/* 5.9 Toimeentulotuki, e/kk */

/* Ty�tulot, e/v */
TYOTULOT = 12 * SUM(KOKO_PALKKA);
TYOTULOT_PUOL = 12 * SUM(KOKO_PALKKA_PUOL);

/* Ty�tulojen osuus veronalaisista ansiotuloista */
IF ANSIOTULO > 0 THEN TYO_OSUUS = TYOTULOT / ANSIOTULO;
ELSE TYO_OSUUS = 0;
IF ANSIOTULO_PUOL > 0 THEN TYO_OSUUS_PUOL = TYOTULOT_PUOL / ANSIOTULO_PUOL;
ELSE TYO_OSUUS_PUOL = 0;

/* Ty�tulojen verot, e/v */
TYO_VEROT = TYO_OSUUS * SUM(VARSVEROTYHT, YLEVERO);
TYO_VEROT_PUOL = TYO_OSUUS_PUOL * SUM(VARSVEROTYHT_PUOL, YLEVERO_PUOL);

/* Muiden ansiotulojen verot, e/v */
MUUT_VEROT = (1 - TYO_OSUUS) * SUM(VARSVEROTYHT, YLEVERO);
MUUT_VEROT_PUOL = (1 - TYO_OSUUS_PUOL) * SUM(VARSVEROTYHT_PUOL, YLEVERO_PUOL);

/* Nettoty�tulot e/kk */
NETTOTYOTULO_AR1 = MAX(SUM(TYOTULOT/12, -TYO_VEROT/12, -PALKVAK/12, -KOKO_TULONHANKKULUT, -KOKO_AYMAKSUT, -KOKO_TYOMATKAKULUT), 0);
NETTOTYOTULO_AR2 = MAX(SUM(TYOTULOT_PUOL/12, -TYO_VEROT_PUOL/12, -PALKVAK_PUOL/12, -KOKO_TULONHANKKULUT_PUOL, -KOKO_AYMAKSUT_PUOL, -KOKO_TYOMATKAKULUT_PUOL), 0);
ARRAY NETTOTYOTULO_AR{*} NETTOTYOTULO_AR1 NETTOTYOTULO_AR2;
NETTOTYOTULO = SUM(NETTOTYOTULO_AR1, NETTOTYOTULO_AR2);

/* Tulonhankkimiskulut */
THKULUT_AR1 = MAX(SUM(KOKO_TULONHANKKULUT, KOKO_AYMAKSUT, KOKO_TYOMATKAKULUT), 0);
THKULUT_AR2 = MAX(SUM(KOKO_TULONHANKKULUT_PUOL, KOKO_AYMAKSUT_PUOL, KOKO_TYOMATKAKULUT_PUOL), 0);
ARRAY THKULUT_AR{*} THKULUT_AR1 THKULUT_AR2;

/* Muita verottomia tuloja */
MUUSEKALTULO = SUM(ELATTUKI, ASUMTUKI, ASUMLISAYHT, ELASUMTUKI, OPLAINA, OPLAINA_PUOL, LAPSIKORO, LAPSIKORO_PUOL);

/* Lasketaan verojen osuus ansiotuloista kun sova-maksuja ei huomioida
	(sova-maksut mukana muuttujassa VEROJENOSUUS, joten ei voida k�ytt�� sit�) */
IF ANSIOTULO > 0 THEN VOSUUSEISOVA = SUM(VARSVEROTYHT, YLEVERO)/ANSIOTULO;
ELSE VOSUUSEISOVA = 0;

/* Muu nettotulo erotuksena, (e/kk) */
MUUNETTOTULO = MAX(SUM(KOTITNETTOTULO, -NETTOTYOTULO, -KOKO_TULONHANKKULUT, -KOKO_TULONHANKKULUT_PUOL, -KOKO_AYMAKSUT, -KOKO_AYMAKSUT_PUOL, -KOKO_TYOMATKAKULUT, -KOKO_TYOMATKAKULUT_PUOL), 0);

/* Ty�tt�myysturvan korotusosat nettona, (e/kk) */
TYOTKOROSAT = SUM(TYOTKOROSA * (1 - VOSUUSEISOVA), TYOTKOROSA_PUOL * (1 - VOSUUSEISOVA));

/* Ty�tt�myysturvan korotusosat muuttuivat etuoikeutetuksi tuloksi toimeentulotuessa 1.1.2013 alkaen. */
IF KOKO_VUOSI >= 2013 THEN MUUNETTOTULO = MAX(SUM(MUUNETTOTULO, -TYOTKOROSAT), 0);

/* Opintorahan oppimateriaalilis� nettona, (e/kk) */
OPPIMAT = SUM((OPRAHA-OPRAHA_ILMOP) * (1 - VOSUUSEISOVA), (OPRAHA_PUOL-OPRAHA_ILMOP_PUOL) * (1 - VOSUUSEISOVA));

/* Opintorahan oppimateriaalilis� on etuoikeutettu tulo toimeentulotuessa 1.8.2019 alkaen.  */
IF (&VUOSIKA = 1 AND KOKO_VUOSI >= 2019) OR (&VUOSIKA = 2 AND ((KOKO_VUOSI = 2019 AND KOKO_KUUK >= 8) OR (KOKO_VUOSI >= 2020))) THEN MUUNETTOTULO = MAX(SUM(MUUNETTOTULO, -OPPIMAT), 0);

%IF &VUOSIKA = 2 %THEN %DO;
	%ToimTukiKS (TOIMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_KELRYHMA, 1, IFN(KOKO_PUOLISO, 2, 1), 0, KOKO_LAPSIA_17,
	SUM(KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9), LAPSLIS, NETTOTYOTULO_AR, SUM(MUUNETTOTULO, MUUSEKALTULO), SUM(KOKO_VUOKRA_VASTIKE, KOKO_VESI), PHMAKSUT, THKULUT_AR);
	/* Epidemiakorvaus */ 
	IF TOIMTUKI > 0 AND KOKO_EPIDEMKORVL = 1 THEN DO;
		%EpidemKorvKS(EPIDEMKORV, KOKO_VUOSI, KOKO_KUUK, INF, SUM(1, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17)); 
	END;
%END;
%ELSE %DO;
	%ToimTukiVS (TOIMTUKI, KOKO_VUOSI, INF, KOKO_KELRYHMA, 1, IFN(KOKO_PUOLISO, 2, 1), 0, KOKO_LAPSIA_17,
	SUM(KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9), LAPSLIS, NETTOTYOTULO_AR, SUM(MUUNETTOTULO, MUUSEKALTULO), SUM(KOKO_VUOKRA_VASTIKE, KOKO_VESI), PHMAKSUT, THKULUT_AR);
	/* Epidemiakorvaus */
	IF TOIMTUKI > 0 AND KOKO_EPIDEMKORVL = 1 THEN DO;
		%EpidemKorvVS(EPIDEMKORV, KOKO_VUOSI, INF, SUM(1, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, KOKO_LAPSIA_7_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17));
	END;
%END;

/* 5.10 Kotitalouden k�ytett�viss� oleva tulo, (e/kk) */

/* HUOM! T�m� ei sis�ll� opintolainaa eik� siit� v�hennet� p�iv�hoitomaksuja */

KAYT_TULO = SUM(KOTITNETTOTULO, LAPSLIS, ELATTUKI, ASUMTUKI, ASUMLISAYHT, ELASUMTUKI, LAPSIKORO, LAPSIKORO_PUOL, TOIMTUKI, EPIDEMKORV);

DROP testi taulu_: /* Pudotetaan kaikki taulu_-alkuiset */ kkuuk lapsia
     sarake kuuknro tunnus1-tunnus4 w y z povnimi1-povnimi4 KOKO 
	 VEROLAPS vahlapsia alijenimm kulkorotx HENK YHTLAPSIATTURVA YHTLAPSIATTURVA_PUOL 
     YHTLAPSIASAIRVAK YHTLAPSIASAIRVAK_PUOL ELLAPSIA VUOKRA TYOTKOROSA TYOTKOROSA_PUOL TYOTKOROSAT
	 KOKO_ALOITUSPVM KOKO_ALOITUSPVM_PUOL ONHUOLTAJA ONHUOLTAJA_PUOL 
	 OPIR_ILMHUOLT OPIR_ILMOP OPIR_ILMHUOLTOP OPIR_ILMHUOLT_PUOL OPIR_ILMOP_PUOL OPIR_ILMHUOLTOP_PUOL 
	 OPRAHA_ILMHUOLT OPRAHA_ILMOP OPRAHA_ILMHUOLTOP OPRAHA_ILMHUOLT_PUOL OPRAHA_ILMOP_PUOL OPRAHA_ILMHUOLTOP_PUOL
	 VOSUUSEISOVA ELATTUKI_YKSILAPSI
	 EVESI TYOTULOT TYOTULOT_PUOL TYO_OSUUS TYO_OSUUS_PUOL TYO_VEROT TYO_VEROT_PUOL
	 MUUT_VEROT MUUT_VEROT_PUOL NETTOTYOTULO_AR1 NETTOTYOTULO_AR2 THKULUT_AR1 THKULUT_AR2
	 OPINRAHA_YA_HUOM OPPIMAT;

RUN;

%MEND KOKO_LASKENTA_KOTIT;

/* 6. Lasketaan marginaaliveroasteet */

%MACRO Koko_Simuloi_MargVero;

/* 6.1 Otetaan talteen alkuper�iset tulokset ja nimet��n 
       laskennassa tarvittavat tulo- ja verotiedot uudelleen */

DATA TEMP.KOKO_ESIM_MARGVERO ;
SET OUTPUT.&TULOSNIMI_KOKO;
VEROT = VEROTYHT;
KTU = KAYT_TULO;
RUN;

/* 6.2 Simuloidaan malli uudestaan lis��m�ll� palkkatuloihin askeleen mukainen palkanlis� */

%Generoi_Muuttujat;

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;
KOKO_PALKKA = SUM(KOKO_PALKKA, KOKO_ASKEL);
RUN;

%Tarkista_Muuttujat;

%KOKO_LASKENTA(0);
%KOKO_LASKENTA(1);
%KOKO_LASKENTA_KOTIT;

/* 6.3 Otetaan talteen uudelleen simuloidut tulokset ja nimet��n 
       laskennassa tarvittavat tulo- ja verotiedot uudelleen */

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;
VEROT2 = VEROTYHT;
KTU2 = KAYT_TULO;
KEEP VEROT2 KTU2;
RUN;

/* 6.4 Lasketaan marginaaliveroaste ja efektiivinen marginaaliveroaste */

DATA OUTPUT.&TULOSNIMI_KOKO;
MERGE OUTPUT.&TULOSNIMI_KOKO  TEMP.KOKO_ESIM_MARGVERO ;
MARGIVERO = 100 * SUM(VEROT2, -VEROT) / (12 * KOKO_ASKEL); /* HUOM! KOKO-mallissa palkka on kuukausitasolla, jonka vuoksi my�s askel on kerrottava 12:sta */
EFMARGIVERO = 100 * (1 - (SUM(KTU2, -KTU) / KOKO_ASKEL));

DROP VEROT VEROT2 KTU2 KTU;

RUN;

%MEND Koko_Simuloi_MargVero;

/* 7. Kootaan ja tulostetaan tulokset */

%MACRO Koko_Tulokset;

/* 7.1 Laitetaan muuttujat oikeaan j�rjestykseen */

DATA OUTPUT.&TULOSNIMI_KOKO;
	RETAIN KOKO_VUOSI KOKO_KUUK KOKO_PUOLISO KOKO_LAPSIA_ALLE3 KOKO_LAPSIA_3_6 KOKO_LAPSIA_7_9 KOKO_LAPSIA_10_15 KOKO_LAPSIA_16 KOKO_LAPSIA_17 KOKO_LAPSIAYHT
	KOKO_IKA KOKO_IKA_PUOL 
	KOKO_YAKRYHMA KOKO_YALISAKRYHMA KOKO_YALAMMRYHMA KOKO_EAKRYHMA KOKO_EALAMMRYHMA	KOKO_KELRYHMA KOKO_KUNNVERO KOKO_KIRKVERO
	KOKO_VALMVUOSI KOKO_PINTALA KOKO_OMISTUS KOKO_OMAKOTI
	KOKO_VUOKRA_VASTIKE KOKO_VESI KOKO_ASKOROT KOKO_TILANNE KOKO_TILANNE_PUOL KOKO_KOROTUS KOKO_MTURVA KOKO_AKTIIVI KOKO_EPIDEMKORVL KOKO_PALKKA KOKO_TULONHANKKULUT KOKO_AYMAKSUT  
	KOKO_TYOMATKAKULUT KOKO_EDPALKKA KOKO_ELAKE KOKO_ASKEL KOKO_PALKKA_PUOL KOKO_TULONHANKKULUT_PUOL KOKO_AYMAKSUT_PUOL KOKO_TYOMATKAKULUT_PUOL KOKO_EDPALKKA_PUOL
	KOKO_ELAKE_PUOL INF TYOTPR SVHANKVAH SAIRPR KOTIHTULOT KOTIHTU OPINTUKI_TUKIAIKA OPRAHA OPIR OPLAINA OPLAI ASUMLISA ASLIS KANSEL TAKUUEL LESKENELAK LAPSENELAK ELAKYHT LAPSIKORO
	TYOEL TYOTMAKSU SVPRMAKSU PALKVAK HANKVAH ANSIOTULO PUHDANSIOTULO ANS ELVAH VERTULO1 PER VERTULO2 KUNNANS OPRAHVAH KUNNELVAH KUNNVERTULO1 KUNNPER KUNNVERTULO2 KUNNVERO KIRKVERO SAIRVAKM KANSELM
	VALTELVAH VALTVERTULO VALTVERO VALTANS VALTVERO_B KUNNVERO_B SAIRVAKM_B KANSELM_B KIRKVERO_B VALTLAPS VALTVERO_C KUNNVERO_C SAIRVAKM_C KANSELM_C KIRKVERO_C
	VARSVEROTYHT VEROTYHT YLEVERO NETTOTULO VEROJENOSUUS TYOTPR_PUOL SVHANKVAH_PUOL SAIRPR_PUOL KOTIHTU_PUOL OPINTUKI_TUKIAIKA_PUOL OPRAHA_PUOL OPIR_PUOL OPLAINA_PUOL OPLAI_PUOL
	ASUMLISA_PUOL ASLIS_PUOL KANSEL_PUOL TAKUUEL_PUOL LESKENELAK_PUOL ELAKYHT_PUOL LAPSIKORO_PUOL TYOEL_PUOL TYOTMAKSU_PUOL SVPRMAKSU_PUOL PALKVAK_PUOL HANKVAH_PUOL
	ANSIOTULO_PUOL PUHDANSIOTULO_PUOL KUNNANS_PUOL OPRAHVAH_PUOL KUNNELVAH_PUOL KUNNVERTULO1_PUOL KUNNPER_PUOL KUNNVERTULO2_PUOL KUNNVERO_PUOL KIRKVERO_PUOL
	SAIRVAKM_PUOL KANSELM_PUOL VALTELVAH_PUOL VALTVERTULO_PUOL VALTVERO_PUOL VALTANS_PUOL VALTVERO_B_PUOL KUNNVERO_B_PUOL SAIRVAKM_B_PUOL KANSELM_B_PUOL
	KIRKVERO_B_PUOL VALTLAPS_PUOL VALTVERO_C_PUOL KUNNVERO_C_PUOL SAIRVAKM_C_PUOL KANSELM_C_PUOL KIRKVERO_C_PUOL VARSVEROTYHT_PUOL VEROTYHT_PUOL YLEVERO_PUOL
	NETTOTULO_PUOL VEROJENOSUUS_PUOL LAPSLIS ELATTUKI ASUMLISAYHT OIKELASUM ELASUMTUKI ASUMTULO PERUSOM ASUMTUKI PHTULO PHMAKSUT NETTOTYOTULO MUUSEKALTULO MUUNETTOTULO
	TOIMTUKI EPIDEMKORV VAHKOROT ALIJHYV KOTITVARSVEROT KOTITVEROTYHT KOTITNETTOTULO KAYT_TULO MARGIVERO EFMARGIVERO; 
	SET OUTPUT.&TULOSNIMI_KOKO;
RUN;

/* 7.2 M��ritell��n muuttujille selkokieliset selitteet */

PROC DATASETS LIB=OUTPUT NOPRINT;
	MODIFY &TULOSNIMI_KOKO;
	LABEL 
	KOKO_VUOSI = 'Lains��d�nt�vuosi'
	KOKO_KUUK = 'Lains��d�nt�kuukausi'
	KOKO_PUOLISO = 'Onko puolisoa, (0/1)'
	KOKO_LAPSIA_ALLE3 = 'Alle 3-vuotiaiden lasten lukum��r�'
	KOKO_LAPSIA_3_6 = '3-6-vuotiaiden lasten lukum��r�'
	KOKO_LAPSIA_7_9 = '7-9-vuotiaiden lasten lukum��r�'
	KOKO_LAPSIA_10_15 = '10-15-vuotiaiden lasten lukum��r�'
	KOKO_LAPSIA_16 = '16-vuotiaiden lasten lukum��r�'
	KOKO_LAPSIA_17 = '17-vuotiaiden lasten lukum��r�'
	KOKO_IKA = 'Henkil�n ik�'
	KOKO_IKA_PUOL = 'Puolison ik�'
	KOKO_YAKRYHMA = 'Yleisen asumistuen kuntaryhm�, 1-4'
	KOKO_YALISAKRYHMA = 'Yleisen asumistuen lis�kustannusryhm�, 0-2'
	KOKO_YALAMMRYHMA = 'Yleisen asumistuen l�mmitysryhm�, 1-3'
	KOKO_EAKRYHMA = 'El�kkeensaajan asumistuen kuntaryhm�, 1-4'
	KOKO_EALAMMRYHMA = 'El�kkeensaajan asumistuen l�mmitysryhm�, 1-3'
	KOKO_KELRYHMA = 'Kunnan kalleusluokka, 1/2'
	KOKO_KUNNVERO = 'Kunnallisveroprosentti (999 = keskim. veropros.), %'
	KOKO_KIRKVERO = 'Kirkollisveroprosentti (999 = keskim. veropros.), %'
	KOKO_VALMVUOSI = 'Asunnon valmistumis- tai perusparannusvuosi'
	KOKO_PINTALA = 'Asunnon pinta-ala, (m2)'
	KOKO_OMISTUS = 'Omistusasunto, (0/1)'
	KOKO_OMAKOTI = 'Omakotitalo, (0/1)'
	KOKO_VUOKRA_VASTIKE = 'Vuokra tai yhti�vastike, (e/kk)'
	KOKO_VESI = 'Vesimaksu, (e/kk)'
	KOKO_ASKOROT = 'Asuntolainan korot, (e/kk)'
	KOKO_TILANNE = 'Henkil�n status'
	KOKO_TILANNE_PUOL = 'Puolison status'
	KOKO_KOROTUS = 'Ty�tt�myysturvan korotusosa, (0/1)'
	KOKO_MTURVA = 'Ty�tt�myysturvan muutosturvalis� / ty�llist�misohjelmalis�, (0/1)'
	KOKO_AKTIIVI = 'Ty�tt�myysturvan aktiivimallin leikkuri, (0/1)'
	KOKO_EPIDEMKORVL = 'Lasketaanko mahdollinen epidemiakorvaus, (0/1)' 
	KOKO_PALKKA = 'Ty�tulo, (e/kk)'
	KOKO_ASKEL = 'Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa, (e/kk)'
	KOKO_EDPALKKA = 'P�iv�rahan perusteena oleva palkka, (e/kk)'
	KOKO_TULONHANKKULUT = 'Tulonhankkimiskulut, (e/kk)'
	KOKO_AYMAKSUT = 'Ay-j�senmaksut, (e/kk)'
	KOKO_TYOMATKAKULUT = 'Ty�matkakulut, (e/kk)'
	KOKO_ELAKE = 'Ty�el�ke, (e/kk)'

	KOKO_PALKKA_PUOL = 'Puolison ty�tulo, (e/kk)'
	KOKO_EDPALKKA_PUOL = 'Puolison p�iv�rahan perusteena oleva palkka, (e/kk)'
	KOKO_TULONHANKKULUT_PUOL = 'Puolison tulonhankkimiskulut, (e/kk)'
	KOKO_AYMAKSUT_PUOL = 'Puoliston ay-j�senmaksut, (e/kk)'
	KOKO_TYOMATKAKULUT_PUOL = 'Puolison ty�matkakulut, (e/kk)'
	KOKO_ELAKE_PUOL = 'Puolison ty�el�ke, (e/kk)'

	INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

	TYOTPR = 'Ty�tt�myysp�iv�rahat, (e/kk)'
	TYOTPR_PUOL = 'Puoliso: Ty�tt�myysp�iv�rahat, (e/kk)'
	SAIRPR = 'Sairausvakuutuksen p�iv�rahat tai vanhempainp�iv�rahat, (e/kk)'
	SVHANKVAH = 'Sairausvakuutuksen p�iv�rahojen tai vanhempainp�iv�rahojen laskennassa v�hennetyt tulonhankkimiskulut, (e/v)'
	SAIRPR_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahat tai vanhempainp�iv�rahat, (e/kk)'
	SVHANKVAH_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahojen tai vanhempainp�iv�rahojen laskennassa k�ytetyt tulonhankkimiskulut, (e/v)'
	KOTIHTULOT = 'Kotihoidon tuen perusteena olevat kotitalouden tulot, (e/kk)' 
	KOTIHTU = 'Kotihoidon tuki, (e/kk)'
	KOTIHTU_PUOL = 'Puoliso: Kotihoidon tuki, (e/kk)'
	OPINTUKI_TUKIAIKA = 'Opintotuen laskennassa k�ytetyt tukikuukaudet vuodessa'
	OPINTUKI_TUKIAIKA_PUOL = 'Puoliso: Opintotuen laskennassa k�ytetyt tukikuukaudet vuodessa'
	OPRAHA = 'Opintoraha, (e/kk)'
	OPIR = 'Opintoraha, (e/tukikk)'
	OPRAHA_PUOL = 'Puoliso: Opintoraha, (e/kk)'
	OPIR_PUOL = 'Puoliso: Opintoraha, (e/tukikk)'
	OPLAINA = 'Opintolaina, (e/kk)'
	OPLAI = 'Opintolaina, (e/tukikk)'
	OPLAINA_PUOL = 'Puoliso: Opintolaina, (e/kk)'
	OPLAI_PUOL = 'Puoliso: Opintolaina, (e/tukikk)'
	ASUMLISA = 'Opintotuen asumislis�, (e/kk)'
	ASLIS = 'Opintotuen asumislis�, (e/tukikk)'
	ASUMLISA_PUOL = 'Puoliso: Opintotuen asumislis�, (e/kk)'
	ASLIS_PUOL = 'Puoliso: Opintotuen asumislis�, (e/tukikk)'
	KANSEL = 'Kansanel�ke, (e/kk)'
	KANSEL_PUOL = 'Puoliso: Kansanel�ke, (e/kk)'
	TAKUUEL = 'Takuuel�ke, (e/kk)'
	TAKUUEL_PUOL = 'Puoliso: Takuuel�ke, (e/kk)'
	ELAKYHT = 'Ty�-, kansan-, takuu- ja leskenel�ke yhteens�, (e/kk)'
	ELAKYHT_PUOL = 'Puoliso: Ty�-, kansan-, takuu- ja leskenel�ke yhteens�, (e/kk)'
	LAPSIKORO = 'El�kkeensaajan lapsikorotukset, (e/kk)'
	LAPSIKORO_PUOL = 'Puoliso: El�kkeensaajan lapsikorotukset, (e/kk)'

	LAPSENELAK = 'Lapsenel�ke, (e/kk)'
	LESKENELAK = 'Leskenel�ke, (e/kk)'
	LESKENELAK_PUOL = 'Puoliso: Leskenel�ke, (e/kk)'
	TYOEL = 'Palkansaajan ty�el�kemaksu, (e/v)'
	TYOEL_PUOL = 'Puoliso: Palkansaajan ty�el�kemaksu, (e/v)'
	TYOTMAKSU = 'Palkansaajan ty�tt�myysvakuutusmaksu, (e/v)'
	TYOTMAKSU_PUOL = 'Puoliso: Palkansaajan ty�tt�myysvakuutusmaksu, (e/v)'
	SVPRMAKSU = 'Sairausvakuutuksen p�iv�rahamaksu, (e/v)'
	SVPRMAKSU_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahamaksu, (e/v)'
	PALKVAK = 'Palkansaajan el�ke-, ty�tt�myysvakuutusmaksu ja sairausvakuutuksen p�iv�rahamaksu yhteens�, (e/v)'
	PALKVAK_PUOL = 'Puoliso: Palkansaajan el�ke-, ty�tt�myysvakuutusmaksu ja sairausvakuutuksen p�iv�rahamaksu yhteens�, (e/v)'
	HANKVAH = 'Tulonhankkimisv�hennys, (e/v)'
	HANKVAH_PUOL = 'Puoliso: Tulonhankkimisv�hennys, (e/v)'
	ANSIOTULO = 'Ansiotulot yhteens�, (e/v)'
	ANSIOTULO_PUOL = 'Puoliso: Ansiotulot yhteens�, (e/v)'
	PUHDANSIOTULO = 'Puhdas ansiotulo, (e/v)'
	PUHDANSIOTULO_PUOL = 'Puoliso: Puhdas ansiotulo, (e/v)'
	ANS = 'Ansiotulov�hennys (2023-), (e/v)'
	ANS_PUOL = 'Puoliso: Ansiotulov�hennys(2023-), (e/v)'
	KUNNANS = 'Kunnallisverotuksen ansiotulov�hennys , (e/v)'
	KUNNANS_PUOL = 'Puoliso: Kunnallisverotuksen ansiotulov�hennys, (e/v)'
	OPRAHVAH = 'Opintorahav�hennys, (e/v)'
	OPRAHVAH_PUOL = 'Puoliso: Opintorahav�hennys, (e/v)'
	ELVAH = 'El�ketulov�hennys(2023-), (e/v)'
	ELVAH_PUOL = 'Puoliso: El�ketulov�hennys(2023-), (e/v)'
	KUNNELVAH = 'Kunnallisverotuksen el�ketulov�hennys, (e/v)'
	KUNNELVAH_PUOL = 'Puoliso: Kunnallisverotuksen el�ketulov�hennys, (e/v)'
	VERTULO1 = 'Verotettava tulo ennen perusv�hennyst�(2023-), (e/v)'
	VERTULO1_PUOL = 'Puoliso: Verotettava tulo ennen perusv�hennyst�(2023-), (e/v)'
	KUNNVERTULO1 = 'Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst�, (e/v)'
	KUNNVERTULO1_PUOL = 'Puoliso: Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst�, (e/v)'
	PER = 'Perusv�hennys(2023-), (e/v)'
	PER_PUOL = 'Puoliso: Perusv�hennys(2023-), (e/v)'
	KUNNPER = 'Kunnallisverotuksen perusv�hennys, (e/v)'
	KUNNPER_PUOL = 'Puoliso: Kunnallisverotuksen perusv�hennys, (e/v)'
	VERTULO2 = 'Verotettava tulo(2023-), (e/v)'
	VERTULO2_PUOL = 'Puoliso: Verotettava tulo(2023-), (e/v)'
	KUNNVERTULO2 = 'Kunnallisverotuksessa verotettava tulo, (e/v)'
	KUNNVERTULO2_PUOL = 'Puoliso: Kunnallisverotuksessa verotettava tulo, (e/v)'
	KUNNVERO = 'Kunnallisvero ennen verosta teht�vi� v�hennyksi�, (e/v)'
	KUNNVERO_PUOL = 'Puoliso: Kunnallisvero ennen verosta teht�vi� v�hennyksi�, (e/v)' 
	KUNNVERO_B = 'Kunnallisvero ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	KUNNVERO_B_PUOL = 'Puoliso: Kunnallisvero ansio/ty�tulov�hennyksen j�lkeen, (e/v)' 
	KUNNVERO_C = 'Kunnallisvero lapsiv�hennyksen j�lkeen, (e/v)'
	KUNNVERO_C_PUOL = 'Puoliso: Kunnallisvero lapsiv�hennyksen j�lkeen, (e/v)' 
	KIRKVERO = 'Kirkollisvero ennen verosta teht�vi� v�hennyksi�, (e/v)'
	KIRKVERO_PUOL = 'Puoliso: Kirkollisvero ennen verosta teht�vi� v�hennyksi�, (e/v)'
	KIRKVERO_B = 'Kirkollisvero ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	KIRKVERO_B_PUOL = 'Puoliso: Kirkollisvero ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	KIRKVERO_C = 'Kirkollisvero lapsiv�hennyksen j�lkeen, (e/v)'
	KIRKVERO_C_PUOL = 'Puoliso: Kirkollisvero lapsiv�hennyksen j�lkeen, (e/v)'
	SAIRVAKM = 'Sairaanhoitomaksu/sairausvakuutusmaksu ennen verosta teht�vi� v�hennyksi�, (e/v)'
	SAIRVAKM_PUOL = 'Puoliso: Sairaanhoitomaksu/sairausvakuutusmaksu ennen verosta teht�vi� v�hennyksi�, (e/v)'
	SAIRVAKM_B = 'Sairaanhoitomaksu/sairausvakuutusmaksu ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	SAIRVAKM_B_PUOL = 'Puoliso: Sairaanhoitomaksu/sairausvakuutusmaksu ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	SAIRVAKM_C = 'Sairaanhoitomaksu/sairausvakuutusmaksu lapsiv�hennyksen j�lkeen, (e/v)'
	SAIRVAKM_C_PUOL = 'Puoliso: Sairaanhoitomaksu/sairausvakuutusmaksu lapsiv�hennyksen j�lkeen, (e/v)'
	KANSELM = 'Kansanel�kevakuutusmaksu ennen verosta teht�vi� v�hennyksi�, (e/v)'
	KANSELM_PUOL = 'Puoliso: Kansanel�kevakuutusmaksu ennen verosta teht�vi� v�hennyksi�, (e/v)'
	KANSELM_B = 'Kansanel�kevakuutusmaksu ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	KANSELM_B_PUOL = 'Puoliso: Kansanel�kevakuutusmaksu ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	KANSELM_C = 'Kansanel�kevakuutusmaksu lapsiv�hennyksen j�lkeen, (e/v)'
	KANSELM_C_PUOL = 'Puoliso: Kansanel�kevakuutusmaksu lapsiv�hennyksen j�lkeen, (e/v)'
	VALTELVAH = 'Valtionverotuksen el�ketulov�hennys , (e/v)'
	VALTELVAH_PUOL = 'Puoliso: Valtionverotuksen el�ketulov�hennys , (e/v)'
	VALTVERTULO = 'Valtionverotuksessa verotettava tulo , (e/v)'
	VALTVERTULO_PUOL = 'Puoliso: Valtionverotuksessa verotettava tulo , (e/v)'
	VALTVERO = 'Valtion tulovero ennen verosta teht�vi� v�hennyksi�, (e/v)'
	VALTVERO_PUOL = 'Puoliso: Valtion tulovero ennen verosta teht�vi� v�hennyksi�, (e/v)'
	VALTVERO_B = 'Valtion tulovero ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	VALTVERO_B_PUOL = 'Puoliso: Valtion tulovero ansio/ty�tulov�hennyksen j�lkeen, (e/v)'
	VALTVERO_C = 'Valtion tulovero lapsiv�hennyksen j�lkeen, (e/v)'
	VALTVERO_C_PUOL = 'Puoliso: Valtion tulovero lapsiv�hennyksen j�lkeen, (e/v)'
	VALTANS = 'Ansiotulov�hennys/ty�tulov�hennys valtionverosta, (e/v)'
	VALTANS_PUOL = 'Puoliso: Ansiotulov�hennys/ty�tulov�hennys valtionverosta, (e/v)'
	VARSVEROTYHT = 'Verot yhteens� lapsiv�hennyksen j�lkeen, (e/v)'
	VARSVEROTYHT_PUOL = 'Puoliso: Verot yhteens� lapsiv�hennyksen j�lkeen, (e/v)'
	VALTLAPS = 'Lapsiv�hennys, (e/v)'
	VALTLAPS_PUOL = 'Puoliso: Lapsiv�hennys, (e/v)'
	YLEVERO = 'YLE-vero, (e/v)'
	YLEVERO_PUOL = 'Puoliso: YLE-vero, (e/v)'
	VEROTYHT = 'Verot ja veroluontoiset maksut yhteens� lapsiv�hennyksen j�lkeen, (e/v)'
	VEROTYHT_PUOL = 'Puoliso: Verot ja veroluontoiset maksut yhteens� lapsiv�hennyksen j�lkeen, (e/v)'
	NETTOTULO = 'Nettotulo lapsiv�hennyksen j�lkeen, (e/kk)'
	NETTOTULO_PUOL = 'Puoliso: Nettotulo lapsiv�hennyksen j�lkeen, (e/kk)'
	VEROJENOSUUS = 'Verojen ja veroluontoisten maksujen osuus tuloista lapsiv�hennyksen j�lkeen, (%)'
	VEROJENOSUUS_PUOL = 'Puoliso: Verojen ja veroluontoisten maksujen osuus tuloista lapsiv�hennyksen j�lkeen, (%)'

	LAPSLIS = 'Kotitalous: Lapsilis�t, (e/kk)'
	KOKO_LAPSIAYHT = 'Lasten (alle 18-v.) lukum��r� kotitaloudessa'
	ELATTUKI = 'Kotitalous: Elatustuki, (e/kk)'
	VAHKOROT = 'Kotitalous: V�hennyskelpoiset korot, (e/v)'
	ALIJHYV = 'Kotitalous: Alij��m�hyvitys, (e/v)'
	KOTITVARSVEROT = 'Kotitalous: Verot yhteens� alij��m�hyvityksen j�lkeen, (e/v)'
	KOTITVEROTYHT = 'Kotitalous: Verot ja veroluontoiset maksut yhteens� alij��m�hyvityksen j�lkeen, (e/v)'
	KOTITNETTOTULO = 'Kotitalous: Nettotulo alij��m�hyvityksen j�lkeen, (e/kk)'
	ASUMLISAYHT = 'Kotitalous: Opintotuen asumislis�, (e/kk)'
	OIKELASUM = 'Kotitalous: Oikeus el�kkeensaajien asumistukeen, (0/1)' 
	ELASUMTUKI = 'Kotitalous: El�kkeensaajien asumistuki, (e/kk)'
	ASUMTULO = 'Kotitalous: Yleisen asumistuen perusomavastuun laskemista varten muodostettu tulo (ennen vuotta 2015), (e/kk)'
	PERUSOM = 'Kotitalous: Yleisen asumistuen perusomavastuu (ennen vuotta 2015), (e/kk)'
	ASUMTUKI = 'Kotitalous: Yleinen asumistuki, (e/kk)'
	PHTULO = 'Kotitalous: P�iv�hoitomaksujen perusteena oleva tulo, (e/kk)'
	PHMAKSUT = 'Kotitalous: P�iv�hoitomaksut, (e/kk)'
	NETTOTYOTULO = 'Kotitalous: Nettoty�tulo toimeentulotuessa, (e/kk)'
	MUUNETTOTULO = 'Kotitalous: Muu nettotulo toimeentulotuessa, (e/kk)'
	MUUSEKALTULO = 'Kotitalous: Muut verottomat tulot toimeentulotuessa, (e/kk)'
	TOIMTUKI = 'Kotitalous: Toimeentulotuki, (e/kk)'
	EPIDEMKORV = 'Kotitalous: Epidemiakorvaus, (e/kk)'
	KAYT_TULO = 'Kotitalous: K�ytett�viss� oleva tulo, (e/kk)'

	MARGIVERO = 'Marginaaliveroaste, (%)'
	EFMARGIVERO = 'Kotitalous: Efektiivinen marginaaliveroaste, (%)'

	;
	%IF &EROTIN = 1 %THEN %DO;
		FORMAT _NUMERIC_ 1&DESIMAALIT..&DESIMAALIT;
		FORMAT INF MARGIVERO EFMARGIVERO VEROJENOSUUS 10.5;
	%END;

	%IF &EROTIN = 2 %THEN %DO;
		FORMAT _NUMERIC_ NUMx1&DESIMAALIT..&DESIMAALIT;
		FORMAT INF MARGIVERO EFMARGIVERO VEROJENOSUUS NUMx10.5;
	%END;

	/* Kokonaislukuina ne muuttujat, joissa ei haluta k�ytt�� desimaalierotinta */

	FORMAT KOKO_VUOSI KOKO_KUUK KOKO_PUOLISO KOKO_LAPSIA_ALLE3 KOKO_LAPSIA_3_6 KOKO_LAPSIA_7_9 KOKO_LAPSIA_10_15 
	KOKO_LAPSIA_16 KOKO_LAPSIA_17 KOKO_IKA KOKO_IKA_PUOL KOKO_YAKRYHMA KOKO_YALISAKRYHMA KOKO_YALAMMRYHMA
	KOKO_EAKRYHMA KOKO_EALAMMRYHMA KOKO_KELRYHMA KOKO_VALMVUOSI KOKO_OMISTUS KOKO_OMAKOTI KOKO_TILANNE
	KOKO_TILANNE_PUOL KOKO_KOROTUS KOKO_MTURVA KOKO_AKTIIVI KOKO_EPIDEMKORVL KOKO_LAPSIAYHT OIKELASUM OPINTUKI_TUKIAIKA OPINTUKI_TUKIAIKA_PUOL 8.;

RUN;
QUIT;

/* Jos puolisoa ei ole m��ritelty, poistetaan laskennassa kutsumalla luodut puolison muuttujat */
%IF &MINIMI_KOKO_PUOLISO = 0 %THEN %DO;
	%PUT Ei m��ritelty puolisoa, joten poistetaan laskennassa kutsutut puolison sarakkeet.;
	/* Haetaan sarakkeiden nimet */
	PROC CONTENTS DATA=OUTPUT.&TULOSNIMI_KOKO OUT=TEMP.KOKO_ESIM_SARAK(KEEP=NAME) NOPRINT;
	RUN;

	/* Haetaan lista sarakkeista, jotka p��ttyv�t _PUOL */
	PROC SQL NOPRINT;
	SELECT NAME INTO :PUDOTUS SEPARATED BY ' '
	FROM TEMP.KOKO_ESIM_SARAK
	WHERE UPCASE(NAME) LIKE '%^_PUOL' ESCAPE '^';
	QUIT;

	/* Poistetaan tulostiedostosta kaikki sarakkeet, jotka p��ttyv�t _PUOL */
	DATA OUTPUT.&TULOSNIMI_KOKO;
	SET OUTPUT.&TULOSNIMI_KOKO;
	DROP &PUDOTUS;
	RUN;
%END;


/* Valitaan tulostettavat muuttujat */
DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;
KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP KOKO_KUUK;
%END;

RUN;


* Tulosten printtaus ja vienti exceliin riippuen valinnasta; 
%EsimTulokset(&TULOSNIMI_KOKO, KOKO);

%MEND Koko_Tulokset;

/* 8. Suoritetaan kaikki vaiheet yhden p��makron sis�ll�. */

%MACRO Koko_Simuloi_Esim;

/* M��ritell��n osamallien lains��d�nn�n parametrit lokaaleiksi makromuuttujiksi */

/* Muuttujat, joihin haetaan lista mallin k�ytt�mist� lakiparametreist� */
%LOCAL SAIRVAK_PARAM SAIRVAK_MUUNNOS;

/* Haetaan SAIRVAK-mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(SAIRVAK_PARAM, SAIRVAK);
%HaeLaskettavatLokaalit(SAIRVAK_MUUNNOS, SAIRVAK);

%LOCAL &SAIRVAK_PARAM;

/* TTURVA-mallin parametrit */

%LOCAL TTURVA_PARAM TTURVA_MUUNNOS;

%HaeLokaalit(TTURVA_PARAM, TTURVA);
%HaeLaskettavatLokaalit(TTURVA_MUUNNOS, TTURVA);

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TTURVA_PARAM;

/* KANSEL-mallin parametrit */

%LOCAL KANSEL_PARAM KANSEL_MUUNNOS;

%HaeLokaalit(KANSEL_PARAM, KANSEL);
%HaeLaskettavatLokaalit(KANSEL_MUUNNOS, KANSEL);

%LOCAL &KANSEL_PARAM;

/* KOTIHTUKI-mallin parametrit */
%LOCAL KOTIHTUKI_PARAM KOTIHTUKI_MUUNNOS;

%HaeLokaalit(KOTIHTUKI_PARAM, KOTIHTUKI);
%HaeLaskettavatLokaalit(KOTIHTUKI_MUUNNOS, KOTIHTUKI);

%LOCAL &KOTIHTUKI_PARAM;

/* PHOITO-mallin parametrit*/
%LOCAL PHOITO_PARAM PHOITO_MUUNNOS;

%HaeLokaalit(PHOITO_PARAM, PHOITO);
%HaeLaskettavatLokaalit(PHOITO_MUUNNOS, PHOITO);

%LOCAL &PHOITO_PARAM;

/* OPINTUKI-mallin parametrit */

%LOCAL OPINTUKI_PARAM OPINTUKI_MUUNNOS;

%HaeLokaalit(OPINTUKI_PARAM, OPINTUKI);
%HaeLaskettavatLokaalit(OPINTUKI_MUUNNOS, OPINTUKI);

%LOCAL &OPINTUKI_PARAM;

/* VERO-mallin parametrit */

%LOCAL VERO_PARAM VERO_MUUNNOS VERO2_PARAM VERO2_MUUNNOS VERO_JOHDETUT;

/* Haetaan mallin k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(VERO_PARAM, VERO);
%HaeLaskettavatLokaalit(VERO_MUUNNOS, VERO);

/* Haetaan johdettavien muuttujien nimet */
%HaeLaskettavatLokaalit(VERO_JOHDETUT, VERO, indikaattori='j');

/* Varallisuusveroon liittyv�t parametrit (VERO-malli) */

/* Haetaan varallisuusveron k�ytt�mien lakiparametrien nimet */
%HaeLokaalit(VERO2_PARAM, VERO_VARALL);
%HaeLaskettavatLokaalit(VERO2_MUUNNOS, VERO_VARALL, indikaattori='z');

/* Luodaan tyhj�t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &VERO_PARAM &VERO2_PARAM &VERO_JOHDETUT;

/* KIVERO-mallin parametrit */
%LOCAL KIVERO_PARAM KIVERO_MUUNNOS;

%HaeLokaalit(KIVERO_PARAM, KIVERO);
%HaeLaskettavatLokaalit(KIVERO_MUUNNOS, KIVERO);

%LOCAL &KIVERO_PARAM;

/* LLISA-mallin parametrit */
%LOCAL LLISA_PARAM LLISA_MUUNNOS;
%HaeLokaalit(LLISA_PARAM, LLISA);
%HaeLaskettavatLokaalit(LLISA_MUUNNOS, LLISA);

%LOCAL &LLISA_PARAM;

/* ELASUMTUKI-malli parametrit */
%LOCAL ELASUMTUKI_PARAM ELASUMTUKI_MUUNNOS;

%HaeLokaalit(ELASUMTUKI_PARAM, ELASUMTUKI);
%HaeLaskettavatLokaalit(ELASUMTUKI_MUUNNOS, ELASUMTUKI);

%LOCAL &ELASUMTUKI_PARAM;

/* ASUMTUKI-mallin parametrit */
%LOCAL ASUMTUKI_PARAM ASUMTUKI_MUUNNOS;

%HaeLokaalit(ASUMTUKI_PARAM, ASUMTUKI);
%HaeLaskettavatLokaalit(ASUMTUKI_MUUNNOS, ASUMTUKI);

%LOCAL &ASUMTUKI_PARAM;

/* TOIMTUKI-mallin parametrit */
%LOCAL TOIMTUKI_PARAM TOIMTUKI_MUUNNOS;

%HaeLokaalit(TOIMTUKI_PARAM, TOIMTUKI);
%HaeLaskettavatLokaalit(TOIMTUKI_MUUNNOS, TOIMTUKI);

%LOCAL &TOIMTUKI_PARAM;

/* Epidemiaetuuksien parametrit */
%LOCAL EPIDEM_PARAM EPIDEM_MUUNNOS;

%HaeLokaalit(EPIDEM_PARAM, EPIDEM);
%HaeLaskettavatLokaalit(EPIDEM_MUUNNOS, EPIDEM);

%LOCAL &EPIDEM_PARAM; 

/* Yksil�tason laskenta */
%KOKO_LASKENTA(0);
%KOKO_LASKENTA(1);

/* Haetaan vuokranormiparametrit 2011 tasolla, jotta er��t taulukot syntyv�t
(ongelma, mik�li asumistukia ei ole ajettu mallilla aiemmin */
%HaeParam_VuokraNormit(2011);

/* Kotitaloustason laskenta */
%KOKO_LASKENTA_KOTIT;

/* Lasketaan marginaaliveroasteet */
%Koko_Simuloi_MargVero;

/* Tulostetaan tulokset */
%Koko_Tulokset;

%MEND Koko_Simuloi_Esim;

%Koko_Simuloi_Esim;
