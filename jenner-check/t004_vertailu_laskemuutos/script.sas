/***********************************************************************
* Esimerkki: SISU-mallin VertailuMakrot.sas -tiedoston LaskeMuutos-makron
* kutsu. LaskeMuutos laskee kahden skenaarion (paatteet _1 ja _2) valisen
* erotuksen ja muutosprosentin annetulle tunnuslukulistalle. Syote on
* yhdistetty summataulu, jossa kaksi skenaariota rinnakkain.
***********************************************************************/

/* Yhdistetty summataulu: kaksi skenaariota (_1 perus, _2 uudistus) */
data vertailu;
    input ryhma $ verot_1 verot_2 tuet_1 tuet_2;
    datalines;
desiili1  1200 1260  800 760
desiili2  2400 2520  600 570
desiili3  4100 4305  300 300
;
run;

/* Lasketaan erotus ja muutosprosentti tunnusluvuille verot ja tuet */
data vertailu_muutos;
    set vertailu;
    %LaskeMuutos(verot tuet, _1, _2);
run;

proc print data=vertailu_muutos noobs label;
    title "LaskeMuutos: erotus ja muutosprosentti skenaarioiden valilla";
run;
