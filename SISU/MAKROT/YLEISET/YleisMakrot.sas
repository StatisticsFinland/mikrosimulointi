/********************************************************************
*  Kuvaus: Yleismakroja simuloinnin ohjaamiseen						*
*  Viimeksi päivitetty: 27.08.2024									* 
********************************************************************/

/*
Sisältö:

VarExist - palauttaa muuttujien nimet tekstinä, jos muuttujat ovat taulussa
Paste - palauttaa listan loppupäätteellä liitettynä
LuoKuuID - Makro, jolla luodaan kuukausi-id lakimakrojen sisällä
IkaKuuk - Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä ikävälillä tarkasteluvuoden aikana
Tarkistus - Makro tarkistaa löytyykö haluttua tiedostoa määritellystä tiedostosijainnista.
YLEIS_NollaaNumeerisetPuuttuvat - Nollaa numeeristen muuttujien puuttuvat arvot (kk-malli)
YLEIS_LuoVKkJarjestysmuuttuja - Luo aineistoon vuoteen ja kuukauteen perustuvan järjestysmuuttujan (kk-malli)

*/

/* Makro, joka palauttaa muuttujien nimet tekstinä, jos muuttujat ovat taulussa

%PUT %VarExist(muuttujat, taulu);

muuttujat - lista muuttujista.
taulu - taulu, josta tarkastetaan löytyvätkö muuttujat

Poikkeukset:
WARNING - jos muuttujaa ei löydy taulusta

*/
%macro VarExist(muuttujat, taulu)/
DES = "YleisMakrot: Palautetaan muuttujien nimet vain jos muuttujat ovat taulussa";
	%LOCAL muuttujat taulu apu tulos i taulu_a close puuttuvat;
	%LET taulu_a = %SYSFUNC(open(&taulu));
	%LET i = 1;
	%LET apu = %SCAN(&muuttujat, &i);
	%DO %WHILE ("&apu" NE "");
		%IF %SYSFUNC(varnum(&taulu_a,&apu)) > 0 %THEN %DO;
			%LET tulos = &tulos &apu;
		%END;
		%ELSE %DO;
			%LET puuttuvat = &puuttuvat &apu;
		%END;
		%LET i = %EVAL(&i + 1);
		%LET apu = %SCAN(&muuttujat, &i);
	%END;
	%LET close = %SYSFUNC(close(&taulu_a));
	%IF %LENGTH(&puuttuvat) > 0 %THEN %DO;
		%PUT NOTE: VarExist-makro: Taulu &taulu ei sisällä seuraavia muuttujia: &puuttuvat;
	%END;

	&tulos
%mend VarExist;

/* Makro, joka palauttaa listan tekstinä, jossa listan sanoihin on lisätty määritelty pääte.

%PUT %PASTE(a b c, _vero);
palauttaa: a_vero b_vero c_vero

LISTA - sanalista
SUFFIX - liitettävä loppupääte ilman lainausmerkkejä

*/
%MACRO PASTE(LISTA, SUFFIX)/
DES = "YleisMakrot: Yhtenäisen päätteen liittäminen listan jäseniin";
	%LOCAL i APU UUSI;
	%LET i = 1;
	%DO %UNTIL (%LENGTH(%SCAN(&LISTA, &i)) = 0);
		%LET UUSI = %SYSFUNC(CATS(%SCAN(&LISTA, &I), %STR(&SUFFIX)));
		%LET APU = %TRIM(&APU &UUSI);
		/* Jos viimeinen nimi listalla, niin lopetetaan loop*/
		%LET i = %EVAL(&i + 1);
	%END;
	
	/* Palautetaan lista */
	&APU
%MEND PASTE;

/* Makro, jolla luodaan kuukausi-id lakimakrojen sisällä */

/* HUOM! Käytä tätä makroa vain kuuid-muuttujien luomiseen!
Lainsäädännön muuttumisajankohdat, joihin kuuid-muuttujaa verrataan
tulee luoda MDY-funktiolla. */

%MACRO LuoKuuID(idmuuttuja, mvuosi, mkuuk)/
DES = 'YleisMakrot: Kuukausi-id -muuttujan muodostus';
/* Jos simuloinnin tyyppi on SIMULX, aikamuuttuja muodostetaan lainsäädöntövuoden ja -kuukauden perusteella eli
aikamuuttuja ei muutu. Näin lakimakrojen sisällä olevat kuukausiehdot menevät oikein myös silloin kun
simuloinnin tyyppi on SIMULX. */
%IF %UPCASE(&TYYPPI) EQ SIMULX %THEN %DO;
	&idmuuttuja = MDY(&LKUUK, 1, &LVUOSI);
%END;
%ELSE %DO;
	&idmuuttuja = MDY(&mkuuk, 1, &mvuosi);
%END;
%MEND LuoKuuID;

/* Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä ikävälillä tarkasteluvuoden aikana */

%MACRO IkaKuuk(ika_kuuk, ika_ala, ika_yla, ikakk)/
DES = 'YleisMakrot: Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä ikävälillä tarkasteluvuoden aikana';

IF (&ika_ala < 0 OR &ika_yla < 0 OR &ika_yla < &ika_ala) THEN temp = 0;

ELSE DO;

	ala_kuuk = 12 * &ika_ala;
	yla_kuuk = 12 * &ika_yla + 11;

	SELECT;
		WHEN (&ikakk < ala_kuuk) DO;
			temp = 0;
		END;
		WHEN (&ikakk > yla_kuuk) DO;
			temp = 13 - (&ikakk - yla_kuuk);
			IF temp < 0 THEN temp = 0;
		END;
		WHEN (ala_kuuk <= &ikakk <= yla_kuuk) DO;
			temp = &ikakk - ala_kuuk;
			IF temp > 12 THEN temp = 12;
		END;
	END;

END;

&ika_kuuk = temp;
DROP ala_kuuk yla_kuuk temp;
%MEND IkaKuuk;


/*
Tarkistus-makro tarkistaa löytyykö haluttua aineistoa (polku) määritellystä sijainnista.
Makro keskeyttää ajon, jos tarkastettavaa aineistoa ei löydy tai se on vanhempi kuin määritelty aineiston ikä (tiedostonika).
Polkuun laitetaan etsittävän aineiston kirjastoviite esim. (STARTDAT.start_elasumtuki_henki).
Tarkmalli-makromuuttuja viittaa simulointimalliin, joka tulisi olla ajettuna.
*/

%MACRO Tarkistus(polku, tarkmalli, tiedostonika);

%IF %SYSFUNC(exist(&polku))

		%THEN %DO;
			%LET file_exists = 1;
		%END;

		%ELSE %DO;
			%LET file_exists = 0;
%END; 

	*Jos starttidataa ei löydy - annetaan varoitus ja ohjeistus;

	%IF &file_exists. ne 1  %THEN %DO;
		%PUT ERROR: HUOM!	&tarkmalli ei ole ajettu;
		%PUT ERROR: HUOM!	Aja &tarkmalli ensin tai valitse TARKISTUS_&malli = 0;
		%ABORT CANCEL;
	%END;

	%ELSE %DO;

	PROC DATASETS NOLIST;
		CONTENTS DATA=&polku. OUT=TEMP.DATAMOD(KEEP=MODATE) NOPRINT;
	RUN;

	PROC MEANS DATA=TEMP.DATAMOD NOPRINT;
		OUTPUT OUT=TEMP.DATAVERT(KEEP=MODDATETIME) MAX=MODDATETIME;
	RUN;

	DATA TEMP.DATAVERT;
	SET TEMP.DATAVERT;
		
		MODDATE = DATEPART(MODDATETIME);
		TODAY = TODAY();
		KESTO = SUM(TODAY, -MODDATE);
		CALL SYMPUT ('KESTO', kesto);

	RUN;

	%IF &kesto > &tiedostonika %THEN %DO;
			%PUT ERROR: HUOM!	&polku on yli &tiedostonika päivää vanha;
			%PUT ERROR: HUOM!	Aja &tarkmalli ensin tai valitse TARKISTUS = 0;
			%ABORT CANCEL;
		%END;

%END;

%MEND;
/* Makro nollaa numeeristen muuttujien puuttuvat arvot */
%MACRO YLEIS_NollaaNumeerisetPuuttuvat;

	%IF %SYMEXIST(M_YLEIS_NNP_LASKURI) = 0 %THEN %DO;
		%GLOBAL M_YLEIS_NNP_LASKURI;
		%LET M_YLEIS_NNP_LASKURI = 0;
	%END;

	%LET M_YLEIS_NNP_LASKURI = %EVAL(&M_YLEIS_NNP_LASKURI. + 1);

	ARRAY NOLLATTAVAT&M_YLEIS_NNP_LASKURI. _NUMERIC_;

	DO OVER NOLLATTAVAT&M_YLEIS_NNP_LASKURI.;
		IF NOLLATTAVAT&M_YLEIS_NNP_LASKURI. = . THEN NOLLATTAVAT&M_YLEIS_NNP_LASKURI. = 0;
	END;

%MEND YLEIS_NollaaNumeerisetPuuttuvat;

/* Makro luo aineistoon vuoteen ja kuukauteen perustuvan järjestysmuuttujan */
%MACRO YLEIS_LuoVKkJarjestysmuuttuja(lahtoaineisto, 
				vuosimuuttuja, kuukausimuuttuja,
				tulosaineisto, tulosmuuttuja);

	PROC SQL NOPRINT;
		SELECT MIN(&vuosimuuttuja.), MAX(&vuosimuuttuja.) INTO :MINVUOSI, :MAXVUOSI
		FROM &lahtoaineisto.;
	QUIT;

	DATA &tulosaineisto.;
		SET &lahtoaineisto.;

		%DO I = 0 %TO (&MAXVUOSI. - &MINVUOSI.);
			IF &vuosimuuttuja. = (&MINVUOSI. + &I) THEN &tulosmuuttuja. = &kuukausimuuttuja. + (&I. * 12);
		%END;

	RUN;

%MEND YLEIS_LuoVKkJarjestysmuuttuja;
