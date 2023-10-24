/**************************************************
* Kuvaus: Toimeentulotuen lains‰‰d‰ntˆ‰ makroina. *
* Viimeksi p‰ivitetty: 27.7.2018				  *
**************************************************/

/* Tiedosto sis‰lt‰‰ seuraavat makrot:

1. LapsKerrS = Alaik‰isten lasten osuus desimaalilukuna toimeentulotuen peruosasta
2. ToimTukiKS = Toimeentulotuki kuukaudessa
3. ToimTukiVS = Toimeentulotuki vuosikeskiarvona
4. ToimTukiLLKS = Toimeentulotuen perusosa ja lapsilis‰t yhteens‰ kuukaudessa
5. VahimmTuloS = Toimeentulotuen perusosa, maksimaalinen yleisess‰ asumistuessa hyv‰ksytt‰v‰ asumiskustannus
				 ja lapsilis‰t yhteens‰ kuukaudessa */




/* 1. Alaik‰isten lasten osuus desimaalilukuna toimeentulotuen perusosasta */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, alaik‰isten lasten osuus desimaalilukuna toimeentulotuen perusosasta
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		lapsia17: 17-vuotiaiden lasten lukum‰‰r‰
		lapsia10_16: 10-16-vuotiaiden lasten lukum‰‰r‰
		lapsiaalle10: Alle 10-vuotiaiden lasten lukum‰‰r‰ */ 
	
%MACRO LapsKerrS(tulos, mvuosi, mkuuk, lapsia17, lapsia10_16, lapsiaalle10)/
DES = "TOIMTUKI: Alaik‰isten lasten osuus desimaalilukuna toimeentulotuen perusosasta";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_PARAM, PARAM.&PTOIMTUKI); 

	*Lasketaan aluksi kerroin, kun lasten lukum‰‰r‰‰n liittyvi‰ v‰hennyksi‰ ei oteta huomioon.;
	%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	*Vuoden 1998 maaliskuusta l‰htien myˆs 17-vuotiaat on katsottu toimeentulotuessa lapsiksi.;
	IF kuuid >= MDY(3, 1, 1998) THEN DO;
		lapsiayht = SUM(&lapsia17, &lapsia10_16, &lapsiaalle10);
		kerrennenvah = SUM(&lapsia17 * &Lapsi17, &lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
	END;
	ELSE DO;
		lapsiayht = SUM(&lapsia10_16, &lapsiaalle10);
		kerrennenvah = SUM(&lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
	END;
	kerr = kerrennenvah;

	*Lasten lukum‰‰r‰‰n liittyv‰t v‰hennykset huomioon.;
	IF lapsiayht >= 2 THEN DO;
		kerr = SUM(kerr, -&LapsiVah2);
		IF lapsiayht >= 3 THEN DO;
			kerr = SUM(kerr, -&LapsiVah3);
			IF lapsiayht >= 4 THEN DO;
				kerr = SUM(kerr, -&LapsiVah4);
				IF lapsiayht >= 5 THEN DO;
					kerr = SUM(kerr, - &LapsiVah5 * (SUM(lapsiayht, -4)));
				END;
			END;
		END;
	END;

	&tulos = kerr;

	DROP kuuid lapsiayht kerrennenvah kerr;

%MEND LapsKerrS;


/* 2. Toimeentulotuki kuukaudessa */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, toimeentulotuki kuukaudessa, e/kk
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kryhma: Toimeentulotuen kuntaryhm‰
		ydinp: Onko kyseess‰ ydinperhe, 0/1
		aik: V‰hint‰‰n 18-vuotiaiden henkilˆiden lukum‰‰r‰ poisluettuna v‰hint‰‰n 18-vuotiaat lapset
		aiklapsia: V‰hint‰‰n 18-vuotiaiden lasten lukum‰‰r‰
		lapsia17: 17-vuotiaiden lasten lukum‰‰r‰
		lapsia10_16: 10-16-vuotiaiden lasten lukum‰‰r‰
		lapsiaalle10: Alle 10-vuotiaiden lasten lukum‰‰r‰
		lapsilisat: Perheen saamat lapsilis‰t yhteens‰, e/kk
		tyotulo: Perheen jokaisen j‰senen tyˆtulot nettona ilman tulonhankkimiskuluja
				 ker‰ttyn‰ vektoriin (ARRAY), e/kk
		muuttulot: Perheen yhteenlasketut muut nettotulot, e/kk
		asmenot: Perheen yhteenlasketut asumismenot, e/kk
		harkmenot: Perheen yhteenlasketut harkinnanvaraiset menot, e/kk
		tulonhank: Perheen jokaisen j‰senen tulonhankkimiskulut ker‰ttyn‰ vektoriin (ARRAY), e/kk */ 

%MACRO ToimTukiKS(tulos, mvuosi, mkuuk, minf, kryhma, ydinp, aik, aiklapsia, lapsia17,
lapsia10_16, lapsiaalle10, lapsilisat, tyotulo, muuttulot, asmenot, harkmenot, tulonhank) /
DES = "TOIMTUKI: Toimeentulotuki kuukaudessa";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_PARAM, PARAM.&PTOIMTUKI); 
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_MUUNNOS, &minf);

	*Kuntaryhman valinta.;
	IF &kryhma = 1 THEN DO;
		perusmaara = &YksinKR1;
	END;
	ELSE DO;
		IF &kryhma = 2 THEN DO;
			perusmaara = &YksinKR2;
		END;
	END;

	*Lasketaan yksinasuvan perusosan suuruus.;
	perus = &YksPros * perusmaara;
	*Lasketaan yksinhuoltajan perusosan suuruus.;
	perusyh = (1 + &Yksinhuoltaja) * perus;

	%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	*Lasketaan aluksi toimeentulotuen suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.
	Lasketaan erikseen ennen vuoden 1998 maaliskuuta olevassa tilanteessa ja sen j‰lkeen, sill‰ 
	- Ennen vuoden 1998 maaliskuuta 17-vuotiaat on katsottu toimeentulotuessa aikuisiksi.
	- Maaliskuusta 1998 l‰htien yksin aikuisten lasten kanssa asuva katsotaan toimeentulotuessa yksinasuvaksi.;

	IF kuuid < MDY(3, 1, 1998) THEN DO;

		*Lasketaan normin suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.;
		IF &aik = 1 AND SUM(&lapsia10_16, &lapsiaalle10) > 0 THEN normi = perusyh + SUM(&aiklapsia, &lapsia17) * &AikLapsi18Plus * perus;
		ELSE IF &aik = 1 AND &ydinp = 1 AND SUM(&aiklapsia, &lapsia17) = 0 THEN normi = perus;
		ELSE normi = &aik * &Aik18Plus * perus + SUM(&aiklapsia, &lapsia17) * &AikLapsi18Plus * perus;

	END;
	ELSE DO;
		
		*Lasketaan normin suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.;
		IF &aik = 1 AND SUM(&lapsia17, &lapsia10_16, &lapsiaalle10) > 0 THEN normi = perusyh + &aiklapsia * &AikLapsi18Plus * perus;
		ELSE IF &aik = 1 AND &ydinp = 1 THEN normi = perus + &aiklapsia * &AikLapsi18Plus * perus;
		ELSE normi = &aik * &Aik18Plus * perus + &aiklapsia * &AikLapsi18Plus * perus;
		
	END;

	*Otetaan huomioon alaik‰iset lapset.;
	%LapsKerrS(lapskerr, &mvuosi, &mkuuk, &lapsia17, &lapsia10_16, &lapsiaalle10);
	normi = SUM(normi, lapskerr * perus);
		
	*Toimeentulotuessa huomioon otettava tyˆtulo.;
	*Vuodesta 2015 l‰htien tyˆtulon suojaosa on henkilˆkohtainen.;
	IF &mvuosi < 2015 THEN DO;
		tyotulosum = SUM(OF &tyotulo{*});
		tulonhanksum = SUM(OF &tulonhank{*});
		vapaatulo = &VapaaOs * SUM(tyotulosum, tulonhanksum);
		IF vapaatulo > &VapaaOsRaja THEN vapaatulo = &VapaaOsRaja;
		tyotulohuomioon = SUM(tyotulosum, -vapaatulo);
	END;
	ELSE DO;
		tyotulohuomioon = 0;
		DO i = 1 TO DIM(&tyotulo);

			%LuoKuuID(kuuid, &mvuosi, &mkuuk);
			IF kuuid <= MDY(5, 1, 2018) THEN DO;	
				vapaatulo = &VapaaOs * SUM(&tyotulo{i}, &tulonhank{i});
			END;
			ELSE DO;
				vapaatulo = SUM(&tyotulo{i}, &tulonhank{i});
			END;	
			IF vapaatulo > &VapaaOsRaja THEN vapaatulo = &VapaaOsRaja;
			tyotulohuomioon = SUM(tyotulohuomioon, &tyotulo{i}, -vapaatulo);
		END;
	END;
	
	*Toimeentulotuessa huomioon otettavat tulot yhteens‰.
	Vuodesta 1994 l‰htien myˆs lapsilis‰t on otettu tulona huomioon.;
	IF &mvuosi < 1994 THEN tulothuomioon = SUM(tyotulohuomioon, &muuttulot);
	ELSE tulothuomioon = SUM(tyotulohuomioon, &muuttulot, &lapsilisat);

	*Toimeentulotuessa huomioon otettavat asumismenot.;
	asmenothuomioon = (SUM(1, -&AsOmaVast)) * &asmenot;

	*Tulot - menot.;
	netto = SUM(tulothuomioon, -asmenothuomioon, -&harkmenot);

	*Toimeentulotuki yhteens‰.;
	IF (netto >= normi) THEN tuki = 0;
	ELSE tuki = SUM(normi, -netto);

	&tulos = tuki;

	DROP perusmaara perus perusyh kuuid i
		 normi lapskerr tyotulosum tulonhanksum vapaatulo
		 tyotulohuomioon tulothuomioon asmenothuomioon netto tuki;

%MEND ToimTukiKS;


/* 3. Toimeentulotuki vuosikeskiarvona */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, toimeentulotuki vuosikeskiarvona, e/kk
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
		kryhma: Toimeentulotuen kuntaryhm‰
		ydinp: Onko kyseess‰ ydinperhe, 0/1
		aik: V‰hint‰‰n 18-vuotiaiden henkilˆiden lukum‰‰r‰ poisluettuna v‰hint‰‰n 18-vuotiaat lapset
		aiklapsia: V‰hint‰‰n 18-vuotiaiden lasten lukum‰‰r‰
		lapsia17: 17-vuotiaiden lasten lukum‰‰r‰
		lapsia10_16: 10-16-vuotiaiden lasten lukum‰‰r‰
		lapsiaalle10: Alle 10-vuotiaiden lasten lukum‰‰r‰
		lapsilisat: Perheen saamat lapsilis‰t yhteens‰, e/kk
		tyotulo: Perheen jokaisen j‰senen tyˆtulot nettona ilman tulonhankkimiskuluja
				 ker‰ttyn‰ vektoriin (ARRAY), e/kk
		muuttulot: Perheen yhteenlasketut muut nettotulot, e/kk
		asmenot: Perheen yhteenlasketut asumismenot, e/kk
		harkmenot: Perheen yhteenlasketut harkinnanvaraiset menot, e/kk
		tulonhank: Perheen jokaisen j‰senen tulonhankkimiskulut ker‰ttyn‰ vektoriin (ARRAY), e/kk */ 

%MACRO ToimTukiVS(tulos, mvuosi, minf, kryhma, ydinp, aik, aiklapsia, lapsia17,
lapsia10_16, lapsiaalle10, lapsilisat, tyotulo, muuttulot, asmenot, harkmenot, tulonhank) /
DES = "TOIMTUKI: Toimeentulotuki vuosikeskiarvona";

	ttvuosi = 0;

	%DO kuuk = 1 %TO 12;
		%ToimTukiKS(ttkk, &mvuosi, &kuuk, &minf, &kryhma, &ydinp, &aik, &aiklapsia, &lapsia17,
		&lapsia10_16, &lapsiaalle10, &lapsilisat, &tyotulo, &muuttulot, &asmenot, &harkmenot, &tulonhank);
		ttvuosi = SUM(ttvuosi, ttkk);
	%END;

	ttvuosi = ttvuosi / 12;

	&tulos = ttvuosi;

	DROP ttvuosi ttkk;

%MEND ToimTukiVS;