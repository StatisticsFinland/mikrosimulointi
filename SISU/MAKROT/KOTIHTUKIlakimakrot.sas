/******************************************************************** 
* Kuvaus: Kotihoidontuen lains‰‰d‰ntˆ‰ makroina						* 
* Viimeksi p‰ivitetty: 6.3.2019									*
********************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2. KotihTukiKaava1 = Kotihoidontuki kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997
3. KotihTukiKaava2 = Kotihoidontuki kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien
4. KotihTukiKS = Kotihoidontuki kuukausitasolla, vanha ja uusi lains‰‰d‰ntˆ
5. KotihTukiVS = Kotihoidontuki kuukausitasolla vuosikeskiarvona, vanha ja uusi lains‰‰d‰ntˆ
6. KotihTukiTuloS = K‰‰nteisfunktio kotihoidontuen perusteena olevan kuukausitulon laskemiseksi
7. HoitoRahaKS = Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla
8. HoitoRahaVS = Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla vuosikeskiarvona
9. HoitoLisaKS = Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla
10. HoitoLisaVS = Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla vuosikeskiarvona
11. HoitoLisaTuloS = K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 1)
12. HoitoLisaTuloKS = K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 2)
13.1 OsitHoitRahaS = Osittainen hoitoraha kuukausitasolla 
13.2 OsitHoitRahaTunnS = Osittainen hoitoraha kuukausitasolla tuntitiedolla 
13.3 JoustHoitRahaTunnS = Joustava hoitoraha kuukausitasolla tuntitiedolla 	
14.1 OsitHoitRahaVS = Osittainen hoitoraha kuukausitasolla vuosikeskiarvona 
14.2 OsitHoitRahaTunnVS = Osittainen hoitoraha kuukausitasolla vuosikeskiarvona tuntitiedolla  
14.3 JoustHoitRahaTunnVS = Joustava hoitoraha kuukausitasolla vuosikeskiarvona tuntitiedolla   

/* 2. Makro laskee kotihoidontuen kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997.
      Kaavaan lis‰tty muiden kotona hoidettavien alle kouluik‰isten laskeminen */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiKaava1(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, bruttotulo, nettotulo)/
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

*Peruosa;

temp = sum(&Perus, &sisaria * &SisarKerr * &Perus, &muuallekouluik * &SisarKerr * &Perus);

*Lis‰osa;

lisa = &Kerr1 * &Perus;

*Erilainen tulok‰site ennen vuotta 1991;

tulo1 = &bruttotulo;

IF &mvuosi < 1991 THEN tulo1 = &nettotulo;
	
IF (tulo1 <= &KHraja1) THEN temp = temp + lisa;

ELSE IF tulo1 > &KHraja1 THEN DO;
	lisa = MAX(SUM(lisa, -&Kerr2 *(tulo1 - &KHraja1)), 0);
	temp = SUM(temp, lisa);
END;

&tulos = temp; 

DROP temp lisa tulo1; 

%MEND KotihTukiKaava1;


/* 3. Makro laskee kotihoidontuen kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	tulo: Perheen bruttotulot, e/kk;

%MACRO KotihTukiKaava2(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, tulo)/
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

*Rajataan hoitolis‰n perhekoossa laskettavien lasten lukum‰‰r‰ kahteen;

lapslkm = SUM(&sisaria, 1, &muuallekouluik);
IF lapslkm > 2 THEN lapslkm = 2;

*Apumuuttuja;

koko1 = SUM(&koko, -&sisaria,-&muuallekouluik,-1, lapslkm);

*Hoitoraha;

temp = SUM(&Perus, &sisaria * &Sisar, &muuallekouluik * &SisarMuu);

*koko-muuttuja rajataan tapauksiin 2, 3 ja 4;

IF (koko1 > 4) THEN koko1 = 4;

IF (koko1 < 2) THEN koko1 = 2;

*Tulorajat ja kertoimet;

SELECT (koko1);
	WHEN(2) DO;
		raja = &KHraja1; kerr = &Kerr1;
	END;
	WHEN(3) DO;
		raja = &KHraja2; kerr = &Kerr2;
	END;
   	WHEN(4)  DO;
		raja = &KHraja3; kerr = &Kerr3;
	END;
END;
  		
*Hoitolis‰;
	
IF (&tulo <= raja) THEN hlisa = &Lisa;

*Alenema tulojen suuruuden mukaan;

ELSE IF (&tulo > raja) THEN hlisa = SUM(&Lisa, -kerr * (&tulo - raja));

IF (hlisa < 0) THEN hlisa = 0;

temp = SUM(temp, hlisa);

&tulos = temp; 

DROP temp raja kerr hlisa koko1 lapslkm; 

%MEND KotihTukiKaava2;


/* 	4. Makro laskee kotihoidontuen kuukausitasolla sek‰ vanhalla ett‰ uudella lains‰‰d‰nnˆll‰ */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/
DES ='KOTIHTUKI: Kotihoidontuki kuukausitasolla, vanha ja uusi lains‰‰d‰ntˆ';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid >= MDY(8, 1, 1997) THEN DO;
	%KotihTukiKaava2(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo);
END;

*Vanha kaava ennen elokuuta 1997;

ELSE IF kuuid < MDY(8, 1, 1997) THEN DO;	
	%KotihTukiKaava1(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &bruttotulo, &nettotulo);	
END;

DROP kuuid;

%MEND KotihTukiKS;


/* 5. T‰m‰ makro laskee kotihoidon tuen kuukausitasolla vuosikeskiarvona, sek‰ vanhalla ett‰ uudella lains‰‰d‰nnˆll‰ */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiVS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla vuosikeskiarvona, vanha ja uusi lains‰‰d‰ntˆ';

raha = 0;

%DO i = 1 %TO 12;
	%KotihTukiKS(temp, &mvuosi, &i, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;

DROP raha temp ;
%MEND KotihTukiVS;


/* 6. Makro laskee k‰‰nteisfunktiona kotihoidon tuen perusteena olevan kuukausitulon */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuen perusteena oleva tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	tuki: Kotihoidontuki, e/kk;

%MACRO KotihTukiTuloS(tulos, mvuosi, mkuuk, sisaria, muuallekouluik, koko, tuki)/
DES = 'KOTIHTUKI: K‰‰nteisfunktio kotihoidontuen perusteena olevan kuukausitulon laskemiseksi';

testix = 0;
tuki1 = &tuki;

*T‰ysi tuki: jos tuki1-muuttuja on yht‰ suuri tai suurempi kuin t‰ysi tuki, annetaan tuloksi 0;

%KotihTukiKS(vert1, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, 0, 0);

IF SUM(tuki1, -vert1) >= 0 THEN testix = 0;

ELSE DO;
		
	*Minimituki;
				
	%KotihTukiKS(vert2, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, 99999, 99999);

	vert = vert2;
								
	DO j = 10 TO 0 BY -1 UNTIL (vert > tuki1);
		testix = j * 1000;
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO k = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000,  k * 100);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;
			
	DO m = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100, m * 10);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO n = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100,  m * 10, n);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO p = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100, m * 10, n, p/10);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;
				
END;

IF testix < 0 THEN testix = 0;

&tulos = testix; 

DROP vert1 vert2 vert j k m n p testix tuki1;

%MEND KotihTukiTuloS;


/* 7. Makro laskee kuukausitasolla hoitorahan (perusosa) kotihoidon tuen minimitasoksi */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitorahan perusosa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	brutto: Perheen bruttotulot, e/kk
	netto: Perheen nettotulot, e/kk;

%MACRO HoitoRahaKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik)/
DES = 'KOTIHTUKI: Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla';

%KotihTukiKS(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, 0, 99999, 99999);

%MEND HoitoRahaKS;


/* 8. Makro laskee kuukausitasolla hoitorahan (perusosa) kotihoidon tuen minimitasoksi */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitorahan perusosa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	brutto: Perheen bruttotulot, e/kk
	netto: Perheen nettotulot, e/kk;

%MACRO HoitoRahaVS(tulos, mvuosi, minf, sisaria, muuallekouluik)/
DES = 'KOTIHTUKI: Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla vuosikeskiarvona';

%KotihTukiVS(&tulos, &mvuosi, &minf, &sisaria, &muuallekouluik, 0, 99999, 99999);

%MEND HoitoRahaVS;


/* 9. Makro laskee hoitolis‰n (lis‰osa) kotihoidontuen ja hoitorahan erotuksena kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO HoitoLisaKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/
DES = 'KOTIHTUKI: Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla';

temp = 0;

%KotihTukiKS(temp1, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
%HoitoRahaKS(temp2, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik);

temp = SUM(temp1, -temp2);

IF temp < 0 THEN temp = 0;

&tulos = Temp;

DROP temp;
%MEND HoitoLisaKS;


/* 10. Makro laskee hoitolis‰n (lis‰osa) kotihoidontuen ja hoitorahan erotuksena kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO HoitoLisaVS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/
DES = 'KOTIHTUKI: Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla';

temp = 0;

%KotihTukiVS(temp1, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
%HoitoRahaVS(temp2, &mvuosi, &minf, &sisaria, &muuallekouluik);

temp = sum(temp1, -temp2);

IF temp < 0 THEN temp = 0;

&tulos = temp;

DROP temp;
%MEND HoitoLisaVS;


/* 11. Makro laskee k‰‰nteisfunktiona hoitolis‰n (lis‰osan) perusteena olevan kuukausitulon (versio 1) */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰n perusteena olevan tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muita alle kouluik‰isi‰ lapsia
	koko: Perheen koko
	hoitolisa: Hoitolis‰, e/kk;   

%MACRO HoitoLisaTuloS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, hoitolisa)/
DES = 'KOTIHTUKI: K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 1)';

testix = 0; 
hoitolisa1 = &HoitoLisa; *Apumuuttuja hoitolisa1;

*T‰ysi tuki, jos hoitolisa1-muuttuja on yht‰ suuri tai suurempi, annetaan tuloksi 0;

%HoitoLisaVS(vert1, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, 0, 0);
erotus = hoitolisa1 - vert1;
IF erotus >= 0 THEN DO;
	testix = 0;
END;
ELSE DO;

	*Minimituki, jos hoitolisa1-muuttuja on minimitukea pienempi, korjataan se minimituen suuruiseksi;

	%HoitoLisaVS(Vert2, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, 99999, 99999);
	erotus = hoitolisa1 - vert2;
	IF erotus < 0 THEN hoitolisa1 = vert2; 
						
	*Testataan tulov‰li 10000 - 0 suurimmasta pienimp‰‰n tuhatlukuun;
	DO j = 10 TO 1 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*Sitten 100 euron v‰lein;
	DO k = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*10 euron v‰lein;
	DO m = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + m * 10;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*1 euron v‰lein;
	DO n = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + n;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*0.1 euron v‰lein;
	DO p = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + n + p/10;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	IF testix < 0 THEN &tulos = 0;

END; 

&tulos = testix;

DROP testix erotus hoitolisa1 vert1 vert2 ;
%MEND HoitoLisaTuloS;


/* 12. Makro laskee k‰‰nteisfunktiona hoitolis‰n (lis‰osan) perusteena olevan kuukausitulon (versio 2) */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰n perusteena olevan tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muita alle kouluik‰isi‰ lapsia
	koko: Perheen koko
	hoitolisa: Hoitolis‰, e/kk;  

%MACRO HoitoLisaTuloKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, hoitolisa)/
DES = 'KOTIHTUKI: K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 2)';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid >= MDY(8, 1, 1997) THEN hoitolisa1 = &Lisa;
ELSE hoitolisa1 = &Kerr1 * &Perus; 

*Rajataan hoitolis‰n perhekoossa laskettavien lasten lukum‰‰r‰ kahteen;

lapslkm = SUM(&sisaria, 1, &muuallekouluik);
IF lapslkm > 2 THEN lapslkm = 2;

*Apumuuttuja;

koko1 = SUM(&koko, -&sisaria,-&muuallekouluik,-1, lapslkm);

*Hoitoraha;

temp = SUM(&Perus, &sisaria * &Sisar, &muuallekouluik * &SisarMuu);


IF koko1 > 4 THEN koko1 = 4;
IF koko1 < 2 THEN koko1 = 2;

SELECT (koko1);
	WHEN(2) DO;
		raja = &KHraja1; kerr = &Kerr1;
	END;
	WHEN(3) DO;
		raja = &KHraja2; kerr = &Kerr2;
	END;
   	WHEN(4)  DO;
		raja = &KHraja3; kerr = &Kerr3;
	END;
END;
	
IF kuuid < MDY(8, 1, 1997) THEN DO;
	raja = &KHraja1;
	kerr = &Kerr2;
END;

nollaraja = raja + hoitolisa1 / kerr;

/* Jos hoitolis‰ on maksimihoitolis‰, annetaan tuloksi 0 */
IF &hoitolisa >= hoitolisa1 THEN &tulos = 0;

/* Jos hoitolis‰ on 0, annetaan tuloksi 99999 */
ELSE IF &hoitolisa = 0 THEN &tulos = 99999;

/* Muussa tapauksessa p‰‰tell‰‰n k‰‰nteisesti */
ELSE &tulos = SUM(hoitolisa1, -&hoitolisa, kerr * raja) / kerr; 

DROP kuuid hoitolisa1 koko1 raja kerr nollaraja lapslkm;
%MEND HoitoLisaTuloKS;


/* 13.1 Makro laskee osittaisen hoitorahan kuukausitasolla */ 

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi;

%MACRO OsitHoitRahaS(tulos, mvuosi, mkuuk, minf)/
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

*Elokuusta 1997 alkaen;

IF kuuid >= MDY(8, 1, 1997) THEN DO;
	&tulos = &OsRaha;
END;

*Ennen elokuuta 1997;

ELSE IF kuuid < MDY(8, 1, 1997) THEN DO;
	&tulos = &OsKerr * &Perus;
END;

DROP kuuid;
	
%MEND OsitHoitRahaS;


/* 13.2 Makro laskee osittaisen hoitorahan kuukausitasolla tuntitiedolla */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tunnit: Osittaisen hoitorahan saajan viikkotyˆtuntien m‰‰r‰;

%MACRO OsitHoitRahaTunnS(tulos, mvuosi, mkuuk, minf, tunnit)/
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF &tunnit > &OsittRaja THEN DO;
	&tulos = 0;
END;

*Elokuusta 1997 alkaen;

ELSE IF kuuid >= MDY(8, 1, 1997) THEN DO;
	&tulos = &OsRaha;
END;

*Ennen elokuuta 1997;

ELSE IF kuuid < MDY(8, 1, 1997) THEN DO;
	&tulos = &OsKerr * &Perus;
END;

DROP kuuid;
	
%MEND OsitHoitRahaTunnS;


/* 13.3 Makro laskee joustavan hoitorahan kuukausitasolla tuntitiedolla */ 

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tunnit: Joustavan hoitorahan saajan viikkotyˆtuntien m‰‰r‰;

%MACRO JoustHoitRahaTunnS(tulos, mvuosi, mkuuk, minf, tunnit)/
DES = 'KOTIHTUKI: Joustava hoitoraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_PARAM, PARAM.&PKOTIHTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KOTIHTUKI_MUUNNOS, &minf);

IF &tunnit <= &JsRaja1 THEN DO;
	&tulos = &JsRaha1;
END;
ELSE IF &JsRaja1 < &tunnit AND &tunnit <= &JsRaja2 THEN DO;
	&tulos = &JsRaha2;
END;
ELSE IF &JsRaja2 < &tunnit THEN DO;
	&tulos = 0;
END;

%MEND JoustHoitRahaTunnS;


/* 14.1 Makro laskee osittaisen hoitorahan kuukausitasolla vuosikeskiarvona */ 

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi;

%MACRO OsitHoitRahaVS(tulos, mvuosi, minf)/
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla vuosikeskiarvona';

oshoiraha = 0;

%DO i = 1 %TO 12;
	%OsitHoitRahaS(temp, &mvuosi, &i, &minf);
	oshoiraha = SUM(oshoiraha, temp);
%END;

&tulos = oshoiraha / 12;

drop temp oshoiraha;
%MEND OsitHoitRahaVS;


/* 14.2 Makro laskee osittaisen hoitorahan kuukausitasolla vuosikeskiarvona tuntitiedolla */ 

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tunnit: Osittaisen hoitorahan saajan viikkotyˆtuntien m‰‰r‰;

%MACRO OsitHoitRahaTunnVS(tulos, mvuosi, minf, tunnit)/
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla vuosikeskiarvona';

oshoiraha = 0;

%DO i = 1 %TO 12;
	%OsitHoitRahaTunnS(temp, &mvuosi, &i, &minf, &tunnit);
	oshoiraha = SUM(oshoiraha, temp);
%END;

&tulos = oshoiraha / 12;

drop temp oshoiraha;
%MEND OsitHoitRahaTunnVS;


/* 14.3 Makro laskee joustavan hoitorahan kuukausitasolla vuosikeskiarvona tuntitiedolla */ 

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tunnit: Joustavan hoitorahan saajan viikkotyˆtuntien m‰‰r‰;

%MACRO JoustHoitRahaTunnVS(tulos, mvuosi, minf, tunnit)/
DES = 'KOTIHTUKI: Joustava hoitoraha kuukausitasolla vuosikeskiarvona';

jshoiraha = 0;

%DO i = 1 %TO 12;
	%JoustHoitRahaTunnS(temp, &mvuosi, &i, &minf, &tunnit);
	jshoiraha = SUM(jshoiraha, temp);
%END;

&tulos = jshoiraha / 12;

drop temp jshoiraha;
%MEND JoustHoitRahaTunnVS;
