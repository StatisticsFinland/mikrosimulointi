options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/MAKROT/YLEISET/TulosMakrot.sas (macro SumKotitT)

   SumKotitT sums person-level results up to the household level. For the model
   it is called from it selects the grouping/ID variables, then runs
   PROC SUMMARY with BY knro, an ID list of household-constant variables, and a
   VAR list of measures to sum. The macro definition below is reproduced
   verbatim from TulosMakrot.sas. It is called with KUTSMALLI=VERO and a global
   &PAINO weight variable; input is a small synthetic person-level table whose
   columns match the ID/VAR lists.
   --------------------------------------------------------------------------- */

%LET PAINO = ykor;

%MACRO SumKotitT(TULOS, SISAAN, KUTSMALLI, MJAT)/
DES = "TulosMakrot: sum person-level results to household level";

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

	%IF &SUMMAUS=1 %THEN %DO;
		PROC SUMMARY DATA=&sisaan(DROP = hnro);
			BY knro;
			ID &KIDRYHMA;
			VAR &MJAT;
			OUTPUT OUT = &tulos (DROP = &DRYHMA)  SUM = ;
		RUN;
	%END;

%MEND SumKotitT;
