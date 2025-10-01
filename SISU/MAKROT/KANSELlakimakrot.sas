/*******************************************************************
* Kuvaus: Kelan el‰kkeiden ja vammaistukien lains‰‰d‰ntˆ‰ makroina *
*******************************************************************/ 

/* Tiedosto sis‰lt‰‰ seuraavat makrot:

1. Kansanelake_SimpleKS = Kansanel‰ke kuukausitasolla
2. Kansanelake_SimpleVS = Kansanel‰ke kuukausitasolla vuosikeskiarvona
3. KanselTuloKS = Kansanel‰kkeen ja takuuel‰kkeen perusteena oleva vuositulo
4. KanselTuloVS = Kansanel‰kkeen ja takuuel‰kkeen perusteena oleva vuositulo vuosikeskiarvona
5. TakuuElakeKS = Takuuel‰ke kuukausitasolla
6. TakuuElakeVS = Takuuel‰ke kuukausitasolla vuosikeskiarvona
7. LapsenElakeaKS = Lapsenel‰ke kuukausitasolla
8. LapsenElakeaVS = Lapsenel‰ke kuukausitasolla vuosikeskiarvona
9. LeskenElakeaKS = Leskenel‰ke kuukausitasolla
10. LeskenElakeaVS = Leskenel‰ke kuukausitasolla vuosikeskiarvona
11. PerhElTuloKS = Perhe-el‰kkeen perusteena olevan vuositulo
12. PerhElTuloVS = Perhe-el‰kkeen perusteena olevan vuositulo vuosikeskiarvona
13. MaMuErTukiKS = Maahanmuuttajan erityistuki kuukausitasolla
14. MaMuErTukiVS = Maahanmuuttajan erityistuki kuukausitasolla vuosikeskiarvona
15. SotilasAvKS = Sotilasavustus kuukausitasolla
16. SotilasAvVS = Sotilasavustus kuukausitasolla vuosikeskiarvona 
17. VammTukiKS = Vammaistuki ja ruokavaliokorvaus kuukausitasolla
18. VammTukiVS = Vammaistuki ja ruokavaliokorvaus kuukausitasolla vuosikeskiarvona 
19. KanselLisatKS = Kansanel‰kkeeseen liittyv‰t lis‰t kuukausitasolla
20. KanselLisatVS = Kansanel‰kkeeseen liittyv‰t lis‰t kuukausitasolla vuosikeskiarvona
21. YlimRintLisaKS = Ylim‰‰r‰inen rintamalis‰ kuukausitasolla
22. YlimRintLisaVS = Ylim‰‰r‰inen rintamalis‰ kuukausitasolla vuosikeskiarvona */




/* 1. Kansanel‰ke kuukausitasolla */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, kansanel‰ke kuukausitasolla, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
    	laitos: Asuuko henkilˆ laitoksessa, 0/1
		puoliso: Onko henkilˆll‰ puoliso, 0/1
		kryhma: Kuntaryhm‰, 1/2 (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
		tyoelake: Saadun tyˆel‰kkeen m‰‰r‰, e/v
		asusuht: Asuinaikasuhteutuksen kerroin, 0-1 (t‰ysi el‰ke = 1)
		ika: Henkilˆn ik‰ vuosissa (vuodesta 2025 l‰htien alle 18-vuotiaat eiv‰t ole oikeutettuja el‰kkeeseen)
		ontyokyvyte: Onko kyseess‰ tyˆkyvyttˆmyysel‰ke, 0/1
		tyotulo: Tyˆtulo, e/kk */

%MACRO Kansanelake_SimpleKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, tyoelake, asusuht, ika,
ontyokyvyte = 0, tyotulo = 0)
/ DES = "KANSEL: Kansanel‰ke kuukausitasolla";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

	%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	/* 1.1.2010 LƒHTIEN:
	Tyˆkyvyttˆmyyden perusteella maksettava kansanel‰ke j‰tet‰‰n lep‰‰m‰‰n,
	jos tyˆtulot ylitt‰v‰t m‰‰ritellyn rajan. */
	IF &mvuosi >= 2010 AND &ontyokyvyte = 1 AND &tyotulo > &RajaTyotulo THEN DO;
		
		&tulos = 0;

	END;

	ELSE DO;

		*Pohjaosa (vakio ennen vuotta 1997);
		IF &mvuosi < 1997 THEN DO;
			pohja = &PerPohja;

			*Vuonna 1996 myˆs pohjaosa oli tyˆel‰kev‰henteinen, tosin eritt‰in korkeilla tulorajoilla;
			IF &mvuosi = 1996 THEN DO;
				IF &puoliso = 0 THEN raja = (&kryhma < 1.5) * &PohjRajaY1 + (&kryhma > 1.5) * &PohjRajaY2;
				ELSE raja = (&kryhma < 1.5) * &PohjRajaP1 + (&kryhma > 1.5) * &PohjRajaP2;
			
				IF &tyoelake > raja THEN DO;
					pohja = SUM(pohja, -&KEPros * SUM(&tyoelake, -raja) / 12);
					IF pohja < 0 THEN pohja = 0;
				END;
			END;

			 *Lis‰osa/tukiosa ennen vuotta 1997. 
			  Huom! Ennen 9/1991 puoliso-valinta tarkoittaa, ett‰ puoliso saa myˆs kansanel‰kett‰;
			IF &puoliso = 0 THEN taysitukiosa = (&kryhma < 1.5) * &TukOsY1 + (1.5 < &kryhma < 2.5) * &TukOsY2 + (&kryhma > 2.5) * &TukOsY3 + &TukiLisY;
			ELSE DO;
					IF &mvuosi < ((1991 - &paramalkuke) * 12 + 9) THEN taysitukiosa = &PuolAlenn * ((&kryhma < 1.5) * &TukOsY1 + (1.5 < &kryhma < 2.5) * &TukOsY2 + (&kryhma > 2.5) * &TukOsY3) + 0.5 * &TukiLisPP;
					ELSE taysitukiosa = (&kryhma < 1.5) *&TukOsP1 + (&kryhma > 1.5) * &TukOsP2;
			END;

			*Tyˆel‰kev‰hennys;
			IF &tyoelake <= &KERaja THEN lisosa = taysitukiosa;
			ELSE lisosa = SUM(taysitukiosa, -&KEPros * SUM(&tyoelake, -&KERaja) / 12);
			IF lisosa < 0 THEN lisosa = 0;

			*Laitosasumisen tuottama v‰hennys;
			IF &laitos NE 0 THEN DO;
				IF &kryhma < 1.5 THEN laitosraja = &LaitosRaja1;
				ELSE laitosraja = &LaitosRaja2;
				IF lisosa > laitosraja * taysitukiosa THEN lisosa = laitosraja * taysitukiosa;
			END;
		END;

		*T‰ysi el‰ke (vuoden 1996 j‰lkeen). Ei en‰‰ lis‰- ja pohjaosaa kuten ennen;
		ELSE DO;
			IF &puoliso = 0 THEN DO;	
				IF &kryhma < 1.5 THEN taysike = &TaysKEY1 * &asusuht;
				ELSE taysike = &TaysKEY2 * &asusuht;
			END;
			ELSE DO;
				IF &kryhma < 1.5 THEN taysike = &TaysKEP1 * &asusuht;
				ELSE taysike = &TaysKEP2 * &asusuht;
			END;

			IF &tyoelake > &KERaja THEN DO;
				taysike = SUM(taysike, -&KEPros * SUM(&tyoelake, -&KERaja) / 12);
				IF taysike < 0 THEN taysike = 0;
			END;

			IF &laitos NE 0 THEN DO;
				IF &puoliso = 0 THEN DO;
					IF &kryhma < 1.5 THEN raja = &LaitosTaysiY1;
					ELSE raja = &LaitosTaysiY2;
				END;
				ELSE DO;
					IF &kryhma < 1.5 THEN raja = &LaitosTaysiP1;
					ELSE raja = &LaitosTaysiP2;
				END;
				IF taysike > raja THEN taysike = raja;
			END;
		END;

		*Ennen 9/1991 makro laskee vain t‰yden el‰kkeen;
		IF kuuid < MDY(9, 1, 1991) THEN DO;
			IF &tyoelake > 0 THEN &tulos = .;
			ELSE &tulos = SUM(pohja, taysitukiosa);
		END;

		ELSE IF &mvuosi < 1997 THEN &tulos = SUM(pohja, lisosa) * &asusuht;
		ELSE &tulos = taysike;

		IF &tulos < &KEMinimi THEN &tulos = 0;

		*Vuodesta 2025 alkaen el‰kett‰ ei myˆnnet‰ alle 18-vuotiaille;
		IF &ika < &AlaIkaRaja THEN &tulos = 0;

	END;

	DROP kuuid pohja raja taysike taysitukiosa lisosa laitosraja;

%MEND Kansanelake_SimpleKS;


/* 2. Kansanel‰ke kuukausitasolla vuosikeskiarvona */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, kansanel‰ke kuukausitasolla vuosikeskiarvona, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
    	laitos: Asuuko henkilˆ laitoksessa, 0/1
		puoliso: Onko henkilˆll‰ puoliso, 0/1
		kryhma: Kuntaryhm‰, 1/2 (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
		tyoelake: Saadun tyˆel‰kkeen m‰‰r‰, e/v
		asusuht: Asuinaikasuhteutuksen kerroin, 0-1 (t‰ysi el‰ke = 1)
		ika: Henkilˆn ik‰ vuosissa (vuodesta 2025 l‰htien alle 18-vuotiaat eiv‰t ole oikeutettuja el‰kkeeseen)
		ontyokyvyte: Onko kyseess‰ tyˆkyvyttˆmyysel‰ke, 0/1
		tyotulo: Tyˆtulo, e/kk */

%MACRO Kansanelake_SimpleVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, tyoelake, asusuht, ika,
ontyokyvyte = 0, tyotulo = 0) 
/ DES = "KANSEL: Kansanel‰ke kuukausitasolla vuosikeskiarvona";

	vuosielake = 0;

	%DO i = 1 %TO 12;
		%Kansanelake_SimpleKS(temp, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &tyoelake, &asusuht, &ika, ontyokyvyte = &ontyokyvyte, tyotulo = &tyotulo);
		vuosielake = SUM(vuosielake,temp);
	%END;

	&tulos = vuosielake / 12;

	DROP vuosielake temp;

%MEND Kansanelake_SimpleVS;


/* 3. Makro laskee kansanel‰kkeen ja takuuel‰kkeen perusteena olevan vuositulon; 
      t‰m‰ toimii vuodesta 1990 l‰htien, muttei kaikilta osin erikoislains‰‰d‰ntˆvuonna 1996 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansanel‰kkeen ja takuuel‰kkeen perusteena oleva tulo, e/v 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laitos: Asuuko henkilˆ laitoksessa (0/1)
	puoliso: Onko henkilˆll‰ puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	elake: Saatu kansanel‰kkeen m‰‰r‰, e/kk
	takuuel: Onko kyseess‰ takuuel‰ke (0/1)
	asusuht: Asuinaikasuhteutus (0-1), t‰ysi=1
	kertoimet: Lykk‰ys- ja varhennuskertoimet (0-), t‰ysi=1;

%MACRO KanselTuloKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, elake, takuuela, asusuht, kertoimet) / 
DES = 'KANSEL: Kansanel‰kkeen ja takuuel‰kkeen perusteena oleva vuositulo';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF &takuuela NE 1 THEN DO;
	
	*Ennen vuotta 1997 k‰ytetty lains‰‰d‰ntˆ, jossa sek‰ pohja- ett‰ lis‰osa;
	IF &mvuosi < 1997 THEN DO;
		elake2 = &elake / (&asusuht * &kertoimet);
		temp = 0;
		pohja = &PerPohja;
	
		IF &puoliso = 0 THEN DO;	
			IF &kryhma < 1.5 THEN taysitukiosa = &TukOsY1;
			ELSE taysitukiosa = &TukOsY2;
		END;
		ELSE DO;
			IF &kryhma < 1.5 THEN taysitukiosa = &TukOsP1;
			ELSE taysitukiosa = &TukOsP2;
		END;
	
		IF &kryhma < 1.5 THEN laitosraja = &LaitosRaja1;
		ELSE laitosraja = &LaitosRaja2;
	
		IF (&laitos = 0 AND elake2 < SUM(pohja, taysitukiosa)) OR (&laitos NE 0 AND elake2 < SUM(pohja, laitosraja * taysitukiosa)) 
		THEN temp = SUM(SUM(pohja, taysitukiosa, -elake2) / &KEPros, &KERaja / 12);
	END;

	*Vuosina 1997-2010 k‰ytetty lains‰‰d‰ntˆ, jossa vain yksi osa;

	ELSE DO;
		temp = 0;
		elake2 = &elake / &kertoimet;
	
		IF &puoliso = 0 THEN DO;	
			IF &kryhma < 1.5 THEN DO;
				taysike = &TaysKEY1 * &asusuht;
				raja = &LaitosTaysiY1;
			END;
			ELSE DO;
				taysike = &TaysKEY2 * &asusuht;
				raja = &LaitosTaysiY2;
			END;
		END;

		ELSE DO;
			IF &kryhma < 1.5 THEN DO;
				taysike = &TaysKEP1 * &asusuht;
				raja = &LaitosTaysiP1;
			END;
			ELSE DO;
				taysike = &TaysKEP2 * &asusuht;
				raja = &LaitosTaysiP2;
			END;
		END;

		IF (&laitos = 0 AND elake2 < taysike) OR (&laitos NE 0 AND elake2 < raja) THEN temp = 12 * SUM(SUM(taysike, -elake2) / &KEPros, &KERaja / 12);
	END;
END;

*Takuuel‰kett‰ koskeva p‰‰ttely. Tulomaksimi = takuuel‰ke;
ELSE IF kuuid > MDY(2, 1, 2011) THEN temp = ((&TakuuEl * &kertoimet) - &elake) * 12;

IF temp < 0 THEN temp = 0;
IF kuuid < MDY(9, 1, 1991) THEN &tulos = .;
ELSE IF &elake < &KEMinimi OR (&elake < &PerPohja AND &mvuosi < 1997) THEN &tulos = 99999999; 
ELSE &tulos = temp;

DROP temp taysike taysitukiosa pohja raja laitosraja kuuid elake2;
%MEND KanselTuloKS;


/* 4. Kansanel‰kkeen ja takuuel‰kkeen perusteena oleva vuositulo vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansanel‰kkeen ja takuuel‰kkeen perusteena oleva tulo, e/vuosi 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laitos: Asuuko henkilˆ laitoksessa (0/1)
	puoliso: Onko henkilˆll‰ puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	elake: Saatu kansanel‰kkeen m‰‰r‰, e/kk
	takuuel: Onko kyseess‰ takuuel‰ke (0/1)
	asusuht: Asuinaikasuhteutus (0-1), t‰ysi=1
	kertoimet: Lykk‰ys- ja varhennuskertoimet (0-), t‰ysi=1;

%MACRO KanselTuloVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, elake, takuuela, asusuht, kertoimet) / 
DES = 'KANSEL: Kansanel‰kkeen ja takuuel‰kkeen perusteena oleva vuositulo vuosikeskiarvona';

vuositulo = 0;

%DO i = 1 %TO 12;
	%KanselTuloKS(temp2, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &elake, &takuuela, &asusuht, &kertoimet);
	vuositulo = SUM(vuositulo, temp2);
%END;

&tulos = vuositulo / 12;

DROP vuositulo temp2;
%MEND KanselTuloVS;


/* 5. Takuuel‰ke kuukausitasolla (voimassa 3/2011-) */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, takuuel‰ke kuukausitasolla, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kokonelake: Muut el‰kkeet (tyˆ-, perhe-, kansanel‰kkeet ym.) yhteens‰, e/kk
		varhkerr: Varhennusv‰hennyksen kerroin, 0-1 (t‰ysi el‰ke = 1)
		ika: Henkilˆn ik‰ vuosissa (vuodesta 2025 l‰htien alle 18-vuotiaat eiv‰t ole oikeutettuja el‰kkeeseen)
		ontyokyvyte: Onko kyseess‰ tyˆkyvyttˆmyysel‰ke, 0/1
		tyotulo: Tyˆtulo, e/kk */

%MACRO TakuuElakeKS(tulos, mvuosi, mkuuk, minf, kokonelake, varhkerr, ika, 
ontyokyvyte = 0, tyotulo = 0)
/ DES = "KANSEL: Takuuel‰ke kuukausitasolla";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

	/* Tyˆkyvyttˆmyyden perusteella maksettava takuuel‰ke j‰tet‰‰n lep‰‰m‰‰n,
	jos tyˆtulot ylitt‰v‰t m‰‰ritellyn rajan. */
	IF &ontyokyvyte = 1 AND &tyotulo > &RajaTyotulo THEN DO;
		
		&tulos = 0;

	END;

	ELSE DO;

		/* Takuuel‰ke on takuuel‰kerajan ja muiden saatujen el‰kkeiden erotus */ 
		IF &kokonelake < &TakuuEl * &varhkerr THEN temp = &TakuuEl * &varhkerr - &kokonelake;
		ELSE temp = 0;

		IF temp < &KEMinimi THEN temp = 0;

		IF &ika < &AlaIkaRaja THEN temp = 0;
 
		&tulos = temp;

	END;

	DROP kuuid temp;

%MEND TakuuElakeKS;


/* 6. Takuuel‰ke kuukausitasolla vuosikeskiarvona (voimassa 3/2011-) */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, takuuel‰ke kuukausitasolla vuosikeskiarvona, e/kk 
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kokonelake: Muut el‰kkeet (tyˆ-, perhe-, kansanel‰kkeet ym.) yhteens‰, e/kk
		varhkerr: Varhennusv‰hennyksen kerroin, 0-1 (t‰ysi el‰ke = 1)
		ika: Henkilˆn ik‰ vuosissa (vuodesta 2025 l‰htien alle 18-vuotiaat eiv‰t ole oikeutettuja el‰kkeeseen)
		ontyokyvyte: Onko kyseess‰ tyˆkyvyttˆmyysel‰ke, 0/1
		tyotulo: Tyˆtulo, e/kk */

%MACRO TakuuElakeVS(tulos, mvuosi, minf, kokonelake, varhkerr, ika,
ontyokyvyte = 0, tyotulo = 0)
/ DES = "KANSEL: Takuuel‰ke kuukausitasolla vuosikeskiarvona";

	vuositulo = 0;

	%DO i = 1 %TO 12;
		%TakuuElakeKS(temp, &mvuosi, &i, &minf, &kokonelake, &varhkerr, &ika, ontyokyvyte = &ontyokyvyte, tyotulo = &tyotulo);
		vuositulo = SUM(vuositulo, temp);
	%END;

	&tulos = vuositulo / 12;

	DROP vuositulo temp;

%MEND TakuuElakeVS;


/* 7. Makro laskee lapsenel‰kkeen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsenel‰ke, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	tays: Onko t‰ysorpo (=molemmat vanhemmat kuolleet) (0/1) 
	elake: Saadut muut el‰ketulot, e/vuosi
	koulel: Onko koululaisel‰ke (0/1);

%MACRO LapsenElakeaKS(tulos, mvuosi, mkuuk, minf, tays, elake, koulel) / 
DES = 'KANSEL: Lapsenel‰ke kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

*Muut el‰ketulot pienent‰v‰t lapsenel‰kkeen t‰ydennysm‰‰r‰‰ tietyn rajan j‰lkeen;

IF &koulel = 0 THEN DO;
	temp = &LapsElTayd;
	IF &elake > &KERaja THEN temp = SUM(temp, -&KEPros * SUM(&elake, -&KERaja) / 12);
	IF temp < 0 THEN temp = 0;
END;
ELSE temp = 0;

temp = SUM(&LapsElPerus, temp);

*T‰ysorvoille tuki on kaksinkertainen, koska tuki tulee kummastakin vanhemmasta;
IF &tays NE 0 THEN temp = 2 * temp;

IF &mvuosi < 1990 THEN &tulos = .;
ELSE IF temp < &LapsElMinimi THEN &tulos = 0;
ELSE &tulos = temp;

DROP temp;
%MEND LapsenElakeaKS;


/* 8. Makro laskee lapsenel‰kkeen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsenel‰ke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	tays: Onko t‰ysorpo (=molemmat vanhemmat kuolleet) (0/1) 
	elake: Saadut muut el‰ketulot, e/vuosi
	koulel: Onko koululaisel‰ke (0/1); 

%MACRO LapsenElakeaVS(tulos, mvuosi, minf, tays, elake, koulel) / 
DES = 'KANSEL: Lapsenel‰ke kuukausitasolla vuosikeskiarvona';

vuosielake = 0;

%DO i = 1 %TO 12;
	%LapsenElakeaKS(temp2, &mvuosi, &i, &minf, &tays, &elake, &koulel);
	vuosielake = SUM(vuosielake, temp2);
%END;

&tulos = vuosielake / 12;

DROP vuosielake temp2;
%MEND LapsenElakeaVS;


/* 9. Makro laskee leskenel‰kkeen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, leskenel‰ke, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alku: Onko kyseess‰ lesken alkuel‰ke (0/1)
	puoliso: Onko henkilˆll‰ uusi puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko henkilˆll‰ lapsia (0/1)
	tyotulo: Tyˆtulot (e/vuosi)
	potulo: P‰‰omatulot (e/vuosi)
	eltulo: Muut el‰ketulot (e/vuosi)
	varall: Veronalainen varallisuus, e (ei merkityst‰ lains‰‰d‰nnˆss‰ vuoden 2007 j‰lkeen);

%MACRO LeskenElakeaKS(tulos, mvuosi, mkuuk, minf, alku, puoliso, kryhma, lapsia, tyotulo, potulo, eltulo, varall) / 
DES = 'KANSEL: Leskenel‰ke kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

*Varallisuudesta otettiin huomioon vain pieni osa tietyn rajan j‰lkeen;
IF &varall > &PerhElOmRaja THEN potulo = SUM(&potulo, &PerhElOmPros * SUM(&varall, -&PerhElOmRaja));
ELSE potulo = &potulo;

*Tulojen yhteissumma. Tyˆtulosta otetaan huomioon vain tietty osuus;
tulo = SUM(&tyotulo * &LeskTyoTuloOsuus, potulo, &eltulo);

*Leskenel‰kkeen lis‰osan parametrin m‰‰ritys. Ennen vuotta 1991 puolisolla ei ollut vaikutusta;
IF &kryhma < 2 THEN DO;
	IF &puoliso = 0 OR kuuid < MDY(9, 1, 1991) THEN taystayd = &LeskTaydY1;
	ELSE taystayd = &LeskTaydP1;
END;
ELSE DO;
	IF &puoliso = 0 OR kuuid < MDY(9, 1, 1991) THEN taystayd = &LeskTaydY2;
	ELSE taystayd = &LeskTaydP2;
END;

*Tulojen v‰hent‰v‰ vaikutus lis‰osaan tietyn vuositulorajan j‰lkeen;
IF tulo > &KERaja THEN DO;
	vahtayd = SUM(taystayd, -&KEPros * SUM(tulo, -&KERaja) / 12);
	IF vahtayd < 0 THEN vahtayd = 0;
END;
ELSE vahtayd = taystayd;

*Jos on kyseess‰ ns. alkuel‰ke (jota maksetaan puolen vuoden j‰lkeen kuolemasta), tulojen vaikutus el‰kkeeseen on rajattu. 
Ennen vuotta 2008 alkuel‰ke oli perusm‰‰r‰ + v‰hint‰‰n tietty osa t‰ydennysm‰‰r‰st‰. Vuodesta 2008 l‰htien alkuel‰ke on kiinte‰m‰‰r‰inen etuus;
IF &alku NE 0 THEN DO;
	IF &mvuosi < 2008 THEN DO;

		IF &kryhma < 1.5 THEN kerroin = &LeskAlkuMinimi1;
		ELSE kerroin = &LeskAlkuMinimi2;

		IF vahtayd < kerroin * taystayd THEN vahtayd = kerroin * taystayd;
		temp = &LeskPerus + vahtayd;
	END;

	ELSE temp = &LeskAlku;
END;

*Ei alkuel‰ke. Jos on lapsia, siihen lis‰t‰‰n perusosa. Muuten se on pelkk‰ tulov‰henteinen lis‰osa;
ELSE DO;
	IF &lapsia > 0 THEN temp = &LeskPerus + vahtayd;
	ELSE temp = vahtayd;
END;


*Koodi ei sis‰ll‰ vuotta 1983 aikaisempaa lains‰‰d‰ntˆ‰;
IF &mvuosi < 1983 THEN &tulos = .;

ELSE IF temp < &LeskMinimi THEN &tulos = 0;
ELSE &tulos = temp;

DROP temp kuuid vahtayd taystayd kerroin potulo tulo;
%MEND LeskenElakeaKS;


/* 10. Makro laskee leskenel‰kkeen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, leskenel‰ke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alku: Onko kyseess‰ lesken alkuel‰ke (0/1)
	puoliso: Onko henkilˆll‰ uusi puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko henkilˆll‰ lapsia (0/1)
	tyotulo: Tyˆtulot (e/vuosi)
	potulo: P‰‰omatulot (e/vuosi)
	eltulo: Muut el‰ketulot (e/vuosi)
	varall: Veronalainen varallisuus, e (ei merkityst‰ lains‰‰d‰nnˆss‰ vuoden 2007 j‰lkeen);

%MACRO LeskenElakeaVS(tulos, mvuosi, minf, alku, puoliso, kryhma, lapsia, tyotulo, potulo, eltulo, varall) /
DES = 'KANSEL: Leskenel‰ke kuukausitasolla vuosikeskiarvona';

vuosielake = 0;

%DO i = 1 %TO 12;
	%LeskenElakeaKS(temp2, &mvuosi, &i, &minf, &alku, &puoliso, &kryhma, &lapsia, &tyotulo, &potulo, &eltulo, &varall);
	vuosielake = SUM(vuosielake, temp2);
%END;

&tulos = vuosielake / 12;
DROP vuosielake temp2;
%MEND LeskenElakeaVS;


/* 11. Makro laskee perhe-el‰kkeen perusteena olevan vuositulon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Perhe-el‰kkeen perusteena oleva tulo, e/vuosi 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laps: Onko kyseess‰ lapsenel‰ke (0/1)
	tays: Onko kyseess‰ t‰ysorpo (0/1)
	alku: Onko kyseess‰ lesken alkuel‰ke (0/1)
	puoliso: Onko henkilˆll‰ uusi puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko leskell‰ lapsia (0/1)
	taydmaara: Saadun el‰kkeen (tuloriippuvaisen) t‰ydennysosan suuruus, e/kk;

%MACRO PerhElTuloKS(tulos, mvuosi, mkuuk, minf, laps, tays, alku, puoliso, kryhma, lapsia, taydmaara) /
DES = 'KANSEL: Perhe-el‰kkeen perusteena olevan vuositulo';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

taydmaara = &taydmaara;

*Lasketaan lapsenel‰kkeiden t‰ysi t‰ydennysm‰‰r‰;
IF &laps NE 0 THEN DO;
	pieninel = &LapsElMinimi;
	perus2 = &LapsElPerus;
	%LapsenelakeAKS(taysitayd, &mvuosi, &mkuuk, &minf, &tays, 0, 0);

	*T‰ysorvoilla ollessa kaksinkertainen etuus, jaetaan ne kahdella;
	IF &tays NE 0 THEN	DO;
		taysitayd = SUM(taysitayd / 2, -perus2);
		taydmaara = &taydmaara / 2;
	END;

	ELSE taysitayd = SUM(taysitayd, -perus2);
END;

*Lasketaan leskenel‰kkeiden t‰ysi t‰ydennysm‰‰r‰;
ELSE DO;
	pieninel = &LeskMinimi;
	IF &alku = 0 THEN DO;
		IF &lapsia > 0 THEN perus2 = &LeskPerus;
		ELSE perus2 = 0;
	END;

	ELSE DO;
		%LeskenElakeAKS(perus2, &mvuosi, &mkuuk, &minf, 1, &puoliso, &kryhma, 0, 0, 0, 999999, 0);
	END;

	%LeskenElakeAKS(taysitayd, &mvuosi, &mkuuk, &minf, (&alku NE 0), &puoliso, &kryhma, 0, 0, 0, 0, 0);
	taysitayd = taysitayd - perus2;
END;

*Lasketaan t‰ydennysm‰‰r‰‰ v‰hent‰neen tulon suuruus;
IF taydmaara <= 0 OR SUM(taydmaara, perus2) < pieninel THEN temp2 = 99999999;
ELSE IF taydmaara >= 0 AND taydmaara < taysitayd AND &KEPros > 0 THEN temp2 = SUM( SUM(taysitayd, -taydmaara) / &KEPros, &KERaja / 12);
ELSE temp2 = 0;

&tulos = temp2;
DROP temp2 taysitayd pieninel taydmaara perus2;
%MEND PerhElTuloKS;


/* 12. Makro laskee perhe-el‰kkeen perusteena olevan vuositulon vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, perhe-el‰kkeen perusteena oleva tulo, e/vuosi (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laps: Onko kyseess‰ lapsenel‰ke (0/1)
	tays: Onko kyseess‰ t‰ysorpo (0/1)
	alku: Onko kyseess‰ lesken alkuel‰ke (0/1)
	puoliso: Onko henkilˆll‰ uusi puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko leskell‰ lapsia (0/1)
	taydmaara: Saadun el‰kkeen (tuloriippuvaisen) t‰ydennysosan suuruus, e/kk;

%MACRO PerhElTuloVS(tulos, mvuosi, minf, laps, taysi, alku, puoliso, kryhma, lapsia, taydmaara) / 
DES = 'KANSEL: Perhe-el‰kkeen perusteena oleva vuositulo vuosikeskiarvona';

tulo2 = 0;

%DO i = 1 %TO 12;
	%PerhElTuloKS(temp3, &mvuosi, &i, &minf, &laps, &taysi, &alku, &puoliso, &kryhma, &lapsia, &taydmaara);
	tulo2 = SUM(tulo2, temp3);
%END;

&tulos = tulo2 / 12;
DROP tulo2 temp3;
%MEND PerhElTuloVS;


/* 13. Makro laskee maahanmuuttajan erityistuen kuukausitasolla (voimassa 10/2003 - 3/2011) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, maahanmuuttajan erityistuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laitos: Asuuko henkilˆ laitoksessa (0/1)
	puoliso: Onko henkilˆll‰ puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko henkilˆll‰ lapsia (0/1)
	omatulo: Henkilˆn muut tulot, e/kk
	puoltulo: Henkilˆn puolison muut tulot, e/kk;

%MACRO MaMuErTukiKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, omatulo, puoltulo) / 
DES = 'KANSEL: Maahanmuuttajan erityistuki kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

*Maahanmuuttajan erityistuki oli yht‰ suuri kuin kansanel‰ke, mutta tulot v‰hent‰v‰t sit‰ t‰ysim‰‰r‰isesti;
%Kansanelake_SimpleKS(temp2, &mvuosi, &mkuuk, &minf, &laitos, &puoliso, &kryhma, 0, 1, 0);

IF &omatulo > 0 OR &puoltulo > 0 THEN temp2 = SUM(temp2, -&omatulo, -(&puoltulo > temp2 AND &puoliso = 1) * SUM(&puoltulo, -temp2));

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

IF kuuid < MDY(10, 1, 2003) OR kuuid >= MDY(3, 1, 2011) THEN &tulos = .;
ELSE IF temp2 < &KEMinimi THEN &tulos = 0;
ELSE &tulos = temp2;
DROP temp2 kuuid;
%MEND MaMuErTukiKS;


/* 14. Makro laskee maahanmuuttajan erityistuen kuukausitasolla vuosikeskiarvona (voimassa 10/2003 - 3/2011) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, maahanmuuttajan erityistuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	laitos: Asuuko henkilˆ laitoksessa (0/1)
	puoliso: Onko henkilˆll‰ puoliso (0/1)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Onko henkilˆll‰ lapsia (0/1)
	omatulo: Henkilˆn muut tulot, e/kk
	puoltulo: Henkilˆn puolison muut tulot, e/kk;

%MACRO MaMuErTukiVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, omatulo, puoltulo) / 
DES = 'KANSEL: Maahanmuuttajan erityistuki kuukausitasolla vuosikeskiarvona';

vuositulo = 0;

%DO i = 1 %TO 12;
	%MaMuErTukiKS(temp3, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &omatulo, &puoltulo);
	vuositulo = SUM(vuositulo, temp3);
%END;

&tulos = vuositulo / 12;
DROP vuositulo temp3;

%MEND MaMuErTukiVS;


/* 15. Makro laskee sotilasavustuksen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, sotilasavustus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	jasenia: Avustettavien perheenj‰senien lkm
	asummenot: Asumismenot, e/kk
	omatulo: Henkilˆn omat tyˆtulot, e/kk
	puoltulo: Puolison tyˆtulot, e/kk;

%MACRO SotilasAvKS(tulos, mvuosi, mkuuk, minf, kryhma, jasenia, asummenot, omatulo, puoltulo) / 
DES = 'KANSEL: Sotilasavustus kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

%Kansanelake_SimpleKS(taysi, &mvuosi, &mkuuk, &minf, 0, 0, &kryhma, 0, 1, 18);

IF &jasenia < 1 THEN temp = 0;
ELSE IF &jasenia < 2 THEN temp = &SotAvPros1 * taysi;
ELSE temp = ((&jasenia - 2) * &SotAvPros3 + &SotAvPros1 + &SotAvPros2) * taysi;


IF &mvuosi >= 2022 THEN omatulo = &omatulo - &SotAvSuoj; /*Suojaosa asevelvollisen tyˆtuloihin 1.1.2022 alkaen*/
ELSE omatulo = &omatulo;

IF omatulo < 0 then omatulo=0;

tulot = omatulo + &puoltulo;

temp = SUM(temp, &asummenot, -tulot);

IF &mvuosi < 1994 THEN temp = .;
ELSE IF temp < &SotAvMinimi THEN temp = 0;

&tulos = temp;
DROP temp taysi omatulo tulot;
%MEND SotilasAvKS;


/* 16. Makro laskee sotilasavustuksen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, sotilasavustus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuonna 2008 ja sen j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	jasenia: Avustettavien perheenj‰senien lkm
	asummenot: Asumismenot, e/kk
	omatulo: Henkilˆn omat tyˆtulot, e/kk
	puoltulo: Puolison tyˆtulot, e/kk;

%MACRO SotilasAvVS(tulos, mvuosi, minf, kryhma, jasenia, asummenot, omatulo,puoltulo) / 
DES = 'KANSEL: Sotilasavustus kuukausitasolla vuosikeskiarvona';

sotav = 0;

%DO i = 1 %TO 12;
	%SotilasAvKS(temp, &mvuosi, &i, &minf, &kryhma, &jasenia, &asummenot, &omatulo, &puoltulo);
	sotav = SUM(sotav, temp);
%END;

&tulos = sotav / 12;
DROP temp sotav;
%MEND SotilasAvVS;


/* 17. Makro laskee vammaistuen ja ruokavaliokorvauksen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vammaistuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	vammtuki: Onko kyseess‰ normaali vammaistuki (0/1)
	lapshoituki: Onko kyseess‰ alle 16-vuotiaan vammasituki (0/1)
	keliakia: Onko kyseess‰ ruokavaliokorvaus (0/1)
	aste: Korvauksen aste (1/2/3);

%MACRO VammTukiKS(tulos, mvuosi, mkuuk, minf, vammtuki, lapshoituki, keliakia, aste) / 
DES = 'KANSEL: Vammaistuki ja ruokavaliokorvaus kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

temp = 0;

*Normaali vammaistuki;
IF &vammtuki NE 0 THEN DO;
	IF &aste = 1 THEN temp = &VammNorm;
	ELSE IF &aste in (2,4) THEN temp = &VammKorot;
	ELSE IF &aste = 3 THEN temp = &VammErit;
END;

*Alle 16-vuotiaan vammasituki;
IF &lapshoituki NE 0 THEN DO;
	IF &aste = 1 THEN temp = temp + &LapsHoitTukNorm;
	ELSE IF &aste = 2 THEN temp = temp + &LapsHoitTukKorot;
	ELSE IF &aste = 3 THEN temp = temp + &LapsHoitTukErit;
END;

*Ruokavaliokorvaus;
IF &keliakia NE 0 THEN temp = temp + &Keliak;

&tulos = temp;
DROP temp;
%MEND VammTukiKS;


/* 18. Makro laskee vammaistuen ja ruokavaliokorvauksen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vammaistuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	vammtuki: Onko kyseess‰ normaali vammaistuki (0/1)
	lapshoituki: Onko kyseess‰ alle 16-vuotiaan vammasituki (0/1)
	keliakia: Onko kyseess‰ ruokavaliokorvaus (0/1)
	aste: Korvauksen aste (1/2/3);

%MACRO VammTukiVS(tulos, mvuosi, minf, vammtuki, lapshoituki, keliakia, aste) / 
DES = 'KANSEL: Vammaistuki ja ruokavaliokorvaus kuukausitasolla vuosikeskiarvona';

vamtuki = 0;

%DO i = 1 %TO 12;
	%VammTukiKS(temp, &mvuosi, &i, &minf, &vammtuki, &lapshoituki, &keliakia, &aste);
	vamtuki = SUM(vamtuki, temp);
%END;

&tulos = vamtuki / 12;
DROP temp vamtuki;
%MEND VammTukiVS;


/* 19. Makro laskee kansanel‰kkeeseen tulevat lis‰t kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansanel‰kkeeseen tulevat lis‰t, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alkava: Onko kyseess‰ alkava el‰ke (0/1)
	apulisa: Onko suojattua apulis‰‰ (0/1) (ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1988 j‰lkeen) tai veteraanilis‰, jos myˆs hoitotuki2 tai hoitotuki3 valittu
	hoitolisa: Onko suojattua hoitolis‰‰ (0/1) (ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1988 j‰lkeen)
	hoitotuki1: Onko normaalia hoitotukea (0/1)
	hoitotuki2: Onko korotettua hoitotukea (0/1)
	hoitotuki3: Onko erityishoitotukea (0/1)
	ril: Onko rintamalis‰‰ (0/1)
	puollis: Onko puolisolis‰‰ (0/1) (ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1996 j‰lkeen)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Lapsien lkm;

%MACRO KanselLisatKS(tulos, mvuosi, mkuuk, minf, alkava, apulisa, hoitolisa, hoitotuki1, hoitotuki2, hoitotuki3, ril, puollis, kryhma, lapsia) /
DES = 'KANSEL: Kansanel‰kkeeseen liittyv‰t lis‰t kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

temp = 0;

IF &hoitolisa NE 0 THEN temp = &HoitoLis;
ELSE IF &hoitotuki1 NE 0 THEN temp = &HoitTukiNorm;
ELSE IF &hoitotuki2 NE 0 THEN temp = &HoitTukiKor;
ELSE IF &hoitotuki3 NE 0 THEN temp = &HoitTukiErit;

IF &apulisa NE 0 THEN DO;
	IF &hoitotuki2 NE 0 OR &hoitotuki3 NE 0 THEN temp = SUM(temp, &VeterLisa);
	ELSE temp = &ApuLis;
END;

IF &ril NE 0 THEN temp = SUM(temp,(ROUND((&RiLi/12),.01)));
IF &puollis NE 0 AND (&alkava = 0 OR &mvuosi < 1996) THEN temp = SUM(temp, &PuolisoLis);
IF (&mvuosi < 1996 OR &mvuosi > 2001) OR &alkava = 0 THEN temp = SUM(temp, &lapsia * &KELaps);

&tulos = temp;
DROP temp;
%MEND KanselLisatKS;


/* 20. Makro laskee kansanel‰kkeeseen tulevat lis‰t kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansanel‰kkeeseen tulevat lis‰t, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alkava: Onko kyseess‰ alkava el‰ke (0/1)
	apulisa: Onko suojattua apulis‰‰ (0/1) (ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1988 j‰lkeen)
	hoitolisa: Onko suojattua hoitolis‰‰ (0/1) (ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1988 j‰lkeen)
	hoitotuki1: Onko normaalia hoitotukea (0/1)
	hoitotuki2: Onko korotettua hoitotukea (0/1)
	hoitotuki3: Onko erityishoitotukea (0/1)
	ril: Onko rintamalis‰‰ (0/1)
	puollis: Onko puolisolis‰‰ (0/1) (Ei makseta en‰‰ alkaviin el‰kkeisiin vuoden 1996 j‰lkeen)
	kryhma: Kuntaryhm‰ (1/2) (ei merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰)
	lapsia: Lapsien lkm;

%MACRO KanselLisatVS(tulos, mvuosi, minf, alkava, apulisa, hoitolisa, hoitotuki1, hoitotuki2, hoitotuki3, ril, puollis, kryhma, lapsia) /
DES = 'KANSEL: Kansanel‰kkeeseen liittyv‰t lis‰t kuukausitasolla vuosikeskiarvona';

lisat2 = 0;

%DO i = 1 %TO 12;
	%KanselLisatKS(temp2, &mvuosi, &i, &minf, &alkava, &apulisa, &hoitolisa, &hoitotuki1, &hoitotuki2, &hoitotuki3, &ril, &puollis, &kryhma, &lapsia);
	lisat2 = SUM(lisat2, temp2);
%END;

&tulos = lisat2 / 12;
DROP lisat2 temp2;
%MEND KanselLisatVS;


/* 21. Makro laskee ylim‰‰r‰isen rintamalis‰n kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, ylim‰‰r‰inen rintamalis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	lisaosa: Saadun lis‰osan suuruus, e/kk (merkityst‰ vain vuotta 1997 aikaisemmassa lains‰‰d‰nnˆss‰)
	kanselake: Saadun kansanel‰kkeen m‰‰r‰, e/kk
	tyoelake: Saadun tyˆel‰kkeen m‰‰r‰, e/kk (merkityst‰ vain 4/2000 j‰lkeen);

%MACRO YlimRintLisaKS(tulos, mvuosi, mkuuk, minf, lisaosa, kanselake, tyoelake) / 
DES = 'KANSEL: Ylim‰‰r‰inen rintamalis‰ kuukausitasolla';

%HaeParam&TYYPPI(&mvuosi, &mkuuk, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInf&TYYPPI(&mvuosi, &mkuuk, &KANSEL_MUUNNOS, &minf);

%LuoKuuID(kuuid, &mvuosi, &mkuuk);

*Ennen vuotta 1997 ylim. rintamalis‰ oli tietty osuus kansanel‰kkeen lis‰osasta;
IF &mvuosi < 1997 THEN DO;
	temp = &YliRiliPros * &lisaosa;
	IF temp < &YliRiliMinimi THEN temp = 0;
END;

*Vuoden 1997 j‰lkeen ylim. rintamalis‰ oli tietty prosentti kansanel‰kkeen tietyn rajan ylitt‰v‰st‰ osasta, 
 mutta kuitenkin minimin verran;
ELSE DO;

	*Vuoden 2000 j‰lkeen tyˆel‰kkeet vaikuttavat rintamalis‰prosenttiin alentaen askel askeleelta;
	IF kuuid >= MDY(4, 1, 2000) AND &tyoelake > 0 THEN DO;

			IF &tyoelake * 12 <= &KERaja THEN prosvah = FLOOR(&tyoelake * 12 / SUM(&YliRiliAskel));
			ELSE prosvah = SUM(FLOOR(&KERaja / SUM(&YliRiliAskel)), FLOOR(SUM(&tyoelake * 12, -&KERaja) / SUM(&YliRiliAskel2)));

			ylirilipros = &YliRiliPros - prosvah / 100;
			IF ylirilipros < &YliRiliPros2 THEN ylirilipros = &YliRiliPros2;
	END;
	ELSE ylirilipros = &YliRiliPros; 
	
	temp = 0;
	IF 12 * &kanselake > &YliRiliRaja THEN temp = ylirilipros * SUM(&kanselake, -&YliRiliRaja / 12);
	IF temp < &YliRiliMinimi AND &kanselake > 0 THEN temp = &YliRiliMinimi;
END;

&tulos = temp;
DROP temp ylirilipros kuuid prosvah;
%MEND YlimRintLisaKS;


/* 22. Makro laskee ylim‰‰r‰isen rintamalis‰n kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, ylim‰‰r‰inen rintamalis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	lisaosa: Saadun lis‰osan suuruus, e/kk (merkityst‰ vain vuotta 1997 aikaisemmassa lains‰‰d‰nnˆss‰)
	kanselake: Saadun kansanel‰kkeen m‰‰r‰, e/kk
	tyoelake: Saadun tyˆel‰kkeen m‰‰r‰, e/kk (merkityst‰ vain 4/2000 j‰lkeen);

%MACRO YlimRintLisaVS(tulos, mvuosi, minf, lisaosa, kanselake, tyoelake) / 
DES = 'KANSEL: Ylim‰‰r‰inen rintamalis‰ kuukausitasolla vuosikeskiarvona';

rintlis = 0;

%DO i = 1 %TO 12;
	%YlimRintLisaKS(temp, &mvuosi, &i, &minf, &lisaosa, &kanselake, &tyoelake); 
	rintlis = SUM(rintlis, temp);
%END;

temp = rintlis / 12;
&tulos = temp;
DROP temp rintlis;
%MEND YlimRintLisaVs;