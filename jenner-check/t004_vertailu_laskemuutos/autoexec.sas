options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/MAKROT/YLEISET/VertailuMakrot.sas (macro LaskeMuutos)

   LaskeMuutos walks a list of statistic names and, for each, computes the
   difference and percentage change between two scenarios (suffixes suff1 and
   suff2), emitting the assignment and LABEL statements into a DATA step. It is
   used when comparing two SISU result tables. The macro definition below is
   reproduced verbatim from VertailuMakrot.sas (Finnish DES/LABEL text kept).
   --------------------------------------------------------------------------- */

%MACRO LaskeMuutos(mlista, suff1, suff2)/
DES = "VertailuMakrot: difference and percent change between two compared tables";
	%LOCAL apu_muuttuja k;
	%LET k = 1;
	%LET apu_muuttuja = %SCAN(&mlista,&k);
	%DO %WHILE ("&apu_muuttuja" NE "");
		/* Laskutoimitukset */
		&apu_muuttuja._ero&suff1.&suff2 = &apu_muuttuja.&suff2 - &apu_muuttuja.&suff1;
		&apu_muuttuja._muutos&suff1.&suff2 = &apu_muuttuja._ero&suff1.&suff2 /  &apu_muuttuja.&suff1;
		LABEL &apu_muuttuja._ero&suff1.&suff2 = "Erotus &apu_muuttuja &suff2 - &suff1";
		LABEL &apu_muuttuja._muutos&suff1.&suff2 = "Muutospros &apu_muuttuja &suff2 - &suff1";

		%LET colorLista = &colorLista &apu_muuttuja._muutos&suff1.&suff2;

		%LET k = %EVAL(&k+1);
		%LET apu_muuttuja = %SCAN(&mlista,&k);
	%END;
%MEND LaskeMuutos;
