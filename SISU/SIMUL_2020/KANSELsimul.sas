/**********************************************
* Kuvaus: Kansanel‰kkeen simulointimalli 2018 *
* Viimeksi p‰ivitetty: 30.5.2020			  *
**********************************************/ 

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */
%TuhoaGlobaalit;

%LET START = &OUT;

%LET MALLI = KANSEL;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos ohjelma ajetaan KOKO-mallin kautta, k‰ytet‰‰n siell‰ m‰‰riteltyj‰ ohjaavien makromuuttujien arvoja */

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = 0;
%END;

/* Jos ohjelma ajetaan erillisajossa, k‰ytet‰‰n alla syˆtettyj‰ ohjaavien makromuuttujien arvoja */

%IF &START NE 1 %THEN %DO;

	/* Seuraavia vaiheita ei ajeta jos arvot annetaan t‰m‰n koodin ulkopuolelta (&EG = 1) */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2020;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2020;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;		* Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = REK;	* K‰ytett‰v‰ aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_KE = kansel_simul_&SYSDATE._1; * Simuloidun tulostiedoston nimi ;

	%LET KDATATULO = 0;		* K‰ytet‰‰nkˆ KANSEL-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;

	* Inflaatiokorjaus. Euro- tai markkam‰‰r‰isten parametrien haun yhteydess‰ suoritettavassa
	  deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse INF-makromuuttujaan
	  (HUOM! desimaalit erotettava pisteell‰ .). Esim. jos yksi lains‰‰d‰ntˆvuoden euro on
	  aineistovuoden rahassa 95 sentti‰, syˆt‰ arvoksi 0.95.
	  Simuloinnin tulokset ilmoitetaan aina aineistovuoden rahassa.
	  Jos puolestaan haluaa k‰ytt‰‰ automaattista inflaatiokorjausta, on vaihtoehtoja kaksi:
	  - Elinkustannusindeksiin (kuluttajahintaindeksi, ind51) perustuva inflaatiokorjaus: INF = KHI
	  - Ansiotasoindeksiin (ansio64) perustuva inflaatiokorjaus: INF = ATI ;

	%LET INF = 1.00; * Syˆt‰ lukuarvo, KHI tai ATI;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;	

    * KANSEL-mallin el‰kkeiden KEL-indeksikorotus.  
	  KEL-indeksikorotuksen simuloinnissa ei voi el‰kkeiden osalta k‰ytt‰‰ parametritaulujen p‰ivitysohjelmaa PARAMindeksit.sas,
	  koska KEL-indeksikorotus tehd‰‰n maksussa oleviin el‰kkeisiin, kun taas SISU laskee el‰kkeet uudelleen (jolloin kyseess‰ on el‰kkeiden tasokorotus).
	  Valitsemalla KEL_INDEKSIKOROTUS = 1 ja syˆtt‰m‰ll‰ uusi KEL-indeksin pisteluku sek‰ sen voimassaolokuukausien lukum‰‰r‰ makromuuttujiin KEL_IND ja KEL_KUUK,
	  simuloituja KANSEL-mallin etuuksia korotetaan suhteessa yht‰ paljon kuin KEL-indeksin pisteluku on muuttunut keskim‰‰rin vuoden aikana.;		 
	  
	%LET KEL_INDEKSIKOROTUS = 1; * 1 = Simuloiduille KEL-sidonnaisille etuuksille tehd‰‰n indeksikorotus;

	%LET KEL_IND = 1733;    * KEL-indeksikorotuksen indeksipisteluku;

	%LET KEL_KUUK = 5;		* KEL-indeksikorotuksen voimassaolokuukaudet;

	DATA _NULL_;				* Asetetaan KEL-indeksi lains‰‰d‰ntˆvuoden perusteella;
	SET param.pindeksi_vuosi;
	IF vuosi = &LVUOSI. THEN DO;
		CALL SYMPUT ('KEL_IND_EX',IndKel);
					END;
	RUN;



	* Ajettavat osavaiheet ; 

	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET LAKIMAK_TIED_KE = KANSELlakimakrot; * Lakimakrotiedoston nimi ;
	%LET PKANSEL = pkansel; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (kaikki pohja-aineiston muuttujat)) ;
	%LET MUUTTUJAT = takuuelake TAKUUELA kelake KANSANELAKE lapsikorotus LAPSIKOROT rielake RILISA ryelake YLIMRILI etuki EHOITUKI vtukia16 LVTUKI 
				     hvamtuk VTUKI LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkˆ (1 = henkilˆ, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilˆluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavu (ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste)
							     soss (sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilˆluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilˆluokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavuv (viitehenkilˆn mukaiset ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulasv (viitehenkilˆn koulutusaste)
							     paasoss (viitehenkilˆn sosioekonominen asema)
							     rake (kotitalouden rakenne)
								 maakunta (NUTS3-aluejaon mukainen maakuntajako);
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		 * Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhj‰, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukum‰‰r‰t ;
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

	%LET PAINO = ykor ; 	* K‰ytett‰v‰ painokerroin (jos tyhj‰, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj‰, niin ei rajauksia);

	%END;

	/* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus */

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

%END;

/* Ajetaan lakimakrot ja tallennetaan ne */

%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KE..sas";

%MEND Aloitus;

%Aloitus;


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KansEl_Muut_Poiminta;

	%IF &POIMINTA = 1 %THEN %DO;

		DATA STARTDAT.START_KANSEL;
			SET POHJADAT.&AINEISTO&AVUOSI 
			(
			WHERE = ((ELAKUUK > 0) OR (lapsikorotus > 0) OR (rielake > 0) OR (ryelake > 0) OR (etuki > 0)
			OR (vtukia16 > 0) OR (hvamtuk > 0)	OR (KORJ_LAPEL > 0) OR (KORJ_ALKU > 0)
			OR (jatko > 0))
	 
			KEEP = hnro lasmu knro elak kelake etuki lapsikorotus rielake ryelake vakio pe_perus tayde ikakk hvamtuk
			vtukia16 ehtm lhtm pelake velaji tklaji svatvp lelake tansel tmuuel ttapel tlapel tpotel
			hrelake htperhe tuntelpe hpalktu lapper pe_perus alku jatko laptay lapel takuuelake ikavu velake tkelake
			svaltio muuttovv teanstu teleuve tkansel takuuel tulkp tulkelvp tepalkat toptiot tosinktp telps43 tmuukust 
			tepalk tmerile tpalv trespa tepertyok1 tepertyok2 telps41 telps42 telps8 telps1 tutmp235 tutmp4 telps2 telps5 ttyoltuk
			tmtatt tpjta tyhtat anstukor yrtukor syvu leelake
			tmaat1evyr tmaat1pevyr tliik1evyr tliikpevyr tporo1evyr tyhtmatevyr tyhtateevyr tyhtmat tyhtate 
			KANSEL_TULO LAPSETULO LESK_JATKOTULO KPUOLISO TAYSORPO ELAKUUK LAPSKUUK RILIKUUK EHOITOKUUK LVTUKIKUUK
			VTUKIKUUK KORJ_LAPEL KORJ_ALKU TAKUUEL_TULO ASUSUHT MAMUPTULOT MAMUTULOT LYKKAYSK VARHENP
			);

			ARRAY PISTE 
			rielake kelake takuuelake lapsikorotus ryelake hvamtuk vtukia16 etuki pelake;
			DO OVER PISTE;
				IF PISTE <= 0 THEN PISTE = .;
			END;

			/* Kansanel‰kej‰rjestelm‰n lapsenel‰ke */
			LAELAKEDATA = SUM(lapper, laptay);

			IF lapper > 0 and laptay <= 0 THEN laptay = 0;

			/* Kansanel‰kej‰rjestelm‰n leskenel‰ke */
			IF sum(vakio, pe_perus) > 0 OR tayde > 0 THEN LEELAKEDATA = leelake;

			/* Asuuko henkilˆ laitoksessa;
			   tieto vain rekisteriaineistossa, palveluaineistossa tyhj‰n‰ [.] muuttujana */
			LAITOS = max(0, lasmu);

			/* Kunnan kalleusryhm‰;
			   tietoa ei ole aineistossa, eik‰ sill‰ ole merkityst‰ vuoden 2008 j‰lkeisess‰ lains‰‰d‰nnˆss‰ */
			KRYHMA = 2; 

			/* Muut el‰kkeet kuin kansanel‰ke ja takuuel‰ke;
			   VERO-mallin mukaisesti */
			MUUT_EL = MAX(SUM(tansel, ttapel, tlapel, tpotel, teanstu, tmuuel, teleuve, tulkelvp), 0); /*tulkelvp - ulkomaan el‰kkeet lis‰tty 28.3.2022*/

			/* Onko kyseess‰ tyˆkyvyttˆmyysel‰ke */
			IF ((tkelake > 0)
				OR (tklaji IN (2,8,9))
				OR (ttapel > 0)
				OR (tlapel > 0)) THEN ONTYOKYVYTE = 1;
			ELSE ONTYOKYVYTE = 0;

			/* Tyˆtulo */
			TYOTULO = SUM(tepalkat, toptiot, tosinktp, anstukor, tulkp, telps43, tmuukust, tepalk, tmerile, tpalv, trespa,
						tutmp235, tutmp4, tepertyok1, tepertyok2, telps41, telps42, telps8, telps1, telps2, telps5, ttyoltuk, tmaat1evyr,
						tmaat1pevyr, tpjta, tliik1evyr, tliikpevyr, tporo1evyr, tyhtmatevyr, tyhtateevyr, 
						SUM(tyhtat, -tyhtmat, -tyhtate), tmtatt, yrtukor);
		
			LABEL
				LAELAKEDATA = "Kansanel‰kej‰rjestelm‰n lapsenel‰ke (e/v), DATA"
				LEELAKEDATA = "Kansanel‰kej‰rjestelm‰n leskenel‰ke (e/v), DATA"	
				LAITOS = "Asuuko henkilˆ laitoksessa (0/1), DATA"
				KRYHMA = "Kunnan kalleusryhm‰ (1/2)"
				MUUT_EL = "Muut el‰kkeet kuin kansanel‰ke ja takuuel‰ke, (e/v), DATA"
				ONTYOKYVYTE = "Onko kyseess‰ tyˆkyvyttˆmyysel‰ke (0/1), DATA"
				TYOTULO = "Tyˆtulo (e/v), DATA";

		RUN;

	%END;

%MEND KansEl_Muut_Poiminta;

%KansEl_Muut_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 3.1 Varsinainen simulointivaihe */

%MACRO KansEl_Simuloi_Data;

/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL KANSEL_PARAM KANSEL_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(KANSEL_PARAM, KANSEL);
%HaeLaskettavatLokaalit(KANSEL_MUUNNOS, KANSEL);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &KANSEL_PARAM;

/* Haetaan parametrit */
%HaeParamSimul(&LVUOSI, &LKUUK, &KANSEL_PARAM, PARAM.&PKANSEL);
%ParamInfSimul(&LVUOSI, &LKUUK, &KANSEL_MUUNNOS, &INF);

DATA TEMP.&TULOSNIMI_KE;
	SET STARTDAT.START_KANSEL;

	/* Kansanel‰ke;
	simuloidaan siihen oikeutetuille el‰kel‰isille,
	ennen vuotta 1997 pohjaosa siis simuloidaan kaikille el‰kel‰isille. */
	IF 
	(
		/* on el‰kekuukausia */
		(ELAKUUK > 0)
		AND
		/* ulkomailla syntyneiden osalta: on asunut riitt‰v‰n kauan Suomessa */
		((muuttovv = .) OR ((muuttovv NE .) AND (SUM(&AVUOSI, -MAX(muuttovv, syvu + 16)) > &Karenssi)))
		AND
		/* ei ole osa-aikael‰kkeell‰ (osa-aikael‰kkeell‰ voi saada kansanel‰kett‰,
		mutta el‰kkeen m‰‰r‰ lasketaan ns. ennakoidun el‰kkeen perusteella 
		(eli tyˆel‰ke, jonka henkilˆ saisi, jos siirtyisi el‰kkeelle 63-vuotiaana)
		eik‰ t‰t‰ tietoa ole aineistossa, joten osa-aikael‰kel‰iset rajataan
		kokonaan pois) */
		(NOT(velaji = 6))
		AND
		/* ei ole sellainen henkilˆ, joka saa takuuel‰kett‰ mutta ei saa kansanel‰kett‰ */
		(NOT((takuuel > 0) AND (tkansel = 0)))
		AND
		(
			/* saa vanhuusel‰kett‰ tai tyˆkyvyttˆmyysel‰kett‰*/
			((velake > 0) OR (tkelake > 0))
			OR
			/* on t‰ytt‰nyt 65 vuotta v‰hint‰‰n 1 kk ennen vuoden loppua */
			((ikavu > 65) OR ((ikavu = 65) AND (ikakk > 0)))
			OR
			/* saa tyˆkyvyttˆmyysel‰kett‰ tyˆel‰kkeen‰ */
			(tklaji IN (2,8,9))
			OR
			/* saa tapaturmavakuutukseen tai liikennevakuutukseen
			perustuvaa tyˆkyvyttˆmyysel‰kett‰ */
			((ttapel > 0) OR (tlapel > 0))	
		) 
	)
	THEN DO;
		IF &KDATATULO = 0 AND KANSEL_TULO NE . THEN DO;
			%Kansanelake_SimpleVS(KANSANELAKE, &LVUOSI, &INF, LAITOS, KPUOLISO, KRYHMA, KANSEL_TULO, ASUSUHT, ontyokyvyte = ONTYOKYVYTE, tyotulo = TYOTULO / 12);
		END;
		ELSE DO;
			%Kansanelake_SimpleVS(KANSANELAKE, &LVUOSI, &INF, LAITOS, KPUOLISO, KRYHMA, MUUT_EL / ELAKUUK * 12, ASUSUHT, ontyokyvyte = ONTYOKYVYTE, tyotulo = TYOTULO / 12);
		END;
		KANSANELAKE = KANSANELAKE * (LYKKAYSK * VARHENP) * ELAKUUK;
	END;

	*Lapsikorotukset;
	IF lapsikorotus > 0 THEN DO;
		%KanseLLisatVS(LAPSIKOROT, &LVUOSI, &INF, 1, 0, 0, 0, 0, 0, 0, 0, KRYHMA, 1);
		LAPSIKOROT = LAPSKUUK * LAPSIKOROT;
		IF &LVUOSI < 2002 AND KANSANELAKE = 0 THEN LAPSIKOROT = 0;
	END;

	*Rintamalis‰t;
	IF rielake > 0 THEN DO;
		%KanseLLisatVS(RILISA, &LVUOSI, &INF, 1, 0, 0, 0, 0, 0, 1, 0, KRYHMA, 0);
		RILISA = RILIKUUK * RILISA;
	END;

	*Ylim‰‰r‰iset rintamalis‰t;
	IF ryelake > 0 THEN DO;
		IF &KDATATULO = 0 AND KANSEL_TULO NE . THEN DO;
			LASKLISAOSA = 0;
			IF &LVUOSI < 1997 THEN DO;
				%Kansanelake_SimpleVS(LASKLISAOSA, &LVUOSI, &INF, LAITOS, KPUOLISO, KRYHMA, KANSEL_TULO, ASUSUHT);
				LASKLISAOSA = SUM(LASKLISAOSA, -&PerPohja);
			END;
			%YlimRintLisaVS(YLIMRILI, &LVUOSI, &INF, LASKLISAOSA, KANSANELAKE / ELAKUUK, KANSEL_TULO);
		END;

		ELSE DO;
			LISAOSA = 0;
			IF &LVUOSI < 1997 THEN DO;
				%Kansanelake_SimpleVS(LISAOSA, &LVUOSI, &INF, LAITOS, KPUOLISO, KRYHMA, MUUT_EL, ASUSUHT);
				LISAOSA = SUM(LISAOSA, -&PerPohja);
			END;
			%YlimRintLisaVS(YLIMRILI, &LVUOSI, &INF, LISAOSA, kelake / ELAKUUK, MUUT_EL / 12);
		END;

		YLIMRILI = RILIKUUK * YLIMRILI;

		DROP LASKLISAOSA LISAOSA; 
	END;

	*Hoitotuet ja veteraanilis‰;
	IF etuki > 0 THEN DO;
		%KanseLLisatVS(EHOITUKI, &LVUOSI, &INF, 1, (ehtm = 4 OR (YLIMRILI > 0 AND ehtm IN (2,3))), (ehtm = 5), (ehtm = 1), (ehtm = 2), (ehtm = 3), 0, 0, KRYHMA, 0);
		EHOITUKI = EHOITUKI * EHOITOKUUK;
	END;

	*Vammaistuet;
	IF vtukia16 > 0 THEN DO;
		%VammTukiVS(LVTUKI, &LVUOSI, &INF, 0, 1, 0, lhtm);
		LVTUKI = LVTUKI * LVTUKIKUUK;
	END;
	IF hvamtuk > 0 THEN DO;
		%VammTukiVS(VTUKI, &LVUOSI, &INF, 1, 0, 0, lhtm);
		VTUKI = VTUKI * VTUKIKUUK;
		IF VTUKI <= 0 THEN VTUKI = .;
	END;
	DROP lhtm;

	*Lapsenel‰ke;
	IF KORJ_LAPEL > 0 THEN DO;
		IF &KDATATULO = 0 THEN DO;	
			%LapsenElakeAVS(LAPSENELAKE, &LVUOSI, &INF, TAYSORPO, LAPSETULO, (lapper > 0 and laptay <= 0));
		END;
		ELSE DO;
			%LapsenElakeAVS(LAPSENELAKE, &LVUOSI, &INF, TAYSORPO, SUM(hrelake, htperhe, tuntelpe) / 12, (lapper > 0 and laptay <= 0));
		END;
		LAPSENELAKE = KORJ_LAPEL * LAPSENELAKE;
	END;

	*Lesken alku- ja jatkoel‰ke;
	IF KORJ_ALKU > 0 THEN DO;
		%LeskenElakeAVS(LEALKUE, &LVUOSI, &INF, 1, KPUOLISO, KRYHMA, 0, hpalktu, svatvp, MUUT_EL, 0);
		LEALKUE = LEALKUE * KORJ_ALKU;
	END;
	IF jatko > 0 THEN DO;
		IF &KDATATULO = 0 THEN DO;
			%LeskenElakeAVS(LEJATKOE, &LVUOSI, &INF, 0, KPUOLISO, KRYHMA, (pe_perus > 0), 0, 0, LESK_JATKOTULO, 0);
		END;
		ELSE DO;
			%LeskenElakeAVS(LEJATKOE, &LVUOSI, &INF, 0, KPUOLISO, KRYHMA, (pe_perus > 0), hpalktu, svatvp, MUUT_EL, 0);
		END;
		LEJATKOE = LEJATKOE * jatko;
	END;

	*Summataan simuloidut leskenel‰kkeet;
	LESKENELAKE = SUM(LEALKUE, LEJATKOE);

	*Maahanmuuttajan erityistuki simuloidaan ulkomailla syntyneille pienituloisille el‰kel‰isille;
	IF ELAKUUK > 0 AND SVALTIO NE '246' AND 2003 <= &LVUOSI <= 2011 AND (KANSANELAKE NG 0 OR ASUSUHT NE 1) AND SUM(&AVUOSI, -muuttovv) > &KarenssiMamu AND muuttovv > 0 THEN DO;
		%MaMuErTukiVS(MMTUKI, &LVUOSI, &INF, LAITOS, KPUOLISO, KRYHMA, MAMUTULOT, MAMUPTULOT);

		*Tuki on alkanut ja p‰‰ttynyt keskell‰ vuotta (10/2003 - 2/2011), mik‰ otetaan seuraavassa huomioon;
		%IF &LVUOSI = 2003 %THEN %DO;
			%IF %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
				IF &LKUUK < 10 THEN MMTUKI = .;
				ELSE MMTUKI = MMTUKI * 4 * ELAKUUK
			%END;	
			%ELSE %DO; MMTUKI = MMTUKI * 4 * MIN(ELAKUUK, 3); %END;
		%END;
		%ELSE %IF &LVUOSI = 2011 %THEN %DO;
			%IF %UPCASE(&TYYPPI) = SIMULX %THEN %DO;
				IF &LKUUK > 2 THEN MMTUKI = .;
				ELSE MMTUKI = MMTUKI * 6 * ELAKUUK;
			%END;
			%ELSE %DO; MMTUKI = MMTUKI * 6 * MIN(ELAKUUK, 2); %END;
		%END;
		%ELSE %DO; MMTUKI = MMTUKI * ELAKUUK; %END;
	END;


	/* Takuuel‰ke;
	simuloidaan oikeutetuille, ei etuuden saamisen mukaan */
	IF 
	(
		/* takuuel‰ke tullut k‰yttˆˆn vuonna 2011 */
		(&LVUOSI >= 2011)
		AND 
		/* on el‰kekuukausia */
		(ELAKUUK > 0)
		AND 
		/* ulkomailla syntyneiden osalta: on asunut riitt‰v‰n kauan Suomessa */
		((muuttovv = .) OR ((muuttovv NE .) AND (SUM(&AVUOSI, -MAX(muuttovv, syvu + 16)) > &Karenssi)))
		AND
		(
			/* saa vanhuusel‰kett‰ kansanel‰kkeen‰ tai tyˆel‰kkeen‰ */
			((velake > 0) OR (velaji IN (1,7)))
			OR
			/* saa tyˆkyvyttˆmyysel‰kett‰ kansanel‰kkeen‰ */
			(tkelake > 0)
			OR
			/* saa tyˆkyvyttˆmyysel‰kett‰ tyˆel‰kkeen‰ */
			(tklaji IN (2,8,9))
			OR
			/* saa tapaturmavakuutukseen tai liikennevakuutukseen
			perustuvaa tyˆkyvyttˆmyysel‰kett‰ */
			((ttapel > 0) OR (tlapel > 0))
			OR
			/* on t‰ytt‰nyt 65 vuotta v‰hint‰‰n 1 kk ennen vuoden loppua */
			((ikavu > 65) OR ((ikavu = 65) AND (ikakk > 0)))
			OR
			/* simuloitunut kansanel‰kett‰ */
			KANSANELAKE > 0 
			OR 
			/* saa takuuel‰kett‰ */
			(takuuel > 0) 	
		)	
	)
	THEN DO; 

		IF &KDATATULO = 0 and TAKUUEL_TULO NE . THEN DO;
			%TakuuElakeVS(TAKUUELA, &LVUOSI, &INF, SUM(TAKUUEL_TULO, KANSANELAKE, LESKENELAKE, LAPSENELAKE) / 12, VARHENP, ontyokyvyte = ONTYOKYVYTE, tyotulo = TYOTULO / 12);
		END;
		ELSE DO;
			%TakuuElakeVS(TAKUUELA, &LVUOSI, &INF, SUM(MUUT_EL, KANSANELAKE, LESKENELAKE, LAPSENELAKE) / ELAKUUK, VARHENP, ontyokyvyte = ONTYOKYVYTE, tyotulo = TYOTULO / 12);
		END;
		TAKUUELA = ELAKUUK * TAKUUELA;

	END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

ARRAY PISTE 
	TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI 
	LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE LEALKUE LEJATKOE MMTUKI;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille muuttujille selitteet ;

LABEL 
TAKUUELA = 'Takuuel‰ke, MALLI'
KANSANELAKE = 'Kansanel‰kkeet, MALLI'
MMTUKI = 'Maahanmuuttajan erityistuki, MALLI'
LAPSIKOROT = 'Lapsikorotukset, MALLI'
RILISA = 'Rintamalis‰t, MALLI'
YLIMRILI = 'Ylim‰‰r‰iset rintamalis‰t, MALLI'
EHOITUKI = 'El‰kkeensaajan hoitotuet, MALLI'
LVTUKI = 'Alle 16-vuotiaan vammaistuki, MALLI'
VTUKI = 'Vammaistuki, MALLI'
LAELAKEDATA = 'Lapsenel‰ke, DATA'
LAPSENELAKE = 'Lapsenel‰ke, MALLI'
LEELAKEDATA = 'Leskenel‰ke, DATA'
LESKENELAKE = 'Leskenel‰ke, MALLI'
LEALKUE = 'Lesken alkuel‰ke, MALLI'
LEJATKOE = 'Lesken jatkoel‰ke, MALLI';

KEEP hnro knro TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI 
LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE LEALKUE LEJATKOE MMTUKI;

/* KEL-INDEKSIKOROTUS */


IF &KEL_INDEKSIKOROTUS=1 THEN DO;

/* indeksikorotettavat muuttujat */
ARRAY simuloidut TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI 
LAPSENELAKE LEALKUE LEJATKOE;

DO OVER simuloidut; simuloidut=simuloidut*((&KEL_IND./&KEL_IND_EX.-1)*&KEL_KUUK./12+1); END; 

LESKENELAKE=sum(LEALKUE,LEJATKOE,psmk);

END;

RUN;

/* 3.2 Luodaan tulostiedosto OUTPUT-kansioon */

/* T‰t‰ vaihetta ei ajeta mik‰li osamallia k‰ytet‰‰n KOKO-mallin kautta. */

%IF &START NE 1 %THEN %DO;

	/* Yhdistet‰‰n tulokset pohja-aineistoon */

	DATA TEMP.&TULOSNIMI_KE;

	/* 3.2.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO kelake lapsikorotus rielake ryelake etuki vtukia16 hvamtuk takuuelake
			ikavu ikavuv desmod soss paasoss elivtu koulas koulasv rake maakunta)
		TEMP.&TULOSNIMI_KE;
	%END;

	/* 3.2.2 Laaja tulostiedosto (kaikki pohja-aineiston muuttujat) */

	%IF &TULOSLAAJ = 2 %THEN %DO; 
		MERGE POHJADAT.&AINEISTO&AVUOSI TEMP.&TULOSNIMI_KE;
	%END;

	/* Muokataan datan muuttujia */

	* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

	ARRAY PISTE 
		kelake lapsikorotus rielake ryelake etuki vtukia16 hvamtuk takuuelake;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	* Luodaan datan muuttujille selitteet ;

	LABEL 
	takuuelake = 'Takuuel‰ke, DATA'
	kelake = 'Kansanel‰kkeet, DATA'
	lapsikorotus = 'Lapsikorotukset, DATA'
	rielake = 'Rintamalis‰t, DATA'
	ryelake = 'Ylim‰‰r‰iset rintamalis‰t, DATA'
	etuki = 'El‰kkeensaajan hoitotuet, DATA'
	vtukia16 = 'Alle 16-vuotiaan vammaistuki, DATA'
	hvamtuk = 'Vammaistuki, DATA'
	;

	BY hnro;

	RUN;

	%IF &YKSIKKO = 2 AND &START ^= 1 %THEN %DO;
		%SumKotitT(OUTPUT.&TULOSNIMI_KE._KOTI, TEMP.&TULOSNIMI_KE, KANSEL, &MUUTTUJAT);
		
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KE;
		RUN;
		QUIT;
	%END;

	/* Jos k‰ytt‰j‰ m‰‰ritellyt YKSIKKO=1 (henkilˆtaso) tai YKSIKKO on mit‰ tahansa muuta kuin 2 (kotitaloustaso)
		niin j‰tet‰‰n tulostaulu henkilˆtasolle ja nimet‰‰n se uudelleen */

	%ELSE %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST;
			DELETE &TULOSNIMI_KE._HLO;
			CHANGE &TULOSNIMI_KE=&TULOSNIMI_KE._HLO;
			COPY OUT=OUTPUT MOVE;
			SELECT &TULOSNIMI_KE._HLO;
		RUN;
		QUIT;
	%END;

	/* Tyhjennet‰‰n TEMP-kirjasto */

	%IF &TEMPTYHJ = 1 %THEN %DO;
		PROC DATASETS LIBRARY=TEMP NOLIST KILL;
		RUN;
		QUIT;
	%END;

%END;

%MEND KansEl_Simuloi_Data;

%KansEl_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 4. Tulostetaan k‰ytt‰j‰n pyyt‰m‰t taulukot */

%MACRO KutsuTulokset;
	%IF &TULOKSET = 1 AND &YKSIKKO = 1 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KE._HLO,1);
	%END;
	%IF &TULOKSET = 1 AND &YKSIKKO = 2 %THEN %DO;
		%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_KE._KOTI,2);
	%END;
	
	/* Jos EG = 1 ja simulointia ei ajettu KOKOsimul-koodin kautta, palautetaan EG-makromuuttujalle oletusarvo */
	%IF &START ^= 1 and &EG = 1 %THEN %DO;
		%LET EG = 0;
	%END;
%MEND;
%KutsuTulokset;


/* 5. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));

%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;