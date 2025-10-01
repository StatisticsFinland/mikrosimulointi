/* ******************************************************************
* Kuvaus: Ohjelma kulutusluokkien parametritaulukoiden yl‰luokkien	*
*         jakamiseen alaluokkiin									*
*  Viimeksi p‰ivitetty: 14.6.2024 									*
*  P‰ivitetty toimimaan vuoden 2022 aineistolla						*
********************************************************************/

/* Asetukset */
%LET HAJOTETTAVA = _09_5; /* Alemmalle tasolle hajotettava luokka */
%LET TASO = 7; /* Alempi taso jolle hajotetaan: Tasot 3, 4, 5 ja 7 (esim. 7 tarkoittaa tarkinta, eli 7 numeron tasoa) */
/* lukum‰‰r‰t tarkoittavat numeroiden m‰‰ri‰ esim. _02_1 -> TASO=3, _02_1_9_0_1_9 -> TASO=7 */

%LET AINEISTO = kulu_valmisaineisto_2022; /* Aineisto, jonka muuttujien perusteella jako alaluokkiin tehd‰‰n (POHJADAT-kansiossa) */

%LET PARAM_VVERO = PARAM.PVVERO_TUOTTEET;	/* L‰hdetaulu */
%LET PARAM_VVERO_OUT = PARAM.PVVERO_TUOTTEET_TESTI; /* Kohdetaulu */


/* Jos t‰m‰ taulu j‰‰ tyhj‰ksi, niin tulostaulu pysyy muuttumattomana. */
%MACRO PuraAlatasolle(PARAM_VVERO, PARAM_VVERO_OUT, HAJOTETTAVA, TASO);

	/* Haetaan lista m‰‰ritellyn aineiston muuttujista */
	PROC CONTENTS DATA = POHJADAT.&AINEISTO. OUT = temp_luokat (KEEP = NAME) NOPRINT; RUN;

	/* Pidet‰‰n korvattavat tasot */
	DATA temp_tuote;
		LENGTH tuote $13;
	
		 SET temp_luokat (RENAME = (NAME = tuote_orig));
		
		/* Sallitaan hajottaminen alasp‰in, jos mahdollista. */
		IF INDEX(tuote_orig, "&HAJOTETTAVA") AND LENGTH(compress(tuote_orig,' _')) = &TASO AND (LENGTH(compress("&HAJOTETTAVA",' _'))) < &TASO;
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
		LENGTH Tuote $13;
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