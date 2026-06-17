/***********************************************************************
* Esimerkki: SISU-mallin YleisMakrot.sas -tiedoston IkaKuuk-makron kutsu.
* IkaKuuk laskee kuukaudet, jotka henkilo viettaa tietyssa ikavalissa
* tarkasteluvuoden aikana. Syotteena henkilon ikakuukaudet (ikakk).
* Lasketaan kuukaudet, jotka henkilo on 18-64 -vuotiaiden ikavalissa.
***********************************************************************/

data ika_kuukaudet;
    input henkilo $ ikakk;          /* henkilon ika kuukausina vuoden alussa */

    %IkaKuuk(kk_18_64, 18, 64, ikakk);   /* tyoikaiset 18-64 */
    %IkaKuuk(kk_0_17,   0, 17, ikakk);   /* alaikaiset 0-17 */

    datalines;
lapsi      120
nuori      210
aikuinen   480
elaketta   780
;
run;

proc print data=ika_kuukaudet noobs;
    title "IkaKuuk: kuukaudet ikavalilla 18-64 ja 0-17";
    var henkilo ikakk kk_18_64 kk_0_17;
run;
