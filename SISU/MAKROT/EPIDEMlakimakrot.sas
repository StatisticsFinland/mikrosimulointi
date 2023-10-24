/**************************************************
* Kuvaus: Epidemiakorvauksen ja epidemiatuen	  *
*		  lains‰‰d‰ntˆ‰ makroina. 				  *	
* Viimeksi p‰ivitetty: 16.12.2020				  *
**************************************************/

/* Tiedosto sis‰lt‰‰ seuraavat makrot:

1. EpidemKorvKS
2. EpidemKorvVS
3. EpidemTuki


/* 1. Epidemiakorvaus kuukaudessa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, epidemiakorvaus kuukaudessa, e/kk
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		perhkoko: Perheen koko */ 
	
%MACRO EpidemKorvKS(tulos, mvuosi, mkuuk, minf, perhkoko)/
DES = "EPIDEM: Epidemiakorvaus kuukausitasolla"; 

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &EPIDEM_PARAM, PARAM.&PEPIDEM); 
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &EPIDEM_MUUNNOS, &minf);	

	&tulos = &EpiKorv * &perhkoko;

%MEND EpidemKorvKS;


/* 2. Epidemiakorvaus vuosikeskiarvona */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, epidemiakorvaus vuosikeskiarvona, e/kk
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		perhkoko: Perheen koko */ 

%MACRO EpidemKorvVS(tulos, mvuosi, minf, perhkoko)/
DES = "EPIDEM: Epidemiakorvaus kuukausitasolla vuosikeskiarvona"; 

	epivuosi = 0;

	%DO kuuk = 1 %TO 12;
		%EpidemKorvKS(epikk, &mvuosi, &kuuk, &minf, &perhkoko); 
		epivuosi = SUM(epivuosi,epikk);
	%END;

	epivuosik = epivuosi / 12;

	&tulos = epivuosik;

	DROP epivuosi epikk epivuosik;

%MEND EpidemKorvVS;


/* 3. Epidemiatuki */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, epidemiatuki, e
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		paivat: P‰ivien m‰‰r‰ joilta saanut epidemiatukea */

%MACRO EpidemTuki(tulos, mvuosi, mkuuk, minf, paivat)/
DES = "EPIDEM: Epidemiatuki"; 

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &EPIDEM_PARAM, PARAM.&PEPIDEM); 
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &EPIDEM_MUUNNOS, &minf);	

	&tulos = &EpiTuki * &paivat;

%MEND EpidemTuki;