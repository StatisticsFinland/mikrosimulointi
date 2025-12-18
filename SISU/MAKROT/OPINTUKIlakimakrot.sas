/***********************************************************
* Kuvaus: Opintotuen lains‰‰d‰ntˆ‰ makroina                *
***********************************************************/ 


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
1. VanhKorotusS = Opintorahaan vanhempien tulojen perusteella laskettava korotus
2. VanhAlennusS = Asumislis‰‰n ja opintorahaan vanhempien tulojen perusteella laskettava alennus
3. AsumLisaKS = Asumislis‰ kuukausitasolla 
4. AsumLisaVS = Asumislis‰ kuukausitasolla vuosikeskiarvona
5. OpRahaKS = Opintoraha kuukausitasolla
6. OpRahaVS = Opintoraha kuukausitasolla vuosikeskiarvona
7. OpRahaAsumLisaKS = Opintorahan ja asumislis‰n summa kuukausitasolla
8. AikOpinRahaKS = Aikuisopintoraha kuukausitasolla
9. AikOpinRahaVS = Aikuisopintoraha kuukausitasolla vuosikeskiarvona
10. AikKoulTukiK1 = Aikuiskoulutustuen laskukaava 31.7.2010 asti
11. AikKoulTukiK2 = Aikuiskoulutustuen laskukaava 1.8.2010 alkaen
12. AikKoulTukiKS = Aikuiskoulutustuki kuukausitasolla
13. AikKoulTukiVS = Aikuiskoulutustuki kuukausitasolla vuosikeskiarvona
14. AikKoulSoviteltuKS = Soviteltu aikuiskoulutustuki kuukausitasolla
15. AikKoulSoviteltuVS = Soviteltu aikuiskoulutustuki kuukausitasolla vuosikeskiarvona 
16. OpLainaKS = Opintolainan valtiontakaus kuukausitasolla
17. OpLainaVS = Opintolainan valtiontakaus kuukausitasolla vuosikeskiarvona
18. OpTukiTakaisinS = Opintotuen takaisinperint‰ vuositasolla
19. AsumLisaVuokraKS = Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla
20. AsumLisaVuokraVS = Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla vuosikeskiarvona
21. TukiKuuk = Makron avulla voidaan p‰‰tell‰ opintotukikuukaudet vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan
22. TukiKuukOik = Makron avulla p‰‰tell‰‰n oikeutetut opintotukikuukaudet esimerkkilaskennassa asetettujen muiden omien tulojen j‰lkeen
*/


/* 1. Makro laskee opintorahaan vanhempien tulojen (ja varallisuuden) perusteella laskettavan korotuksen */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintorahaan vanhempien tulojen perusteella laskettava korotus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e
	huoltaja: Alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi);

%MACRO VanhKorotusS(tulos, mvuosi, mkuuk, minf, kork, vanh, ika, vanhtulo1, vanhtulo2, vanhvarall, huoltaja=0)/
DES = 'OPINTUKI: Opintorahaan vanhempien tulojen perusteella laskettava korotus';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF (kuuid < MDY(7,1,1992)) OR (kuuid < MDY(7,1,1994) AND &kork = 0) THEN temp = 0;

ELSE DO;

	* Ei korotusta, jos on alaik‰isen lapsen huoltaja;
	IF &huoltaja = 1 THEN temp = 0;

	* Ei korotusta, jos ei asu vanhempien luona ja ylitt‰‰ ik‰rajan;
	ELSE IF (&vanh = 0 AND &ika >= &ORaja2) THEN temp = 0;

	ELSE DO;
		
		* 1.1.2019 l‰htien k‰ytet‰‰n uutta tulok‰sitett‰;
		IF kuuid => MDY(1,1,2019) 
		THEN vanhtulo = &vanhtulo1; 
		ELSE vanhtulo = &vanhtulo2;
		
		* Lasketaan vanhempien tuloihin korotus, jos varallisuusraja ylittyy;
		IF &vanhvarall > &VanhVarRaja
		THEN vanhtulo = vanhtulo + (&VanhVarPros * (&vanhvarall - &VanhVarRaja));
		ELSE vanhtulo = vanhtulo;

		IF vanhtulo <= &VanhTuloYlaRaja THEN DO;
			IF &kork = 1 THEN DO;
				IF &vanh = 1 THEN DO;
					IF &ika < &ORaja1 THEN temp = &KorkVanhAlle20b;
					ELSE temp = &KorkVanh20b;
				END;
				ELSE temp = &KorkMuuAlle20b;
			END;
			ELSE DO;
				IF &vanh = 1 THEN DO;
					IF &ika < &ORaja1 THEN temp = &MuuVanhAlle20b;
					ELSE temp = &MuuVanh20b;
				END;
				ELSE temp = &MuuMuuAlle20b;
			END;
		END;

		IF vanhtulo > &VanhTuloRaja THEN DO;

			IF vanhtulo > &VanhTuloYlaRaja THEN temp = 0;
			ELSE IF &VanhKynnys > 0 THEN DO;
				vah = FLOOR((vanhtulo - &VanhTuloRaja) / SUM(&VanhKynnys));
				vah = vah * &VanhPros * temp;
    			temp = SUM(temp, -vah);
				IF temp < 0 THEN temp = 0;
			END;
			ELSE temp = 0;
		END;
	END;
END;
&tulos = temp;
DROP vanhtulo vah temp kuuid;
%MEND VanhKorotusS;


/* 2. Makro laskee asumislis‰n ja opintorahan alennuksen vanhempien tulojen perusteella */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, asumislis‰‰n ja opintorahaan vanhempien tulojen perusteella laskettava alennus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alisa: Onko kyse asumislis‰st‰ vai opintorahasta teht‰v‰st‰ alennuksesta (1 = asumislis‰, 0 = opintoraha)
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi) 
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	opraha: Asumislis‰ tai opintoraha, e/kk
	huoltaja: Alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi);

%MACRO VanhAlennusS(tulos, mvuosi, mkuuk, minf, alisa, kork, vanh, ika, sisaria, vanhtulo1, vanhtulo2, opraha, huoltaja=0)/
DES = "OPINTUKI: Asumislis‰‰n ja opintorahaan vanhempien tulojen perusteella laskettava alennus, e/kk";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

	%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	* 1.1.2019 l‰htien k‰ytet‰‰n uutta tulok‰sitett‰;
	IF kuuid => MDY(1,1,2019) 
	THEN vanhtulo = &vanhtulo1; 
	ELSE vanhtulo = &vanhtulo2;

	IF (kuuid < MDY(7,1,1992)) OR (kuuid < MDY(7,1,1994) AND &kork = 0) THEN temp = 0;

	ELSE DO;

		* Ei alennusta, jos on alaik‰isen lapsen huoltaja;
		IF &huoltaja = 1 THEN temp = 0;

		*Ei alennusta, jos on korkeakouluopiskelija;
		ELSE IF &kork = 1 THEN temp = 0;

		*Asumislis‰n alennus;
		*ENNEN 1.8.2019: Koskee alle 18-vuotiaita;
		ELSE IF 
			(
				&alisa = 1 
				AND 
				(kuuid < MDY(8,1,2019) AND &ika < &ORaja3)
			) 
			THEN DO; 
				IF vanhtulo <= &VanhTuloRaja2 THEN temp = 0;
				ELSE IF &VanhTuloRaja2Kynnys > 0 THEN DO;
					temp = FLOOR((vanhtulo - &VanhTuloRaja2) / SUM(&VanhTuloRaja2Kynnys));
					temp = temp * &VanhTuloPros2 * &opraha;
					IF temp > &opraha THEN temp = &opraha;
				END;
			END;
				
		*ENNEN 1.1.2018: Opintorahan alennus koskee kaikkia alle 20-vuotiaita ei-korkeakouluopiskelijoita;
		*1.1.2018 LƒHTIEN: Opintorahan alennus koskee alle 20-vuotiaita vanhempien luona asuvia 
		ei-korkeakouluopiskelijoita ja alle 18-vuotiaita itsen‰isesti asuvia ei-korkeakouluopiskelijoita;	                   
		ELSE IF 
			(
				&alisa NE 1
				AND
					(
						((kuuid < MDY(1, 1, 2018)) AND (&ika < &ORaja1))
						OR
						((kuuid >= MDY(1, 1, 2018) AND kuuid < MDY(8, 1, 2019)) AND ((&vanh = 1 AND &ika < &ORaja1) OR (&vanh = 0 AND &ika < &ORaja3)))
						OR
						((kuuid >= MDY(8, 1, 2019)) AND (&vanh = 1 AND &ika < &ORaja1))
					 )
			) 
			THEN DO;

				*ENNEN 1.8.2014: Vanhempien tulojen yl‰raja, jolloin alennusta ei viel‰ tule, on sama kaikille;
				IF (kuuid < MDY(8, 1, 2014)) THEN kaytraja = &VanhTuloRaja2;
				* 1.8.2014 LƒHTIEN - ENNEN 1.1.2018: Vanhempien tulojen yl‰raja, jolloin alennusta ei viel‰ tule, 
				on korkeampi 18-19-vuotiailla itsen‰isesti asuvilla kuin muilla; 	
				ELSE IF (kuuid < MDY(1, 1, 2018)) THEN DO;
					IF &vanh = 1 OR &ika < &ORaja3 THEN kaytraja = &VanhTuloRaja2;	
					ELSE kaytraja = &VanhTuloRaja3; 	
				END;
				* 1.1.2018 LƒHTIEN: Vanhempien tulojen yl‰raja, jolloin alennusta ei viel‰ tule, on sama kaikille;
				ELSE kaytraja = &VanhTuloRaja2; 

			*Lasketaan alennus edell‰ p‰‰tellyn rajan pohjalta;
			IF vanhtulo <= kaytraja THEN temp = 0;
			ELSE IF &VanhTuloRaja2Kynnys > 0 THEN DO;
				temp = FLOOR((vanhtulo - kaytraja) / SUM(&VanhTuloRaja2Kynnys));
				temp = temp * &VanhTuloPros2 * &opraha;
				IF temp > &opraha THEN temp = &opraha;
			END;
		END;

		ELSE temp = 0;

	END;

	&tulos = temp;

	DROP kuuid vanhtulo temp kaytraja;

%MEND VanhAlennusS;

	
/* 3. Makro laskee asumislis‰n kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, asumislis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	asmeno: Asumismenot, e/kk
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi
	kuntaryhm‰: Kuntaryhm‰, joka vaikuttaa etuuden m‰‰r‰‰n	;

%MACRO AsumLisaKS (tulos, mvuosi, mkuuk, minf, kork, ika, sisaria, asmeno, omatulo, vanhtulo1, vanhtulo2, puoltulo, kuntaryhma)/
DES = 'OPINTUKI: Asumislis‰ kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	IF 
		(kuuid < MDY(7, 1, 1992)) OR 
		(kuuid < MDY(7, 1, 1994) AND &kork = 0) OR 
		(kuuid > MDY(7, 1, 2017) AND kuuid < MDY(8, 1, 2025)) 
	THEN temp2 = 0;

	ELSE DO;

	* Pienin huomioon otettava asumismeno ;
	IF &asmeno < &VuokraMinimi THEN temp2 = 0; 

	ELSE DO;

		* Vuokra otetaan huomioon vain vuokrakattoon asti ;
		IF &asmeno > &VuokraKatto THEN asmenot = &VuokraKatto;
		ELSE asmenot = &asmeno;

		* Vuokra otetaan huomioon vain vuokrakattoon asti (kuntaryhmittelyn mukainen kattovuokra voimassa 8/2025 l‰htien);
		IF kuuid >= MDY(8, 1, 2025) THEN DO;
			IF &kuntaryhma = 1 THEN asmenot = MIN(&asmeno, &VuokraKatto1);
			IF &kuntaryhma = 2 THEN asmenot = MIN(&asmeno, &VuokraKatto2);
			IF &kuntaryhma = 3 THEN asmenot = MIN(&asmeno, &VuokraKatto3);
		END;
		ELSE DO;
			asmenot = MIN(&asmeno, &VuokraKatto);
		END;

		* Peruskaava ;
		temp2 = &AsLisaPerus + (&AsLisaPros * (asmenot - &VuokraRaja));

		* V‰hennys opiskelijan omien tulojen perusteella ennen 1.1.1998 ;
		IF &mvuosi < 1998 THEN DO;
			IF &omatulo/12 > &AsLisaTuloRaja THEN IF &AsLisaVanhKynnys > 0  
			THEN vah1 = FLOOR((&omatulo/12 - &AsLisaTuloRaja) / SUM(&AsLisaVanhKynnys));
			vah1 = vah1 * &AsLisavahPros * temp2;
		END;
		temp2 = SUM(temp2, -vah1);

		* V‰hennys puolison tulojen perusteella 1.5.2000 l‰htien 31.12.2008 asti, jos
  		puoliso asuu samassa asunnossa ;
		IF kuuid > MDY(4, 1, 2000) THEN IF &mvuosi < 2009 THEN DO;
			IF &puoltulo > &AsLisaPuolTuloRaja THEN IF &AsLisaPuolTuloKynnys > 0 
			THEN vah2 = FLOOR((&puoltulo - &AsLisaPuolTuloRaja) / SUM(&AsLisaPuolTuloKynnys));
			vah2 = vah2 * &AsLisaPuolVahPros * temp2;
		END;
		temp2 = SUM(temp2, -vah2);
		IF (temp2 < 0) THEN temp2 = 0;

		* V‰hennys vanhempien tulojen perusteella ;
		%VanhAlennusS(asalennus, &mvuosi, &mkuuk, &minf, 1, &kork, 0, &ika, &sisaria, &vanhtulo1, &vanhtulo2, temp2);
		temp2 = SUM(temp2, -asalennus);
	END;
END;

&tulos = temp2;

DROP vah1 vah2 temp2 asalennus asmenot kuuid;

%MEND AsumLisaKS;


/* 4. Makro laskee asumislis‰n kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, asumislis‰, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	asmeno: Asumismenot, e/kk
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi
	kuntaryhma: Kuntaryhm‰, joka vaikuttaa etuuden m‰‰r‰‰n	;

%MACRO AsumLisaVS (tulos, mvuosi, minf, kork, ika, sisaria, asmeno, omatulo, vanhtulo1, vanhtulo2, puoltulo, kuntaryhma)/
DES = 'OPINTUKI: Asumislis‰ kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%AsumLisaKS(temp, &mvuosi, &i, &minf, &kork, &ika, &sisaria, &asmeno, &omatulo, &vanhtulo1, &vanhtulo2, &puoltulo, &kuntaryhma);
	raha = SUM(raha,  temp);
%END;
&tulos = raha / 12;
DROP raha temp;
%MEND AsumLisaVS;


/* 5. Makro laskee opintorahan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e
	aloituspvm: Opiskelujen aloitusp‰iv‰m‰‰r‰
	huoltaja: Alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi)
	oppimateriaali: Otetaanko laskennassa huomioon mahdollinen oppimateriaalilis‰ (1 = tosi, 0 = ep‰tosi);

%MACRO OpRahaKS (tulos, mvuosi, mkuuk, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo1, vanhtulo2, vanhvarall, aloituspvm=., huoltaja=0, oppimateriaali=1)/
DES = 'OPINTUKI: Opintoraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF (kuuid < MDY(7, 1, 1992)) OR (kuuid < MDY(7, 1, 1994) AND &kork = 0) THEN temp2 = 0;

ELSE DO;

	* Korkeakouluopiskelijat ;
	IF &kork = 1 THEN DO;
		IF &vanh = 1 AND &huoltaja = 0 THEN DO; 
			IF &ika < &ORaja1 THEN DO;
				IF &aloituspvm >= MDY(8, 1, 2014) AND kuuid >= MDY(8, 1, 2014) AND kuuid < MDY(8, 1, 2017) THEN temp2 = &KorkVanhAlle20_2;
				ELSE temp2 = &KorkVanhAlle20;
			END;
			ELSE DO;
				IF &aloituspvm >= MDY(8, 1, 2014) AND kuuid >= MDY(8, 1, 2014) AND kuuid < MDY(8, 1, 2017) THEN temp2 = &KorkVanh20_2;
				ELSE temp2 = &KorkVanh20;
			END;
    	END;
		ELSE DO;
			IF &ika < &ORaja2 AND &huoltaja = 0 THEN DO;
				IF &aloituspvm >= MDY(8, 1, 2014) AND kuuid >= MDY(8, 1, 2014) AND kuuid < MDY(8, 1, 2017) THEN temp2 = &KorkMuuAlle20_2;
				ELSE temp2 = &KorkMuuAlle20;
			END;
			ELSE DO;
				IF &aloituspvm >= MDY(8, 1, 2014) AND kuuid >= MDY(8, 1, 2014) AND kuuid < MDY(8, 1, 2017) THEN temp2 = &KorkMuu20_2;
				ELSE temp2 = &KorkMuu20;
			END;
    	END;
	END;		
	
	* Muut kuin korkeakouluopiskelijat ;	
	ELSE DO;
		IF &vanh = 1 AND &huoltaja = 0 THEN DO; 
			IF &ika < &ORaja1 THEN temp2 = &MuuVanhAlle20;
			ELSE temp2 = &MuuVanh20;
		END;	
		ELSE DO;
			IF &ika < &ORaja2 AND &huoltaja = 0 THEN temp2 = &MuuMuuAlle20;
			ELSE temp2 = &MuuMuu20;
		END;
	END;		

	* Korotus vanhempien tulojen (ja varallisuuden) perusteella ;	
	%VanhKorotusS(korotus, &mvuosi, &mkuuk, &minf, &kork, &vanh, &ika, &vanhtulo1, &vanhtulo2, &vanhvarall, huoltaja=&huoltaja);
  	temp2 = SUM(temp2, korotus);

	* V‰hennys vanhempien tulojen perusteella ;
 	%VanhAlennusS(opalennus, &mvuosi, &mkuuk, &minf, 0, &kork, &vanh, &ika, &sisaria, &vanhtulo1, &vanhtulo2, temp2, huoltaja=&huoltaja);
 	temp2 = SUM(temp2, -opalennus);

	* V‰hennys opiskelijan omien tulojen perusteella ennen 1.1.1998 ;
	IF &mvuosi < 1998 THEN DO;

		IF (&omatulo/12 > &OpTuloRaja AND &OpTuloVahKynnys > 0) THEN DO;
			vah2 = FLOOR((&omatulo/12 - &OpTuloRaja) / SUM(&OpTuloVahKynnys));
			vah2 = vah2 * &OpTuloVahPros  * temp2;
		END;
		ELSE DO; 
			vah2 = 0;
		END;
		temp2 = SUM(temp2, -vah2);
	END;

	IF temp2 < 0 THEN temp2 = 0;

	* 1.1.2018 LƒHTIEN: Alle 18-vuotiaan lapsen huoltajalla oikeus opintorahan huoltajakorotukseen;
	IF &huoltaja = 1 THEN temp2 = SUM(temp2, &HuoltKor);

	* 1.8.2019 LƒHTIEN: Pienituloisten perheiden ammatillista tai lukiokoulutusta suorittavilla lapsilla oikeus opintorahan oppimateriaalilis‰‰n;
	* 1.8.2021 LƒHTIEN: Oppimateriaalilis‰ poistuu opiskelijoilta, jotka ovat oppivelvollisuuslain mukaan oikeutettuja maksuttomaan koulutukseen;
	IF &oppimateriaali = 1 THEN DO;
		IF (&ika < 17 AND kuuid < MDY(8, 1, 2021)) OR (&ika > MIN(&mvuosi - 2005, 20) AND &kork = 0 AND &vanhtulo1 <= &VanhTuloYlaRaja AND korotus > 0) THEN temp2 = SUM(temp2, &OpmatLisa);
	END;

END;

&tulos = temp2;
DROP vah2 temp2 opalennus korotus kuuid;
%MEND OpRahaKS;


/* 6. Makro laskee opintorahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintoraha, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi).
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e/vuosi
	aloituspvm: Opiskelujen aloitusp‰iv‰m‰‰r‰ 
	huoltaja: Alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi)
	oppimateriaali: Otetaanko laskennassa huomioon mahdollinen oppimateriaalilis‰ (1 = tosi, 0 = ep‰tosi);

%MACRO OpRahaVS (tulos, mvuosi, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo1, vanhtulo2, vanhvarall, aloituspvm=., huoltaja=0, oppimateriaali=1)/
DES = 'OPINTUKI: Opintoraha kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%OpRahaKS(temp, &mvuosi, &i, &minf, &kork, &vanh, &ika, &sisaria, &omatulo, &vanhtulo1, &vanhtulo2, &vanhvarall, aloituspvm=&aloituspvm, huoltaja=&huoltaja, oppimateriaali=&oppimateriaali);
	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND OpRahaVS;


/* 7. Makro laskee opintorahan ja asumislis‰n summan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintotuki yhteens‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo1: Vanhempien veronalaiset ansio- ja p‰‰omatulot, e/vuosi
	vanhtulo2: Vanhempien puhtaat ansio- ja p‰‰omatulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e
	asummeno: Asumismenot, e/kk
	aloituspvm: Opiskelujen aloitusp‰iv‰m‰‰r‰
	huoltaja: Alaik‰isen lapsen huoltaja (1 = tosi, 0 = ep‰tosi)
	oppimateriaali: Otetaanko laskennassa huomioon mahdollinen oppimateriaalilis‰ (1 = tosi, 0 = ep‰tosi);

%MACRO OpRahaAsumLisaKS (tulos, mvuosi, mkuuk, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo1, vanhtulo2, puoltulo, vanhvarall, asummeno, aloituspvm=., huoltaja=0, oppimateriaali=1)/
DES = 'OPINTUKI: Opintorahan ja asumislis‰n summa kuukausitasolla';

%OpRahaKS(rahak, &mvuosi, &mkuuk, &minf, &kork, &vanh, &ika, &sisaria, &omatulo, &vanhtulo1, &vanhtulo2, &vanhvarall, aloituspvm=&aloituspvm, huoltaja=&huoltaja, oppimateriaali=&oppimateriaali);
temp3 = rahak;

IF &vanh = 0 THEN DO;
	%AsumLisaKS(lisak, &mvuosi, &mkuuk, &minf, &kork, &ika, &sisaria, &aSUMmeno, &omatulo, &vanhtulo1, &vanhtulo2, &puoltulo);
	temp3 = SUM(rahak, lisak);
END;

&tulos = temp3;
DROP rahak lisak temp3;
%MEND OpRahaAsumLisaKS;

	
/* 8. Makro laskee aikuisopintorahan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikOpinRahaKS (tulos, mvuosi, mkuuk, minf, kork, tulo)/
DES = 'OPINTUKI: Aikuisopintoraha kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid < MDY(7, 1, 1992) OR kuuid > MDY(12, 1, 2002) THEN temp = 0;

ELSE DO;

	IF &kork = 1 THEN AikOpAlaRaja = &KorkMuu20;
	ELSE AikOpAlaRaja = &AikOpAlaRaja;

	temp = &AikOpPros * &tulo;
	IF temp < AikOpAlaRaja THEN temp = AikOpAlaRaja;
	IF temp > &AikOpYlaRaja THEN temp = &AikOpYlaRaja;

END;

&tulos = temp;
DROP temp kuuid AikOpAlaRaja;
%MEND AikOpinRahaKS;


/* 9. Makro laskee aikuisopintorahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikOpinRahaVS (tulos, mvuosi, minf, kork, tulo)/
DES = 'OPINTUKI: Aikuisopintoraha kuukausitasolla (vuosikeskiarvo)';

raha = 0;
%DO i = 1 %TO 12;
	%AikOpinRahaKS (temp2, &mvuosi, &i, &minf, &kork, &tulo);
	raha = SUM(raha, temp2);
%END;
&tulos = raha / 12;
DROP raha temp2;
%MEND AikOpinRahaVS;


/*  Aikuiskoulutustuen (e/kk) laskentamakrot (10, 11, 12, 13, 14, 15) */

/*  Makrojen parametrit:
	tulos: Makron tulosmuuttuja, aikuiskoulutustuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tulo: Tukikautta edelt‰v‰n vuoden tyˆ-, virka- tai muun palvelussuhteen vakiintuneet ansiot, e/vuosi
	praha: T‰yden tuen m‰‰r‰, jos ei olisi soviteltu, e/kk
	tyotulo: Tyˆtulo, joka on sovittelun perusteena, e/kk
*/

	
/* 10. Laskukaava 31.7.2010 asti */

%MACRO AikKoulTukiK1 (tulos, mvuosi, mkuuk, minf, tulo)/
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla, 31.7.2010 asti';

	kktulo = &tulo / 12;

	temp = &AikKoulPerus;
	IF kktulo < &AikKoulTuloRaja
	THEN temp = temp + (&AikKoulPros1 * kktulo);

	ELSE DO;
		temp = temp + (&AikKoulPros1 * &AikKoulTuloRaja);
		temp = temp + (&AikKoulPros2 * (kktulo - &AikKoulTuloRaja));
	END;
	
	DROP kktulo;

&tulos = temp;
DROP temp kuuid kktulo;
%MEND AikKoulTukiK1 ;


/* 11. Laskukaava 1.8.2010 alkaen */

%MACRO AikKoulTukiK2(tulos, mvuosi, mkuuk, minf, tulo)/ 
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla, 1.8.2010 alkaen';

kktulo = &tulo / 12;

*Kuukausipalkkaan teht‰v‰ v‰hennys;
paivapalkka = (1 - &ATVahPros) * (kktulo / &ATPaivia);
*Aikuiskoulutustuen enimm‰ism‰‰r‰;
raja = &ATProsYlaRaja * paivapalkka;

*Ansiosidonnaisen p‰iv‰rahan varsinainen laskukaava;
IF (1 - &ATVahPros) * kktulo < &ATTaite * &ATPerus THEN temp = SUM(&ATPerus, &ATPros1 * SUM(paivapalkka, -&ATPerus));
ELSE temp = SUM(&ATPerus, &ATPros1 * SUM(&ATTaite * &ATPerus / &ATPaivia, -&ATPerus), &ATPros2 * SUM(paivapalkka, -&ATTaite * &ATPerus / &ATPaivia));

*Maksimip‰iv‰raha;
IF temp > raja THEN temp = raja;

*Minimip‰iv‰raha;
temp = MAX(temp, &ATPerus);

temp = temp * &ATPAIVIA;
IF temp < 0 THEN temp = 0;

&tulos = temp;
DROP temp kuuid kktulo paivapalkka raja;
%MEND AikKoulTukiK2;


/* 12. Makro laskee aikuiskoulutustuen kuukausitasolla valitsemalla ajankohdan mukaan makron 11.1. tai 11.2  */ 

%MACRO AikKoulTukiKS(tulos, mvuosi, mkuuk, minf, tulo)/ 
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid < MDY(8, 1, 2001) THEN &tulos = 0;

*1.8.2001-31.7.2010;
IF MDY(8, 1, 2001) <= kuuid < MDY(8, 1, 2010) THEN DO;
	%AikKoulTukiK1 (&tulos, &mvuosi, &mkuuk, &minf, &tulo);
END;

*1.8.2010 alkaen;	
IF kuuid >= MDY(8, 1, 2010) THEN DO;
	%AikKoulTukiK2 (&tulos, &mvuosi, &mkuuk, &minf, &tulo);
END;
%MEND AikKoulTukiKS;


/*  13. Makro laskee aikuiskoulutustuen kuukausitasolla vuosikeskiarvona */

%MACRO AikKoulTukiVS(tulos, mvuosi, minf, tulo)/ 
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla vuosikeskiarvona';

vuosituki = 0;

%DO i = 1 %TO 12;
	%AikKoulTukiKS(temp, &mvuosi, &i, &minf, &tulo);
	vuosituki = SUM(vuosituki, temp);
%END;

&tulos = vuosituki / 12;
DROP temp vuosituki;
%MEND AikKoulTukiVS;


/*  14. Makro laskee sovitellun aikuiskoulutustuen kuukausitasolla */

%MACRO AikKoulSoviteltuKS(tulos, mvuosi, mkuuk, minf, praha, tyotulo, tulo)/
DES = 'OPINTUKI: Soviteltu aikuiskoulutustuki kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI); 
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid < MDY(8,1,2010) THEN temp2=0;

ELSE DO;

	*Sovitellun laskukaava. Ei sovitella jos alle suojaosan;
	IF &tyotulo < &ATSovSuoja THEN temp2 = &praha;

	*Muuten sovitellaan;
	ELSE DO; 

		temp2 = &praha - (&ATSovPros * (&tyotulo - &ATSovSuoja));
		IF temp2 < 0 THEN temp2 = 0;

		* Sovitellun aikuiskoulutustuen laki muuttui 1.8.2020;
		IF kuuid >= MDY(8,1,2020) THEN DO;  
			/* Aikuiskoulutustuen ja tyˆtulojen yhteism‰‰r‰ tukikuukauden aikana on enint‰‰n aikuiskoulutustuen perusteena olevan palkan suuruinen */
			IF SUM(temp2,&tyotulo) > ((1 - &ATVahPros)*(&tulo / 12)) THEN temp2 = SUM(((1 - &ATVahPros)*(&tulo / 12)), -&tyotulo); 
			IF temp2 < 0 THEN temp2 = 0;
			/* Aikuiskoulutustuen ja tyˆtulojen yhteism‰‰r‰ tukikuukauden aikana on v‰hint‰‰n niin paljon kuin henkilˆll‰ olisi oikeus saada perusosana */
			temp2 = MAX(temp2, ((&ATPaivia * &ATPerus) - (&ATSovPros * &tyotulo) * (&tyotulo > &ATSovSuoja))); 
			IF temp2 < 0 THEN temp2= 0;
		END; 

	END;

	/*Jos henkilˆlle aikuiskoulutustukena maksettava m‰‰r‰ olisi pienempi kuin 100 euroa,
	tukea ei makseta ellei hakija sit‰ nimenomaisesti vaadi (ennen 1.8.2020). 
	Jos henkilˆlle aikuiskoulutustukena kuukaudelta maksettava m‰‰r‰ olisi pienempi kuin aikuiskoulutustuen perusosa,
	tukea ei makseta. */
	IF temp2 < &ATPerus then temp2 = 0; 

END;

&tulos = temp2;

DROP temp2;
%MEND AikKoulSoviteltuKS;


/*  15. Makro laskee sovitellun aikuiskoulutustuen kuukausitasolla vuosikeskiarvona */

%MACRO AikKoulSoviteltuVS(tulos, mvuosi, minf, praha, tyotulo, tulo)/
DES = 'OPINTUKI: Soviteltu aikuiskoulutustuki kuukausitasolla vuosikeskiarvona';

sovtuki = 0;

%DO i = 1 %TO 12;
	%AikKoulSoviteltuKS(temp, &mvuosi, &i, &minf, &praha, &tyotulo, &tulo);
	sovtuki = SUM(sovtuki, temp);
%END;

&tulos = sovtuki / 12;
DROP temp sovtuki;
%MEND AikKoulSoviteltuVS;


/* 16. Makro laskee kuukausitasolla opintolainan valtiontakauksen m‰‰r‰n */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, (potentiaalinen) opintolainan valtiontakaus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	aikkoul: Aikuiskoulutusopiskelija (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina ;

%MACRO OpLainaKS (tulos, mvuosi, mkuuk, minf, kork, aikkoul, ika)/
DES = 'OPINTUKI: Opintolainan valtiontakaus kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

IF &aikkoul = 1 THEN temp = &OpLainaAikKoul;

ELSE DO;

	IF &kork = 1 THEN DO;
		IF &ika < &ORaja3 THEN temp = &OpLainaKorAlle18;
		ELSE temp = &OpLainaKor;
	END;

	ELSE DO;
		IF &ika < &ORaja3 THEN temp = &OpLainaMuuAlle18;
		ELSE temp = &OpLainaMuu;
	END;

END;

&tulos = temp;
DROP temp;
%MEND OpLainaKS;


/* 17. Makro laskee opintolainan valtiontakauksen m‰‰r‰n kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, (potentiaalinen) opintolainan valtiontakaus, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	aikkoul: Aikuiskoulutusopiskelija (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina¥;

%MACRO OpLainaVS (tulos, mvuosi, minf, kork, aikkoul, ika)/
DES = 'OPINTUKI: Opintolainan valtiontakaus kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%OpLainaKS (temp2, &mvuosi, &i, &minf, &kork, &aikkoul, &ika);
	raha = SUM(raha, temp2);
%END;
&tulos = raha / 12;
DROP raha temp2;
%MEND OpLainaVS;


/* 18. Makro laskee opintotuen takaisinperinn‰n 1.1.1998 l‰htien vuositasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, takaisinperitt‰v‰n opintotuen m‰‰r‰, e/vuosi
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	optukikuuk: Opintotukikuukaudet vuodessa
	tulo: Henkilˆn omat veronalaiset tulot (ml. apurahat, pl. opintoraha), e/vuosi
	tuki: Opintoraha, e/vuosi ;

%MACRO OpTukiTakaisinS (tulos, mvuosi, mkuuk, minf, optukikuuk, tulo, tuki)/
DES = 'OPINTUKI: Opintotuen takaisinperint‰ vuositasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

* Ei takaisinperint‰‰, jos ei tukea tai jos ei tuloja.
  Funktio k‰sittelee vain lains‰‰d‰ntˆ‰ 1.1.1998 l‰htien ;
IF (&tuki <= 0) OR (&tulo <= 0) OR (&mvuosi < 1998) THEN temp = 0;

ELSE DO;

	tukikuuk=&optukikuuk;	
	IF tukikuuk < 0 THEN tukikuuk = 1;
	IF tukikuuk > 12 THEN tukikuuk = 12;

	* Tuloraja opintotukikuukausille: OpTuloRaja
  	Tuloraja muille kuukausille: OpTuloRaja2   ;
	
	* Vapaa tulo ;
	vapaa = (tukikuuk * &OpTuloRaja) + ((12 - tukikuuk) * &OpTuloRaja2);

	IF &tulo < vapaa THEN temp = 0;

	ELSE DO;

		* Vapaan tulon ylitys ;
		ylitys = &tulo - vapaa;

		* Lains‰‰d‰ntˆ ennen 1.1.2001: laissa m‰‰ritellyn 
 		rajan alittavasta tulosta perit‰‰n tietty osuus 
  		ja sen ylitt‰v‰st‰ osuudesta kokonaan ;

		IF &mvuosi < 2001 THEN DO;
			IF ylitys < &TakPerRaja THEN temp = &TakPerPros * ylitys;
			ELSE temp = (ylitys - &TakPerRaja) + (&TakPerPros * &TakPerRaja);
		END;

		* Lains‰‰d‰ntˆ 1.1.2001 l‰htien: takaisin peritt‰v‰ m‰‰r‰
  		riippuu siit‰, kuinka monikertainen ylitys on m‰‰riteltyyn
  		rajaan n‰hden. Tukea kuukautta kohden perit‰‰n takaisin t‰m‰n 
  		monikerran verran, mutta ei kuitenkaan tietyn alarajan alittavaa ylityst‰ ;

		ELSE IF &mvuosi > 2001 THEN DO;
			IF ylitys < &TakPerAlaRaja OR &TakPerRaja <= 0 THEN temp = 0;
			ELSE DO;
				luku = FLOOR(ylitys / SUM(&TakPerRaja)); 
				IF luku = 0 THEN luku = 1;
				IF tukikuuk > 0 THEN temp = luku * (&tuki / SUM(tukikuuk));
				ELSE temp = 0;
			 END;
		END;

	END;   
 
	* Takaisin peritt‰v‰ summa ei voi olla opintotukea suurempi ;
	IF temp > &tuki THEN temp = &tuki;

    * Mutta takaisin peritt‰v‰‰ summaa korotetaan tietyll‰ prosentilla ;
	temp  = temp * (1 + &TakPerKorotus) ;

END;

&tulos = temp;
DROP tukikuuk vapaa ylitys luku temp;
%MEND OpTukiTakaisinS;


/* 19. Asumlis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta
       vuokran suuruuden kuukausitasolla. Toimii hein‰kuusta 1993 l‰htien,
       jos opiskelijan ja puolison tuloja ei oteta huomioon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vuokran suuruus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	aslisa: Asumislis‰, e/kk;

%MACRO AsumLisaVuokraKS (tulos, mvuosi, mkuuk, minf, aslisa)/
DES = 'OPINTUKI: Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

* Jos ei asumislis‰‰, ei lasketa pidemm‰lle. 
  Ei lasketa myˆsk‰‰n ennen hein‰kuuta 1993 ;

IF &aslisa <= 0 OR kuuid < MDY(7, 1, 1993) THEN temp = 0;

ELSE DO;

	* Maksimilis‰ ;
	maksimi = &AsLisaPros * &Vuokrakatto;

	* Jos maksimiasumilisa, annetaan tulokseksi &VuokraKatto;
	IF &aslisa >= maksimi THEN temp = &VuokraKatto;

	* Muussa tapauksessa p‰‰tell‰‰n k‰‰nteisesti;
	ELSE DO;
		IF &aslisa < maksimi THEN IF &aslisa >= &AsLisaPros * &VuokraMinimi THEN IF &AsLisaPros > 0
		THEN temp = &aslisa / SUM(&AsLisaPros);
    	IF &aslisa < &AsLisaPros * &VuokraMinimi 
		THEN temp = &VuokraMinimi;
	END;
END;

&tulos = temp;
DROP maksimi temp kuuid;
%MEND AsumLisaVuokraKS;
		

/* 20. Asumlis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta
       vuokran suuruuden kuukausitasolla vuosikeskiarvona.
       HUOM! keskiarvo lasketaan 9 kuukaudelle (tammi-toukokuu ja syys-joulukuu) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vuokran suuruus, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	aslisa: Asumislis‰, e/kk ;
 
%MACRO AsumLisaVuokraVS (tulos, mvuosi, minf, aslisa)/
DES = 'OPINTUKI: Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 5;
	%AsumLisaVuokraKS(vuokra1, &mvuosi, &i, &minf,  &aslisa);
	raha = SUM(raha, vuokra1);
%END;
%DO j = 9 %TO 12;
	%AsumLisaVuokraKS(vuokra2, &mvuosi, &j, &minf, &aslisa);
	raha = SUM(raha, vuokra2);
%END;

&tulos = raha / 9;
DROP raha vuokra1 vuokra2;		
%MEND AsumLisaVuokraVS;

/* 21. Makron avulla voidaan p‰‰tell‰ opintotukikuukaudet
       vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan  */

* Makron parametrit:
    tukikuuk: Makron tulosmuuttuja, opintotukikuukausien lukum‰‰r‰ tarkasteluvuonna 
    tuki: Aineiston mukainen opintoraha 
	aste: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi).
	ika: Ik‰ vuosina
	oletus: Aineiston perusteella laskettujen oletusarvona olevien opintotukikuukausien lukum‰‰r‰
	aloituspvm: Opiskelun aloitusp‰iv‰m‰‰r‰;

%MACRO TukiKuuk(tukikuuk, tuki, aste, vanh, ika, oletus, aloituspvm=.)/
DES = 'OPINTUKI: Makro p‰‰ttelee opintotukikuukaudet vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan';

* Lasketaan t‰ysim‰‰r‰inen opintotuki aineistovuoden perusteella (&AVUOSI), joka riippuu oppilaitosasteesta,
  vanhempien luona asumisesta ja i‰st‰ ;

%OpRahaVS(taystuki, &AVUOSI, 1, &aste, &vanh, &ika, 0, 0, 0, 0, 0, aloituspvm=&aloituspvm);
kuuktuki = taystuki;

* Tarkistetaan, vastaako tuki jotakin t‰yden tuen monikertaa ;

DO i = 1 TO 12 UNTIL (round(&tuki) = round(i * kuuktuki)); 

&tukikuuk = i;

END;

* Jos ei, annetaan tulokseksi valmiina oleva tieto ;

IF &tukikuuk NE i THEN &tukikuuk = &oletus;

DROP i kuuktuki taystuki;
%MEND TukiKuuk;

/* 22. Makron avulla p‰‰tell‰‰n oikeutetut opintotukikuukaudet esimerkkilaskennassa asetettujen
       muiden omien tulojen j‰lkeen */

*makron parametrit:
	tukikoik: Makron tulosmuuttuja, tulojen perusteella m‰‰rietty opintotukikuukausien enimm‰ism‰‰r‰
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	omatulo: Henkilˆn omat tulot
	opintokk: Syˆtetyt opintotukikuukaudet;

%MACRO TukiKuukOik(tukikoik, mvuosi, mkuuk, minf, omatulo, opintokk)/
DES = 'OPINTUKI: Makron avulla p‰‰tell‰‰n oikeutetut opintotukikuukaudet esimerkkilaskennassa asetettujen muiden omien tulojen j‰lkeen';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_PARAM, PARAM.&POPINTUKI);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &OPINTUKI_MUUNNOS, &minf);

* Alustetaan tukiaika (12kk) ja tuen saanti (kyll‰);

OPINTUKI_OIKEUS = 12;

* M‰‰ritet‰‰n oikeutettujen tukikuukausien m‰‰r‰ tulojen perusteella ;
* Laskenta vain vuodesta 1998 alkaen, ennen t‰t‰ annetaan 12kk koska tuki v‰hentyi silloin eri
  tavalla (huomioitu tukea laskevissa lakimakroissa);

IF &mvuosi > 1997 THEN DO;
DO WHILE(OPINTUKI_OIKEUS > 0 AND &omatulo > &OpTuloRaja * OPINTUKI_OIKEUS + (&OpTuloRaja + &TakPerRaja) * (12-OPINTUKI_OIKEUS) );
	OPINTUKI_OIKEUS = OPINTUKI_OIKEUS - 1;
END;
END;

IF OPINTUKI_OIKEUS < &opintokk THEN DO; 
	temp = OPINTUKI_OIKEUS;
END;
ELSE DO;
	temp = &opintokk; 
END;

&tukikoik = temp;

DROP OPINTUKI_OIKEUS;
%mend TukiKuukOik;