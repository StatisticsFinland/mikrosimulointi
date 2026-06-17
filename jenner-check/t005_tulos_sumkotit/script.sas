/***********************************************************************
* Esimerkki: SISU-mallin TulosMakrot.sas -tiedoston SumKotitT-makron kutsu.
* SumKotitT summaa henkilotason tulokset kotitaloustasolle: PROC SUMMARY
* BY knro, ID-listana kotitalouskohtaiset taustamuuttujat ja VAR-listana
* summattavat tunnusluvut. Syote on henkilotason aineisto (knro = kotitalous).
***********************************************************************/

/* Henkilotason esimerkkiaineisto: kaksi henkiloa per kotitalous.
   knro = kotitalous, hnro = henkilo (pudotetaan), ID-muuttujat ovat
   kotitalouden sisalla vakioita; verot ja tuet summataan. */
data henkilot;
    input knro hnro ykor ikavuv desmod paasoss elivtu koulas koulasv rake maakunta verot tuet;
    datalines;
1 11 100 35 4 1 2 3 3 1 9 5200 1200
1 12 100 35 4 1 2 3 3 1 9 4800 1500
2 21 100 52 7 1 2 4 4 2 1 9100 800
2 22 100 52 7 1 2 4 4 2 1    0 2400
3 31 100 19 1 3 1 2 2 1 5    0 3600
;
run;

proc sort data=henkilot; by knro; run;

/* Summataan verot ja tuet kotitaloustasolle (KUTSMALLI = VERO) */
%SumKotitT(kotitaloustaso, henkilot, VERO, verot tuet);

proc print data=kotitaloustaso noobs;
    title "SumKotitT: henkilotason verot ja tuet summattuna kotitalouksille";
    var knro ykor ikavuv desmod maakunta verot tuet;
run;
