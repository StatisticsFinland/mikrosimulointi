/*********************************************************** *
 *  Kuvaus: Tyˆnantajamaksujen simulointimalli 2018		     * 
 *  Viimeksi p‰ivitetty: 10.11.2020							 * 
 * **********************************************************/

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */
%TuhoaGlobaalit;

%LET MALLI = TAMAKSU;

%LET alkoi1&MALLI = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */
%MACRO Aloitus;

	%LET AVUOSI = 2018;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2018;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET AINEISTO = r18_tamaksu; 	* K‰ytett‰v‰ aineisto;

	%LET TYYPPI = SIMUL; 		* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12; 			* Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET TULOSNIMI_TA = tamaksu_simul_&SYSDATE._1; * Simuloidun tulostiedoston nimi ;

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

	%LET LAKIMAK_TIED_TA = TAMAKSUlakimakrot;	* Lakimakrotiedoston nimi ;
	%LET PTAMAKSU = ptamaksu; * K‰ytett‰v‰n parametritiedoston nimi;

	* Tulostaulukoiden esivalinnat ; 

	%LET MUUTTUJAT = TASAVAMAKSU TATYVAMAKSU TAELMAKSU TARYHEMAKSU TATATUMAKSU TAMAKSUSUM; * Taulukoitavat muuttujat (summataulukot) ;	
	%LET LUOK_HLO1 = ;  * Taulukoinnin 1. henkilˆluokitus
						    Vaihtoehtoina: 
							  ikavu (ik‰ryhm‰t);
						
	%LET EXCEL = 0; * Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;
	
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
	%LET CV = ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	* K‰ytett‰v‰ painokerroin (jos tyhj‰, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj‰, niin ei rajauksia);

	* Lasketaan mahdollinen indeksiin perustuva inflaatiokorjaus;

	%InfKerroin(&AVUOSI, &LVUOSI, &INF);

	/* Ajetaan lakimakrot ja tallennetaan ne */

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TA..sas";

%MEND Aloitus;

%Aloitus;

/* 2. Simulointivaihe */
%LET alkoi2&malli = %SYSFUNC(TIME());

%MACRO Tamaksu_simulointi;

/* 2.1 Haetaan parametrit */

/* Muuttujat, joihin haetaan lista mallin k‰ytt‰mist‰ lakiparametreist‰ */
%LOCAL TAMAKSU_PARAM TAMAKSU_MUUNNOS;

/* Haetaan mallin k‰ytt‰mien lakiparametrien nimet */
%HaeLokaalit(TAMAKSU_PARAM, TAMAKSU);
%HaeLaskettavatLokaalit(TAMAKSU_MUUNNOS, TAMAKSU);

/* Luodaan tyhj‰t lokaalit muuttujat lakiparametien hakua varten */
%LOCAL &TAMAKSU_PARAM;

/* Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */
%KuukSimul(TAMAKSU);

/* 2.2 Datan poiminta ja apumuuttujien luominen (optio) */

DATA TEMP.TAMAKSU_POHJA;
	SET POHJADAT.&AINEISTO;
	JARJESTYS = _N_;
RUN;

/* 2.2.1 M‰‰ritell‰‰n tarvittavat muuttujat taulukkoon START_TAMAKSU 

START_TAMAKSU -taulukkoon on rajattu vain ne suorituslajit, joista tyˆntekij‰t ovat varmuudella
maksaneet tyˆttˆmyysvakuutusmaksuja ja tyˆel‰kemaksuja (pieni‰ maksuja
saattaa olla joissakin suorituslajeissa, mutta niit‰ ei ole otettu mukaan).

K‰ytt‰j‰t voivat halutessaan muokata palkkak‰sitett‰ tai rakentaa 
eri tyˆnantajamaksuille eri palkkak‰sitteet. 
Palkkak‰sitteet on avattu vuositiedot_suorituslajit.xls -tiedostossa.*/

/* Suorituslajit, joista maksetaan tyˆnantajamaksuja */

DATA STARTDAT.START_TAMAKSU;
SET TEMP.TAMAKSU_POHJA
(KEEP = hnro ykor palkka ikavu tsekt pros muulis autovere suorlaji JARJESTYS);
WHERE 
suorlaji = '1' OR /*palkka sivutoimesta*/
suorlaji = '1Y' OR /*yritt‰j‰n palkka sivutoimesta*/ 
suorlaji = '2' OR /*merityˆtulo*/
suorlaji = '5' OR /*ns. 6kk s‰‰nnˆn alainen (vakuutus)palkka*/
suorlaji = '6' OR /*sijaismaksajan maksama palkka ja palkkaturva*/
suorlaji = '7M' OR /*ulkomaisen tyˆnantajan (ei kiinte‰‰ toimipaikkaa Suomessa) maksama palkka Suomessa vakuutetulle*/
suorlaji = 'H3' OR /*perhehoitajan tai omaishoitajan palkkio ja kulukorvaus*/
suorlaji = 'P' OR  /*palkka p‰‰toimesta*/
suorlaji = 'P3' OR /*kunnallisen perhep‰iv‰hoitajan palkkio*/
suorlaji = 'SA' /*sairauskassojen t‰ydennysp‰iv‰raha*/;
RUN;

/* 2.2.2 Apumuuttujien luominen taulukkoon START_TAMAKSU */

DATA STARTDAT.START_TAMAKSU;
SET STARTDAT.START_TAMAKSU;

*Luodaan uusi palkkamuuttuja (TAPALKKA) palkkatuloille, jossa palkkaan lis‰t‰‰n autoetu ja muut luontoisedut;

TAPALKKA = SUM(palkka, autovere, muulis);
LABEL TAPALKKA = 'Palkka (sis. autoetu ja muut luontoisedut), DATA';

RUN;

/* 2.3 Simuloidaan tyˆnantajan sairausvakuutusmaksu, tyˆel‰kemaksu, tyˆttˆmyysvakuutusmaksu, 
     ryhm‰henkivakuutusmaksu, tapaturmavakuutusmaksu */

DATA TEMP.TAMAKSU;
SET STARTDAT.START_TAMAKSU;

IF TAPALKKA > 0 THEN DO;
	%SairVakMaksuVTAS(TASAVAMAKSUK, &LVUOSI, &INF, ikavu, (TAPALKKA / 12), tsekt);
	%TyotVakMaksuVTAS(TATYVAMAKSUK, &LVUOSI, &INF, ikavu, (TAPALKKA / 12), tsekt);
	%ElMaksuVTAS(TAELMAKSUK, &LVUOSI, &INF, ikavu, (TAPALKKA / 12), pros, tsekt);
	%RyHeMaksuVTAS(TARYHEMAKSUK,&LVUOSI, &INF, (TAPALKKA / 12), tsekt);
	%TaTuMaksuVTAS(TATATUMAKSUK, &LVUOSI, &INF, (TAPALKKA / 12), tsekt);
END;

/* Kerrotaan vuositasoiseksi kuukausitasoisesta */ 
TASAVAMAKSU = TASAVAMAKSUK * 12;
TATYVAMAKSU = TATYVAMAKSUK * 12;
TAELMAKSU = TAELMAKSUK * 12;
TARYHEMAKSU = TARYHEMAKSUK * 12;
TATATUMAKSU = TATATUMAKSUK * 12;

TAMAKSUSUM = SUM(TASAVAMAKSU, TATYVAMAKSU, TAELMAKSU, TARYHEMAKSU, TATATUMAKSU);

DROP TASAVAMAKSUK TATYVAMAKSUK TAELMAKSUK TARYHEMAKSUK TATATUMAKSUK;

/* 2.4 Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan */ 

ARRAY PISTE 
	TAPALKKA TASAVAMAKSU TATYVAMAKSU TAELMAKSU    
	TARYHEMAKSU TATATUMAKSU TAMAKSUSUM;

DO OVER PISTE;
	IF PISTE <= 0 THEN
		PISTE = .;
END;

/* 2.5 Luodaan muuttujille selitteet */

LABEL
	TAPALKKA = 'Tyˆnantajan sosiaalivakuutusmaksujen pohjalla oleva ansiotulo' 
	TASAVAMAKSU = 'Tyˆnantajan sairausvakuutusmaksu, MALLI' 
	TATYVAMAKSU = 'Tyˆnantajan tyˆttˆmyysvakuutusmaksu, MALLI' 
	TAELMAKSU = 'Tyˆnantajan tyˆel‰kemaksu, yksityinen ja julkinen sektori, MALLI' 
	TARYHEMAKSU = 'Tyˆnantajan ryhm‰henkivakuutusmaksu, MALLI' 
	TATATUMAKSU = 'Tyˆnantajan tapaturmavakuutusmaksu, MALLI'
	TAMAKSUSUM = 'Tyˆnantajamaksut yhteens‰ (sairaus, el‰ke, tyˆttˆmyys, henki, tapaturma), MALLI'; 
RUN;

PROC SQL;
	CREATE TABLE OUTPUT.&TULOSNIMI_TA(DROP=JARJESTYS)
	AS SELECT a.*,
				b.TAPALKKA,
				b.TASAVAMAKSU,
				b.TATYVAMAKSU,
				b.TAELMAKSU,   
				b.TARYHEMAKSU,
				b.TATATUMAKSU,
				b.TAMAKSUSUM
	FROM TEMP.TAMAKSU_POHJA AS a
	LEFT JOIN TEMP.TAMAKSU AS b
	ON (a.JARJESTYS = b.JARJESTYS);
QUIT;

/* 2.6 Summataan aineisto henkilˆtasolle */

PROC SUMMARY DATA = OUTPUT.&TULOSNIMI_TA;
VAR TAPALKKA TASAVAMAKSU TATYVAMAKSU TAELMAKSU  
	TARYHEMAKSU TATATUMAKSU TAMAKSUSUM;
BY hnro;
ID ykor ikavu;
OUTPUT OUT = OUTPUT.&TULOSNIMI_TA._HLO (DROP = _TYPE_ _FREQ_) SUM=;
RUN;

/* Tyhjennet‰‰n TEMP-kirjasto */

%IF &TEMPTYHJ = 1 %THEN %DO;
	PROC DATASETS LIBRARY=TEMP NOLIST KILL;
	RUN;
	QUIT;
%END;

%MEND Tamaksu_simulointi;

%Tamaksu_simulointi;

%LET loppui2&malli = %SYSFUNC(TIME());

/* 3. Tulostetaan k‰ytt‰j‰n pyyt‰m‰t taulukot */

%KokoTulokset(1,&MALLI,OUTPUT.&TULOSNIMI_TA._HLO,1); 

/* 4. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));

%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;