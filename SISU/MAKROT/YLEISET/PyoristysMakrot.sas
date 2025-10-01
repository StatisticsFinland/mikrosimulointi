/*********************************************
* Kuvaus: Makroja raham��rien py�rist�miseen *
* Viimeksi paivitetty: 24.1.2018             *
*********************************************/

/* Tiedosto sis�lt�� seuraavat makrot:
1. PyoristysSentinTarkkuuteen = Py�rist�� annetun raham��r�n sentin tarkkuuteen
2. PyoristysEuronTarkkuuteen = Py�rist�� annetun raham��r�n euron tarkkuuteen
3. Pyoristys100mk = Py�rist�� annetun raham��r�n 100 markan tarkkuuteen
4. Pyoristys1000mk = Py�rist�� annetun raham��r�n 1000 markan tarkkuuteen
5. Pyoristys10e = Py�rist�� annetun raham��r�n 10 euron tarkkuuteen
6. Pyoristys100e = Py�rist�� annetun raham��r�n 100 euron tarkkuuteen
*/

/* 1. Py�rist�� annetun raham��r�n sentin tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, sentin tarkkuuteen py�ristetty raham��r�
		rahamaara: Rahamaara, joka halutaan py�rist�� */

%MACRO PyoristysSentinTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: Py�rist�� annetun raham��r�n sentin tarkkuuteen";

	&tulos = ROUND(&rahamaara, 0.01); 	

%MEND PyoristysSentinTarkkuuteen;


/* 2. Py�rist�� annetun raham��r�n euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen py�ristetty raham��r�
		rahamaara: Rahamaara, joka halutaan py�rist�� */

%MACRO PyoristysEuronTarkkuuteen(tulos, rahamaara)/
DES = "PyoristysMakrot: Py�rist�� annetun raham��r�n euron tarkkuuteen";

	&tulos = ROUND(&rahamaara, 1);

%MEND PyoristysEuronTarkkuuteen;


/* 3. Py�rist�� annetun raham��r�n 100 markan tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen py�ristetty raham��r�
		arvo: Rahamaara, joka halutaan py�rist�� */

%MACRO Pyoristys100mk (tulos, arvo)/
DES = 'PyoristysMakrot: Py�ristys 100 markan tarkkuuteen';
&tulos = &euro * &arvo / 100;
&tulos = CEIL(&tulos);
&tulos = 100 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys100mk;


/* 4. Py�rist�� annetun raham��r�n 1000 markan tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen py�ristetty raham��r�
		arvo: Rahamaara, joka halutaan py�rist�� */

%MACRO Pyoristys1000mk (tulos, arvo)/
DES = 'PyoristysMakrot: Py�ristys 1000 markan tarkkuuteen';
&tulos = &euro * &arvo / 1000;
&tulos = CEIL(&tulos);
&tulos = 1000 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys1000mk;


/* 5. Py�rist�� annetun raham��r�n 10 euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen py�ristetty raham��r�
		arvo: Rahamaara, joka halutaan py�rist�� */

%MACRO Pyoristys10e(tulos, arvo)/
DES = 'PyoristysMakrot: Py�ristys 10 euron tarkkuuteen';
&tulos = CEIL(&arvo / 10);
&tulos = 10 * (&tulos);
%MEND Pyoristys10e;


/* 6. Py�rist�� annetun raham��r�n 100 euron tarkkuuteen */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, euron tarkkuuteen py�ristetty raham��r�
		arvo: Rahamaara, joka halutaan py�rist�� */

%MACRO Pyoristys100e(tulos, arvo)/
DES = 'PyoristysMakrot: Py�ristys 100 euron tarkkuuteen';
&tulos = CEIL(&arvo / 100);
&tulos = 100 * &tulos;
%MEND Pyoristys100e;