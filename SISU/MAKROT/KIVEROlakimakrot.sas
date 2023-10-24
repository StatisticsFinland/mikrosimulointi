/***********************************************************************
* Kuvaus: Kiinteistöveron lainsäädäntöä makroina 					   *
* Viimeksi päivitetty: 16.3.2020	     		       			       *
***********************************************************************/ 


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2.  PtVerotusArvoS	= Pientalon verotusarvo
3.  VapVerotusArvoS	= Vapaa-ajan asunnon verotusarvo
4.  KiVeroPtS		= Pientalon kiinteistövero
5.  KiVeroVapS		= Vapaa-ajan asunnon kiinteistövero
6.  KiMinimi		= Kiinteistöveron pienimmän määrättävän veron huomioon ottaminen
*/


/* 2. Pientalon verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Pientalon verotusarvo
	mvuosi: 		Vuosi, jonka lainsäädäntöä käytetään
	minf: 			Deflaattori euromääräisten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (1=pientalo)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ikäalennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelemättömän kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyllä)
	lammitysk:		Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys)
	sahkok:			Sähkökoodi (0=ei, 1=kyllä)
	jhvalarvokoodi:	Jälleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyvästi);

%MACRO PtVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi)/ 
DES = 'KIVERO: Pientalon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 1 THEN DO;

	/* Rakennuksen pinta-alasta erotetaan kellarin pinta-ala */

	asuinpa = &rakennuspa - &kellaripa;
	IF &rakennuspa LT &kellaripa THEN asuinpa = &rakennuspa;

	/* Ensimmäiseksi lasketaan pientalon perusarvo */

	IF &kantarakenne = 1 AND &valmvuosi LT 1960 THEN ptperarvo = &PtPuuVanh;
	ELSE IF &kantarakenne = 1 AND (1960 LE &valmvuosi LT 1970) THEN ptperarvo = &PtPuuUusi;
	ELSE ptperarvo = &PtPerusArvo;

		/* Silloin kun valmistumisvuosi puuttuu, perusarvoksi annetaan korkein perusarvo */
	IF &valmvuosi = 0 THEN ptperarvo = &PtPerusArvo;

	/* Toiseksi lasketaan vesijohdon/viemärin, keskuslämmityksen ja sähkön 
	   puuttumisesta ja rakennuksen koosta tehtävät perusarvon vähennykset */

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

	/* Kolmanneksi lasketaan jälleenhankinta-arvo vähentämällä perusarvosta ed. vähennykset
	ja lisätään jälleenhankinta-arvoon viimeistelemättömän kellarin arvo*/

	vahsum = SUM(vahvesi, vahkesk, vahsahko, vahpap, vahpas);

	pthankarvoala = SUM(ptperarvo, -vahsum);

	kelparvo = &kellaripa * &KellArvo;

	pthankarvo = pthankarvoala * asuinpa + kelparvo;

	/* Neljänneksi lasketaan verotusarvo vähentämällä jälleenhankinta-arvosta ikäalennukset */
		/* Lasketaan rakennuksen korjattu ikä */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = (&mvuosi - korjvuosi + 1);
	IF korjvuosi = 0 THEN rakika = 0;

		/* Lasketaan ikävähennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN ikavahpt = &IkaAlePuu / 100 * rakika;
	
	IF &kantarakenne = 2 THEN ikavahpt = &IkaAleKivi / 100 * rakika;
	
	IF ikavahpt GE (1 - &IkaVahRaja) THEN ikavahpt2 = &IkaVahRaja;
	IF ikavahpt LT (1 - &IkaVahRaja) THEN ikavahpt2 = 1 - ikavahpt;

	/* Keskeneräisen rakennuksen valmiusastetta ei tiedetä. Vuonna 2010 keskeneräisten rakennusten valmiusaste oli keskimäärin 
	62 prosenttia, jota käytetään myös tässä laskennassa. */ 

	IF korjvuosi GT &mvuosi THEN valmaste = 0.62;

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
	mvuosi: 		Vuosi, jonka lainsäädäntöä käytetään
	minf: 			Deflaattori euromääräisten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (7=vapaa-ajan asunto)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ikäalennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	talviask:		Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyllä)
	sahkok:			Sähkökoodi (0=ei, 1=kyllä)
	viemarik:		Viemäritieto (0=ei, 1=kyllä)
	vesik:			Vesijohtotieto (0=ei, 1=kyllä)
	wck:			Vapaa-ajan asunnon wc-tieto (0 = ei, 1=kyllä)
	saunak:			Vapaa-ajan asunnon saunatieto (0=ei, 1=kyllä)
	jhvalarvokoodi:	Jälleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyvästi);

%MACRO VapVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi)/  
DES = 'KIVERO: Vapaa-ajan asunnon verotusarvo';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

IF &raktyyppi = 7 THEN DO;

	/* Ensimmäiseksi lasketaan vapaa-ajan asunnon perusarvo */

	vapperarvo = &VapPerusArvo * &rakennuspa;

	/*Toiseksi lasketaan vapaa-ajan asunnon lisäarvo talviasuttavuudesta, sähköstä, viemäristä, 
	  vesijohdosta, WC:stä ja saunasta sekä rakennuksen koosta tehtävät vähennykset */

	/* HUOM! EI VOIDA LASKEA LISÄARVOA KUISTISTA, KOSKA AINEISTOSSA EI OLE TARVITTAVAA TIETOA */

	IF (&VapNelioRaja1 LT &rakennuspa LE &VapNelioRaja2) THEN DO;
		vahvraja = &rakennuspa - &VapNelioRaja1;
		vahvpap = vahvraja * &VapVahPieni * &rakennuspa;
	END;

	IF &rakennuspa GT &VapNelioRaja2 THEN vahvpas = &rakennuspa * &VapVahSuuri;

	IF &talviask = 1 THEN listalvi = &rakennuspa * &VapLisTalvi;
	ELSE listalvi = 0;
	
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

	/* Kolmanneksi lasketaan jälleenhankinta-arvo vähentämällä perusarvosta ed. lisäykset ja vähennykset */

	lissum = SUM(listalvi, lissahko, lisviem, lisvesi, liswc, lissauna);
	vaphankarvo = SUM(vapperarvo, -vahvpap, -vahvpas, lissum);

	/* Neljänneksi lasketaan verotusarvo vähentämällä jälleenhankinta-arvosta ikäalennukset */
	/* Lasketaan rakennuksen korjattu ikä */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = (&mvuosi - korjvuosi + 1);
	IF korjvuosi = 0 THEN rakika = 0;

	/* Lasketaan ikävähennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN DO;
		ikavahvap = (&IkaAlePuu / 100) * rakika;
	END;

	IF &kantarakenne = 2 THEN DO;
		ikavahvap = (&IkaAleKivi / 100) * rakika;
	END;

	IF ikavahvap GE (1 - &IkaVahRaja) THEN ikavahvap2 = &IkaVahRaja;
	IF ikavahvap LT (1 - &IkaVahRaja) THEN ikavahvap2 = (1 - ikavahvap);

	/* UUSI KOODI! Keskeneräisen rakennuksen valmiusasteesta ei ole tietoa. Vuonna 2010 keskeneräisten rakennusten valmiusaste oli keskimäärin 
	56 prosenttia, jota käytetään tässä laskennassa. */ 

	IF korjvuosi GT &mvuosi THEN valmaste = 0.56;

	/* Lopuksi lasketaan verotusarvo */

	IF korjvuosi GT &mvuosi THEN temp = (valmaste * vaphankarvo);
	IF &jhvalarvokoodi > 1 then temp = valopullinen;
	ELSE temp = vaphankarvo * ikavahvap2;

END;

ELSE temp = 0;

&tulos = temp;

DROP vapperarvo vahvraja vahvpap vahvpas listalvi lissahko lisviem lisvesi liswc lissauna lissum vaphankarvo 
korjvuosi rakika ikavahvap ikavahvap2 valmaste temp;
%MEND VapVerotusArvoS;


/* 4. Kiinteistövero pientalosta */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteistövero pientalosta
	mvuosi: 		Vuosi, jonka lainsäädäntöä käytetään
	minf: 			Deflaattori euromääräisten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ikäalennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelemättömän kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyllä)
	lammitysk:		Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys)
	sahkok:			Sähkökoodi (0=ei, 1=kyllä)
	jhvalarvokoodi:	Jälleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyvästi)
	veropros:		Rakennukselle määrätty kiinteistöveroprosentti;

%MACRO KiVeroPtS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, veropros)/
DES = 'KIVERO: Kiinteistövero pientalosta';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

%PtVerotusArvoS(ptvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&kellaripa, &vesik, &lammitysk, &sahkok, &jhvalarvokoodi);

IF &raktyyppi = 1 THEN DO;

	temp = ptvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp ptvarvo;
%MEND KiVeroPtS;


/* 5. Vapaa-ajan asunnon kiinteistövero */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteistövero vapaa-ajan asunnosta
	mvuosi: 		Vuosi, jonka lainsäädäntöä käytetään
	minf: 			Deflaattori euromääräisten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Laskentavuosi. Rakentamisvuodesta poikkeava ikäalennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	talviask:		Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyllä)
	sahkok:			Sähkökoodi (0=ei, 1=kyllä)
	viemarik:		Viemäritieto (0=ei, 1=kyllä)
	vesik:			Vesijohtotieto (0=ei, 1=kyllä)
	wck:			Vapaa-ajan asunnon wc-tieto (0 = ei, 1=kyllä)
	saunak:			Vapaa-ajan asunnon saunatieto (0=ei, 1=kyllä)
	jhvalarvokoodi:	Jälleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyvästi)
	veropros:		Rakennukselle määrätty kiinteistöveroprosentti;

%MACRO KiVeroVapS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, talviask, sahkok, 
viemarik, vesik, wck, saunak, jhvalarvokoodi, veropros)/ 
DES = 'KIVERO: Vapaa-ajan asunnon kiinteistövero';

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf);

%VapVerotusArvoS(vapvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&talviask, &sahkok, &viemarik, &vesik, &wck, &saunak, &jhvalarvokoodi);

IF &raktyyppi = 7 THEN DO;

	temp = vapvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp vapvarvo; 
%MEND KiVeroVapS;


/* 6. Kiinteistöveron pienimmän määrättävän veron huomioon ottaminen */ 

*Makron parametrit:
	tulos: 			Makron tulosmuuttuja, Kiinteistövero josta on nollattu pienintä perittävää määrää pienemmät kiinteistöverot.
	mvuosi: 		Vuosi, jonka lainsäädäntöä käytetään 
	minf: 			Deflaattori euromääräisten parametrien kertomiseksi 
	kivero: 		Kiinteistövero ennen pienimmän määrättävän veron huomioon ottamista; 
	
%MACRO KiMinimi(tulos, mvuosi, minf, kivero)/
DES = 'KIVERO: Pienimmän määrättävän veron huomioon ottaminen'; 

%HaeParam&TYYPPI(&mvuosi, 1, &KIVERO_PARAM, PARAM.&PKIVERO);
%ParamInf&TYYPPI(&mvuosi, 1, &KIVERO_MUUNNOS, &minf); 

IF &kivero < &PiMinimi THEN DO; 
	temp = 0; 
END; 

ELSE temp = &kivero; 

&tulos = temp; 

DROP temp; 
%MEND KiMinimi; 


