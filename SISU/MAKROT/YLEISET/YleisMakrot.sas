/********************************************************************
*  Kuvaus: Yleismakroja simuloinnin ohjaamiseen						*
*  Viimeksi p�ivitetty: 27.08.2024									* 
********************************************************************/

/*
Sis�lt�:

VarExist - palauttaa muuttujien nimet tekstin�, jos muuttujat ovat taulussa
Paste - palauttaa listan loppup��tteell� liitettyn�
LuoKuuID - Makro, jolla luodaan kuukausi-id lakimakrojen sis�ll�
IkaKuuk - Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll� ik�v�lill� tarkasteluvuoden aikana
Tarkistus - Makro tarkistaa l�ytyyk� haluttua tiedostoa m��ritellyst� tiedostosijainnista.
YLEIS_NollaaNumeerisetPuuttuvat - Nollaa numeeristen muuttujien puuttuvat arvot (kk-malli)
YLEIS_LuoVKkJarjestysmuuttuja - Luo aineistoon vuoteen ja kuukauteen perustuvan j�rjestysmuuttujan (kk-malli)

*/

/* Makro, joka palauttaa muuttujien nimet tekstin�, jos muuttujat ovat taulussa

%PUT %VarExist(muuttujat, taulu);

muuttujat - lista muuttujista.
taulu - taulu, josta tarkastetaan l�ytyv�tk� muuttujat

Poikkeukset:
WARNING - jos muuttujaa ei l�ydy taulusta

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
		%PUT NOTE: VarExist-makro: Taulu &taulu ei sis�ll� seuraavia muuttujia: &puuttuvat;
	%END;

	&tulos
%mend VarExist;

/* Makro, joka palauttaa listan tekstin�, jossa listan sanoihin on lis�tty m��ritelty p��te.

%PUT %PASTE(a b c, _vero);
palauttaa: a_vero b_vero c_vero

LISTA - sanalista
SUFFIX - liitett�v� loppup��te ilman lainausmerkkej�

*/
%MACRO PASTE(LISTA, SUFFIX)/
DES = "YleisMakrot: Yhten�isen p��tteen liitt�minen listan j�seniin";
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

/* Makro, jolla luodaan kuukausi-id lakimakrojen sis�ll� */

/* HUOM! K�yt� t�t� makroa vain kuuid-muuttujien luomiseen!
Lains��d�nn�n muuttumisajankohdat, joihin kuuid-muuttujaa verrataan
tulee luoda MDY-funktiolla. */

%MACRO LuoKuuID(idmuuttuja, mvuosi, mkuuk)/
DES = 'YleisMakrot: Kuukausi-id -muuttujan muodostus';
/* Jos simuloinnin tyyppi on SIMULX, aikamuuttuja muodostetaan lains��d�nt�vuoden ja -kuukauden perusteella eli
aikamuuttuja ei muutu. N�in lakimakrojen sis�ll� olevat kuukausiehdot menev�t oikein my�s silloin kun
simuloinnin tyyppi on SIMULX. */
%IF %UPCASE(&TYYPPI) EQ SIMULX %THEN %DO;
	&idmuuttuja = MDY(&LKUUK, 1, &LVUOSI);
%END;
%ELSE %DO;
	&idmuuttuja = MDY(&mkuuk, 1, &mvuosi);
%END;
%MEND LuoKuuID;

/* Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll� ik�v�lill� tarkasteluvuoden aikana */

%MACRO IkaKuuk(ika_kuuk, ika_ala, ika_yla, ikakk)/
DES = 'YleisMakrot: Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll� ik�v�lill� tarkasteluvuoden aikana';

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
Tarkistus-makro tarkistaa l�ytyyk� haluttua aineistoa (polku) m��ritellyst� sijainnista.
Makro keskeytt�� ajon, jos tarkastettavaa aineistoa ei l�ydy tai se on vanhempi kuin m��ritelty aineiston ik� (tiedostonika).
Polkuun laitetaan etsitt�v�n aineiston kirjastoviite esim. (STARTDAT.start_elasumtuki_henki).
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

	*Jos starttidataa ei l�ydy - annetaan varoitus ja ohjeistus;

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
			%PUT ERROR: HUOM!	&polku on yli &tiedostonika p�iv�� vanha;
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

/* Makro luo aineistoon vuoteen ja kuukauteen perustuvan j�rjestysmuuttujan */
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
