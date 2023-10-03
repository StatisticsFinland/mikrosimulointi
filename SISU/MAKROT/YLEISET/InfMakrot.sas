/********************************************************************
*	Kuvaus: Makrot indeksiin perustuvan inflaatiokertoimen			*
*	laskemiseen.													*
*	Viimeksi päivitetty: 24.1.2018		   					       	*
********************************************************************/

/*
SISÄLLYS:

InfKerroin - Indeksiin perustuvan inflaatiokertoimen laskenta aineistosimuloinnissa
InfKerroin_ESIM - Indeksiin perustuvan inflaatiokertoimen laskenta esimerkkilaskelmissa
*/

%MACRO InfKerroin(vertvuosi, vuosi, ind)/
DES = "InfMakrot: Inflaatiokorjauksessa käytettävä yleismakro";

/* Taataan yhteensopivuus vanhojen malliversioiden kanssa siten, että
KHI-korjaus tehdään myös silloin kun syötetty arvo on 999 */
%IF &ind = 999 OR %UPCASE(&ind) = KHI OR %UPCASE(&ind) = ATI %THEN %DO;
	%IF &ind = 999 OR %UPCASE(&ind) = KHI %THEN %DO;
		%LET vertind = ind51;
	%END;
	%ELSE %IF %UPCASE(&ind) = ATI %THEN %DO;
		%LET vertind = ansio64;
	%END;

	%LET taulu = %SYSFUNC(OPEN(PARAM.&PINDEKSI_VUOSI, i));
	%LET w = %SYSFUNC(FETCH(&taulu));
	%LET y = %SYSFUNC(GETVARN(&taulu, %SYSFUNC(VARNUM(&taulu, Vuosi))));
	%DO %WHILE (&w = 0);
		%LET y = %SYSFUNC(GETVARN(&taulu, %SYSFUNC(VARNUM(&taulu, Vuosi))));
		%IF &y = &vertvuosi %THEN %LET indvert = %SYSFUNC(GETVARN(&taulu, %SYSFUNC(VARNUM(&taulu, &vertind))));
		%IF &y = &vuosi %THEN %LET indnyt = %SYSFUNC(GETVARN(&taulu, %SYSFUNC(VARNUM(&taulu, &vertind))));
		%LET w = %SYSFUNC(FETCH(&taulu));
	%END;
	%IF (&indnyt NE 0) AND (&indnyt NE .) %THEN %LET INF = %SYSEVALF(&indvert / &indnyt);
	%ELSE %LET INF = 1;
	%LET z = %SYSFUNC(CLOSE(&taulu));
%END;

%MEND InfKerroin;

%MACRO InfKerroin_ESIM(vertvuosi, vuosi, ind, infnimi = INF)/
DES = "InfMakrot: Inflaatiokorjauksessa käytettävä yleismakro, esimerkkilaskelmat";

/* Taataan yhteensopivuus vanhojen malliversioiden kanssa siten, että
KHI-korjaus tehdään myös silloin kun syötetty arvo on 999 */
%IF &ind = 999 OR %UPCASE(&ind) = KHI OR %UPCASE(&ind) = ATI %THEN %DO;
	%IF &ind = 999 OR %UPCASE(&ind) = KHI %THEN %DO;
		%LET vertind = ind51;
	%END;
	%ELSE %IF %UPCASE(&ind) = ATI %THEN %DO;
		%LET vertind = ansio64;
	%END;

	taulu = OPEN("PARAM.&PINDEKSI_VUOSI", "i");
	w = FETCH(taulu);
	y = GETVARN(taulu, VARNUM(taulu, "Vuosi"));
	DO WHILE (w = 0);
		y = GETVARN(taulu, VARNUM(taulu, "Vuosi"));
		IF y = &vertvuosi THEN indvert = GETVARN(taulu, VARNUM(taulu, "&vertind"));
		IF y = &vuosi THEN indnyt = GETVARN(taulu, VARNUM(taulu, "&vertind"));
		w = FETCH(taulu);
	END;
	IF (indnyt NE 0) AND (indnyt NE .) THEN &infnimi = (indvert / indnyt);
	ELSE &infnimi = 1;
	z = CLOSE(taulu);
	DROP taulu w y indvert indnyt z;
%END;
%ELSE %DO;
	&infnimi = &ind;
%END;

%MEND InfKerroin_ESIM;