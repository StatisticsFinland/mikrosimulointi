/*******************************************************************
*  Kuvaus: V‰lillisen verotuksen lains‰‰d‰ntˆ‰ makroina 	       * 
*  Viimeksi p‰ivitetty: 30.06.2020        					       * 
*******************************************************************/

/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 ParamTuotteet = Kertoimen haku jokaiselle tuotteelle
2.2 LaskeAlv = Kohdevuoden kulutuksen ja alv:n m‰‰r‰ sek‰ muuttujien tallentaminen uudella loppup‰‰tteell‰
2.3 LaskeNetto = laskee alvittomat hinnat, sek‰ palauttaa alv sek‰ nettohinnat
*/

/* 2.1 Makro, jolla haetaan jokaiselle tuotteelle kerroin */

/* Makrojen parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	ptaulu: ALV-mallin Parametritaulu */

%MACRO ParamTuotteet(mvuosi, ptaulu)
/ DES = 'VVERO: Kertoimen haku jokaiselle tuotteelle';
	DATA testi; /* _NULL_ */
		SET &ptaulu (keep = Selite Kerroin Tuote v&mvuosi);
		/* Haetaan makromuuttujan arvo, jos v&mvuosi-arvo ei ole numeerinen */
		hae_param = verify(compress(v&mvuosi),'0123456789.');
		IF hae_param THEN kanta = SYMGET(v&mvuosi);
		ELSE kanta = put(compress(v&mvuosi), 8.);

		/* Tallennetaan tuotteiden veroprosentit makromuuttujiksi */
		CALL SYMPUTX(CATS(tuote), kanta, 'F');
		/* Tallennetaan tuotteiden kertoimet  makromuuttujiksi */
		CALL SYMPUTX(CATS(tuote,'_KERROIN'), Kerroin, 'F');
	RUN;
%MEND ParamTuotteet;

/* 2.2 Makro, joka laskee kohdevuoden kulutuksen, alv:n
	sek‰ tallentaa muuttujat uudella loppup‰‰tteell‰. */

/* Makrojen parametrit:
	TUOTTEET: Lista tuotteista eli muuttujista */

%MACRO LaskeAlv(TUOTTEET)
/ DES = 'VVERO: Kohdevuoden kulutuksen ja alv:n m‰‰r‰ sek‰ muuttujien tallentaminen uudella loppup‰‰tteell‰';
	/* Loopataan kaikki listan muuttujat yli ja lasketana alv sek‰ kulutus */

	%DO I = 1 %TO %SYSFUNC(COUNTW(&TUOTTEET));
		%LET TUOTE = %SCAN(&TUOTTEET, &I);

		/* Kohdevuoden alv */
		&TUOTE._ALV = &TUOTE._NETTO * &&&TUOTE/100;
		/* Kohdevuoden kulutus */
		&TUOTE._KULUTUS = SUM(&TUOTE._NETTO, &TUOTE._ALV);

	%END;
%MEND LaskeAlv;
/* 2.3 Makro, joka laskee alvittomat hinnat ja palauttaa alv:n sek‰ nettohinnat */

/* Makrojen parametrit:
	TUOTTEET: Lista tuotteista eli muuttujista */

%MACRO LaskeNetto(TUOTTEET)
/ DES = 'VVERO: Laskee alvittomat hinnat, sek‰ palauttaa alv:n sek‰ nettohinnan';
	/* Loopataan kaikki listan muuttujat yli ja lasketana alvittomat hinnat*/

	%DO i = 1 %TO %SYSFUNC(COUNTW(&TUOTTEET));
		%LET TUOTE = %SCAN(&TUOTTEET, &i);
		
		&TUOTE._NETTO = &TUOTE/(1+&&&TUOTE/100);

		&TUOTE._ALV = &TUOTE._NETTO * &&&TUOTE/100;

		&TUOTE._KULUTUS = SUM(&TUOTE._NETTO, &TUOTE._ALV);

	%END;
%MEND LaskeNetto;