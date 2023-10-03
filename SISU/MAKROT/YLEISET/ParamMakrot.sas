/*******************************************************************
*  Kuvaus: Parametrien hakumakrot								   *
*          Apumakroja parametrien hakuun ja yll‰pitoon.            * 
*  Viimeksi p‰ivitetty: 23.5.2018		   					       * 
*******************************************************************/

/* SISƒLLYS 
0. Parametrien haun toimintaperiaate
1. Quick Start
2. Parametrien hakumakrot
2.1 HaeParamSimul
2.2 HaeParamEsim
2.3 HaeParamSimulx
3. Parametrien muunnosmakrot
3.1 ParamInfSimul
3.2 ParamInfEsim
3.3 ParamInfSimulx
4. Parametrien nimien hakumakrot
4.1 HaeLokaalit
4.2 HaeLaskettavatLokaalit
5. KuukSimul
6. Yleisen asumistuen parametrien hakumakrot vuosittaisia tauluja varten
6.1 HaeParam_VuokraNormit
6.2 HaeParam_EnimmVuokra
7. VERO-mallin HAKU-makrot, joilla parametrit haetaan vain esimerkkilaskelmissa
7.1 HAKU
7.2 HAKUVV
*/

/* 0. Parametrien haun toimintaperiaate */

/*
Parametrien hakumakrot ovat yleismakroja, jotka toimivat kaikissa osamalleissa.

OSAMALLEISSA ja ESIMERKKILASKELMISSA
- Osamalleissa ja esimerkkilaskelmissa haetaan Kaikki_param-taulukosta lista mallin k‰ytt‰mist‰
  parametreist‰. (Poiminta- ja Simuloi_Data-vaiheet)
- Listan avulla luodaan tyhj‰ lokaali makromuuttuja jokaiselle mallin k‰ytt‰m‰lle lakiparametrille.
- Haetaan myˆs lista lakiparametreist‰, joille tehd‰‰n muunnos (INF tai valuutta-muunnos) parametrien haun j‰lkeen

LAKIMAKROISSA
- Osamalleissa luotujen listojen perusteella:
	1. Haetaaan parametrit (%HaeParam&TYYPPI-makroilla)
       K‰ytett‰v‰ makro vaihtuu simuloinnin tyypin mukaan: %HaeParamEsim, %HaeParamSimul tai %HaeParamSimulx
	2. Kerrotaan parametrit tarvittaessa INF tai tehd‰‰n valuuttamuunnos (%ParamInf&TYYPPI-makroilla)

LOGIIKKA
Hakumakrojen nimet ovat seuraavat:
- HaeParamSimul
- HaeParamSimulx (Tyhj‰ makro. Ajetaan jos TYYPPI = SIMULX)
- HaeParamEsim (Esimerkkilaskentojen makro, toimii data-askeleessa)
Ja muunnoksen tekev‰t makrot on nimetty:
- ParamInfSimul
- ParamInfSimulx (Tyhj‰ makro)
- ParamInfEsim (Esimerkkilaskentojen makro, toimii data-askeleessa)

Lakimakroissa makroja voidaan kutsua komennolla %HaeParam&TYYPPI
- Jos TYYPPI=SIMULX haetaan parametrit osamalleissa %HaeParamSimul-makrolla.
  T‰m‰n j‰lkeen lakimakroissa kutsutaan tyhj‰‰ makroa HaeParamSimulx,
  joka ei kirjoita parametrien p‰‰lle uusia arvoja.
*/

/* 1. QUICK START */

/*
TOIMINNALLISUUS:

Lakimarkoissa haetaan parametrit. Esimerkiksi lapsilis‰mallissa on jokaisessa lakimakrossa kaksi rivi‰:
%HaeParam&TYYPPI(&mvuosi, &mkuuk, &LLISA_PARAM, PARAM.&PLLISA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &LLISA_MUUNNOS, &minf);

MUIDEN KUIN MƒƒRITELTYJEN LAKIPARAMETRIEN HAKEMINEN:

1) M‰‰ritell‰‰n mit‰ haluataan hakea ja mille halutaan laskea muunnokset.
   Voidaan listata haettavat parametrit makromuuttujaan:

%LET Haettavat_param = Param1 Param2 Param3 Jne;
%LET Laskettavat_param = Param1 Param2;

2) Luodaan tyhj‰t lokaalit makromuuttujat..

%LOCAL &Haettavat_param;

3a) Haetaan lakiparametrit taulukostaja ja tehd‰‰n muunnokset

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &Haettavat_param, <Parametritaulun osoite>);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &Laskettavat_param, &INF);

3b) Jos haettavien parametrien lukum‰‰r‰ on pieni, voidaan 

%LOCAL Param1 Param2 Param3 Jne;
%HaeParam&TYYPPI(&mvuosi, &mkuuk, Param1 Param2 Param3 Jne, <Parametritaulun osoite>);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, Param1 Param2, &INF);

*/

/* ######## 2. Parametrien hakumakrot ######## */

/* ######### 2.1 HaeParamSimul  #########

Hakee parametrit parametritauluista, joissa on vuosi-muuttuja tai vuosi- ja kuukausi-muuttujat (vuosi ja kuuk)

Sis‰‰n syˆtett‰v‰t tiedot (Kaikki syˆtett‰v‰ j‰rjestyksess‰)
	-mvuosi
	-mkuuk
	-ptaulu
	-mlista

Toimintaperiaate:
1) Lasketaan juokseva kuukausinumero
2) Avataan taulu
3) Tarkastetaan lˆytyykˆ taulusta KUUK-muuttuja.
4) Haetaan havainnot. Haetaan vuosi.
5) Jos taulussa on kuuk:
	-haetaan kuuk -> muodostetaan juokseva aika MDY(<kuuk>,1,<vuosi>)
   Jos ei ole kuuk:
	- ei haeta kuuk. Muodostetaan juokseva aika MDY(1,1,<vuosi>)
6) Etsit‰‰n rivi, joka t‰ytt‰‰ ehdon: vuosi&kuukausi >= taulusta vuosi&kuukausi
7) Muodostetaan k=1 juokseva ja valitaan mlista-muuttujan ensimm‰inen sana %SCAN(&mlista,&k) tai %SCAN(&mlista,1)
8) Loopataan mlista:n l‰pi: Haetaan arvot sek‰ jaetaan valuutalla ja kerrotaan INF.
9) Suljetaan taulu
10) Testausta varten %PUT _LOCAL_; -komento tulostaa lokiin lokaalien makromuuttujien arvot
*/

%MACRO HaeParamSimul(mvuosi, mkuuk, mlista, ptaulu)/
DES = 'ParamMakrot: Makro, joka hakee parametrit aineistosimuloinnissa';
%LOCAL k;

/* 1) Haetaan juokseva j‰rjestysnumero kuukausi-vuosi. K‰ytet‰‰n SAS:n aikaa. */
%LET kuuknro = %SYSFUNC(MDY(&mkuuk,1,&mvuosi));

/* 2) Avataan taulu */
%LET taulu_ll = %SYSFUNC(OPEN(&PTAULU, i));

/* 3) Tarkastetaan lˆytyykˆ KUUK-muuttujaa taulusta. Jos kkuuk=0, niin ei lˆydy. */
%LET kkuuk = %SYSFUNC(VARNUM(&taulu_ll, kuuk));

/* 4) haetaan havainnot. haetaan vuosi */
%LET w = %SYSFUNC(REWIND(&taulu_ll));
%LET w = %SYSFUNC(FETCHOBS(&taulu_ll, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_ll, 1)); /* Vuosi */

/* 5) Jos taulussa on kuuk-sarake, haetaan vuosi-kuukausi-yhdistelm‰n mukaan.
Muissa tapauksissa k‰ytet‰‰n hakemiseen vuotta */
%IF &KKUUK NE 0 %THEN %DO;
	%LET z = %SYSFUNC(GETVARN(&taulu_ll, 2)); /* Kuukausi */
	%LET testi = %SYSFUNC(MDY(&z, 1, &y));
%END;
%ELSE %DO;
	%LET testi = %SYSFUNC(MDY(1, 1, &y));
%END;

/* 6) Kelataan taulua rivi rivilt‰ kunnes  ehto (vuosi ja kuukausi taulusta) <= (vuosi ja kuukausi) t‰yttyy
Jos taulussa ei ole kuuk-saraketta, ei haeta kuuk-saraketta. */
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&w = -1));
	%LET w = %SYSFUNC(FETCH(&taulu_ll));
	%LET y = %SYSFUNC(GETVARN(&taulu_ll, 1));
	%IF &KKUUK NE 0 %THEN %DO;
		%LET z = %SYSFUNC(GETVARN(&taulu_ll, 2)); /* Kuukausi */
		%LET testi = %SYSFUNC(MDY(&z, 1, &y));
	%END;
	%ELSE %DO;
		%LET testi = %SYSFUNC(MDY(1, 1, &y));
	%END;
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_ll, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_ll, &riveja));
%END;

/* 7) Asetetaan juokseva indikaattori */
%LET k = 1;

/* Valitaan 1. v‰lill‰ erotettu sana */
%LET msarake = %SCAN(&mlista, 1);

/* 8) Loopataan kunnes tyhj‰. Muodostetaan jokaiselle valitulle muuttujalle */
%DO %WHILE ("&msarake" NE "");
	/* Muuttuja = Muuttujan nimisen sarakkeen ensimm‰inen arvo */
	%LET &msarake = %SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, &msarake))));
	%IF &&&msarake EQ . OR &&&msarake EQ '' %THEN %DO;
		%PUT WARNING: MUUTTUJAN &&msarake ARVO TAULUSSA &ptaulu ON TYHJƒ!;
	%END;
	%LET k = %EVAL(&k+1);
	%LET msarake = %SCAN(&mlista, &k);
%END;

/* 9) Suljetaan taulu */
%LET loppu = %SYSFUNC(CLOSE(&taulu_ll));

/* 10) Tarkastusosion voi sijoittaa t‰h‰n.*/

%MEND HaeParamSimul;

/* ######### 2.2 HaeParamEsim #########

Hakee parametrit parametritauluista, joissa on vuosi-muuttuja tai vuosi- ja kuukausi-muuttujat (vuosi ja kuuk)

Sis‰‰n syˆtett‰v‰t tiedot (Kaikki syˆtett‰v‰ j‰rjestyksess‰)
	-mvuosi
	-mkuuk
	-ptaulu
	-mlista

Toimintaperiaate on sama kuin HaeParamSimul, mutta HaeParamEsim-makro toimii osana data-askelta esimerkkilaskelmissa.
Makroon sis‰‰n tuleva mvuosi on sarakkeen muodossa esimerkkilaskelmissa.
0) Annataan parametritaulukohtainen nimi avattavalle taululle, jotta useita tauluja avatessa ei tule ristiriitoja.
1) Lasketaan juokseva kuukausinumero
2) Avataan taulu
3) Tarkastetaan lˆytyykˆ taulusta KUUK-muuttuja.
4) Haetaan havainnot. Haetaan vuosi.
5) Jos taulussa on kuuk:
	-haetaan kuuk -> muodostetaan juokseva aika MDY(<kuuk>,1,<vuosi>)
   Jos ei ole kuuk:
	- ei haeta kuuk. Muodostetaan juokseva aika MDY(1,1,<vuosi>)
6) Etsit‰‰n rivi, joka t‰ytt‰‰ ehdon: vuosi&kuukausi >= taulusta vuosi&kuukausi
7) Muodostetaan k=1 juokseva ja valitaan mlista-muuttujan ensimm‰inen sana %SCAN(&mlista,&k) tai %SCAN(&mlista,1)
8) Loopataan mlista:n l‰pi: Haetaan arvot sek‰ jaetaan valuutalla ja kerrotaan INF.
9) Testausta varten %PUT _LOCAL_; -komento tulostaa lokiin lokaalien makromuuttujien arvot

HUOM! Jos haet parametritaulun work-kirjastosta, anna ptaulu-syˆte muodossa WORK.PARAMETRITAULU makrokutsussa.
*/

%MACRO HaeParamEsim(mvuosi, mkuuk, mlista, ptaulu)/
DES = 'ParamMakrot: Makro, joka hakee parametrit esimerkkilaskelmissa';

%LOCAL taulun_apu;
/* 0) Avattavalla taululle nimi: Kun esimerkkilaskelmissa avataan useita taulua, ei pit‰isi tulla ongelmia*/
%LET taulun_apu = %SCAN(&ptaulu,2,'.');
%LET taulun_apu = taulu_&taulun_apu;

/* 1) Haetaan juokseva j‰rjestysnumero kuukausi-vuosi. K‰ytet‰‰n SAS:n aikaa. */
kuuknro = MDY(&mkuuk,1,&mvuosi);
/* 2) Jos taulu ei ole auki, avataan se */
IF _N_ = 1 OR &taulun_apu =. THEN &taulun_apu = OPEN("&ptaulu", "i");
RETAIN &taulun_apu;
/* 3) Tarkastetaan lˆytyykˆ taulusta KUUK-muuttuja. */
kkuuk = VARNUM(&taulun_apu, "kuuk");

/* 4) Haetaan havainnot. Haetaan vuosi. */
w = REWIND(&taulun_apu);
w = FETCHOBS(&taulun_apu, 1);
y = GETVARN(&taulun_apu, 1);

/* 5) Jos taulussa on kuuk-sarake, haetaan vuosi-kuukausi-yhdistelm‰n mukaan.
Muissa tapauksissa k‰ytet‰‰n hakemiseen vuotta */
IF KKUUK NE 0 THEN DO;
	z = GETVARN(&taulun_apu, 2);
	testi = MDY(z,1,y);
END;
ELSE DO;
	testi = MDY(1,1,y);
END;

/* 6) Kelataan taulua rivi rivilt‰ kunnes  ehto (vuosi ja kuukausi taulusta) <= (vuosi ja kuukausi) t‰yttyy
Jos taulussa ei ole kuuk-saraketta, ei haeta kuuk-saraketta. */
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
		w = FETCH(&taulun_apu);
		y = GETVARN(&taulun_apu, 1);
		IF KKUUK NE 0 THEN DO;
			z = GETVARN(&taulun_apu, 2);
			testi = MDY(z,1,y);
		END;
		ELSE DO;
			testi = MDY(1,1,y);
		END;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(&taulun_apu, "NLOBS");
	w = FETCHOBS(&taulun_apu, &riveja);
END;

/* 7) Loopataan nimien yli ja haetaan */
%LET k = 1;

/* Valitaan 1. v‰lill‰ erotettu sana */
%LET msarake = %SCAN(&mlista, 1);

/* 8) Loopataan kunnes tyhj‰. Muodostetaan jokaiselle valitulle muuttujalle */
%DO %WHILE ("&msarake" NE "");
	/* Muuttuja = Muuttujan nimisen sarakkeen ensimm‰inen arvo */
	%LET &msarake = GETVARN(&taulun_apu, VARNUM(&taulun_apu, "&msarake"));
	%LET k = %EVAL(&k+1);
	%LET msarake = %SCAN(&mlista, &k);
%END;

/* 9) Tarkastusosion voi sijoittaa t‰h‰n. */

DROP &taulun_apu kuuknro kkuuk w y z testi;

%MEND HaeParamEsim;

/*
######### 2.3 HaeParamSimulx #########

Tyhj‰ makro, joka ajetaan valinnalla TYYPPI = SIMULX.
Osamalleissa haetaan vuodelle ja kuukaudella parametrit HaeParamSimul-makrolla, kun TYYPPI = SIMULX.
T‰m‰n j‰lkeen lakimakroissa kutsutaan tyhj‰‰ HaeParamSimulx.
Parametrien arvot pysyv‰t samana eik‰ HaeParamSimulx kirjoita niiden yli.

*/

%MACRO HaeParamSimulx(mvuosi, mkuuk, mlista, ptaulu)/
DES = 'ParamMakrot: Tyhj‰ parametrienhakumakro tilannetta TYYPPI=SIMULX varten';
%MEND HaeParamSimulx;


/*
######### 3. Parametrien muunnosmakrot #########
######### 3.1 ParamInfSimul #########

Makro, jolla lasketaan parametreille valuutta ja INF-muunnokset.

Sis‰‰n:
Positional parameters: Kaikki pit‰‰ syˆtt‰‰ samassa j‰rjestyksess‰.
- mvuosi - vuosi
- mkuuk - kuukausi
- minf - inf
Keyword parameters: Ei tarvitse syˆtt‰‰.
- meuro - euron arvo (Oletus = 5.94573)

Mallin euron arvo on oletuksena meuro = 5.94573. Arvoa voi muttaa antamalla meuro=<arvo>.
*/

%macro ParamInfSimul(mvuosi, mkuuk, mlista, minf, meuro=5.94573)/
DES = 'ParamMakrot: Makro, joka laskee parametrien muunnokset aineistosimuloinnissa';
%local k valuutta;

%LET valuutta = %sysfunc(IFN(&mvuosi < 2002, &meuro,  1));

/* loopataan yli listan */
%let k = 1;

/* Valitaan 1. v‰lill‰ erotettu sana */
%let mmuuttuja = %SCAN(&mlista, 1);

/* Loopataan kunnes tyhj‰. Muodostetaan jokaiselle valitulle muuttujalle */
%DO %WHILE ("&mmuuttuja" NE "");
	/* Lasketaan muunnos */
	%LET &mmuuttuja = (&&&mmuuttuja / &valuutta)*&minf;
	/* Siirryt‰‰n listalla seuraavaan */
	%LET k = %EVAL(&k+1);
	%LET mmuuttuja = %SCAN(&mlista, &k);
%END;

%mend ParamInfSimul;

/* ######### 3.2 ParamInfEsim #########

Makro, jolla lasketaan parametreille valuutta ja INF-muunnokset.

Makro on t‰ysin sama kuin yll‰, mutta yht‰ rivi‰ on muutettu.

Sis‰‰n:
Positional parameters: Kaikki pit‰‰ syˆtt‰‰ samassa j‰rjestyksess‰.
- mvuosi - vuosi
- mkuuk - kuukausi
- minf - inf
Keyword parameters: Ei tarvitse syˆtt‰‰.
- meuro - euron arvo (Oletus = 5.94573)

Mallin euron arvo on oletuksena meuro = 5.94573. Arvoa voi muttaa antamalla meuro=<arvo>.
*/
%MACRO ParamInfEsim(mvuosi, mkuuk, mlista, minf, meuro=5.94573)/
DES = 'ParamMakrot: Makro, joka laskee parametrien muunnokset esimerkkilaskelmissa';
%LOCAL k valuutta;

%LET valuutta = IFN(&mvuosi < 2002, &meuro,  1);

/* loopataan yli listan */
%LET k = 1;

/* Valitaan 1. v‰lill‰ erotettu sana */
%LET mmuuttuja = %SCAN(&mlista, 1);

/* Loopataan kunnes tyhj‰. Muodostetaan jokaiselle valitulle muuttujalle */
%DO %WHILE ("&mmuuttuja" NE "");
	/* Lasketaan muunnos */
	%LET &mmuuttuja = (&&&mmuuttuja / &valuutta)*&minf;
	/* Siirryt‰‰n listalla seuraavaan */
	%LET k = %EVAL(&k+1);
	%LET mmuuttuja = %SCAN(&mlista, &k);
%END;

%MEND ParamInfEsim;

/* ######### 3.3 ParamInfSimulx #########
   Tyhj‰ makro, joka ajetaan valinnalla TYYPPI = SIMULX.
*/

%MACRO ParamInfSimulx (mvuosi, mkuuk, mlista, minf, meuro=5.94573)/
DES = 'ParamMakrot: Tyhj‰ muunnosmakro tilannetta TYYPPI=SIMULX varten';
%MEND ParamInfSimulx;


/*
######### 4. Parametrien nimien hakumakrot #########
######### 4.1 HaeLokaalit #########

Makro, joka hakee listaksi mallin lakiparametrit Kaikki_param-taulu ja
palauttaa lokaali_lista-makromuuttujaan.

Sis‰‰n:
Positional parameters: Kaikki pit‰‰ syˆtt‰‰ samassa j‰rjestyksess‰.
- lokaali_lista (palautettava output)
- malli (Kaikki_param-taulun sarakkeen nimi)

*/

%MACRO HaeLokaalit(lokaali_lista, malli)/
DES = 'ParamMakrot: Mallin k‰ytt‰mien parametrien nimien hakeminen';
/* Haetaan mallikohtainen sarake yhdeksi makromuuttujaksi jossa listataan lakiparametrien nimet */
PROC SQL NOPRINT;
	SELECT &malli INTO :&lokaali_lista SEPARATED BY ' '
	FROM OHJAUS.kaikki_param;
QUIT;
%MEND HaeLokaalit;

/*
######### 4.2 HaeLaskettavatLokaalit #########

Haetaan lista lakiparametreist‰, joille Kaikki_param-taulun &malli._M -sarakkeen mukaan
lasketaan joku muunnos.

Sis‰‰n:
Positional parameters: Kaikki pit‰‰ syˆtt‰‰ samassa j‰rjestyksess‰.
- lokaali_lista (palautettava output)
- malli (Kaikki_param-taulun sarakkeen nimi)
Keyword parameters: Ei tarvitse syˆtt‰‰.
- indikaattori (Kaikki_param-taulussa muunnosta luokitteleva kirjain)
  Oletuksena k‰ytet‰‰n indikaattoria x, joka kertoo ett‰ kyse on parametrista,
  jolle halutaan tehd‰ sek‰ mahdollinen valuuttamuunnos markoista euroiksi ett‰
  INF-muunnos

*/
%MACRO HaeLaskettavatLokaalit(lokaali_lista, malli, indikaattori='x')/
DES = 'ParamMakrot: Mallin k‰ytt‰mien muunnettavien parametrien nimien hakeminen';
%LOCAL tarkastus;
/* Haetaan mallikohtainen sarake yhdeksi makromuuttujaksi jossa listataan parametrien nimet.
Muodostetaan myˆs rivien lukum‰‰r‰st‰ tarkastus-muuttuja */
PROC SQL NOPRINT;
SELECT &malli, COUNT(*) INTO :&lokaali_lista SEPARATED BY ' ', :tarkastus
FROM OHJAUS.kaikki_param
WHERE &malli and &malli._M EQ &indikaattori;
QUIT;
/* Jos valittiin nolla rivi‰, palautetaan tyhj‰ lista */
%IF &tarkastus EQ 0 %THEN %LET &lokaali_lista = ;
%MEND HaeLaskettavatLokaalit;

/*
######### 5. KuukSimul #########

Makro, jolla haetaan halutun osamallin parametrit valmiiksi silloin kun kyse on
kuukausitason simuloinnista, eli kun TYYPPI = SIMULX.

Makron parametrit:
	kuukmalli: Osamalli, jonka parametrit haetaan
*/

%MACRO KuukSimul(kuukmalli)/
DES = 'ParamMakrot: Makro, jolla haetaan halutun osamallin parametrit kuukausitason simuloinnissa';

%IF %UPCASE(&TYYPPI) = SIMULX %THEN %DO;

	%HaeParamSimul(&LVUOSI, &LKUUK, &&&kuukmalli._PARAM, PARAM.&&&P&kuukmalli);
	%ParamInfSimul(&LVUOSI, &LKUUK, &&&kuukmalli._MUUNNOS, &INF);

%END;

%MEND KuukSimul;

/*
######### 6. Yleisen asumistuen parametrien hakumakrot vuosittaisia tauluja varten #########

######### 6.1 HaeParam_VuokraNormit #########

Makro joka tarvitaan vuokranormitaulukon lukemiseen.
Vuokranormitaulukosta erotellaan halutun vuoden normit sek‰
tehd‰‰n pinta-alaluokitusta kuvaava taulukko

Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
*/

%MACRO HaeParam_VuokraNormit(mvuosi)/
DES = 'ParamMakrot: Makro, joka tarvitaan ASUMTUKI-mallin vuokranormitaulukon lukemiseen';

%IF &mvuosi < &paramalkuyat %THEN %LET mvuosi = &paramalkuyat;
%ELSE %IF &mvuosi > &paramloppuyat %THEN %LET mvuosi = &paramloppuyat;


DATA TEMP.normit&mvuosi;
SET PARAM.&PASUMTUKI_VUOKRANORMIT;
WHERE vuosi = &mvuosi;
RUN;

* Vuokranormitaulukosta erotellaan pinta-alaluokituksen sis‰lt‰v‰ sarake ;

DATA TEMP.alat;
SET TEMP.normit&mvuosi (KEEP = ala);
RUN;

* J‰rjestet‰‰n halutun vuoden vuokranormitaulukko k‰‰nteiseen j‰rjestykseen pinta-alan mukaan ;

PROC SORT  DATA = TEMP.normit&mvuosi;
BY DESCENDING ala;
RUN;

* Seuraavat toimet tulisi erottaa t‰st‰ makrosta ;

* Normitaulukon m‰‰rittelyist‰ tehd‰‰n taulukko ;

PROC CONTENTS DATA = TEMP.normit&mvuosi
OUT = TEMP.normisarak NOPRINT;
RUN;

* Edell‰ luodusta taulukosta erotellaan rakennuksen valmistumisvuotta
tarkoittavien sarakkeiden nimet, joista edelleen erotetaan vuosiluvut
omaksi sarakkeeksi. T‰t‰ k‰ytet‰‰n NormvuokraS-makroissa haettaessa vuokranormitaulukosta
oikea sarake ;

DATA TEMP.normisarakb (KEEP = taite taiten);
SET TEMP.normisarak;
WHERE SUBSTRN(name, 1, 4) = 'Valm';
taite = SUBSTRN(name, 5, 4);
taiten = INPUT(taite, 4.);
RUN;

* J‰rjestet‰‰n em. taulukko k‰‰nteiseen j‰rjestykseen ;

PROC SORT DATA = TEMP.normisarakb;
BY DESCENDING taiten ;
RUN;

%MEND HaeParam_VuokraNormit;

/* 
######### 6.2 HaeParam_EnimmVuokra #########

Makro, joka etsii osa-asuntojen enimm‰isasumismenotaulukosta halutun vuoden rivit

Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
*/

%MACRO HaeParam_EnimmVuokra (mvuosi)/
DES = 'ParamMakrot: Makro, joka etsii ASUMTUKI-mallin osa-asuntojen enimm‰isasumismenotaulukosta halutun vuoden rivit' ;

%IF &mvuosi < &paramalkuyat %THEN %LET mvuosi = &paramalkuyat;
%ELSE %IF &mvuosi > &paramloppuyat %THEN %LET mvuosi = &paramloppuyat;

DATA TEMP.penimmtaulu&mvuosi;
SET PARAM.&PASUMTUKI_ENIMMMENOT;
WHERE vuosi = &mvuosi;
RUN;

%MEND HaeParam_EnimmVuokra;


/* 
######### 7. VERO-mallin HAKU-makrot, joilla parametrit haetaan vain esimerkkilaskelmissa #########

Makrot, jotka vaikuttavat siihen, miten kussakin lakimakrossa haetaan parametrit. 
Jos tyyppi = ESIM, parametrit haetaan joka makrokutsulla erikseen.
Muuten parametrit on haettava makromuuttujiksi ennen simulointi-data-askeeleen ajamista.

*Makrojen parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi

*/

/* 
######### 7.1 HAKU #########
*/

%MACRO HAKU/
DES = 'ParamMakrot: Makro, jolla haetaan VERO-mallin parametrit vain esimerkkilaskelmissa';
%IF %UPCASE(&TYYPPI) = ESIM %THEN %DO;
%HaeParamEsim(&mvuosi, 1, &VERO_PARAM, PARAM.&PVERO);
%ParamInfEsim(&mvuosi, 1, &VERO_MUUNNOS, &minf);
%END;
%MEND HAKU;

/* 
######### 7.2 HAKUVV #########
*/

%MACRO HAKUVV/
DES = 'ParamMakrot: Makro, jolla haetaan VERO-mallin varallisuusveron parametrit vain esimerkkilaskelmissa';
%IF %UPCASE(&TYYPPI) = ESIM  %THEN %DO;
%HaeParamEsim(&mvuosi, 1, &VERO2_PARAM, PARAM.&PVERO_VARALL);
%ParamInfEsim(&mvuosi, 1, &VERO2_MUUNNOS, &minf);
%END;
%MEND HAKUVV;