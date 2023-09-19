/****************************************************
* Kuvaus: Yleisen asumistuen lains‰‰d‰ntˆ‰ makroina *
****************************************************/

/* HUOM! ASUMTUKI-mallissa parametrien haku tapahtuu vuokranormien osalta eri tavalla kuin muissa malleissa.
	  	 T‰st‰ johtuen Normivuokra- ja EnimmVuokra-lakimakroista on kaksi eri versiota aineistosimulointiin ja esimerkkilaskelmiin.
		 Tyyppi: SIMUL = Aineistosimulointi
	     Tyyppi: ESIM = Esimerkkilaskelmat */

/* Tiedosto sis‰lt‰‰ seuraavat makrot:

Asumistuki ennen vuotta 2015:
1. NormiNeliotS = Asunnon pinta-alan kohtuullinen neliˆmetrim‰‰r‰ (normineliˆt)
2. NormiVuokraSIMUL = Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), SIMUL
3. NormiVuokraESIM = Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), ESIM
4. EnimmVuokraSIMUL = Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), SIMUL
5. EnimmVuokraESIM = Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), ESIM
6. HoitoNormiS = Omakotitalon hoitonormi kuukaudessa
7. TuloMuokkausS = Perusomavastuun m‰‰rittelyss‰ tarvittavan tulon laskenta
8. PerusOmaVastS = Perusomavastuu kuukaudessa
9. AsumTukiVuokS = Asumistuki kuukaudessa vuokra-asunnossa
10. AsumTukiOmS = Asumistuki kuukaudessa omistusasunnossa
11. AsumTukiOsaS = Asumistuki kuukaudessa osa-asunnossa

Asumistuki vuonna 2015 ja sen j‰lkeen:
12. As2015PeruskaavaS =	Asumistuen peruskaava
13. As2015PerusOmaVastuuS = Perusomavastuu
14. As2015VesinormiS = Hyv‰ksytt‰v‰t vesimaksut
15. As2015LamponormiS = Hyv‰ksytt‰v‰t l‰mmitysmenot
16. As2015KattovuokraS = Hyv‰ksytt‰v‰t enimm‰isasumismenot
17. As2015KorkomenoS = Hyv‰ksytt‰v‰t korkomenot
18. As2015AsumismenoVuokraAsuntoS = Asumismenot vuokra-asunnossa
19. As2015HyvAsumismenoVuokraAsuntoS = Hyv‰ksytt‰v‰t asumismenot vuokra-asunnossa
20. As2015AsumistukiVuokraKS = Asumistuki kuukaudessa vuokra-asunnossa
21. As2015AsumistukiVuokraVS = Asumistuki vuosikeskiarvona vuokra-asunnossa
22. As2015HoitomenoOmaOsakeTodS = Todelliset hoitomenot omassa osakeasunnossa
23. As2015HoitomenoOmaOsakeS = Hoitomenot omassa osakeasunnossa
24. As2015HyvHoitomenoOmaOsakeS	= Hyv‰ksytt‰v‰t hoitomenot omassa osakeasunnossa
25. As2015RahoitusmenoOmaOsakeS	= Rahoitusmenot omassa osakeasunnossa
26. As2015HyvRahoitusmenoOmaOsakeS = Hyv‰ksytt‰v‰t rahoitusmenot omassa osakeasunnossa
27. As2015HyvAsumismenoOmaOsakeS = Hyv‰ksytt‰v‰t asumismenot omassa osakeasunnossa
28. As2015AsumistukiOmaOsakeKS = Asumistuki kuukaudessa omassa osakeasunnossa
29. As2015AsumistukiOmaOsakeVS = Asumistuki vuosikeskiarvona omassa osakeasunnossa
30. As2015HoitonormiS = Hyv‰ksytt‰v‰t hoitomenot
31. As2015HoitomenoOmaTaloTodS = Todelliset hoitomenot omassa omakotitalossa
32. As2015HoitomenoOmaTaloS = Hoitomenot omassa omakotitalossa
33. As2015HyvHoitomenoOmaTaloS = Hyv‰ksytt‰v‰t hoitomenot omassa omakotitalossa
34. As2015RahoitusmenoOmaTaloS = Rahoitusmenot omassa omakotitalossa
35. As2015HyvRahoitusmenoOmaTaloS = Hyv‰ksytt‰v‰t rahoitusmenot omassa omakotitalossa
36. As2015HyvAsumismenoOmaTaloS = Hyv‰ksytt‰v‰t asumismenot omassa omakotitalossa
37. As2015AsumistukiOmaTaloKS = Asumistuki kuukaudessa omassa omakotitalossa
38. As2015AsumistukiOmaTaloVS = Asumistuki vuosikeskiarvona omassa omakotitalossa */




***********************************
*  Asumistuki ennen vuotta 2015.  *
***********************************;

/* 1. Makro, joka m‰‰rittelee normineliˆt (asunnon pinta-alan kohtuullisen neliˆmetrim‰‰r‰n);
	  Toimii, kun lains‰‰d‰ntˆvuosi annettu makromuuttujana ja kyseisen vuoden parametrit jo m‰‰ritelty */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normineliˆt, m2 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0);

%MACRO NormiNeliotS(tulos, mvuosi, henk, vamm)/
DES = 'ASUMTUKI: Asunnon pinta-alan kohtuullinen neliˆmetrim‰‰r‰ (normineliˆt)';

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

luku = &henk;

*Vuodesta 1998 l‰htien vammaisille normi suuremman henkilˆluvun mukaan;

IF (&mvuosi > 1997) AND (&vamm NE 0) THEN luku = &henk + 1;

SELECT (luku);
   WHEN(1) &tulos = &EnimmN1;
   WHEN(2) &tulos = &EnimmN2;
   WHEN(3) &tulos = &EnimmN3;
   WHEN(4) &tulos = &EnimmN4;
   WHEN(5) &tulos = &EnimmN5;
   WHEN(6) &tulos = &EnimmN6;
   WHEN(7) &tulos = &EnimmN7;
   WHEN(8) &tulos = &EnimmN8;
   OTHERWISE &tulos = &EnimmN8 + (luku - 8) * &EnimmNPlus;
END;

DROP luku;

%MEND NormiNeliotS;

/* 2. Makro, joka m‰‰rittelee normivuokran (hyv‰ksytt‰v‰n kuukausittaisen enimm‰isasumismenon neliˆmetri‰ kohden).
	  T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	  Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	  T‰m‰ edellytt‰‰, ett‰ halutun vuoden vuokranormit on jo erotettu omaksi taulukoksi normit&mvuosi. */
 
*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/m2/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala;

%MACRO NormiVuokraSIMUL (tulos, mvuosi,  minf, kryhma, kesklamm, vesijohto, valmvuosi, ala)/
DES = 'ASUMTUKI: Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), SIMUL';

*Ensin etsit‰‰n oikea sarake, hakemalla vuosiluvun perusteella taulukosta normisarakb oikea
sarakkeen nimi;

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

IF _N_ = 1 OR taulu_ns = . THEN taulu_ns = OPEN("TEMP.normisarakb", "i");

RETAIN taulu_ns;

w = REWIND(taulu_ns);

w = FETCHOBS(taulu_ns, 1);

IF (GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900) THEN DO;
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

ELSE DO UNTIL ((GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900));
	w = FETCH(taulu_ns);
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

*T‰m‰n j‰lkeen haetaan vuokranormi pinta-alan, kuntaryhm‰n ym. muuttujien avulla;

nimi = COMPRESS("TEMP.normit"||nvuosi);

IF _N_ = 1 OR taulu_vn = . THEN taulu_vn = OPEN(nimi, "i");

RETAIN taulu_vn;

w = REWIND(taulu_vn);

w = FETCHOBS(taulu_vn, 1);
IF GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) THEN DO;
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi < 2002, &euro, 1);
END;
ELSE DO UNTIL (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2));
	w = FETCH(taulu_vn);
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi < 2002, &euro, 1);	
END;

*w = CLOSE(taulu_vn);

DROP nvuosi taulu_ns w taulu_vn; 

%MEND NormiVuokraSIMUL;

/* 3. Makro, joka m‰‰rittelee normivuokran kuukausitasolla.
	  T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain taulukossa, jossa lains‰‰d‰ntˆvuosi on SAS-muuttuja.
      Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM). */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala;

%MACRO NormiVuokraESIM (tulos, mvuosi, minf, kryhma, kesklamm, vesijohto, valmvuosi, ala)/
DES = 'ASUMTUKI: Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), ESIM';

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

IF _N_ = 1 OR taulu_ns = . THEN taulu_ns = OPEN("TEMP.normisarakb", "i");

RETAIN taulu_ns;

w = REWIND(taulu_ns);
w = FETCHOBS(taulu_ns, 1);

IF (GETVARN(taulu_ns, 2) <= &valmvuosi) THEN sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
ELSE DO UNTIL ((GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900));
	w = FETCH(taulu_ns);
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

IF _N_ = 1 OR taulu_vn = . THEN taulu_vn = OPEN("PARAM.&PASUMTUKI_VUOKRANORMIT", "i");

RETAIN taulu_vn;

w = REWIND(taulu_vn);

w = FETCHOBS(taulu_vn, 1);

IF  (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) AND nvuosi = GETVARN(taulu_vn, 3)) THEN DO;
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi<2002, &euro, 1);	
END;
ELSE DO UNTIL (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) AND nvuosi = GETVARN(taulu_vn, 3));
	w = FETCH(taulu_vn);
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi<2002, &euro, 1);	
END;

DROP nvuosi taulu_ns w sarake taulu_vn;

%MEND NormiVuokraESIM;

/* 4. Makro, joka m‰‰rittelee normivuokran osa-asunnossa kuukausitasolla.
	  T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	  Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	  Toimii osana data-asekelta, kun lains‰‰d‰ntˆvuosi on m‰‰ritelty ennen makron ajamista ja halutun
	  vuoden normit eroteltu taulukoksi penimmtaulu&mvuosi. */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra osa-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰;

%MACRO EnimmVuokraSIMUL(tulos, mvuosi, minf, kryhma, henk)/
DES = 'ASUMTUKI: Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), SIMUL';

%LET valuutta = IFN(&mvuosi < 2002, &euro, 1);

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

enimnimi = COMPRESS("TEMP.penimmtaulu"||nvuosi);

IF _N_ = 1 OR taulu_ev = . THEN taulu_ev = OPEN(enimnimi, "i");

RETAIN taulu_ev;

w = REWIND(taulu_ev);

w = FETCHOBS(taulu_ev, 1);

IF GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
ELSE DO UNTIL ((GETVARN(taulu_ev, 1) = &kryhma) OR (w = -1));
	w = FETCH(taulu_ev);
	IF GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
END;

*W = CLOSE(taulu_ev);

DROP nvuosi enimnimi taulu_ev w;

%MEND EnimmVuokraSIMUL;

/* 5. Makro, joka m‰‰rittelee normivuokran osa-asunnossa kuukausitasolla.
	  T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain taulukossa, jossa lains‰‰d‰ntˆvuosi on SAS-muuttuja.
      Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).*/

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰;

%MACRO EnimmVuokraESIM(tulos, mvuosi, minf, kryhma, henk)/
DES = 'ASUMTUKI: Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), ESIM';

%LET valuutta = IFN(&mvuosi < 2002, &euro, 1);

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

IF _N_ = 1 OR taulu_ev = . THEN taulu_ev = OPEN("param.&PASUMTUKI_ENIMMMENOT", "i");

RETAIN taulu_ev;

w = REWIND(taulu_ev);

w = FETCHOBS(taulu_ev, 1);

IF GETVARN(taulu_ev, 2 ) = nvuosi AND GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
ELSE DO UNTIL ((GETVARN(taulu_ev, 2 ) = nvuosi) AND (GETVARN(taulu_ev, 1) = &kryhma) OR (w = -1));
	w = FETCH(taulu_ev);
	IF GETVARN(taulu_ev, 1 ) = &kryhma AND GETVARN(taulu_ev, 2 ) = nvuosi THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
END;

DROP nvuosi taulu_ev w;

%MEND EnimmVuokraESIM;

/* 6. Makro, joka laskee omakotitalon hoitonormin, tai erillisen l‰mmitysnormin */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, omakotitalon hoitonormi, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	omakoti: Onko omakotitalo (on/ei, 1/0)
	lryhma: L‰mmitysryhma (1-3)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	ala: Asunnon pinta-ala;

%MACRO HoitoNormiS(tulos, mvuosi, minf, omakoti, lryhma, henk, ala)/
DES = 'ASUMTUKI: Omakotitalon hoitonormi kuukaudessa';

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
%ParamInf&TYYPPI(&mvuosi, 1, &ASUMTUKI_MUUNNOS, &minf);

SELECT(&lryhma);
	WHEN(1) neliokohd = &Hoitomeno1;
	WHEN(2) neliokohd = &Hoitomeno2;
	WHEN(3) neliokohd = &Hoitomeno3;
	OTHERWISE neliokohd = &Hoitomeno1;
END;

IF &omakoti = 0 THEN &tulos = &ala * neliokohd;

ELSE &tulos = SUM(&HoitoMenoAs, &henk * &HoitoMenoHenk, &ala * neliokohd);

DROP neliokohd;

%MEND HoitoNormiS;

/* 7. Makro, joka laskee perusomavastuun m‰‰rittelyss‰ tarvittavan tulon
	  ottamalla huomioon varallisuuden, yksinhuoltajuuden ja henkilˆluvun */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, perusomavastuun m‰‰rittelyss‰ tarvittava tulo, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	ykshuolt: Yksinhuoltaja (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	varall: Ruokakunnan varallisuus, e
	tulot: Ruokakunnan huomioon otettavat tulot, e/kk;

%MACRO TuloMuokkausS(tulos, mvuosi, minf, ykshuolt, henk, varall, tulot)/
DES = 'ASUMTUKI: Perusomavastuun m‰‰rittelyss‰ tarvittavan tulon laskenta';

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
%ParamInf&TYYPPI(&mvuosi, 1, &ASUMTUKI_MUUNNOS, &minf);

*Ensin valitaan varallisuusrajanormi;

SELECT(&henk);
	WHEN(1) varraja = &AVarRaja1;
	WHEN(2) varraja = &AVarRaja2;
	WHEN(3) varraja = &AVarRaja3;
	WHEN(4) varraja = &AVarRaja4;
	WHEN(5) varraja = &AVarRaja5;
	OTHERWISE;
END;
SELECT;
	WHEN(&henk >= 6) varraja = &AVarRaja6;
	OTHERWISE varraja = varraja;
END;
&tulos = &tulot;

*Ennen vuotta 1998 varallisuusrajan ylitys johti siihen, ett‰ asumistukea ei saanut,
eli tulot katsottiin niin suuriksi, ettei asumistukeen ole oikeutta;

IF (&mvuosi < 1998) AND (&varall >  varraja) THEN &tulos = 999999;

*Vuodesta 1998 l‰htien tietty prosenttisuus (VarallPros) rajan ylityksest‰ katsotaan tuloksi;

IF (&mvuosi >= 1998 AND &varall >  varraja) THEN &tulos = SUM(&tulot, &VarallPros) * (&varall - varraja);

*Jos henkilˆit‰ on enemm‰n kuin 8 tuloista v‰hennet‰‰n henkilˆluvun ylityksell‰ kerrottu vakio;

IF (&henk > 8) THEN &tulos = SUM(&tulot, -(&henk - 8) * &OmaVastVah);

*Yhden lapsen yksinhuoltajille lis‰v‰hennys huomioon otettaviin tuloihin;

IF (&ykshuolt NE 0 AND &henk = 2) THEN &tulos = SUM(&tulot, -&YksHVah);

IF &tulos < 0 THEN &tulos = 0;

DROP varraja;

%MEND TuloMuokkausS;

/* 8. Makro, joka m‰‰rittelee perusomavastuun kuukaudessa */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, perusomavastuu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	tulo: Ruokakunnan tulot, johon on tehty edellisen makron sis‰lt‰m‰t
		  muokkaukkset henkilˆluvun, varallisuuden ja yksinhuoltajuuden perusteella, e/kk;

%MACRO PerusOmaVastS (tulos, mvuosi, minf, kryhma, henk, tulo)/
DES = 'ASUMTUKI: Perusomavastuu kuukaudessa';

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

%LET valuutta = IFN(nvuosi < 2002, &euro, 1);

&tulos = 0;
testi = &tulo / &minf;

*Oikean taulukon nime‰mist‰ varten m‰‰ritell‰‰n kuntaryhm‰st‰ ja vuodesta riippuva tunnus, joka on
taulukon nimen lopussa; 
*Ennen vuotta 1995 kuntaryhmi‰ oli kolme ja nykyisell‰ 3. ja 4. kuntaryhm‰ll‰ oli yhteinen taulukko (c).
*Vuosina 1995ñ2001 kuntaryhmi‰ oli 3 ja nykyisill‰ 1. ja 2. kuntaryhm‰ll‰ oli yhteinen taulukko (a).
*Vuodesta 2002 l‰htien kuntaryhmi‰ on 4 ja kuntaryhmill‰ 1. ja 2. on yhteinen taulukko (ab).;

IF nvuosi < 1995 THEN DO;
		tunnus1 = ' a';
		tunnus2 = ' b';
		tunnus3 = ' c';
		tunnus4 = ' c';
END;

ELSE IF nvuosi> 1994 AND nvuosi < 2002 THEN DO;
		tunnus1 = ' a';
		tunnus2 = ' a';
		tunnus3 = ' b';
		tunnus4 = ' c';
END;

ELSE IF nvuosi GE 2002 THEN DO;
		tunnus1 = 'ab';
		tunnus2 = 'ab';
		tunnus3 = ' c';
		tunnus4 = ' d';
END;

*Avattavan taulukon nimi;

povnimi1 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus1);
povnimi2 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus2);
povnimi3 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus3);
povnimi4 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus4);

*Jos tyyppi = SIMUL tai SIMULx, taulukko avataan vain kerran;

IF _N_ = 1 OR taulu_pov1 = . OR UPCASE(SYMGET("TYYPPI")) = 'ESIM' THEN taulu_pov1 = OPEN(povnimi1, "i");
IF _N_ = 1 OR taulu_pov2 = . OR UPCASE(SYMGET("TYYPPI")) = 'ESIM' THEN taulu_pov2 = OPEN(povnimi2, "i");
IF _N_ = 1 OR taulu_pov3 = . OR UPCASE(SYMGET("TYYPPI")) = 'ESIM' THEN taulu_pov3 = OPEN(povnimi3, "i");
IF _N_ = 1 OR taulu_pov4 = . OR UPCASE(SYMGET("TYYPPI")) = 'ESIM' THEN taulu_pov4 = OPEN(povnimi4, "i");

%IF %UPCASE(&TYYPPI) = SIMUL OR %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
	RETAIN taulu_pov1;
	RETAIN taulu_pov2;
	RETAIN taulu_pov3;
	RETAIN taulu_pov4;
%END;

*Selataan taulukkoa, kunnes henkilˆn lukum‰‰r‰‰ osoittavasta
sarakkeesta lˆytyy ensimm‰inen rivi, jossa testitulo >= tuloraja;
*Sarakkeen numero = henkilˆiden lukum‰‰r‰ + 1, paitsi jos henkilˆit‰ > 8;
*T‰ss‰ tarvitaan joka kuntaryhm‰lle oma koodi koska eri kuntaryhmien
tiedot haetaan eri taulukoista;

SELECT (&kryhma);
    WHEN (1) DO;	
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov1);
		w = FETCHOBS(taulu_pov1, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov1, MIN(&henk + 1, 9)) / &valuutta;
		ELSE DO WHILE (raja < testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov1, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov1, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov1);
		END;
	END;
	WHEN (2) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov2);
		w = FETCHOBS(taulu_pov2, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov2, MIN(&henk + 1, 9)) / &valuutta;
		ELSE DO WHILE(raja <  testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov2, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov2, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov2);
		END;
	END;
	WHEN (3) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov3);
		w = FETCHOBS(taulu_pov3, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov3, MIN(&henk + 1, 9)) / &valuutta;
		DO WHILE(raja <  testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov3, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov3, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov3);
		END;
	END;
	WHEN (4) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov4);
		w = FETCHOBS(taulu_pov4, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov4, MIN(&henk + 1, 9)) / &valuutta;
		DO WHILE(raja < testi AND w = 0);
		    IF w = 0 THEN raja = GETVARN(taulu_pov4, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov4, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
   		     w = FETCH(taulu_pov4);
		END;
	END;
	OTHERWISE;
END;

*Jos tyyppi = ESIM, taulukot avataan ja suljetaan joka rivill‰ erikseen;

%IF %UPCASE(&TYYPPI) = ESIM %THEN %DO;
	W = CLOSE (taulu_pov1);
	W = CLOSE (taulu_pov2);
	W = CLOSE (taulu_pov3);
	W = CLOSE (taulu_pov4);
	DROP taulu_pov1 taulu_pov2 taulu_pov3 taulu_pov4;
%END;

DROP w raja testi tunnus1 tunnus2 tunnus3 tunnus4 povnimi1 povnimi2 povnimi3 povnimi4 nvuosi;

IF &tulos = . THEN &tulos  = 9999/&valuutta;

%MEND PerusOmaVastS;

/* 9. Asumistuki kuukaudessa vuokra-asunnossa. 
       Perusomavastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumistuki vuokra-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	lryhma: l‰mmitysryhma (1 -3)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala
	perusomavast: Perusomavastuu, e/kk
	vuokra: Vuokra, e/kk
	vesi: Vesimaksu, e/kk
	lammkust: Erilliset l‰mmityskustannukset, e/kk;

%MACRO AsumTukiVuokS(tulos, mvuosi, minf, kryhma, lryhma, kesklamm, vesijohto, henk, vamm, 
valmvuosi, ala, perusomavast, vuokra, vesi, lammkust)/
DES = 'ASUMTUKI: Asumisuki kuukaudessa vuokra-asunnossa';

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
%ParamInf&TYYPPI(&mvuosi, 1, &ASUMTUKI_MUUNNOS, &minf);

%NormiNeliotS(hyvneliot, &mvuosi, &henk, &vamm);

hyvala = MIN(&ala, hyvneliot);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

%HoitonormiS(hyvlamm, &mvuosi, &minf, 0, &lryhma, 0, &ala);

hyvlamm = MIN(hyvlamm, &lammkust);

askust = SUM(&vuokra, hyvvesi, hyvlamm);

IF &ala > 0 THEN neliokust = askust / &ala;

ELSE neliokust = 0;

%IF %UPCASE(&TYYPPI) = ESIM %THEN %DO;
	%NormivuokraESIM(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);
%END;

%IF %UPCASE(&TYYPPI) = SIMUL OR %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
	%NormivuokraSIMUL(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);
%END;

hyvkust2 = MIN(hyvkust, neliokust);

hyvkust3 = hyvala * hyvkust2;

&tulos = &ATukiPros * (hyvkust3 - &perusomavast);

IF &tulos <  &APieninTuki THEN &tulos = 0;

DROP hyvneliot hyvala hyvlamm hyvvesi askust neliokust hyvkust hyvkust2 hyvkust3;

%MEND AsumtukiVuokS;

/* 10. Asumisuki kuukaudessa omistusasunnossa. 
       Perusomvastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumistuki omistusasunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	lryhma: l‰mmitysryhma (1 -3)
	omakoti: Onko omakotitalo (on/ei, 1/0)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala
	omavast: Perusomavastuu, e/kk
	yhtvast: Yhtiˆvastike, e/kk
	vesi: Vesimaksu, e/kk
	lammkust: Erilliset l‰mmityskustannukset, e/kk
	korot: Asuntolainan korot, e/kk
	vuosimaksu: Aravalainan vuosimaksu, e/kk;

%MACRO AsumTukiOmS(tulos, mvuosi, minf, kryhma, lryhma, omakoti, kesklamm, vesijohto, henk, vamm, valmvuosi, 
ala, omavast, yhtvast, vesi, lammkust, korot, vuosimaksu)/
DES = 'ASUMTUKI: Asumistuki kuukaudessa omistusasunnossa';

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
%ParamInf&TYYPPI(&mvuosi, 1, &ASUMTUKI_MUUNNOS, &minf);

%NormiNeliotS(hyvneliot, &mvuosi, &henk, &vamm);

hyvala = MIN(&ala, hyvneliot);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

hyvkorot = &KorkoTukiPros * &korot;

hyvvuosimaksu = &AravaPros * &vuosimaksu;

%HoitonormiS(hyvlamm, &mvuosi, &minf, &omakoti, &lryhma, &henk, &ala);

IF &omakoti NE 0 THEN asmeno = SUM(hyvkorot, hyvvuosimaksu, hyvlamm);

ELSE asmeno = SUM(&yhtvast, hyvkorot, hyvvuosimaksu, hyvvesi, MIN(hyvlamm, &lammkust));

IF &ala > 0 THEN neliokust = asmeno / &ala;

ELSE neliokust = 0;

%IF %UPCASE(&TYYPPI) = ESIM %THEN %DO;
	%NormivuokraESIM(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);
%END;

%IF %UPCASE(&TYYPPI) = SIMUL OR %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
	%NormivuokraSIMUL(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);
%END;

hyvkust2 = MIN(hyvkust, neliokust);

asmeno2 = hyvala * hyvkust2;

&tulos = &ATukiPros * (asmeno2 - &omavast);

IF &tulos < &APieninTuki THEN &tulos = 0;

DROP hyvneliot hyvala hyvvesi hyvkorot hyvvuosimaksu hyvlamm asmeno asmeno2 neliokust hyvkust hyvkust2 ;

%MEND AsumTukiOmS;

/* 11. Asumistuki kuukaudessa osa-asunnossa.
       Perusomavastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumisuki osa-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	perusomavast: Perusomavastuu, e/kk
	vuokra: Vuokra, e/kk
	vesi: Vesimaksu, e/kk;

%MACRO AsumTukiOsaS(tulos, mvuosi, minf, kryhma, henk, vamm, perusomavast, vuokra, vesi)/
DES = 'ASUMTUKI: Asumisuki kuukaudessa osa-asunnossa';

luku = &henk;

*Vammaisille normi yht‰ suuremman henkilˆluvun mukaan:;

IF (&mvuosi > 1997) AND (&vamm NE 0) THEN luku = &henk + 1;

%HaeParam&TYYPPI(&mvuosi, 1, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
%ParamInf&TYYPPI(&mvuosi, 1, &ASUMTUKI_MUUNNOS, &minf);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

%IF %UPCASE(&TYYPPI) = ESIM %THEN %DO;
	%EnimmVuokraESIM(hyvvuokra, &mvuosi, &minf, &kryhma, luku);
%END;

%IF %UPCASE(&TYYPPI) = SIMUL OR %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
	%EnimmVuokraSIMUL(hyvvuokra, &mvuosi, &minf, &kryhma, luku);
%END;

hyvvuokra = MIN(SUM(&vuokra, hyvvesi), hyvvuokra);

&tulos = &ATukiPros * SUM(hyvvuokra, -&perusomavast);

IF &tulos < &APieninTuki THEN &tulos = 0;

DROP luku hyvvesi hyvvuokra;

%MEND AsumtukiOsaS;




********************************************
*  Asumistuki vuonna 2015 ja sen j‰lkeen.  *
********************************************;


/* 12. Asumistuen peruskaava */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuen peruskaava, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		hyvasumismeno: Hyv‰ksytt‰v‰t asumismenot, e/kk
		perusomavastuu: Perusomavastuu, e/kk */

%MACRO As2015PeruskaavaS(tulos, mvuosi, mkuuk, minf, hyvasumismeno, perusomavastuu) /
DES = "ASUMTUKI: Asumistuen peruskaava";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	eipyorasumistuki = &ATukiPros * SUM(&hyvasumismeno, -&perusomavastuu);

	%PyoristysSentinTarkkuuteen(asumistuki, eipyorasumistuki);

	IF asumistuki < &APieninTuki THEN &tulos = 0;
	ELSE &tulos = asumistuki;

	DROP eipyorasumistuki asumistuki;	

%MEND As2015PeruskaavaS;


/* 13. Perusomavastuu */

/*	Makron parametrit:
		tulos: Makron tulosmuuttuja, perusomavastuu, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */

%MACRO As2015PerusomavastuuS(tulos, mvuosi, mkuuk, minf, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Perusomavastuu";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	IF MDY(&mkuuk, 1, &mvuosi) >= MDY(8, 1, 2017) THEN yhttulot = SUM(&tulot, &opinraha);
	ELSE yhttulot = &tulot;

	vahtyotulotsum = 0;
	DO i=1 TO DIM(&tyotulot);
		%PyoristysSentinTarkkuuteen(pyortyotulot, &tyotulot{i});
		IF pyortyotulot > &AAnsiotulovahennys THEN vahtyotulot = &AAnsiotulovahennys;
		ELSE vahtyotulot = pyortyotulot;
		vahtyotulotsum = SUM(vahtyotulotsum, vahtyotulot); 
	END;

	eipyorastukitulot = SUM(yhttulot, -vahtyotulotsum);

	%PyoristysEuronTarkkuuteen(astukitulot, eipyorastukitulot);

	eipyorperusomavastuu = &PerusomaKerroin * SUM(astukitulot, -SUM(&PerusomaVakio, &PerusomaAikuinenKerroin * &aikuistenlkm, &PerusomaLapsiKerroin * &lastenlkm));

	%PyoristysSentinTarkkuuteen(perusomavastuu, eipyorperusomavastuu);

	IF perusomavastuu < &PerusOmaEiHuomioonRaja THEN &tulos = 0;
	ELSE &tulos = perusomavastuu;

	DROP yhttulot vahtyotulotsum i pyortyotulot vahtyotulot eipyorastukitulot astukitulot 
	eipyorperusomavastuu perusomavastuu;

%MEND As2015PerusomavastuuS;


/* 14. Hyv‰ksytt‰v‰t vesimaksut */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t vesimaksut, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰ */

%MACRO As2015VesinormiS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t vesimaksut";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	&tulos = &HuomVesi * &ruokakunnankoko;

%MEND As2015VesinormiS;


/* 15. Hyv‰ksytt‰v‰t l‰mmitysmenot */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t l‰mmitysmenot, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */

%MACRO As2015LamponormiS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, lisakustannusryhma) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t l‰mmitysmenot";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	%PyoristysEuronTarkkuuteen(huomlampo1_lk1, (1 + &HuomLampoHNormiKor1) * &HuomLampo1);
	%PyoristysEuronTarkkuuteen(huomlampoplus_lk1, (1 + &HuomLampoHNormiKor1) * &HuomLampoPlus);

	%PyoristysEuronTarkkuuteen(huomlampo1_lk2, (1 + &HuomLampoHNormiKor2) * &HuomLampo1);
	%PyoristysEuronTarkkuuteen(huomlampoplus_lk2, (1 + &HuomLampoHNormiKor2) * &HuomLampoPlus);

	IF &lisakustannusryhma = 0 THEN lampoyht = SUM(&HuomLampo1, &HuomLampoPlus * (&ruokakunnankoko - 1));
	ELSE IF &lisakustannusryhma = 1 THEN lampoyht = SUM(huomlampo1_lk1, huomlampoplus_lk1 * (&ruokakunnankoko - 1));
	ELSE IF &lisakustannusryhma = 2 THEN lampoyht = SUM(huomlampo1_lk2, huomlampoplus_lk2 * (&ruokakunnankoko - 1));

	&tulos = lampoyht;

	DROP huomlampo1_lk1 huomlampoplus_lk1 huomlampo1_lk2 huomlampoplus_lk2 lampoyht;

%MEND As2015LamponormiS;


/* 16. Hyv‰ksytt‰v‰t enimm‰isasumismenot */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t enimm‰isasumismenot, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa */

%MACRO As2015KattovuokraS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t enimm‰isasumismenot";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	IF &vammaistenlkm >= 1 THEN ruokakunnankokol = &ruokakunnankoko + &vammaistenlkm;
	ELSE ruokakunnankokol = &ruokakunnankoko;

	SELECT(&kuntaryhma);
	
		WHEN(1) DO;
			SELECT(ruokakunnankokol);
				WHEN(1) &tulos = &Kattovuokra_1_1;
				WHEN(2) &tulos = &Kattovuokra_1_2;
				WHEN(3) &tulos = &Kattovuokra_1_3;
				WHEN(4) &tulos = &Kattovuokra_1_4;
				OTHERWISE &tulos = &Kattovuokra_1_4 + (ruokakunnankokol - 4) * &Kattovuokra_1_Plus;
			END;
		END;

		WHEN(2) DO;
			SELECT(ruokakunnankokol);
				WHEN(1) &tulos = &Kattovuokra_2_1;
				WHEN(2) &tulos = &Kattovuokra_2_2;
				WHEN(3) &tulos = &Kattovuokra_2_3;
				WHEN(4) &tulos = &Kattovuokra_2_4;
				OTHERWISE &tulos = &Kattovuokra_2_4 + (ruokakunnankokol - 4) * &Kattovuokra_2_Plus;
			END;
		END;

		WHEN(3) DO;
			SELECT(ruokakunnankokol);
				WHEN(1) &tulos = &Kattovuokra_3_1;
				WHEN(2) &tulos = &Kattovuokra_3_2;
				WHEN(3) &tulos = &Kattovuokra_3_3;
				WHEN(4) &tulos = &Kattovuokra_3_4;
				OTHERWISE &tulos = &Kattovuokra_3_4 + (ruokakunnankokol - 4) * &Kattovuokra_3_Plus;
			END;
		END;

		WHEN(4) DO;
			SELECT(ruokakunnankokol);
				WHEN(1) &tulos = &Kattovuokra_4_1;
				WHEN(2) &tulos = &Kattovuokra_4_2;
				WHEN(3) &tulos = &Kattovuokra_4_3;
				WHEN(4) &tulos = &Kattovuokra_4_4;
				OTHERWISE &tulos = &Kattovuokra_4_4 + (ruokakunnankokol - 4) * &Kattovuokra_4_Plus;
			END;
		END;

	END;

	DROP ruokakunnankokol;	

%MEND As2015KattovuokraS;


/* 17. Hyv‰ksytt‰v‰t korkomenot */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t korkomenot, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015KorkomenoS(tulos, mvuosi, mkuuk, korko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t korkomenot";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	&tulos = &KorkoTukiPros * &korko;

%MEND As2015KorkomenoS;


/* 18. Asumismenot vuokra-asunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumismenot vuokra-asunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vuokra: Vuokra, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk 
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */		

%MACRO As2015AsumismenoVuokraAsuntoS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, vuokra, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma) /
DES = "ASUMTUKI: Asumismenot vuokra-asunnossa";

	IF &erillinenvesi = 1 THEN DO;
		%As2015VesinormiS(vesimaksu, &mvuosi, &mkuuk, &minf, &ruokakunnankoko);
	END;
	ELSE vesimaksu = 0;

	IF &erillinenlampo = 1 THEN DO;
		%As2015LamponormiS(lampomaksu, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &lisakustannusryhma);
	END;
	ELSE lampomaksu = 0;

	IF &vuokra < &alivuokralaisenvuokra THEN eipyorasumismeno = SUM(vesimaksu, lampomaksu);
	ELSE eipyorasumismeno = SUM(&vuokra, -&alivuokralaisenvuokra, vesimaksu, lampomaksu);

	%PyoristysSentinTarkkuuteen(asumismeno, eipyorasumismeno);

	&tulos = asumismeno;

	DROP vesimaksu lampomaksu eipyorasumismeno asumismeno; 

%MEND As2015AsumismenoVuokraAsuntoS;


/* 19. Hyv‰ksytt‰v‰t asumismenot vuokra-asunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t asumismenot vuokra-asunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vuokra: Vuokra, e/kk 
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */		
	
%MACRO As2015HyvAsumismenoVuokraAsuntoS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, vuokra, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t asumismenot vuokra-asunnossa";

	%As2015KattovuokraS(kattovuokra, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm);

	%As2015AsumismenoVuokraAsuntoS(asumismeno, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &vuokra, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	&tulos = MIN(kattovuokra, asumismeno);

	DROP kattovuokra asumismeno;

%MEND As2015HyvAsumismenoVuokraAsuntoS;


/* 20. Asumistuki kuukaudessa vuokra-asunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki kuukaudessa vuokra-asunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vuokra: Vuokra, e/kk  
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */
		
%MACRO As2015AsumistukiVuokraKS(tulos, mvuosi, mkuuk, minf, kuntaryhma, vammaistenlkm, vuokra, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki kuukaudessa vuokra-asunnossa";

	%As2015HyvAsumismenoVuokraAsuntoS(hyvasumismeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, (&aikuistenlkm + &lastenlkm), &vammaistenlkm, &vuokra, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);
	
	%As2015PerusomavastuuS(perusomavastuu, &mvuosi, &mkuuk, &minf, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);

	%As2015PeruskaavaS(asumistuki, &mvuosi, &mkuuk, &minf, hyvasumismeno, perusomavastuu);

	&tulos = asumistuki;

	DROP astukitulot hyvasumismeno perusomavastuu asumistuki;

%MEND As2015AsumistukiVuokraKS;


/* 21. Asumistuki vuosikeskiarvona vuokra-asunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki vuosikeskiarvona vuokra-asunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vuokra: Vuokra, e/kk  
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */

%MACRO As2015AsumistukiVuokraVS(tulos, mvuosi, minf, kuntaryhma, vammaistenlkm, vuokra, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki vuosikeskiarvona vuokra-asunnossa";

	asvuosi = 0;

	%DO kuuk=1 %TO 12;
		%As2015AsumistukiVuokraKS(askk, &mvuosi, &kuuk, &minf, &kuntaryhma, &vammaistenlkm, &vuokra, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);
		asvuosi = SUM(asvuosi, askk); 
	%END;

	asvuosi = asvuosi / 12;

	&tulos = asvuosi;

	DROP askk asvuosi;

%MEND As2015AsumistukiVuokraVS;


/* 22. Todelliset hoitomenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, todelliset hoitomenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */

%MACRO As2015HoitomenoOmaOsakeTodS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma) /
DES = "ASUMTUKI: Todelliset hoitomenot omassa osakeasunnossa";

	IF &erillinenvesi = 1 THEN DO;
		%As2015VesinormiS(vesimaksu, &mvuosi, &mkuuk, &minf, &ruokakunnankoko);
	END;
	ELSE vesimaksu = 0;

	IF &erillinenlampo = 1 THEN DO;
		%As2015LamponormiS(lampomaksu, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &lisakustannusryhma);
	END;
	ELSE lampomaksu = 0;

	eipyorhoitomenotod = SUM(&vastike, vesimaksu, lampomaksu, -&alivuokralaisenvuokra);

	%PyoristysSentinTarkkuuteen(hoitomenotod, eipyorhoitomenotod);

	&tulos = hoitomenotod;

	DROP vesimaksu lampomaksu eipyorhoitomenotod hoitomenotod;

%MEND As2015HoitomenoOmaOsakeTodS;


/* 23. Hoitomenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hoitomenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk 
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */

%MACRO As2015HoitomenoOmaOsakeS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma) /
DES = "ASUMTUKI: Hoitomenot omassa osakeasunnossa";

	%As2015HoitomenoOmaOsakeTodS(hoitomenotod, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	IF hoitomenotod < 0 THEN &tulos = 0;
	ELSE &tulos = hoitomenotod;

	DROP hoitomenotod;

%MEND As2015HoitomenoOmaOsakeS;


/* 24. Hyv‰ksytt‰v‰t hoitomenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t hoitomenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa 
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */	

%MACRO As2015HyvHoitomenoOmaOsakeS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t hoitomenot omassa osakeasunnossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015HoitomenoOmaOsakeS(hoitomeno, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	%As2015KattovuokraS(kattovuokra, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm);

	&tulos = MIN(hoitomeno, &OmAsHoitomenoOsuus * kattovuokra);

	DROP hoitomeno kattovuokra;

%MEND As2015HyvHoitomenoOmaOsakeS;


/* 25. Rahoitusmenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, rahoitusmenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk  
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */
	
%MACRO As2015RahoitusmenoOmaOsakeS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Rahoitusmenot omassa osakeasunnossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015HoitomenoOmaOsakeTodS(hoitomenotod, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	%As2015HoitomenoOmaOsakeS(hoitomeno, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	%As2015HyvHoitomenoOmaOsakeS(hyvhoitomeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	ylithoitomeno = SUM(hoitomeno, -hyvhoitomeno);

	huomylithoitomeno = &KorkoTukiPros * ylithoitomeno;

	%As2015KorkomenoS(korkomeno, &mvuosi, &mkuuk, &korko);

	eipyorrahoitusmeno = SUM(huomylithoitomeno, korkomeno);

	%PyoristysSentinTarkkuuteen(rahoitusmeno, eipyorrahoitusmeno);

	IF hoitomenotod < 0 THEN rahoitusmeno = rahoitusmeno - (-1) * hoitomenotod;

	IF rahoitusmeno < 0 THEN rahoitusmeno = 0;

	&tulos = rahoitusmeno; 

	DROP hoitomenotod hoitomeno hyvhoitomeno ylithoitomeno huomylithoitomeno korkomeno
	eipyorrahoitusmeno rahoitusmeno;

%MEND As2015RahoitusmenoOmaOsakeS;


/* 26. Hyv‰ksytt‰v‰t rahoitusmenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t rahoitusmenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk 
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015HyvRahoitusmenoOmaOsakeS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t rahoitusmenot omassa osakeasunnossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015RahoitusmenoOmaOsakeS(rahoitusmeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma, &korko);

	%As2015KattovuokraS(kattovuokra, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm);

	&tulos = MIN(rahoitusmeno, &OmAsRahoitusmenoOsuus * kattovuokra);

	DROP rahoitusmeno kattovuokra;

%MEND As2015HyvRahoitusmenoOmaOsakeS;


/* 27. Hyv‰ksytt‰v‰t asumismenot omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t asumismenot omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015HyvAsumismenoOmaOsakeS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t asumismenot omassa osakeasunnossa";

	%As2015HyvHoitomenoOmaOsakeS(hyvhoitomeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma);

	%As2015HyvRahoitusmenoOmaOsakeS(hyvrahoitusmeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma, &korko);

	&tulos = SUM(hyvhoitomeno, hyvrahoitusmeno);

	DROP hyvhoitomeno hyvrahoitusmeno;

%MEND As2015HyvAsumismenoOmaOsakeS;


/* 28. Asumistuki kuukaudessa omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki kuukaudessa omassa osakeasunnossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk 
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk 
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */

%MACRO As2015AsumistukiOmaOsakeKS(tulos, mvuosi, mkuuk, minf, kuntaryhma, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, korko, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki kuukaudessa omassa osakeasunnossa";

	%As2015HyvAsumismenoOmaOsakeS(hyvasumismeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, (&aikuistenlkm + &lastenlkm), &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma, &korko);

	%As2015PerusomavastuuS(perusomavastuu, &mvuosi, &mkuuk, &minf, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);

	%As2015PeruskaavaS(asumistuki, &mvuosi, &mkuuk, &minf, hyvasumismeno, perusomavastuu);

	&tulos = asumistuki;

	DROP astukitulot hyvasumismeno perusomavastuu asumistuki;

%MEND As2015AsumistukiOmaOsakeKS;


/* 29. Asumistuki vuosikeskiarvona omassa osakeasunnossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki vuosikeskiarvona omassa osakeasunnossa, e/v 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		vastike: Hoito- ja rahoitusvastike yhteens‰, e/kk
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk 
		erillinenvesi: Maksetaanko vesimaksut erill‰‰n vuokrasta, 0/1
		erillinenlampo: Maksetaanko l‰mmitysmenot erill‰‰n vuokrasta, 0/1 
		lisakustannusryhma: L‰mmitysmenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk 
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */

%MACRO As2015AsumistukiOmaOsakeVS(tulos, mvuosi, minf, kuntaryhma, vammaistenlkm, vastike, alivuokralaisenvuokra, erillinenvesi, erillinenlampo, lisakustannusryhma, korko, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki vuosikeskiarvona omassa osakeasunnossa";

	asvuosi = 0;

	%DO kuuk=1 %TO 12;
		%As2015AsumistukiOmaOsakeKS(askk, &mvuosi, &kuuk, &minf, &kuntaryhma, &vammaistenlkm, &vastike, &alivuokralaisenvuokra, &erillinenvesi, &erillinenlampo, &lisakustannusryhma, &korko, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);
		asvuosi = SUM(asvuosi, askk); 
	%END;

	asvuosi = asvuosi / 12;

	&tulos = asvuosi;

	DROP askk asvuosi;

%MEND As2015AsumistukiOmaOsakeVS;


/* 30. Hyv‰ksytt‰v‰t hoitomenot */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t hoitomenot, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015HoitonormiS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, lisakustannusryhma) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t hoitomenot";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_MUUNNOS, &minf);

	%PyoristysEuronTarkkuuteen(oktalohnormi1_lk1, (1 + &HuomLampoHNormiKor1) * &OKTaloHNormi1);
	%PyoristysEuronTarkkuuteen(oktalohnormi2_lk1, (1 + &HuomLampoHNormiKor1) * &OKTaloHNormi2);
	%PyoristysEuronTarkkuuteen(oktalohnormi3_lk1, (1 + &HuomLampoHNormiKor1) * &OKTaloHNormi3);
	%PyoristysEuronTarkkuuteen(oktalohnormi4_lk1, (1 + &HuomLampoHNormiKor1) * &OKTaloHNormi4);
	%PyoristysEuronTarkkuuteen(oktalohnormiplus_lk1, (1 + &HuomLampoHNormiKor1) * &OKTaloHNormiPlus);

	%PyoristysEuronTarkkuuteen(oktalohnormi1_lk2, (1 + &HuomLampoHNormiKor2) * &OKTaloHNormi1);
	%PyoristysEuronTarkkuuteen(oktalohnormi2_lk2, (1 + &HuomLampoHNormiKor2) * &OKTaloHNormi2);
	%PyoristysEuronTarkkuuteen(oktalohnormi3_lk2, (1 + &HuomLampoHNormiKor2) * &OKTaloHNormi3);
	%PyoristysEuronTarkkuuteen(oktalohnormi4_lk2, (1 + &HuomLampoHNormiKor2) * &OKTaloHNormi4);
	%PyoristysEuronTarkkuuteen(oktalohnormiplus_lk2, (1 + &HuomLampoHNormiKor2) * &OKTaloHNormiPlus);

	IF &lisakustannusryhma = 0 THEN DO;
		SELECT(&ruokakunnankoko);
			WHEN(1) hnormiyht = &OKTaloHNormi1;
			WHEN(2) hnormiyht = &OKTaloHNormi2;
			WHEN(3) hnormiyht = &OKTaloHNormi3;
			WHEN(4) hnormiyht = &OKTaloHNormi4;
			OTHERWISE hnormiyht = &OKTaloHNormi4 + &OKTaloHNormiPlus * (&ruokakunnankoko - 4);
		END;
	END;
	ELSE IF &lisakustannusryhma = 1 THEN DO;
		SELECT(&ruokakunnankoko);
			WHEN(1) hnormiyht = oktalohnormi1_lk1;
			WHEN(2) hnormiyht = oktalohnormi2_lk1;
			WHEN(3) hnormiyht = oktalohnormi3_lk1;
			WHEN(4) hnormiyht = oktalohnormi4_lk1;
			OTHERWISE hnormiyht = oktalohnormi4_lk1 + oktalohnormiplus_lk1 * (&ruokakunnankoko - 4);
		END;
	END;
	ELSE IF &lisakustannusryhma = 2 THEN DO;
		SELECT(&ruokakunnankoko);
			WHEN(1) hnormiyht = oktalohnormi1_lk2;
			WHEN(2) hnormiyht = oktalohnormi2_lk2;
			WHEN(3) hnormiyht = oktalohnormi3_lk2;
			WHEN(4) hnormiyht = oktalohnormi4_lk2;
			OTHERWISE hnormiyht = oktalohnormi4_lk2 + oktalohnormiplus_lk2 * (&ruokakunnankoko - 4);
		END;
	END;

	&tulos = hnormiyht;

	DROP oktalohnormi1_lk1 oktalohnormi2_lk1 oktalohnormi3_lk1 oktalohnormi4_lk1 oktalohnormiplus_lk1
	oktalohnormi1_lk2 oktalohnormi2_lk2 oktalohnormi3_lk2 oktalohnormi4_lk2 oktalohnormiplus_lk2
	hnormiyht;

%MEND As2015HoitonormiS;


/* 31. Todelliset hoitomenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, todelliset hoitomenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */ 

%MACRO As2015HoitomenoOmaTaloTodS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, alivuokralaisenvuokra, lisakustannusryhma) /
DES = "ASUMTUKI: Todelliset hoitomenot omassa omakotitalossa";

	%As2015HoitonormiS(hoitonormi, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &lisakustannusryhma);

	&tulos = SUM(hoitonormi, -&alivuokralaisenvuokra);

	DROP hoitonormi;
	
%MEND As2015HoitomenoOmaTaloTodS;


/* 32. Hoitomenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hoitomenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */ 

%MACRO As2015HoitomenoOmaTaloS(tulos, mvuosi, mkuuk, minf, ruokakunnankoko, alivuokralaisenvuokra, lisakustannusryhma) /
DES = "ASUMTUKI: Hoitomenot omassa omakotitalossa";

	%As2015HoitomenoOmaTaloTodS(hoitomenotod, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &alivuokralaisenvuokra, &lisakustannusryhma);

	IF hoitomenotod < 0 THEN &tulos = 0;
	ELSE &tulos = hoitomenotod;

	DROP hoitomenotod;

%MEND As2015HoitomenoOmaTaloS;


/* 33. Hyv‰ksytt‰v‰t hoitomenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t hoitomenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰) */	

%MACRO As2015HyvHoitomenoOmaTaloS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t hoitomenot omassa omakotitalossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015HoitomenoOmaTaloS(hoitomeno, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &alivuokralaisenvuokra, &lisakustannusryhma);

	%As2015KattovuokraS(kattovuokra, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm);

	&tulos = MIN(hoitomeno, &OmAsHoitomenoOsuus * kattovuokra);

	DROP hoitomeno kattovuokra;

%MEND As2015HyvHoitomenoOmaTaloS;


/* 34. Rahoitusmenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, rahoitusmenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
						(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015RahoitusmenoOmaTaloS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Rahoitusmenot omassa omakotitalossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015HoitomenoOmaTaloTodS(hoitomenotod, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &alivuokralaisenvuokra, &lisakustannusryhma);

	%As2015HoitomenoOmaTaloS(hoitomeno, &mvuosi, &mkuuk, &minf, &ruokakunnankoko, &alivuokralaisenvuokra, &lisakustannusryhma);

	%As2015HyvHoitomenoOmaTaloS(hyvhoitomeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma);

	ylithoitomeno = SUM(hoitomeno, -hyvhoitomeno);

	huomylithoitomeno = &KorkoTukiPros * ylithoitomeno;

	%As2015KorkomenoS(korkomeno, &mvuosi, &mkuuk, &korko);

	eipyorrahoitusmeno = SUM(huomylithoitomeno, korkomeno);

	%PyoristysSentinTarkkuuteen(rahoitusmeno, eipyorrahoitusmeno);

	IF hoitomenotod < 0 THEN rahoitusmeno = rahoitusmeno - (-1) * hoitomenotod;

	IF rahoitusmeno < 0 THEN rahoitusmeno = 0;

	&tulos = rahoitusmeno;

	DROP hoitomenotod hoitomeno hyvhoitomeno ylithoitomeno huomylithoitomeno korkomeno
	eipyorrahoitusmeno rahoitusmeno;

%MEND As2015RahoitusmenoOmaTaloS;


/* 35. Hyv‰ksytt‰v‰t rahoitusmenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t rahoitusmenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015HyvRahoitusmenoOmaTaloS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t rahoitusmenot omassa omakotitalossa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &ASUMTUKI_PARAM, PARAM.&PASUMTUKI);

	%As2015RahoitusmenoOmaTaloS(rahoitusmeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma, &korko);

	%As2015KattovuokraS(kattovuokra, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm);

	&tulos = MIN(rahoitusmeno, &OmAsRahoitusmenoOsuus * kattovuokra);

	DROP rahoitusmeno kattovuokra; 

%MEND As2015HyvRahoitusmenoOmaTaloS;


/* 36. Hyv‰ksytt‰v‰t asumismenot omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, hyv‰ksytt‰v‰t asumismenot omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		ruokakunnankoko: Ruokakunnan j‰senten lukum‰‰r‰
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk */

%MACRO As2015HyvAsumismenoOmaTaloS(tulos, mvuosi, mkuuk, minf, kuntaryhma, ruokakunnankoko, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma, korko) /
DES = "ASUMTUKI: Hyv‰ksytt‰v‰t asumismenot omassa omakotitalossa";

	%As2015HyvHoitomenoOmaTaloS(hyvhoitomeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma);

	%As2015HyvRahoitusmenoOmaTaloS(hyvrahoitusmeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, &ruokakunnankoko, &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma, &korko);

	&tulos = SUM(hyvhoitomeno, hyvrahoitusmeno);

	DROP hyvhoitomeno hyvrahoitusmeno;

%MEND As2015HyvAsumismenoOmaTaloS;


/* 37. Asumistuki kuukaudessa omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki kuukaudessa omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */

%MACRO As2015AsumistukiOmaTaloKS(tulos, mvuosi, mkuuk, minf, kuntaryhma, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma, korko, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki kuukaudessa omassa omakotitalossa";

	%As2015HyvAsumismenoOmaTaloS(hyvasumismeno, &mvuosi, &mkuuk, &minf, &kuntaryhma, (&aikuistenlkm + &lastenlkm), &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma, &korko);

	%As2015PerusomavastuuS(perusomavastuu, &mvuosi, &mkuuk, &minf, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);

	%As2015PeruskaavaS(asumistuki, &mvuosi, &mkuuk, &minf, hyvasumismeno, perusomavastuu);

	&tulos = asumistuki;

	DROP astukitulot hyvasumismeno perusomavastuu asumistuki;

%MEND As2015AsumistukiOmaTaloKS;


/* 38. Asumistuki vuosikeskiarvona omassa omakotitalossa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, asumistuki vuosikeskiarvona omassa omakotitalossa, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kuntaryhma: Asumistuen kuntaryhm‰ 
		vammaistenlkm: Vammaisten henkilˆiden lukum‰‰r‰ ruokakunnassa
		alivuokralaisenvuokra: Alivuokralaisen maksama vuokra, e/kk
		lisakustannusryhma: Hoitomenojen korotus er‰iss‰ maakunnissa 
							(0 = ei korotusta, 1 = 1. lis‰korotusryhm‰, 2 = 2. lis‰korotusryhm‰)	
		korko: Asunnon hankkimiseksi ja perusparantamiseksi otettujen lainojen korot, e/kk
		tulot: Ruokakunnan yhteenlasketut bruttotulot ilman opintorahaa, e/kk
		tyotulot: Ruokakunnan jokaisen j‰senen tyˆtulot bruttona ker‰ttyn‰ vektoriin (ARRAY), e/kk
		aikuistenlkm: Ruokakuntaan kuuluvien aikuisten lukum‰‰r‰
		lastenlkm: Ruokakuntaan kuuluvien lasten lukum‰‰r‰
		opinraha: Ruokakunnan yhteens‰ saama opintoraha bruttona, e/kk */	

%MACRO As2015AsumistukiOmaTaloVS(tulos, mvuosi, minf, kuntaryhma, vammaistenlkm, alivuokralaisenvuokra, lisakustannusryhma, korko, tulot, tyotulot, aikuistenlkm, lastenlkm, opinraha = 0) /
DES = "ASUMTUKI: Asumistuki vuosikeskiarvona omassa omakotitalossa";

	asvuosi = 0;

	%DO kuuk=1 %TO 12;
		%As2015AsumistukiOmaTaloKS(askk, &mvuosi, &kuuk, &minf, &kuntaryhma, &vammaistenlkm, &alivuokralaisenvuokra, &lisakustannusryhma, &korko, &tulot, &tyotulot, &aikuistenlkm, &lastenlkm, opinraha = &opinraha);
		asvuosi = SUM(asvuosi, askk); 
	%END;

	asvuosi = asvuosi / 12;

	&tulos = asvuosi;

	DROP askk asvuosi;

%MEND As2015AsumistukiOmaTaloVS;