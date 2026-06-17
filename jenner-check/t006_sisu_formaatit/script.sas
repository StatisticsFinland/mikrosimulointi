/* ******************************************************************
* Esimerkki: SISU-mallin OHJAUS/SisuFormaatit.sas -tiedoston
* luokitusformaattien maarittely ja kaytto. Alla maaritellaan PROC
* FORMATilla tuloihin liittyva tuhaterotin-PICTURE seka tulodesiili-,
* ikaluokka-, sosioekonomisen aseman ja koulutusasteen VALUE-formaatit
* (samat arvovalit ja selitteet kuin lahdetiedostossa; vain a- ja
* o-umlautit on translitteroitu ASCII-muotoon). Lopuksi formaatit
* liitetaan pieneen esimerkkiaineistoon PROC PRINTilla.
********************************************************************/

PROC FORMAT;

/* TUHATEROTIN (tuhaterottimellinen rahamaaraformaatti) */
PICTURE tuhat (ROUND)
low - <0 = '0 000 000 000 000 009' (DECSEP=',' PREFIX='-')
0 - high = '0 000 000 000 000 009' (DECSEP=',');

/* DESIILIT */
VALUE desmod (NOTSORTED MULTILABEL)
0 = '01. desiili'
1 = '02. desiili'
2 = '03. desiili'
3 = '04. desiili'
4 = '05. desiili'
5 = '06. desiili'
6 = '07. desiili'
7 = '08. desiili'
8 = '09. desiili'
9 = '10. desiili'
low-high = 'Yhteensa';

/* IKALUOKITUS */
VALUE ikavu (NOTSORTED MULTILABEL)
low-24 = '0-24'
25-34 = '25-34'
35-44 = '35-44'
45-54 = '45-54'
55-64 = '55-64'
65-74 = '65-74'
75-high = '75-'
low-high = 'Yhteensa' ;

/* SOSIOEKONOMINEN ASEMA (HENKILO) */
VALUE soss (NOTSORTED MULTILABEL)
10-29 = '1. Yrittajat ja maatalousyrittajat'
30-59 = '2. Palkansaajat'
60 = '3. Opiskelijat ja koululaiset'
70-79 = '4. Elakelaiset'
80,81,82 = '5. Tyottomat ja muut'
90-99 = '6. Tuntemattomat'
low-high = 'Yhteensa';

/* KOULUTUSASTE (KOULUTUSLUOKITUS 2016) */
VALUE koulas (NOTSORTED MULTILABEL)
0 = '1. Perusaste, ei suoritettua tutkintoa tai tuntematon'
3 = '2. Keskiaste'
4 = '3. Erikoisammattikoulutusaste'
5 = '4. Alin korkea-aste'
6 = '5. Alempi korkeakouluaste'
7 = '6. Ylempi korkeakouluaste'
8 = '7. Tutkijakoulutusaste'
low-high = 'Yhteensa';

RUN;

/* Esimerkkiaineisto, johon formaatit liitetaan */
data henkilot;
    input hnro ikavuosi soss koulas desmod tulot;
    datalines;
1   19  60  3  0   8500
2   41  40  6  4  34200
3   52  20  7  6  61000
4   68  72  4  8  29800
5   30  81  0  2  12750
;
run;

proc print data=henkilot noobs;
    title "SisuFormaatit: luokitusformaatit liitettyna esimerkkiaineistoon";
    var hnro ikavuosi soss koulas desmod tulot;
    format ikavuosi ikavu.
           soss    soss.
           koulas  koulas.
           desmod  desmod.
           tulot   tuhat.;
run;
