/***********************************************************************
* Esimerkki: SISU-mallin PyoristysMakrot.sas -rahanmaaran pyoristys-
* makrojen kutsu. Makrot tuottavat data-askeleen sijoituslauseita, joten
* ne kutsutaan suoraan data-askeleen sisalla. Syote on joukko esimerkki-
* rahamaaria, joihin sovelletaan eri tarkkuustasoja.
***********************************************************************/

data pyoristykset;
    input rahamaara;

    /* Sentin ja euron tarkkuus */
    %PyoristysSentinTarkkuuteen(sentti, rahamaara);
    %PyoristysEuronTarkkuuteen(euro, rahamaara);

    /* 10 euron ja 100 euron tarkkuus (pyoristys ylospain, CEIL) */
    %Pyoristys10e(kymppi, rahamaara);
    %Pyoristys100e(satanen, rahamaara);

    datalines;
12.345
99.99
250.5
1001
4567.891
;
run;

proc print data=pyoristykset noobs;
    title "PyoristysMakrot: rahamaaran pyoristys eri tarkkuustasoille";
    var rahamaara sentti euro kymppi satanen;
run;
