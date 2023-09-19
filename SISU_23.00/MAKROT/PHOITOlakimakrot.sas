/******************************************************************** 
* Kuvaus: Kunnallisten p‰iv‰hoitomaksujen lains‰‰d‰ntˆ‰ makroina	*
********************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2. PHoitoMaksuS = P‰iv‰hoitomaksu kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ   	
3. PHoitoMaksuVS = P‰iv‰hoitomaksu kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ   
4. SumPHoitoMaksuS = P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla     	
5. SumPHoitoMaksuVS = P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona
*/

/* 2. T‰m‰ makro laskee yhden lapsen p‰iv‰hoitomaksun kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia
	sisarn: Monesko sisar p‰iv‰hoidossa (nuorin = 1) (HUOM. parametreissa sisar)
	muitalapsia: Perheen muiden alaik‰isten lasten lukum‰‰r‰
	tulo: P‰iv‰hoitomaksun perusteena oleva tulo, e/kk ;

%MACRO PHoitoMaksuS(tulos, mvuosi, mkuuk, minf, puoliso, phlapsia, sisarn, muitalapsia, tulo)/
DES = 'PHOITO: P‰iv‰hoitomaksu kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ';


%HaeParam&TYYPPI(&mvuosi, &mkuuk, &PHOITO_PARAM, PARAM.&PPHOITO);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &PHOITO_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

tulo1 = &tulo;

*Perheen koko aina v‰hint‰‰n 2;
koko = 2; 

IF (&puoliso = 1) THEN koko = koko + 1; 

*Ennen 1.8.2008 perheen koossa otetaan huomioon korkeintaan kaksi p‰iv‰hoitolasta;
IF (&phlapsia > 1) AND kuuid < MDY(8, 1, 2008) THEN koko = SUM(koko, 1);

*1.8.2008 l‰htien perheen koossa otetaan huomioon kaikki alaik‰iset lapset;
IF kuuid >= MDY(8, 1, 2008) THEN koko = sum(koko, &phlapsia, &muitalapsia, -1);

IF koko < 3 THEN DO;
	raja = &PHRaja1;
	kerr = &PHKerr1;
END;

ELSE IF koko = 3 THEN DO;
	raja = &PHRaja2;
	kerr = &PHKerr2;
END;

* Elokuusta 2008 l‰htien lis‰‰ portaita;

ELSE IF koko > 3 AND kuuid < MDY(8, 1, 2008) THEN DO;
	Raja = &PHRaja3;
    Kerr = &PHKerr3;
END;
		
ELSE IF koko = 4 AND kuuid >=  MDY(8, 1, 2008) THEN DO;
	Raja = &PHRaja3;
    Kerr = &PHKerr3;
END;
		
ELSE IF koko = 5 AND kuuid >= MDY(8, 1, 2008) THEN DO;
	raja = &PHRaja4;
    kerr = &PHKerr4;
END;
	
ELSE IF Koko > 5 AND kuuid >= MDY(8, 1, 2008) THEN DO;
	raja = &PHRaja5;
    kerr = &PHKerr5;
END;
			
* PHVahenn-parametrin k‰yttˆ on erilainen ennen 1.8.2008 ja sen j‰lkeen;
* Ennen 8/2008 v‰hennys tuloista;
 
IF kuuid < MDY(8, 1, 2008) THEN DO;
	lukum = &muitalapsia;
	*Jos p‰iv‰hoitolapsia on > 2 ylimenev‰t lapset lis‰t‰‰n "muihin lapsiin";

	IF &PHLapsia > 2 THEN lukum = sum(&muitalapsia, &phlapsia, -2);

	tulo1 = sum(&tulo, -lukum * &PHVahenn);

END;
	   
IF tulo1 < 0 THEN tulo1 = 0;

*PHVahenn-parametrilla suurennetaan tulorajaa 8/2008 l‰htien, jos koko-muuttuja > 6;

IF kuuid >= MDY(8, 1, 2008) AND koko > 6 THEN raja = SUM(raja, (koko - 6) * &PHVahenn);

*Jos pienet tulot, nollamaksu;

IF tulo1 <= raja THEN DO;
	temp = 0; 		
END;

*Tulosidonnaisuus;

ELSE DO;

	IF tulo1 > raja THEN temp = kerr * (tulo1 - raja);

	*Yl‰raja;

	IF temp > &PHYlaraja THEN temp = &PHYlaraja;

	*Alarajan alitus johtaa nollamaksuun;

	IF temp <  &PHAlaraja THEN DO;
 		temp = 0; 
	END;

	*Sisarn-muuttujan mukaan yl‰raja muuttuu, ja lis‰ksi
	 otetaan huomioon mahdollinen alennus;

	ELSE DO;

		IF &sisarn = 1 THEN DO;
			
		END; 

		ELSE DO;

			temp2 = temp;

			IF kuuid < MDY(3, 1, 2017) AND temp2 > &PHYlaraja2 THEN temp2 = &PHYlaraja2;

			*Maaliskuusta 2017 l‰htien toisiksi nuorimman p‰iv‰hoitomaksu on 90% nuorimman lapsen maksusta;

			IF kuuid >= MDY(3, 1, 2017) THEN temp2 = temp * &PHAlennus2;

			IF temp2 < &PHAlaraja THEN temp2 = 0;

			IF &sisarn = 2 THEN DO;
					temp = temp2;
			END;
			ELSE DO;

				alennettu = &PHAlennus3 * temp;

				IF alennettu < &PHAlaraja THEN alennettu = 0;

				IF &sisarn > 2 THEN temp = alennettu; 

			END;
		END;
	END;
END;

&tulos = temp;

DROP kuuid raja kerr temp temp2 alennettu lukum tulo1; 
%MEND PHoitoMaksuS;

/* 3. T‰m‰ makro laskee yhden lapsen p‰iv‰hoitomaksun kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia
	sisarn: Monesko sisar p‰iv‰hoidossa (nuorin = 1) (HUOM. parametreissa sisar)
	muitalapsia: Perheen muiden alaik‰isten lasten lukum‰‰r‰
	tulo: P‰iv‰hoitomaksun perusteena oleva tulo, e/kk ;

%MACRO PHoitoMaksuVS(tulos, mvuosi, minf, puoliso, phlapsia, sisarn, muitalapsia, tulo)/
DES = 'PHOITO: P‰iv‰hoitomaksu kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ';

phmaksu = 0;

%DO i = 1 %TO 12;
	%PHoitoMaksuS(temp, &mvuosi, &i, &minf, &puoliso, &phlapsia, &sisarn, &muitalapsia, &tulo);
	phmaksu = SUM(phmaksu, temp);
%END;

&tulos = phmaksu / 12;
DROP temp phmaksu;
%MEND PHoitoMaksuVS;

/* 4. Makro laskee p‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia, joista maksu perit‰‰n
	sisar: Monesko sisar p‰iv‰hoidossa (nuorin = 1)
	muitalapsia: Onko muita lapsia (0/1)
	tulo: P‰iv‰hoitomaksun perusteena oleva perheen bruttotulo, e/kk;

%MACRO SumPHoitoMaksuS(tulos, mvuosi, mkuuk, minf, puoliso, phlapsia, muitalapsia, tulo)/
DES =  'PHOITO: P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla';

tempx = 0;

DO i = 1 TO &PHLapsia;
	%PHoitoMaksuS(maksu, &mvuosi, &mkuuk, &minf, &puoliso, &phlapsia, i, &muitalapsia, &tulo);
	tempx = SUM(tempx, maksu);
END;

&tulos = tempx;

DROP maksu tempx i;
%MEND SumPHoitoMaksuS;

/* 5. Makro laskee p‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia, joista maksu perit‰‰n
	sisar: Monesko sisar p‰iv‰hoidossa (nuorin = 1)
	muitalapsia: Onko muita lapsia (0/1)
	tulo: P‰iv‰hoitomaksun perusteena oleva perheen bruttotulo, e/kk;

%MACRO SumPHoitoMaksuVS(tulos, mvuosi, minf, puoliso, phlapsia, muitalapsia, tulo)/
DES =  'PHOITO: P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona';

phmaksusum = 0;

%DO i = 1 %TO 12;
	%SumPHoitoMaksuS(temp, &mvuosi, &i, &minf, &puoliso, &phlapsia, &muitalapsia, &tulo);
	phmaksusum = SUM(phmaksusum, temp);
%END;

&tulos = phmaksusum / 12;

DROP temp phmaksusum;
%MEND SumPHoitoMaksuVS;
