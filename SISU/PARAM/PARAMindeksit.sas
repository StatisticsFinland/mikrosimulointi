/******************************************************************************
* Kuvaus: Parametritaulujen sekä indeksien hallinnointiohjelmat
* Toimii perusvuodella 2020
* Päivitetty viimeksi: 19.1.2023				     					      
******************************************************************************/

/*=============================================================================
Sisältää:

- Massapäivittämisohjelman, jolla kaikki parametritaulut voidaan päivittää
tulevaisuuteen indeksisidonnaisten parametrien osalta.

Apuohjelmat:
- Indeksien lukemiseen liittyvä apuohjelma IndArvot
- Parametrien sidonnaisuuksiin liittyvä apuohjelma ParamTaulut
-----------------------------------------------------------------------------*/

/* Valtion tuloveroasteikon (Raja1--Raja12, Vakio1--Vakio12) indeksointiin */

%LET TULORAJA = 0; * Tuloveroasteikon indeksointi (0 = ei käytössä 1 = käytössä);  


/*=============================================================================
#1: IndArvot -apumakro


Makro indeksien arvojen noutamiseksi. Tätä kutsutaan osana indeksien 
päivitysmakroja. Tätä muokkaamalla voidaan vaihtaa indeksien sisältöjä,
tai noutaa uusia indeksejä taulusta. Makro saa tarvittavat arvot
ohjelmassa, jossa sitä kutsutaan.
-----------------------------------------------------------------------------*/
%macro IndArvot(INDTAULU) /
		DES = 'Indeksien arvojen noutaminen indeksitauluista';
	
	proc sql noprint;

		select min(vuosi) into :ALKU
		from &INDTAULU;

		select max(vuosi) into :LOPPU
		from &INDTAULU;
 	

	%do QZ = &ALKU %to &LOPPU;
		%GLOBAL ansio64&QZ ansio64kolmas&QZ IndKel&QZ TEL8020&QZ
				ind51&QZ ind51loka&QZ IndOpt2010&QZ palkvahpros&QZ palkvahpros100&QZ
				elvakmaks&QZ korelvakmaks&QZ
				svpro&QZ svprmaks&QZ elkorsvmaks&QZ tyotvakmaks&QZ vuokraind&QZ;
	%end;

		/*=====================================================================
		Ansiotasoindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ansio64 into :ansio64&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ANSIOTASOINDEKSI &QZ: &&ansio64&QZ;
		%end;

		/*=====================================================================
		Ansiotasoindeksi (kolmas vuosineljännes)
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ansio64kolmas into :ansio64kolmas&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ANSIOTASOINDEKSI KOLMANNELLA VUOSINELJÄNNEKSELLÄ &QZ: &&ansio64kolmas&QZ;
		%end;

		/*=====================================================================
		Kansaneläkeindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndKel into :IndKel&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: KANSANELÄKEINDEKSI &QZ: &&IndKel&QZ;
		%end;

		/*=====================================================================
		Palkkakerroin
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select TEL8020 into :TEL8020&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: PALKKAKERROIN &QZ: &&TEL8020&QZ;
		%end;

		/*=====================================================================
		Elinkustannusindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ind51 into :ind51&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ELINKUSTANNUSINDEKSI &QZ: &&ind51&QZ;
		%end;

		/*=====================================================================
		Elinkustannusindeksi: lokakuu
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ind51loka into :ind51loka&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ELINKUSTANNUSINDEKSI LOKAKUU &QZ: &&ind51loka&QZ;
		%end;

		/*=====================================================================
		Opetustoimen hintaindeksi 2010
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndOpt2010 into :IndOpt2010&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: OPETUSTOIMEN HINTAINDEKSI &QZ: &&IndOpt2010&QZ;
		%end;

		/*=====================================================================
		Työeläkeindeksi 20-80
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select TEL2080 into :TEL20&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: TYÖELÄKEINDEKSI &QZ: &&TEL20&QZ;
		%end;

		/*=====================================================================
		Sairauspäivärahan vakuutuspalkan prosenttivähennys
		/*---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select palkvahpros100 into :palkvahpros100&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Sairauspäivärahan vakuutuspalkan prosenttivähennys &QZ: &&palkvahpros100&QZ;
		%end;

		/*=====================================================================
		Vakuutuspalkan prosenttivähennys
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select palkvahpros into :palkvahpros&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Vakuutuspalkan prosenttivähennys &QZ: &&palkvahpros&QZ;
		%end;

		/*=====================================================================
		Työntekijän työeläkemaksu
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select elvakmaks into :elvakmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Työntekijän työeläkemaksu &QZ: &&elvakmaks&QZ;
		%end;
		
		/*=====================================================================
		Korotettu työntekijän työeläkemaksu
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select korelvakmaks into :korelvakmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Korotettu työntekijän työeläkemaksu &QZ: &&korelvakmaks&QZ;
		%end;
		
		/*=====================================================================
		Sairaanhoitomaksu palkansaajilla ja yrittäjillä
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select svpro into :svpro&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Sairaanhoitomaksu palkansaajilla ja yrittäjillä &QZ: &&svpro&QZ;
		%end;
		
		/*=====================================================================
		Päivärahamaksu palkansaajilla
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select svprmaks into :svprmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Päivärahamaksu palkansaajilla &QZ: &&svprmaks&QZ;
		%end;

		/*=====================================================================
		Sairaanhoitomaksun lisäprosentti eläkeläisillä
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select elkorsvmaks into :elkorsvmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Sairaanhoitomaksun lisäprosentti eläkeläisillä &QZ: &&elkorsvmaks&QZ;
		%end;
		
		/*=====================================================================
		Työttömyysvakuutusmaksu työntekijällä
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select tyotvakmaks into :tyotvakmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Työttömyysvakuutusmaksu työntekijällä &QZ: &&tyotvakmaks&QZ;
		%end;	

		/*=====================================================================
		Vuokraindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select vuokraind into :vuokraind&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Vuokraindeksi &QZ: &&vuokraind&QZ;
		%end;	

	quit;

%mend IndArvot;


/*=============================================================================
#2 ParamTaulut -apumakro

ParamTaulut -ohjelma sisältää parametritaulujen indeksisidonnaiset
parametrit, niihin liittyvän indeksin, sekä pyöristystarkkuuden. Ohjelmaa
kutsutaan osana massa- ja yksittäispäivityksiä, eikä se näin ole standalone.

Makro saa kutsun ja tiedon parametritaulun sijainnista makrosta, jossa se 
ajetaan. Tätä muokkaamalla voidaan vaihtaa indeksisidonnaisuuksia, 
lisätä tauluihin päivitettäviä indeksejä, sekä muokata pyöristystarkkuutta.
-----------------------------------------------------------------------------*/
%macro ParamTaulut /DES = 'Parametrien listaukset tauluissa';

	/*=========================================================================
	Päivitys: opintotuki 
	-------------------------------------------------------------------------*/

	%if %length (&POPINTUKI) > 0 %then %do;
		%luo(&POPINTUKI)
		%PaivitaOTTuloRaja(OpTuloRaja, ansio64kolmas, &POPINTUKI, 1)
		%PaivitaOTTuloRaja(OpTuloRaja2, ansio64kolmas, &POPINTUKI, 1)
		%PaivitaOTTuloRaja(TakPerRaja, ansio64kolmas, &POPINTUKI, 1)
		%PaivitaOTTuloRaja(TakPerAlaRaja, ansio64kolmas, &POPINTUKI, 1)
		%PaivitaOpintuki(MuuMuu20, IndKel, &POPINTUKI, .01, 2019, 250.28)
		%PaivitaOpintuki(MuuMuuAlle20b, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(MuuVanhAlle20b, IndKel, &POPINTUKI, .01, 2019, 59.01)
		%PaivitaOpintuki(MuuVanh20b, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(KorkMuuAlle20b, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(KorkVanhAlle20b, IndKel, &POPINTUKI, .01, 2019, 59.01)
		%PaivitaOpintuki(KorkVanh20b, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(OpMatLisa, IndKel, &POPINTUKI, .01, 2019, 46.8)
		%PaivitaOpintuki(HuoltKor, IndKel, &POPINTUKI, .01, 2023, 141.63)
		%PaivitaOpintuki(MuuMuuAlle20, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(MuuVanhAlle20, IndKel, &POPINTUKI, .01, 2019, 38.66)
		%PaivitaOpintuki(MuuVanh20, IndKel, &POPINTUKI, .01, 2019, 81.39)
		%PaivitaOpintuki(KorkMuuAlle20, IndKel, &POPINTUKI, .01, 2019, 101.74)
		%PaivitaOpintuki(KorkMuu20, IndKel, &POPINTUKI, .01, 2019, 250.28)
		%PaivitaOpintuki(KorkVanhAlle20, IndKel, &POPINTUKI, .01, 2019, 38.66)
		%PaivitaOpintuki(KorkVanh20, IndKel, &POPINTUKI, .01, 2019, 81.39)
	%end;

	/*=========================================================================
	Päivitys: toimeentulotuki
	-------------------------------------------------------------------------*/
	%if %length(&PTOIMTUKI) > 0 %then %do;
		%luo(&PTOIMTUKI)
		%paivita(YksinKR1, IndKel, &PTOIMTUKI, .01, 2011, 463.77)
		%paivita(YksinKR2, IndKel, &PTOIMTUKI, .01, 2011, 463.77)
	%end;

	/*=========================================================================
	Päivitys: työttömyysturva
	-------------------------------------------------------------------------*/
	%if %length(&PTTURVA) > 0 %then %do;
		%luo(&PTTURVA);
		%paivita(TTPerus, IndKel, &PTTURVA, .01, 2019, 33.33)
/*		%paivita(TTLaps1, IndKel, &PTTURVA, .01, 2019, 5.23)*/
/*		%paivita(TTLaps2, IndKel, &PTTURVA, .01, 2019, 7.68)*/
/*		%paivita(TTLaps3, IndKel, &PTTURVA, .01, 2019, 9.90)*/
		%kytkentaSVTT1(VahPros, palkvahpros, &PTTURVA)
	%end;

	/*=========================================================================
	Päivitys: asumistuki
	-------------------------------------------------------------------------*/
	%if %length(&PASUMTUKI) > 0 %then %do;
		%luo(&PASUMTUKI)
		%PaivitaTaannehtiva1(Kattovuokra_1_1, Ind51loka, &PASUMTUKI, 1, 2017, 492)
		%PaivitaTaannehtiva1(Kattovuokra_1_2, Ind51loka, &PASUMTUKI, 1, 2017, 706)
		%PaivitaTaannehtiva1(Kattovuokra_1_3, Ind51loka, &PASUMTUKI, 1, 2017, 890)
		%PaivitaTaannehtiva1(Kattovuokra_1_4, Ind51loka, &PASUMTUKI, 1, 2017, 1038)
		%PaivitaTaannehtiva1(Kattovuokra_1_Plus, Ind51loka, &PASUMTUKI, 1, 2017, 130)
		%PaivitaTaannehtiva1(Kattovuokra_2_1, Ind51loka, &PASUMTUKI, 1, 2017, 390)
		%PaivitaTaannehtiva1(Kattovuokra_2_2, Ind51loka, &PASUMTUKI, 1, 2017, 570)
		%PaivitaTaannehtiva1(Kattovuokra_2_3, Ind51loka, &PASUMTUKI, 1, 2017, 723)
		%PaivitaTaannehtiva1(Kattovuokra_2_4, Ind51loka, &PASUMTUKI, 1, 2017, 856)
		%PaivitaTaannehtiva1(Kattovuokra_2_Plus, Ind51loka, &PASUMTUKI, 1, 2017, 117)
		%PaivitaTaannehtiva1(Kattovuokra_3_1, Ind51loka, &PASUMTUKI, 1, 2017, 344)
		%PaivitaTaannehtiva1(Kattovuokra_3_2, Ind51loka, &PASUMTUKI, 1, 2017, 501)
		%PaivitaTaannehtiva1(Kattovuokra_3_3, Ind51loka, &PASUMTUKI, 1, 2017, 641)
		%PaivitaTaannehtiva1(Kattovuokra_3_4, Ind51loka, &PASUMTUKI, 1, 2017, 764)
		%PaivitaTaannehtiva1(Kattovuokra_3_Plus, Ind51loka, &PASUMTUKI, 1, 2017, 112)
/*		%PaivitaTaannehtiva1(Kattovuokra_4_1, Ind51loka, &PASUMTUKI, 1, 2017, 344)*/
/*		%PaivitaTaannehtiva1(Kattovuokra_4_2, Ind51loka, &PASUMTUKI, 1, 2017, 501)*/
/*		%PaivitaTaannehtiva1(Kattovuokra_4_3, Ind51loka, &PASUMTUKI, 1, 2017, 641)*/
/*		%PaivitaTaannehtiva1(Kattovuokra_4_4, Ind51loka, &PASUMTUKI, 1, 2017, 764)*/
/*		%PaivitaTaannehtiva1(Kattovuokra_4_Plus, Ind51loka, &PASUMTUKI, 1, 2017, 112)*/
		%paivita(PerusOmaVakio, IndKel, &PASUMTUKI, 1, 2010, 555)
		%paivita(PerusOmaAikuinenKerroin, IndKel, &PASUMTUKI, 1, 2010, 78)
		%paivita(PerusOmaLapsiKerroin, IndKel, &PASUMTUKI, 1, 2010, 246)
		%paivita(HuomVesi, IndKel, &PASUMTUKI, 1, 2010, 17)
		%paivita(HuomLampo1, IndKel, &PASUMTUKI, 1, 2010, 38)
		%paivita(HuomLampoPlus, IndKel, &PASUMTUKI, 1, 2010, 13)
/*		%paivita(OKTaloHNormi1, IndKel, &PASUMTUKI, 1, 2010, 89)*/
/*		%paivita(OKTaloHNormi2, IndKel, &PASUMTUKI, 1, 2010, 107)*/
/*		%paivita(OKTaloHNormi3, IndKel, &PASUMTUKI, 1, 2010, 135)*/
/*		%paivita(OKTaloHNormi4, IndKel, &PASUMTUKI, 1, 2010, 159)*/
/*		%paivita(OKTaloHNormiPlus, IndKel, &PASUMTUKI, 1, 2010, 49)*/

	%end;

	/*=========================================================================
	Päivitys: eläkkeensaajan asumistuki
	-------------------------------------------------------------------------*/
	%if %length(&PELASUMTUKI) > 0 %then %do;
		%luo(&PELASUMTUKI)
		%paivita(EPieninTukiKk, IndKel, &PELASUMTUKI, .01, 2001, 5.38)
		%paivita(LisOVRaja, IndKel, &PELASUMTUKI, 1, 2001, 7415)
		%paivita(LisOVRaja2, IndKel, &PELASUMTUKI, 1, 2001, 10637)
		%paivita(LisOVRaja3, IndKel, &PELASUMTUKI, 1, 2001, 12106)
		%paivita(LisOVRaja4, IndKel, &PELASUMTUKI, 1, 2001, 7415)
		%paivita(LisOVRaja5, IndKel, &PELASUMTUKI, 1, 2001, 12106)
		%paivita(OmRaja, IndKel, &PELASUMTUKI, 1, 2001, 10820)
		%paivita(OmRaja2, IndKel, &PELASUMTUKI, 1, 2001, 17312)
		%paivita(PerusOVast, IndKel, &PELASUMTUKI, .01, 2001, 491.51)
	%end;

	/*=========================================================================
	Päivitys: kansaneläke
	-------------------------------------------------------------------------*/
	%if %length(&PKANSEL) > 0 %then %do;
		%luo(&PKANSEL)
		%paivita(ApuLis, IndKel, &PKANSEL, .01, 2001, 72.57)
		%paivita(HoitoLis, IndKel, &PKANSEL, .01, 2001, 106.89)
		%paivita(HoitTukiNorm, IndKel, &PKANSEL, .01, 2001, 56.78)
		%paivita(HoitTukiKor, IndKel, &PKANSEL, .01, 2001, 123.70)
		%paivita(HoitTukiErit, IndKel, &PKANSEL, .01, 2001, 261.57)
		%paivita(KELaps, IndKel, &PKANSEL, .01, 2001, 17.66)
		%paivita(KEMinimi, IndKel, &PKANSEL, .01, 2001, 5.38)
		%paivita(KERaja, IndKel, &PKANSEL, 1, 2001, 536) 
		%paivita(LaitosTaysiY1, IndKel, &PKANSEL, .01, 2001, 528.50)
		%paivita(LaitosTaysiY2, IndKel, &PKANSEL, .01, 2001, 528.50)
		%paivita(LaitosTaysiP1, IndKel, &PKANSEL, .01, 2001, 471.84)
		%paivita(LaitosTaysiP2, IndKel, &PKANSEL, .01, 2001, 471.84)
		%paivita(LapsElPerus, IndKel, &PKANSEL, .01, 2001, 48.05)
		%paivita(LapsElTayd, IndKel, &PKANSEL, .01, 2001, 72.68)
		%paivita(LapsElMinimi, IndKel, &PKANSEL, .01, 2001, 5.38)
		%paivita(LapsHoitTukNorm, IndKel, &PKANSEL, .01, 2001, 74.19)
		%paivita(LapsHoitTukKorot, IndKel, &PKANSEL, .01, 2001, 173.12)
		%paivita(LapsHoitTukErit, IndKel, &PKANSEL, .01, 2001, 335.69)
		%paivita(LeskAlku, IndKel, &PKANSEL, .01, 2001, 261.15)
		%paivita(LeskPerus, IndKel, &PKANSEL, .01, 2001, 81.80)
		%paivita(LeskTaydY1, IndKel, &PKANSEL, .01, 2001, 424.55)
		%paivita(LeskTaydY2, IndKel, &PKANSEL, .01, 2001, 424.55)
		%paivita(LeskTaydP1, IndKel, &PKANSEL, .01, 2001, 367.33)
		%paivita(LeskTaydP2, IndKel, &PKANSEL, .01, 2001, 367.33)
		%paivita(LeskMinimi, IndKel, &PKANSEL, .01, 2001, 5.38)	
		%paivita(RiLi, IndKel, &PKANSEL, .01, 2001, 1635.24)
		%paivita(TakuuEl, IndKel, &PKANSEL, .01, 2001, 665.37)
		%Kytkenta(RajaTyotulo, &PKANSEL, TakuuEl, &PKANSEL, 2019)
		%paivita(TaysKEY1, IndKel, &PKANSEL, .01, 2001, 528.50)
		%paivita(TaysKEY2, IndKel, &PKANSEL, .01, 2001, 528.50)
		%paivita(TaysKEP1, IndKel, &PKANSEL, .01, 2001, 471.84)
		%paivita(TaysKEP2, IndKel, &PKANSEL, .01, 2001, 471.84)
		%paivita(VammNorm, IndKel, &PKANSEL, .01, 2001, 74.19)
		%paivita(VammKorot, IndKel, &PKANSEL, .01, 2001, 173.12)
		%paivita(VammErit, IndKel, &PKANSEL, .01, 2001, 335.69)
		%paivita(VeterLisa, IndKel, &PKANSEL, .01, 2001, 85.70)
		%paivita(YliRiliMinimi, IndKel, &PKANSEL, .01, 2001, 5.19)
		%paivita(YliRiliRaja, IndKel, &PKANSEL, .01, 2001, 873.81)
		%paivita(YliRiliAskel, IndKel, &PKANSEL, .01, 2001, 58.36)
		%paivita(YliRiliAskel2, IndKel, &PKANSEL, .01, 2001, 144.38)
	%end;

	/*=========================================================================
	Päivitys: kotihoidon tuki
	-------------------------------------------------------------------------*/
	%if %length(&PKOTIHTUKI) > 0 %then %do;
		%luo(&PKOTIHTUKI)
		%paivita(Lisa, IndKel, &PKOTIHTUKI, .01, 2010, 168.19)
		%paivita(OsRaha, IndKel, &PKOTIHTUKI, .01, 2013, 96.41)
		%paivita(Perus, IndKel, &PKOTIHTUKI, .01, 2010, 314.28)
		%paivita(Sisar, IndKel, &PKOTIHTUKI, .01, 2010, 94.09)
		%paivita(Sisarmuu, IndKel, &PKOTIHTUKI, .01, 2010, 60.46)
		%paivita(JsRaha1, IndKel, &PKOTIHTUKI, .01, 2013, 240.00)
		%paivita(JsRaha2, IndKel, &PKOTIHTUKI, .01, 2013, 160.00)

	%end;

	/*=====================================================================
	Päivitys: päivähoito
	---------------------------------------------------------------------*/
	%if %length(&PPHOITO) > 0 %then %do;
		%luo(&PPHOITO)
		%PaivitaPhoito(PHRaja1, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHRaja2, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHRaja3, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHRaja4, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHRaja5, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHVahenn, ansio64, &PPHOITO, 1)
		%PaivitaPhoito(PHYlaRaja, IndOpt2010, &PPHOITO, 1)
		%PaivitaPhoito(PHAlaRaja, IndOpt2010, &PPHOITO, 1)
	%end;

	/*=========================================================================
	Päivitys: lapsilisä
	-------------------------------------------------------------------------*/
	%if %length (&PLLISA) > 0 %then %do;
		%luo(&PLLISA)
		%PaivitaTaannehtiva1(AlenElatTuki, Ind51loka, &PLLISA, .01, 2019, 165.74)
		%PaivitaTaannehtiva1(ElatTuki, Ind51loka, &PLLISA, .01, 2019, 165.74)
	%end;

	/*=========================================================================
	Päivitys: sairausvakuutus
	-------------------------------------------------------------------------*/
	%if %length (&PSAIRVAK) > 0 %then %do;
		%luo(&PSAIRVAK)
		%paivita(Minimi, IndKel, &PSAIRVAK, .01, 2010, 26.62)
		%Kytkenta(VanhMin, &PSAIRVAK, Minimi, &PSAIRVAK, 2005)	
		%paivita(SRaja1, TEL8020, &PSAIRVAK, 1, 2010, 1264)
		%paivita(SRaja2, TEL8020, &PSAIRVAK, 1, 2010, 20780)
		%paivita(SRaja2Vanh, TEL8020, &PSAIRVAK, 1, 2010, 32892)
		%paivita(SRaja3, TEL8020, &PSAIRVAK, 1, 2010, 50606)
		%kytkentaSVTT1(PalkVah, PalkVahPros100, &PSAIRVAK)
	%end;

	/*=========================================================================
	Päivitys: kiinteistövero (ei indeksipäivitettäviä parametreja)
	-------------------------------------------------------------------------*/
	%if %length(&PKIVERO) > 0 %then %do;
		%luo(&PKIVERO)
	%end;

	/*=========================================================================
	Päivitys: vero
	-------------------------------------------------------------------------*/
	%if %length (&PVERO) > 0 %then %do;
		%luo(&PVERO)
		%kytkentaSVTT1(ElVakMaksu, elvakmaks, &PVERO)
		%kytkentaSVTT1(KorElVakMaksu, korelvakmaks, &PVERO)
		%kytkentaSVTT1(SvPros, svpro, &PVERO)
		%kytkentaSVTT1(SvPrMaksu, svprmaks, &PVERO)
		%kytkentaSVTT1(ElKorSvMaksu, elkorsvmaks, &PVERO)
		%kytkentaSVTT1(TyotVakMaksu, tyotvakmaks, &PVERO)

		%IF &TULORAJA = 1 %then %do;	
			%tulorajat(Ind51);
		%end;

		/*=====================================================================
		Nämä kytkennät liittyvät KANSEL -mallin päivityksiin. 
		Kansaneläkkeen noustessa kunnallisverotuksen eläketulovähennystä
		korjataan.
		---------------------------------------------------------------------*/
			%if %length (&PKANSEL) > 0 %then %do;
				%kytkentaV1(KelaPuol, &PKANSEL, &PVERO)
				%kytkentaV1(KelaYks, &PKANSEL, &PVERO)
			%end;
	%end;

%mend ParamTaulut;

/*=============================================================================
#3 Param_Paivitys -ohjelma

Ohjelma päivittää massana perusvuoden (pvuosi) ja tavoitevuoden (tvuosi)
aikavälin. Ensimmäinen päivitettävä vuosi on pvuosi+1.
Hyödynnettävissä mm. tulevaisuuteen kohdistuvien muutosten 
päivittämiseksi (indeksiennusteet). Parametrit päivitetään pääosin vuoden
alkuihin (pl. poikkeukselliset tapaukset, kuten päivähoidon parametrit,
joka noudattaa normaalia sykliään). Parametritauluissa oltava rivit!


Tarvitsee:
	- Perusvuoden ja viimeisen vuoden (ensimmäiset kaksi parametria)
	- Indeksitaulun sijainnin ja nimen
	- Parametritaulujen nimet (param.kansiossa) jotka päivitetään
	- Kaksi viimeistä riviä määrittävät kuukauden ja vuoden, jotka päivitetään

Tuottaa:
	- work -kansioon päivitetyt parametritaulut
	- jos jätät parametritaulun nimen tyhjäksi, ao. taulua ei päivitetä	

1.	Ajettuasi tämän PARAMindeksit-ohjelman kokonaisuudessaan, tee parametrien
	päivitys kutsumalla ParamPaivitys-makroa. Tässä esimerkki makrokutsusta:

%ParamPaivitys(
	pvuosi = 2025, 
	tvuosi = 2029, 
	indtaulu = param.pindeksi_vuosi,
	popintuki = popintuki,
	ptoimtuki = ptoimtuki, 
	ptturva = ptturva,
	pasumtuki = pasumtuki,
	pelasumtuki = pelasumtuki,
	pkansel = pkansel,
	pkotihtuki = pkotihtuki,
	pphoito = pphoito,
	pllisa = pllisa,
	psairvak = psairvak,
	pkivero = pkivero,
	pvero = pvero
	);


2. Mahdollisuus vertailla uusia tauluja edellisiin:

		%let vertailu_taulu = ptoimtuki;

		proc compare	base = param.&vertailu_taulu 	compare = work.&vertailu_taulu;
		run;

3. Parametritaulujen siirto workista param-kansioon:

		proc copy in=WORK out=PARAM memtype=data;
		   select popintuki ptoimtuki ptturva pasumtuki pelasumtuki pkansel pkotihtuki pphoito pllisa psairvak pkivero pvero;
		run;


-----------------------------------------------------------------------------*/



%macro ParamPaivitys (PVUOSI, TVUOSI, INDTAULU,
		POPINTUKI, PTOIMTUKI, PTTURVA, PASUMTUKI, PELASUMTUKI, PKANSEL, 
		PKOTIHTUKI, PPHOITO, PLLISA, PSAIRVAK, PKIVERO, PVERO) /
		DES = 'Parametritaulujen massapäivitysohjelma';

		%let _notes = %sysfunc(getoption(NOTES));
		options nonotes;

		/*=====================================================================
		Virheabortit (päivitysrajoitukset, jotka katkaisevat ohjelman
		jos virheellisiä asetuksia on annettu)
		---------------------------------------------------------------------*/
		%if %length(&PKANSEL) > 0 and %length(&PVERO) < 1 %then %do;
		%put WARNING: Vero -parametrit parametritaulun nimi puuttuu.;
		%put WARNING: Kansel -parametreja päivitettäessä VERO päivitettävä.;
		%put WARNING: VERO-parametrit KelaYks ja KelaPuol päivittämättä.;
		%put WARNING: PARAMETRITAULUJEN PÄIVITYSTÄ JATKETAAN.;

		%end;

		/*=====================================================================
		Indeksitaulun tarkastus		
		---------------------------------------------------------------------*/
		proc sql noprint;
			select max(vuosi) into :cap from &indtaulu;
			select min(vuosi) into :floor from &indtaulu;
		quit;

		%if (&pvuosi < &floor or &tvuosi > &cap) %then %do;
			%if &pvuosi < &floor %then %do;
			%put WARNING: Indeksikorjausten vuosi alle taulussa olevan vuoden.;
			%end;

			%if &tvuosi > &cap %then %do;
			%put WARNING: Indeksikorjausten vuosi yli taulussa olevan vuoden.;
			%end;

			%put WARNING: PARAMETRITAULUJEN PÄIVITYS KESKEYTETTY.;
			%goto exit;
		%end;

	/*========================================================================
	Apumakro: Indeksien arvojen noutaminen
	-------------------------------------------------------------------------*/
	%IndArvot(&INDTAULU);

	/*=========================================================================
	Apumakro: päivityksen pohjataulut work -kansioon
	-------------------------------------------------------------------------*/
	%macro Luo(LUOTAULU) / DES = 'Apumakro taulujen luomiseen work -kansioon';

		proc sql noprint;
				create table &LUOTAULU as select * from PARAM.&LUOTAULU;

		/*=====================================================================
		Tarkastetaan vuoden olemassaolo, luodaan tarvittaessa
		---------------------------------------------------------------------*/
			%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
			%do QD = 1 %to &MAX;  
			%let LVUOSI = %sysevalf(&PVUOSI+&QD);

				select max(vuosi) into :VUOSICHECK
				from &LUOTAULU;

				%if &VUOSICHECK < &LVUOSI %then %do;

					%put WARNING: Parametritaulussa &LUOTAULU ei kaikkia vuosia.;
					%put WARNING: Vuoden &LVUOSI lainsäädännön pohja;
					%put WARNING: on kopio vuodesta &VUOSICHECK.;

		/*=====================================================================
		Tavalliset parametritaulut
		---------------------------------------------------------------------*/
					%if &LUOTAULU ^= &PPHOITO AND &LUOTAULU ^= &POPINTUKI AND &LUOTAULU ^= &PVERO AND &LUOTAULU ^= &PKIVERO %then %do;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK and kuuk = (select max(kuuk) from &LUOTAULU where vuosi = &VUOSICHECK);

						update _temp set vuosi = &LVUOSI;
						update _temp set kuuk = 1;
						insert into &LUOTAULU select * from _temp;
						drop table _temp;

					%end;

		/*=====================================================================
		Vero- ja kiinteistöveromallin parametritaulujen erikoistapaukset
		---------------------------------------------------------------------*/
					%if &LUOTAULU = &PVERO OR &LUOTAULU = &PKIVERO %then %do;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK;

						update _temp set vuosi = &LVUOSI;
						insert into &LUOTAULU select * from _temp;
						drop table _temp;

					%end;

		/*=====================================================================
		Opintotuen parametritaulun erikoistapaus
		---------------------------------------------------------------------*/
					%if &LUOTAULU = &POPINTUKI %then %do;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK and kuuk = (select max(kuuk) from &LUOTAULU where vuosi = &VUOSICHECK);

						update _temp set vuosi = &LVUOSI;
						update _temp set kuuk = 1;
						insert into &LUOTAULU select * from _temp;

						update _temp set vuosi = &LVUOSI;
						update _temp set kuuk = 8;
						insert into &LUOTAULU select * from _temp;

						drop table _temp;
					%end;

		/*=====================================================================
		Päivähoidon parametritaulun erityistapaus
		---------------------------------------------------------------------*/
					%if &LUOTAULU = &PPHOITO %then %do;

						select vuosi into :check from &LUOTAULU
						where vuosi = %sysevalf(&LVUOSI-1) and kuuk = 8;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK
						%if %symexist(check) = 1 %then %do;
							%if &check = %sysevalf(&LVUOSI-1) %then %do;
							and kuuk = 8
							%end;
						%end;;
						
						update _temp set vuosi = &LVUOSI;
						update _temp set kuuk = 1;
						insert into &LUOTAULU select * from _temp;

		/*=====================================================================
		Lisätään rivi ja 8. kuukausi, jos päivitysvuosi
		---------------------------------------------------------------------*/
							%if %symexist(check) = 0
								%then %do;
								update _temp set kuuk = 8;
								insert into &LUOTAULU select * from _temp;
							%end;
							%else %do;
								%if &check = %sysevalf(&LVUOSI-2) %then %do;
								update _temp set kuuk = 8;
								insert into &LUOTAULU select * from _temp;
								%end;
							%end;
						%end;
					%end;
				%end;
		quit;

		/*=====================================================================
		Järjestetään taulut
		---------------------------------------------------------------------*/
		%if &LUOTAULU ^= &PPHOITO AND &LUOTAULU ^= &POPINTUKI %then %do;
			proc sort data = &LUOTAULU; by descending vuosi;run;
		%end;

		%if &LUOTAULU = &PPHOITO OR &LUOTAULU = &POPINTUKI %then %do;
			proc sort data = &LUOTAULU; by descending vuosi descending kuuk;run;
		%end;
	%mend Luo;



	/********************************************************************************************************************************************************
	********************************************************************************************************************************************************/

	/*=========================================================================
	Parametritaulujen päivitysmakro
	-------------------------------------------------------------------------*/
	%macro Paivita(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
	/ DES = 'Taulujen päivitysmakro';

	/*=========================================================================
	Päivitysohjelman runko: taulujen päivittäminen
	-------------------------------------------------------------------------*/
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&LVUOSI-1);
		%let JVUOSI = 2023;

		/*=====================================================================
		Jatketaan päivittämistä
		HUOM! Tässä kohtaa eritelty sairausvakuutuksen tulorajojen
		eurokatkaisut (parametria ei pyöristetä, vaan katkaistaan 
		kokonaiseuroon, ts. int).
		---------------------------------------------------------------------*/
		proc sql noprint;

				*Päivitetään niiden osamallien taulut, joissa indeksijäädytettäviä arvoja;
				%if (&PTAULU = pasumtuki OR &PTAULU = pelasumtuki OR &PTAULU = pkotihtuki 
					 OR &PTAULU = popintuki OR &PTAULU = psairvak OR &PTAULU = ptturva)

						%then %do;

								*IndKel-sidonnaisten arvojen jäädytys;
								%if (&IND = IndKel)

									%then %do;

										*Ehto ottaa huomioon mikäli LVUOSI 2024 - 2027;
										%if (&LVUOSI >= 2024 AND &LVUOSI <= 2027)
											
											%then %do;
												update &PTAULU
												set &PARAM = 

													round(
													((&&&IND&JVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
													, &RND)

												where vuosi = &LVUOSI;
											%end;

										*Ehto ottaa huomioon mikäli IndKel arvo on yli 2009 ennen vuotta 2028;
										%if (&&&IND&LVUOSI > 2009)
											
											%then %do;
												update &PTAULU
												set &PARAM = 

												round(
												(SUM(&&&IND&LVUOSI, -SUM(2009, -1805))/(&&&IND&LPVUOSI)) * &LPTASO
												, &RND)

												where vuosi = &LVUOSI;
											%end;
										
									    *Ehto laskee kelasidonnaisen etuuden arvon vuodelle 2028 ja eteenpäin;
										%if (&LVUOSI >= 2028)
											
											%then %do;
												update &PTAULU
												set &PARAM = 

													round(
													(SUM(&&&IND&LVUOSI, -SUM(2009, -1805))/(&&&IND&LPVUOSI)) * &LPTASO
													, &RND)

												where vuosi = &LVUOSI;
											%end;

									%end;


									%else %do;
										%if (&PARAM = SRaja1 or &PARAM = SRaja2 or &PARAM = SRaja3)

											%then %do;
												update &PTAULU
												set &PARAM = 

													int(
													((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
													)

												where vuosi = &LVUOSI;
											%end;

											%else %do;
												update &PTAULU
												set &PARAM = 

													round(
													((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
													, &RND)

												where vuosi = &LVUOSI;
											%end;

									%end;

						%end;

						%else %do;						
							update &PTAULU
							set &PARAM = 

								round(
								((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
								, &RND)

							where vuosi = &LVUOSI;
						%end;

		quit;

		%end;

	%mend Paivita;

	/********************************************************************************************************************************************************
	********************************************************************************************************************************************************/

	/*=========================================================================
	Päivitysmakro, jossa indeksikorotuksen perusteena on indeksin muutos
	vuodesta päivitysvuosi-2 vuoteen päivitysvuosi-1
	-------------------------------------------------------------------------*/
	%MACRO PaivitaTaannehtiva1(param, ind, ptaulu, rnd, perusvuosi, arvo);

		%LET MAX = %SYSEVALF(&TVUOSI-&PVUOSI);

		%DO QD = 1 %TO &MAX;  

			%LET E2VUOSI = %SYSEVALF(&PVUOSI+&QD-2);
			%LET EVUOSI = %SYSEVALF(&PVUOSI+&QD-1);
			%LET LVUOSI = %SYSEVALF(&PVUOSI+&QD);

			PROC SQL NOPRINT;

				SELECT &param INTO :TASO FROM &ptaulu
				WHERE Vuosi = &EVUOSI;

				
					%if &EVUOSI = &perusvuosi %then %do;
						UPDATE &ptaulu
							SET &param = ROUND(((&&&ind&EVUOSI)/(&&&ind&E2VUOSI)) * &arvo, &rnd)
					%end; 

					/*Indeksijäädytykset*/
					%else %if (&LVUOSI >= 2024 AND &LVUOSI <= 2027) AND (&PTAULU = pasumtuki) %then %do;

						%if (&LVUOSI >= 2024 AND &LVUOSI <= 2027) %then %do;
							/*Ei tehdä mitään, koska arvoille ei haluta tehdä indeksikorotusta*/
						%end;

						/*Lain viimeinen soveltamisvuosi, jos kelaindeksi > 2009*/
						%if (&&&INDKEL&LVUOSI > 2009) %then %do;
							update &PTAULU
								set &PARAM = ROUND(((&&&ind&EVUOSI)/(2461)) * &taso, &rnd)
								where vuosi = &LVUOSI;
						%end;			
					%end; 

					/*Normaalit korotukset*/
					%else %do;
						update &PTAULU
							set &PARAM = ROUND(((&&&ind&EVUOSI)/(&&&ind&E2VUOSI)) * &taso, &rnd)
							where Vuosi = &LVUOSI;
					%end; 
				QUIT;
			%END;
		
	%MEND PaivitaTaannehtiva1;

	/*=========================================================================
	Päivähoito -taulu tarvitsee oman päivitysaliohjelman päivähoitoihin
	liittyvien elokuutarkastusten johdosta.
	-------------------------------------------------------------------------*/
	%macro PaivitaPhoito(PARAM, IND, PTAULU, RND) / DES = 'Erityismakro
		Päivähoito -parametrien päivittämiseksi elokuusykliä varten';

		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);

	/*=========================================================================
	Käynnistetään päivähoitotaulun päivitysluuppi
	-------------------------------------------------------------------------*/
	%do QD = 1 %to &MAX;

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&PVUOSI+&QD-1);
		%let E2VUOSI = %sysevalf(&PVUOSI+&QD-2);
		%let E4VUOSI = %sysevalf(&PVUOSI+&QD-4);

		proc sql noprint;

		/*=====================================================================
		Haetaan edellisvuoden uusin parametri
		---------------------------------------------------------------------*/

		select &PARAM into :UPD from &PTAULU
				where vuosi = &EVUOSI;

		/*=====================================================================
		Käytetään oletuksena edellisvuoden arvoa
		---------------------------------------------------------------------*/

				update &PTAULU
				set &PARAM = round(&UPD, &RND)
				where vuosi = &LVUOSI;

		/*=====================================================================
		Joka toinen vuosi saa indeksikorjauksen (niille riveille, joilla
		kuukausi >= 8) HUOM! kuitenkin EDELLISEN vuoden indeksin mukaisesti!
		---------------------------------------------------------------------*/

				%if %sysfunc(mod(&LVUOSI,2)) = 0 %then %do;

					update &PTAULU
					set &PARAM =
						round(
					((&&&IND&E2VUOSI)/(&&&IND&E4VUOSI)) * &UPD
					, &RND)
					where vuosi = &LVUOSI 
					and kuuk >= 8;

				%end;
	
		quit;
					
	%end;

	%mend PaivitaPhoito;

	/*=========================================================================
	Opintotuki-taulu tarvitsee oman päivitysaliohjelman opintorahoihin
	elokuussa tapahtuvien indeksikorotusten vuoksi.
	-------------------------------------------------------------------------*/
	%macro PaivitaOpintuki(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
	/ DES = 'Opintorahojen päivitysmakro';

		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);

	%do QD = 1 %to &MAX;  

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&LVUOSI-1);
		%let JVUOSI = 2023;

		proc sql noprint;

		select &PARAM into :UPD from &PTAULU
		where vuosi = &EVUOSI;

		*IndKel-sidonnaisten arvojen jäädytys;
		%if (&IND = IndKel)	%then %do;
			*Ehto ottaa huomioon mikäli LVUOSI 2024 - 2027;
			%if (&LVUOSI >= 2024 AND &LVUOSI <= 2027) %then %do;
				update &PTAULU
					set &PARAM = round(((&&&IND&JVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO, &RND)
					where vuosi = &LVUOSI;
			%end;
			*Ehto ottaa huomioon mikäli IndKel arvo on yli 2009 ennen vuotta 2028;
			%if (&&&IND&LVUOSI > 2009) %then %do;
				update &PTAULU
					set &PARAM = round((SUM(&&&IND&LVUOSI, -SUM(2009, -1805))/(&&&IND&LPVUOSI)) * &LPTASO, &RND)
					where vuosi = &LVUOSI AND kuuk = 8;
				
				update &PTAULU
					set &PARAM = &UPD
					where vuosi = &LVUOSI AND kuuk = 1;
			%end;
			*Ehto laskee kelasidonnaisen etuuden arvon vuodelle 2028 ja eteenpäin;
			%if (&LVUOSI >= 2028) %then %do;
				update &PTAULU
					set &PARAM = round((SUM(&&&IND&LVUOSI, -SUM(2009, -1805))/(&&&IND&LPVUOSI)) * &LPTASO, &RND)
					where vuosi = &LVUOSI AND kuuk = 8;
				
				update &PTAULU
					set &PARAM = &UPD
					where vuosi = &LVUOSI AND kuuk = 1;
			%end;
		%end;

		%else %do;
			update &PTAULU
				set &PARAM = round(((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO, &RND)
				where vuosi = &LVUOSI AND kuuk = 8;
				
			update &PTAULU
				set &PARAM = &UPD
				where vuosi = &LVUOSI AND kuuk = 1;
								
		quit;
		%end;
	%end;

	%mend PaivitaOpintuki;

	/*=========================================================================
	Opintotuen tulorajojen uusi tarkistus (joka tehdään ensi kerran 1.1.2018)
	tarvitsee oman päivitysaliohjelman parillisten vuosien tarkastusten
	johdosta.
	-------------------------------------------------------------------------*/
	%macro PaivitaOTTuloRaja(PARAM, IND, PTAULU, RND) /
		DES = 'Erityismakro Opintotuen tulorajojen päivittämiseksi';

		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);

	/*=========================================================================
	Käynnistetään opintotuen päivitysluuppi
	-------------------------------------------------------------------------*/
	%do QD = 1 %to &MAX;

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&PVUOSI+&QD-1);
		%let E3VUOSI = %sysevalf(&PVUOSI+&QD-3);

		/*=====================================================================
		Haetaan edellisvuoden uusin parametri
		---------------------------------------------------------------------*/

		proc sql noprint;

			select &PARAM into :upd from &PTAULU
				where vuosi = &EVUOSI;

		/*=====================================================================
		Käytetään oletuksena edellisvuoden arvoa. Poikkeuksena v. 2023, 
		jolloin parametrien arvot muuttuivat erillisellä säädöksellä.
		---------------------------------------------------------------------*/

				%if &LVUOSI ^= 2023 %then %do;

				update &PTAULU
				set &PARAM = round(&UPD, &RND)
				where vuosi = &LVUOSI;

				%END;

		/*=====================================================================
		Tehdään indeksikorotus jos kyse on parillisesta vuodesta
		(2018-2022) tai parittomasta vuodesta (2025-) ja vain jos tuloraja nousisi. 
		Poikkeuksena vuosi 2023, jonka tarkistus siirtyi vuodelle 2025 vuoden 2024 arvolla.
		---------------------------------------------------------------------*/

				%if %sysfunc(mod(&LVUOSI,2)) > 0 and &LVUOSI > 2024 %then %do;

					update &PTAULU
					set &PARAM =
						MAX(round(&UPD, &RND), round(
					((&&&IND&EVUOSI)/(&&&IND&E3VUOSI)) * &UPD
					, &RND))
					where vuosi = &LVUOSI;

				%end;

				%if &LVUOSI = 2025 %then %do;

					update &PTAULU
					set &PARAM =
						MAX(round(&UPD, &RND), round(
					((&&&IND.2024)/(&&&IND.2022)) * &UPD
					, &RND))
					where vuosi = &LVUOSI;

				%end;
		quit;
					
	%end;

	%mend PaivitaOTTuloRaja;


	/*=========================================================================
	Kytkentä VERO- ja KANSEL -parametrien välillä: eläketulovähennys
	-------------------------------------------------------------------------*/
	%macro KytkentaV1(PARAM, PKANSEL, PVERO) / DES = 'Verotuksen
		eläketulovähennyksen ja kansaneläkkeen maksimin huomioiva kytkentä';
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

			%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		/*=====================================================================
		Tämä päivittää vero -taulun parametrin vastaamaan koko vuoden
		pyöristettyä kansaneläkkeen enimmäismäärää.

		Vero -taulun parametri ValtElKerr vastaa lainsäädännön kerrointa.
		Tätä parametriä pitää tn. inflaatiokorjata, kun verotuksen 
		taulukkoja inflaatiokorjataan.
		---------------------------------------------------------------------*/
			proc sql noprint;

				select round((TaysKEY1*12),.01) into :UPD1
				from &PKANSEL where vuosi = &LVUOSI;

				update &PVERO
				set &PARAM = &UPD1
				where vuosi = &LVUOSI;

			quit;

		%end;

	%mend KytkentaV1;

	/*=========================================================================
	Kytkentä SAIRVAK ja TTURVA -parametreistä vakuutuspalkan
	prosenttivähennykseen, ja VERO -parametreistä TyEl-maksuun, 
	sairausvakuutusmaksuun ja työttömyysvakuutusmaksuun.
	-------------------------------------------------------------------------*/
	%macro kytkentaSVTT1(PARAM, IND, PTAULU) / DES = 'Vakuutuspalkan 
		prosenttivähennyksen, TyEl-maksun, sairausvakuutusmaksun ja
		työttömyysvakuutusmaksun huomioiva kytkentä';
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

			%let LVUOSI = %sysevalf(&PVUOSI+&QD);

			proc sql noprint;

		/*=====================================================================
		Asettaa vakuutuspalkan prosenttivähennyksen indeksitaulun
		mukaiseksi
		---------------------------------------------------------------------*/
				update &PTAULU
				set &PARAM = &&&IND&LVUOSI
				where vuosi = &LVUOSI;

			quit;

		%end;

	%mend kytkentaSVTT1;

	/*=========================================================================
	Yleiskäyttöinen kytkentämakro, jolla ptaulu_pohja-taulun 
	param_pohja-parametrit kopioidaan ptaulu_kopio-taulun 
	param_kopio-parametreiksi annetusta vuodesta alkaen.
	-------------------------------------------------------------------------*/

	%MACRO Kytkenta(param_kopio, ptaulu_kopio, param_pohja, ptaulu_pohja, alkuvuosi);

		%LET MAX = %SYSEVALF(&TVUOSI-&PVUOSI);

		%DO QD = 1 %TO &MAX;  

			%LET LVUOSI = %SYSEVALF(&PVUOSI+&QD);

			%IF &LVUOSI >= &alkuvuosi %THEN %DO;

				PROC SQL NOPRINT;

					SELECT &param_pohja. INTO :APU_POHJA
					FROM &ptaulu_pohja.
					WHERE Vuosi = &LVUOSI;

					UPDATE &ptaulu_kopio.
					SET &param_kopio. = &APU_POHJA
					WHERE Vuosi = &LVUOSI;

				QUIT;

			%END;

		%END;

	%MEND;

	/*=========================================================================
	Verotuksen tulorajojen inflaatiokorjausta varten luotu makro.
	Infl -parametri määrittää, mitä indeksiä inflaatiokorjaukseen käytetään.
	-------------------------------------------------------------------------*/

	%macro tulorajat(infl) / DES = 'Verotuksen tulorajojen inflaatiokorjaus';

	/*=========================================================================
	Poimitaan talteen perusvuoden mukaiset tulorajat ja vakioverot
	-------------------------------------------------------------------------*/
	proc sql noprint;
		%do VRAJ = 1 %to 12;
			select raja&VRAJ, pros&VRAJ into 
				:xraja&VRAJ,
				:xpros&VRAJ
			from &PVERO
			where vuosi = &PVUOSI;
		%end;
	quit;

	/*=========================================================================
	Tulorajojen inflaatiokorjaus:
	-------------------------------------------------------------------------*/
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  
		%let upvuosi = %sysevalf(&pvuosi+&qd);

		/*=====================================================================
		Parametritaulussa on 12 tulorajaa. Määritetään ensimmäinen
		(nolla) manuaalisesti ja mystinen 8 euroa vakiomääräksi.
		---------------------------------------------------------------------*/
			%do vraj = 2 %to 12;
					%let kierros = %sysevalf(&VRAJ-1);
					%let vakiov1 = 8;
					%let xrajab1 = 0;

		/*=====================================================================
		Lasketaan tulorajat uudelleen
		---------------------------------------------------------------------*/
					%let xrajab&vraj = %sysfunc(round 
							(%sysevalf(
							(&&&infl&upvuosi/&&&infl&pvuosi)*&&xraja&vraj)
							,100));
							
		/*=====================================================================
		Lasketaan tulorajoja vastaavat veron vakiomäärät uudelleen
		---------------------------------------------------------------------*/
					%let vakiov&vraj = %sysevalf(
							(&&xrajab&vraj-&&xrajab&kierros)*&&xpros&kierros
							+&&vakiov&kierros
							);

		/*=====================================================================
		Päivitetään verotuksen parametritaulua
		---------------------------------------------------------------------*/
					proc sql noprint; 
						update &pvero
							set raja&vraj = &&xrajab&vraj
								where vuosi = &upvuosi;
						update &pvero
							set vakio&vraj = &&vakiov&vraj
								where vuosi = &upvuosi;
					quit;
			%end;
		%end;

	%mend tulorajat;

	/*=========================================================================
	Päivitetään parametritaulut
	-------------------------------------------------------------------------*/
	%ParamTaulut;

		/*=====================================================================
		Virhepoistuminen
		---------------------------------------------------------------------*/
		%exit:;

options &_notes;

%mend ParamPaivitys;


/*=========================================================================
Vanhoja indeksisidonnaisuuksia
-------------------------------------------------------------------------*/

/*=========================================================================
Lapsilisä ennen indeksisidonnaisuuden poistoa
-------------------------------------------------------------------------*/
/* Indeksisidonnaisuus vuoteen 2016 asti */
/*
%if %length (&PLLISA) > 0 %then %do;
        %luo(&PLLISA)
        %paivita(Lapsi1, IndKel, &PLLISA, .01, 2015, 95.75)
        %paivita(Lapsi2, IndKel, &PLLISA, .01, 2015, 105.80)
        %paivita(Lapsi3, IndKel, &PLLISA, .01, 2015, 135.01)
        %paivita(Lapsi4, IndKel, &PLLISA, .01, 2015, 154.64)
        %paivita(Lapsi5, IndKel, &PLLISA, .01, 2015, 174.27)
        %paivita(YksHuolt, IndKel, &PLLISA, .01, 2015, 48.55)
%end;
*/

/*=========================================================================
Opintotuki ennen indeksisidonnaisuuden poistoa 
-------------------------------------------------------------------------*/
/* Indeksisidonnaisuus voimassa 2015, poistettiin 2016 */
/*
%if %length (&POPINTUKI) > 0 %then %do;
        %luo(&POPINTUKI)
        %Paivita(KorkVanh20, IndKel, &POPINTUKI, .01, 2013, 122)
        %Paivita(KorkVanhAlle20, IndKel, &POPINTUKI, .01, 2013, 55)
        %Paivita(KorkMuu20, IndKel, &POPINTUKI, .01, 2013, 298)
        %Paivita(KorkMuuAlle20, IndKel, &POPINTUKI, .01, 2013, 145)
        %Paivita(MuuVanh20, IndKel, &POPINTUKI, .01, 2013, 80)
        %Paivita(MuuVanhAlle20, IndKel, &POPINTUKI, .01, 2013, 38)
        %Paivita(MuuMuu20, IndKel, &POPINTUKI, .01, 2013, 246)
        %Paivita(MuuMuuAlle20, IndKel, &POPINTUKI, .01, 2013, 100)
        %Paivita(KorkVanh20_2, IndKel, &POPINTUKI, .01, 2013, 135)
        %Paivita(KorkVanhAlle20_2, IndKel, &POPINTUKI, .01, 2013, 61)
        %Paivita(KorkMuu20_2, IndKel, &POPINTUKI, .01, 2013, 331)
        %Paivita(KorkMuuAlle20_2, IndKel, &POPINTUKI, .01, 2013, 161)
%end;
*/

/*=========================================================================
Indeksisidonnaisuudet ennen 1.1.2018 voimaan tulleita lakimuutoksia 
-------------------------------------------------------------------------*/

/* %paivita(YksinKR1, IndKel, &PTOIMTUKI, .01, 2011, 455.00) */
/* %paivita(YksinKR2, IndKel, &PTOIMTUKI, .01, 2011, 455.00) */

/*
%PaivitaVuokraInd(Kattovuokra_1_1, VuokraInd, &PASUMTUKI, 1, 2015, 508)
%PaivitaVuokraInd(Kattovuokra_1_2, VuokraInd, &PASUMTUKI, 1, 2015, 735)
%PaivitaVuokraInd(Kattovuokra_1_3, VuokraInd, &PASUMTUKI, 1, 2015, 937)
%PaivitaVuokraInd(Kattovuokra_1_4, VuokraInd, &PASUMTUKI, 1, 2015, 1095)
%PaivitaVuokraInd(Kattovuokra_1_Plus, VuokraInd, &PASUMTUKI, 1, 2015, 137)
%PaivitaVuokraInd(Kattovuokra_2_1, VuokraInd, &PASUMTUKI, 1, 2015, 492)
%PaivitaVuokraInd(Kattovuokra_2_2, VuokraInd, &PASUMTUKI, 1, 2015, 706)
%PaivitaVuokraInd(Kattovuokra_2_3, VuokraInd, &PASUMTUKI, 1, 2015, 890)
%PaivitaVuokraInd(Kattovuokra_2_4, VuokraInd, &PASUMTUKI, 1, 2015, 1038)
%PaivitaVuokraInd(Kattovuokra_2_Plus, VuokraInd, &PASUMTUKI, 1, 2015, 130)
%PaivitaVuokraInd(Kattovuokra_3_1, VuokraInd, &PASUMTUKI, 1, 2015, 390)
%PaivitaVuokraInd(Kattovuokra_3_2, VuokraInd, &PASUMTUKI, 1, 2015, 570)
%PaivitaVuokraInd(Kattovuokra_3_3, VuokraInd, &PASUMTUKI, 1, 2015, 723)
%PaivitaVuokraInd(Kattovuokra_3_4, VuokraInd, &PASUMTUKI, 1, 2015, 856)
%PaivitaVuokraInd(Kattovuokra_3_Plus, VuokraInd, &PASUMTUKI, 1, 2015, 117)
%PaivitaVuokraInd(Kattovuokra_4_1, VuokraInd, &PASUMTUKI, 1, 2015, 344)
%PaivitaVuokraInd(Kattovuokra_4_2, VuokraInd, &PASUMTUKI, 1, 2015, 501)
%PaivitaVuokraInd(Kattovuokra_4_3, VuokraInd, &PASUMTUKI, 1, 2015, 641)
%PaivitaVuokraInd(Kattovuokra_4_4, VuokraInd, &PASUMTUKI, 1, 2015, 764)
%PaivitaVuokraInd(Kattovuokra_4_Plus, VuokraInd, &PASUMTUKI, 1, 2015, 112)
*/

/* %paivita(HoitTukiNorm, IndKel, &PKANSEL, .01, 2001, 49.69) */
/* %paivita(RiLi, IndKel, &PKANSEL, .01, 2001, 39.56) */
/* %paivita(TakuuEl, IndKel, &PKANSEL, .01, 2001, 612.16) */
/* %paivita(VeterLisa, IndKel, &PKANSEL, .01, 2001, 83.92) */
/* %paivita(YliRiliMinimi, IndKel, &PKANSEL, .01, 2001, 5.07) */
/* %paivita(YliRiliRaja, IndKel, &PKANSEL, .01, 2001, 981.60) */

/* %paivita(Minimi, IndKel, &PSAIRVAK, .01, 2010, 22.04) */
/* %paivita(VanhMin, IndKel, &PSAIRVAK, .01, 2010, 22.04) */

/*=========================================================================
Aiemmin käytetty vuokraindeksisidonnaisten parametrien päivitysmakro:
Indeksikorotuksen perusteena indeksin muutos perusvuodesta
vuoteen LVUOSI-2.
-------------------------------------------------------------------------*/
/*
%macro PaivitaVuokraInd(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
/ DES = 'Taulujen päivitysmakro: vuokraindeksiin sidotut';

	%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
	%do QD = 1 %to &MAX;  

	%let LVUOSI = %sysevalf(&PVUOSI+&QD);
	%let PAVUOSI = %sysevalf(&PVUOSI+&QD-2);

	proc sql noprint;

		update &PTAULU
			set &PARAM = 

				round(
				((&&&IND&PAVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
				, &RND)

				where vuosi = &LVUOSI;
		quit;

	%end;

%mend PaivitaVuokraInd;
*/

/*=========================================================================
Indeksisidonnaisuudet ennen 1.1.2019 voimaan tulleita lakimuutoksia 
-------------------------------------------------------------------------*/

/* %paivita(YksinKR1, IndKel, &PTOIMTUKI, .01, 2011, 458.10) */
/* %paivita(YksinKR2, IndKel, &PTOIMTUKI, .01, 2011, 458.10) */

/* %paivita(RajaTyotulo, IndKel, &PKANSEL, .01, 2011, 687.74) */
/* %paivita(TakuuEl, IndKel, &PKANSEL, .01, 2001, 624.24) */

/* %paivita(Minimi, IndKel, &PSAIRVAK, .01, 2010, 22.89) */
/* %paivita(VanhMin, IndKel, &PSAIRVAK, .01, 2010, 22.89) */

/*=========================================================================
Indeksisidonnaisuudet ennen 1.4.2019 voimaan tulleita lakimuutoksia 
-------------------------------------------------------------------------*/

/* %paivita(RiLi, IndKel, &PKANSEL, .01, 2001, 478.92) */
/* %paivita(VeterLisa, IndKel, &PKANSEL, .01, 2001, 84.65) */
/* %paivita(YliRiliMinimi, IndKel, &PKANSEL, .01, 2001, 5.12) */
/* %paivita(YliRiliRaja, IndKel, &PKANSEL, .01, 2001, 937.44) */

/*=========================================================================
Indeksisidonnaisuudet ennen 1.1.2020 voimaan tulleita lakimuutoksia 
-------------------------------------------------------------------------*/

/* %paivita(KorotusOsa, IndKel, &PTTURVA, .01, 2012, 4.59)	*/
/* %paivita(TTPerus, IndKel, &PTTURVA, .01, 2012, 31.36) */
/* %paivita(TTLaps1, IndKel, &PTTURVA, .01, 2012, 5.06) */
/* %paivita(TTLaps2, IndKel, &PTTURVA, .01, 2012, 7.43) */
/* %paivita(TTLaps3, IndKel, &PTTURVA, .01, 2012, 9.58) */

/* %PaivitaTaannehtiva1(Kattovuokra_1_1, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_1_2, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_1_3, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_1_4, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_1_Plus, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_2_1, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_2_2, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_2_3, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_2_4, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_2_Plus, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_3_1, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_3_2, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_3_3, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_3_4, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_3_Plus, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_4_1, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_4_2, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_4_3, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_4_4, Ind51loka, &PASUMTUKI, 1) */
/* %PaivitaTaannehtiva1(Kattovuokra_4_Plus, Ind51loka, &PASUMTUKI, 1) */

/* %paivita(LisOVRaja, IndKel, &PELASUMTUKI, 1, 2001, 6986) */
/* %paivita(LisOVRaja2, IndKel, &PELASUMTUKI, 1, 2001, 10240) */
/* %paivita(LisOVRaja3, IndKel, &PELASUMTUKI, 1, 2001, 11221) */
/* %paivita(LisOVRaja4, IndKel, &PELASUMTUKI, 1, 2001, 6986) */
/* %paivita(LisOVRaja5, IndKel, &PELASUMTUKI, 1, 2001, 11221) */

/* %paivita(LaitosTaysiY1, IndKel, &PKANSEL, .01, 2001, 506.35) */
/* %paivita(LaitosTaysiY2, IndKel, &PKANSEL, .01, 2001, 506.35) */
/* %paivita(LaitosTaysiP1, IndKel, &PKANSEL, .01, 2001, 449.13) */
/* %paivita(LaitosTaysiP2, IndKel, &PKANSEL, .01, 2001, 449.13) */
/* %paivita(TakuuEl, IndKel, &PKANSEL, .01, 2001, 631.69) */
/* %paivita(TaysKEY1, IndKel, &PKANSEL, .01, 2001, 528.50) */
/* %paivita(TaysKEY2, IndKel, &PKANSEL, .01, 2001, 528.50) */
/* %paivita(TaysKEP1, IndKel, &PKANSEL, .01, 2001, 471.84) */
/* %paivita(TaysKEP2, IndKel, &PKANSEL, .01, 2001, 471.84) */

/* %paivita(Minimi, IndKel, &PSAIRVAK, .01, 2010, 25.88) */

/*==========================================================================================
Aiemmin käytetty päivitysmakro, jossa indeksikorotuksen perusteena on
indeksin muutos vuodesta päivitysvuosi-2 vuoteen päivitysvuosi-1
------------------------------------------------------------------------------------------*/

/*
%MACRO PaivitaTaannehtiva1(param, ind, ptaulu, rnd);

	%LET MAX = %SYSEVALF(&TVUOSI-&PVUOSI);

	%DO QD = 1 %TO &MAX;

		%LET E2VUOSI = %SYSEVALF(&PVUOSI+&QD-2);
		%LET EVUOSI = %SYSEVALF(&PVUOSI+&QD-1);
		%LET LVUOSI = %SYSEVALF(&PVUOSI+&QD);

		PROC SQL NOPRINT;

			SELECT &param INTO :TASO FROM &ptaulu
			WHERE Vuosi = &EVUOSI;

			UPDATE &ptaulu
				SET &param =
					ROUND
						(
							((&&&ind&EVUOSI)/(&&&ind&E2VUOSI)) * &TASO, &rnd
						)
				WHERE Vuosi = &LVUOSI;

		QUIT;

	%END;

%MEND PaivitaTaannehtiva1;
*/

/* %PaivitaTaannehtiva1(AlenElatTuki, Ind51loka, &PLLISA, .01) */
/* %PaivitaTaannehtiva1(ElatTuki, Ind51loka, &PLLISA, .01) */

/*==========================================================================================
Aiemmin käytetty kytkentä sairausvakuutuksen päivärahan vakuutuspalkan
vähennysprosentin hakemiseen
------------------------------------------------------------------------------------------*/

/* %kytkentaSVTT1(PalkVah, palkvahpros, &PSAIRVAK) */

/*==========================================================================================
Indeksisidonnaisuus ennen 1.4.2020 voimaan tullutta rintamasotilaseläkelain muutosta
------------------------------------------------------------------------------------------*/

/* %paivita(RiLi, IndKel, &PKANSEL, .01, 2001, 484.92) */

/*==========================================================================================
Indeksisidonnaisuus ennen 1.8.2020 voimaan tullutta aikuiskoulutustuen muutosta
------------------------------------------------------------------------------------------*/
/* %paivita(ATPerus, IndKel, &POPINTUKI, .01, 2016, 27.78) /*