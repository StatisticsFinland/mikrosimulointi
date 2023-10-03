/* ******************************************************************
* Kuvaus: Summa- tai IND-taulukoiden taulukointiohjelma (simple)	*
* Viimeksi p‰ivitetty: 22.9.2015									*
********************************************************************/

%MACRO Aloitus;
	%LET tulos = WORK.Tulos2; /* Tulostiedoston nimi */

	%LET inputTaulu1 = OUTPUT.vero_simul_2015_BASE1_HLO_S; /* Ensimm‰inen taulu */
	%LET inputTaulu2 = OUTPUT.vero_simul_2015_REF1_HLO_S; /* Toinen liitett‰v‰ taulu */
	
	%LET suff1 = _BASE; /* Jos yhdistet‰‰n useampia tauluna, k‰ytet‰‰n suff1 = ; */
	%LET suff2 = _REF;

	/* Vertailtavat tunnusluvut (sum mean ...) tai IND-tauluissa RLKM AOSU DES */

	%LET tunnusluvut = sum sumwgt;

	/* Yhdist‰miseen k‰ytett‰vien sarakkeiden nimet */

	%LET luokat = DESMOD; /* Syˆt‰ luokat (desmod  rake  ...) siin‰ j‰rjestyksess‰ kuin ne on taulussa */
	%LET byvar = variable; /* Summataulujen oletus = variable. IND-tauluissa k‰yt‰ tyhj‰‰ */

	/* Jos yhdistet‰‰n useampu kuin kaksi taulua, syˆt‰ taulujen nimet: */
 
	%LET inputTaulu3 = ;
	%LET inputTaulu4 = ;
	%LET inputTaulu5 = ;
	%LET suff3 = _3;
	%LET suff4 = _4;
	%LET suff5 = _5;

	%LET excel = 1; 	/* Excel */
	%LET tulosta = 1;
%MEND Aloitus;

%MACRO Taulukoi;
/* Paikalliset muuttujat Aloitus-makroa varten */
%LOCAL tulos inputTaulu1 inputTaulu2 inputTaulu3 inputTaulu4 inputTaulu5
	suff1 suff2 suff3 suff4 suff5 tunnusluvut luokat byvar tulosta color ylemRaja alemRaja
	vertailu excel;

/* Haetaan asetukset */
%Aloitus;

%LaskeSimple(&tulos, &inputTaulu1, &inputTaulu2, &tunnusluvut, &suff1, &suff2,
		byvar = &luokat &byvar);

/* Jos eiv‰t ole tyhji‰, niin */
%DO i = 3 %TO 5;
	%IF %LENGTH(&&inputTaulu&i) > 0 %THEN %DO;

	%LaskeSimple(&tulos, &tulos, &&inputTaulu&i, &tunnusluvut, /* tyhj‰ */, &&suff&i,
		byvar = &luokat &byvar);

	%END;
%END;

PROC SORT DATA = &tulos; BY &luokat &byvar; RUN;

%IF &EXCEL = 1 %THEN %DO;
	%LOCAL EXCEL_NIMI;
	%LET EXCEL_NIMI = %SCAN(&tulos, -1);
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&EXCEL_NIMI..xls" STYLE = MINIMAL;
%END;

/* Asetetaan formaatit. Varoitus: Picture format lyhent‰‰ dataa (tuhat. tuhatdec. miljoona.) */
%IF &tulosta EQ 1 %THEN %DO;
	PROC REPORT DATA = &tulos;
		FORMAT _NUMERIC_ tuhat.;
	RUN;
%END;

%IF &EXCEL = 1 %THEN %DO;
		ODS HTML3 CLOSE;
%END;

%MEND Taulukoi;

%Taulukoi;