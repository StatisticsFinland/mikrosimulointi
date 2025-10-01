/************************************************************ 
* Kuvaus: Ty�nantajamaksujen lakimakrot						*
************************************************************/

/* Tiedosto sis�lt�� seuraavat makrot: 

1. SairVakMaksuKTAS = Ty�nantajan sairausvakuutusmaksu kuukausitasolla
2. SairVakMaksuVTAS = Ty�nantajan sairausvakuutusmaksu kuukausitasolla vuosikeskiarvona
3. TyotVakMaksuKTAS = Ty�nantajan ty�tt�myysvakuutusmaksu kuukausitasolla
4. TyotVakMaksuVTAS = Ty�nantajan ty�tt�myysvakuutusmaksu kuukausitasolla vuosikeskiarvona
5. ElMaksuKTAS = Ty�nantajan el�kevakuutusmaksu kuukausitasolla
6. ElMaksuVTAS = Ty�nantajan el�kevakuutusmaksu kuukausitasolla vuosikeskiarvona
7. RyHeMaksuKTAS = Ty�nantajan ryhm�henkivakuutusmaksu kuukausitasolla
8. RyHeMaksuVTAS = Ty�nantajan ryhm�henkivakuutusmaksu kuukausitasolla vuosikeskiarvona
9. TaTuMaksuKTAS = Ty�nantajan tapaturmavakuutusmaksu kuukausitasolla 
10. TaTuMaksuVTAS = Ty�nantajan tapaturmavakuutusmaksu kuukausitasolla vuosikeskiarvona */




/* 1. Sairausvakuutusmaksu kuukausitasolla, ty�nantaja. Makro laskee ty�nantajan maksaman sairausvakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Sairausvakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO SairVakMaksuKTAS(tulos, mvuosi, mkuuk, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan sairausvakuutusmaksu kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_PARAM, PARAM.&PTAMAKSU);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_MUUNNOS, &inf);


	IF 16 LE &ikavu LE 67 AND &svpalkka GT 0 THEN DO;

			IF &sektori = 3 THEN savamaksu = (&SavaKun/100) * &svpalkka;
			IF &sektori = 8 THEN savamaksu = (&SavaVal/100) * &svpalkka;
			ELSE savamaksu = (&SavaYks/100) * &svpalkka;

	END;

	&tulos = savamaksu;

DROP savamaksu;

%MEND SairVakMaksuKTAS;


/* 2. Sairausvakuutusmaksu kuukausitasolla vuosikeskiarvona, ty�nantaja. Makro laskee ty�nantajan maksaman sairausvakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Sairausvakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO SairVakMaksuVTAS (tulos, mvuosi, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan sairausvakuutusmaksu kuukausitasolla vuosikeskiarvona';

sava = 0;

%DO i = 1 %TO 12; 
 %SairVakMaksuKTAS (temp, &mvuosi, &i, &inf, &ikavu, &svpalkka, &sektori);
 sava = SUM(sava, temp);
%END;


&tulos = sava / 12; 
DROP sava temp;

%MEND SairVakMaksuVTAS;


/* 3. Ty�tt�myysvakuutusmaksu kuukausitasolla, ty�nantaja. Makro laskee ty�nantajan maksaman ty�tt�myysvakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ty�tt�myysvakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot, e/v
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);


%MACRO TyotVakMaksuKTAS (tulos, mvuosi, mkuuk, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan ty�tt�myysvakuutusmaksu kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_PARAM, PARAM.&PTAMAKSU);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_MUUNNOS, &inf);

IF &mvuosi >= 2022 THEN DO;

	IF 18 LE &ikavu LE 65 AND &svpalkka GT 0 AND &sektori NE 8 THEN DO;
			&tulos = (&TyVa/100) * &svpalkka;
			END; 
			ELSE DO;
			&tulos =0;
			END;
END;

ELSE DO;


IF 17 LE &ikavu LE 65 AND &svpalkka GT 0 AND &sektori NE 8 THEN DO;
		&tulos = (&TyVa/100) * &svpalkka;
		END; 
		ELSE DO;
		&tulos =0;
		END;
END;

%MEND TyotVakMaksuKTAS;


/* 4. Ty�tt�myysvakuutusmaksu vuosikeskiarvo kuukausitasolla, ty�nantaja. Makro laskee ty�nantajan maksaman ty�tt�myysvakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ty�tt�myysvakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot, e/v
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO TyotVakMaksuVTAS (tulos, mvuosi, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan ty�tt�myysvakuutusmaksu kuukausitasolla vuosikeskiarvona';

tyotvmaksu = 0;

%DO i = 1 %TO 12; 
 %TyotVakMaksuKTAS (temp, &mvuosi, &i, &inf, &ikavu, &svpalkka, &sektori);
 tyotvmaksu = SUM(tyotvmaksu, temp);
%END;

&tulos = tyotvmaksu / 12; 
DROP tyotvmaksu temp;

%MEND TyotVakMaksuVTAS;


/*5. Ty�el�kevakuutusmaksu kuukausitasolla, ty�nantaja. Makro laskee ty�nantajan maksaman el�kevakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ty�el�kevakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori:Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO ElMaksuKTAS (tulos, mvuosi, mkuuk, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan el�kevakuutusmaksu kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_PARAM, PARAM.&PTAMAKSU);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_MUUNNOS, &inf);

IF &mvuosi LE 2016 AND 18 LE &ikavu LE 67 AND &svpalkka GT 0 THEN DO;

		IF &sektori EQ 3 THEN &tulos = (&KuEL/100) * &svpalkka;
		ELSE IF &sektori EQ 8 THEN &tulos = (&VaEL/100) * &svpalkka;
		ELSE  &tulos = (&TyEL/100) * &svpalkka;
	END;
ELSE IF &mvuosi GT 2016 AND 17 LE &ikavu LE 67 AND &svpalkka GT 0 THEN DO;

		IF &sektori EQ 3 THEN &tulos = (&KuEL/100) * &svpalkka;
		ELSE IF &sektori EQ 8 THEN &tulos = (&VaEL/100) * &svpalkka;
		ELSE  &tulos = (&TyEL/100) * &svpalkka;
	END;
ELSE DO;
	&tulos = 0; 
END;


%MEND ElMaksuKTAS;


/*6. Ty�el�kevakuutusmaksu kuukausitasolla vuosikeskiarvona, ty�nantaja. Makro laskee ty�nantajan maksaman el�kevakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ty�el�kevakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	ikavu: Ik�, vuosia
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori:Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);


%MACRO ElMaksuVTAS (tulos, mvuosi, inf, ikavu, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan el�kevakuutusmaksu kuukausitasolla vuosikeskiarvona';

elmaksuV = 0;

%DO i = 1 %TO 12; 
 	%ElMaksuKTAS (temp, &mvuosi, &i, &inf, &ikavu, &svpalkka, &sektori);
 	elmaksuV = SUM(elmaksuV, temp);
%END;


&tulos = elmaksuV / 12; 
DROP elmaksuV temp;

%MEND ElMaksuVTAS;


/* 7. Ryhm�henkivakuutus kuukausitasolla ty�nantaja. Makro ottaa huomioon ty�nantajan maksaman ryhm�henkivakuutusmaksun vuodesta 2010 */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ryhm�henkivakuutus 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO RyHeMaksuKTAS (tulos, mvuosi, mkuuk, inf, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan ryhm�henkivakuutusmaksu kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_PARAM, PARAM.&PTAMAKSU);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_MUUNNOS, &inf);

	IF &svpalkka > 0 THEN DO;

		IF &sektori NE 3 OR &sektori NE 8  
			THEN &tulos = (&RyHeYks/100) * &svpalkka;
		ELSE IF &sektori = 3 
			THEN &tulos = (&RyHeKun/100) * &svpalkka;

	END;

%MEND RyHeMaksuKTAS;


/* 8. Ryhm�henkivakuutus kuukausitasolla vuosikeskiarvona, ty�nantaja. Makro ottaa huomioon ty�nantajan maksaman ryhm�henkivakuutusmaksun vuodesta 2010 */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Ryhm�henkivakuutus 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);


%MACRO RyHeMaksuVTAS (tulos, mvuosi, inf, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan ryhm�henkivakuutusmaksu kuukausitasolla vuosikeskiarvona';

rymaksu = 0;

%DO i = 1 %TO 12; 
 %RyHeMaksuKTAS (temp, &mvuosi, &i, &inf, &svpalkka, &sektori);
 rymaksu = SUM(rymaksu, temp);
%END;


&tulos = rymaksu / 12; 
DROP rymaksu temp;

%MEND RyHeMaksuVTAS;


/* 9. Tapaturmavakuutusmaksu kuukausitasolla, ty�nantaja. Makro laskee ty�nantajan maksaman tapaturmavakuutusmaksun 
	vuodesta 2010 l�htien */
  
*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Tapaturmavakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);

%MACRO TaTuMaksuKTAS (tulos, mvuosi, mkuuk, inf, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan tapaturmavakuutusmaksu kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_PARAM, PARAM.&PTAMAKSU);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TAMAKSU_MUUNNOS, &inf);

IF &svpalkka GT 0 AND &sektori NE 8 THEN DO;
	&tulos = (&TaTu/100) * &svpalkka;
	END;
ELSE DO;
	&tulos = 0; 
END;

%MEND TaTuMaksuKTAS;


/* 10. Tapaturmavakuutusmaksu kuukausitasolla vuosikeskiarvona, ty�nantaja. Makro laskee ty�nantajan maksaman tapaturmavakuutusmaksun 
	vuodesta 2010 l�htien */

*Makron parametrit:
  	tulos: Makron tulosmuuttuja, Tapaturmavakuutusmaksu 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	inf: Deflaattori eurom��r�isten parametrien kertomiseksi
	svpalkka: Ty�nantajamaksujen pohjalla olevat palkkatulot
	sektori: Ty�nantajasektori (1=yritykset, 2=rah. ja vak.laitokset, 3=kunta, kuntien liikelaitokset,
		4=voittoa tavoittelemattomat, 5=kotitaloudet, 6=ulkomaat, 8=valtio ja sos rahastot, 9=as oy);


%MACRO TaTuMaksuVTAS (tulos, mvuosi, inf, svpalkka, sektori)/
DES = 'TAMAKSU: Ty�nantajan tapaturmavakuutusmaksu kuukausitasolla vuosikeskiarvona';

tatmaksu = 0; 
%DO i = 1 %TO 12; 
 	%TaTuMaksuKTAS (temp, &mvuosi, &i, &inf, &svpalkka, &sektori);
	tatmaksu = SUM(tatmaksu, temp);
%END;

&tulos = tatmaksu / 12; 
DROP temp tatmaksu; 	

%MEND TaTuMaksuVTAS;


