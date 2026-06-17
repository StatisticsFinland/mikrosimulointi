options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/MAKROT/YLEISET/PyoristysMakrot.sas

   PyoristysMakrot.sas defines a set of money-rounding macros used throughout
   the SISU model. The macro definitions below are reproduced verbatim from
   that file (only the Finnish DES= descriptions are transliterated to ASCII).
   The markka-rounding macros (Pyoristys100mk / Pyoristys1000mk) reference a
   global &euro conversion factor, which the model defines elsewhere; here it
   is set to 1 so the macros can be exercised standalone.
   --------------------------------------------------------------------------- */

%LET euro = 1;

/* 1. Pyoristaa annetun rahamaaran sentin tarkkuuteen */
%MACRO PyoristysSentinTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: round to cent precision";
	&tulos = ROUND(&rahamaara, 0.01);
%MEND PyoristysSentinTarkkuuteen;

/* 2. Pyoristaa annetun rahamaaran euron tarkkuuteen */
%MACRO PyoristysEuronTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: round to euro precision";
	&tulos = ROUND(&rahamaara, 1);
%MEND PyoristysEuronTarkkuuteen;

/* 3. Pyoristaa annetun rahamaaran 100 markan tarkkuuteen */
%MACRO Pyoristys100mk (tulos, arvo)/
DES = 'PyoristysMakrot: round to 100 markka precision';
&tulos = &euro * &arvo / 100;
&tulos = CEIL(&tulos);
&tulos = 100 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys100mk;

/* 4. Pyoristaa annetun rahamaaran 1000 markan tarkkuuteen */
%MACRO Pyoristys1000mk (tulos, arvo)/
DES = 'PyoristysMakrot: round to 1000 markka precision';
&tulos = &euro * &arvo / 1000;
&tulos = CEIL(&tulos);
&tulos = 1000 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys1000mk;

/* 5. Pyoristaa annetun rahamaaran 10 euron tarkkuuteen */
%MACRO Pyoristys10e(tulos, arvo)/
DES = 'PyoristysMakrot: round to 10 euro precision';
&tulos = CEIL(&arvo / 10);
&tulos = 10 * (&tulos);
%MEND Pyoristys10e;

/* 6. Pyoristaa annetun rahamaaran 100 euron tarkkuuteen */
%MACRO Pyoristys100e(tulos, arvo)/
DES = 'PyoristysMakrot: round to 100 euro precision';
&tulos = CEIL(&arvo / 100);
&tulos = 100 * &tulos;
%MEND Pyoristys100e;
