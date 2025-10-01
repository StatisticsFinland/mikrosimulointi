/***********************************************************************
* Kuvaus: Kiinteist�veron lains��d�nt�� makroina 					   *
***********************************************************************/ 


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2.  PtVerotusArvoS		= Pientalon verotusarvo
3.  VapVerotusArvoS		= Vapaa-ajan asunnon verotusarvo
4.  KiVeroPtS			= Pientalon kiinteist�vero
5.  KiVeroVapS			= Vapaa-ajan asunnon kiinteist�vero
6.  KiMinimi			= Kiinteist�veron pienimm�n m��r�tt�v�n veron huomioon ottaminen
7.	KiVeroMaaS			= Maapohjan kiinteist�vero (2024-)
8.	TalVerotusArvoS 	= Talousrakennuksen verotusarvo
9.	KiVeroTalS			= Talousrakennuksen kiinteist�vero
*/


/* 2. Pientalon verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Pientalon verotusarvo
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (1=pientalo)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelem�tt�m�n kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	lammitysk:		L�mmityskoodi (1=keskusl�mmitys, 2=ei keskusl�mmityst�, 3=s�hk�l�mmitys)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	valmiusaste:	Keskener�isen rakennuksen valmiusaste
	valopullinen:	Datassa oleva rakennuksen verotusarvo;

%MACRO PtVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, valmiusaste, valopullinen)/ 
DES = 'KIVERO: Pientalon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 1 THEN DO;

	/* Rakennuksen pinta-alasta erotetaan kellarin pinta-ala, paitsi jos kellarin pinta-ala on suurempi */
	IF &kellaripa > &rakennuspa THEN asuinpa = &rakennuspa;
	ELSE asuinpa = SUM(&rakennuspa, -&kellaripa);

	/* Ensimm�iseksi lasketaan pientalon perusarvo: Eri arvo jos kyseess� puutalo, joka on valmistunut ennen 1960 tai vuosien 1960-1969 v�lill�. */
	IF &kantarakenne = 1 AND &valmvuosi < 1970 THEN DO;
		IF &valmvuosi < 1960 THEN ptperarvo = &PtPuuVanh;
		ELSE ptperarvo = &PtPuuUusi;
	END;
	ELSE ptperarvo = &PtPerusArvo;

	/* Toiseksi lasketaan vesijohdon/viem�rin, keskusl�mmityksen ja s�hk�n puuttumisesta teht�v�t perusarvon v�hennykset */
	IF &vesik = 0 THEN vahvesi = &PtEiVesi;
	IF &vesik = 1 THEN vahvesi = 0;

	IF &lammitysk > 1 THEN vahkesk = &PtEiKesk;
	IF &lammitysk = 1 THEN vahkesk = 0;

	IF &sahkok = 0 THEN vahsahko = &PtEiSahko;
	IF &sahkok = 1 THEN vahsahko = 0;

	/* Lasketaan rakennuksen pinta-alasta riippuvat v�hennykset */
	/* Jos rakennuksen pinta-ala = [&PtNelioRaja1, &PtNelioRaja2], niin v�hennyksen m��r� on riippuvainen pinta-alasta ja v�hennyksen eurom��r�st� per neli�: */
	IF &PtNelioRaja1 < &rakennuspa <= &PtNelioRaja2 THEN vahpa = SUM(&rakennuspa, -&PtNelioRaja1) * &PtVahPieni;
	/* Jos taas rakennuksen pinta-ala > &PtNelioRaja2, niin v�hennyksen m��r� on kiinte� eurom��r� */
	ELSE IF &rakennuspa > &PtNelioRaja2 THEN vahpa = &PtVahSuuri;

	/* Lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta v�hennykset	ja lis�t��n j�lleenhankinta-arvoon viimeistelem�tt�m�n kellarin arvo*/
	pthankarvo = asuinpa * SUM(ptperarvo, -vahvesi, -vahkesk, -vahsahko, -vahpa) + &kellaripa * &KellArvo;

	/* Lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
	/* Lasketaan aluksi rakennuksen korjattu ik�, oltava > 0 */
	IF &ikavuosi > &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE korjvuosi = &valmvuosi; 

	IF korjvuosi = 0 THEN rakika = 0;
	ELSE rakika = max((&mvuosi - korjvuosi + 1), 0);

	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */
	IF &kantarakenne = 1 THEN ikavahpt = &IkaAlePuu / 100 * rakika;
	IF &kantarakenne = 2 THEN ikavahpt = &IkaAleKivi / 100 * rakika;
	
	/* Huomioidaan ik�v�hennyksen alaraja. ikavahpt2 voi saada arvoja v�lilt�: [&IkaVahRaja, 1] */
	ikavahpt2 = MAX(&IkaVahRaja, SUM(1, -ikavahpt));

	/* Lopuksi lasketaan verotusarvo */
	/* Jos rakennusta korjataan, niin arvo m��ritet��n valmiusasteen avulla	*/
	IF korjvuosi > &mvuosi THEN temp = (&valmiusaste/100 * pthankarvo);
	/* Jos j�lleenhankinta-arvon koodi > 1, k�ytet��n datan verotusarvoa */
	ELSE IF &jhvalarvokoodi > 1 then temp = &valopullinen;
	/* Muissa tapauksissa arvo m��ritet��n huomioimalla ik�v�hennys */
	ELSE temp = pthankarvo * ikavahpt2;

END;

&tulos = temp;

DROP asuinpa ptperarvo vahvesi vahkesk vahsahko vahpa pthankarvo korjvuosi rakika ikavahpt ikavahpt2 temp;
%MEND PtVerotusArvoS;


/* 3. Vapaa-ajan asunnon verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Vapaa-ajan asunnon verotusarvo
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (7=vapaa-ajan asunto)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	talviask:		Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyll�)
	kuistipa:		Vapaa-ajan asunnon kuistin pinta-ala, m2
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	viemarik:		Viem�ritieto (0=ei, 1=kyll�)
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	wck:			Vapaa-ajan asunnon wc-tieto (0 = ei, 1=kyll�)
	saunak:			Vapaa-ajan asunnon saunatieto (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	valmiusaste:	Keskener�isen rakennuksen valmiusaste
	valopullinen:	Datassa oleva rakennuksen verotusarvo;

%MACRO VapVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, kuistipa, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi, valmiusaste, valopullinen)/  
DES = 'KIVERO: Vapaa-ajan asunnon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 7 THEN DO;

	/* Lasketaan vapaa-ajan asunnon perusarvo */
	vapperarvo = &VapPerusArvo;

	/* Lasketaan rakennuksen pinta-alasta riippuvat v�hennykset*/
	/* Jos rakennuksen pinta-ala = [&VapNelioRaja1, &VapNelioRaja2], niin v�hennyksen m��r� on riippuvainen pinta-alasta ja v�hennyksen eurom��r�st� per neli�: */
	IF &VapNelioRaja1 < &rakennuspa <= &VapNelioRaja2 THEN vahpa = SUM(&rakennuspa, -&VapNelioRaja1) * &VapVahPieni;
	/* Jos taas rakennuksen pinta-ala > &VapNelioRaja2, niin v�hennyksen m��r� on kiinte� eurom��r� */
	ELSE IF &rakennuspa > &VapNelioRaja2 THEN vahpa = &VapVahSuuri;

	/*	Lasketaan vapaa-ajan asunnon lis�arvo talviasuttavuudesta, kuistista, s�hk�st�, viem�rist�, vesijohdosta, WC:st� ja saunasta*/
	IF &talviask = 1 THEN listalvi = &VapLisTalvi;
	ELSE listalvi = 0;

	IF &kuistipa > 0 THEN liskuisti = &kuistipa * &VapLisKuis;
	ELSE liskuisti = 0;
	
	IF &sahkok = 1 THEN lissahko = &VapLisSahko1 + (&rakennuspa * &VapLisSahko2);
	ELSE lissahko = 0;

	IF &viemarik = 1 THEN lisviem = &VapLisViem;
	ELSE lisviem = 0;

	IF &vesik = 1 THEN lisvesi = &VapLisVesi;
	ELSE lisvesi = 0;

	IF &wck = 1 THEN liswc = &VapLisWC;
	ELSE liswc = 0;

	IF &saunak = 1 THEN lissauna = &VapLisSauna;
	ELSE lissauna = 0;

	/* Lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta pinta-alaan sidottu v�hennys ja lis�t��n arvoon edell� lasketut lis�arvot */
	vaphankarvo = SUM(vapperarvo * &rakennuspa, -vahpa * &rakennuspa, listalvi * &rakennuspa, lissahko, lisviem, lisvesi, liswc, lissauna, liskuisti);

	/* Lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
	/* Lasketaan aluksi rakennuksen korjattu ik�, oltava > 0 */
	IF &ikavuosi > &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE korjvuosi = &valmvuosi; 

	IF korjvuosi = 0 THEN rakika = 0;
	ELSE rakika = max((&mvuosi - korjvuosi + 1), 0);

	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */
	IF &kantarakenne = 1 THEN ikavahvap = (&IkaAlePuu / 100) * rakika;
	IF &kantarakenne = 2 THEN ikavahvap = (&IkaAleKivi / 100) * rakika;

	/* Huomioidaan ik�v�hennyksen alaraja. ikavahvap2 voi saada arvoja v�lilt�: [&IkaVahRaja, 1] */
	ikavahvap2 = MAX(&IkaVahRaja, SUM(1, -ikavahvap));

	/* Lopuksi lasketaan verotusarvo */
	/* Jos rakennusta korjataan, niin arvo m��ritet��n valmiusasteen avulla	*/
	IF korjvuosi > &mvuosi THEN temp = (&valmiusaste/100 * vaphankarvo);
	/* Jos j�lleenhankinta-arvon koodi > 1, k�ytet��n datan verotusarvoa */
	ELSE IF &jhvalarvokoodi > 1 then temp = &valopullinen;
	/* Muissa tapauksissa arvo m��ritet��n huomioimalla ik�v�hennys */
	ELSE temp = vaphankarvo * ikavahvap2;

END;

ELSE temp = 0;

&tulos = temp;

DROP vapperarvo listalvi lissahko lisviem lisvesi liswc lissauna vaphankarvo korjvuosi rakika ikavahvap ikavahvap2 temp liskuisti;
%MEND VapVerotusArvoS;


/* 4. Kiinteist�vero pientalosta */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero pientalosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti
	ptvarvo:		Rakennuksen verotusarvo;

%MACRO KiVeroPtS(tulos, mvuosi, minf, raktyyppi, veropros, ptvarvo)/
DES = 'KIVERO: Kiinteist�vero pientalosta';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 1 THEN &tulos = &ptvarvo * (&veropros / 100);
ELSE &tulos = 0;

%MEND KiVeroPtS;


/* 5. Vapaa-ajan asunnon kiinteist�vero */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero vapaa-ajan asunnosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti
	vapvarvo:		Rakennuksen verotusarvo;

%MACRO KiVeroVapS(tulos, mvuosi, minf, raktyyppi, veropros, vapvarvo)/ 
DES = 'KIVERO: Vapaa-ajan asunnon kiinteist�vero';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 7 THEN &tulos = &vapvarvo * (&veropros / 100);
ELSE &tulos = 0;

%MEND KiVeroVapS;


/* 6. Kiinteist�veron pienimm�n m��r�tt�v�n veron huomioon ottaminen */ 

*Makron parametrit:
	tulos: 			Makron tulosmuuttuja, Kiinteist�vero josta on nollattu pienint� peritt�v�� m��r�� pienemm�t kiinteist�verot.
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n 
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	kivero: 		Kiinteist�vero ennen pienimm�n m��r�tt�v�n veron huomioon ottamista; 
	
%MACRO KiMinimi(tulos, mvuosi, minf, kivero)/
DES = 'KIVERO: Pienimm�n m��r�tt�v�n veron huomioon ottaminen'; 

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf); 

IF &kivero < &PiMinimi THEN &tulos = 0;
ELSE &tulos = &kivero; 

%MEND KiMinimi; 

/* 7. Maapohjan kiinteist�vero (2024-) */ 

*Makron parametrit:
	tulos: 				Makron tulosmuuttuja, Maapohjan kiinteist�vero.
	mvuosi: 			Vuosi, jonka lains��d�nt�� k�ytet��n 
	minf: 				Deflaattori eurom��r�isten parametrien kertomiseksi 
	verotusarvo: 		Maapohjan verotusarvo
	kiintpros: 			Aineistossa oleva kiinteist�n kuntaveroprosentti
	kuntanro: 			Kiinteist�n kuntakoodi
	MaapohjaAlaraja: 	Maapohjan kiinteist�veroprosentin alaraja (2024-);
	
%MACRO KiVeroMaaS(tulos, mvuosi, minf, verotusarvo, kiintpros, kuntanro)/
DES = 'KiVeroMaaS: Maapohjan kiinteist�vero (2024-)'; 

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf); 

/* Ahvenanmaan kunnille ei sovelleta maapohjan kiinteist�veroprosentin alarajaa */
IF &kuntanro IN (035, 043, 060, 062, 065, 076, 170, 295, 318, 417, 438, 478, 736, 766, 771, 941) THEN &tulos = &verotusarvo * (&kiintpros / 100);
/* Muille kunnille sovelletaan maapohjan kiinteist�veroprosentin alarajaa */
ELSE &tulos = &verotusarvo * (MAX(&kiintpros, &MaapohjaAlaraja) / 100);

%MEND KiVeroMaaS;

/* 8. Talousrakennuksen verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Vapaa-ajan asunnon verotusarvo
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (7=vapaa-ajan asunto)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	autokatos: 		Onko rakennus autokatos (0 = ei, 1 = kyll�)
	lampoeristys:	L�mp�eristys (0 = ei, 1 = kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	valmiusaste:	Keskener�isen rakennuksen valmiusaste
	valopullinen:	Datassa oleva rakennuksen verotusarvo;

%MACRO TalVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, autokatos, lampoeristys, jhvalarvokoodi, valmiusaste, valopullinen)/  
DES = 'KIVERO: Talousrakennuksen verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi in (8, 9) THEN DO;

	/* Lasketaan talousrakennuksen perusarvo */
	IF &lampoeristys = 1 THEN taperarvo = &TaPerusArvo;
	ELSE IF &lampoeristys = 0 THEN DO;
		IF &valmvuosi >= 1970 THEN taperarvo = &TaEiLampoArvo;
		ELSE taperarvo = &TaVanhaArvo;
	END;

	/* Lasketaan verotusarvo v�hent�m�ll� arvosta ik�alennukset */
	/* Lasketaan aluksi rakennuksen korjattu ik�, oltava > 0 */
	IF &ikavuosi > &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE korjvuosi = &valmvuosi; 

	IF korjvuosi = 0 THEN rakika = 0;
	ELSE rakika = max((&mvuosi - korjvuosi + 1), 0);
	
	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */
	IF &autokatos = 1 THEN ikavahtal = (&IkaAleAutokatos / 100) * rakika;
	ELSE DO;
		IF &kantarakenne = 1 THEN ikavahtal = (&IkaAlePuuTalous / 100) * rakika;
		ELSE IF &kantarakenne = 2 THEN ikavahtal = (&IkaAleKiviTalous / 100) * rakika;
	END;
	
	/* Huomioidaan ik�v�hennyksen alaraja. ikavahtal2 voi saada arvoja v�lilt�: [&IkaVahRajaTalous, 1] */
	ikavahtal2 = MAX(&IkaVahRajaTalous, SUM(1, -ikavahtal));

	/* Lopuksi lasketaan verotusarvo */
	/* Jos rakennusta korjataan, niin arvo m��ritet��n valmiusasteen avulla	*/
	IF korjvuosi > &mvuosi THEN temp = (&valmiusaste/100 * taperarvo * rakennuspa);
	/* Jos j�lleenhankinta-arvon koodi > 1, k�ytet��n datan verotusarvoa */
	ELSE IF &jhvalarvokoodi > 1 THEN temp = &valopullinen;
	/* Muissa tapauksissa arvo m��ritet��n huomioimalla ik�v�hennys */
	ELSE temp = ikavahtal2 * taperarvo * rakennuspa;

END;

ELSE temp = 0;

&tulos = temp;

DROP korjvuosi rakika ikavahtal ikavahtal2 temp taperarvo;

%MEND TalVerotusArvoS;

/* 9. Talousrakennuksen kiinteist�vero */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero vapaa-ajan asunnosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti
	talousrakarvo:	Rakennuksen verotusarvo;

%MACRO KiVeroTalS(tulos, mvuosi, minf, raktyyppi, veropros, talousrakarvo)/ 
DES = 'KIVERO: Talousrakennuksen kiinteist�vero';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi in (8, 9) THEN &tulos = &talousrakarvo * (&veropros / 100);
ELSE &tulos = 0;

%MEND KiVeroTalS;