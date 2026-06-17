options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/DATA/POHJADAT/tulrek_summaus.sas

   The upstream program reads two income-register source tables from the
   POHJADAT library (POHJADAT.tulrek_palkka<vuosi> and
   POHJADAT.tulrek_etuus<vuosi>). Those tables are licensed microdata that is
   not part of the public repository, so here we point POHJADAT at WORK and
   build small synthetic tables with the exact columns the program reads:
   hnro (person id), kk (month), transactionCode, summa (amount).

   The transaction codes below are chosen so that some fall inside the
   excluded code lists in the program and some do not, exercising the
   CASE WHEN ... NOT IN (...) aggregation on real data.
   --------------------------------------------------------------------------- */

libname POHJADAT '.';

data POHJADAT.tulrek_palkka2024;
    input hnro $ kk transactionCode summa;
    datalines;
A001 1 101 1500
A001 1 401 200
A001 2 101 1600
A001 2 405 50
A002 1 102 2000
A002 1 419 300
A002 3 101 1800
B003 1 319 999
B003 1 110 2500
B003 2 110 2400
;
run;

data POHJADAT.tulrek_etuus2024;
    input hnro $ kk transactionCode summa;
    datalines;
A001 1 2001 400
A001 1 1006 120
A001 2 2001 410
A002 1 1266 300
A002 1 2002 250
A002 3 1310 90
B003 1 2001 600
B003 1 1015 75
B003 2 2003 520
;
run;
