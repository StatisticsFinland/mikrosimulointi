/*********************************************
* Kuvaus: Makroja rahamäärien pyöristämiseen *
* Viimeksi paivitetty: 24.1.2018             *
*********************************************/

/* Tiedosto sisältää seuraavat makrot:
1. PyoristysSentinTarkkuuteen = Pyöristää annetun rahamäärän sentin tarkkuuteen
2. PyoristysEuronTarkkuuteen = Pyöristää annetun rahamäärän euron tarkkuuteen
3. Pyoristys100mk = Pyöristää annetun rahamäärän 100 markan tarkkuuteen
4. Pyoristys1000mk = Pyöristää annetun rahamäärän 1000 markan tarkkuuteen
5. Pyoristys10e = Pyöristää annetun rahamäärän 10 euron tarkkuuteen
6. Pyoristys100e = Pyöristää annetun rahamäärän 100 euron tarkkuuteen
*/

/* 1. Pyöristää annetun rahamäärän sentin tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, sentin tarkkuuteen pyöristetty rahamäärä
		rahamaara: Rahamaara, joka halutaan pyöristää */

%MACRO PyoristysSentinTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: Pyöristää annetun rahamäärän sentin tarkkuuteen";

	&tulos = ROUND(&rahamaara, 0.01); 	

%MEND PyoristysSentinTarkkuuteen;


/* 2. Pyöristää annetun rahamäärän euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen pyöristetty rahamäärä
		rahamaara: Rahamaara, joka halutaan pyöristää */

%MACRO PyoristysEuronTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: Pyöristää annetun rahamäärän euron tarkkuuteen";

	&tulos = ROUND(&rahamaara, 1);

%MEND PyoristysEuronTarkkuuteen;


/* 3. Pyöristää annetun rahamäärän 100 markan tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen pyöristetty rahamäärä
		arvo: Rahamaara, joka halutaan pyöristää */

%MACRO Pyoristys100mk (tulos, arvo)/
DES = 'PyoristysMakrot: Pyöristys 100 markan tarkkuuteen';
&tulos = &euro * &arvo / 100;
&tulos = CEIL(&tulos);
&tulos = 100 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys100mk;


/* 4. Pyöristää annetun rahamäärän 1000 markan tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen pyöristetty rahamäärä
		arvo: Rahamaara, joka halutaan pyöristää */

%MACRO Pyoristys1000mk (tulos, arvo)/
DES = 'PyoristysMakrot: Pyöristys 1000 markan tarkkuuteen';
&tulos = &euro * &arvo / 1000;
&tulos = CEIL(&tulos);
&tulos = 1000 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys1000mk;


/* 5. Pyöristää annetun rahamäärän 10 euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen pyöristetty rahamäärä
		arvo: Rahamaara, joka halutaan pyöristää */

%MACRO Pyoristys10e(tulos, arvo)/
DES = 'PyoristysMakrot: Pyöristys 10 euron tarkkuuteen';
&tulos = CEIL(&arvo / 10);
&tulos = 10 * (&tulos);
%MEND Pyoristys10e;


/* 6. Pyöristää annetun rahamäärän 100 euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen pyöristetty rahamäärä
		arvo: Rahamaara, joka halutaan pyöristää */

%MACRO Pyoristys100e(tulos, arvo)/
DES = 'PyoristysMakrot: Pyöristys 100 euron tarkkuuteen';
&tulos = CEIL(&arvo / 100);
&tulos = 100 * &tulos;
%MEND Pyoristys100e;