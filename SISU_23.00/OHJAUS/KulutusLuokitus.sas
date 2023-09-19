/* ******************************************************************
* Kuvaus: Ohjelma kulutusluokkien parametritaulukoiden yl‰luokkien	*
*         jakamiseen alaluokkiin									*
* Viimeksi p‰ivitetty: 18.5.2015 									*
********************************************************************/

/* Asetukset */
%LET HAJOTETTAVA = A021; /* Alemmalle tasolle hajotettava luokka */
%LET TASO = 7; /* Alempi taso jolle hajotetaan: Tasot 3, 4, 5 ja 7 (esim. 7 tarkoittaa tarkinta, eli 7 numeron tasoa) */

%LET AINEISTO = AIKASA2016; /* Aineisto, jonka muuttujien perusteella jako alaluokkiin tehd‰‰n (POHJADAT-kansiossa) */

%LET PARAM_VVERO = PARAM.PVVERO_TUOTTEET;	/* L‰hdetaulu */
%LET PARAM_VVERO_OUT = PARAM.PVVERO_TUOTTEET_UUSI; /* Kohdetaulu */


/* Jos t‰m‰ taulu j‰‰ tyhj‰ksi, niin tulostaulu pysyy muuttumattomana. */
%MACRO PuraAlatasolle(PARAM_VVERO, PARAM_VVERO_OUT, HAJOTETTAVA, TASO);

	/* Haetaan lista m‰‰ritellyn aineiston muuttujista */
	PROC CONTENTS DATA = POHJADAT.&AINEISTO OUT = temp_luokat (KEEP = NAME) NOPRINT; RUN;

	/* Pidet‰‰n korvattavat tasot */
	DATA temp_tuote(DROP = tuote_orig);
		LENGTH tuote $8;
		SET temp_luokat (RENAME = (NAME = tuote_orig));
		/* Sallitaan hajottaminen alasp‰in, jos mahdollista. */
		IF INDEX(tuote_orig, "&HAJOTETTAVA") AND LENGTH(tuote_orig) = (&TASO + 1) AND (%LENGTH(&HAJOTETTAVA)-1) < &TASO;
		tuote = LEFT(tuote_orig);
		/* Annetaan myˆs selitteeksi tuoteluokan koodi */
		Selite = tuote;
	RUN;

	PROC SQL NOPRINT;
	SELECT count(*) INTO :pituus
	FROM temp_tuote;
	QUIT;

	/* Korvataan yhden rivin yksi solu ja laajennetaan: */
	DATA &PARAM_VVERO_OUT (DROP = i);
		LENGTH Tuote $8;
		SET &PARAM_VVERO;
		/* Jos tuote on mahdollista hajottaa jollekin tasolle, niin hajotetaan: */
		IF TUOTE = "&HAJOTETTAVA" AND &pituus > 0 THEN DO;
			DO i = 1 to &pituus;
				SET temp_tuote;
				OUTPUT;
			END;
		END;
		ELSE OUTPUT;
	RUN;
%MEND PuraAlatasolle;

%PuraAlatasolle(&PARAM_VVERO, &PARAM_VVERO_OUT, &HAJOTETTAVA, &TASO); 