/********************************************************************
*  Kuvaus: Aineistosimuloinnin tulosten tuottamiseen liittyviä		*
*		   makroja													*
*  Viimeksi päivitetty: 4.8.2020		   					       	*
********************************************************************/

/*
SISÄLLYS:

KokoTulokset - Makro joka ajaa perustaulukot annetusta datasta
SumKotitT - Makro joka summaa henkilötason tulokset kotitaloustasolle
Desiilit - Makro tulodesiilien uudelleenlaskentaan
KoyhInd - Tulonjakoindikaattorit laskeva makro
*/


/*
Makro joka ajaa perustaulukot annetusta datasta

Makron parametrit:

	MISTA - ohjausparametri joka kertoo kutsutaanko makroa simulointimallista vai suoraan
	MALLINIMI - malli jolla taulukoitava aineisto on tuotettu
	TAIN - taulukoitavan aineiston nimi
	TASO - onko aineisto
		1 - henkilötasolla
		2 - kotitaloustasolla
		3 - tulonjakoindikaattoriaineisto
*/

%MACRO KokoTulokset(MISTA, MALLINIMI, TAIN, TASO)/
DES = "TulosMakrot: Perustaulukoiden tuottaminen annetusta datasta";

/* Tulonjakoindikaattoreiden lyhyttä excel nimeä varten muuttuja TAINLYH, jossa on jätetty
kirjaston nimi pois. */

	%LET TAINLYH=%SUBSTR(&TAIN,8,%EVAL(%LENGTH(&TAIN)-7));

/* Tulonjakoindikaattorieiden tulostus */

%IF &TASO=3 %THEN %DO;

	%IF &EXCEL = 1 %THEN %DO;
		ODS HTML3 PATH = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT" FILE="&TAINLYH..xls" STYLE = MINIMAL;
	%END;

	/* Tulostetaan indikaattorit SAS:n outputtiin */

	PROC PRINT DATA = &TAIN NOOBS LABEL;
	TITLE1 "TULONJAKOINDIKAATTOREITA, KOKOMALLI";
	TITLE2 "TULOKÄSITE: &TULO";
	FORMAT AOSU commax15.2 RLKM tuhat.;
	RUN;

	%IF &EXCEL = 1 %THEN %DO;

		ODS HTML3 CLOSE;

	%END;

%END;


/* Kotitaloustason tulokset (optio) */

%IF &TASO=2 %THEN %DO;

	%LET TASONIMI=KOTITALOUSTASO;
	%LET TASON=KOTI;

%END;

%ELSE %IF &TASO=1 %THEN %DO;

	%LET TASONIMI=HENKILÖTASO;
	%LET TASON=HLO;

%END;

	/* Summatason tulostaulukko (optio) */

%IF &TASO=1 OR &TASO=2 %THEN %DO;

	%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 PATH = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT" FILE="&TAINLYH._S.xls" STYLE = MINIMAL;

	%END;
	
	ODS NOPROCTITLE;

	PROC MEANS DATA=&TAIN &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0 STACKODS;
	TITLE "TUNNUSLUVUT (&TASONIMI), &MALLINIMI";
	CLASS &&LUOK_&TASON.1 &&LUOK_&TASON.2 &&LUOK_&TASON.3 / MLF PRELOADFMT;
	VAR &MUUTTUJAT ;
	FORMAT _NUMERIC_ tuhat.;
	%DO I = 1 %TO 3;
		%IF %LENGTH (&&LUOK_&TASON&I) >0 %THEN %DO;
			/* Viedään luokittelevan muuttujan tyypin tunnus makromuuttujaan VARTYPE */
			%LET DSID = %SYSFUNC(OPEN(&TAIN));
			%LET VARNUM = %SYSFUNC(VARNUM(&DSID, &&LUOK_&TASON&I));
			%LET VARTYPE = %SYSFUNC(VARTYPE(&DSID, &VARNUM));
			%LET RC = %SYSFUNC(CLOSE(&DSID));
			/* Jos luokitteleva muuttuja on numeerinen, annetaan numeerinen formaatti */
			%IF &VARTYPE = N %THEN %DO;
				FORMAT &&LUOK_&TASON&I &&LUOK_&TASON&I... ;
			%END;
			/* Jos luokitteleva muuttuja on tekstimuotoinen, annetaan tekstimuotoinen formaatti */
			%IF &VARTYPE = C %THEN %DO;
				FORMAT &&LUOK_&TASON&I $&&LUOK_&TASON&I... ;
			%END;
		%END;
	%END;
	ODS OUTPUT SUMMARY = &TAIN._S;
	WHERE &RAJAUS;
	WEIGHT &PAINO;
	RUN;

	ODS PROCTITLE;

	%IF &EXCEL = 1 %THEN %DO;

		ODS HTML3 CLOSE;

	%END;

%END;

%MEND KokoTulokset;


/*
Makro joka summaa henkilötason tulokset kotitaloustasolle

Makron parametrit:

	TULOS = Tuotettavan tulostiedoston nimi
	SISAAN = Summattava henkilötason tiedosto
	KUTSMALLI = Malli, josta makroa kutsutaan
	MJAT = Summataulukossa taulukoitavat muuttujat

*/

%MACRO SumKotitT(TULOS, SISAAN, KUTSMALLI, MJAT)/
DES = "TulosMakrot: Henkilötason tulosten summaus kotitaloustasolle";

	%IF &KUTSMALLI=KOKO %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta jasenia kulyks modoecd DESMOD_MALLI;;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=VERO %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=TOIMTUKI %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=OPINTUKI %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=TTURVA %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=SAIRVAK %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=KOTIHTUKI %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=LLISA %THEN %DO;
		%LET SUMMAUS=0;
	%END;

	%IF &KUTSMALLI=KANSEL %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=KIVERO %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=ASUMTUKI %THEN %DO;
		%LET SUMMAUS=0;
	%END;

	%IF &KUTSMALLI=ELASUMTUKI %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &KUTSMALLI=PHOITO %THEN %DO;
		%LET KIDRYHMA=&PAINO ikavuv desmod paasoss elivtu koulas koulasv rake maakunta;
		%LET DRYHMA=_TYPE_ _FREQ_;
		%LET SUMMAUS=1;
	%END;

	%IF &SUMMAUS=1 %THEN %DO;
		PROC SUMMARY DATA=&sisaan(DROP = hnro);
			BY knro;
			ID &KIDRYHMA;
			VAR &MJAT;
			OUTPUT OUT = &tulos (DROP = &DRYHMA)  SUM = ;
		RUN;
	%END;

%MEND SumKotitT;


/*
Makro tulodesiilien uudelleenlaskentaan

Makron parametrit:
	id: Yksikkötunniste (kotitalous/asuntokunta, aina knro)
	tulo: Datan tulo-/varallisuus- tms. -muuttuja, jonka mukaiset desiilit lasketaan
	jasenia: Datan muuttuja, joka kertoo kotitalouden jäsenmäärän
	kuluyks: Datan muuttuja, joka kertoo kulutusyksiköiden lukumäärän
	paino: Painokerroin
	sisaan: Aineisto, josta laskenta tehdään
	luokittelu: muodostettavan luokittelevan muuttujan nimi. Oletuksena DESMOD_MALLI
*/

%MACRO Desiilit(id, tulo, jasenia, kuluyks, paino, sisaan, luokittelu = DESMOD_MALLI)/
DES = 'TulosMakrot: Tulodesiilit laskeva makro';

/* Asetetaan painoksi 1 jos painokerroin ei käytössä (parametrin arvo = tyhjä) */
	%IF &PAINO= %THEN %DO;
	DATA &sisaan;
		SET &sisaan;
		eikor = 1; 
	RUN;
	%LET PAINO = eikor;
	%END;

/* Muodostetaan laskentatiedosto kotitaloustasolle */

PROC SQL; 
CREATE VIEW _LASKE AS SELECT &ID, &JASENIA, max(&KULUYKS)/10 AS KULUYKS, &PAINO, 
&JASENIA*&PAINO AS WK, SUM(&TULO) AS TULO
FROM &sisaan 
GROUP BY &ID 
ORDER BY &ID;
QUIT;

DATA _LASKE1/VIEW=_LASKE1; 
SET _LASKE; 
	BY &ID;
	IF FIRST.&ID;
	%IF &KULUYKS = JASENIA %THEN %DO; 
    KULUYKS = 10*KULUYKS; %END;       
	ETULO = MAX((TULO/KULUYKS), 0);
RUN;

/* Lasketaan desiilien rajat */

PROC UNIVARIATE DATA = _LASKE1 NOPRINT;
VAR ETULO;
WEIGHT WK;
OUTPUT OUT = _DESIILIT
PCTLPTS = 10 TO 90 BY 10 PCTLPRE = DES;
RUN;

/* Viedään desiilien rajat makromuuttujiksi */
%GLOBAL DES10 DES20 DES30 DES40 DES50 DES60 DES70 DES80 DES90;

PROC SQL NOPRINT;
SELECT DES10, DES20, DES30, DES40, DES50, DES60, DES70, DES80, DES90
INTO :DES10, :DES20, :DES30, :DES40, :DES50, :DES60, :DES70, :DES80, :DES90
FROM _DESIILIT;
QUIT;

/* Määritellään uudet desiilit kotitalouksille */

DATA _LASKE2; 
SET _LASKE1;
IF ETULO <= &DES10 THEN &luokittelu = 0;
ELSE IF ETULO <= &DES20 THEN &luokittelu = 1;
ELSE IF ETULO <= &DES30 THEN &luokittelu = 2;
ELSE IF ETULO <= &DES40 THEN &luokittelu = 3;
ELSE IF ETULO <= &DES50 THEN &luokittelu = 4;
ELSE IF ETULO <= &DES60 THEN &luokittelu = 5;
ELSE IF ETULO <= &DES70 THEN &luokittelu = 6;
ELSE IF ETULO <= &DES80 THEN &luokittelu = 7;
ELSE IF ETULO <= &DES90 THEN &luokittelu = 8;
ELSE &luokittelu = 9;
DROP KULUYKS &jasenia &paino wk tulo etulo;
RUN;

/* Viedään uusi muuttuja dataan */
DATA &SISAAN; 
MERGE &SISAAN _LASKE2;
BY &ID;
LABEL
&luokittelu = 'Käytettävissä olevien tulojen desiiliryhmä, MALLI';
RUN;

PROC DATASETS LIB = WORK NOLIST;
	DELETE _: /MEMTYPE = VIEW;
	DELETE _: /MEMTYPE = DATA;
RUN;QUIT;

%MEND Desiilit;


/*
Tulonjakoindikaattorit laskeva makro

Makron parametrit:
	rajat: Laskettavien köyhyysrajojen määrä
	rajaN: Parametri jokaiselle köyhyysrajalle, joka kertoo rajan osuuden mediaanista
	sisaan: Aineisto, josta laskenta tehdään
	jasenia: Datan muuttuja, joka kertoo kotitalouden jäsenmäärän
	paino: Painokerroin
	tulot: Datan tulomuuttuja, josta tulot lasketaan
	kuluyks: Datan muuttuja, joka kertoo kulutusyksiköiden lukumäärän
	id: Yksikkötunniste (kotitalous/asuntokunta, aina knro)
	desit: Desiilimuuttuja (yleensä DESMOD_MALLI)
	destu: Tulostetaanko desiilien tulo-osuudet (1 jos tulostetaan)
*/

%MACRO KoyhInd(rajat, raja1, raja2, raja3, sisaan, jasenia, paino, tulot, kuluyks, id, desit, destu)/
DES = 'TulosMakrot: Tulonjakoindikaattorit laskeva makro';

/* Asetetaan painoksi 1 jos painokerroin ei käytössä (parametrin arvo = tyhjä) */
	%IF &PAINO= %THEN %DO;
	DATA &sisaan;
		SET &sisaan;
		eikor = 1; 
	RUN;
	%LET PAINO = eikor;
	%END;

/* 1. Määritetään tulostaulukon nimi */

%LET OUTP = OUTPUT.&TULOSNIMI_KOKO._IND;

/* 2. Haetaan tiedostosta &sisaan laskentaan tarvittavat tiedot laskentatauluksi */

PROC SQL;
	CREATE VIEW _LASKU AS SELECT
	1 as lkm, a.&id, max(a.&kuluyks)/10 as kuluyks, sum(a.&tulot) as tulot, a.&paino*a.&jasenia as wk, a.&paino, 
	a.&jasenia as jasenia, c.lapset, b.vanhat, d.tyolliset, e.eityol, f.miehet, g.naiset, a.&desit
	FROM &sisaan AS a
	LEFT JOIN (SELECT &id, COUNT(hnro) AS vanhat FROM &sisaan WHERE ikavu >= 65 GROUP BY &id) AS b ON a.&id = b.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS lapset FROM &sisaan WHERE ikavu <= 17 GROUP BY &id) AS c on a.&id = c.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS tyolliset FROM &sisaan WHERE (soss between 10 and 59) and (ikavu between 18 and 64) GROUP BY &id) AS d ON a.&id = d.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS eityol FROM &sisaan WHERE (soss between 60 and 99) and (ikavu between 18 and 64) GROUP BY &id) AS e ON a.&id = e.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS miehet FROM &sisaan WHERE catt(sp) = "1" GROUP BY &id) AS f ON a.&id = f.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS naiset FROM &sisaan WHERE catt(sp) = "2" GROUP BY &id) AS g ON a.&id = g.&id

	GROUP BY a.&id
	ORDER BY a.&id;
	QUIT;

DATA _LASK1/VIEW=_LASK1; 
	SET _LASKU;
	BY &ID;
	IF FIRST.&ID;
	%if &kuluyks = jasenia %then %do;
		kuluyks = 10*kuluyks;
	%end;
	etulo = tulot/kuluyks;
RUN;

/* 3. Lasketaan mediaanitulo &tulot-muuttujasta tiedostoon med */

PROC UNIVARIATE DATA = _LASK1 NOPRINT;
	VAR etulo; WEIGHT wk; 
	OUTPUT OUT = _MED PCTLPTS = 50 PCTLPRE = med;
RUN;

/* 4. Tallennetaan valitut köyhyysrajat makromuuttujiksi */

%DO i = 1 %TO &rajat; 
	PROC SQL NOPRINT; 
		SELECT (&&raja&i/100)*(med50)
		INTO :absoraja&i FROM _MED;
	QUIT;
%END;

/* 5. Merkitään laskentatauluun köyhyysrajat
	ja lasketaan rajojen alapuolella oleville erotus tulojen ja rajan välillä */

DATA _LASK;
	SET _LASK1;
	%DO i = 1 %TO &rajat;
		IF &&absoraja&i > etulo THEN DO;
			koy&&raja&i = 1;
			ero&&raja&i = SUM(&&absoraja&i, -etulo);
		END;
	%END;
RUN;

/* 6. Lasketaan köyhyysrajojen alapuolella olevien mediaani- ja keskitulot tauluihin */

%DO i = 1 %TO &rajat;
	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) MEAN MEDIAN MAXDEC=0 NOPRINT; 
		VAR etulo;
		WEIGHT wk;
		OUTPUT OUT = _RMN&i MEAN(etulo) = R&&raja&i;
		OUTPUT OUT = _RMD&i MEDIAN(etulo) = R&&raja&i;
	RUN;

	PROC SQL NOPRINT;
		SELECT R&&raja&i 
		INTO :KMD&i FROM _RMD&i;
	QUIT; 
%END;


/* 7. Lasketaan henkilömäärät niissä ryhmissä, joille halutaan tuottaa köyhyysasteet */

%DO i = 1 %TO &rajat;
	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
		VAR lapset vanhat tyolliset eityol miehet naiset; 
		WEIGHT &PAINO; 
		OUTPUT OUT = _PLA&i SUM(lapset) = R&&raja&i;
		OUTPUT OUT = _PVA&i SUM(vanhat) = R&&raja&i;
		OUTPUT OUT = _TYO&i SUM(tyolliset) = R&&raja&i;
		OUTPUT OUT = _ETY&i SUM(eityol) = R&&raja&i;
		OUTPUT OUT = _M&i SUM(miehet) = R&&raja&i;
		OUTPUT OUT = _N&i SUM(naiset) = R&&raja&i;
	RUN;

	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
		VAR lkm; 
		WEIGHT wk; 
		OUTPUT OUT = _K&i SUM(lkm) = R&&raja&i;
	RUN;

%END;

/* 8. Tallennetaan totaalilukuja makromuuttujiksi köyhyysasteiden laskentaa varten */

PROC SQL NOPRINT;
	SELECT SUM(vanhat*&PAINO), SUM(lapset*&PAINO), SUM(tyolliset*&PAINO), SUM(eityol*&PAINO), SUM(miehet*&PAINO), SUM(naiset*&PAINO), SUM(lkm*wk)
		INTO :VANH, :LAPS, :TYOL, :EITYOL, :MIEHET, :NAISET, :LKM FROM _LASK;
	%DO i = 1 %TO &rajat; 
		SELECT R&&raja&i INTO :KLKM&i FROM _K&i;
	%END;
QUIT;

/* 9. Lasketaan ginikerroin, keskitulo, ja mediaanitulo ensimmäisille riveille */

/* Ginikerroin kovarianssikaavalla */
PROC SORT DATA=_LASK OUT=_GINIPOHJA;
	BY etulo;
RUN;

DATA _GINIPOHJA;
	SET _GINIPOHJA;
	r + wk;
	KEEP etulo wk r;
RUN;

PROC CORR DATA=_GINIPOHJA NOPRINT COV VARDEF=WGT OUTP=_GINICOV;
	VAR r etulo;
	WEIGHT wk;
RUN;

PROC TRANSPOSE DATA=_GINICOV (WHERE=(%UPCASE(_NAME_) NE 'etulo')) OUT=_GINICOV2;
	ID _TYPE_;
RUN;

DATA _GINILASK;
	SET _GINICOV2;
	WHERE %UPCASE(_NAME_) EQ 'etulo';
	G=2*COV/SUMWGT/MEAN;
RUN;

PROC SQL NOPRINT;
	SELECT G 
	INTO :GINI FROM _GINILASK;
QUIT;

/* Keski- ja mediaanitulo */
PROC UNIVARIATE DATA = _LASK NOPRINT;
	VAR etulo;
	WEIGHT wk;
	OUTPUT OUT = _MEANMED mean = MeantuPOP median = MedtuPOP;
RUN;

PROC SQL NOPRINT;
	SELECT MeantuPOP, MedtuPOP 
	INTO :meantupop, :medtupop FROM _MEANMED;
QUIT;

/* 10. Lasketaan indikaattorit */

%DO i = 1 %TO &rajat;

	/* Kirjoitetaan valitut köyhyysrajat tauluun outputtia varten */
	DATA _AR&i;
		LENGTH Otsikko $50;
		Otsikko = "Pienituloisuusraja, &&Raja&i % mediaanitulosta";
		RLKM = ROUND((&&absoraja&i), 1);
		OUTPUT;
	RUN;

	/* Keskitulo köyhyysrajan alla */
	DATA _RMN&I;
		SET _RMN&I; 
		LENGTH Otsikko $50;
		Otsikko = "Keskitulo pienituloisuusrajan alla, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
	RUN;

	/* Mediaanitulo köyhyysrajan alla */
	DATA _RMD&I; 
		SET _RMD&I; 
		LENGTH Otsikko $50;
		Otsikko = "Mediaanitulo pienituloisuusrajan alla, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
	RUN;

	/* Lasketaan köyhien lukumäärä sekä köyhyysaste */
	DATA _POP&i;
		LENGTH Otsikko $50;
		Otsikko = "Pienituloiset ja pienituloisuusaste, &&Raja&i %";
		RLKM = ROUND(&&KLKM&i, 1);
		AOSU = ROUND((100 * (&&KLKM&i / &lkm)), .01);
		OUTPUT;
	RUN;

	/* Lasketaan köyhyysvaje köyhien mediaanitulon osuutena populaation mediaanitulosta */
	DATA _VAJ&i;
		LENGTH Otsikko $50;
		Otsikko = "Köyhyysvaje ja osuus pienituloisuusrajasta, &&Raja&i %";
		RLKM = ROUND(SUM(&&absoraja&i, -&&KMD&i), 1);
		AOSU = ROUND((100 * (RLKM / &&absoraja&i)), .01);
		OUTPUT;
	RUN;

	/* Alle 18-vuotiaiden köyhyysasteet */
	DATA _PLA&i;
		SET _PLA&i; 
		LENGTH Otsikko $50;
		Otsikko = "Alle 18 pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &laps)), .01);
	RUN;

	/* 65 vuotta täyttäneiden köyhyysasteet */
	DATA _PVA&i;
		SET _PVA&i; 
		LENGTH Otsikko $50;
		Otsikko = "65+ pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &vanh)), .01);
	RUN;

	/* Työllisten köyhyysasteet */
	DATA _TYO&i;
		SET _TYO&i; 
		LENGTH Otsikko $50;
		Otsikko ="Työlliset pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &tyol)), .01);
	RUN;

	/* Ei-Työllisten köyhyysasteet */
	DATA _ETY&i;
		SET _ETY&i; 
		LENGTH Otsikko $50;
		Otsikko ="Ei-työlliset pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &eityol)), .01);
	RUN;

	/* Miesten köyhyysasteet */
	DATA _M&i;
		SET _M&i; 
		LENGTH Otsikko $50;
		Otsikko ="Miehet pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &miehet)), .01);
	RUN;

	/* Naisten köyhyysasteet */
	DATA _N&i;
		SET _N&i; 
		LENGTH Otsikko $50;
		Otsikko ="Naiset pienituloisissa talouksissa, &&Raja&i %";
		RLKM = ROUND(R&&raja&i, 1);
		AOSU = ROUND((100 * (R&&raja&i / &naiset)), .01);
	RUN;
		
%END;

DATA _POPMN; 
	LENGTH Otsikko $50;
	Otsikko = "Keskitulo / kulutusyksikkö";
	RLKM = ROUND(&MeantuPOP, 1);
	OUTPUT;
RUN;

DATA _POPMD; LENGTH Otsikko $50;
	Otsikko = "Mediaanitulo / kulutusyksikkö";
	RLKM = ROUND(&MedtuPOP, 1);
	OUTPUT;
RUN;

DATA _GINI; 
	LENGTH Otsikko $50;
	Otsikko = "Populaatio ja Gini-kerroin";
	RLKM = ROUND(&lkm, 1);
	AOSU = ROUND(100 * &GINI, .01);
	OUTPUT;
RUN;

/* 11. Viedään tiedot &OUTP-dataan */

DATA &OUTP;
	SET _GINI _POPMN _POPMD
	%DO i = 1 %TO &rajat; _AR&i %END;
	%DO i = 1 %TO &rajat; _RMN&i %END;
	%DO i = 1 %TO &rajat; _RMD&i %END;
	%DO i = 1 %TO &rajat; _POP&i %END;
	%DO i = 1 %TO &rajat; _VAJ&i %END;
	%DO i = 1 %TO &rajat; _PLA&i %END;
	%DO i = 1 %TO &rajat; _PVA&i %END;
	%DO i = 1 %TO &rajat; _TYO&i %END;
	%DO i = 1 %TO &rajat; _ETY&i %END;
	%DO i = 1 %TO &rajat; _M&i %END;
	%DO i = 1 %TO &rajat; _N&i %END;
	;
	LABEL RLKM = "Euroa / lukumäärä" AOSU = "Suhdeluku / %-osuus";
	FORMAT RLKM tuhat.;
	KEEP Otsikko RLKM AOSU;
RUN;

/* 12. Desiilien tulo-osuudet */

%IF &destu = 1 %THEN %DO;

	/* Lasketaan desiilien rajat ja viedään ne makromuuttujiksi */	

	PROC UNIVARIATE DATA = _LASK NOPRINT;
		VAR ETULO;
		WEIGHT wk;   
		OUTPUT OUT = _DESIILIT
		PCTLPTS = 10 TO 90 BY 10 PCTLPRE = DES;
	RUN;

	PROC SQL NOPRINT;
		SELECT DES10, DES20, DES30, DES40, DES50, DES60, DES70, DES80, DES90
		INTO :DES10, :DES20, :DES30, :DES40, :DES50, :DES60, :DES70, :DES80, :DES90
		FROM _DESIILIT;
	QUIT;

	/* Lasketaan desiilien tulo-osuudet */

	PROC MEANS DATA = _LASK NOPRINT; 
		VAR ETULO; CLASS &desit; 
		WEIGHT wk;
		OUTPUT OUT = _DESTEMP SUM=;
	RUN;

	PROC SQL NOPRINT; 
		SELECT ETULO INTO :TOT FROM _DESTEMP WHERE &desit = .;
	QUIT;

	/* Viedän desiilien tiedot tauluksi */

	DATA _DESTEMP; 
		SET _DESTEMP (DROP = _TYPE_ _FREQ_);
		LENGTH Otsikko $50;	
		IF &desit = . THEN DELETE;
		AOSU = ROUND((100 * ETULO / &TOT), 0.01);
		RLKM = ROUND(ETULO, 1);
		IF &desit = 0 THEN Otsikko = "1. desiilin tulot / kulutusyksikkö ja tulo-osuus"; 
		ELSE IF &desit = 1 THEN DO; Otsikko = "2. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES10;END;
		ELSE IF &desit = 2 THEN DO; Otsikko = "3. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES20;END;
		ELSE IF &desit = 3 THEN DO; Otsikko = "4. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES30;END;
		ELSE IF &desit = 4 THEN DO; Otsikko = "5. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES40;END;
		ELSE IF &desit = 5 THEN DO; Otsikko = "6. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES50;END;
		ELSE IF &desit = 6 THEN DO; Otsikko = "7. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES60;END;
		ELSE IF &desit = 7 THEN DO; Otsikko = "8. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES70;END;
		ELSE IF &desit = 8 THEN DO; Otsikko = "9. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES80;END;
		ELSE DO; Otsikko = "10. desiilin tulot / kulutusyksikkö ja tulo-osuus"; DES = &DES90;
		END;
		LABEL DES = 'Desiilien tulorajat';
		DROP ETULO;
	RUN;

	PROC SQL NOPRINT;
		SELECT AOSU INTO :S10 from _DESTEMP where &desit = 0;
		SELECT SUM(AOSU) INTO :S20 from _DESTEMP where &desit in (0,1);
		SELECT SUM(AOSU) INTO :S80 from _DESTEMP where &desit in (8,9);
		SELECT AOSU INTO :S90 from _DESTEMP where &desit = 9;
	QUIT;

	DATA _OSUUSSUHDE; 
		LENGTH Otsikko $50;
		Otsikko = "Tulo-osuuksien suhde, ylin ja alin 20 % (S80/S20)";
		AOSU = ROUND(&S80 / &S20, .01);
		OUTPUT;
		Otsikko = "Tulo-osuuksien suhde, ylin ja alin 10 % (S90/S10)";
		AOSU = ROUND(&S90 / &S10, .01);
		OUTPUT;
	RUN;

	DATA &OUTP; 
		SET &OUTP _DESTEMP(DROP = &desit) _OSUUSSUHDE;
		FORMAT RLKM tuhat. DES tuhat.;
	RUN;

%END;

/* 13. Poistetaan TEMP-taulut WORK-hakemistosta*/

PROC DATASETS LIBRARY = WORK NOLIST; 
	DELETE _: /MEMTYPE = DATA;
	DELETE _: /MEMTYPE = VIEW;
QUIT;

%MEND KoyhInd;