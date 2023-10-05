/*******************************************************************
* Kuvaus: Simulointiohjelmien ajossa tarvittavia makromuuttujien   *
*         ja kirjastojen määrittelyjä.                             *
* Viimeksi päivitetty: 13.4.2023 							   	   *
*******************************************************************/

/* SISÄLLYS 
0. Yleiset optiot ja SAS-asetukset
1. Hakemisto- ja kirjastoviittaukset
	1.1 Mallivuosi, mallin sijainti, muistin käyttö ja TEMP-kirjaston tyhjennys 
	1.2 Ohjelma, joka määrittää sijaintilevyn ja hakemiston sekä kenoviivan ympäristön mukaan
	1.3 Määritellään kirjastoviittaukset
2. Makro, jolla voi säädellä lokin kirjoitusta 
3. Määritellään mallin ohjausparametrit globaaleiksi makromuuttujiksi 
	3.1 TuhoaGlobaalit - Makro, jolla tuhotaan globaalit makromuuttujat
	3.2 TeeGlobaalit - Makro, jolla luodaan tyhjät globaalit makromuuttujat
		3.2.1 Mallin ohjausparametrit
		3.2.2 Osamallien nimet ohjausparametreina
	 	3.2.3 Parametritaulukoiden alkuvuodet 
		3.2.4 Euron arvo
4. Käytettävät templatet
5. Ajetaan muistiin mallin yleiset makrot
6. Ajetaan formaatit muistiin
7. Tarkistusohjelma onko ALKUsimul.sas ajettu 
*/

/* 0. Yleiset optiot ja SAS-asetukset */

%GLOBAL EG;
%LET EG = 0;

OPTIONS COMPRESS = BINARY;

/* Asetetaan SAS:n oletusnimet muuttujille myös SAS EG */

OPTIONS VALIDVARNAME = V7;

/* 1. Hakemisto- ja kirjastoviittaukset */

/* 1.1 Mallivuosi, mallin sijainti, muistin käyttö ja TEMP-kirjaston tyhjennys */

%GLOBAL HAKEM LEVY KENO MVUOSI MUISTISSA TEMPTYHJ;

%LET MVUOSI = 2020; /* Mallivuosi (aineiston perusvuosi) */

%LET MUISTISSA = 0; /* Käytetäänkö muistia simuloinnin nopeuttamiseksi
					   0 = ei (suositus työasemakäytössä)
					   1 = kyllä (suositus FIONA-etäkäyttöpalvelimella)
					   Valinnalla 1 STARTDAT- ja TEMP-kirjastojen tiedostoja ei
					   kirjoiteta levylle vaan ne sijaitsevat vain muistissa. */

%LET TEMPTYHJ = 1;  /* Tyhjennetäänkö TEMP-kirjasto simulointikoodeissa tilan säästämiseksi (1 = kyllä, 0 = ei) */

/* 1.2 Ohjelma, joka määrittää sijaintilevyn ja hakemiston sekä kenoviivan ympäristön mukaan */

/* Jos haluat määrittää mallin sijainnin käsin, käytä SYSCHECK-makron sijaan tätä koodia: */
*%LET HAKEM = SISU; 	/* Kansio, jossa malli sijaitsee */
*%LET LEVY = C: ; 		/* Levyasema, jossa malli sijaitsee */
*%LET KENO = \; 		/* Kenoviivan suunta */

%MACRO SYSCHECK;
/* Jos mallia ajetaan AIX-ympäristössä, määritellään sijainti käsin */
%IF &SYSSCPL = AIX %THEN %DO;
		%LET HAKEM = USER/SISU; 	/* Kansio, jossa ohjelmakansiot ovat */
		%LET LEVY = %SYSGET(HOME) ; /* Levyasema, jossa ohjelma sijaitsee */
		%LET KENO = /;				/* Kenoviivan suunta */
%END;
/* Muussa tapauksessa käytetään tämän ALKUsimul-koodin sijaintia mallin sijainnin määrittämiseksi */
%ELSE %DO;
	/* SAS EG:ssä tiedoston polku löytyy makromuuttujasta _SASPROGRAMFILE */
	%IF %SYMEXIST(_SASPROGRAMFILE) %THEN %DO;
		%LET POLKU = %SYSFUNC(COMPRESS(&_SASPROGRAMFILE, "'"));
	%END;
	/* Base SAS:ssa polku on SAS_EXECFILEPATH -system variablessa */
	%ELSE %DO;
		%LET POLKU = %SYSGET(SAS_EXECFILEPATH);
	%END;
	/* Päätellään levyasema, jossa ohjelma sijaitsee */
	%LET LEVY = %SCAN(&POLKU, 1, '\');
	/* Päätellään kansio, jossa ohjelmakansiot ovat */
	%LET HAKEM = %SUBSTR(&POLKU, %LENGTH(&LEVY) + 2, %LENGTH(&POLKU) - %LENGTH(%SCAN(&POLKU, -2, '\')) - %LENGTH(%SCAN(&POLKU, -1, '\')) - %LENGTH(&LEVY) - 3);
	%LET KENO = \;
%END;
%MEND SYSCHECK;

%SYSCHECK;

/* 1.3 Määritellään kirjastoviittaukset */

%MACRO TeeKirjastot;
LIBNAME PARAM "&LEVY&KENO&HAKEM&KENO.PARAM"; /* Muokattujen parametritiedostojen kirjasto */
LIBNAME POHJADAT "&LEVY&KENO&HAKEM&KENO.DATA&KENO.POHJADAT"; /* Pohja-aineistojen kirjasto (perusvuoden ja ajantasaistetut aineistot) */
LIBNAME STARTDAT "&LEVY&KENO&HAKEM&KENO.DATA&KENO.STARTDAT" %IF &MUISTISSA = 1 %THEN %DO; MEMLIB %END;; /* Lähtöaineiston (poiminta ja muokkaukset tehty) kirjasto */
LIBNAME TEMP "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.TEMP" %IF &MUISTISSA = 1 %THEN %DO; MEMLIB %END;; /* Apu- ja välitaulukkojen kansio */ 
LIBNAME OUTPUT "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT"; /* Tulostaulukkojen kirjasto */
LIBNAME AJANT_R "&LEVY&KENO&HAKEM&KENO.AJANTASAISTUS&KENO.REK"; /* Ajantasaistusohjelmien- ja taulujen kirjasto */
LIBNAME SIMUL "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI"; /* Mallivuoden &MVUOSI aineistosimulointiohjelmien kirjasto */
LIBNAME ESIM "&LEVY&KENO&HAKEM&KENO.ESIM"; /* Esimerkkilaskelmien simulointiohjelmien kirjasto */
LIBNAME DOKUM "&LEVY&KENO&HAKEM&KENO.DOKUM"; /* Mallin dokumenttien kirjasto */
LIBNAME OHJAUS "&LEVY&KENO&HAKEM&KENO.OHJAUS"; /* Mallin ohjausparametrien kansio */
LIBNAME MAKROT "&LEVY&KENO&HAKEM&KENO.MAKROT"; /* Makrojen kirjasto */
%MEND TeeKirjastot;

%TeeKirjastot;

/* 2. Tällä makrolla voi säädellä lokin kirjoitusta, kun valitaan arvo optio-muuttujalle:
		0 = ei lokia;
		1 = NOTES, SOURCE ja SOURCE2;
		2 = myös makroihin liittyvät lokioptiot;
		Varoitus: Kaikkien makrolokioptioiden käyttö tuottaa hyvin pitkän lokin. */

%MACRO Loki(optio);

%LET PREFIX = NO;

%IF &optio = 0 %THEN %DO;
	%LET &PREFIX = NO;
	OPTIONS SQLUNDOPOLICY = NONE;
%END;

%ELSE %IF &optio = 2 %THEN %DO;
	%LET PREFIX = ;
%END;

OPTIONS &PREFIX.NOTES;
OPTIONS &PREFIX.SOURCE &PREFIX.SOURCE2;
OPTIONS &PREFIX.MPRINT;
OPTIONS &PREFIX.MPRINTNEST; 
OPTIONS &PREFIX.SYMBOLGEN; 
OPTIONS &PREFIX.MEXECNOTE;
OPTIONS &PREFIX.MLOGIC &PREFIX.MLOGICNEST;

%IF &optio = 1 %THEN %DO;
	OPTIONS NOTES SOURCE SOURCE2;
%END;

%MEND Loki;

%Loki(1);

/* 3. Määritellään mallin ohjausparametrit globaaleiksi makromuuttujiksi */

/* 3.1 Makro globaalien makromuuttujien tuhoamista ja tyhjinä uudelleen
		luomista varten. Makro jättää tuhoamatta makromuuttujat, jotka on määritelty
		OHJAUS.kaikki_param-taulun pysyvat-sarakkeessa.

Makroa kutsutaan jokaisen osamallin ja esimerkkilaskelman alussa.
*/

%MACRO TuhoaGlobaalit;
	/* Tämä makro tuhoaa globaalit makromuuttujat osamalleissa. Tuhoamista ei tehdä siinä
	tapauksessa, että mallia ajetaan KOKOsimul-koodin kautta (OUT = 1) tai silloin kun EG = 1.
	Jos et halua että makromuuttujasi tuhotaan, lisää ne KAIKKI_PARAM-taulun pysyvat-sarakkeeseen. */
	%IF &OUT NE 1 AND &EG NE 1 %THEN %DO;
	
	%LOCAL tuhottavat;

	PROC SQL NOPRINT;
	SELECT name INTO :tuhottavat SEPARATED BY ' '
	FROM SASHELP.vmacro
	WHERE SCOPE = 'GLOBAL' AND name NOT IN(SELECT UPCASE(Pysyvat) FROM OHJAUS.KAIKKI_PARAM WHERE pysyvat NE '');
	QUIT;

	/* Tuhotaan globaalit makromuuttujat*/
	%SYMDEL &tuhottavat;

	/* Luodaan tilalle uudet tyhjät globaalit makromuuttujat */
	%TeeGlobaalit;

	%LET START = &OUT;

	%END;
%MEND TuhoaGlobaalit;

/* 3.2 Makrolla luodaan osamalleissa käytetyt ohjausparametrit tyhjinä globaaleina makromuuttujina. */
%MACRO TeeGlobaalit;

	/* 3.2.1 Mallin ohjausparametrit */

	%GLOBAL OUT POIMINTA TULOKSET 

			LAKIMAK_TIED_OT LAKIMAK_TIED_PH LAKIMAK_TIED_TT LAKIMAK_TIED_SV LAKIMAK_TIED_KT 
			LAKIMAK_TIED_LL LAKIMAK_TIED_TO LAKIMAK_TIED_KE LAKIMAK_TIED_VE LAKIMAK_TIED_KV
			LAKIMAK_TIED_YA LAKIMAK_TIED_EA LAKIMAK_TIED_TA LAKIMAK_TIED_EP
			
			SIMUL_TIED_OT SIMUL_TIED_TT SIMUL_TIED_SV SIMUL_TIED_KT SIMUL_TIED_LL SIMUL_TIED_TO 
			SIMUL_TIED_KE SIMUL_TIED_VE SIMUL_TIED_KV SIMUL_TIED_YA SIMUL_TIED_EA SIMUL_TIED_PH

			ESIM_TIED_OT ESIM_TIED_TT ESIM_TIED_SV ESIM_TIED_KT ESIM_TIED_LL ESIM_TIED_TO ESIM_TIED_KE
			ESIM_TIED_VE ESIM_TIED_KV ESIM_TIED_YA ESIM_TIED_EA ESIM_TIED_PH ESIM_TIED_KOKO ESIM_TIED_VR

			POPINTUKI PTTURVA PTAMAKSU PSAIRVAK PKOTIHTUKI PLLISA PTOIMTUKI PKANSEL PVERO 
		    PVERO_VARALL PKIVERO PASUMTUKI PASUMTUKI_VUOKRANORMIT 
			PASUMTUKI_ENIMMMENOT PELASUMTUKI PINDEKSI_VUOSI PINDEKSI_KUUK PPHOITO PEPIDEM
			KOKOpoiminta KOKOsummat KOKOindikaattorit

			INF MVUOSI AVUOSI LVUOSI LKUUK AINEISTO KIVERO_AINEISTO TULOSNIMI_SV TULOSNIMI_KT TULOSNIMI_TT
			TULOSNIMI_LL TULOSNIMI_TO TULOSNIMI_KE TULOSNIMI_VE TULOSNIMI_KV TULOSNIMI_YA TULOSNIMI_EA 
			TULOSNIMI_OT TULOSNIMI_PH TULOSNIMI_VR TULOSNIMI_KOKO TULOSNIMI_TA

			TYYPPI TYYPPI_KOKO EXCEL TULOSLAAJ TULOSLAAJ_KOKO MUUTTUJAT YKSIKKO
			LUOK_HLO1 LUOK_HLO2 LUOK_HLO3 LUOK_KOTI1 LUOK_KOTI2 LUOK_KOTI3
			SUMWGT SUM MIN MAX RANGE MEAN MEDIAN MODE VAR STD CV PAINO RAJAUS
			VUOSIKA VALITUT RAJALKM KRAJA1 KRAJA2 KRAJA3 TULO KULUYKS TARKISTUS_ASUMTUKI
		
			KDATATULO SDATATULO TTDATATULO YRIT TARKPVM APKESTOSIMUL VKKESTOSIMUL

			MAKSIMI_VERO_PUOLISO MINIMI_KOKO_PUOLISO

			ASUMKUST_MAKS

			/* Yleisen asumistuen laskennassa tarvittava makromuuttuja */
			AIKMAX

			/* Osamallien moduuleita ohjaavat makromuuttujat */
			OSINKO_MODUL

			/* Vanhempainpäivärahojen esimerkkilaskentaa ohjaavat makromuuttujat */
			INFMUUNNOS ATIMUUNNOS PALKTASOV VRAHA_LASKE_VUOSITULOT

			/* VVERO-mallia ohjaavat makromuuttujat */
			TULOSNIMI_VVE LAKIMAK_TIED_VVE APUMAK_TIED_VVE PVVERO PVVERO_TUOTTEET
			KULUTUS KULUTUS_KOROTUS TUNNUSLUVUT KOKOSIMUL KOKOSIMUL_MUUTTUJAT

			/* Esimerkkilaskelmien formaatteja määrittelevät makromuuttujat */
			EROTIN DESIMAALIT

			/*TAMAKSUjen työeläkevakuutusmaksuprosentin valinta KuEL- ja VaEL-vakuutettujen palkkojen  osalta*/
			KUELVAELDATA
			
			/* Perhevapaauuudistuksen käyttöönoton ilmaiseva makromuuttuja */
			PERHEVAP
			

			/*Ylimääräisen indeksimuutoksen määrittelyn makromuuttujat*/
			KEL_IND KEL_IND_EX KEL_KUUK KEL_INDEKSIKOROTUS
;

	/* 3.2.2 Osamallien nimet ohjausparametreina */

	%GLOBAL SAIRVAK TTURVA KANSEL KOTIHTUKI OPINTUKI VERO KIVERO LLISA ASUMTUKI ELASUMTUKI PHOITO TOIMTUKI VANHRAHA TAMAKSU;

	/* 3.2.3 Parametritaulukoiden alkuvuodet (ja ASUMTUKI-mallin erillisparametrien loppuvuosi) */

	%GLOBAL euro paramloppuyat paramalkusv paramalkukt paramalkutt paramalkull paramalkuto paramalkuke paramalkuve paramalkuyat paramalkueat paramalkuot;

	%LET paramalkusv = 1982;  /* Sairausvakuutuksen parametritaulukon lähtövuosi */
	%LET paramalkuot = 1992;  /* Opintotuen parametritaulukon lähtövuosi */
	%LET paramalkukt = 1985;  /* Kotihoidontuen parametritaulukon lähtövuosi */
	%LET paramalkutt = 1985;  /* Työttömyysturvan parametritaulukon lähtövuosi */
	%LET paramalkull = 1948;  /* Lapsilisän parametritaulukon lähtövuosi */
	%LET paramalkuto = 1989;  /* Toimeentulotuen parametritaulukon lähtövuosi */
	%LET paramalkuke = 1957;  /* Kansaneläkkeen parametritaulukon lähtövuosi */
	%LET paramalkuve = 1980;  /* Veromallin parametritaulukon lähtövuosi */
	%LET paramalkukv = 2009;  /* Kiinteistöveron parametritaulukon lähtövuosi */
	%LET paramalkuyat = 1990; /* Yleisen asumistuen parametritaulukon lähtövuosi */
	%LET paramalkueat = 1990; /* Eläkkeensaajien asumistuen parametritaulukon lähtövuosi */
	%LET paramloppuyat = 2015; /* Yleisen asumistuen erillisparametritaulukoiden loppuvuosi */

	/* 3.2.4 Euron arvo (ParamInf&TYYPPI -makroilla on oma keyword variable euron arvon laskemista varten.
	   Tämän makromuuttujan muuttaminen ei vaikuta ParamInf&TYYPPI-makroihin!) */

	%LET euro = 5.94573;

%MEND TeeGlobaalit;

/* Luodaan globaalit makromuuttujat */
%TeeGlobaalit;

/* 4. Käytettävät templatet */

ODS PATH work.templat(UPDATE) sasuser.templat(READ) sashelp.tmplmst(READ);

/* Määritetään miten arvot tulostetaan PROC MEANS- ja PROC SUMMARY -proseduureilla */

PROC TEMPLATE;
EDIT BASE.SUMMARY;
DEFINE N;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE SUMWGT;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE SUM;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE MIN;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE MAX;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE RANGE;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE MEAN;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE MEDIAN;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE MODE;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE VAR;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE CV;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE STDDEV;
FORMAT = tuhat.;
JUST = RIGHT;
END;
DEFINE NOBS;
FORMAT = tuhat.;
JUST = RIGHT;
END;
END;
RUN;

/* 5. Ajetaan muistiin mallin yleiset makrot */

%MACRO TeeMakrot;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.InfMakrot.sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.ParamMakrot.sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.PyoristysMakrot.sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.TulosMakrot.sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.VertailuMakrot.sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO.YLEISET&KENO.YleisMakrot.sas";
%MEND TeeMakrot;

%TeeMakrot;

/* 6. Ajetaan formaatit muistiin */ 

%INCLUDE "&LEVY&KENO&HAKEM&KENO.OHJAUS&KENO.SisuFormaatit.sas";

/* 7. Tätä makromuuttujaa tutkimalla voi selvittää, onko tämä ohjelma ajettu */

%GLOBAL XALKU;
%LET XALKU = 1;
