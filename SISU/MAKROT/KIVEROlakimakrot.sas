/***********************************************************************
* Kuvaus: Kiinteist�veron lains��d�nt�� makroina 					   *
***********************************************************************/ 


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2.  PtVerotusArvoS	= Pientalon verotusarvo
3.  VapVerotusArvoS	= Vapaa-ajan asunnon verotusarvo
4.  KiVeroPtS		= Pientalon kiinteist�vero
5.  KiVeroVapS		= Vapaa-ajan asunnon kiinteist�vero
6.  KiMinimi		= Kiinteist�veron pienimm�n m��r�tt�v�n veron huomioon ottaminen
7.	KiVeroMaaS		= Maapohjan kiinteist�vero (2024-)
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
	valmiusaste:	Keskener�isen rakennuksen valmiusaste;

%MACRO PtVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, valmiusaste)/ 
DES = 'KIVERO: Pientalon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 1 THEN DO;

	/* Rakennuksen pinta-alasta erotetaan kellarin pinta-ala */

	asuinpa = &rakennuspa - &kellaripa;
	IF &rakennuspa LT &kellaripa THEN asuinpa = &rakennuspa;

	/* Ensimm�iseksi lasketaan pientalon perusarvo */

	IF &kantarakenne = 1 AND &valmvuosi LT 1960 THEN ptperarvo = &PtPuuVanh;
	ELSE IF &kantarakenne = 1 AND (1960 LE &valmvuosi LT 1970) THEN ptperarvo = &PtPuuUusi;
	ELSE ptperarvo = &PtPerusArvo;

		/* Silloin kun valmistumisvuosi puuttuu, perusarvoksi annetaan korkein perusarvo */
	IF &valmvuosi = 0 THEN ptperarvo = &PtPerusArvo;

	/* Toiseksi lasketaan vesijohdon/viem�rin, keskusl�mmityksen ja s�hk�n 
	   puuttumisesta ja rakennuksen koosta teht�v�t perusarvon v�hennykset */

	IF &vesik = 0 THEN vahvesi = &PtEiVesi;
	IF &vesik = 1 THEN vahvesi = 0;

	IF &lammitysk GT 1 THEN vahkesk = &PtEiKesk;
	IF &lammitysk = 1 THEN vahkesk = 0;

	IF &sahkok = 0 THEN vahsahko = &PtEiSahko;
	IF &sahkok = 1 THEN vahsahko = 0;

	IF &PtNelioRaja1 LT &rakennuspa LE &PtNelioRaja2 THEN DO;
	vahpapala = (&rakennuspa - &PtNelioRaja1);
	vahpap = vahpapala * &PtVahPieni;
	END;

	IF &rakennuspa GT &PtNelioRaja2 THEN vahpas = &PtVahSuuri;

	/* Kolmanneksi lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta ed. v�hennykset
	ja lis�t��n j�lleenhankinta-arvoon viimeistelem�tt�m�n kellarin arvo*/

	vahsum = SUM(vahvesi, vahkesk, vahsahko, vahpap, vahpas);

	pthankarvoala = SUM(ptperarvo, -vahsum);

	kelparvo = &kellaripa * &KellArvo;

	pthankarvo = pthankarvoala * asuinpa + kelparvo;

	/* Nelj�nneksi lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
	/* Lasketaan rakennuksen korjattu ik� */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = max((&mvuosi - korjvuosi + 1), 0);
	IF korjvuosi = 0 THEN rakika = 0;

	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN ikavahpt = &IkaAlePuu / 100 * rakika;
	
	IF &kantarakenne = 2 THEN ikavahpt = &IkaAleKivi / 100 * rakika;
	
	IF ikavahpt GE (1 - &IkaVahRaja) THEN ikavahpt2 = &IkaVahRaja;
	IF ikavahpt LT (1 - &IkaVahRaja) THEN ikavahpt2 = 1 - ikavahpt;

	/* Keskener�isen rakennuksen valmiusaste */ 

	IF korjvuosi GT &mvuosi THEN valmaste = &valmiusaste;

	/* Lopuksi lasketaan verotusarvo */

	IF korjvuosi GT &mvuosi THEN temp = (valmaste * pthankarvo);
	IF &jhvalarvokoodi > 1 then temp = valopullinen;
	ELSE temp = pthankarvo * ikavahpt2;

END;

&tulos = temp;

DROP asuinpa ptperarvo vahvesi vahkesk vahsahko vahpapala vahpap vahpas vahsum pthankarvoala kelparvo pthankarvo 
korjvuosi rakika ikavahpt ikavahpt2 valmaste temp;
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
	valmiusaste:	Keskener�isen rakennuksen valmiusaste;

%MACRO VapVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, kuistipa, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi, valmiusaste)/  
DES = 'KIVERO: Vapaa-ajan asunnon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 7 THEN DO;

	/* Ensimm�iseksi lasketaan vapaa-ajan asunnon perusarvo */

	vapperarvo = &VapPerusArvo * &rakennuspa;

	/*Toiseksi lasketaan vapaa-ajan asunnon lis�arvo talviasuttavuudesta, kuistista, s�hk�st�, viem�rist�, 
	  vesijohdosta, WC:st� ja saunasta sek� rakennuksen koosta teht�v�t v�hennykset */

	IF (&VapNelioRaja1 LT &rakennuspa LE &VapNelioRaja2) THEN DO;
		vahvraja = &rakennuspa - &VapNelioRaja1;
		vahvpap = vahvraja * &VapVahPieni * &rakennuspa;
	END;

	IF &rakennuspa GT &VapNelioRaja2 THEN vahvpas = &rakennuspa * &VapVahSuuri;

	IF &talviask = 1 THEN listalvi = &rakennuspa * &VapLisTalvi;
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

	/* Kolmanneksi lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta ed. lis�ykset ja v�hennykset */

	lissum = SUM(listalvi, lissahko, lisviem, lisvesi, liswc, lissauna, liskuisti);
	vaphankarvo = SUM(vapperarvo, -vahvpap, -vahvpas, lissum);

	/* Nelj�nneksi lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
	/* Lasketaan rakennuksen korjattu ik� */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = max((&mvuosi - korjvuosi + 1), 0);
	IF korjvuosi = 0 THEN rakika = 0;

	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN DO;
		ikavahvap = (&IkaAlePuu / 100) * rakika;
	END;

	IF &kantarakenne = 2 THEN DO;
		ikavahvap = (&IkaAleKivi / 100) * rakika;
	END;

	IF ikavahvap GE (1 - &IkaVahRaja) THEN ikavahvap2 = &IkaVahRaja;
	IF ikavahvap LT (1 - &IkaVahRaja) THEN ikavahvap2 = (1 - ikavahvap);

	/* Keskener�isen rakennuksen valmiusaste */ 

	IF korjvuosi GT &mvuosi THEN valmaste = &valmiusaste;

	/* Lopuksi lasketaan verotusarvo */

	IF korjvuosi GT &mvuosi THEN temp = (valmaste * vaphankarvo);
	IF &jhvalarvokoodi > 1 then temp = valopullinen;
	ELSE temp = vaphankarvo * ikavahvap2;

END;

ELSE temp = 0;

&tulos = temp;

DROP vapperarvo vahvraja vahvpap vahvpas listalvi lissahko lisviem lisvesi liswc lissauna lissum vaphankarvo 
korjvuosi rakika ikavahvap ikavahvap2 valmaste temp liskuisti;
%MEND VapVerotusArvoS;


/* 4. Kiinteist�vero pientalosta */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero pientalosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelem�tt�m�n kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	lammitysk:		L�mmityskoodi (1=keskusl�mmitys, 2=ei keskusl�mmityst�, 3=s�hk�l�mmitys)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti;

%MACRO KiVeroPtS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, veropros, valmiusaste)/
DES = 'KIVERO: Kiinteist�vero pientalosta';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

%PtVerotusArvoS(ptvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&kellaripa, &vesik, &lammitysk, &sahkok, &jhvalarvokoodi, &valmiusaste);

IF &raktyyppi = 1 THEN DO;

	temp = ptvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp ptvarvo;
%MEND KiVeroPtS;


/* 5. Vapaa-ajan asunnon kiinteist�vero */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero vapaa-ajan asunnosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Laskentavuosi. Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
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
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti;

%MACRO KiVeroVapS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, talviask, kuistipa, sahkok, 
viemarik, vesik, wck, saunak, jhvalarvokoodi, veropros, valmiusaste)/ 
DES = 'KIVERO: Vapaa-ajan asunnon kiinteist�vero';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

%VapVerotusArvoS(vapvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&talviask, &kuistipa, &sahkok, &viemarik, &vesik, &wck, &saunak, &jhvalarvokoodi, &valmiusaste);

IF &raktyyppi = 7 THEN DO;

	temp = vapvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp vapvarvo; 
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

IF &kivero < &PiMinimi THEN DO; 
	temp = 0; 
END; 

ELSE temp = &kivero; 

&tulos = temp; 

DROP temp; 
%MEND KiMinimi; 

/* 7. Maapohjan kiinteist�vero (2024-) */ 

*Makron parametrit:
	tulos: 			Makron tulosmuuttuja, Maapohjan kiinteist�vero.
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n 
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	verotusarvo: 	Maapohjan verotusarvo
	kiintpros: 		Aineistossa oleva kiinteist�n kuntaveroprosentti
	kuntanro: 		Kiinteist�n kuntakoodi
	MaapohjaAlaraja Maapohjan kiinteist�veroprosentin alaraja (2024-);
	
%MACRO KiVeroMaaS(tulos, mvuosi, minf, verotusarvo, kiintpros, kuntanro)/
DES = 'KiVeroMaaS: Maapohjan kiinteist�vero (2024-)'; 

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf); 

temp = 0;

/* Ahvenanmaan kunnille ei sovelleta maapohjan kiinteist�veroprosentin alarajaa */
IF &kuntanro IN (035, 043, 060, 062, 065, 076, 170, 295, 318, 417, 438, 478, 736, 766, 771, 941) THEN DO;
	temp = &verotusarvo * (&kiintpros / 100);
END;
ELSE DO;
	temp = &verotusarvo * (MAX(&kiintpros, &MaapohjaAlaraja) / 100);
END;

&tulos = temp; 

DROP temp; 
%MEND KiVeroMaaS;