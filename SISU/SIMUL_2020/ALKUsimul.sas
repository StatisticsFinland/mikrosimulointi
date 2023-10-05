/*******************************************************************
* Kuvaus: Simulointiohjelmien ajossa tarvittavia makromuuttujien   *
*         ja kirjastojen m��rittelyj�.                             *
* Viimeksi p�ivitetty: 13.4.2023 							   	   *
*******************************************************************/

/* SIS�LLYS 
0. Yleiset optiot ja SAS-asetukset
1. Hakemisto- ja kirjastoviittaukset
	1.1 Mallivuosi, mallin sijainti, muistin k�ytt� ja TEMP-kirjaston tyhjennys 
	1.2 Ohjelma, joka m��ritt�� sijaintilevyn ja hakemiston sek� kenoviivan ymp�rist�n mukaan
	1.3 M��ritell��n kirjastoviittaukset
2. Makro, jolla voi s��dell� lokin kirjoitusta 
3. M��ritell��n mallin ohjausparametrit globaaleiksi makromuuttujiksi 
	3.1 TuhoaGlobaalit - Makro, jolla tuhotaan globaalit makromuuttujat
	3.2 TeeGlobaalit - Makro, jolla luodaan tyhj�t globaalit makromuuttujat
		3.2.1 Mallin ohjausparametrit
		3.2.2 Osamallien nimet ohjausparametreina
	 	3.2.3 Parametritaulukoiden alkuvuodet 
		3.2.4 Euron arvo
4. K�ytett�v�t templatet
5. Ajetaan muistiin mallin yleiset makrot
6. Ajetaan formaatit muistiin
7. Tarkistusohjelma onko ALKUsimul.sas ajettu 
*/

/* 0. Yleiset optiot ja SAS-asetukset */

%GLOBAL EG;
%LET EG = 0;

OPTIONS COMPRESS = BINARY;

/* Asetetaan SAS:n oletusnimet muuttujille my�s SAS EG */

OPTIONS VALIDVARNAME = V7;

/* 1. Hakemisto- ja kirjastoviittaukset */

/* 1.1 Mallivuosi, mallin sijainti, muistin k�ytt� ja TEMP-kirjaston tyhjennys */

%GLOBAL HAKEM LEVY KENO MVUOSI MUISTISSA TEMPTYHJ;

%LET MVUOSI = 2020; /* Mallivuosi (aineiston perusvuosi) */

%LET MUISTISSA = 0; /* K�ytet��nk� muistia simuloinnin nopeuttamiseksi
					   0 = ei (suositus ty�asemak�yt�ss�)
					   1 = kyll� (suositus FIONA-et�k�ytt�palvelimella)
					   Valinnalla 1 STARTDAT- ja TEMP-kirjastojen tiedostoja ei
					   kirjoiteta levylle vaan ne sijaitsevat vain muistissa. */

%LET TEMPTYHJ = 1;  /* Tyhjennet��nk� TEMP-kirjasto simulointikoodeissa tilan s��st�miseksi (1 = kyll�, 0 = ei) */

/* 1.2 Ohjelma, joka m��ritt�� sijaintilevyn ja hakemiston sek� kenoviivan ymp�rist�n mukaan */

/* Jos haluat m��ritt�� mallin sijainnin k�sin, k�yt� SYSCHECK-makron sijaan t�t� koodia: */
*%LET HAKEM = SISU; 	/* Kansio, jossa malli sijaitsee */
*%LET LEVY = C: ; 		/* Levyasema, jossa malli sijaitsee */
*%LET KENO = \; 		/* Kenoviivan suunta */

%MACRO SYSCHECK;
/* Jos mallia ajetaan AIX-ymp�rist�ss�, m��ritell��n sijainti k�sin */
%IF &SYSSCPL = AIX %THEN %DO;
		%LET HAKEM = USER/SISU; 	/* Kansio, jossa ohjelmakansiot ovat */
		%LET LEVY = %SYSGET(HOME) ; /* Levyasema, jossa ohjelma sijaitsee */
		%LET KENO = /;				/* Kenoviivan suunta */
%END;
/* Muussa tapauksessa k�ytet��n t�m�n ALKUsimul-koodin sijaintia mallin sijainnin m��ritt�miseksi */
%ELSE %DO;
	/* SAS EG:ss� tiedoston polku l�ytyy makromuuttujasta _SASPROGRAMFILE */
	%IF %SYMEXIST(_SASPROGRAMFILE) %THEN %DO;
		%LET POLKU = %SYSFUNC(COMPRESS(&_SASPROGRAMFILE, "'"));
	%END;
	/* Base SAS:ssa polku on SAS_EXECFILEPATH -system variablessa */
	%ELSE %DO;
		%LET POLKU = %SYSGET(SAS_EXECFILEPATH);
	%END;
	/* P��tell��n levyasema, jossa ohjelma sijaitsee */
	%LET LEVY = %SCAN(&POLKU, 1, '\');
	/* P��tell��n kansio, jossa ohjelmakansiot ovat */
	%LET HAKEM = %SUBSTR(&POLKU, %LENGTH(&LEVY) + 2, %LENGTH(&POLKU) - %LENGTH(%SCAN(&POLKU, -2, '\')) - %LENGTH(%SCAN(&POLKU, -1, '\')) - %LENGTH(&LEVY) - 3);
	%LET KENO = \;
%END;
%MEND SYSCHECK;

%SYSCHECK;

/* 1.3 M��ritell��n kirjastoviittaukset */

%MACRO TeeKirjastot;
LIBNAME PARAM "&LEVY&KENO&HAKEM&KENO.PARAM"; /* Muokattujen parametritiedostojen kirjasto */
LIBNAME POHJADAT "&LEVY&KENO&HAKEM&KENO.DATA&KENO.POHJADAT"; /* Pohja-aineistojen kirjasto (perusvuoden ja ajantasaistetut aineistot) */
LIBNAME STARTDAT "&LEVY&KENO&HAKEM&KENO.DATA&KENO.STARTDAT" %IF &MUISTISSA = 1 %THEN %DO; MEMLIB %END;; /* L�ht�aineiston (poiminta ja muokkaukset tehty) kirjasto */
LIBNAME TEMP "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.TEMP" %IF &MUISTISSA = 1 %THEN %DO; MEMLIB %END;; /* Apu- ja v�litaulukkojen kansio */ 
LIBNAME OUTPUT "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT"; /* Tulostaulukkojen kirjasto */
LIBNAME AJANT_R "&LEVY&KENO&HAKEM&KENO.AJANTASAISTUS&KENO.REK"; /* Ajantasaistusohjelmien- ja taulujen kirjasto */
LIBNAME SIMUL "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI"; /* Mallivuoden &MVUOSI aineistosimulointiohjelmien kirjasto */
LIBNAME ESIM "&LEVY&KENO&HAKEM&KENO.ESIM"; /* Esimerkkilaskelmien simulointiohjelmien kirjasto */
LIBNAME DOKUM "&LEVY&KENO&HAKEM&KENO.DOKUM"; /* Mallin dokumenttien kirjasto */
LIBNAME OHJAUS "&LEVY&KENO&HAKEM&KENO.OHJAUS"; /* Mallin ohjausparametrien kansio */
LIBNAME MAKROT "&LEVY&KENO&HAKEM&KENO.MAKROT"; /* Makrojen kirjasto */
%MEND TeeKirjastot;

%TeeKirjastot;

/* 2. T�ll� makrolla voi s��dell� lokin kirjoitusta, kun valitaan arvo optio-muuttujalle:
		0 = ei lokia;
		1 = NOTES, SOURCE ja SOURCE2;
		2 = my�s makroihin liittyv�t lokioptiot;
		Varoitus: Kaikkien makrolokioptioiden k�ytt� tuottaa hyvin pitk�n lokin. */

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

/* 3. M��ritell��n mallin ohjausparametrit globaaleiksi makromuuttujiksi */

/* 3.1 Makro globaalien makromuuttujien tuhoamista ja tyhjin� uudelleen
		luomista varten. Makro j�tt�� tuhoamatta makromuuttujat, jotka on m��ritelty
		OHJAUS.kaikki_param-taulun pysyvat-sarakkeessa.

Makroa kutsutaan jokaisen osamallin ja esimerkkilaskelman alussa.
*/

%MACRO TuhoaGlobaalit;
	/* T�m� makro tuhoaa globaalit makromuuttujat osamalleissa. Tuhoamista ei tehd� siin�
	tapauksessa, ett� mallia ajetaan KOKOsimul-koodin kautta (OUT = 1) tai silloin kun EG = 1.
	Jos et halua ett� makromuuttujasi tuhotaan, lis�� ne KAIKKI_PARAM-taulun pysyvat-sarakkeeseen. */
	%IF &OUT NE 1 AND &EG NE 1 %THEN %DO;
	
	%LOCAL tuhottavat;

	PROC SQL NOPRINT;
	SELECT name INTO :tuhottavat SEPARATED BY ' '
	FROM SASHELP.vmacro
	WHERE SCOPE = 'GLOBAL' AND name NOT IN(SELECT UPCASE(Pysyvat) FROM OHJAUS.KAIKKI_PARAM WHERE pysyvat NE '');
	QUIT;

	/* Tuhotaan globaalit makromuuttujat*/
	%SYMDEL &tuhottavat;

	/* Luodaan tilalle uudet tyhj�t globaalit makromuuttujat */
	%TeeGlobaalit;

	%LET START = &OUT;

	%END;
%MEND TuhoaGlobaalit;

/* 3.2 Makrolla luodaan osamalleissa k�ytetyt ohjausparametrit tyhjin� globaaleina makromuuttujina. */
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

			/* Vanhempainp�iv�rahojen esimerkkilaskentaa ohjaavat makromuuttujat */
			INFMUUNNOS ATIMUUNNOS PALKTASOV VRAHA_LASKE_VUOSITULOT

			/* VVERO-mallia ohjaavat makromuuttujat */
			TULOSNIMI_VVE LAKIMAK_TIED_VVE APUMAK_TIED_VVE PVVERO PVVERO_TUOTTEET
			KULUTUS KULUTUS_KOROTUS TUNNUSLUVUT KOKOSIMUL KOKOSIMUL_MUUTTUJAT

			/* Esimerkkilaskelmien formaatteja m��rittelev�t makromuuttujat */
			EROTIN DESIMAALIT

			/*TAMAKSUjen ty�el�kevakuutusmaksuprosentin valinta KuEL- ja VaEL-vakuutettujen palkkojen  osalta*/
			KUELVAELDATA
			
			/* Perhevapaauuudistuksen k�ytt��noton ilmaiseva makromuuttuja */
			PERHEVAP
			

			/*Ylim��r�isen indeksimuutoksen m��rittelyn makromuuttujat*/
			KEL_IND KEL_IND_EX KEL_KUUK KEL_INDEKSIKOROTUS
;

	/* 3.2.2 Osamallien nimet ohjausparametreina */

	%GLOBAL SAIRVAK TTURVA KANSEL KOTIHTUKI OPINTUKI VERO KIVERO LLISA ASUMTUKI ELASUMTUKI PHOITO TOIMTUKI VANHRAHA TAMAKSU;

	/* 3.2.3 Parametritaulukoiden alkuvuodet (ja ASUMTUKI-mallin erillisparametrien loppuvuosi) */

	%GLOBAL euro paramloppuyat paramalkusv paramalkukt paramalkutt paramalkull paramalkuto paramalkuke paramalkuve paramalkuyat paramalkueat paramalkuot;

	%LET paramalkusv = 1982;  /* Sairausvakuutuksen parametritaulukon l�ht�vuosi */
	%LET paramalkuot = 1992;  /* Opintotuen parametritaulukon l�ht�vuosi */
	%LET paramalkukt = 1985;  /* Kotihoidontuen parametritaulukon l�ht�vuosi */
	%LET paramalkutt = 1985;  /* Ty�tt�myysturvan parametritaulukon l�ht�vuosi */
	%LET paramalkull = 1948;  /* Lapsilis�n parametritaulukon l�ht�vuosi */
	%LET paramalkuto = 1989;  /* Toimeentulotuen parametritaulukon l�ht�vuosi */
	%LET paramalkuke = 1957;  /* Kansanel�kkeen parametritaulukon l�ht�vuosi */
	%LET paramalkuve = 1980;  /* Veromallin parametritaulukon l�ht�vuosi */
	%LET paramalkukv = 2009;  /* Kiinteist�veron parametritaulukon l�ht�vuosi */
	%LET paramalkuyat = 1990; /* Yleisen asumistuen parametritaulukon l�ht�vuosi */
	%LET paramalkueat = 1990; /* El�kkeensaajien asumistuen parametritaulukon l�ht�vuosi */
	%LET paramloppuyat = 2015; /* Yleisen asumistuen erillisparametritaulukoiden loppuvuosi */

	/* 3.2.4 Euron arvo (ParamInf&TYYPPI -makroilla on oma keyword variable euron arvon laskemista varten.
	   T�m�n makromuuttujan muuttaminen ei vaikuta ParamInf&TYYPPI-makroihin!) */

	%LET euro = 5.94573;

%MEND TeeGlobaalit;

/* Luodaan globaalit makromuuttujat */
%TeeGlobaalit;

/* 4. K�ytett�v�t templatet */

ODS PATH work.templat(UPDATE) sasuser.templat(READ) sashelp.tmplmst(READ);

/* M��ritet��n miten arvot tulostetaan PROC MEANS- ja PROC SUMMARY -proseduureilla */

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

/* 7. T�t� makromuuttujaa tutkimalla voi selvitt��, onko t�m� ohjelma ajettu */

%GLOBAL XALKU;
%LET XALKU = 1;
