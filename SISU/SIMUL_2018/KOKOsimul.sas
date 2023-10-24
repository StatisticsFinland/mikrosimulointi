/****************************************************
* KOKO-mallin simulointiohjelma 2018          		*
* Viimeksi päivitetty: 29.5.2020 			  		*
****************************************************/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */
%TuhoaGlobaalit;

%LET alkoi1KOKO = %SYSFUNC(TIME());

* Antamalla OUT-makromuuttujalle arvo 1, varmistetaan, että osamallit ottavat ohjausparametrit tästä KOKO-mallista.
  Asetetaan &TULOSLAAJ-makromuuttuja arvoon 1, jotta osamallien tulostaulukoiden koko olisi mahd. pieni;

%LET OUT = 1;
%LET TULOSLAAJ = 1;

* Osamallien simuloitujen tulostiedostojen nimet (luodaan vain väliaikaistiedostoiksi TEMP-kansioon);

%LET TULOSNIMI_SV = SV_TULOS;
%LET TULOSNIMI_KT = KT_TULOS;
%LET TULOSNIMI_TT = TT_TULOS;
%LET TULOSNIMI_LL = LL_TULOS;
%LET TULOSNIMI_TO = TO_TULOS;
%LET TULOSNIMI_KE = KE_TULOS;
%LET TULOSNIMI_VE = VE_TULOS;
%LET TULOSNIMI_KV = KV_TULOS;
%LET TULOSNIMI_YA = YA_TULOS;
%LET TULOSNIMI_EA = EA_TULOS;
%LET TULOSNIMI_OT = OT_TULOS;
%LET TULOSNIMI_PH = PH_TULOS;

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Seuraavia vaiheita ei ajeta jos arvot annetaan tämän koodin ulkopuolelta (&EG = 1) */

%IF &EG NE 1 %THEN %DO;

%LET AVUOSI = 2018;		* Aineistovuosi (vvvv);

%LET LVUOSI = 2018;		* Lainsäädäntövuosi (vvvv);
						* HUOM! Jos käytät vuotta 2017 ja ASUMTUKI-mallia;
						* valitse TYYPPI_KOKO = SIMULX ja haluamasi lainsäädäntökuukausi;

%LET TYYPPI_KOKO = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

%LET LKUUK = 12;		* Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

%LET AINEISTO = REK;	* Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

%LET TULOSNIMI_KOKO = koko_simul_&SYSDATE._1; * Simuloidun tulostiedoston nimi;

* Inflaatiokorjaus. Euro- tai markkamääräisten parametrien haun yhteydessä suoritettavassa
  deflatoinnissa käytettävän kertoimen voi syöttää itse INF-makromuuttujaan
  (HUOM! desimaalit erotettava pisteellä .). Esim. jos yksi lainsäädäntövuoden euro on
  aineistovuoden rahassa 95 senttiä, syötä arvoksi 0.95.
  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
  Jos puolestaan haluaa käyttää automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

%LET INF = 1.00; * Syötä lukuarvo, KHI tai ATI;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko;

/* KOKO-mallissa ajettavat osavaiheet */

%LET KOKOpoiminta = 1; 		* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) ;
%LET KOKOsummat = 1;		* Summataulukot (1 jos ajetaan, 0 jos ei) ;
%LET KOKOindikaattorit = 1; * Tulonjakoindikaattorit (1 jos ajetaan, 0 jos ei) ;

/* Ajettavien osamallien valinta.
   Jos osamalli ajetaan, niin sitä seuraavissa malleissa käytetään kyseisen mallin simuloituja tietoja. 
   Jos osamallia ei ajeta, niin sitä seuraavissa malleissa käytetään kyseisen mallin osalta datassa olevia tietoja.
   Mallit ajetaan alla olevassa järjestyksessä.  

   RAJOITUKSET: 
   1) Jos joku tai jotkut malleista (SAIRVAK, TTURVA, KANSEL, KOTIHTUKI tai OPINTUKI) 
	  ajetaan, niin myös VERO-malli on ajettava.
   2) ELASUMTUKI-malli pitää ajaa aina, jos ASUMTUKI-malli ajetaan.
   3) KIVERO-mallin ajamista varten tarvitaan kiinteistöverotuksen erillisaineisto aineistovuodelle.
*/

* Jos arvo = 1, niin malli ajetaan, jos 0, niin mallia ei ajeta ja käytetään datan tietoja. ;

%LET SAIRVAK = 1;
%LET TTURVA = 1;
%LET KOTIHTUKI = 1;
%LET KANSEL = 1;
%LET OPINTUKI = 1;
%LET VERO = 1;
%LET KIVERO = 1;
%LET LLISA = 1;
%LET ELASUMTUKI = 1;
%LET ASUMTUKI = 1;
%LET PHOITO = 0;
%LET TOIMTUKI = 1;

/* Erillismoduulien valinta (vain REK) */
%LET OSINKO_MODUL = 0;

/* Osamallien ohjausparametreja */

%LET POIMINTA = 1;   	* Muuttujien poiminta osamalleissa (1 jos ajetaan, 0 jos ei). HUOM! APUMUUTTUJIA EI SAA LUODA JOS PARAMETREJA ON MUUTETTU;
%LET KDATATULO = 0; 	* Käytetäänkö KANSEL-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;
%LET SDATATULO = 0;  	* Käytetäänkö SAIRVAK-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0; 
%LET TTDATATULO = 0;  	* Käytetäänkö TTURVA-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;
%LET APKESTOSIMUL = 0;	* Leikataanko TTURVA-mallissa ansiopäivärahan kestoa käytettävän lainsäädännön mukaan = 1 vai eikö = 0.
						  Leikatut päivät siirretään työmarkkinatukeen;
%LET VKKESTOSIMUL = 0;	* Leikataanko TTURVA-mallissa vuorottelukorvauksen kestoa käytettävän lainsäädännön mukaan = 1 vai eikö = 0.
						  Leikattuja päiviä ei siirretä muihin etuuksiin;
%LET TARKPVM = 1;    	* Jos tämän arvo = 1, VERO-mallissa sairausvakuutuksen päivärahamaksun
						  laskentaa tarkennetaan käänteisellä päättelyllä ;
%LET YRIT = 0; 			* Simuloidaanko toimeentulotuki myös yrittäjätalouksille (1 = Kyllä, 0 = Ei);

* Osamallien simuloinnissa käytettävien lakimakrotiedostojen nimet ;

%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;
%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;
%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;
%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;
%LET LAKIMAK_TIED_LL = LLISAlakimakrot;
%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;
%LET LAKIMAK_TIED_KE = KANSELlakimakrot;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;
%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;
%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;
%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;
%LET LAKIMAK_TIED_PH = PHOITOlakimakrot;

* Osamallien simuloinnissa käytettävien simulointitiedostojen nimet ;

%LET SIMUL_TIED_OT = OPINTUKIsimul;
%LET SIMUL_TIED_TT = TTURVAsimul;
%LET SIMUL_TIED_SV = SAIRVAKsimul;
%LET SIMUL_TIED_KT = KOTIHTUKIsimul;
%LET SIMUL_TIED_LL = LLISAsimul;
%LET SIMUL_TIED_TO = TOIMTUKIsimul;
%LET SIMUL_TIED_KE = KANSELsimul;
%LET SIMUL_TIED_VE = VEROsimul;
%LET SIMUL_TIED_KV = KIVEROsimul;
%LET SIMUL_TIED_YA = ASUMTUKIsimul;
%LET SIMUL_TIED_EA = ELASUMTUKIsimul;
%LET SIMUL_TIED_PH = PHOITOsimul;

* Osamallien simuloinnissa käytettävien parametritaulukoiden nimet ;

%LET POPINTUKI = popintuki;
%LET PTTURVA = ptturva;
%LET PSAIRVAK = psairvak;
%LET PKOTIHTUKI = pkotihtuki;
%LET PLLISA = pllisa;
%LET PTOIMTUKI = ptoimtuki;
%LET PKANSEL = pkansel;
%LET PVERO = pvero;
%LET PVERO_VARALL = pvero_varall;
%LET PKIVERO = pkivero;
%LET PASUMTUKI = pasumtuki;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;
%LET PELASUMTUKI = pelasumtuki;
%LET PPHOITO = pphoito;

/* Tulostaulukoiden esivalinnat */ 

%LET TULOSLAAJ_KOKO = 1 ; * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;

* Taulukoitavat muuttujat (summataulukko) ;

%LET MUUTTUJAT = SAIRVAK_SIMUL SAIRVAK_DATA TTURVA_SIMUL TTURVA_DATA KOTIHTUKI_SIMUL KOTIHTUKI_DATA
		KANSEL_PERHEL_SIMUL KANSEL_PERHEL_DATA VEROTT_KANSEL_SIMUL VEROTT_KANSEL_DATA ASUMLISA_SIMUL
		ASUMLISA_DATA OPLAINA_SIMUL OPLAINA_DATA OPINTUKI_SIMUL OPINTUKI_DATA PALKVAK_SIMUL PALKVAK_DATA
		PRAHAMAKSU_SIMUL PRAHAMAKSU_DATA KUNNVE_SIMUL KUNNVE_DATA KIRKVE_SIMUL KIRKVE_DATA
		SAIRVAKMAKSU_SIMUL SAIRVAKMAKSU_DATA VALTVERO_SIMUL VALTVERO_DATA
		POVERO_SIMUL POVERO_DATA YLEVERO_SIMUL YLEVERO_DATA VEROTYHT_SIMUL VEROTYHT_DATA MAKSP_VEROT_SIMUL
		MAKSP_VEROT_DATA PTVARVO_SIMUL PTKIVERO_SIMUL VAPVARVO_SIMUL
		VAPKIVERO_SIMUL ASOYKIVERO_SIMUL MPKIVE_SIMUL KIVEROYHT_SIMUL KIVEROYHT2_SIMUL
		KIVEROYHT_DATA LAPSIP_SIMUL LAPSIP_DATA ELASUMTUKI_SIMUL ELASUMTUKI_DATA ASUMTUKI_SIMUL ASUMTUKI_DATA
		PHOITO_SIMUL PHOITO_DATA TOIMTUKI_SIMUL TOIMTUKI_DATA PALKAT MUUT_EL MUU_ANSIO PANSIO_SIMUL PANSIO_DATA 
		PPOMA_SIMUL PPOMA_DATA YRIT_ANSIO YRIT_POTULO SEKAL_PRAHAT SEKAL_POTULO SEKAL_VEROT SEKAL_VEROTT_TULO
		EI_SIMULTULOT ASUNTOTULO SEKAL_VAHENN OSVEROVAP_SIMUL OSVEROVAP_DATA 
		OSINGOTP_SIMUL OSINGOTP_DATA OSINGOTA_SIMUL OSINGOTA_DATA 
		YHTHYV_SIMUL PRAHAT_SIMUL PRAHAT_DATA ASUMTUET_SIMUL ASUMTUET_DATA VERONAL_TULOT_SIMUL 
		VERONAL_TULOT_DATA VEROTT_TULOT_SIMUL VEROTT_TULOT_DATA BRUTTORAHATULO_SIMUL BRUTTORAHATULO_DATA 
		KAYTRAHATULO_SIMUL kturaha KAYTRAHATULO_DATA KAYTRAHATULO_KIRKVE_SIMUL KAYTRAHATULO_KIRKVE_DATA
		KAYTTULO_SIMUL ktu KAYTTULO_DATA; 	 

%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
								 DESMOD_MALLI (mallissa uudelleen tuotetut tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     desmod (alkuperäiset tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
%LET LUOK_HLO2 = ;		 	* Taulukoinnin 2. henkilöluokitus ;
%LET LUOK_HLO3 = ;		 	* Taulukoinnin 3. henkilöluokitus ;

%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     DESMOD_MALLI (mallissa uudelleen tuotetut tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     desmod (alkuperäiset tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavuv (viitehenkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilön koulutusaste)
							     paasoss (viitehenkilön sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
%LET LUOK_KOTI2 = ; 	  	* Taulukoinnin 2. kotitalousluokitus ;
%LET LUOK_KOTI3 = ; 	  	* Taulukoinnin 3. kotitalousluokitus ;

%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);

%LET SUMWGT = SUMWGT; * N eli lukumäärät ;
%LET SUM = SUM; 
%LET MIN = ; 
%LET MAX = ;
%LET RANGE = ;
%LET MEAN = ;
%LET MEDIAN = ;
%LET MODE = ;
%LET VAR = ;
%LET CV = ;
%LET STD = ;

%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana) ;
%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

%LET TARKISTUS_ASUMTUKI = 1;	* Tarkistetaan ASUMTUKI-mallin ajoa varten onko ELASUMTUKIsimul ajettuna (kyllä/ei (1/0));

* Tulonjakoindikaattoreiden esivalinnat ;

%LET RAJALKM = 3; * Käytettävien köyhyysrajojen määrä ;
%LET KRAJA1 = 60; * 1. köyhyysraja (% mediaanitulosta) ;
%LET KRAJA2 = 50; * 2. köyhyysraja (% mediaanitulosta) ;
%LET KRAJA3 = 40; * 3. köyhyysraja (% mediaanitulosta) ;
%LET TULO = KAYTRAHATULO_SIMUL;  * Käytettävä tulokäsite: 
							   - BRUTTORAHATULO_SIMUL (Rahatulot ennen veroja ja vähennyksiä)
							   - KAYTRAHATULO_SIMUL (Käytettävissä olevat rahatulot) (Oletus)
							   - KAYTRAHATULO_KIRKVE_SIMUL (Käytettävissä olevat rahatulot, vähennetty kirkollisverot)
				   			   - tai KAYTTULO_SIMUL (Käytettävissä olevat tulot (ml. laskennallinen asuntotulo));
%LET KULUYKS = modoecd ; * Kulutusyksikön määritelmä:
							- jasenia (Jäsenten lukumäärä)
							- kulyks (OECD:n kulutusyksikkömääritelmä) 
							- tai modoecd (Modifioitu OECD:n kulutusyksikkömääritelmä);
%END;

/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%LET KIVERO_AINEISTO = KIVE_&AINEISTO&AVUOSI; 	* Käytettävä kiinteistöverorekisterin aineisto (aina KIVE_&AINEISTO);

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KoKo_Muutt_Poiminta;

* Annetaan ERROR jos käyttäjä on valinnut ASUMTUKI-mallin ja lainsäädäntövuodelle 2017 simulointityypin SIMUL;
%IF &ASUMTUKI = 1 AND &LVUOSI = 2017 AND %UPCASE(&TYYPPI_KOKO) = SIMUL %THEN %DO;
	%PUT ERROR: Lainsäädäntövuodelle 2017 ei voi käyttää ASUMTUKI-mallissa simulointityyppiä SIMUL;
	%PUT ERROR: Valitse TYYPPI_KOKO = SIMULX ja haluamasi lainsäädäntökuukausi (LKUUK)!;
	%ABORT CANCEL;
%END;

%IF &KOKOpoiminta = 1 %THEN %DO;

	/* Määritellään tarvittavat aineiston muuttujat taulukkoon START_KOKO */

	DATA STARTDAT.START_KOKO;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro asko trpl trplkor anstukor tapur tulkp tmpt tkust tepalk
	 tmeri tlue2 tpalv trespa tpturva vthmp tpjta
	 tyhtat yrtukor tpalv2 telps1 telps2 telps5 ttyoltuk tlakko tpalv2a
	 tmuut tomlis telvpal tsuurpu tutmp2 tutmp3 tutmp4
	 tyhtpot tmetsp tmetspp tvaksp tvuokr tvuokr1 tpalv2p tjvkork  tmuukor tjmark tmuutp
	 tsiraho tmyynt tmyynt1 fluotap tvahevas tptmuu tulkyhp ttapel tlapel ttappr tmuupr
	 tvakpr kokorve hlakav tpotel tmuuel teanstu tmluoko tmtatt hkuto amstipe
	 hsotav hasepr hsotvkor vaklis korav elasa rahsa apuraha lassa lahdever omakkiiv vevm
	 verokor lveru elama astulone muastulo hsaiprva haiprva hwmky htkapr tmtukimk vvvmk1
	 vvvmk3 vvvmk5 yhtez tkoultuk hvamtuk kelapu hlaho rvvm kellaps rili riyl kthr kthl ktku
	 oshr lgjhhr hkotihm hasuli hopila verot svatvap svatpp lpvma lshma ltva ltvp lkuve lkive
	 lelvak tnoosvvb teinovvb tuosvvap teinovv tnoosvab tuosvv tenosve
	 teinova tpeito llmk aitav lbeltuki hastuki htoimtuk
	 hoimaksk hoimakso hoiaikak hoiaikao hoimaksy hoiaikay
	 tvahep50 tptvs tvahep20 tptsu50 korosazkg korosazkf korosatkg korosatkf 
	 dtyhtep korosapks korosapkw aemkm lylen tkapite
	 tansel tkansel tperhel takuuel tkopira tkuntra teleuve
	 toyjmyv toyjmav toyjmyvvap toyjmavvap
	 tosmetpt tyhtmat tyhtate tyhtmpot tyhtpote tmaat1evyr tmaat1pevyr
	 tliik1evyr tliikpevyr tporo1evyr tyhtmatevyr tyhtateevyr tmaat2evyr
	 tmaat2pevyr tliik2evyr tliik2pevyr tporo2evyr tyhtmpotevyr tyhtpoteevyr 
	);

	/* Lisätään aineistoon apumuuttujia */

	/* Palkkatulot */

	PALKAT = SUM(trpl, trplkor, anstukor, tulkp, tmpt, tkust, tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tutmp2, tutmp3, tutmp4);

	PALKAT = MAX(SUM(PALKAT, -vthmp), 0);

	/* Sosiaalietuuksia, joita ei simuoida */

	SEKAL_PRAHAT = SUM(ttappr, tmuupr, tvakpr, tkuntra); 

	/* Ansioeläkkeet ym. */

	MUUT_EL = MAX(SUM(tansel, ttapel, tlapel, tpotel, teanstu, tmuuel, teleuve), 0);

	/* Muita sekalaisia ansiotuloja */

	MUU_ANSIO = SUM(tpalv2, telps1, telps2, telps5, ttyoltuk, tlakko, tpalv2a, tmuut, tomlis, telvpal, tmluoko, tsuurpu, SUM(MAX(tkoultuk, 0)), tkapite, tapur);

	/* Yritystuloja ansiotuloina (yrittäjävähennystä ei ole tehty) */

	YRIT_ANSIO = SUM(tmaat1evyr, tmaat1pevyr, tpjta, tliik1evyr, tliikpevyr, tporo1evyr, tyhtmatevyr, tyhtateevyr, SUM(tyhtat, -tyhtmat, -tyhtate), tmtatt, yrtukor);

	/* Yritystuloja pääomatuloina (yrittäjävähennystä ei ole tehty) */

	YRIT_POTULO = SUM(tmaat2evyr, tmaat2pevyr, tliik2evyr, tliik2pevyr, tporo2evyr, tyhtmpotevyr, tyhtpoteevyr, SUM(tyhtpot, -tyhtmpot, -tyhtpote), MAX(tmetsp, 0), MAX(tmetspp, 0), MAX(tosmetpt, 0), tvaksp);

	/* Sekalaisia pääomatuloja */

	SEKAL_POTULO = SUM(tvuokr, tvuokr1, tpalv2p, tjvkork, tmuukor, tjmark, tmuutp, tsiraho, 
		MAX(SUM(tmyynt, tmyynt1, -fluotap), 0), tvahevas, tptmuu, MAX(SUM(tulkyhp, -tuosvv), 0), tvahep50, tptvs, tvahep20, tptsu50);

	/* Sekalaisia, ei-simuloituja, verottomia tuloja */

	SEKAL_VEROTT_TULO = SUM(hkuto, amstipe, hsotav, hasepr, hsotvkor,
		vaklis, korav, elasa, rahsa, apuraha, lassa, kokorve, hlakav);

	/* Sekalaisia, ei-simuloituja veroja */

	SEKAL_VEROT = SUM(lahdever, MAX(SUM(vevm, -lelvak), 0), verokor, lveru);

	/* Sekalaisia vähennyksiä tuloista, nyt vain elatusmaksut */

	SEKAL_VAHENN = elama;

	/* Puhdas ansiotulo ja pääomatulo */

	PANSIO_DATA = svatvap;
	PPOMA_DATA = svatpp;

	/* Laskennallinen asuntotulo */

	ASUNTOTULO = SUM(astulone, muastulo);
	
	/* Lasketaan vertailutiedoiksi simuloitavien muuttujasummien arvoja datasta */

	SAIRVAK_DATA = SUM(MAX(hsaiprva, 0), MAX(haiprva, 0), MAX(hwmky, 0), htkapr);

	TTURVA_DATA = SUM(MAX(vvvmk1, 0), MAX(vvvmk3, 0), MAX(vvvmk5, 0),
					MAX(0, SUM(dtyhtep, korosapks, korosapkw)), MAX(SUM(yhtez, korosazkg, korosazkf), 0),
				    MAX(SUM(tmtukimk, korosatkg, korosatkf), 0));

	KANSEL_PERHEL_DATA = SUM(tkansel, tperhel, takuuel);
	VEROTT_KANSEL_DATA = SUM(MAX(hvamtuk, 0), kelapu, hlaho, rvvm, kellaps, rili, riyl);
	KOTIHTUKI_DATA = SUM(MAX(kthr, 0), MAX(kthl, 0), ktku, oshr, lgjhhr, hkotihm);
	OPINTUKI_DATA = tkopira;
	OPLAINA_DATA = SUM(MAX(hopila, 0));
	ASUMLISA_DATA = SUM(MAX(hasuli, 0), 0);
	PRAHAT_DATA = SUM(SAIRVAK_DATA, TTURVA_DATA, KOTIHTUKI_DATA, OPINTUKI_DATA);
	KUNNVE_DATA = SUM(MAX(lkuve, 0));
	KIRKVE_DATA = SUM(MAX(lkive, 0));
	PRAHAMAKSU_DATA = SUM(MAX(lpvma, 0));
	SAIRVAKMAKSU_DATA = SUM(MAX(lshma, 0));
	PALKVAK_DATA = SUM(MAX(lelvak, 0));
	VALTVERO_DATA = SUM(MAX(ltva, 0));
	POVERO_DATA = SUM(MAX(ltvp, 0));
	VEROTYHT_DATA = SUM(lelvak, lpvma, ltva, ltvp, lkuve, lkive, lshma, lylen);
	VEROT_DATA = SUM(verot, -lkive, lelvak);
	MAKSP_VEROT_DATA = SUM(MAX(verot, 0));
	OSVEROVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, toyjmyvvap, toyjmavvap, teinovv);
	OSVEROVAP1_DATA = SUM(tnoosvvb, tuosvvap);
	OSVEROVAP2_DATA = SUM(toyjmyvvap, toyjmavvap);
	OSVEROVAP3_DATA = teinovvb;
	OSVEROVAP4_DATA = teinovv;
	OSINGOTP_DATA = SUM(tnoosvab, tenosve, tuosvv, toyjmav);
	OSINGOTP1_DATA = SUM(tnoosvab, tuosvv);
	OSINGOTP2_DATA = toyjmav;
	OSINGOTP3_DATA = tenosve;
	OSINGOTA_DATA = SUM(teinova, tpeito, toyjmyv);
	YLEVERO_DATA = lylen;
	LAPSIP_DATA = SUM(MAX(llmk, 0), MAX(aitav, 0) , MAX(lbeltuki, 0));
	ELASUMTUKI_DATA = SUM(MAX(aemkm, 0));
	ASUMTUKI_DATA = SUM(MAX(hastuki, 0), 0);
	ASUMTUET_DATA = SUM(ASUMLISA_DATA, ELASUMTUKI_DATA, ASUMTUKI_DATA);
	PHOITO_DATA = SUM(MAX(hoiaikak * hoimaksk, 0), MAX(hoiaikao * hoimakso, 0), MAX(hoiaikay * hoimaksy, 0));
	TOIMTUKI_DATA = SUM(MAX(htoimtuk, 0));
	VERONAL_TULOT_DATA = SUM(PRAHAT_DATA,  KANSEL_PERHEL_DATA);
	VEROTT_TULOT_DATA = SUM(LAPSIP_DATA, VEROTT_KANSEL_DATA, ASUMTUET_DATA, TOIMTUKI_DATA);

	/* Tulot, joita (normaalisti) ei simuloida, yhteenlaskettuna */

	EI_SIMULTULOT = SUM(PALKAT, MUU_ANSIO, SEKAL_PRAHAT,  MUUT_EL,
		YRIT_ANSIO, YRIT_POTULO, SEKAL_POTULO, SEKAL_VEROTT_TULO);

	/* Maksetut kiinteistöverot */

	KIVEROYHT_DATA = omakkiiv;

	/* Luodaan uusille summamuuttujille selitteet */

	LABEL
	PALKAT = 'Palkkatulot yhteensä, DATA'
	MUUT_EL = 'Ansio ym. eläkkeet yhteensä, DATA'
	MUU_ANSIO = 'Muita sekalaisia ansiotuloja yhteensä, DATA'
	YRIT_ANSIO = 'Yritystulot ansiotuloina yhteensä, DATA'
	YRIT_POTULO = 'Yritystulot pääomatuloina yhteensä, DATA'
	SEKAL_PRAHAT = 'Sosiaalietuudet yhteensä, joita ei simuloida, DATA'
	SEKAL_POTULO = 'Sekalaisia pääomatuloja yhteensä, DATA'
	SEKAL_VEROT = 'Sekalaisia, ei-simuloituja veroja yhteensä, DATA'
	SEKAL_VEROTT_TULO = 'Sekalaisia, ei-simuloituja, verottomia tuloja yhteensä, DATA'
	ASUNTOTULO = 'Laskennallinen asuntotulo, DATA'
	SEKAL_VAHENN = 'Sekalaisia vähennyksiä tuloista (elatusmaksut), DATA'
	OSVEROVAP_DATA = 'Verottomat osingot yhteensä, DATA'
	OSVEROVAP1_DATA = 'Verottomat osingot: ulkomaan osingot ja listatut yhtiöt, DATA'
	OSVEROVAP2_DATA = 'Verottomat osingot: osuuspääoman korko, DATA'
	OSVEROVAP3_DATA = 'Verottomat osingot: listaamaattomat yhtiöt (pääomatulo), DATA'
	OSVEROVAP4_DATA = 'Verottomat osingot: listaamattomat yhtiöt (ansiotulo), DATA'
	OSINGOTP_DATA = 'Pääomatulo-osingot yhteensä, DATA'
	OSINGOTP1_DATA = 'Pääomatulo-osingot: ulkomaan osingot ja julkisesti noteeratut osakkeet, DATA'
	OSINGOTP2_DATA = 'Pääomatulo-osingot: osuuspääoman korot, DATA'
	OSINGOTP3_DATA = 'Pääomatulo-osingot: henkilöyhtiöt, DATA'
	OSINGOTA_DATA = 'Ansiotulo-osingot yhteensä, DATA'
	PANSIO_DATA = 'Puhdas ansiotulo, DATA'
	PPOMA_DATA = 'Puhdas pääomatulo, DATA'
	SAIRVAK_DATA = 'Sairausvakuutuslain mukaiset päivärahat yhteensä, DATA'
	TTURVA_DATA = 'Työttömyysturva ja koulutustuki yhteensä, DATA'
	KANSEL_PERHEL_DATA = 'Kansaneläkkeet ja perhe-eläkkeet yhteensä (ml. takuueläke), DATA'
	VEROTT_KANSEL_DATA = 'Verottomat eläkelisät ja vammaistuet yhteensä, DATA'
	KOTIHTUKI_DATA = 'Lasten kotihoidon tuki yhteensä, DATA'
	PHOITO_DATA = 'Päivähoitomaksut yhteensä, DATA'
	OPINTUKI_DATA = 'Opintoraha yhteensä, DATA'
	OPLAINA_DATA ='Opintolainan valtiontakaus, DATA'
	PRAHAT_DATA = 'Sosiaaliturvan päivärahat yhteensä, DATA'
	LAPSIP_DATA = 'Lapsilisät, äitiysavustus ja elatustuki yhteensä, DATA'
	ELASUMTUKI_DATA = 'Eläkkeensaajien asumistuki, DATA'
	ASUMTUKI_DATA = 'Yleinen asumistuki yhteensä, DATA'
	ASUMLISA_DATA = 'Opintotuen asumislisä, DATA'
	ASUMTUET_DATA = 'Asumistuet yhteensä, DATA'
	PHOITO_DATA = 'Päivähoitomaksut yhteensä, DATA'
	TOIMTUKI_DATA = 'Toimeentulotuki, DATA'
	PALKVAK_DATA = 'Palkansaajan eläke- ja työttömyysvakuutusmaksut yhteensä, DATA'
	PRAHAMAKSU_DATA = 'Sairausvakuutuksen päivärahamaksu, DATA'
	KUNNVE_DATA = 'Kunnallisverot, DATA'
	KIRKVE_DATA = 'Kirkollisverot, DATA'
	SAIRVAKMAKSU_DATA = 'Sairaanhoitomaksut, DATA'
	VALTVERO_DATA = 'Valtion tuloverot, DATA'
	POVERO_DATA = 'Pääomatulon verot, DATA'
	MAKSP_VEROT_DATA = 'Maksuunpannut verot, DATA' 
	VEROTYHT_DATA = 'Kaikki verot ja maksut yhteensä, DATA'
	VEROT_DATA = 'Verot ja maksut yhteensä (pl. kirkollisvero), DATA'
	VERONAL_TULOT_DATA = 'Veronalaiset tulonsiirrot yhteensä, DATA'
	VEROTT_TULOT_DATA = 'Verottomat tulonsiirrot yhteensä, DATA'
	EI_SIMULTULOT = 'Tulot, joita (normaalisti) ei simuloida, yhteenlaskettuna, DATA'
	YLEVERO_DATA = 'Yle-vero, DATA'
	KIVEROYHT_DATA = 'Kiinteistöverot (pl. asoy) yhteensä, DATA';

	/* Pidetään vain tarpeelliset muuttujat */

	KEEP hnro knro asko htkapr ktku hkotihm hoiaikay hoimaksy
	KUNNVE_DATA KIRKVE_DATA PRAHAMAKSU_DATA SAIRVAKMAKSU_DATA PALKVAK_DATA VALTVERO_DATA POVERO_DATA
	PANSIO_DATA PPOMA_DATA MAKSP_VEROT_DATA OPLAINA_DATA PALKAT SEKAL_PRAHAT MUUT_EL MUU_ANSIO
	YRIT_ANSIO YRIT_POTULO SEKAL_POTULO SEKAL_VEROT SEKAL_VAHENN SEKAL_VEROTT_TULO EI_SIMULTULOT
	ASUNTOTULO SAIRVAK_DATA TTURVA_DATA KANSEL_PERHEL_DATA VEROTT_KANSEL_DATA KOTIHTUKI_DATA OPINTUKI_DATA
	ASUMLISA_DATA PRAHAT_DATA VEROTYHT_DATA VEROT_DATA OSVEROVAP_DATA OSINGOTP_DATA OSINGOTA_DATA LAPSIP_DATA
	ELASUMTUKI_DATA ASUMTUKI_DATA ASUMTUET_DATA PHOITO_DATA TOIMTUKI_DATA VERONAL_TULOT_DATA PRAHAT_DATA 
	ASUMTUET_DATA VERONAL_TULOT_DATA VEROTT_TULOT_DATA OSVEROVAP1_DATA OSVEROVAP2_DATA OSVEROVAP3_DATA
	OSVEROVAP4_DATA OSINGOTP1_DATA OSINGOTP2_DATA OSINGOTP3_DATA KIVEROYHT_DATA YLEVERO_DATA;

	RUN;

%END;

%MEND KoKo_Muutt_Poiminta;

%KoKo_Muutt_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2KOKO = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe (osamallien ajo ja tietojen siirto osamalleista) */

%MACRO KoKo_Simuloi_Data;

/* Tarkistetaan onko VERO-malli ajettu mikäli ajetaan joku malli, joka kaipaa sitä */

%IF &SAIRVAK = 1 AND &VERO = 0 %THEN %PUT WARNING: SAIRVAK-malli valittu, valitse myös VERO-malli!;
%IF &TTURVA = 1 AND &VERO = 0 %THEN %PUT WARNING: TTURVA-malli valittu, valitse myös VERO-malli!;
%IF &KANSEL = 1 AND &VERO = 0 %THEN %PUT WARNING: KANSEL-malli valittu, valitse myös VERO-malli!;
%IF &KOTIHTUKI = 1 AND &VERO = 0 %THEN %PUT WARNING: KOTIHTUKI-malli valittu, valitse myös VERO-malli!;
%IF &OPINTUKI = 1 AND &VERO = 0 %THEN %PUT WARNING: OPINTUKI-malli valittu, valitse myös VERO-malli!;

/* 3.1 Kutsutaan osamallien simulointikoodeja */

/* Sairausvakuutus */
%IF &SAIRVAK = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_SV..sas";
%END;

/* Työttömyysturva */
%IF &TTURVA = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_TT..sas";
%END;

/* Kansaneläke */
%IF &KANSEL = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KE..sas";
%END;

/* Kotihoidontuki */
%IF &KOTIHTUKI = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KT..sas";
%END;

/* Opintotuki */
%IF &OPINTUKI = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_OT..sas";
%END;

/* Verotus */
%IF &VERO = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_VE..sas";
%END;

/* Kiinteistöverotus */
%IF &KIVERO = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KV..sas";
%END;

/* Lapsilisät */
%IF &LLISA = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_LL..sas";
%END;

/* Eläkkeensaajan asumistuki */
%IF &ELASUMTUKI = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_EA..sas";
%END;

/* Yleinen asumistuki */
%IF &ASUMTUKI = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_YA..sas";
%END;

/* Päivähoitomaksut */
%IF &PHOITO = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_PH..sas";
%END;

/* Toimeentulotuki */
%IF &TOIMTUKI = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_TO..sas";
%END;

/* 3.3 Yhdistetään osamallien tulokset KOKO-mallin starttidataan */

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &KOTIHTUKI = 1 OR &OPINTUKI = 1 OR &VERO = 1 OR &KIVERO = 1
	OR &LLISA = 1 OR &ELASUMTUKI = 1 OR &ASUMTUKI = 1 OR &PHOITO = 1 OR &TOIMTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_KOKO;
		MERGE STARTDAT.START_KOKO (IN = C)

		/* Sairausvakuutus */
		%IF &SAIRVAK = 1 %THEN %DO;
			TEMP.&TULOSNIMI_SV
			(KEEP = hnro SAIRPR VANHPR SAIRPR_TYONANT VANHPR_TYONANT ERITHOITR)
		%END;

		/* Työttömyysturva */
		%IF &TTURVA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_TT
			(KEEP = hnro YHTTMTUKI TMTUKILMKOR PERILMAKOR PERUSPR ANSIOPR ANSIOILMKOR VUORKORV YPITOK)
		%END;

		/* Kansaneläke */
		%IF &KANSEL = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KE
			(KEEP = hnro TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI KTUKI
				MMTUKI LAPSENELAKE LAELAKEDATA LESKENELAKE LEELAKEDATA)
		%END;

		/* Kotihoidon tuki */
		%IF &KOTIHTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KT
			(KEEP = hnro KOTIHTUKI OSHOIT JSHOIT HOITORAHA HOITOLISA)
		%END;

		/* Opintotuki */
		%IF &OPINTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_OT
			(KEEP = hnro TUKIKESK TUKIKOR ASUMLISA OPLAIN)
		%END;

		/* Verotus */
		%IF &VERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_VE
			(KEEP = hnro PALKVAK THANKKULUT2 PUHD_ANSIO PUHD_PO ANSIOT_VAH ELTULVAH_K ELTULVAH_V OPRAHVAH
				INVVAH_K PRAHAMAKSU KUNNVTULO1 PERVAH KUNNVTULO2 KUNNVEROG KIRKVEROG SAIRVAKG KEVG
				VALTVERTULO YHTHYV VALTVEROH VALTANSVAH INVVAH_V ELVELV_VAH POVEROC ALIJHYV ALIJHYVERIT
				KOTITVAH_DATA KOTITVAH ULKVAH OSINKOVAP OSINKOP OSINKOA OSINKOP1 OSINKOP2 OSINKOP3
				OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4 ASKOROT ENSASKOROT MUU_VAH ANSIOVEROT
				KAIKKIVEROT MAKSP_VEROT YLEVERO LAPSIVAH)
		%END;

		/* Kiinteistöverotus */
		%IF &KIVERO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_KV
			(KEEP = hnro VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA ASOYKIVERO KVTONTTIS
				KIVEROYHT KIVEROYHT2)
		%END;

		/* Lapsilisät */
		%IF &LLISA = 1 %THEN %DO;
			TEMP.&TULOSNIMI_LL
			(KEEP = hnro LLISA_HH AITAVUST ELATUSTUET_HH)
		%END;

		/* Eläkkeensaajan asumistuki */
		%IF &ELASUMTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_EA
			(KEEP = hnro ELAKASUMTUKI)
		%END;

		/* Yleinen asumistuki */
		%IF &ASUMTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_YA
			(KEEP = hnro TUKISUMMA)
		%END;

		/* Päivähoitomaksut */
		%IF &PHOITO = 1 %THEN %DO;
			TEMP.&TULOSNIMI_PH
			(KEEP = hnro PHMAKSU_KOK PHMAKSU_OS)
		%END;

		/* Toimeentulotuki */
		%IF &TOIMTUKI = 1 %THEN %DO;
			TEMP.&TULOSNIMI_TO
			(KEEP = hnro TOIMTUKI)
		%END;

		;
		BY hnro;
		IF C;
	RUN;

%END;

/* 3.3 Lasketaan simuloitujen muuttujien summia henkilöittäin.
       Jos muuttujatietoja ei ole simuloitu, lasketaan vastaavat arvot datasta */

DATA TEMP.&TULOSNIMI_KOKO; 
SET STARTDAT.START_KOKO;

/* Sairausvakuutuksen päivärahat */

%IF &SAIRVAK = 0 %THEN %DO;
	SAIRVAK_SIMUL = SAIRVAK_DATA;
%END;
%ELSE %DO;
	SAIRVAK_SIMUL = SUM(SAIRPR, VANHPR, ERITHOITR, htkapr);
%END;

/* Työttömyysturvan päivärahat */

%IF &TTURVA = 0 %THEN %DO;
	TTURVA_SIMUL = TTURVA_DATA;
%END;
%ELSE %DO;
	TTURVA_SIMUL = SUM(YHTTMTUKI, PERUSPR, ANSIOPR, VUORKORV);
%END;

/* Kansaneläkkeet ym. */

%IF &KANSEL = 0 %THEN %DO;
	KANSEL_PERHEL_SIMUL = KANSEL_PERHEL_DATA;
	VEROTT_KANSEL_SIMUL = VEROTT_KANSEL_DATA;
%END;
%ELSE %DO;
	KANSEL_PERHEL_SIMUL = SUM(TAKUUELA, KANSANELAKE, LESKENELAKE, LAPSENELAKE); 
	VEROTT_KANSEL_SIMUL = SUM(LAPSIKOROT, RILISA, YLIMRILI, EHOITUKI, LVTUKI, VTUKI, KTUKI, MMTUKI);
%END;

/* Lasten kotihoidon tuki */

%IF &KOTIHTUKI = 0 %THEN %DO;
	KOTIHTUKI_SIMUL = KOTIHTUKI_DATA;
%END;
%ELSE %DO;
	KOTIHTUKI_SIMUL = SUM(KOTIHTUKI, OSHOIT, JSHOIT, ktku, hkotihm);
%END;

/* Opintorahat ja asumislisä */

%IF &OPINTUKI = 0 %THEN %DO;
	OPINTUKI_SIMUL = OPINTUKI_DATA;
	ASUMLISA_SIMUL = ASUMLISA_DATA;
	OPLAINA_SIMUL = OPLAINA_DATA;
%END;
%ELSE %DO;
	OPINTUKI_SIMUL = SUM(TUKIKESK, TUKIKOR);
	ASUMLISA_SIMUL = ASUMLISA;
	OPLAINA_SIMUL = OPLAIN;
	DROP ASUMLISA OPLAIN;
%END;

/* Veronalaiset päivärahatulot yhteensä */

PRAHAT_SIMUL = SUM(SAIRVAK_SIMUL, TTURVA_SIMUL, KOTIHTUKI_SIMUL, OPINTUKI_SIMUL);

/* Verot ja muita VERO-mallilla laskettuja tietoja */

%IF &VERO = 0 %THEN %DO;
	PANSIO_SIMUL = PANSIO_DATA;
	PPOMA_SIMUL = PPOMA_DATA;
	KUNNVE_SIMUL = KUNNVE_DATA;
	KIRKVE_SIMUL = KIRKVE_DATA;
	PRAHAMAKSU_SIMUL = PRAHAMAKSU_DATA;
	SAIRVAKMAKSU_SIMUL = SAIRVAKMAKSU_DATA;
	KEVE_SIMUL = .;
	PALKVAK_SIMUL = PALKVAK_DATA;
	VALTVERO_SIMUL = VALTVERO_DATA;
	POVERO_SIMUL = POVERO_DATA;
	VEROTYHT_SIMUL = VEROTYHT_DATA;
	VEROT_SIMUL = VEROT_DATA;
	MAKSP_VEROT_SIMUL = MAKSP_VEROT_DATA;
	OSVEROVAP_SIMUL = OSVEROVAP_DATA;
	OSVEROVAP1_SIMUL = OSVEROVAP1_DATA;
	OSVEROVAP2_SIMUL = OSVEROVAP2_DATA; 
	OSVEROVAP3_SIMUL = OSVEROVAP3_DATA; 
	OSVEROVAP4_SIMUL = OSVEROVAP4_DATA;
	YHTHYV_SIMUL = .;
	OSINGOTP_SIMUL = OSINGOTP_DATA;
	OSINGOTP1_SIMUL = OSINGOTP1_DATA;
	OSINGOTP2_SIMUL = OSINGOTP2_DATA;
	OSINGOTP3_SIMUL = OSINGOTP3_DATA;
	OSINGOTA_SIMUL = OSINGOTA_DATA;
	YLEVERO_SIMUL = YLEVERO_DATA;
%END;
%ELSE %DO;
	PANSIO_SIMUL = PUHD_ANSIO;
	PPOMA_SIMUL = PUHD_PO;
	KUNNVE_SIMUL = KUNNVEROG;
	KIRKVE_SIMUL = KIRKVEROG;
	PRAHAMAKSU_SIMUL = PRAHAMAKSU;
	SAIRVAKMAKSU_SIMUL = SAIRVAKG;
	KEVE_SIMUL = KEVG;
	PALKVAK_SIMUL = PALKVAK;
	VALTVERO_SIMUL = VALTVEROH;
	POVERO_SIMUL = POVEROC;
	VEROTYHT_SIMUL = KAIKKIVEROT;
	VEROT_SIMUL = SUM(KAIKKIVEROT, -KIRKVEROG);
	MAKSP_VEROT_SIMUL = MAKSP_VEROT;
	OSVEROVAP_SIMUL = OSINKOVAP;
	OSVEROVAP1_SIMUL = OSINKOVAP1;
	OSVEROVAP2_SIMUL = OSINKOVAP2; 
	OSVEROVAP3_SIMUL = OSINKOVAP3; 
	OSVEROVAP4_SIMUL = OSINKOVAP4;
	OSINGOTP_SIMUL = OSINKOP;
	OSINGOTP1_SIMUL = OSINKOP1;
	OSINGOTP2_SIMUL = OSINKOP2;
	OSINGOTP3_SIMUL = OSINKOP3;
	OSINGOTA_SIMUL = OSINKOA;
	YHTHYV_SIMUL = YHTHYV;
	YLEVERO_SIMUL = YLEVERO;

	DROP KUNNVEROG KIRKVEROG PRAHAMAKSU SAIRVAKG PALKVAK VALTVEROH POVEROC
	     KAIKKIVEROT OSINKOVAP OSINKOP OSINKOA OSINKOP1 OSINKOP2 OSINKOP3 
		 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4 YHTHYV YLEVERO MAKSP_VEROT PUHD_ANSIO PUHD_PO KEVG;
%END;

/* Kiinteistövero */

%IF &KIVERO = 1 %THEN %DO; 
	PTVARVO_SIMUL = VALOPULLINENPT;
	PTKIVERO_SIMUL = RAK_KVEROPT;
	VAPVARVO_SIMUL = VALOPULLINENVA;
	VAPKIVERO_SIMUL = RAK_KVEROVA;
	ASOYKIVERO_SIMUL = ASOYKIVERO;
	MPKIVE_SIMUL =  KVTONTTIS ;
	KIVEROYHT_SIMUL = KIVEROYHT;
	KIVEROYHT2_SIMUL = KIVEROYHT2;
 
	DROP VALOPULLINENPT RAK_KVEROPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA ASOYKIVERO KVTONTTIS KIVEROYHT KIVEROYHT2;
%END;
%ELSE %DO;			  	  
	KIVEROYHT2_SIMUL = KIVEROYHT_DATA; 
%END;

/* Lapsilisät ym. */

%IF &LLISA = 0 %THEN %DO;
	LAPSIP_SIMUL = LAPSIP_DATA;
%END;
%ELSE %DO;
	LAPSIP_SIMUL = SUM(LLISA_HH, AITAVUST, ELATUSTUET_HH);
%END;

/* Eläkkeensaajien asumistuki */

%IF &ELASUMTUKI = 0 %THEN %DO;
	ELASUMTUKI_SIMUL = ELASUMTUKI_DATA;
%END;
%ELSE %DO;
	ELASUMTUKI_SIMUL = ELAKASUMTUKI;

	DROP ELAKASUMTUKI;
%END;

/* Yleinen asumistuki */

%IF &ASUMTUKI = 0 %THEN %DO;
	ASUMTUKI_SIMUL = ASUMTUKI_DATA;
%END;
%ELSE %DO;
	ASUMTUKI_SIMUL = SUM(TUKISUMMA, 0);

	DROP TUKISUMMA;
%END;

/* Asumistuet yhteensä */

ASUMTUET_SIMUL =  SUM(ASUMLISA_SIMUL, ELASUMTUKI_SIMUL, ASUMTUKI_SIMUL);

/* Päivähoitomaksut yhteensä */

%IF &PHOITO = 0 %THEN %DO;
	PHOITO_SIMUL = PHOITO_DATA;
%END;
%ELSE %DO;
	PHOITO_SIMUL = SUM(PHMAKSU_KOK, PHMAKSU_OS, (hoiaikay * hoimaksy), 0);
%END;

/* Toimeentulotuki */

%IF &TOIMTUKI = 0 %THEN %DO;
	TOIMTUKI_SIMUL = TOIMTUKI_DATA;
%END;
%ELSE %DO;
	TOIMTUKI_SIMUL = TOIMTUKI;

	DROP TOIMTUKI;
%END;

/* Veronalaiset tulonsiirrot */

VERONAL_TULOT_SIMUL = SUM(PRAHAT_SIMUL, KANSEL_PERHEL_SIMUL);

/* Verottomat tulonsiirrot */

VEROTT_TULOT_SIMUL = SUM(LAPSIP_SIMUL, VEROTT_KANSEL_SIMUL, ASUMTUET_SIMUL, TOIMTUKI_SIMUL);

/* Muodostetaan kokonaissummia */

BRUTTORAHATULO_DATA = SUM(EI_SIMULTULOT, VERONAL_TULOT_DATA, VEROTT_TULOT_DATA,  OSVEROVAP_DATA, OSINGOTA_DATA, OSINGOTP_DATA);

BRUTTORAHATULO_SIMUL = SUM(EI_SIMULTULOT, VERONAL_TULOT_SIMUL, VEROTT_TULOT_SIMUL, OSVEROVAP_SIMUL, OSINGOTA_SIMUL, OSINGOTP_SIMUL);

KAYTRAHATULO_DATA = MAX(SUM(BRUTTORAHATULO_DATA, -VEROT_DATA, -SEKAL_VEROT, -SEKAL_VAHENN, -KIVEROYHT_DATA), 0);

KAYTRAHATULO_SIMUL = MAX(SUM(BRUTTORAHATULO_SIMUL, -VEROT_SIMUL, -SEKAL_VEROT, -SEKAL_VAHENN, -KIVEROYHT2_SIMUL), 0);

KAYTRAHATULO_KIRKVE_DATA = MAX(SUM(KAYTRAHATULO_DATA, -KIRKVE_DATA), 0);

KAYTRAHATULO_KIRKVE_SIMUL = MAX(SUM(KAYTRAHATULO_SIMUL, -KIRKVE_SIMUL), 0);

KAYTTULO_DATA = MAX(SUM(KAYTRAHATULO_DATA, ASUNTOTULO), 0);

KAYTTULO_SIMUL = MAX(SUM(KAYTRAHATULO_SIMUL, ASUNTOTULO), 0);


RUN;


/* 3.4 Yhdistetään simuloitu data aineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA TEMP.&TULOSNIMI_KOKO;
	
/* 3.4.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ_KOKO = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO jasenia modoecd kulyks sp ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta
	ktu kturaha)
	TEMP.&TULOSNIMI_KOKO;
%END;

/* 3.4.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

%IF &TULOSLAAJ_KOKO = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_KOKO;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
	PALKAT MUUT_EL MUU_ANSIO YRIT_ANSIO YRIT_POTULO SEKAL_POTULO SEKAL_VEROT 
	EI_SIMULTULOT ASUNTOTULO SEKAL_VAHENN OSVEROVAP_DATA OSVEROVAP_SIMUL OSINGOTP_DATA 
	OSINGOTP_SIMUL OSINGOTA_DATA OSINGOTA_SIMUL SAIRVAK_DATA SAIRVAK_SIMUL TTURVA_DATA
	TTURVA_SIMUL KANSEL_PERHEL_DATA KANSEL_PERHEL_SIMUL KOTIHTUKI_DATA KOTIHTUKI_SIMUL 
	OPINTUKI_DATA OPINTUKI_SIMUL PRAHAT_DATA PRAHAT_SIMUL VEROT_DATA VEROT_SIMUL 
	YHTHYV_SIMUL LAPSIP_DATA LAPSIP_SIMUL VEROTT_KANSEL_DATA VEROTT_KANSEL_SIMUL 
	ELASUMTUKI_DATA ELASUMTUKI_SIMUL ASUMTUKI_DATA ASUMTUKI_SIMUL ASUMLISA_DATA ASUMLISA_SIMUL 
	ASUMTUET_DATA ASUMTUET_SIMUL PHOITO_DATA PHOITO_SIMUL TOIMTUKI_DATA TOIMTUKI_SIMUL VERONAL_TULOT_DATA
	VERONAL_TULOT_SIMUL VEROTT_TULOT_DATA VEROTT_TULOT_SIMUL VALTVERO_DATA VALTVERO_SIMUL POVERO_DATA
	POVERO_SIMUL KUNNVE_DATA KUNNVE_SIMUL KIRKVE_DATA KIRKVE_SIMUL SAIRVAKMAKSU_DATA SAIRVAKMAKSU_SIMUL 
	PALKVAK_DATA PALKVAK_SIMUL PRAHAMAKSU_DATA PRAHAMAKSU_SIMUL VEROTYHT_SIMUL VEROTYHT_DATA YLEVERO_SIMUL 
	YLEVERO_DATA PANSIO_DATA PANSIO_SIMUL PPOMA_DATA PPOMA_SIMUL MAKSP_VEROT_DATA MAKSP_VEROT_SIMUL OPLAINA_SIMUL OPLAINA_DATA
	OSVEROVAP1_DATA OSVEROVAP2_DATA OSVEROVAP3_DATA OSVEROVAP4_DATA OSINGOTP1_DATA OSINGOTP2_DATA OSINGOTP3_DATA
	OSVEROVAP1_SIMUL OSVEROVAP2_SIMUL OSVEROVAP3_SIMUL OSVEROVAP4_SIMUL OSINGOTP1_SIMUL OSINGOTP2_SIMUL OSINGOTP3_SIMUL
	PTVARVO_SIMUL PTKIVERO_SIMUL VAPVARVO_SIMUL VAPKIVERO_SIMUL ASOYKIVERO_SIMUL MPKIVE_SIMUL KIVEROYHT2_SIMUL 
    KIVEROYHT_SIMUL KIVEROYHT_DATA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Asetetaan mahdollisten tulosmuuttujien tyhjät ja negatiiviset arvot nolliksi, jotta
	myös nämä henkilöt huomioidaan tulonjakoindikaattoreiden laskennassa;

ARRAY NOLLA
	BRUTTORAHATULO_DATA BRUTTORAHATULO_SIMUL KAYTRAHATULO_DATA KAYTRAHATULO_SIMUL
	KAYTRAHATULO_KIRKVE_DATA KAYTRAHATULO_KIRKVE_SIMUL KAYTTULO_DATA KAYTTULO_SIMUL ktu kturaha;
DO OVER NOLLA;
	IF NOLLA < 0 THEN NOLLA = 0;
END;

/* Luodaan simuloitujen ja datan muuttujien summille selitteet */

LABEL 
PANSIO_SIMUL = 'Puhdas ansiotulo, MALLI'
PPOMA_SIMUL = 'Puhdas pääomatulo, MALLI'
OSVEROVAP_SIMUL = 'Verottomat osingot yhteensä, MALLI'
OSVEROVAP1_SIMUL = 'Verottomat osingot: ulkomaan osingot ja listatut yhtiöt, MALLI'
OSVEROVAP2_SIMUL = 'Verottomat osingot: osuuspääoman korko, MALLI'
OSVEROVAP3_SIMUL = 'Verottomat osingot: listaamaattomat yhtiöt (pääomatulo), MALLI'
OSVEROVAP4_SIMUL = 'Verottomat osingot: listaamattomat yhtiöt (ansiotulo), MALLI'
OSINGOTP_SIMUL = 'Pääomatulo-osingot yhteensä, MALLI'
OSINGOTP1_SIMUL = 'Pääomatulo-osingot: ulkomaan osingot ja julkisesti noteeratut osakkeet, MALLI'
OSINGOTP2_SIMUL = 'Pääomatulo-osingot: osuuspääoman korot, MALLI'
OSINGOTP3_SIMUL = 'Pääomatulo-osingot: henkilöyhtiöt, MALLI'
OSINGOTA_SIMUL = 'Ansiotulo-osingot yhteensä, MALLI'
SAIRVAK_SIMUL = 'Sairausvakuutuslain mukaiset päivärahat yhteensä, MALLI'
TTURVA_SIMUL = 'Työttömyysturva ja koulutustuki yhteensä, MALLI'
KOTIHTUKI_SIMUL = 'Lasten kotihoidon tuki yhteensä, MALLI'
PHOITO_SIMUL = 'Päivähoitomaksut yhteensä, MALLI'
OPINTUKI_SIMUL = 'Opintoraha yhteensä, MALLI'
OPLAINA_SIMUL ='Opintolainan valtiontakaus, MALLI'
PRAHAT_SIMUL = 'Sosiaaliturvan päivärahat yhteensä, MALLI'
PRAHAMAKSU_SIMUL = 'Sairausvakuutuksen päivärahamaksu, MALLI'
PALKVAK_SIMUL = 'Palkansaajan eläke- ja työttömyysvakuutusmaksut yhteensä, MALLI'
KUNNVE_SIMUL = 'Kunnallisverot, MALLI'
KIRKVE_SIMUL = 'Kirkollisverot, MALLI'
SAIRVAKMAKSU_SIMUL = 'Sairaanhoitomaksut, MALLI'
KEVE_SIMUL = 'Kansaneläkevakuutusmaksut, MALLI'
VALTVERO_SIMUL = 'Valtion tuloverot, MALLI'
POVERO_SIMUL = 'Pääomatulon verot, MALLI'
YLEVERO_SIMUL = 'Yle-vero, MALLI'
VEROTYHT_SIMUL = 'Kaikki verot ja maksut yhteensä, MALLI'
VEROT_SIMUL = 'Verot ja maksut yhteensä (pl. kirkollisvero), MALLI'
MAKSP_VEROT_SIMUL = 'Maksuunpannut verot, MALLI' 
YHTHYV_SIMUL = 'Yhtiöveron hyvitys, MALLI'
LAPSIP_SIMUL = 'Lapsilisät, äitiysavustus ja elatustuki yhteensä, MALLI'
VEROTT_KANSEL_SIMUL = 'Verottomat eläkelisät ja vammaistuet yhteensä, MALLI'
KANSEL_PERHEL_SIMUL = 'Kansaneläkkeet ja perhe-eläkkeet yhteensä (ml. takuueläke), MALLI'
ELASUMTUKI_SIMUL = 'Eläkkeensaajien asumistuki, MALLI'
ASUMTUKI_SIMUL = 'Yleinen asumistuki yhteensä, MALLI'
ASUMLISA_SIMUL = 'Opintotuen asumislisä, MALLI'
ASUMTUET_SIMUL = 'Asumistuet yhteensä, MALLI'
TOIMTUKI_SIMUL = 'Toimeentulotuki, MALLI'
VERONAL_TULOT_SIMUL = 'Veronalaiset tulonsiirrot yhteensä, MALLI'
VEROTT_TULOT_SIMUL = 'Verottomat tulonsiirrot yhteensä, MALLI'
BRUTTORAHATULO_SIMUL = 'Rahatulot ennen veroja ja vähennyksiä, MALLI'
BRUTTORAHATULO_DATA = 'Rahatulot ennen veroja ja vähennyksiä, DATA'
KAYTRAHATULO_SIMUL = 'Käytettävissä olevat rahatulot, MALLI'
KAYTRAHATULO_DATA = 'Käytettävissä olevat rahatulot (rekonstruoitu), DATA'
KAYTRAHATULO_KIRKVE_DATA = 'Käytettävissä olevat rahatulot, vähennetty kirkollisverot, DATA'
KAYTRAHATULO_KIRKVE_SIMUL = 'Käytettävissä olevat rahatulot, vähennetty kirkollisverot, MALLI'
kturaha = 'Käytettävissä olevat rahatulot (aineisto), DATA'
KAYTTULO_SIMUL = 'Käytettävissä olevat tulot, MALLI'
KAYTTULO_DATA = 'Käytettävissä olevat tulot (rekonstruoitu), DATA'
ktu = 'Käytettävissä olevat tulot (aineisto), DATA'
PTKIVERO_SIMUL = 'Kiinteistövero pientalosta, MALLI'
PTVARVO_SIMUL = 'Verotusarvo pientalosta, MALLI'
VAPKIVERO_SIMUL = 'Kiinteistövero vapaa-ajan asunnosta, MALLI'
VAPVARVO_SIMUL = 'Verotusarvo vapaa-ajan asunnosta, MALLI'
MPKIVE_SIMUL = 'Kiinteistövero maapohjasta, MALLI'
ASOYKIVERO_SIMUL = 'Kiinteistövero asunto-osakeyhtiöissä, MALLI'
KIVEROYHT_SIMUL = 'Kiinteistöverot (ml. asoy) yhteensä, MALLI'
KIVEROYHT2_SIMUL = 'Kiinteistöverot (pl. asoy) yhteensä, MALLI';
RUN;

/* 3.5 Lasketaan desiiliryhmät (desmod) uudestaan muuttujaan DESMOD_MALLI */

%Desiilit(knro, &TULO, jasenia, &KULUYKS, &PAINO, TEMP.&TULOSNIMI_KOKO)

/* 3.6 Jos käyttäjä pyytänyt, ajetaan tulonjakoindikaattorit */

%IF &KOKOindikaattorit=1 %THEN %DO;
	%KoyhInd(&RAJALKM, &KRAJA1, &KRAJA2, &KRAJA3, TEMP.&TULOSNIMI_KOKO, jasenia, &PAINO, &TULO, &KULUYKS, knro, DESMOD_MALLI, 1);
%END;

/* 3.7 Jos käyttäjä pyytänyt dataa kotitaloustasolle ,summataan henkilötason data kotitaloustasolle. */

%IF &YKSIKKO=2 %THEN %DO;
	%SumKotitT(OUTPUT.&TULOSNIMI_KOKO._KOTI, TEMP.&TULOSNIMI_KOKO, KOKO, &MUUTTUJAT);

	PROC DATASETS LIBRARY=TEMP NOLIST;
		DELETE &TULOSNIMI_KOKO;
	RUN;
	QUIT;
%END;

/* 3.8 Jos käyttäjä määritellyt YKSIKKO=1 (henkilötaso) tai YKSIKKO on mitä tahansa muuta kuin 2 (kotitaloustaso)
	niin jätetään tulostaulu henkilötasolle ja nimetään se uudelleen */

%ELSE %DO;
	PROC COPY IN=TEMP OUT=OUTPUT MOVE;
		SELECT &TULOSNIMI_KOKO;
	RUN;

	PROC DATASETS LIBRARY=OUTPUT NOLIST;
		DELETE &TULOSNIMI_KOKO._HLO;
		CHANGE &TULOSNIMI_KOKO=&TULOSNIMI_KOKO._HLO;
	RUN;
	QUIT;
%END;

/* 3.9 Tyhjennetään TEMP-kirjasto */

%IF &TEMPTYHJ = 1 %THEN %DO;
	PROC DATASETS LIBRARY=TEMP NOLIST KILL;
	RUN;
	QUIT;
%END;

%MEND KoKo_Simuloi_Data;

%KoKo_Simuloi_Data;

%LET loppui2KOKO = %SYSFUNC(TIME());

/* 4. Tulostetaan käyttäjän pyytämät taulukot */

%MACRO KutsuTulokset;
	%IF &KOKOindikaattorit=1 %THEN %DO;
		%KokoTulokset(1, KOKO, OUTPUT.&TULOSNIMI_KOKO._IND, 3);
	%END;
	%IF &KOKOsummat=1 AND &YKSIKKO=1 %THEN %DO;
		/* Tarkastetaan löytyvätkö MUUTTUJAT tulostaulusta ja palautetaan muuttujat jotka löytyvät */
		%LET MUUTTUJAT = %VarExist(&MUUTTUJAT, OUTPUT.&TULOSNIMI_KOKO._HLO);
		%KokoTulokset(1, KOKO, OUTPUT.&TULOSNIMI_KOKO._HLO, 1);

	%END;
	%IF &KOKOsummat=1 AND &YKSIKKO=2 %THEN %DO;
		%LET MUUTTUJAT = %VarExist(&MUUTTUJAT, OUTPUT.&TULOSNIMI_KOKO._KOTI);
		%KokoTulokset(1, KOKO, OUTPUT.&TULOSNIMI_KOKO._KOTI, 2);
	%END;

	/* Palautetaan EG-makromuuttujalle oletusarvo */
	%IF &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;

%MEND;
%KutsuTulokset;

/* 5. Mitataan kuinka kauan osavaiheisiin kului aikaa ja tulostetaan lokiin ajetusta kokonaisuudesta */

%LET loppui1KOKO = %SYSFUNC(TIME());

%LET kului1KOKO = %SYSEVALF(&loppui1KOKO - &alkoi1KOKO);

%LET kului2KOKO = %SYSEVALF(&loppui2KOKO - &alkoi2KOKO);

%LET kului1KOKO = %SYSFUNC(PUTN(&kului1KOKO, time10.2));

%LET kului2KOKO = %SYSFUNC(PUTN(&kului2KOKO, time10.2));

%PUT KOKO. Koko laskenta. Aikaa kului (hh:mm:ss.00) &kului1KOKO;

%PUT KOKO. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &kului2KOKO;
	
%PUT Makrojen tyyppi: &TYYPPI_KOKO;

%MACRO INFO;
%PUT Ajettiin mallit;
%PUT %SYSFUNC(IFC(&SAIRVAK = 1 ,   SAIRVAK      kyllä, SAIRVAK      ei));
%PUT %SYSFUNC(IFC(&TTURVA = 1 ,    TTURVA       kyllä, TTURVA       ei));
%PUT %SYSFUNC(IFC(&KANSEL = 1 ,    KANSEL       kyllä, KANSEL       ei));
%PUT %SYSFUNC(IFC(&KOTIHTUKI = 1 , KOTIHTUKI    kyllä, KOTIHTUKI    ei));
%PUT %SYSFUNC(IFC(&OPINTUKI = 1 ,  OPINTUKI     kyllä, OPINTUKI     ei));
%PUT %SYSFUNC(IFC(&VERO = 1 ,      VERO         kyllä, VERO         ei));
%PUT %SYSFUNC(IFC(&KIVERO = 1,     KIVERO       kyllä, KIVERO       ei));
%PUT %SYSFUNC(IFC(&LLISA = 1 ,     LLISA        kyllä, LLISA        ei));
%PUT %SYSFUNC(IFC(&ELASUMTUKI = 1, ELASUMTUKI   kyllä, ELASUMTUKI   ei));
%PUT %SYSFUNC(IFC(&ASUMTUKI = 1 ,  ASUMTUKI     kyllä, ASUMTUKI     ei));
%PUT %SYSFUNC(IFC(&PHOITO = 1 ,    PHOITO       kyllä, PHOITO       ei));
%PUT %SYSFUNC(IFC(&TOIMTUKI = 1 ,  TOIMTUKI     kyllä, TOIMTUKI     ei));
%MEND INFO;

%INFO;

/* 6. Palautetaan OUT-makromuuttujan arvoksi 0 */
%LET OUT = 0;
