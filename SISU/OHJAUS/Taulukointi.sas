/* ******************************************************************
* Kuvaus: Summa- tai IND-taulukoiden taulukointiohjelma				*
* Viimeksi p‰ivitetty: 22.9.2015		                   	   		*
********************************************************************/

%MACRO Aloitus;
	%LET tulos = WORK.Tulos; /* Tulostiedoston nimi */

	%LET inputTaulu1 = OUTPUT.vero_simul_2015_BASE1_HLO_S; /* Ensimm‰inen taulu */
	%LET inputTaulu2 = OUTPUT.vero_simul_2015_REF1_HLO_S; /* Toinen liitett‰v‰ taulu */
	
	%LET suff1 = _BASE; /* Jos yhdistet‰‰n useampia tauluna, k‰ytet‰‰n suff1 = ; */
	%LET suff2 = _REF;

	/* Vertailtavat tunnusluvut (sum mean ...) tai IND-tauluissa RLKM AOSU DES */

	%LET tunnusluvut = sum sumwgt;

	/* Yhdist‰miseen k‰ytett‰vien sarakkeiden nimet */

	%LET luokat = ; /* Syˆt‰ luokat (desmod  rake  ...) siin‰ j‰rjestyksess‰ kuin ne on taulussa */
	%LET byvar = variable; /* Summataulujen oletus = variable. IND-tauluissa k‰yt‰ avain */

	/* Jos yhdistet‰‰n useampu kuin kaksi taulua, syˆt‰ taulujen nimet: */

	%LET inputTaulu3 = ;
	%LET inputTaulu4 = ;
	%LET inputTaulu5 = ;
	%LET suff3 = _3;
	%LET suff4 = _4;
	%LET suff5 = _5;

	%LET excel = 1; 	/* Excel */

	/* Tulostus ja v‰rivaihtoehdot taulukoiden tarkastusta varten */
	%LET tulosta = 1; /* Tulostetaanko tulostaulu proc report = 1 */
	%LET pyor = 1; /* Pyˆristet‰‰nkˆ arvot tulostusvaiheessa, valitse summataulukolle 1, indikaattoreille 0 */
	%LET color = 1; /* K‰ytet‰‰nkˆ v‰rej‰ */
	%LET vertailu = 1; /* Vertaillaanko */
	%LET ylemRaja = 0.02; /* Keltaisen raja, et‰isyys nollasta */
	%LET alemRaja = 0.00001; /* Punaisen raja, et‰isyys nollasta */
%MEND Aloitus;

%MACRO Taulukoi;
/* Paikalliset muuttujat Aloitus-makroa varten */
%LOCAL tulos inputTaulu1 inputTaulu2 inputTaulu3 inputTaulu4 inputTaulu5
	suff1 suff2 suff3 suff4 suff5 tunnusluvut luokat byvar tulosta pyor color ylemRaja alemRaja
	vertailu excel;

/* Haetaan asetukset */
%Aloitus;

/* Jos byvar on avain, yhdistet‰‰n taulut sellaisinaan vaakatasossa */
%IF "&byvar" EQ "avain" %THEN %DO;
	DATA Apu1_yhd;
		SET &inputTaulu1;
		avain = _N_;
	RUN;

	DATA Apu2_yhd;
		SET &inputTaulu2;
		avain = _N_;
	RUN;

	%DO i = 3 %TO 5;
		%IF %LENGTH(&&inputTaulu&i) > 0 %THEN %DO;
			DATA Apu&i._yhd;
				SET &&inputTaulu&i;
				avain = _N_;
			RUN;
			%LET inputTaulu&i = Apu&i._yhd;
		%END;
	%END;

	%LET inputTaulu1 = Apu1_yhd;
	%LET inputTaulu2 = Apu2_yhd;
	%LET luokat = ;

%END;

/* Jos jokin inputTaulu3 -- inputTaulu5 on asetettu niin aseta suff1 = ; yhdistely‰ varten */
%IF %LENGTH(&inputTaulu3) > 0 or %LENGTH(&inputTaulu4) > 0 or %LENGTH(&inputTaulu5) > 0 %THEN %DO;
	%LET suff1 = ;
%END;

%LaskeErotus(&tulos, &inputTaulu1, &inputTaulu2, &tunnusluvut, &suff1, &suff2,
	byvar = &luokat &byvar, tulosta = 0, color = &color, yRaja=&ylemRaja, aRaja = &alemRaja);

/* Jos eiv‰t ole tyhji‰, niin */
%DO i = 3 %TO 5;
	%IF %LENGTH(&&inputTaulu&i) > 0 %THEN %DO;

	%LaskeErotus(&tulos, &tulos, &&inputTaulu&i, &tunnusluvut, /* TYHJƒ */, &&suff&i,
		byvar = &luokat &byvar, tulosta = 0, color = &color, yRaja=&ylemRaja, aRaja = &alemRaja);

	%END;
%END;

/* J‰rjest‰ ensin byvar, variable label ja sitten aakkosj‰rjestyksess‰ */
PROC CONTENTS DATA = &tulos (DROP = %VarExist(&byvar label)) OUT = nimet (keep=NAME) NOPRINT; RUN;

PROC SQL NOPRINT;
	SELECT NAME INTO :apulista SEPARATED BY ' '
	FROM nimet
	ORDER by NAME;
QUIT;

/* Valitaan muutokset vertailtaviksi ja v‰rikoodattaviksi */
PROC SQL NOPRINT;
SELECT NAME INTO :color_lista separated by ' ' 
FROM nimet
WHERE NAME like '%muutos%';
QUIT;

/* J‰rjestet‰‰n muuttujat tulostaulukossa oikeaan j‰rjestykseen.
   %VarExist tarkistaa onko label tai _CONTRO_ nimist‰ muuttujaa taulussa */
DATA &tulos;
	/* Jos yhdistet‰‰n yhdistysavaimen mukaan, niin ei j‰rjestet‰ tulostaulua */
	%IF "&byvar" NE "avain" %THEN %DO;
		RETAIN %VarExist(&luokat &byvar label &apulista, &tulos);
	%END;
	SET &tulos;
	%IF %LENGTH(%VarExist(_CONTROL_ , &tulos)) > 0 %THEN %DO;
		DROP _CONTROL_;
	%END;
	%IF %LENGTH(%VarExist(avain , &tulos)) > 0 %THEN %DO;
		DROP avain;
	%END;
	%IF &vertailu NE 1 %THEN %DO;
		DROP &color_lista;
		%LET color = 0;
	%END;
RUN;

%IF &EXCEL = 1 %THEN %DO;
	%LOCAL EXCEL_NIMI;
	%LET EXCEL_NIMI = %SCAN(&tulos, -1);
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&EXCEL_NIMI..xls" STYLE = MINIMAL;
%END;

/* Tulostetaan lopullinen taulu ja loopataan v‰rit yli prosentti-arvojen.
   Asetetaan formaatit. Varoitus: Picture format lyhent‰‰ dataa (tuhat. tuhatdec. miljoona.) */
%IF &tulosta EQ 1 %THEN %DO;
	PROC REPORT DATA = &tulos;
	%IF &pyor = 1 %THEN %DO;
		FORMAT _NUMERIC_ tuhat.;
	%END;
	FORMAT &color_lista percentn6.2;
	%IF &color = 1 %THEN %DO;
		%Korosta(&color_lista, &ylemRaja, &alemRaja);
	%END;
	RUN;
%END;

%IF &EXCEL = 1 %THEN %DO;
		ODS HTML3 CLOSE;
%END;

%MEND Taulukoi;

%Taulukoi;
