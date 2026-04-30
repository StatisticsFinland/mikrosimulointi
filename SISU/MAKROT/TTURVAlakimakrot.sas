/***********************************************************
* Kuvaus: Työttömyysturvan lainsäädäntöä makroina          *
***********************************************************/ 

/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2. AnsioSidKS = Ansiosidonnainen päiväraha kuukausitasolla
3. AnsioSidVS = Ansiosidonnainen päiväraha kuukausitasolla vuosikeskiarvona
4. TyomTukiKS = Työmarkkinatuki kuukausitasolla
5. TyomTukiVS = Työmarkkinatuki kuukausitasolla vuosikeskiarvona
6. PerusPRahaKS =  Peruspäiväraha kuukausitasolla
7. PerusPRahaVS = Peruspäiväraha kuukausitasolla vuosikeskiarvona
8. SoviteltuKS = Soviteltu työttömyyspäiväraha kuukausitasolla
9. SoviteltuVS = Soviteltu työttömyyspäiväraha kuukausitasolla vuosikeskiarvona   
10. AnsioSidPalkkaS = Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla
11. AnsioSidPalkkaVanhaS = Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla (makro aineiston laskennallisten muuttujien päättelyyn)
12. YPitoKorvS = Ylläpitokorvaukset kuukausitasolla
13. YPitoKorvVS = Ylläpitokorvaukset kuukausitasolla vuosikeskiarvona    
14. VuorVapKorvKS = Vuorotteluvapaakorvaukset kuukausitasolla
15. VuorVapKorvVS = Vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona     
16. SovPalkkaS = Sovitellun päivärahan perusteena oleva palkka kuukausitasolla
17. TarvHarkTuloS = Työmarkkinatuen tarveharkinnan perusteena oleva tulo kuukausitasolla
18. OsittTmTTuloS = Osittaisen työmarkkinatuen perusteena oleva vanhempien tulo kuukausitasolla
19. AnsioSidKestoRaj = Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus
20. AnsioSidKestoRajKK = Kuukausimallin Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus
21. Omavastuupv = Omavastuupäivien simulointi (kuukausimalli)
22. TyossaoloehtoKK = Työssäoloehto (kuukausimalli)
23. YleistukiKS = Yleistuki kuukausitasolla
24. YleistukiVS = Yleistuki kuukausitasolla vuosikeskiarvona
*/ 


/*  2. Makro laskee ansiosidonnaisen työttömyyspäivärahan kuukausitasolla */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, ansiosidonnainen työttömyyspäiväraha, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
  	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotettuun päivärahaan
	muutturva: Onko oikeus muutosturvaan
	lisapaiv: onko oikeus lisäpäiviin (0/1)
	kuukpalkka: Työttömyyttä edeltävä kuukausipalkka
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	maxtklaskr: Ansiopäivärahapäivien korkein lukumäärä aineistovuodelta
	edtklaskr: Ansiopäivärahapäivien lukumäärä edellisen vuoden viimeiseltä kvartaalilta
	aktiivi: Aktiivimallin leikkuri;
	
%MACRO AnsioSidKS(tulos, mvuosi, mkuuk, minf, lapsia, oikeuskor, muutturva, lisapaiv, kuukpalkka, vahsosetuus, maxtklaskr, edtklaskr, aktiivi=0)/ 
DES = 'TTURVA: Ansiosidonnainen päiväraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

*Lapsikorotukset;
IF &lapsia <= 0 THEN lapsikor = 0;
ELSE IF &lapsia < 2 THEN lapsikor = &TTLaps1;
ELSE IF &lapsia < 3 THEN lapsikor = &TTLaps2;
ELSE lapsikor = &TTLaps3;

*Kuukausipalkkaan tehtävä vähennys;
tyotulo = (1 - &VahPros) * (&kuukpalkka / &TTPAIVIA);

*Korotetun päivärahan ja työllistymisohjelmalisän prosentit. Tässä on varmistettu että korotuksia ei tule kun ne eivät ole olleet voimassa;
IF &oikeuskor NE 0 AND &mvuosi >= 2003 AND &mvuosi <=2024 THEN DO;
	pros1 = &ProsKor1;
	pros2 = &ProsKor2;
	raja = tyotulo;
END;
ELSE IF &muutturva NE 0 AND kuuid >= MDY(7, 1, 2005) AND &mvuosi <= 2013 THEN DO;
	pros1 = &MuutTurvaPros1;
	pros2 = &MuutTurvaPros2;
	raja = tyotulo;
END;
ELSE IF &lisapaiv NE 0 AND 2003 <= &mvuosi <= 2009 THEN DO; 
	pros1 = &TTPros1;
	pros2 = &ProsKor2;
	raja = &ProsYlaRaja * tyotulo;
END;
ELSE DO;
	pros1 = &TTPros1;
	pros2 = &TTPros2;
	raja = &ProsYlaRaja * tyotulo;
END;

*Ansiosidonnaisen päivärahan varsinainen laskukaava;
IF (1 - &VahPros) * &kuukpalkka < &TTTaite * &TTPerus THEN temp = SUM(&TTPerus, pros1 * SUM(tyotulo, -&TTPerus), lapsikor);
ELSE temp = SUM(&TTPerus, pros1 * SUM(&TTTaite * &TTPerus / &TTPAIVIA, -&TTPerus), pros2 * SUM(tyotulo, -&TTTaite * &TTPerus / &TTPAIVIA), lapsikor);

*Ansiopäivärahojen porrastus;
IF &maxtklaskr > 0 THEN DO;

	/* Nollataan edellisen vuoden päivät, jos laskuri on nollaantunut. */
	IF &edtklaskr > &maxtklaskr THEN EdPaivat = 0;
	ELSE EdPaivat = &edtklaskr;

	/* Lasketaan päivät aineistovuoden puolella. Jos erotus on nolla annetaan arvoksi nykyisen vuoden maksimiarvo. */
	IF SUM(&maxtklaskr, -EdPaivat) <= 0 THEN NykPaivat = &maxtklaskr;
	ELSE NykPaivat = SUM(&maxtklaskr, -EdPaivat); 

	/* Lasketaan kertoimet kertyneiden päivien mukaisesti */
	maksimi1 = MAX(0, SUM(&PorrasPv1, -EdPaivat));  				/* Maksimimäärä päiviä ilman leikkausta */
	maksimi2 = MAX(0, SUM(&PorrasPv2, -&PorrasPv1, -MAX(0, SUM(EdPaivat, -&PorrasPv1)))); 	/* Maksimimäärä päiviä ensimmäisellä portaalla */

	AprLkmNormi = MIN(maksimi1, NykPaivat); 						/* Ei-leikattavien päivien lukumäärä */
	AprLkm1 = MAX(0, MIN(maksimi2, SUM(NykPaivat, -AprLkmNormi))); 	/* Ensimmäisen porrastuksen jälkeisten päivien lukumäärä */
	AprLkm2 = SUM(NykPaivat, -AprLkmNormi, -AprLkm1); 				/* Toisen porrastuksen jälkeisten päivien lukumäärä */

	APRKerroin = (APRlkmNormi*1 + APRlkm1*&PorrasKerroin1 + APRlkm2*&PorrasKerroin2) / NykPaivat;
	
	IF APRKerroin > 0 THEN temp = APRKerroin * temp;

END;

*Maksimipäiväraha;
IF temp > raja THEN temp = raja;

*Minimipäiväraha;
IF &mvuosi >= 2012 AND (&muutturva NE 0 OR &oikeuskor NE 0) THEN temp = MAX(temp, SUM(&TTPerus, lapsikor, &KorotusOsa));
ELSE temp = MAX(temp, SUM(&TTPerus, lapsikor));

*Aktiivimallin leikkuri;
IF &aktiivi = 1 AND 2018 =< &mvuosi <= 2019 THEN temp = SUM(temp * SUM(1, -&AlePros)); 

temp = SUM(temp * &TTPAIVIA, -&vahsosetuus);
IF temp < 0 THEN temp = 0;

&tulos = temp;
DROP temp kuuid tyotulo raja lapsikor pros1 pros2 EdPaivat NykPaivat maksimi1 maksimi2 AprLkmNormi AprLkm1 AprLkm2 APRKerroin; 
%MEND AnsioSidKS;


/*  3. Makro laskee ansiosidonnaisen työttömyyspäivärahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, ansiosidonnainen työttömyyspäiväraha, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
  	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotettuun päivärahaan
	lisapaiv: Onko oikeus ansiopäivärahojen korotettuihin lisäpäiviin
	muutturva: Onko oikeus työllistymisohjelmalisään
	kuukpalkka: Työttömyyttä edeltävä kuukausipalkka
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	maxtklaskr: Ansiopäivärahapäivien korkein lukumäärä aineistovuodelta
	edtklaskr: Ansiopäivärahapäivien lukumäärä edellisen vuoden viimeiseltä kvartaalilta
	aktiivi: Aktiivimallin leikkuri;

%MACRO AnsioSidVS(tulos, mvuosi, minf, lapsia, oikeuskor, muutturva, lisapaiv, kuukpalkka, vahsosetuus, maxtklaskr, edtklaskr, aktiivi=0)/ 
DES = 'TTURVA: Ansiosidonnainen päiväraha kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%AnsioSidKS(temp, &mvuosi, &i, &minf, &lapsia, &oikeuskor, &muutturva, &lisapaiv, &kuukpalkka, &vahsosetuus, &maxtklaskr, &edtklaskr, aktiivi=&aktiivi);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP temp vuosipraha;
%MEND AnsioSidVS;


/*  4. Makro laskee työmarkkinatuen kuukausitasolla */

*Makron parametrit:  
	tulos: Makron tulosmuuttuja, työmarkkinatuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tarvhark: Onko kyseessä tarveharkittu työmarkkinatuki (0/1)
	tyossaoloehto: Täyttääkö työssäoloehdon (1=kyllä, 0=ei)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	huoll: Muiden huollettavien lkm perheessä, jos kyseessä osittainen tmtuki
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tmtuki, e/kk
	vanhomaishp: Vanhempien omaishoidon tuen hoitopalkkiot, jos kyseessä osittainen tmtuki, e/kk
	oikeuskor: Onko oikeus korotusosaan (0/1)
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	aktiivi: Aktiivimallin leikkuri;

%MACRO TyomTukiKS(tulos, mvuosi, mkuuk, minf, tarvhark, tyossaoloehto, puoliso, lapsia, huoll, omatulo, puoltulo, vanhtulot, vanhomaishp, oikeuskor, vahsosetuus, aktiivi=0)/
DES = 'TTURVA: Työmarkkinatuki kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid >= mdy(5, 1, 2026) THEN &tulos = 0;
ELSE DO;

	*Lapsikorotukset;
	IF &lapsia <= 0 THEN lapsikor = 0;
	ELSE IF &lapsia < 2 THEN lapsikor = &TyomLapsPros * &TTLaps1;
	ELSE IF &lapsia < 3 THEN lapsikor = &TyomLapsPros * &TTLaps2;
	ELSE lapsikor = &TyomLapsPros * &TTLaps3;

	*Täysmääräinen työmarkkinatuki;
	temp = &TTPAIVIA * SUM(&TTPerus, lapsikor);
	IF &oikeuskor NE 0 AND &mvuosi >= 2010 AND &mvuosi <= 2024 THEN temp = SUM(temp, &TTPAIVIA * &KorotusOsa);

	*Tarveharkittu tuki;

	IF &tarvhark NE 0 THEN DO;

		*Perheellisen tarveharkinta;
		IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
			raja = SUM(&RajaHuolt, &lapsia * &RajaLaps );

			*Puolison tuloista tehtävä vähennys;
			*Vuonna 2013 työttömyysturvan tarveharkinta puolisojen tulojen perusteella poistui; 
			IF &puoliso NE 0 AND &mvuosi < 2013 THEN DO;
				tulo =  SUM(&puoltulo, -&PuolVah);
				IF tulo < 0 THEN tulo =  0;
			END;

			tulo = SUM(tulo, &omatulo);

			IF tulo > raja THEN temp = SUM(temp, -&TarvPros2 * SUM(tulo, -raja));
		END;

		*Yksinäisen tarveharkinta;
		ELSE IF &omatulo > &RajaYks THEN temp = SUM(temp, -&TarvPros1 * SUM(&omatulo -&RajaYks));

		IF temp < 0 THEN temp = 0;
	END;

	*Osittainen tuki, jos ei ole täyttänyt työssäoloehtoa ja asuu vanhempien luona; 
	IF &tyossaoloehto = 0 THEN DO;

		IF &mvuosi >= 2003 THEN DO;
			raja = SUM(&OsRaja, &huoll * &OsRajaKor);

			*Vuodesta 2025 lähtien vanhempien omaishoidon tuen hoitopalkkiot vähennetään vanhempien tuloista;
			IF &mvuosi >= 2025 THEN vanhempientulot = MAX(SUM(&vanhtulot, -&vanhomaishp), 0);
			ELSE vanhempientulot = &vanhtulot;

				*Tietyn rajan jälkeen vanhemman tulot pienentävät osittaista työmarkkinatukea. Tuki on kuitenkin minimissään tietty prosentti täydestä tuesta.;
				IF vanhempientulot > raja THEN DO;
					testi = temp;
					temp  = SUM(temp, -&OsTarvPros * SUM(vanhempientulot, -raja));
					IF temp < &OsPros * testi THEN temp = &OsPros * testi;
				END;

		END;

		*Ennen vuotta 2003 osittainen tyomtukeen ei vaikuttanut vanhempien tulot vaan se oli aina tietty osuus täysmääräisestä.;
		ELSE temp = &OsPros * temp;
	END;


	*Aktiivimallin leikkuri;
	IF &aktiivi = 1 AND 2018 =< &mvuosi <= 2019 THEN temp = SUM(temp * SUM(1, -&AlePros)); 

	* Lopullisen tuen määrä on pienempi kahdesta vaihtoehdosta: ;
	* 1. Tarveharkittu tuki 2. Täysi tuki, josta vähennetty muut sosiaalietuudet ;
	temp = MIN(temp, (&TTPAIVIA * SUM(&TTPerus, lapsikor) - &vahsosetuus));

	
	IF temp < 0 THEN temp = 0;
	IF &mvuosi < 1994 THEN temp = .;

	&tulos = temp;
	DROP raja testi temp tulo lapsikor vanhempientulot;

END;

%MEND TyomTukiKS;


/*  5. Makro laskee työmarkkinatuen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:  
	tulos: Makron tulosmuuttuja, työmarkkinatuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tarvhark: Onko kyseessä tarveharkittu työmarkkinatuki (0/1)
	ositt: Onko kyseessä osittainen työmarkkinatuki (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	huoll: Muiden huollettavien lkm perheessä, jos kyseessä osittainen tmtuki
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tmtuki, e/kk
	vanhomaishp: Vanhempien omaishoidon tuen hoitopalkkiot, jos kyseessä osittainen tmtuki, e/kk
	oikeuskor: Onko oikeus korotusosaan (0/1)
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	aktiivi: Aktiivimallin leikkuri;

%MACRO TyomTukiVS(tulos, mvuosi, minf, tarvhark, ositt, puoliso, lapsia, huoll, omatulo, puoltulo, vanhtulot, vanhomaishp, oikeuskor, vahsosetuus, aktiivi=0)/
DES = 'TTURVA: Työmarkkinatuki kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%TyomTukiKS(temp, &mvuosi, &i, &minf, &tarvhark, &ositt, &puoliso, &lapsia, &huoll, &omatulo, &puoltulo, &vanhtulot, &vanhomaishp, &oikeuskor, &vahsosetuus, aktiivi=&aktiivi);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP vuosipraha temp;
%MEND TyomTukiVS;


/*  6. Makro laskee peruspäivärahan kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, peruspäiväraha, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    tarvhark: Onko kyseessä tarveharkittu Peruspäiväraha (0/1)
	muutturva: Onko oikeus muutosturvaan (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	aktiivi: Aktiivimallin leikkuri;

%MACRO PerusPRahaKS(tulos, mvuosi, mkuuk, minf, tarvhark, muutturva, puoliso, lapsia, omatulo, puoltulo, vahsosetuus, aktiivi=0)/
DES = 'TTURVA: Peruspäiväraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid >= mdy(5, 1, 2026) THEN &tulos = 0;
ELSE DO;

	*Lapsikorotukset;
	IF &lapsia <= 0 THEN lapsikor = 0;
	ELSE IF &lapsia < 2 THEN lapsikor = &TTLaps1;
	ELSE IF &lapsia < 3 THEN lapsikor = &TTLaps2;
	ELSE lapsikor = &TTLaps3;

	*Täysmääräinen peruspäiväraha;
	temp = &TTPAIVIA * SUM(&TTPerus, lapsikor);
	IF &muutturva NE 0 THEN temp = SUM(temp, &TTPAIVIA * &KorotusOsa);

	*Tarveharkittu tuki, voimassa ennen vuotta 1994;
	IF &tarvhark NE 0 AND &mvuosi < 1994 THEN DO;

		*Perheellisen tarveharkinta;
		IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
			raja = SUM(&RajaHuolt, &lapsia * &RajaLaps );

			IF &puoliso NE 0 THEN DO;
				tulo =  SUM(&puoltulo, -&PuolVah);
				IF tulo < 0 THEN tulo =  0;
			END;

			tulo = SUM(tulo, &omatulo);

			IF tulo > raja THEN temp = SUM(temp, -&TarvPros2 * SUM(tulo, -raja));
		END;

		*Yksinäisen tarveharkinta;
		ELSE IF &omatulo > &RajaYks THEN temp = SUM(temp, -&TarvPros1 * SUM(&omatulo -&RajaYks));

		IF temp < 0 THEN temp = 0;
	END;

	*Aktiivimallin leikkuri;
	IF &aktiivi = 1 AND 2018 =< &mvuosi <= 2019 THEN temp = SUM(temp * SUM(1, -&AlePros)); 

	* Lopullisen tuen määrä on pienempi kahdesta vaihtoehdosta: ;
	* 1. Tarveharkittu tuki 2. Täysi tuki, josta vähennetty muut sosiaalietuudet ;
	temp = MIN(temp, (&TTPAIVIA * SUM(&TTPerus, lapsikor) - &vahsosetuus));

	IF temp < 0 THEN temp = 0;

	&tulos = temp;
	DROP raja temp tulo lapsikor;

END;

%MEND PerusPRahaKS;


/*  7. Makro laskee peruspäivärahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, peruspäiväraha, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    tarvhark: Onko kyseessä tarveharkittu Peruspäiväraha (0/1)
	muutturva: Onko oikeus muutosturvaan (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk
	aktiivi: Aktiivimallin leikkuri;

%MACRO PerusPRahaVS(tulos, mvuosi, minf, tarvhark, muutturva, puoliso, lapsia, omatulo, puoltulo, vahsosetuus, aktiivi=0)/
DES = 'TTURVA: Peruspäiväraha kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%PerusPRahaKS(temp, &mvuosi, &i, &minf, &tarvhark, &muutturva, &puoliso, &lapsia, &omatulo, &puoltulo, &vahsosetuus, aktiivi=&aktiivi);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP temp vuosipraha;
%MEND PerusPRahaVS;


/*  8. Makro laskee sovitellun työttömyysetuuden kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, soviteltu työttömyysetuus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    ansiosid: Onko kyseessä ansiosidonnainen työttömyysetuus (0/1)
	oikeuskor: Onko oikeus korotettuun päivärahaan (0/1)
	lapsia: Lapsien lkm perheessä 
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	tyotulo: Työtulo, joka on sovittelun perusteena, e/kk
	rahapalkka: Ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk
	koultuki: Onko kyseessä koulutustuki (0/1)
	vuorsov: Onko kyseessä soviteltu vuorottelukorvaus (0/1)
	aktiivi: Aktiivimallin leikkuri
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO SoviteltuKS(tulos, mvuosi, mkuuk, minf, ansiosid, oikeuskor, lapsia, praha, tyotulo, rahapalkka, koultuki, vuorsov=0, aktiivi=0, vahsosetuus=0)/
DES = 'TTURVA: Soviteltu työttömyyspäiväraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF &koultuki NE 0 THEN DO;
	sovsuoja = &SovSuojaKoul;
	sovpros = &SovProsKoul;
END;
ELSE IF &vuorsov NE 0 THEN DO;
	sovsuoja = 0;
	sovpros = &SovPros;
END;
ELSE DO;
	sovsuoja = &SovSuoja;
	sovpros = &SovPros;
END;

* Sovitellun laskukaava. Ei sovitella jos alle suojaosan;
IF &tyotulo < sovsuoja THEN temp2 = &praha;

* Muuten sovitellaan;
ELSE DO; 
* Soviteltu työmarkkinatuki, peruspäiväraha tai yleistuki;
	temp2 = &praha - (sovpros * (&tyotulo - sovsuoja));
	temp2 = MAX(temp2, 0);
	* Soviteltu ansiopäiväraha;
	IF &ansiosid NE 0 THEN DO;
		* Sovitellussa ansiopäivärahassa määritetään maksimit ja minimit maksettavalle tuelle;
		IF &oikeuskor NE 0 AND &mvuosi > 2002 THEN ylaraja = 1;
		ELSE ylaraja = &SovRaja;
		* Soviteltu ansiopäiväraha ja työtulot eivät voi ylittää päivärahan perusteena olevan palkan määrää;
		IF SUM(temp2, &tyotulo) > ylaraja * (1 - &VahPros) * &rahapalkka 
			THEN temp2 = SUM(ylaraja * (1 - &VahPros) * &rahapalkka, -&tyotulo);
		* Soviteltu ansiopäiväraha on aina vähintään perusosan suuruinen;
		IF kuuid >= mdy(5, 1, 2026) THEN temp2 = MAX(temp2, (&TTPerus * &TTPAIVIA - (sovpros * &tyotulo)));
		ELSE DO;
			* Ennen yleistukea ansiopäiväraha oli aina vähintään peruspäivärahan suuruinen;
			%PerusPRahaKS(perus, &mvuosi, &mkuuk, &minf, 0, &oikeuskor, 0, &lapsia, 0, 0, 0, aktiivi=&aktiivi);
			temp2 = MAX(temp2, perus - sovpros * (&tyotulo - sovsuoja) * (&tyotulo > sovsuoja));
		END;
	END;
END;

temp2 = temp2 - &vahsosetuus;
&tulos = MAX(temp2, 0);

DROP ylaraja sovsuoja sovpros temp2 perus;
%MEND SoviteltuKS;


/*  9. Makro laskee sovitellun työttömyysetuuden kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, soviteltu työttömyysetuus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    ansiosid: Onko kyseessä ansiosidonnainen työttömyysetuus (0/1)
	oikeuskor: Onko oikeus korotettuun päivärahaan (0/1)
	lapsia: Lapsien lkm perheessä 
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	tyotulo: Työtulo, joka on sovittelun perusteena, e/kk
	rahapalkka: Ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk
	koultuki: Onko kyseessä koulutustuki (0/1)
	vuorsov: Onko kyseessä soviteltu vuorottelukorvaus (0/1)
	aktiivi: Aktiivimallin leikkuri
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO SoviteltuVS(tulos, mvuosi, minf, ansiosid, oikeuskor, lapsia, praha, tyotulo, rahapalkka, koultuki, vuorsov=0, aktiivi=0, vahsosetuus=0)/
DES = 'TTURVA: Soviteltu työttömyyspäiväraha kuukausitasolla vuosikeskiarvona';

sovtyot = 0;

%DO i = 1 %TO 12;
	%SoviteltuKS(temp, &mvuosi, &i, &minf, &ansiosid, &oikeuskor, &lapsia, &praha, &tyotulo, &rahapalkka, &koultuki, vuorsov=&vuorsov, aktiivi=&aktiivi, vahsosetuus=&vahsosetuus);
	sovtyot = SUM(sovtyot, temp);
%END;

&tulos = sovtyot / 12;
DROP temp sovtyot;
%MEND SoviteltuVS;


/*  10. Makro laskee ansiosidonnaisen päivärahan perusteena olevan palkan kuukausitasolla (iteroiva käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
 	lapsia: Lapsien lkm perheessä 
	vuosipraha: Saadun ansiosidonnaisen päivärahan määrä, e/vuosi
	tayspv: Täyden tuen päivien määrä vuoden aikana
	korpv: Korotetun tuen päivien määrä vuoden aikana
	mutpv: Muutosturvapäivien määrä vuoden aikana
	vuor: Jos kyseessä on vuorotteluvapaakorvaus (0/1)
	vuorkor: Jos vuorotteluvapaakorvaus on korotettu (0/1)
	sovtayspv: Soviteltujen ei-korotettujen päivien määrä
	sovkorpv: Soviteltujen korotettujen päivien määrä
	sovtulo: Sovittelun perusteena oleva työtulo (e/kk);

%MACRO AnsioSidPalkkaS(tulos, mvuosi, mkuuk, lapsia, vuosipraha, tayspv, korpv, mutpv, vuor, vuorkor, sovtayspv, sovkorpv, sovmutpv, sovtulo)/
DES = 'TTURVA: Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1); /* INF = 1 */

tayspr = 0; 
korpr = 0; 
mutpr = 0;
vuosipraha = &vuosipraha;

IF &vuor NE 0 THEN DO;	
	IF &vuorkor NE 0 THEN korpros = &VuorKorvPros2;
	ELSE korpros = &VuorKorvPros;
	vuosipraha = &vuosipraha / korpros;
END;

%AnsioSidKS(testi, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, 0, 0, 0, 0);
IF SUM(&tayspv, &korpv, &mutpv, &sovtayspv, &sovkorpv, &sovmutpv) <= 0 THEN &tulos = 0; 
ELSE DO;
	DO i = 0 to 100 UNTIL (apr >= vuosipraha);
		IF MAX(&tayspv, &sovtayspv) > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, i * 1000, 0, 0, 0); 
			IF &sovtayspv THEN DO; %SoviteltuKS(sovtayspr, &mvuosi, &mkuuk, 1, 1, 0, &lapsia, tayspr, &sovtulo, i * 1000, 0); END;
			tayspr = SUM(&tayspv * tayspr, &sovtayspv * sovtayspr) / &TTPAIVIA;
		END;
		IF MAX(&korpv, &sovkorpv) > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, i * 1000, 0, 0, 0);
			IF &sovkorpv THEN DO; %SoviteltuKS(sovkorpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, korpr, &sovtulo, i * 1000, 0); END;
			korpr = SUM(&korpv * korpr, &sovkorpv * sovkorpr) / &TTPAIVIA;
		END;
		IF MAX(&mutpv, &sovmutpv) > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, i * 1000, 0, 0, 0);
			IF &sovmutpv THEN DO; %SoviteltuKS(sovmutpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, mutpr, &sovtulo, i * 1000, 0); END;
			mutpr = SUM(&mutpv * mutpr, &sovmutpv * sovmutpr) / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO j = -9 to 9 UNTIL (apr >= vuosipraha);
		IF MAX(&tayspv, &sovtayspv) > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100), 0, 0, 0); 
			IF &sovtayspv THEN DO; %SoviteltuKS(sovtayspr, &mvuosi, &mkuuk, 1, 1, 0, &lapsia, tayspr, &sovtulo, (i * 1000 + j * 100), 0); END;
			tayspr = SUM(&tayspv * tayspr, &sovtayspv * sovtayspr) / &TTPAIVIA;
		END;
		IF MAX(&korpv, &sovkorpv) > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100), 0, 0, 0);
			IF &sovkorpv THEN DO; %SoviteltuKS(sovkorpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, korpr, &sovtulo, (i * 1000 + j * 100), 0); END;
			korpr = SUM(&korpv * korpr, &sovkorpv * sovkorpr) / &TTPAIVIA;
		END;
		IF MAX(&mutpv, &sovmutpv) > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100), 0, 0, 0);
			IF &sovmutpv THEN DO; %SoviteltuKS(sovmutpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, mutpr, &sovtulo, (i * 1000 + j * 100), 0); END;
			mutpr = SUM(&mutpv * mutpr, &sovmutpv * sovmutpr) / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO k = -9 to 9 UNTIL (apr >= vuosipraha);
		IF MAX(&tayspv, &sovtayspv) > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0); 
			IF &sovtayspv THEN DO; %SoviteltuKS(sovtayspr, &mvuosi, &mkuuk, 1, 1, 0, &lapsia, tayspr, &sovtulo, (i * 1000 + j * 100 + k * 10), 0); END;
			tayspr = SUM(&tayspv * tayspr, &sovtayspv * sovtayspr) / &TTPAIVIA;
		END;
		IF MAX(&korpv, &sovkorpv) > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0);
			IF &sovkorpv THEN DO; %SoviteltuKS(sovkorpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, korpr, &sovtulo, (i * 1000 + j * 100 + k * 10), 0); END;
			korpr = SUM(&korpv * korpr, &sovkorpv * sovkorpr) / &TTPAIVIA;
		END;
		IF MAX(&mutpv, &sovmutpv) > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0);
			IF &sovmutpv THEN DO; %SoviteltuKS(sovmutpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, mutpr, &sovtulo, (i * 1000 + j * 100 + k * 10), 0); END;
			mutpr = SUM(&mutpv * mutpr, &sovmutpv * sovmutpr) / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO m = -9 to 9 UNTIL (apr >= vuosipraha);
		IF MAX(&tayspv, &sovtayspv) > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0); 
			IF &sovtayspv THEN DO; %SoviteltuKS(sovtayspr, &mvuosi, &mkuuk, 1, 1, 0, &lapsia, tayspr, &sovtulo, (i * 1000 + j * 100 + k * 10 + m), 0); END;
			tayspr = SUM(&tayspv * tayspr, &sovtayspv * sovtayspr) / &TTPAIVIA;
		END;
		IF MAX(&korpv, &sovkorpv) > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0);
			IF &sovkorpv THEN DO; %SoviteltuKS(sovkorpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, korpr, &sovtulo, (i * 1000 + j * 100 + k * 10 + m), 0); END;
			korpr = SUM(&korpv * korpr, &sovkorpv * sovkorpr) / &TTPAIVIA;
		END;
		IF MAX(&mutpv, &sovmutpv) > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0);
			IF &sovmutpv THEN DO; %SoviteltuKS(sovmutpr, &mvuosi, &mkuuk, 1, 1, 1, &lapsia, mutpr, &sovtulo, (i * 1000 + j * 100 + k * 10 + m), 0); END;
			mutpr = SUM(&mutpv * mutpr, &sovmutpv * sovmutpr) / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	&tulos = MAX(0, i * 1000 + j * 100 + k * 10 + m);
END;

DROP tayspr korpr mutpr sovtayspr sovkorpr sovmutpr apr i j k m vuosipraha korpros testi lapsikor;
%MEND AnsioSidPalkkaS;


/*  11. Makro laskee ansiosidonnaisen päivärahan perusteena olevan palkan kuukausitasolla (iteroiva käänteisfunktio) 
	    (Makroa käytetään aineiston laskennallisten muuttujien päättelyssä) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
 	lapsia: Lapsien lkm perheessä 
	vuosipraha: Saadun ansiosidonnaisen päivärahan määrä, e/vuosi
	tayspv: Täyden tuen päivien määrä vuoden aikana
	korpv: Korotetun tuen päivien määrä vuoden aikana
	mutpv: Muutosturvapäivien määrä vuoden aikana
	vuor: Jos kyseessä on vuorotteluvapaakorvaus (0/1)
	vuorkor: Jos vuorotteluvapaakorvaus on korotettu (0/1);

%MACRO AnsioSidPalkkaVanhaS(tulos, mvuosi, mkuuk, lapsia, vuosipraha, tayspv, korpv, mutpv, vuor, vuorkor)/
DES = 'TTURVA: Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla (laskennallisten muuttujien päättelyyn)';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1); /* INF = 1 */

tayspr = 0; 
korpr = 0; 
mutpr = 0;
vuosipraha = &vuosipraha;

IF &vuor NE 0 THEN DO;	
	IF &vuorkor NE 0 THEN korpros = &VuorKorvPros2;
	ELSE korpros = &VuorKorvPros;
	vuosipraha = &vuosipraha / korpros;
END;

%AnsioSidKS(testi, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, 0, 0, 0, 0);
IF SUM(&tayspv, &korpv, &mutpv) <= 0 OR (vuosipraha / SUM(&tayspv, &korpv, &mutpv) * &TTPAIVIA <= testi) THEN &tulos = 0;
ELSE DO;
	DO i = 0 to 100 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, i * 1000, 0, 0, 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, i * 1000, 0, 0, 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, i * 1000, 0, 0, 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO j = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100), 0, 0, 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100), 0, 0, 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100), 0, 0, 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO k = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10), 0, 0, 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO m = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10 + m), 0, 0, 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	&tulos = (i * 1000 + j * 100 + k * 10 + m);
END;

DROP tayspr korpr mutpr apr i j k m vuosipraha korpros testi lapsikor;
%MEND AnsioSidPalkkaVanhaS;


/*  12. Makro laskee ylläpitokorvaukset kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ylläpitokorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	oikeuskor: Onko oikeus korotettuun ylläpitokorvaukseen (0/1);

%MACRO YPitoKorvS(tulos, mvuosi, mkuuk, minf, oikeuskor)/
DES = 'TTURVA: Ylläpitokorvaukset kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

&tulos = &TTPAIVIA * &YPiToK * ((&oikeuskor NE 0) + 1);

%MEND YPitoKorvS;


/*  13. Makro laskee ylläpitokorvaukset kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ylläpitokorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	oikeuskor: Onko oikeus korotettuun ylläpitokorvaukseen (0/1);

%MACRO YPitoKorvVS(tulos, mvuosi, minf, oikeuskor)/
DES = 'TTURVA: Ylläpitokorvaukset kuukausitasolla vuosikeskiarvona';

ypito = 0;

%DO i = 1 %TO 12;
	%YPitoKorvS(temp, &mvuosi, &i, &minf, &oikeuskor);
	ypito = SUM(ypito, temp);
%END;

&tulos = ypito / 12;
DROP temp ypito;
%MEND YPitoKorvVS;


/*  14. Makro laskee vuorotteluvapaakorvaukset kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, vuorotteluvapaakorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	perust: Onko perusturvan vuorotteluvapaakorvaus (0/1)
	korotus: Onko kyseessä korotettu korvaus (0/1)
	palkka: Korvauksen perusteena oleva palkka, e/kk
	spalkka: Sovitellun vuorotteluvapaakorvauksen perusteena oleva palkka, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO VuorVapKorvKS(tulos, mvuosi, mkuuk, minf, perust, korotus, palkka, spalkka=0, vahsosetuus=0)/
DES = 'TTURVA: Vuorotteluvapaakorvaukset kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

IF &perust NE 0 THEN DO;
	%PerusPRahaKS(temp1, &mvuosi, &mkuuk, &minf, 0, 0, 0, 0, 0, 0, 0);
END;

ELSE DO;
	%AnsioSidKS(temp1, &mvuosi, &mkuuk, &minf, 0, 0, 0, 0, &palkka, 0, 0, 0);
END;

*Lasketaan soviteltu päiväraha, jos aineistossa sovittelun perusteena oleva palkka;
IF &spalkka > 0 THEN DO;
	%SoviteltuKS(temp, &mvuosi, 1, &INF, (&perust=0), 0, 0, temp1, &spalkka, &palkka, 0, vuorsov=1);
END;

ELSE DO;
	temp = temp1;
END;

temp = temp -&vahsosetuus;
IF temp < 0 THEN temp = 0;

*Vuorottelukorvaus on tietty osuus siitä työttömyysetuudesta, johon olisi oikeutettu työttömänä;
temp = temp * ((&korotus NE 0) * &VuorKorvPros2 + (&korotus = 0) * &VuorKorvPros);

IF &mvuosi IN (1996,1997) AND temp > &VuorKorvYlaRaja THEN temp = &VuorKorvYlaRaja;


&tulos = temp;
DROP temp temp1;
%MEND VuorVapKorvKS;


/*  15. Makro laskee vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, vuorotteluvapaakorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	perust: Onko perusturvan vuorotteluvapaakorvaus (0/1)
	korotus: Onko kyseessä korotettu korvaus (0/1)
	palkka: Korvauksen perusteena oleva palkka, e/kk
	spalkka: Sovitellun vuorotteluvapaakorvauksen perusteena oleva palkka, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO VuorVapKorvVS(tulos, mvuosi, minf, perust, korotus, palkka, spalkka=0, vahsosetuus=0)/
DES = 'TTURVA: Vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona';

vuorvapkorv = 0;

%DO i = 1 %TO 12;
	%VuorVapKorvKS(temp, &mvuosi, &i, &minf, &perust, &korotus, &palkka, spalkka=&spalkka, vahsosetuus=&vahsosetuus);
	vuorvapkorv = SUM(vuorvapkorv, temp);
%END;

&tulos = vuorvapkorv / 12;
DROP temp vuorvapkorv;
%MEND VuorVapKorvVS;


/*  16. Makro laskee sovittelun päivärahan perusteena olevan tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, sovittelun päivärahan perusteena oleva tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	koul: Onko kyseessä koulutustuki (0/1)
	sovpraha: Sovitellun päivärahan määrä (e/kk)
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	lapsia: Lapsien lkm perheessä
	rahapalkka: Työttömyyttä edeltävä kuukausipalkka ansioturvassa, e/kk
	oikeuskor: Onko oikeus korotettuun päivärahaan (sis. muutosturvalisä);

%MACRO SovPalkkaS(tulos, mvuosi, mkuuk, koul, sovpraha, praha, lapsia, rahapalkka, oikeuskor)/
DES = 'TTURVA: Sovitellun päivärahan perusteena oleva palkka kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1); /* INF = 1 */

IF &koul NE 0 THEN DO;
	sovsuoja = &SovSuojaKoul;
	sovpros = &SovProsKoul;
END;

ELSE DO;
	sovsuoja = &SovSuoja;
	sovpros = &SovPros;
END;

* Laskentakaava normaalitilanteessa;
IF sovpros NE 0 THEN temp3 = (&praha - &sovpraha + (sovpros * sovsuoja)) / sovpros;

IF &rahapalkka NE 0 THEN DO;
	IF &oikeuskor NE 0 AND &mvuosi > 2002 THEN ylaraja = 1;
	ELSE ylaraja = &SovRaja;

	* Jos normaalitilanteen mukaan päätellyllä sovittelupalkalla laskettu soviteltu päiväraha alittaa todellisen sovitellun päivärahan,
	ollaan todennäköisesti ylärajalla. Tällöin sovittelupalkka ja soviteltu päiväraha ovat yhteensä yhtä suuret kuin etuuden perusteena
	oleva palkka (kerrottuna ylärajaparametrilla);
	%SoviteltuKS(test, &mvuosi, &mkuuk, 1, 1, &oikeuskor, &lapsia, &praha, temp3, &rahapalkka, &koul);
	IF ROUND(SUM(test, -&sovpraha), 0.01) < 0 THEN DO;
		temp3 = SUM(ylaraja * (1 - &VahPros) * &rahapalkka, - &sovpraha);

		* Jos tähän asti päätellyllä sovittelupalkalla laskettu soviteltu päiväraha ylittää todellisen sovitellun päivärahan,
		ollaan todennäköisesti tilanteessa, jossa henkilö saa ansiopäivärahaa peruspäivärahan suuruisena. Tällöin lasketaan sovittelupalkka
		normaalikaavalla peruspäivärahan määrän perusteella;
		%SoviteltuKS(test2, &mvuosi, &mkuuk, 1, 1, &oikeuskor, &lapsia, &praha, temp3, &rahapalkka, &koul);
		IF ROUND(SUM(test2, -&sovpraha), 0.01) > 0 THEN DO;
			%PerusPRahaKS(perus, &mvuosi, &mkuuk, 1, 0, &oikeuskor, 0, &lapsia, 0, 0, 0);
			 IF sovpros NE 0 THEN temp3 = SUM(perus, -&sovpraha, sovpros * sovsuoja) / sovpros;
		END;
	END;
END;

IF temp < 0 THEN temp3 = 0;
IF &sovpraha >= &praha THEN temp3 = 0;
IF &mvuosi < 1997 then temp3=.;

&tulos = temp3;
DROP sovsuoja sovpros temp3 ylaraja test test2;
%MEND SovPalkkaS;


/*  17. Makro laskee tarveharkinnan perusteena olevan tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, tarveharkinnan perusteena oleva tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotusosaan (0/1)
	tmtuki: Tarveharkitun työmarkkinatuen määrä, e/kk;

%MACRO TarvHarkTuloS(tulos, mvuosi, mkuuk, puoliso, lapsia, oikeuskor, tmtuki)/
DES = 'TTURVA: Työmarkkinatuen tarveharkinnan perusteena oleva tulo kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1); /* INF = 1 */

%TyomTukiKS(taysi, &mvuosi, &mkuuk, 1, 0, 0, 0, &lapsia, 0, 0, 0, 0, 0, &oikeuskor, 0);

IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
	vah= &RajaHuolt + &lapsia * &RajaLaps;
	tarvpros = &TarvPros2;
END;

ELSE DO; 
	vah = &RajaYks;
	tarvpros = &TarvPros1;
END;

IF &puoliso NE 0 THEN vah = vah + &PuolVah;
IF tarvpros > 0 THEN temp = (taysi - &tmtuki + (tarvpros * vah)) / tarvpros;

IF &tmtuki >= taysi OR temp < 0 THEN temp = 0;

&tulos = temp;
DROP taysi tarvpros vah temp;
%MEND TarvHarkTuloS;


/*  18. Makro laskee osittaisen työmarkkinatuen perusteena olevan vanhempien tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, työmarkkinatuen perusteena oleva vanhempien tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    huoll: Muiden huollettavien lkm perheessä
	oikeuskor: Onko oikeus korotusosaan (0/1)
	tmtuki: Osittaisen työmarkkinatuen määrä, e/kk;

%MACRO OsittTmTTuloS(tulos, mvuosi, mkuuk, huoll, oikeuskor, tmtuki)/
DES = 'TTURVA: Osittaisen työmarkkinatuen perusteena oleva vanhempien tulo kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1); /* INF = 1 */

%TyomTukiKS(taysi, &mvuosi, &mkuuk, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, &oikeuskor, 0);

raja = (&OsRaja + (&huoll * &OsRajaKor));
temp = SUM((&OsTarvPros * raja), taysi, -&tmtuki) / &OsTarvPros;

IF &tmtuki >= &OsPros * taysi AND &tmtuki < taysi THEN &tulos = temp;
ELSE IF &tmtuki < &OsPros * taysi THEN &tulos = 99999999;
ELSE &tulos = 0;

DROP raja taysi temp;
%MEND OsittTmTTuloS;


/*  19. Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus  */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, siirtyvät päivät ("netto") (neg. arvo tarkoittaa lisätyt päivät)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	kertymapv: Ansiopäivärahan kertymä ns. nettona eli sovitellut päivät kokonaisina
	tyohistv: Henkilön työhistoria vuosina
	lasktyohistv: Henkilön laskennallinen työhistoria vuosina lisäpäiväoikeutta varten (vuositulojen jako 510:llä)
	taytkk: kuukausi jolloin kertymä on tullut täyteen (1-12, . jos ei ole täyttynyt, 99 jos täyttynyt aineistossa muttei simuloidussa lainsäädännössä, -99 jos lisäpäiväoikeus jo ed. vuonna)
	ikavu: ikä vuosina vuoden lopussa
	ikakk: ikävuoden ylttävät kuukaudet vuoden lopussa (0-11)
	tmtukipv: työmarkkinatukipäivät nettona eli sovitellut päivät kokonaisina
	tyooloehto: täyttääkö työoloehdon (0/1)
	vuorkorv: onko kyseessä vuorottelukorvauksen rajaus (0/1)
;

%MACRO AnsioSidKestoRaj(tulos, mvuosi, mkuuk, kertymapv, tyohistv, lasktyohistv, taytkk, ikavu, ikakk, tmtukipv, tyooloehto, vuorkorv)/
DES = 'TTURVA: Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1);

*Ansiopäivärahan rajoitus;
IF NOT &vuorkorv THEN DO;

	IF &mvuosi >= 2017 AND &lasktyohistv >= &LisaPvTyoHist AND &tyooloehto = 1 AND (&ikavu > &KestoIkaRaja OR (&ikavu = &KestoIkaRaja AND &taytkk > 12 - ikakk)) THEN ENIMMAISKESTO = &AnsioSidKesto3;
	ELSE IF &mvuosi >= 2014 AND &tyohistv <= &KestoLyhEhtoV THEN ENIMMAISKESTO = &AnsioSidKesto2;
	ELSE ENIMMAISKESTO = &AnsioSidKesto;

	*Ansiopäivärahoja lisää, jos henkilö täyttää vaaditun tyohistoriaehdon ja lisäpäiväiän ennen kuin enimmäisaika täyttynyt tarkasteluvuonna;
	IF &taytkk > 0 AND &lasktyohistv >= &LisaPvTyohist AND (&LisaPvAlaIka < &ikavu < &LisaPvYlaika OR (&ikavu = &LisaPvAlaIka AND (&mvuosi IN (2007,2008,2014,2017,2022,2025,2027) OR (12 - &ikakk) <= &taytkk))) THEN temp = MIN(-&tmtukipv, 0);
	ELSE IF &taytkk > 0 AND &lasktyohistv >= &LisaPvTyohist AND &ikavu = &LisaPvYlaika THEN temp = MIN(12 - &ikakk, (&tmtukipv / &TTPaivia)) * -&TTPaivia;

	*Ansiopäivärahoja lisää, jos enimmäiskesto ei ole täyttynyt, mutta datassa kuitenkin on;
	ELSE IF &taytkk NE . AND &tmtukipv > 0 AND ENIMMAISKESTO > &kertymapv THEN temp = MAX(-&tmtukipv, SUM(&kertymapv, -ENIMMAISKESTO));

	*Ansiopäivärahoja pois, jos enimmäiskesto on täyttynyt. Vaikka olisi täyttynyt edellisvuonna, kunhan ei lisäpäiväoikeutta;
	ELSE IF &taytkk NE -99 AND ENIMMAISKESTO < &kertymapv THEN temp = MAX(0, SUM(&kertymapv, -ENIMMAISKESTO));

	ELSE temp=0;
END;

*Vuorottelukorvauksen rajoitus. Sovittelu ei vaikuta vuorottelukorvauksen kestoon. ;
ELSE DO;

	*Datan päivät täytyy muuttaa arkipäivistä kalenteripäiviksi lain mukaisesti;
	KALENTERIPV = &kertymapv * (7/5);

	*Otetaan päivän liikkumavara, koska työttömyyspäivien tai arkipäivien vuosimäärä voi vaihdella;
	IF FLOOR(KALENTERIPV)- 1 > &VuorKorvMaxKesto THEN temp = ROUND((5/7) * SUM(KALENTERIPV, -&VuorKorvMaxKesto));

	*Minimivaatimusta ei sovelleta toistaiseksi, koska ei pystytä erottaa kuluvaa jaksoa päättyneestä;
	*ELSE IF ROUND(KALENTERIPV) < &VuorKorvMinKesto THEN temp = ROUND((5/7) * SUM(KALENTERIPV, -&VuorKorvMinKesto));
	ELSE temp = 0;
END;

&tulos = temp;
DROP ENIMMAISKESTO KALENTERIPV;

%MEND;


/*  20. Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus (kuukausimalli)  */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, siirtyvät päivät ("netto") (neg. arvo tarkoittaa lisätyt päivät)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	kertymapv: Ansiopäivärahan kertymä ns. nettona eli sovitellut päivät kokonaisina
	tyohistv: Henkilön työhistoria vuosina
	lasktyohistv: Henkilön laskennallinen työhistoria vuosina lisäpäiväoikeutta varten (vuositulojen jako 510:llä)
	lisapaivoik: Henkilöllä oikeus työttömyysturvan lisäpäiviin (1=kyllä, 0=ei)
	syntv: Syntymävuosi
	ikavu: Ikä vuosina vuoden lopussa
	tmtukipv: Työmarkkinatukipäivät nettona eli sovitellut päivät kokonaisina
	ansiopv: Ansiosidonnaiset päivärahapäivät nettona eli sovitellut päivät kokonaisina
	tyossaoloehto: Täyttääkö työssäoloehdon (1=kyllä, 0=ei)
;

%MACRO AnsioSidKestoRajKK(tulos, mvuosi, mkuuk, kertymapv, tyohistv, lasktyohistv, lisapaivoik, syntv, ikavu, tmtukipv, ansiopv, tyossaoloehto)/
DES = 'TTURVA: Ansiopäivärahan ja vuorottelukorvauksen enimmäis- ja vähimmäiskeston rajaus';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1);

*Määritetään kullekin enimmäiskesto;
IF &mvuosi >= 2017 AND &lasktyohistv >= &LisaPvTyoHist AND &tyossaoloehto = 1 AND (&ikavu > &KestoIkaRaja) THEN ENIMMAISKESTO = &AnsioSidKesto3;
ELSE IF &mvuosi >= 2014 AND &tyohistv <= &KestoLyhEhtoV THEN ENIMMAISKESTO = &AnsioSidKesto2;
ELSE ENIMMAISKESTO = &AnsioSidKesto;

*Nollataan enimmäiskesto, jos työssäoloehto ei ole täyttynyt;
IF &tyossaoloehto = 0 THEN ENIMMAISKESTO = 0;

*Lisäpäiväoikeuden simulointi;
	*Jos lisäpäiväoikeus on täyttynyt aikaisempina vuosina niin ei ruveta muuttamaan;
	IF first.hnro AND &lisapaivoik THEN LISAPAIVOIK = 1;

	*Määritellään enimmäiskeston täyttymiskuukausi lisäpäiväoikeuden tarkistusta varten;
	IF (&kertymapv >= ENIMMAISKESTO) AND SUM(&kertymapv, -&ansiopv) < ENIMMAISKESTO THEN TAYTKK = 1;
	ELSE TAYTKK = 0;

	*Jos enimmäiskeston täyttymiskuukautena täyttää ikä- ja työhistoriaehdon niin sitten oikeutettu ansiopäivärahan lisäpäiviin;
	IF TAYTKK = 1 AND &lasktyohistv >= &LisaPvTyoHist AND
		((1957 <= &syntv <= 1960 AND &ikavu >= 61) OR (1961 <= &syntv <= 1962 AND &ikavu >= 62) OR
		(&syntv = 1963 AND &ikavu >= 63) OR (&syntv = 1964 AND &ikavu >= 64)) THEN LISAPAIVOIK = 1;

	*Levitetään lisäpäiväoikeus myös tuleville kuukausille;
	%DO i = 1 %TO 11;
		IF lag&i.(LISAPAIVOIK) = 1 AND lag&i.(hnro) = hnro THEN LISAPAIVOIK = 1; 
	%END;

*Jos lisäpäiväoikeus niin muutetaan työmarkkinatuet ansiopäivärahoiksi;
IF LISAPAIVOIK = 1 THEN temp = &tmtukipv; 

*Jos enimmäiskesto ei ole täyttynyt, mutta datassa kuitenkin on, niin muutetaan tmtukipäivät ansiopäivärahoiksi.
Tehdään tämä vain niille, jotka ovat siirtyneet ansiopäivärahalta työmarkkinatuelle;
ELSE DO;
	%DO i = 1 %to 11;
		IF &tmtukipv NE 0 AND lag&i.(&ansiopv) NE 0 AND lag&i.(hnro) = hnro THEN SIIRTYNYT = 1;
	%END;

	IF &tmtukipv > 0 AND &kertymapv < ENIMMAISKESTO AND SIIRTYNYT = 1 THEN temp = MIN(&tmtukipv, SUM(ENIMMAISKESTO, -&kertymapv));

	*Jos enimmäiskesto on täyttynyt, mutta datassa on ansiopäivärahapäiviä, otetaan ansiopäivärahoja pois;
	ELSE IF &kertymapv > ENIMMAISKESTO THEN temp = MAX(-&ansiopv, SUM(ENIMMAISKESTO, -&kertymapv));
	ELSE temp = 0;
END;

&tulos = temp;
DROP temp ENIMMAISKESTO LISAPAIVOIK TAYTKK SIIRTYNYT;

%MEND;


/*  21. Omavastuupäivät  */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, aineisto- ja lainsäädäntövuosien omavastuupäivien erotus
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	aivuosi: Aineistovuosi 
	aikuuk:  Aineistokuukausi
;

%MACRO Omavastuupv(TULOS, mvuosi, mkuuk, aivuosi, aikuuk);

%HaeParam&TYYPPI(&aivuosi, &aikuuk, &TTURVA_PARAM, PARAM.&PTTURVA); *Haetaan aineistovuoden parametrit;

omav_avuosi = &OmavastuuPv; *Tallennetaan aineistovuoden omavastuupäivät muuttujaan;

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);

%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1);

IF omav_avuosi>0 and omav_avuosi NE &OmavastuuPv THEN &TULOS=SUM(&OmavastuuPv,-omav_avuosi);
ELSE &TULOS=0;

%MEND;


/*  22. Työssäoloehto (kuukausimalli)  */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, työssäoloehto
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	tyossaoloehto_kk: Työssäoloehtokuukausien määrä, laskettu edelliseltä 28 kuukaudelta 1.9.2024 voimaan astuneen lainsäädännön mukaan
;

%MACRO TyossaoloehtoKK(tulos, mvuosi, mkuuk, tyossaoloehto_kk)/
DES = 'TTURVA: Työssäoloehdon muodostus';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, 1);

/* Arvioidaan ketkä ovat täyttäneet työssäoloehdon */
IF &tyossaoloehto_kk >= &TyoEhtoKK THEN &tulos = 1;
	ELSE &tulos = 0;

%MEND;


/*  23. Yleistuki kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, yleistuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tyollistymispalvelu: Onko työllistymistä edistävissä palveluissa (1=kyllä, 0=ei)
	tyossaoloehto: Täyttääkö työssäoloehdon (1=kyllä, 0=ei)
	huoll: Vanhempien huollettavien lukumäärä
	omatulo: Oman tulon määrä (ei sisällä sovittellussa huomioitavia palkkatuloja), e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tuki, e/kk
	vahsosetuus: Päivärahasta vähennettävät muut sosiaalietuudet, e/kk
;

%MACRO YleistukiKS(tulos, mvuosi, mkuuk, minf, tyollistymispalvelu, tyossaoloehto, huoll, omatulo, vanhtulot, vahsosetuus)/
DES = 'TTURVA: Yleistuki kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TTURVA_PARAM, PARAM.&PTTURVA);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TTURVA_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid < mdy(5, 1, 2026) THEN &tulos = 0;
ELSE DO;

	*Täysmääräinen yleistuki;
	temp = &TTPAIVIA * &TTPerus;

	*Tarveharkittu tuki;
	IF &tyollistymispalvelu = 0 THEN DO;
		IF &omatulo > &RajaYks THEN temp = SUM(temp, -&TarvPros1 * SUM(&omatulo, -&RajaYks));
		temp = MAX(temp, 0);
	END;

	*Osittainen tuki, jos ei ole täyttänyt työssäoloehtoa ja asuu vanhempien luona; 
	IF &tyossaoloehto = 0 THEN DO;
		*Vanhempien huollettavien määrä korottaa sovelletavaa rajaa;
		raja = SUM(&OsRaja, &huoll * &OsRajaKor);
		*Tietyn rajan jälkeen vanhemman tulot pienentävät osittaista työmarkkinatukea. Tuki on minimissään tietty prosentti täydestä tuesta.;
		IF &vanhtulot > raja THEN DO;
			temp  = MAX(SUM(temp, -&OsTarvPros * SUM(&vanhtulot, -raja)), &OsPros * temp);
		END;
	END;

	* Lopullisen tuen määrä on pienempi kahdesta vaihtoehdosta: ;
	* 1. Tarveharkittu tuki 2. Täysi tuki, josta vähennetty muut sosiaalietuudet ;
	temp = MIN(temp, SUM(&TTPAIVIA * &TTPerus, -&vahsosetuus));
	
	&tulos = MAX(temp, 0);
	DROP temp raja;

END;

%MEND YleistukiKS;


/* 24. Yleistuki kuukausitasolla vuosikeskiarvona */

*Makron parametrit:  
	tulos: Makron tulosmuuttuja, yleistuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tarvhark: Simuloidaanko tarveharkinta (0=kyllä/1=ei)
	ositt: Simloidaanko osittaisena (0=kyllä/1=ei)
	huoll: Vanhempien huollettavien lukumäärä
	omatulo: Oman muun tulon määrä, e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tuki, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO YleistukiVS(tulos, mvuosi, minf, tarvhark, ositt, huoll, omatulo, vanhtulot, vahsosetuus)/
DES = 'TTURVA: Yleistuki kuukausitasolla vuosikeskiarvona';

	vuosipraha = 0;

	%DO i = 1 %TO 12;
		%YleistukiKS(temp, &mvuosi, &i, &minf, &tarvhark, &ositt, &huoll, &omatulo, &vanhtulot, &vahsosetuus);
		vuosipraha = SUM(vuosipraha, temp);
	%END;

&tulos = vuosipraha / 12;
DROP vuosipraha temp;

%MEND YleistukiVS;