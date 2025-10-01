/**************************************************
* Kuvaus: Toimeentulotuen lainsäädäntöä makroina  *
**************************************************/

/* Tiedosto sisältää seuraavat makrot:

1. LapsKerrS = Alaikäisten lasten osuus desimaalilukuna toimeentulotuen peruosasta
2. ToimTukiKS = Toimeentulotuki kuukaudessa
3. ToimTukiVS = Toimeentulotuki vuosikeskiarvona
4. AsumMenoRajat = Asumismenojen kuntakohtaisten rajojen soveltaminen


/* 1. Alaikäisten lasten osuus desimaalilukuna toimeentulotuen perusosasta */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, alaikäisten lasten osuus desimaalilukuna toimeentulotuen perusosasta
		mvuosi: Vuosi, jonka lainsäädäntöä käytetään
		mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
		lapsia17: 17-vuotiaiden lasten lukumäärä
		lapsia10_16: 10-16-vuotiaiden lasten lukumäärä
		lapsiaalle10: Alle 10-vuotiaiden lasten lukumäärä */ 
	
%MACRO LapsKerrS(tulos, mvuosi, mkuuk, lapsia17, lapsia10_16, lapsiaalle10)/
DES = "TOIMTUKI: Alaikäisten lasten osuus desimaalilukuna toimeentulotuen perusosasta";

	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_PARAM, PARAM.&PTOIMTUKI); 

	*Lasketaan aluksi kerroin, kun lasten lukumäärään liittyviä vähennyksiä ei oteta huomioon.;
	%LuoKuuID(kuuid, &mvuosi, &mkuuk);

	*Vuoden 1998 maaliskuusta lähtien myös 17-vuotiaat on katsottu toimeentulotuessa lapsiksi.;
	IF kuuid >= MDY(3, 1, 1998) THEN DO;
		lapsiayht = SUM(&lapsia17, &lapsia10_16, &lapsiaalle10);
		kerrennenvah = SUM(&lapsia17 * &Lapsi17, &lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
	END;
	ELSE DO;
		lapsiayht = SUM(&lapsia10_16, &lapsiaalle10);
		kerrennenvah = SUM(&lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
	END;
	kerr = kerrennenvah;

	*Lasten lukumäärään liittyvät vähennykset huomioon.;
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
		mvuosi: Vuosi, jonka lainsäädäntöä käytetään
		mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi 
		kryhma: Toimeentulotuen kuntaryhmä
		ydinp: Onko kyseessä ydinperhe, 0/1
		aik: Vähintään 18-vuotiaiden henkilöiden lukumäärä poisluettuna vähintään 18-vuotiaat lapset
		aiklapsia: Vähintään 18-vuotiaiden lasten lukumäärä
		lapsia17: 17-vuotiaiden lasten lukumäärä
		lapsia10_16: 10-16-vuotiaiden lasten lukumäärä
		lapsiaalle10: Alle 10-vuotiaiden lasten lukumäärä
		lapsilisat: Perheen saamat lapsilisät yhteensä, e/kk
		tyotulo: Perheen jokaisen jäsenen työtulot nettona ilman tulonhankkimiskuluja
				 kerättynä vektoriin (ARRAY), e/kk
		muuttulot: Perheen yhteenlasketut muut nettotulot, e/kk
		asmenot: Perheen yhteenlasketut asumismenot, e/kk
		harkmenot: Perheen yhteenlasketut harkinnanvaraiset menot, e/kk
		tulonhank: Perheen jokaisen jäsenen tulonhankkimiskulut kerättynä vektoriin (ARRAY), e/kk */ 

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
	Lasketaan erikseen ennen vuoden 1998 maaliskuuta olevassa tilanteessa ja sen jälkeen, sillä 
	- Ennen vuoden 1998 maaliskuuta 17-vuotiaat on katsottu toimeentulotuessa aikuisiksi.
	- Maaliskuusta 1998 lähtien yksin aikuisten lasten kanssa asuva katsotaan toimeentulotuessa yksinasuvaksi.;

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

	*Otetaan huomioon alaikäiset lapset.;
	%LapsKerrS(lapskerr, &mvuosi, &mkuuk, &lapsia17, &lapsia10_16, &lapsiaalle10);
	normi = SUM(normi, lapskerr * perus);
		
	*Toimeentulotuessa huomioon otettava työtulo.;
	*Vuodesta 2015 lähtien työtulon suojaosa on henkilökohtainen.;
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
	
	*Toimeentulotuessa huomioon otettavat tulot yhteensä.
	Vuodesta 1994 lähtien myös lapsilisät on otettu tulona huomioon.;
	IF &mvuosi < 1994 THEN tulothuomioon = SUM(tyotulohuomioon, &muuttulot);
	ELSE tulothuomioon = SUM(tyotulohuomioon, &muuttulot, &lapsilisat);

	*Toimeentulotuessa huomioon otettavat asumismenot.;
	asmenothuomioon = (SUM(1, -&AsOmaVast)) * &asmenot;

	*Tulot - menot.;
	netto = SUM(tulothuomioon, -asmenothuomioon, -&harkmenot);

	*Toimeentulotuki yhteensä.;
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
		mvuosi: Vuosi, jonka lainsäädäntöä käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		kryhma: Toimeentulotuen kuntaryhmä
		ydinp: Onko kyseessä ydinperhe, 0/1
		aik: Vähintään 18-vuotiaiden henkilöiden lukumäärä poisluettuna vähintään 18-vuotiaat lapset
		aiklapsia: Vähintään 18-vuotiaiden lasten lukumäärä
		lapsia17: 17-vuotiaiden lasten lukumäärä
		lapsia10_16: 10-16-vuotiaiden lasten lukumäärä
		lapsiaalle10: Alle 10-vuotiaiden lasten lukumäärä
		lapsilisat: Perheen saamat lapsilisät yhteensä, e/kk
		tyotulo: Perheen jokaisen jäsenen työtulot nettona ilman tulonhankkimiskuluja
				 kerättynä vektoriin (ARRAY), e/kk
		muuttulot: Perheen yhteenlasketut muut nettotulot, e/kk
		asmenot: Perheen yhteenlasketut asumismenot, e/kk
		harkmenot: Perheen yhteenlasketut harkinnanvaraiset menot, e/kk
		tulonhank: Perheen jokaisen jäsenen tulonhankkimiskulut kerättynä vektoriin (ARRAY), e/kk */ 

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




/* 4. Asumismenojen kuntakohtaisten rajojen soveltaminen (jos ASUMKUSTMAKS = 1) */

/* Makron parametrit:
		tulos: Makron tulosmuuttuja, toimeentulotuki vuosikeskiarvona, e/kk
		mvuosi: Vuosi, jonka lainsäädäntöä käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi

Huom. Asummenorajat-taulujen asumisnormien euromääriä ei deflatoida ja tulevien vuosien Asummenorajat-taulujen asumisnormien euromäärät ovat viimeisimmän lainsäädäntövuoden tasossa.
 */ 

%MACRO AsumMenoRajat(mvuosi, mkuuk, minf) /
DES = "ASUMMENOMAKS: Asumismenojen kuntakohtaisten rajojen soveltaminen";

*Noudetaan asumisnormit;
	%HaeParam&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_PARAM, PARAM.&PTOIMTUKI);
	%ParamInf&TYYPPI(&mvuosi, &mkuuk, &TOIMTUKI_MUUNNOS, &minf);

	proc sql undo_policy=none;
	create table TEMP.TEMP_TOIMTUKI_KOTI1 as
	select a.*, 
		case
			when a.jasenia=1 then (b.yksi_henkilo + &HuomVesi * jasenia)
			when a.jasenia=2 then (b.kaksi_henkiloa + &HuomVesi * jasenia)
			when a.jasenia=3 then (b.kolme_henkiloa + &HuomVesi * jasenia)
			when a.jasenia=4 then (b.nelja_henkiloa + &HuomVesi * jasenia)
			when a.jasenia>4 then (b.nelja_henkiloa + (b.lisa_henkilo * (a.jasenia-4)) + (&HuomVesi * a.jasenia))
		end as ASUMNORMIT
	from TEMP.TEMP_TOIMTUKI_KOTI1 a
	left join PARAM.asummenorajat_&mvuosi. b on a.kuntakoodi=b.koodi 
	; 
	quit;

	/* Soveltaminen vuosina 2022-2023*/
	%IF &LVUOSI <= 2023 %THEN %DO;

		data TEMP.TEMP_TOIMTUKI_KOTI1; 
		set TEMP.TEMP_TOIMTUKI_KOTI1;
		IF 
			/*Poikkeuksena lapsiperheet*/
			elivtu not in (20,40,50,60,70,82,84)

			/*Kela on soveltanut asumisnormin soveltamisen ehdossa 5 %:n joustoa*/
			AND ASUMISKULUT_KKS > 1.05 * ASUMNORMIT

			/*Kelan arvion mukaan keskimääräinen määräaika kohtuullisen asunnon hankkimiseksi on ollut noin 6 kuukautta.
			  Vuositasolla toimeentulotuen saajien asumiskustannukset sisällytetään toteutuneiden mukaisina 6 kuukauden ajalta
			  ja asumisnormin mukaisina kuuden kuukauden ajalta*/
			THEN ASUMISKULUT_KKS = MIN(ASUMISKULUT_KKS, SUM((1/2) * ASUMISKULUT_KKS,(1/2) * ASUMNORMIT));

		run;
	%END;

	/* Soveltaminen vuoden 2024 alusta lähtien*/
	%ELSE %IF &LVUOSI >= 2024 %THEN %DO;

		data TEMP.TEMP_TOIMTUKI_KOTI1; 
		set TEMP.TEMP_TOIMTUKI_KOTI1;
		IF 
			/*Poikkeuksena lapsiperheet*/
			elivtu not in (20,40,50,60,70,82,84)

			/*Kela ei sovella enää 5 %:n joustoa*/
			AND ASUMISKULUT_KKS > ASUMNORMIT

			/*Vuodesta 2024 lähtien lakiin on kirjattu toimeentulotuen asumiskustannusten osalta, että määräaika
			  asumisnormien soveltamiseen on 3 kuukautta */			
			THEN ASUMISKULUT_KKS = MIN(ASUMISKULUT_KKS, SUM((&AsumnormiSovAika/12)*ASUMISKULUT_KKS,(SUM(12,-&AsumnormiSovAika)/12)*ASUMNORMIT));
		run;
	%END;

%MEND AsumMenoRajat;