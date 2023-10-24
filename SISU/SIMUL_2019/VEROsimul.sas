/*************************************************************
*  Kuvaus: Tuloverotuksen simulointimalli 2018		         * 
*  Viimeksi päivitetty: 30.5.2020	  		 				 * 
* ***********************************************************/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = VERO;

%LET TYYPPI = SIMUL;

%LET alkoi1&malli = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, käytetään siellä määriteltyjä ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, käytetään alla syötettyjä ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;
	
	%LET AVUOSI = 2018;		/* Aineistovuosi (vvvv)*/

	%LET LVUOSI = 2018;		/* Lainsäädäntövuosi (vvvv) */

	%LET AINEISTO = REK; 	/* Käytettävä aineisto (PALV = tulonjaon palveluaineisto, REK = mikrosimuloinnin rekisteriaineisto) */

	%LET TULOSNIMI_VE = vero_simul_&SYSDATE._1; /* Simuloidun tulostiedoston nimi */

	%LET TARKPVM = 1;    	/* Jos tämän arvo = 1, sairausvakuutuksen päivärahamaksun
						       laskentaa tarkennetaan käänteisellä päättelyllä */

	* Inflaatiokorjaus. Euro- tai markkamääräisten parametrien haun yhteydessä suoritettavassa
	  deflatoinnissa käytettävän kertoimen voi syöttää itse INF-makromuuttujaan
	  (HUOM! desimaalit erotettava pisteellä .). Esim. jos yksi lainsäädäntövuoden euro on
	  aineistovuoden rahassa 95 senttiä, syötä arvoksi 0.95.
	  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
	  Jos puolestaan haluaa käyttää automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
	  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
	  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

	%LET INF = 1.00; * Syötä lukuarvo, KHI tai ATI;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;

	/* Ajettavat osavaiheet */

	%LET POIMINTA = 1;  	/* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) */
	%LET TULOKSET = 1;		/* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei) */

	%LET LAKIMAK_TIED_VE = VEROlakimakrot;	/* Lakimakrotiedoston nimi */
	%LET PVERO = pvero; /* Käytettävien parametritiedostojen nimet */
	%LET PVERO_VARALL = pvero_varall; 
			
	/* Tulostaulukoiden esivalinnat */

	%LET TULOSLAAJ = 1; 	/* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) */
	%LET MUUTTUJAT = ANSIOT POTULOT KOKONTULO ltva VALTVEROH ltvp POVEROC lkuve KUNNVEROG lkive KIRKVEROG lshma SAIRVAKG lelvak PALKVAK 
					 lpvma PRAHAMAKSU KOTITVAH_DATA KOTITVAH lylen YLEVERO LAPSIVAH KAIKKIVEROT_DATA KAIKKIVEROT verot MAKSP_VEROT
					 OSINKOA_DATA OSINKOA OSINKOP_DATA OSINKOP OSINKOVAP_DATA OSINKOVAP; /* Taulukoitavat muuttujat (summataulukot) */
	%LET YKSIKKO = 1;		/* Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) */
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilöluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilöluokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavuv (viitehenkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilön koulutusaste)
							     paasoss (viitehenkilön sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		/* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) */

	/* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	/* N eli lukumäärät */
	%LET SUM = SUM; 
	%LET MIN = ; 
	%LET MAX = ;
	%LET RANGE = ;
	%LET MEAN = ;
	%LET MEDIAN = ;
	%LET MODE = ;
	%LET VAR = ;
	%LET CV =  ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	/* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana) */
	%LET RAJAUS =  ; 		/* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia) */

	%END;

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET SAIRVAK = 0; 
	%LET TTURVA = 0; 
	%LET OPINTUKI = 0; 
	%LET KANSEL = 0; 
	%LET KOTIHTUKI = 0;

	/* Erillismoduulien valinta (vain REK) */
	%LET OSINKO_MODUL = 0;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO Vero_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 2.1 Määritellään tarvittavat muuttujat taulukkoon START_VERO */

	DATA STARTDAT.START_VERO;
	SET POHJADAT.&AINEISTO&AVUOSI (KEEP = 
	 hnro knro soss maakunta asko ayri: kayri: /* Pidetään kaikki ayri- ja kayri-alkuiset */
	 ceinv cinv cllkm csivs fluotap fluotmu ftapakk ftapep ftapepp
	 ftappm ftappmp ftvuora ftyhmt ikakk ikavu
	 lapsiev lelvak lkive lkuve lpvma lshma ltva ltvp lveru svatva svatvap
	 svatpp tansel tapur teanstu teinova teinovv teinovvb teleuve telps1
	 telps2 telps5 telvpal tenosve tepalk tjmark tjvkork tkansel tkust
	 tlakko tlue2 tmeri tmetsp tmetspp tmluoko tmpt tmtatt tmuuel tmuukor tmuut
	 tmuutp tmyynt tmyynt1 tnoosvab tnoosvvb tomlis toyjmav toyjmavvap
	 toyjmyv toyjmyvvap treitosva toptio tpalv tpalv2 tpalv2a tpalv2p
	 tpeito tperhel tpjta tpotel tpturva trespa trpl trplkor
	 anstukor tsiraho tsuurpu ttapel tkuntra tlapel ttappr ttyoltuk
	 tulk tulkp tulkp6 tulkya2 tulkyhp tuosvv tuosvvap tutmp2
	 tutmp3 tutmp4 tvahevas tptelak tptmuu tvakpr tvaksp tvuokr tvuokr1 tyhtat
	 tyhtpot tyot velatk vevm vkoras vkorep vkortu vkotita
	 vkotitki vkotitku vkotitp vkotitsv vlahj vluothm vmatk vmuut1
	 vmuutk vmuutv vohvah vopintov vthmp vthm2 vthm4 vtyasv vtyomj
	 vvevah vvvmk1 vvvmk3 vvvmk5 yhtez yrtukor hsaiprva haiprva tkotihtu
	 hwmky tkoultuk tmtukimk tkopira ktku htkapr hkotihm takuuel oplaikor
	 tjmarkh tvahep50 tptvs tvahep20 tptsu50 korosazkg korosazkf korosatkg
	 korosatkf dtyhtep korosapks korosapkw elivtu lylen tkapite tsijova
	 vthmkor palksiku palkomos tyonosuu 
	 tosmetpt tyhtmat tyhtate tyhtmpot tyhtpote
	 tmaat1evyr tmaat1pevyr tliik1evyr tliikpevyr tporo1evyr tyhtmatevyr
     tyhtateevyr tmaat2evyr tmaat2pevyr tliik2evyr tliik2pevyr tporo2evyr
     tyhtmpotevyr tyhtpoteevyr VKERROIN tulkelvp
	 );

	/* Verrataan lainsäädäntövuotta aineiston äyreihin, valitaan lähin äyri 
	   ja uudelleennimetään veroäyrit simulointia vastaaviksi. 
	   Jos lainsäädäntövuotta vastaavaa äyriä ei löydy aineistosta, kerrotaan sitä
	   lähinnä oleva tieto korotuskertoimella myöhemmin. */

	/* Vuoden 2018 aineistossa äyrit vuosille 2018-2020 */
	%IF ((&LVUOSI >= 2018) AND (&LVUOSI <= 2020)) %THEN %DO; 
		%LET LAYRI = %SUBSTR(&LVUOSI, 3, 2);
		RENAME ayri&LAYRI = AYRI kayri&LAYRI = KAYRI;
	%END;

	%ELSE %IF &LVUOSI < 2018 %THEN %DO;
		RENAME ayri18 = AYRI kayri18 = KAYRI;
	%END;

	%ELSE %IF &LVUOSI > 2020 %THEN %DO;
		RENAME ayri20 = AYRI kayri20 = KAYRI;
	%END;

	/* Muuttujan YKSINHUOLTAJA muodostaminen */

	IF elivtu IN (20, 83, 84) THEN YKSINHUOLTAJA =  1; 
	ELSE YKSINHUOLTAJA = 0;

	RUN;

	/* 2.2 Lisätään aineistoon apumuuttujia */

	/* Puolisot */
		
	DATA TEMP.VERO_PUOLISOT;
	SET STARTDAT.START_VERO (KEEP = knro hnro csivs asko);
	WHERE asko = 1 OR asko = 2;
	RUN;

	PROC MEANS DATA = TEMP.VERO_PUOLISOT SUM NOPRINT;
	BY knro;
	VAR asko;
	OUTPUT OUT = TEMP.VERO_PUOLISOT_2 SUM(asko) = PSOTX;
	RUN;

	DATA STARTDAT.START_VERO;
	MERGE STARTDAT.START_VERO TEMP.VERO_PUOLISOT_2 (WHERE = (PSOTX = 3) KEEP = knro PSOTX);
	BY knro;
	RUN;

	/* Apumuuttujia */

	DATA STARTDAT.START_VERO;
	SET STARTDAT.START_VERO;

	SAIRVAK_DATA = SUM(MAX(hsaiprva, 0), MAX(haiprva, 0), MAX(hwmky, 0), htkapr);
	TTURVA_DATA = SUM(MAX(vvvmk1, 0), MAX(vvvmk3, 0), MAX(vvvmk5, 0),
					MAX(0, SUM(dtyhtep, korosapks, korosapkw)), MAX(SUM(yhtez, korosazkg, korosazkf), 0),
				    MAX(SUM(tmtukimk, korosatkg, korosatkf), 0));

	MUU_TTURVA_DATA = SUM(MAX(tkoultuk, 0)); 
	OPTUKI_DATA = tkopira;
	KANSEL_DATA = SUM(tkansel, tperhel, takuuel);

	/* Vertailutiedoksi aluksi dataan perustuva tieto verottomista osingoista */
	OSINKOVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, toyjmyvvap, toyjmavvap, teinovv);
	OSINKOA_DATA = SUM(teinova, tpeito, toyjmyv);
	OSINKOP_DATA = SUM(tnoosvab, tenosve, tuosvv, toyjmav);

	/* Puolison päättelyä */
	PSOT = IFN(csivs = 2, 1, 0);
	IF PSOTX = 3 AND asko = 1 THEN VEROPUOL = 1;
	ELSE IF PSOTX = 3 AND asko = 2 THEN VEROPUOL = 2;
	ELSE IF PSOTX = . OR asko > 2 THEN VEROPUOL = 0;
	
	/* Eräiden tuloerien summia */
	ULKPALKKA = MAX(SUM(tulkp, -tulkp6), 0);
	PALKKA1 = SUM(trpl, trplkor, anstukor, ULKPALKKA, tmpt, tkust, tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tutmp2, tutmp3, tutmp4);
	MUU_TYO = SUM(tpalv2, telps1, telps2, telps5, ttyoltuk);
	YRITYSTA = SUM(tmaat1evyr, tmaat1pevyr, tpjta, tliik1evyr, tliikpevyr, tporo1evyr, tyhtmatevyr, tyhtateevyr, SUM(tyhtat, -tyhtmat, -tyhtate), tmtatt, yrtukor);
	TYOTULOA = SUM(PALKKA1, MUU_TYO, YRITYSTA);
	YRITYSTP = SUM(tmaat2evyr, tmaat2pevyr, tliik2evyr, tliik2pevyr, tporo2evyr, tyhtmpotevyr, tyhtpoteevyr, SUM(tyhtpot, -tyhtmpot, -tyhtpote), MAX(tmetsp, 0), MAX(tmetspp, 0), MAX(tosmetpt, 0), tvaksp);
	VAKPALK = SUM(MAX(SUM(trpl, -toptio), 0), tmpt, tmeri, tlue2);
	MUUT_EL = MAX(SUM(tansel, ttapel, tlapel, tpotel, teanstu, tmuuel, teleuve), 0);
	MUU_ANSIO = SUM(tlakko, tpalv2a, tmuut, tomlis, telvpal, tmluoko, tsuurpu, MUU_TTURVA_DATA, tkapite, tapur);
	THANKK = SUM(vthm4);
	MUU_VAH_VALT2 = SUM(vmuut1, vmuutv, MAX(SUM(vevm, -lelvak),0));
	MUU_VAH_KUNN2 = SUM(vmuut1, vmuutk, ftapakk,  MAX(SUM(vevm, -lelvak),0));
	POTAPP = SUM(ftappm, ftapep, ftappmp, ftapepp, ftyhmt, ftvuora);
	/* Muodostetaan muuttuja ULK_OSUUS niille henkilöille, joille ulkomaan tuloihin on käytetty vapautusmenetelmää */
	IF svatva > 0 AND tulkya2 > 0 THEN ULK_OSUUS = tulkya2 / svatva; ELSE ULK_OSUUS = 0;
	VUOKRAT = SUM(tvuokr, tvuokr1);
	MUU_PO = SUM(tpalv2p, tjvkork, tmuukor, tjmark, tmuutp, tsiraho, 
				MAX(SUM(tmyynt, tmyynt1, -fluotap), 0), tvahevas, tptmuu, MAX(SUM(tulkyhp, -tuosvv),0),
					tvahep50, tptvs, tvahep20, tptsu50, tptelak);

	/* Lahjoitusvähennys vuosina 2009-2012 ja vuodesta 2016 eteenpäin */
	IF 2009 <= &LVUOSI <= 2012 OR &LVUOSI >= 2016 THEN DO;
		MUU_VAH_VALT2 = SUM(MUU_VAH_VALT2, vlahj);
		MUU_VAH_KUNN2 = SUM(MUU_VAH_KUNN2, vlahj);
	END; 

	/* Luovutustappiot ovat vähennyskelpoisia myös muista pääomatuloista kuin luovutusvoitoista vuodesta 2016 alkaen */
	IF &LVUOSI >= 2016 THEN DO;
		POTAPP = SUM(POTAPP, fluotmu);
	END;

	/* Väliaikainen sijoitusvähennys pääomatulona 2013-2015 */
	IF 2015 <= &LVUOSI <= 2015 THEN DO;
		MUU_PO = SUM(MUU_PO, tsijova);
	END;

	/* Päätellään yrittäjyysindikaattori */
	IF TYOTULOA > 0 AND YRITYSTA > 0.9 * TYOTULOA THEN YRITTAJA = 1;
	ELSE YRITTAJA = 0;

	/* Kotitalousvähennykset ja datan verot */
	KOTITVAH_DATA = SUM(vkotita, vkotitku, vkotitsv, vkotitki, vkotitp);
	KAIKKIVEROT_DATA = SUM(lelvak, lpvma, ltva, ltvp, lkuve, lkive, lshma, lylen);

	/* 2.3 Luodaan uusille apumuuttujille selkokieliset kuvaukset */

	LABEL 	
	PSOT = 'Puoliso (0/1), DATA'
	PSOTX = 'Puolisotunniste, DATA'
	VEROPUOL = 'Puoliso verotuksessa, DATA'
	YRITTAJA = 'Yrittäjyyteen liittyvä apumuuttuja, DATA'

	SAIRVAK_DATA = 'Sairausvakuutuslain mukaiset päivärahat yhteensä, DATA'
	TTURVA_DATA = 'Työttömyysturva ja koulutustuki, DATA'
	MUU_TTURVA_DATA = 'Ei-simuloidut työttömyysturvaetuudet, DATA' 
	OPTUKI_DATA = 'Opintotuki, DATA'
	KANSEL_DATA = 'Kansaneläke (ml. KE:n perhe-eläke ja takuueläke), DATA'
	OSINKOVAP_DATA = 'Verovapaat osingot, DATA'
	OSINKOA_DATA = 'Osingot ansiotulona, DATA'
	OSINKOP_DATA = 'Osingot pääomatulona, DATA'
				
	ULKPALKKA = 'Ulkomaan palkat, DATA'
	PALKKA1 = 'Palkkatulot, DATA'
	MUU_TYO = 'Muut työtulot, DATA'
	YRITYSTA = 'Yrittäjätulot ansiotuloina (yrittäjävähennystä ei ole tehty), DATA'	
	TYOTULOA = 'Ansiotulot (yrittäjävähennystä ei ole tehty), DATA'
	YRITYSTP = 'Yrittäjätulot pääomatuloina (yrittäjävähennystä ei ole tehty), DATA'
	VAKPALK = 'Vakuutuspalkka, DATA'
	MUUT_EL = 'Muut eläkkeet, DATA'
	MUU_ANSIO = 'Muut ansiotulot, DATA'
	THANKK = 'Ulkomaantulon kuluvähennys ja tulonhankkimiskulut muista kuin työ- ja palkkatuloista, DATA'
	MUU_VAH_VALT2 = 'Muita väh. valtionverotuksessa, DATA'
	MUU_VAH_KUNN2 = 'Muita väh. kunnallisverotuksessa, DATA'
	POTAPP = 'Pääomatulon tappiot, DATA'
	ULK_OSUUS = 'Ulkomaan palkkatulojen osuus ansiotuloista, DATA'
	VUOKRAT = 'Vuokratulot, DATA'
	MUU_PO = 'Muut pääomatulot, DATA'

	KOTITVAH_DATA = 'Kotitalousvähennys, DATA'
	KAIKKIVEROT_DATA = 'Kaikki verot, DATA';

	/* 2.4 Tilan ja ajan säästämiseksi pudotetaan starttidatasta muuttujia, joita ei tarvita varsinaisessa simuloinnissa */
	DROP csivs fluotap fluotmu ftapakk ftapep ftapepp ftappm ftappmp
		ftvuora ftyhmt lkive lkuve lpvma lshma ltva ltvp svatva svatvap svatpp
		tansel tapur teanstu teleuve telps1 telps2 telps5 telvpal tepalk tjmark
		tjvkork tkansel tkust tlakko tlue2 tmluoko tmpt tmtatt tmuuel tmuukor
		tmuut tmuutp tmyynt tmyynt1 tomlis toptio tpalv tpalv2 tpalv2a tpalv2p
		tperhel tpjta tpotel tpturva trespa trpl trplkor anstukor tsiraho
		tsuurpu ttapel tlapel ttyoltuk tulkp6 tulkya2 tutmp2 tutmp3
		tutmp4 tvahevas tptelak tptmuu tvaksp tvuokr tvuokr1 vevm
		vkotita vkotitki vkotitku vkotitp vkotitsv vlahj vmuut1 vmuutk
		vmuutv vthm4 vvvmk1 vvvmk3 vvvmk5 yhtez yrtukor hsaiprva haiprva
		hwmky tkoultuk tmtukimk tkopira takuuel tvahep50 tptvs tvahep20 tptsu50
		korosazkg korosazkf korosatkg korosatkf dtyhtep korosapks korosapkw
		lylen tkapite tsijova;

	RUN;

%END;

%MEND Vero_Muutt_Poiminta;

%Vero_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3. Makro hakee tietoja muista osamalleista ja liittää ne mallin dataan */

%MACRO OsaMallit_Vero;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &KOTIHTUKI = 1 OR &OPINTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_VERO;
		MERGE STARTDAT.START_VERO (IN = C)

		/* 3.1 Sairausvakuutus */
		%IF &SAIRVAK = 1 %THEN %DO;
			TEMP.&TULOSNIMI_SV
			(KEEP = hnro SAIRPR VANHPR ERITHOITR)
		%END;

		/* 3.2 Työttömyysturva */
		%IF &TTURVA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_TT
			(KEEP = hnro YHTTMTUKI TMTUKILMKOR PERILMAKOR PERUSPR ANSIOPR ANSIOILMKOR VUORKORV)
		%END;

		/* 3.3 Kansaneläke */
		%IF &KANSEL = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KE
			(KEEP = hnro TAKUUELA KANSANELAKE LAPSENELAKE LESKENELAKE)
		%END;

		/* 3.4 Kotihoidontuki */
		%IF &KOTIHTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KT
			(KEEP = hnro KOTIHTUKI OSHOIT JSHOIT)
		%END;

		/* 3.5 Opintotuki */
		%IF &OPINTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_OT
			(KEEP = hnro TUKIKESK TUKIKOR)
		%END;

		;
		BY hnro;
		IF C;
	RUN;

%END;

%MEND OsaMallit_Vero;

%OsaMallit_Vero;

/* 4. Nämä määrittelyt ja makro tuottavat kertoimet
   keskimääräisen kunnallis- ja kirkollisveroprosentin muunnoskertoimen laskemiseksi
   Muista päivittää tämä aineistovuoden mukaiseksi! */

%MACRO Vero_Ayrit;

/* Vuoden 2018 aineistossa äyrit vuosille 2018-2020 */
%IF &LVUOSI < 2018 %THEN %DO;
	%KunnVerKerroin(2018, &LVUOSI);
%END;

%IF &LVUOSI > 2020 %THEN %DO;
	%KunnVerKerroin(2020, &LVUOSI);
%END;

%ELSE %DO;
	%LET kunnkerroin = 1;
	%LET kirkkerroin = 1;
%END;

%MEND Vero_Ayrit;

/* 5. Simulointivaihe */

%MACRO Vero_Simuloi_Data;

	/* Muuttujat, joihin haetaan lista mallin käyttämistä lakiparametreistä */
	%LOCAL VERO_PARAM VERO_MUUNNOS VERO2_PARAM VERO2_MUUNNOS;

	/* Haetaan mallin käyttämien lakiparametrien nimet */
	%HaeLokaalit(VERO_PARAM, VERO);
	%HaeLaskettavatLokaalit(VERO_MUUNNOS, VERO);
	%LOCAL KirkKerroin KunnKerroin;

	/* Haetaan varallisuusveron käyttämien lakiparametrien nimet */
	%HaeLokaalit(VERO2_PARAM, VERO_VARALL);
	%HaeLaskettavatLokaalit(VERO2_MUUNNOS, VERO_VARALL);

	/* Luodaan tyhjät lokaalit muuttujat lakiparametien hakua varten */
	%LOCAL &VERO_PARAM &VERO2_PARAM;

	%HaeParamSimul(&LVUOSI, 1, &VERO_PARAM, PARAM.&PVERO);
	%ParamInfSimul(&LVUOSI, 1, &VERO_MUUNNOS, &INF);

	%HaeParamSimul(&LVUOSI, 1, &VERO2_PARAM, PARAM.&PVERO_VARALL);
	%ParamInfSimul(&LVUOSI, 1, &VERO2_MUUNNOS, &INF);

	%Vero_Ayrit;

	DATA TEMP.&TULOSNIMI_VE;
	SET STARTDAT.START_VERO;

	/* Haetaan tarvittaessa muiden osamallien tulostauluista tietoja */
	%IF &SAIRVAK = 0 %THEN %DO;
		SAIRVAK_SIMUL = SAIRVAK_DATA;
	%END;
	%ELSE %DO;
		SAIRVAK_SIMUL = SUM(SAIRPR, VANHPR, ERITHOITR, htkapr);
	%END;

	%IF &TTURVA = 0 %THEN %DO; 
		TTURVA_SIMUL = TTURVA_DATA;
	%END;
	%ELSE %DO; 
		TTURVA_SIMUL = SUM(YHTTMTUKI, PERUSPR,  ANSIOPR, VUORKORV);
	%END;

	%IF &KANSEL = 0 %THEN %DO;
		KANSEL_SIMUL = KANSEL_DATA;
	%END;
	%ELSE %DO;
		KANSEL_SIMUL = SUM(TAKUUELA, KANSANELAKE, LAPSENELAKE, LESKENELAKE);
	%END;

	%IF &KOTIHTUKI = 0 %THEN %DO;
		KOTIHTUKI_SIMUL = tkotihtu;
	%END;
	%ELSE %DO;
		KOTIHTUKI_SIMUL = SUM(KOTIHTUKI, OSHOIT, JSHOIT, ktku, hkotihm);
	%END;

	%IF &OPINTUKI = 0 %THEN %DO; 
		OPTUKI_SIMUL = OPTUKI_DATA;
	%END;
	%ELSE %DO; 
		OPTUKI_SIMUL = SUM(TUKIKESK, TUKIKOR);
	%END;

	PRAHAT = SUM(SAIRVAK_SIMUL, TTURVA_SIMUL, KOTIHTUKI_SIMUL, tvakpr, ttappr, tkuntra);
	ELAKE = SUM(KANSEL_SIMUL, MUUT_EL);

	RUN;

	/* ERILLISMODUULIT */

	/* OSINGOT */

	/* Jaetaan osinkotulot eri kategoroihin: ansiotulot, pääomatulot, verottomat tulot */
	%IF &OSINKO_MODUL = 1 %THEN %DO;
		/* Jaetaan osinkotulot eri kategoroihin erillisohjelman (OSINKOsimul.sas) avulla: ansiotulot, pääomatulot, verottomat tulot */

		/* OSINGOT - MODUULI */
		%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO.OSINKOsimul.sas";

		DATA TEMP.&TULOSNIMI_VE;
		MERGE TEMP.&TULOSNIMI_VE TEMP.osingot_simuloitu ;
		BY hnro;

		*Erillisaineisto ei sisällä ulkomaan osinkoja, joten jaetaan ne erikseen tässä;
		%OsinkojenJakoS(OSINKOPU, &LVUOSI, 1, 0, 2, SUM(tuosvvap, tuosvv), 0, 0);
		%OsinkojenJakoS(OSINKOVAPU, &LVUOSI, 1, 0, 1, SUM(tuosvvap, tuosvv), 0, 0);

		OSINKOA = SUM(EILIST_AT, EILISTREIT_AT, EILISTOS_AT, tpeito);
		OSINKOP = SUM(EILIST_POT, LIST_POT, EILISTREIT_POT, LISTREIT_POT, EILISTOS_POT, LISTOS_POT, OSINKOPU);
		OSINKOVAP = SUM(OSU_VAPAA, OSINKOVAPU);
		OSINKOP1 = .;
		OSINKOP2 = .;
		OSINKOP3 = .;
		OSINKOVAP1 = .;
		OSINKOVAP2 = .;
		OSINKOVAP3 = .;
		OSINKOVAP4 = .;

		DROP OSINKOPU OSINKOVAPU;
	%END;
	%ELSE %DO;

		/* EI OSINGOT MODUULIA */
		DATA TEMP.&TULOSNIMI_VE;
		SET TEMP.&TULOSNIMI_VE;

		/* Ansiotulo-osingot, OLETUS */
		%OsinkojenJakoS(OSINKOA, &LVUOSI, 1, 0, 3, 0, SUM(teinova, teinovv, toyjmyv, toyjmyvvap), 0) ;

		/* Pääomatulo-osingot: 1 ulkomaan osingot ja listatut yhtiöt, 2 osuuspääoman korot / noteeraamattomien osuuskuntien
		ylijäämä, 3 listaamaattomat yhtiöt */
		%OsinkojenJakoS(OSINKOP1, &LVUOSI, 1, 0, 2, SUM(tnoosvab, tnoosvvb, -treitosva, tuosvvap, tuosvv), 0, 0);
		%OsinkojenJakoS(OSINKOP2, &LVUOSI, 1, 1, 2, 0, SUM(toyjmav, toyjmavvap), 0);
		%OsinkojenJakoS(OSINKOP3, &LVUOSI, 1, 0, 2, 0, SUM(tenosve, teinovvb), -1);

		/* Verottomat osingot: 1 ulkomaan osingot ja listatut yhtiöt, 2 osuuspääoman korot / noteeraamattomien osuuskuntien
		ylijäämä (pääomatulo), 3 listaamaattomat yhtiöt (pääomatulo), 4 listaamattomat yhtiöt ja osuuskunnat (ansiotulo) */
		%OsinkojenJakoS(OSINKOVAP1, &LVUOSI, 1, 0, 1, SUM(tnoosvab, tnoosvvb, -treitosva, tuosvvap, tuosvv), 0, 0);
		%OsinkojenJakoS(OSINKOVAP2, &LVUOSI, 1, 1, 1, 0, SUM(toyjmav, toyjmavvap), 0);
		%OsinkojenJakoS(OSINKOVAP3, &LVUOSI, 1, 0 ,1, 0, SUM(tenosve, teinovvb), -1);
		%OsinkojenJakoS(OSINKOVAP4, &LVUOSI, 1, 0, 1, 0, SUM(teinova, teinovv, toyjmyv, toyjmyvvap), 0);

		OSINKOA = SUM(OSINKOA, tpeito);
		OSINKOP = SUM(OSINKOP1, OSINKOP2, OSINKOP3, treitosva);
		OSINKOVAP = SUM(OSINKOVAP1, OSINKOVAP2, OSINKOVAP3, OSINKOVAP4);

	%END;

	/* Yhtiöveron hyvitys */
	%YhtHyvS(YHTHYVP, &LVUOSI, &INF, OSINKOP);
	%YhtHyvS(YHTHYVA, &LVUOSI, &INF, OSINKOA);

	/* Yrittäjävähennys */
	%YrittajaVahS(YRVAHA, &LVUOSI, &INF, SUM(tmaat1evyr, tmaat1pevyr, tliik1evyr, tliikpevyr, tporo1evyr, tyhtmatevyr, tyhtateevyr));
	%YrittajaVahS(YRVAHP, &LVUOSI, &INF, SUM(tmaat2evyr, tmaat2pevyr, tliik2evyr, tliik2pevyr, tporo2evyr, MAX(tmetsp, 0), MAX(tmetspp, 0), MAX(tosmetpt, 0), tyhtmpotevyr, tyhtpoteevyr));

	/* Ansiotulot, pääomatulot, kokonaistulot */
	ANSIOT = SUM(PALKKA1,  MUU_TYO,  YRITYSTA,  ELAKE,  PRAHAT, OPTUKI_SIMUL, MUU_ANSIO, OSINKOA, YHTHYVA);
	POTULOT = MAX(SUM(YRITYSTP, VUOKRAT, MUU_PO, OSINKOP, YHTHYVP), 0);
	PUHD_PO = MAX(SUM(POTULOT, -YRVAHP, -vthm2, -tjmarkh, -vohvah), 0);
	KOKONTULO = SUM(ANSIOT, POTULOT);

	/* Palkansaajan työeläkemaksu ja työttömyysvakuutusmaksu yhdistettynä */
	IF VAKPALK > 0 THEN DO;

		* Lasketaan työeläke- ja työttömyysvakuutusmaksut siten, että ensin lasketaan mitä ne
		olisivat vuositasolla silloin kun henkilön ikä on ikavu - 1 ja sitten vastaavasti
		silloin kun henkilön ikä on ikavu. Näin saaduista tuloksista lasketaan ikakk-muuttujan
		avulla painotettu keskiarvo. Näin saadaan oikea tulos myös niiden henkilöiden tapauksessa,
		jotka ovat ylittäneet jonkin ikärajan vuoden aikana;

		* Työttömyysvakuutusmaksu;
		%TyotMaksuS(TYOTMAKSU1, &LVUOSI, &INF, ikavu - 1, VKERROIN * VAKPALK);
		%TyotMaksuS(TYOTMAKSU2, &LVUOSI, &INF, ikavu, VKERROIN * VAKPALK);

		TYOTMAKSU = SUM((12 - ikakk) * TYOTMAKSU1, ikakk * TYOTMAKSU2) / 12;

		* Työeläkemaksu;
		%TyoelMaksuS(ELVAK1, &LVUOSI, &INF, ikavu - 1, VKERROIN * VAKPALK);
		%TyoelMaksuS(ELVAK2, &LVUOSI, &INF, ikavu, VKERROIN * VAKPALK);

		ELVAK = SUM((12 - ikakk) * ELVAK1, ikakk * ELVAK2) / 12;

		* Summataan yhteen muuttujaan;
		PALKVAK = SUM(TYOTMAKSU, ELVAK);
	END;
	ELSE PALKVAK = 0;

	PRAHAMAKSUTULO = SUM(TYOTULOA, -YRVAHA);

	/* Sairausvakuutuksen päivärahamaksu, yritystulon korotettu maksu huomioon otettuna */
	IF PRAHAMAKSUTULO > 0 THEN DO;

		* Sairausvakuutuksen päivärahamaksun laskenta jaetaan kahteen makroon kuten työeläke- ja
		työttömyysvakuutusmaksut yllä. Tulotieto PRAHAMAKSUTULO on muodostettu käänteisesti
		todellisen maksetun päivärahamaksun mukaan, joten sitä ei voida käyttää jos laskennassa
		halutaan muuttaa maksuvelvollisiksi sellaisia henkilöitä, jotka eivät aineistossa ole olleet
		olleet maksuvelvollisia!;

		%SvPRahaMaksuYS(PRAHAMAKSU1, &LVUOSI, &INF, ikavu - 1, IFN(YRITTAJA = 1, 1, 0), PRAHAMAKSUTULO);
		%SvPRahaMaksuYS(PRAHAMAKSU2, &LVUOSI, &INF, ikavu, IFN(YRITTAJA = 1, 1, 0), PRAHAMAKSUTULO);

		PRAHAMAKSU = SUM((12 - ikakk) * PRAHAMAKSU1, ikakk * PRAHAMAKSU2) / 12;

	END;
	ELSE PRAHAMAKSU = 0;

	DROP TYOTMAKSU TYOTMAKSU1 TYOTMAKSU2 ELVAK ELVAK1 ELVAK2;

	/* Tulonhankkimisvähennys, työmatkakuluvähennys, ay-jäsenmaksujen vähennys */
	%TulonHankKulutS(THANKKULUT, &LVUOSI, &INF, SUM(PALKKA1, -tmeri), SUM(vthmp, vluothm, vthmkor), vtyomj, vmatk, tyot); 
	%TulonHankKulutS(THANKKULUTM, &LVUOSI, &INF, tmeri, SUM(vthmp, vluothm, vthmkor), 0, 0, tyot);
	THANKKULUT2 = SUM(THANKKULUT, THANKKULUTM, vtyasv, THANKK);
	PUHD_ANSIO = MAX(SUM(ANSIOT, -YRVAHA, - THANKKULUT2), 0);

	/* Kunnallisveron eläketulovähennys */
	IF ELAKE > 0 THEN DO;
		%KunnElTulVahS(ELTULVAH_K, &LVUOSI, &INF,  PSOT, 0, ELAKE, PUHD_ANSIO, 0);
	END;
	ELSE ELTULVAH_K = 0;

	/* Kunnallisveron ansiotulovähennys */
	IF SUM(PALKKA1, MUU_TYO, YRITYSTA, -YRVAHA, IFN(&LVUOSI > 2004, OSINKOA, 0)) > 0 THEN DO;
		%KunnAnsVahS(ANSIOT_VAH, &LVUOSI, &INF, PUHD_ANSIO, SUM(ANSIOT, -YRVAHA, -ELAKE), SUM(PALKKA1, MUU_TYO, YRITYSTA, -YRVAHA, IFN(&LVUOSI > 2004, OSINKOA, 0)), PALKKA1, SUM(KOKONTULO, -YRVAHA, -YRVAHP));
	END;
	ELSE ANSIOT_VAH = 0;

	/* Kunnallisverotuksen opintorahavähennys */
	IF OPTUKI_SIMUL > 0 THEN DO;
		%KunnOpRahVahS(OPRAHVAH, &LVUOSI, &INF, 1, OPTUKI_SIMUL, SUM(ANSIOT, -YRVAHA), PUHD_ANSIO);
	END;
	ELSE OPRAHVAH = 0;

	/* Kunnallisverotuksen invalidivähennys */
	IF cinv > 0 OR ceinv > 0 THEN DO;
		%KunnVerInvVahS(INVVAH_K, &LVUOSI, &INF, IFN(ceinv > 0, 1, 0), IFN(ceinv > cinv, ceinv, cinv), PUHD_ANSIO, ELAKE);
	END;
	ELSE INVVAH_K = 0;

	/* Valtioverotuksen eläketulovähennys */
	IF elake > 0 THEN DO;
		%ValtElTulVahS(ELTULVAH_V, &LVUOSI, &INF, ELAKE, PUHD_ANSIO, SUM(KOKONTULO, -YRVAHA, -YRVAHP));
	END;
	ELSE ELTULVAH_V = 0;

	/* Kunnallisverotuksen merityötulovähennys */
	IF tmeri > 0 THEN DO;
		%KunnVerMeriVahS(MERIVAHKUN, &LVUOSI, &INF, tmeri);
	END;
	ELSE MERIVAHKUN = 0;

	KUNNVTULO1 = MAX(SUM(ANSIOT, -YRVAHA, -PALKVAK, -PRAHAMAKSU, -THANKKULUT2, -ELTULVAH_K, -ANSIOT_VAH, -MERIVAHKUN, -OPRAHVAH, -INVVAH_K, -MUU_VAH_KUNN2), 0);

	/* Kunnallisverotuksen perusvähennys */
	IF KUNNVTULO1 > 0 THEN DO;
		%KunnPerVahS(PERVAH, &LVUOSI, &INF, KUNNVTULO1);
	END;
	ELSE PERVAH = 0;

	/* Kunnallis- ja kirkollisveroja */
	KUNNVTULO2 = MAX(SUM(kunnvtulo1, - pervah), 0);
	KUNNVEROA = &kunnkerroin * 0.01 * AYRI * KUNNVTULO2 / 100;
	KIRKVEROA = &kirkkerroin * 0.01 * KAYRI * KUNNVTULO2 / 100;

	/* Käänteinen päättely sairausvakuutusmaksuihin */ 
	IF &TARKPVM = 1 AND YRITTAJA = 1 THEN DO;
		PUHD_ANSIOSV = SUM(PUHD_ANSIO, -SUM(YRITYSTA, -YRVAHA), PRAHAMAKSUTULO);
		/* Kunnallisverotuksen eläketulovähennys */
		%KunnElTulVahS (ELTULVAH_KSV, &LVUOSI, &INF,  PSOT, 0, ELAKE, PUHD_ANSIOSV, 0);
		/* Kunnallisveron ansiotulovähennys */
		%KunnAnsVahS(ANSIOT_VAHSV, &LVUOSI, &INF, PUHD_ANSIOSV, SUM(ANSIOT, -YRVAHA, -ELAKE), PRAHAMAKSUTULO, PALKKA1, SUM(KOKONTULO, -YRVAHA, -YRVAHP));
		/* Kunnallisverotuksen opintorahavähennys */
		%KunnOpRahVahS(OPRAHVAHSV, &LVUOSI, &INF, 1, OPTUKI_SIMUL, SUM(ANSIOT, -YRVAHA), PUHD_ANSIOSV);
		/* Kunnallisverotuksen invalidivähennys */
		%KunnVerInvVahS(INVVAH_KSV, &LVUOSI, &INF, IFN(ceinv > 0, 1, 0), IFN(ceinv > cinv, ceinv, cinv), PUHD_ANSIOSV, ELAKE);
		KUNNVTULO1SV = MAX(SUM(ANSIOT, - YRITYSTA, PRAHAMAKSUTULO, - PALKVAK, - PRAHAMAKSU, - THANKKULUT2, - ELTULVAH_KSV, -ANSIOT_VAHSV, -OPRAHVAHSV, -INVVAH_KSV, -MUU_VAH_KUNN2), 0);
		/* Kunnallisverotuksen perusvähennys */
		%KunnPerVahS(PERVAHSV, &LVUOSI, &INF, KUNNVTULO1SV);
		KUNNVTULO2SV = MAX(SUM(KUNNVTULO1SV, -PERVAHSV), 0);
		/* Sairausvakuutusmaksu */
		%SairVakMaksuS(SAIRVAKA, &LVUOSI, &INF, KUNNVTULO2SV, ELAKE, PRAHAMAKSUTULO);
	END;
	ELSE DO;
		/* Sairausvakuutusmaksu, kun ei tehdä käänteistä päättelyä */
		IF KUNNVTULO2 > 0 THEN DO;	
			%SairVakMaksuS(SAIRVAKA, &LVUOSI, &INF, KUNNVTULO2, ELAKE, PRAHAMAKSUTULO);
		END;
	ELSE SAIRVAKA = 0;
	END;

	/* Kansaneläkevakuutusmaksu */
	IF MAX(SUM(KUNNVTULO2, - tulk), 0) > 0 THEN DO;	
		%KansElVakMaksuS(KEVA, &LVUOSI, &INF, MAX(SUM(KUNNVTULO2, - tulk), 0), ELAKE);
	END;
	ELSE KEVA = 0;

	/* Valtionverotuksen merityötulovähennys */
	IF tmeri > 0 THEN DO;
		%ValtVerMeriVahS(MERIVAHVAL, &LVUOSI, &INF, tmeri); 
	END;
	ELSE MERIVAHVAL = 0;

	VALTVERTULO = MAX(SUM(ANSIOT, -YRVAHA, -PALKVAK, -MERIVAHVAL, -PRAHAMAKSU, -THANKKULUT2, -ELTULVAH_V, -MUU_VAH_VALT2), 0);

	/* Valtion tulovero */
	IF VALTVERTULO > 0 THEN DO;
		%ValtTuloVeroS(VALTVEROA, &LVUOSI, &INF, VALTVERTULO);
	END;
	ELSE VALTVEROA = 0;

	/* Vuonna 2013 otettiin käyttöön eläketulon lisävero. Se lisätään valtion tuloveroon. */
	IF ELAKE > 0 THEN DO;
		%ElakeLisaVeroS(ELAKELISAVERO, &LVUOSI, &INF, ELAKE, ELTULVAH_V);
	END;

	VALTVEROA = SUM(VALTVEROA, ELAKELISAVERO);

	/* Valtionverotuksen ansiotulovähennys/työtulovähennys */
	IF SUM(PALKKA1, MUU_TYO, YRITYSTA, -YRVAHA, IFN(&LVUOSI > 2004, OSINKOA, 0)) > 0 THEN DO;
		%ValtVerAnsVahS(VALTANSVAH, &LVUOSI, &INF, SUM(PALKKA1, MUU_TYO, YRITYSTA, -YRVAHA, IFN(&LVUOSI > 2004, OSINKOA, 0)), PUHD_ANSIO);
	END;
	ELSE VALTANSVAH = 0;

	/* Valtionverotuksen invalidivähennys */
	IF cinv > 0 THEN DO;
		%ValtVerInvVahS(INVVAH_V, &LVUOSI, &INF, cinv, ELAKE);
	END;
	ELSE INVVAH_V = 0;

	/* Valtionverotuksen elatusvelvollisuusvähennys */
	IF lapsiev > 0 THEN DO;
		%ValtVerElVelvVahS(ELVELV_VAH, &LVUOSI, &INF, lapsiev, velatk);
	END;
	ELSE ELVELV_VAH = 0;

	/* Vähennykset pääomatuloista */
	PO_VAHENN = SUM(YRVAHP, vthm2, POTAPP, vkortu, vohvah);

	/* Erotellaan ensiasunnon koroista vähennyskelpoinen osuus */
	%VahAsKorotS(ASKOROT, &LVUOSI, &INF, vkoras);
	%VahAsKorotS(ENSASKOROT, &LVUOSI, &INF, vkorep);

	/* Opintolainan korkovähennys poistunut vuonna 2015 */
	IF &LVUOSI >= 2015 THEN DO;
		MUU_VAH = PO_VAHENN;
	END;
	ELSE DO;
		MUU_VAH = SUM(PO_VAHENN, oplaikor);
	END;

	/* Pääomatulon vero, vapaaeht. eläkevakuutusmaksut huomioon otettuna */
	%POTulonveroEritS(POVEROA, &LVUOSI, &INF, OSINKOP, SUM(POTULOT, -OSINKOP), SUM(MUU_VAH, ASKOROT, ENSASKOROT), 0, SUM(vvevah));
	IF SUM(MUU_VAH, ASKOROT, ENSASKOROT) > 0 THEN DO;
		%AlijHyvS(ALIJHYV, &LVUOSI, &INF, 0, cllkm, POTULOT, MUU_VAH, vkoras, vkorep, 0,0);
	END;
	ELSE ALIJHYV = 0;
	
	/* Erityinen alijäämähyvitys */
	IF SUM(PO_VAHENN, vkoras, vkorep, vvevah) > 0 THEN DO;
		%AlijHyvEritS(ALIJHYVERIT, &LVUOSI, &INF, POTULOT, MUU_VAH, vkoras, vkorep, SUM(vvevah));
	END;
	ELSE ALIJHYVERIT = 0;

	/* Kotitalousvähennys */
	IF SUM(palksiku, palkomos, tyonosuu) > 0 THEN DO;
		%KotitVahErillS(KOTITVAH, &LVUOSI, &INF, palksiku, palkomos, tyonosuu);
	END;
	ELSE KOTITVAH = 0;

	/* Lapsivähennys */
	%ValtVerLapsVahS(LAPSIVAH, &LVUOSI, &INF, YKSINHUOLTAJA, cllkm, SUM(PUHD_ANSIO, PUHD_PO));

	/* Opintolainavähennys suoraan datasta, koska sen simuloiminen ei onnistu nykyisillä tiedoilla */
	OPLAIVAH = vopintov;

	/* Vähennysten jako verolajeittain */

	/* Ansio- / työtulovähennys */

	/* Ennen vuotta 2009 valtionverotuksen ansiotulovähennys vähennetään valtion tuloverosta ja yli menevä osuus otetaan huomioon 
	ennankonpidätyksenä (lopullisten verojen vähennyksenä). Vuodesta 2009 lähtien vähennys vähennetään ensi sijasta valtion 
	tuloverosta ja yli menevä osuus vähennetään muista veroista niiden suhteessa (ei pääomatulon verosta).
	Vähennyksen jakamiseen käytetään samaa kaavaa kuin kotitalousvähennyksen jakamiseen */
	IF &LVUOSI < 2009 THEN DO;
		VALTVEROB = MAX(SUM(VALTVEROA, - VALTANSVAH), 0);
		ANVAHYLIJ = MAX(SUM(VALTANSVAH, - VALTVEROA), 0);
		KUNNVEROB = KUNNVEROA;
		SAIRVAKB = SAIRVAKA;
		KEVB = KEVA;
		KIRKVEROB = KIRKVEROA;
	END;
	ELSE DO;
		IF VALTANSVAH > 0 THEN DO;
		    %VahennJakoS(VALTVEROB, &LVUOSI, VALTANSVAH, 1, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* valt. ans. vero */
			%VahennJakoS(KUNNVEROB, &LVUOSI, VALTANSVAH, 2, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kunnallisvero */
			%VahennJakoS(SAIRVAKB, &LVUOSI, VALTANSVAH, 3, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* svak-maksu */
			%VahennJakoS(KEVB, &LVUOSI, VALTANSVAH, 4, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kev-maksu */
			%VahennJakoS(KIRKVEROB, &LVUOSI, VALTANSVAH, 5, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kirkollisvero */
		END;
		ELSE DO;
			VALTVEROB = VALTVEROA;
			KUNNVEROB = KUNNVEROA;
			SAIRVAKB = SAIRVAKA;
			KEVB = KEVA;
			KIRKVEROB = KIRKVEROA;
		END;
		ANVAHYLIJ = 0;
	END;

	/* Lapsivähennys */
	IF LAPSIVAH > 0 THEN DO;
		%VahennJakoS(VALTVEROC, &LVUOSI, LAPSIVAH, 1, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* valt. ans. vero */
		%VahennJakoS(KUNNVEROC, &LVUOSI, LAPSIVAH, 2, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kunnallisvero */
		%VahennJakoS(SAIRVAKC, &LVUOSI, LAPSIVAH, 3, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* svak-maksu */
		%VahennJakoS(KEVC, &LVUOSI, LAPSIVAH, 4, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kev-maksu */
		%VahennJakoS(KIRKVEROC, &LVUOSI, LAPSIVAH, 5, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kirkollisvero */
		%VahennJakoS(POVEROB, &LVUOSI, LAPSIVAH, 6, VALTVEROB, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* pääomatulo */
	END;
	ELSE DO;
		VALTVEROC = VALTVEROB;
		KUNNVEROC = KUNNVEROB;
		SAIRVAKC = SAIRVAKB;
		KEVC = KEVB;
		KIRKVEROC = KIRKVEROB;
		POVEROB = POVEROA;
	END;

	/* Kotitalousvähennyksen, alijäämähyvityksen ja erityisen alijäämähyvityksen jaot käsitellään erikseen
	puolisottomille ja puolisollisille. Puolisollisille jaot tehdään kotitaloustasolla. */

	/* Tehdään jako puolisottomille henkilötasolla */
	IF VEROPUOL = 0 THEN DO;
		VALTVEROD = MAX(VALTVEROC - INVVAH_V - ELVELV_VAH, 0);

		/* Kotitalousvähennys */
		IF KOTITVAH > 0 THEN DO;
			%VahennJakoS(VALTVEROE, &LVUOSI, KOTITVAH, 1, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* valt. ans. vero */
			%VahennJakoS(KUNNVEROD, &LVUOSI, KOTITVAH, 2, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* kunnallisvero */
			%VahennJakoS(SAIRVAKD, &LVUOSI, KOTITVAH, 3, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* svak-maksu */
			%VahennJakoS(KEVD, &LVUOSI, KOTITVAH, 4, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* kev-maksu */
			%VahennJakoS(KIRKVEROD, &LVUOSI, KOTITVAH, 5, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* kirkollisvero */
			%VahennJakoS(POVEROC, &LVUOSI, KOTITVAH, 6, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC, POVEROB); /* pääomatulo */
		END;
		ELSE DO;
			VALTVEROE = VALTVEROD;
			KUNNVEROD = KUNNVEROC;
			SAIRVAKD = SAIRVAKC;
			KEVD = KEVC;
			KIRKVEROD = KIRKVEROC;
			POVEROC = POVEROB;
		END;

		/* Alijäämähyvityksen jako */
		IF ALIJHYV > 0 THEN DO;
			%AlijHyvJakoS(VALTVEROF, &LVUOSI, 1, ALIJHYV, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD); /* valt. ans. vero */
			%AlijHyvJakoS(KUNNVEROE, &LVUOSI, 2, ALIJHYV, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD); /* kunnallisvero */
			%AlijHyvJakoS(SAIRVAKE, &LVUOSI, 3, ALIJHYV, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD); /* svak-maksu */
			%AlijHyvJakoS(KEVE, &LVUOSI, 4, ALIJHYV, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD); /* kev-maksu */
			%AlijHyvJakoS(KIRKVEROE, &LVUOSI, 5, ALIJHYV, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD); /* kirkollisvero */
		END;
		ELSE DO;
			VALTVEROF = VALTVEROE;
			KUNNVEROE = KUNNVEROD;
			SAIRVAKE = SAIRVAKD;
			KEVE = KEVD;
			KIRKVEROE = KIRKVEROD;
		END;

		/* Erityisen alijäämähyvityksen jako */
		IF ALIJHYVERIT > 0 THEN DO;
			%VahennJakoS(VALTVEROG, &LVUOSI, ALIJHYVERIT, 1, VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, 0); /* valt. ans. vero */
			%VahennJakoS(KUNNVEROF, &LVUOSI, ALIJHYVERIT, 2, VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, 0); /* kunnallisvero */
			%VahennJakoS(SAIRVAKF, &LVUOSI, ALIJHYVERIT, 3, VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, 0); /* svak-maksu */
			%VahennJakoS(KEVF, &LVUOSI, ALIJHYVERIT, 4, VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, 0); /* kev-maksu */
			%VahennJakoS(KIRKVEROF, &LVUOSI, ALIJHYVERIT, 5, VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, 0); /* kirkollisvero */
		END;
		ELSE DO;
			VALTVEROG = VALTVEROF;
			KUNNVEROF = KUNNVEROE;
			SAIRVAKF = SAIRVAKE;
			KEVF = KEVE;
			KIRKVEROF = KIRKVEROE;
		END;
	END;

	/* Puolisoiden tapauksessa nimetään muuttujat uudelleen ja tehdään loppuun kotitaloustasolla */
	IF VEROPUOL = 1 OR VEROPUOL = 2 THEN DO;
		IF  asko = 1 THEN DO;
			INVVAH_V1 = INVVAH_V;
			ELVELV_VAH1 = ELVELV_VAH;
			KOTITVAH1 = KOTITVAH;	
			ALIJHYV1 = ALIJHYV;
			ALIJHYVERIT1 = ALIJHYVERIT;
			VALTVEROC1 = VALTVEROC;
			KUNNVEROC1 = KUNNVEROC;
			SAIRVAKC1 = SAIRVAKC;
			KEVC1 = KEVC;
			KIRKVEROC1 = KIRKVEROC;
			POVEROB1 = POVEROB;
		END;

		IF asko = 2 THEN DO;
			INVVAH_V2 = INVVAH_V;
			ELVELV_VAH2 = ELVELV_VAH;
			KOTITVAH2 = KOTITVAH;	
			ALIJHYV2 = ALIJHYV;
			ALIJHYVERIT2 = ALIJHYVERIT;
			VALTVEROC2 = VALTVEROC;
			KUNNVEROC2 = KUNNVEROC;
			SAIRVAKC2 = SAIRVAKC;
			KEVC2 = KEVC;
			KIRKVEROC2 = KIRKVEROC;
			POVEROB2 = POVEROB;
		END;
	END;

	/* Tässä kohtaa pudotetaan pois sellaiset apumuuttujat, joita ei jatkossa tarvita */
	DROP PSOTX YRITTAJA VAHLAPSIA ALIJENIMM ELAKELISAVERO;
	RUN;

	
	/* Puolisoiden tietoja, aputaulu */

	DATA TEMP.VERO_PUOLISOT;
	SET TEMP.&TULOSNIMI_VE (keep = hnro knro VEROPUOL
		INVVAH_V1 ELVELV_VAH1 KOTITVAH1 ALIJHYV1 ALIJHYVERIT1 VALTVEROC1 VALTVEROC1 
		KUNNVEROC1 SAIRVAKC1 KEVC1 KIRKVEROC1 POVEROB1 INVVAH_V2 ELVELV_VAH2 KOTITVAH2 
		ALIJHYV2 ALIJHYVERIT2 VALTVEROC2 VALTVEROC2 KUNNVEROC2 SAIRVAKC2 KEVC2 KIRKVEROC2 POVEROB2); 
	IF VEROPUOL = 1 OR VEROPUOL = 2;
	RUN;

	PROC MEANS DATA = TEMP.VERO_PUOLISOT SUM NOPRINT;
	VAR INVVAH_V1 ELVELV_VAH1 KOTITVAH1 ALIJHYV1 ALIJHYVERIT1 VALTVEROC1 KUNNVEROC1 SAIRVAKC1 KEVC1 KIRKVEROC1 POVEROB1 INVVAH_V2 
		ELVELV_VAH2 KOTITVAH2 ALIJHYV2 ALIJHYVERIT2 VALTVEROC2 KUNNVEROC2 SAIRVAKC2 KEVC2 KIRKVEROC2 POVEROB2;
	BY KNRO;
	OUTPUT OUT = TEMP.VERO_PUOLISOT_SUM
	SUM(INVVAH_V1 )=INVVAH_V1 SUM(ELVELV_VAH1 )=ELVELV_VAH1 SUM(KOTITVAH1 )=KOTITVAH1 SUM(ALIJHYV1 )=ALIJHYV1 SUM(ALIJHYVERIT1 )=ALIJHYVERIT1 
	SUM(VALTVEROC1 )=VALTVEROC1 SUM(KUNNVEROC1 )=KUNNVEROC1 SUM(SAIRVAKC1 )=SAIRVAKC1 SUM(KEVC1)=KEVC1 SUM(KIRKVEROC1 )=KIRKVEROC1 
	SUM(POVEROB1)=POVEROB1 SUM(INVVAH_V2)=INVVAH_V2 SUM(ELVELV_VAH2)=ELVELV_VAH2 SUM(KOTITVAH2)=KOTITVAH2 SUM(ALIJHYV2)=ALIJHYV2 
	SUM(ALIJHYVERIT2)=ALIJHYVERIT2 SUM(VALTVEROC2)=VALTVEROC2 SUM(KUNNVEROC2)=KUNNVEROC2 SUM(SAIRVAKC2)=SAIRVAKC2 SUM(KEVC2)=KEVC2 
	SUM(KIRKVEROC2)=KIRKVEROC2 SUM(POVEROB2)=POVEROB2;
	RUN;

	/* Puolisoiden vähennysten jako, kuten henkilöillä */

	DATA TEMP.VERO_PUOLISOT_SUM;
	SET TEMP.VERO_PUOLISOT_SUM;

	%VahennysSwap(INVVAH_V, VALTVEROC);
	VALTVEROD1 = MAX(SUM(VALTVEROC1, -INVVAH_V1FINAL, -ELVELV_VAH1), 0);
	VALTVEROD2 = MAX(SUM(VALTVEROC2, -INVVAH_V2FINAL, -ELVELV_VAH2), 0);
	VEROTYHT1 = SUM(VALTVEROD1 ,  KUNNVEROC1 ,  SAIRVAKC1 ,  KEVC1 ,  KIRKVEROC1 ,  POVEROB1);
	VEROTYHT2 = SUM(VALTVEROD2 ,  KUNNVEROC2 ,  SAIRVAKC2 ,  KEVC2 ,  KIRKVEROC2 ,  POVEROB2);
	%VahennysSwap(KOTITVAH, VEROTYHT);

	IF KOTITVAH1FINAL > 0 THEN DO;
		%VahennJakoS(VALTVEROE1, &LVUOSI, KOTITVAH1FINAL, 1, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
		%VahennJakoS(KUNNVEROD1, &LVUOSI, KOTITVAH1FINAL, 2, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
		%VahennJakoS(SAIRVAKD1, &LVUOSI, KOTITVAH1FINAL, 3, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
		%VahennJakoS(KEVD1, &LVUOSI, KOTITVAH1FINAL, 4, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
		%VahennJakoS(KIRKVEROD1, &LVUOSI, KOTITVAH1FINAL, 5, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
		%VahennJakoS(POVEROC1, &LVUOSI, KOTITVAH1FINAL, 6, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1, POVEROB1);
	END;
	ELSE DO;
		VALTVEROE1 = VALTVEROD1;
		KUNNVEROD1 = KUNNVEROC1;
		SAIRVAKD1 = SAIRVAKC1;
		KEVD1 = KEVC1;
		KIRKVEROD1 = KIRKVEROC1;
		POVEROC1 = POVEROB1;
	END;

	IF KOTITVAH2FINAL > 0 THEN DO;
		%VahennJakoS(VALTVEROE2, &LVUOSI, KOTITVAH2FINAL, 1, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
		%VahennJakoS(KUNNVEROD2, &LVUOSI, KOTITVAH2FINAL, 2, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
		%VahennJakoS(SAIRVAKD2, &LVUOSI, KOTITVAH2FINAL, 3, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
		%VahennJakoS(KEVD2, &LVUOSI, KOTITVAH2FINAL, 4, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
		%VahennJakoS(KIRKVEROD2, &LVUOSI, KOTITVAH2FINAL, 5, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
		%VahennJakoS(POVEROC2, &LVUOSI, KOTITVAH2FINAL, 6, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2, POVEROB2);
	END;
	ELSE DO;
		VALTVEROE2 = VALTVEROD2;
		KUNNVEROD2 = KUNNVEROC2;
		SAIRVAKD2 = SAIRVAKC2;
		KEVD2 = KEVC2;
		KIRKVEROD2 = KIRKVEROC2;
		POVEROC2 = POVEROB2;
	END;

	VEROTYHT1 = SUM(VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
	VEROTYHT2 = SUM(VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
	%VahennysSwap(ALIJHYV, VEROTYHT);

	IF ALIJHYV1FINAL > 0 THEN DO;
		%AlijHyvJakoS(VALTVEROF1, &LVUOSI, 1, ALIJHYV1FINAL, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
		%AlijHyvJakoS(KUNNVEROE1, &LVUOSI, 2, ALIJHYV1FINAL, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
		%AlijHyvJakoS(SAIRVAKE1, &LVUOSI, 3, ALIJHYV1FINAL, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
		%AlijHyvJakoS(KEVE1, &LVUOSI, 4, ALIJHYV1FINAL, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
		%AlijHyvJakoS(KIRKVEROE1, &LVUOSI, 5, ALIJHYV1FINAL, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
	END;
	ELSE DO;
		VALTVEROF1 = VALTVEROE1;
		KUNNVEROE1 = KUNNVEROD1;
		SAIRVAKE1 = SAIRVAKD1;
		KEVE1 = KEVD1;
		KIRKVEROE1 = KIRKVEROD1;
	END;

	IF ALIJHYV2FINAL > 0 THEN DO;
		%AlijHyvJakoS(VALTVEROF2, &LVUOSI, 1, ALIJHYV2FINAL, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
		%AlijHyvJakoS(KUNNVEROE2, &LVUOSI, 2, ALIJHYV2FINAL, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
		%AlijHyvJakoS(SAIRVAKE2, &LVUOSI, 3, ALIJHYV2FINAL, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
		%AlijHyvJakoS(KEVE2, &LVUOSI, 4, ALIJHYV2FINAL, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
		%AlijHyvJakoS(KIRKVEROE2, &LVUOSI, 5, ALIJHYV2FINAL, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
	END;
	ELSE DO;
		VALTVEROF2 = VALTVEROE2;
		KUNNVEROE2 = KUNNVEROD2;
		SAIRVAKE2 = SAIRVAKD2;
		KEVE2 = KEVD2;
		KIRKVEROE2 = KIRKVEROD2;
	END;

	VEROTYHT1 = SUM(VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1);
	VEROTYHT2 = SUM(VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2);
	%VahennysSwap(ALIJHYVERIT, VEROTYHT);

	IF ALIJHYVERIT1FINAL > 0 THEN DO;
		%VahennJakoS(VALTVEROG1, &LVUOSI, ALIJHYVERIT1FINAL, 1, VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1, 0);
		%VahennJakoS(KUNNVEROF1, &LVUOSI, ALIJHYVERIT1FINAL, 2, VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1, 0);
		%VahennJakoS(SAIRVAKF1, &LVUOSI, ALIJHYVERIT1FINAL, 3, VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1, 0);
		%VahennJakoS(KEVF1, &LVUOSI, ALIJHYVERIT1FINAL, 4, VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1, 0);
		%VahennJakoS(KIRKVEROF1, &LVUOSI, ALIJHYVERIT1FINAL, 5, VALTVEROF1, KUNNVEROE1, SAIRVAKE1, KEVE1, KIRKVEROE1, 0);
	END;
	ELSE DO;
		VALTVEROG1 = VALTVEROF1;
		KUNNVEROF1 = KUNNVEROE1;
		SAIRVAKF1 = SAIRVAKE1;
		KEVF1 = KEVE1;
		KIRKVEROF1 = KIRKVEROE1;
	END;

	IF  ALIJHYVERIT2FINAL > 0 THEN DO;
		%VahennJakoS(VALTVEROG2, &LVUOSI, ALIJHYVERIT2FINAL, 1, VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2, 0);
		%VahennJakoS(KUNNVEROF2, &LVUOSI, ALIJHYVERIT2FINAL, 2, VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2, 0);
		%VahennJakoS(SAIRVAKF2, &LVUOSI, ALIJHYVERIT2FINAL, 3, VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2, 0);
		%VahennJakoS(KEVF2, &LVUOSI, ALIJHYVERIT2FINAL, 4, VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2, 0);
		%VahennJakoS(KIRKVEROF2, &LVUOSI, ALIJHYVERIT2FINAL, 5, VALTVEROF2, KUNNVEROE2, SAIRVAKE2, KEVE2, KIRKVEROE2, 0);
	END;
	ELSE DO;
		VALTVEROG2 = VALTVEROF2;
		KUNNVEROF2 = KUNNVEROE2;
		SAIRVAKF2 = SAIRVAKE2;
		KEVF2 = KEVE2;
		KIRKVEROF2 = KIRKVEROE2;
	END;

	RUN;

	/* Yhdistetään puolisoille kotitaloustasolla loppuun lasketut tiedot henkilöille */
	DATA TEMP.&TULOSNIMI_VE;
	MERGE TEMP.&TULOSNIMI_VE TEMP.VERO_PUOLISOT_SUM (KEEP = knro
	VALTVEROG1 KUNNVEROF1 SAIRVAKF1 KEVF1 KIRKVEROF1 POVEROC1
	VALTVEROG2 KUNNVEROF2 SAIRVAKF2 KEVF2 KIRKVEROF2 POVEROC2
	INVVAH_V1FINAL INVVAH_V2FINAL ALIJHYVERIT1FINAL ALIJHYVERIT2FINAL
	ALIJHYV1FINAL ALIJHYV2FINAL KOTITVAH1FINAL KOTITVAH2FINAL);
	BY knro;

	IF VEROPUOL = 1 THEN DO;
		VALTVEROG = VALTVEROG1;
		KUNNVEROF = KUNNVEROF1;
		SAIRVAKF = SAIRVAKF1;
		KEVF = KEVF1;
		KIRKVEROF = KIRKVEROF1;
		POVEROC = POVEROC1;
		INVVAH_V = INVVAH_V1FINAL;
		ALIJHYV = ALIJHYV1FINAL;
		ALIJHYVERIT = ALIJHYVERIT1FINAL;
		KOTITVAH = KOTITVAH1FINAL;
	END;

	IF VEROPUOL = 2 THEN DO;
		VALTVEROG = VALTVEROG2;
		KUNNVEROF = KUNNVEROF2;
		SAIRVAKF = SAIRVAKF2;
		KEVF = KEVF2;
		KIRKVEROF = KIRKVEROF2;
		POVEROC = POVEROC2;
		INVVAH_V = INVVAH_V2FINAL;
		ALIJHYV = ALIJHYV2FINAL;
		ALIJHYVERIT = ALIJHYVERIT2FINAL;
		KOTITVAH = KOTITVAH2FINAL;
	END;

	DROP VALTVEROG1 KUNNVEROF1 SAIRVAKF1 KEVF1 KIRKVEROF1 POVEROC1 VALTVEROG2 KUNNVEROF2 SAIRVAKF2 KEVF2 KIRKVEROF2 POVEROC2;

	/* Opintolainavähennyksen jako */
	IF OPLAIVAH > 0 THEN DO;
		%VahennJakoS(VALTVEROH, &LVUOSI, OPLAIVAH, 1, VALTVEROG, KUNNVEROF, SAIRVAKF, KEVF, KIRKVEROF, 0); /* valt. ans. vero */
		%VahennJakoS(KUNNVEROG, &LVUOSI, OPLAIVAH, 2, VALTVEROG, KUNNVEROF, SAIRVAKF, KEVF, KIRKVEROF, 0); /* kunnallisvero */
		%VahennJakoS(SAIRVAKG, &LVUOSI, OPLAIVAH, 3, VALTVEROG, KUNNVEROF, SAIRVAKF, KEVF, KIRKVEROF, 0); /* svak-maksu */
		%VahennJakoS(KEVG, &LVUOSI, OPLAIVAH, 4, VALTVEROG, KUNNVEROF, SAIRVAKF, KEVF, KIRKVEROF, 0); /* kev-maksu */
		%VahennJakoS(KIRKVEROG, &LVUOSI, OPLAIVAH, 5, VALTVEROG, KUNNVEROF, SAIRVAKF, KEVF, KIRKVEROF, 0); /* kirkollisvero */
	END;
	ELSE DO;
		VALTVEROH = VALTVEROG;
		KUNNVEROG = KUNNVEROF;
		SAIRVAKG = SAIRVAKF;
		KEVG = KEVF;
		KIRKVEROG = KIRKVEROF;
	END;

	/* Yle-vero */
	%YleVeroS(YLEVERO, &LVUOSI, &INF, ikavu, SUM(PUHD_ANSIO, PUHD_PO), maakunta); 

	/* Yhtiöveron hyvitys yhteensä */
	YHTHYV = SUM(YHTHYVA, YHTHYVP);

	/* Korjataan veroja niille, joilla ulkomaantuloihin on käytetty vapautusmenetelmää */

	VALTVEROH = (1 - ULK_OSUUS)* VALTVEROH;
	KUNNVEROG = (1 - ULK_OSUUS)* KUNNVEROG;
	KIRKVEROG = (1 - ULK_OSUUS)* KIRKVEROG;

	/* Jyvitetään seuraavaksi ulkomaan verojen vähennys eri verolajeihin
	muiden kuin edellisessä kohdassa käsiteltyjen henkilöiden tapauksessa */

	ULKVAH = IFN(ULK_OSUUS NG 0, lveru, 0);

	IF ULKVAH > 0 THEN DO;
		/* Jos henkilö on saanut ulkomaantulona vain palkkaa tai eläkettä,
		vähennetään ulkomaan verot valtion ansiotuloverosta sekä kunnallis-
		ja kirkollisveroista näiden suhteessa */
		IF (tulkp > 0 or tulkelvp > 0) and tulkyhp = 0 THEN DO; 
			JAKAJA = SUM(VALTVEROH, KUNNVEROG, KIRKVEROG);
			IF JAKAJA > 0 THEN DO;
				VALTVEROH = MAX(SUM(VALTVEROH, -ULKVAH * VALTVEROH / JAKAJA), 0);
				KUNNVEROG = MAX(SUM(KUNNVEROG, -ULKVAH * KUNNVEROG / JAKAJA), 0);
				KIRKVEROG = MAX(SUM(KIRKVEROG, -ULKVAH * KIRKVEROG / JAKAJA), 0);
			END;
		END;
		/* Jos henkilö on saanut ulkomaantulona vain pääomatuloja,
		vähennetään ulkomaan verot pääomatuloverosta */
		ELSE IF tulkyhp > 0 and tulkp = 0 and tulkelvp = 0 THEN DO;
				POVEROC = MAX(SUM(POVEROC, -ULKVAH), 0);
		END;
		/* Muussa tapauksessa jyvitetään ulkomaan verot kaikkien neljän
		verolajin kesken näiden suhteessa */
		ELSE DO;
			JAKAJA = SUM(VALTVEROH, KUNNVEROG, KIRKVEROG, POVEROC);
			IF JAKAJA > 0 THEN DO;
				VALTVEROH = MAX(SUM(VALTVEROH, -ULKVAH * VALTVEROH / JAKAJA), 0);
				KUNNVEROG = MAX(SUM(KUNNVEROG, -ULKVAH * KUNNVEROG / JAKAJA), 0);
				KIRKVEROG = MAX(SUM(KIRKVEROG, -ULKVAH * KIRKVEROG / JAKAJA), 0);
				POVEROC = MAX(SUM(POVEROC, -ULKVAH * POVEROC / JAKAJA), 0);
			END;
		END;
	END;

	MAKSP_VEROT = SUM(PRAHAMAKSU,  MAX(SUM(VALTVEROH, POVEROC, KUNNVEROG, SAIRVAKG, KEVG, KIRKVEROG, YLEVERO), 0));
	KAIKKIVEROT = SUM(PALKVAK, MAKSP_VEROT, -ANVAHYLIJ, -YHTHYV);
	ANSIOVEROT = SUM(VALTVEROH, KUNNVEROG, SAIRVAKG, KEVG, KIRKVEROG, -ANVAHYLIJ);

	KEEP hnro OSINKOP1 OSINKOP2 OSINKOP3 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4
		 PRAHAT OSINKOP OSINKOA OSINKOVAP PSOT ULKPALKKA ULKVAH OSINKOA_DATA OSINKOVAP_DATA OSINKOP_DATA
		 PALKKA1 MUU_TYO YRITYSTA YRITYSTP VAKPALK MUUT_EL MUU_ANSIO MUU_PO VUOKRAT
		 THANKK MUU_VAH_VALT2 MUU_VAH_KUNN2 POTAPP ULK_OSUUS
		 OPTUKI_SIMUL SAIRVAK_SIMUL KOTIHTUKI_SIMUL TTURVA_SIMUL KANSEL_SIMUL ELAKE
		 PRAHAMAKSUTULO VKERROIN ANSIOT POTULOT KOKONTULO THANKKULUT2 PO_VAHENN 
		 PUHD_ANSIO PUHD_PO KOTITVAH_DATA ANSIOT_VAH ELTULVAH_K
		 ELTULVAH_V OPRAHVAH INVVAH_K PALKVAK PRAHAMAKSU KUNNVTULO1 PERVAH
		 KUNNVTULO2 KUNNVEROA KUNNVEROB KUNNVEROC KUNNVEROD KUNNVEROE KUNNVEROF KUNNVEROG 
		 KIRKVEROA KIRKVEROB KIRKVEROC KIRKVEROD KIRKVEROE KIRKVEROF KIRKVEROG SAIRVAKA SAIRVAKB SAIRVAKC
		 SAIRVAKD SAIRVAKE SAIRVAKF SAIRVAKG KEVA KEVB KEVC KEVD KEVE KEVF KEVG VALTVERTULO YHTHYVA YHTHYVP YHTHYV
		 VALTVEROA VALTVEROB VALTVEROC VALTVEROD VALTVEROE VALTVEROF VALTVEROG VALTVEROH VALTANSVAH
		 INVVAH_V ELVELV_VAH POVEROA POVEROB POVEROC ALIJHYV ALIJHYVERIT 
		 KOTITVAH ANSIOVEROT KAIKKIVEROT KAIKKIVEROT_DATA MAKSP_VEROT YLEVERO 
		 ASKOROT ENSASKOROT MUU_VAH LAPSIVAH MERIVAHKUN MERIVAHVAL YRVAHA YRVAHP;

	/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan */

	ARRAY PISTE
		 OSINKOP1 OSINKOP2 OSINKOP3 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4
		 PRAHAT OSINKOP OSINKOA OSINKOVAP PSOT ULKPALKKA ULKVAH OSINKOA_DATA OSINKOVAP_DATA OSINKOP_DATA
		 PALKKA1 MUU_TYO YRITYSTA YRITYSTP VAKPALK MUUT_EL MUU_ANSIO MUU_PO VUOKRAT
		 THANKK MUU_VAH_VALT2 MUU_VAH_KUNN2 POTAPP ULK_OSUUS
		 OPTUKI_SIMUL SAIRVAK_SIMUL KOTIHTUKI_SIMUL TTURVA_SIMUL KANSEL_SIMUL ELAKE
		 PRAHAMAKSUTULO VKERROIN ANSIOT POTULOT KOKONTULO THANKKULUT2 PO_VAHENN 
		 PUHD_ANSIO PUHD_PO KOTITVAH_DATA ANSIOT_VAH ELTULVAH_K
		 ELTULVAH_V OPRAHVAH INVVAH_K PALKVAK PRAHAMAKSU KUNNVTULO1 PERVAH
		 KUNNVTULO2 KUNNVEROA KUNNVEROB KUNNVEROC KUNNVEROD KUNNVEROE KUNNVEROF KUNNVEROG
		 KIRKVEROA KIRKVEROB KIRKVEROC KIRKVEROD KIRKVEROE KIRKVEROF KIRKVEROG SAIRVAKA SAIRVAKB
		 SAIRVAKC SAIRVAKD SAIRVAKE SAIRVAKF SAIRVAKG KEVA KEVB KEVC KEVD KEVE KEVF KEVG VALTVERTULO YHTHYVA
		 YHTHYVP YHTHYV VALTVEROA VALTVEROB VALTVEROC VALTVEROD VALTVEROE VALTVEROF VALTVEROG VALTVEROH
		 VALTANSVAH INVVAH_V ELVELV_VAH POVEROA POVEROB POVEROC ALIJHYV ALIJHYVERIT LAPSIVAH
		 KOTITVAH ANSIOVEROT KAIKKIVEROT KAIKKIVEROT_DATA MAKSP_VEROT YLEVERO
		 ASKOROT ENSASKOROT MUU_VAH MERIVAHKUN MERIVAHVAL YRVAHA YRVAHP;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	/* Luodaan simuloiduille muuttujille selitteet */

	LABEL
	YRVAHA = 'Yrittäjävähennys ansiotulosta, MALLI'
	YRVAHP = 'Yrittäjävähennys pääomatulosta, MALLI'
	PO_VAHENN = 'Vähennykset pääomatuloista, DATA'
	PRAHAT = 'Sosiaaliturvan päivärahat yhteensä, MALLI'
	SAIRVAK_SIMUL = 'Sairausvakuutuslain mukaiset päivärahat yhteensä, MALLI'
	KOTIHTUKI_SIMUL = 'Lasten kotihoidon tuki, MALLI'
	OPTUKI_SIMUL = 'Opintorahat, MALLI'
	TTURVA_SIMUL = 'Työttömyysturva ja koulutustuki, MALLI'
	KANSEL_SIMUL = 'Kansaneläke (ml. KE:n perhe-eläke), MALLI'
	ELAKE = 'Eläketulot yhteensä, MALLI'
	OSINKOP = 'Osingot pääomatulona, MALLI'
	OSINKOP1 = 'Osingot pääomatulona: ulkomaan osingot ja julkisesti noteeratut osakkeet, MALLI'
	OSINKOP2 = 'Osingot pääomatulona: osuuspääoman korot, MALLI'
	OSINKOP3 = 'Osingot pääomatulona: henkilöyhtiöt, MALLI'
	OSINKOA = 'Osingot ansiotulona, MALLI'
	OSINKOVAP = 'Verovapaat osingot, MALLI'
	OSINKOVAP1 = 'Verovapaat osingot: ulkomaan osingot ja listatut yhtiöt, MALLI'
	OSINKOVAP2 = 'Verovapaat osingot: osuuspääoman korko, MALLI'
	OSINKOVAP3 = 'Verovapaat osingot: listaamaattomat yhtiöt (pääomatulo), MALLI'
	OSINKOVAP4 = 'Verovapaat osingot: listaamattomat yhtiöt (ansiotulo), MALLI'
	ANSIOT = 'Ansiotulot yhteensä (yrittäjävähennystä ei ole tehty), MALLI'
	POTULOT = 'Pääomatulot yhteensä (yrittäjävähennystä ei ole tehty), MALLI'
	KOKONTULO = 'Kokonaistulot (yrittäjävähennystä ei ole tehty), MALLI'
	THANKKULUT2 = 'Tulonhankkimiskulut, MALLI'
	PUHD_ANSIO = 'Puhdas ansiotulo, MALLI'
	PUHD_PO = 'Puhdas pääomatulo, MALLI'
	ANSIOT_VAH = 'Kunnallisverotuksen ansiotulovähennys, MALLI'
	ELTULVAH_K = 'Kunnallisverotuksen eläketulovähennys, MALLI'
	ELTULVAH_V = 'Eläketulovähennys valtionverotuksessa, MALLI'
	OPRAHVAH = 'Opintorahavähennys, MALLI'
	INVVAH_K = 'Kunnallisverotuksen invalidivähennys, MALLI'
	MERIVAHKUN = 'Kunnallisverotuksen merityötulovähennys, MALLI'
	PALKVAK = 'Palkansaajan eläke- ja työttömyysvakuutusmaksut yhteensä, MALLI'
	PRAHAMAKSU = 'Sairausvakuutuksen päivärahamaksu, MALLI'
	KUNNVTULO1 = 'Kunnallisverotuksessa verotettava tulo ennen perusvähennystä, MALLI'
	PERVAH = 'Kunnallisverotuksen perusvähennys, MALLI'
	KUNNVTULO2 = 'Kunnallisverotuksessa verotettava tulo perusvähennyksen jälkeen, MALLI'
	KUNNVEROA = 'Kunnallisvero, vaihe 1: ennen vähennyksiä, MALLI'
	KUNNVEROB = 'Kunnallisvero, vaihe 2: työ-/ansiotulovähennyksen jälkeen, MALLI'
	KUNNVEROC = 'Kunnallisvero, vaihe 3: lapsivähennyksen jälkeen, MALLI'
	KUNNVEROD = 'Kunnallisvero, vaihe 4: kotitalousvähennyksen jälkeen, MALLI'
	KUNNVEROE = 'Kunnallisvero, vaihe 5: alijäämähyvityksen jälkeen, MALLI'
	KUNNVEROF = 'Kunnallisvero, vaihe 6: erityisen alijäämähyvityksen jälkeen, MALLI'
	KUNNVEROG = 'Kunnallisverot, MALLI'
	KIRKVEROA = 'Kirkollisvero, vaihe 1: ennen vähennyksiä, MALLI'
	KIRKVEROB = 'Kirkollisvero, vaihe 2: työ-/ansiotulovähennyksen jälkeen, MALLI'
	KIRKVEROC = 'Kirkollisvero, vaihe 3: lapsivähennyksen jälkeen, MALLI'
	KIRKVEROD = 'Kirkollisvero, vaihe 4: kotitalousvähennyksen jälkeen, MALLI'
	KIRKVEROE = 'Kirkollisvero, vaihe 5: alijäämähyvityksen jälkeen, MALLI'
	KIRKVEROF = 'Kirkollisvero, vaihe 6: erityisen alijäämähyvityksen jälkeen, MALLI'
	KIRKVEROG = 'Kirkollisverot, MALLI'
	SAIRVAKA = 'Sairaanhoitomaksu, vaihe 1: ennen vähennyksiä, MALLI'
	SAIRVAKB = 'Sairaanhoitomaksu, vaihe 2: työ-/ansiotulovähennyksen jälkeen, MALLI'
	SAIRVAKC = 'Sairaanhoitomaksu, vaihe 3: lapsivähennyksen jälkeen, MALLI'
	SAIRVAKD = 'Sairaanhoitomaksu, vaihe 4: kotitalousvähennyksen jälkeen, MALLI'
	SAIRVAKE = 'Sairaanhoitomaksu, vaihe 5: alijäämähyvityksen jälkeen, MALLI'
	SAIRVAKF = 'Sairaanhoitomaksu, vaihe 6: erityisen alijäämähyvityksen jälkeen, MALLI'
	SAIRVAKG = 'Sairaanhoitomaksut, MALLI'
	KEVA = 'Kansaneläkevakuutusmaksu, vaihe 1: ennen vähennyksiä, MALLI'
	KEVB = 'Kansaneläkevakuutusmaksu, vaihe 2: työ-/ansiotulovähennyksen jälkeen, MALLI'
	KEVC = 'Kansaneläkevakuutusmaksu, vaihe 3: lapsivähennyksen jälkeen, MALLI'
	KEVD = 'Kansaneläkevakuutusmaksu, vaihe 4: kotitalousvähennyksen jälkeen, MALLI'
	KEVE = 'Kansaneläkevakuutusmaksu, vaihe 5: alijäämähyvityksen jälkeen, MALLI'
	KEVF = 'Kansaneläkevakuutusmaksu, vaihe 6: erityisen alijäämähyvityksen jälkeen, MALLI'
	KEVG = 'Kansaneläkevakuutusmaksut, MALLI'
	VALTVERTULO = 'Valtionverotuksessa verotettava tulo, MALLI'
	YHTHYVA = 'Yhtiöveron hyvitys ansiotuloa, MALLI'
	YHTHYVP = 'Yhtiöveron hyvitys pääomatuloa, MALLI'
	YHTHYV = 'Yhtiöveron hyvitys yhteensä, MALLI'
	VALTVEROA = 'Valtion tulovero, vaihe 1: ennen vähennyksiä, MALLI'
	VALTVEROB = 'Valtion tulovero, vaihe 2: työ-/ansiotulovähennyksen jälkeen, MALLI'
	VALTVEROC = 'Valtion tulovero, vaihe 3: lapsivähennys, MALLI'
	VALTVEROD = 'Valtion tulovero, vaihe 4: invalidi-/elatusvelvollisuusvähennyksen jälkeen, MALLI'
	VALTVEROE = 'Valtion tulovero, vaihe 5: kotitalousvähennyksen jälkeen, MALLI'
	VALTVEROF = 'Valtion tulovero, vaihe 6: alijäämähyvityksen jälkeen, MALLI'
	VALTVEROG = 'Valtion tulovero, vaihe 7: erityisen alijäämähyvityksen jälkeen, MALLI'
	VALTVEROH = 'Valtion tuloverot, MALLI'
	VALTANSVAH = 'Valtionverotuksen ansiotulovähennys, MALLI'
	INVVAH_V = 'Valtionverotuksen invalidivähennys, MALLI'
	MERIVAHVAL = 'Valtionverotuksen merityötulovähennys, MALLI'
	ELVELV_VAH = 'Valtionverotuksen elatusvelvollisuusvähennys, MALLI'
	POVEROA = 'Pääomatulon vero, vaihe 1: ennen vähennyksiä, MALLI'
	POVEROB = 'Pääomatulon vero, vaihe 2: lapsivähennyksen jälkeen, MALLI'
	POVEROC = 'Pääomatulon verot, MALLI'
	ASKOROT = 'Asuntolainan korot, vähennyskelpoinen osuus, MALLI'
	ENSASKOROT = 'Ensiasuntoon kohdistuvan asuntolainan korot, vähennyskelpoinen osuus, MALLI'
	MUU_VAH = 'Muut vähennykset pääomatuloista, MALLI'
	ALIJHYV = 'Alijäämähyvitys, MALLI'
	ALIJHYVERIT = 'Erityinen alijäämähyvitys, MALLI'
	KOTITVAH = 'Kotitalousvähennys, MALLI'
	LAPSIVAH = 'Lapsivähennys, MALLI'
	ULKVAH = 'Ulkomaan tulojen verovähennys, MALLI'
	ANSIOVEROT = 'Ansiotulon verot yhteensä (sis. sairaanhoitomaksut ja kansaneläkevakuutusmaksut), MALLI'
	YLEVERO = 'Yle-vero, MALLI'
	KAIKKIVEROT = 'Kaikki verot ja maksut yhteensä, MALLI'
	KAIKKIVEROT_DATA = 'Kaikki verot ja maksut yhteensä, DATA'
	MAKSP_VEROT = 'Maksuunpannut verot, MALLI';

	RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* Tätä vaihetta ei ajeta mikäli osamallia käytetään KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistetään tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_VE;

		/* Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

		%IF &TULOSLAAJ = 1 %THEN %DO;
			MERGE POHJADAT.&AINEISTO&AVUOSI 
			(KEEP = hnro knro &PAINO ltva ltvp lkuve lkive lshma lelvak lpvma verot svatvap 
			svatpp ikavu ikavuv soss paasoss desmod koulas koulasv elivtu rake maakunta lylen)
			TEMP.&TULOSNIMI_VE;
		%END;

		/* Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

		%IF &TULOSLAAJ = 2 %THEN %DO;
			MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_VE;
		%END;

		* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

		ARRAY PISTE ltva ltvp lkuve lkive lshma lelvak lpvma verot svatvap svatpp lylen ;
		DO OVER PISTE;
			IF PISTE <= 0 THEN PISTE = .;
		END;

		* Luodaan datan muuttujille selitteet ;

		LABEL
		svatvap = 'Puhdas ansiotulo, DATA'
		svatpp = 'Puhdas pääomatulo, DATA'
		lelvak = 'Palkansaajan eläke- ja työttömyysvakuutusmaksut yhteensä, DATA'
		lpvma = 'Sairausvakuutuksen päivärahamaksu, DATA'
		lkuve = 'Kunnallisverot, DATA'
		lkive = 'Kirkollisverot, DATA'
		lshma = 'Sairaanhoitomaksut, DATA'
		ltva = 'Valtion tuloverot, DATA'
		ltvp = 'Pääomatulon verot, DATA'
		lylen = 'Yle-vero, DATA'
		verot = 'Maksuunpannut verot, DATA';
		BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_VE._KOTI, TEMP.&TULOSNIMI_VE, &MALLI, &MUUTTUJAT);

		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_VE;
		RUN;
		QUIT;
	%END;

	/* Jos käyttäjä määritellyt YKSIKKO=1 (henkilötaso) tai YKSIKKO on mitä tahansa muuta kuin 2 (kotitaloustaso)
		niin jätetään tulostaulu henkilötasolle ja nimetään se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_VE._HLO;
			CHANGE &TULOSNIMI_VE=&TULOSNIMI_VE._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_VE._HLO;
		RUN;
		QUIT;
	%END;

	/* Tyhjennetään TEMP-kirjasto */

	%IF &TEMPTYHJ = 1 %THEN %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST KILL;
		RUN;
		QUIT;
	%END;

%END;

%MEND;

%Vero_Simuloi_data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 6. Tulostetaan käyttäjän pyytämät taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_VE._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_VE._KOTI,2);
	%END;
	
	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND;
%KutsuTulokset;


/* 7. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));

%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;