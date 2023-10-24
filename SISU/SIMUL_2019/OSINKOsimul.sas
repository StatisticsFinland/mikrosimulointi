/******************************************************************************
* Kuvaus: Osinkoverotuksen erillislaskelma
* Päivitetty viimeksi: 27.4.2017	 
******************************************************************************/


/* Makro osinkojen sarjatason laskentaan.
	vuosi:				Lainsäädäntövuosi
	jaktyyppi: 			Osinkoja jakaneen yhtiön tyyppi:
						J noteerattu
						M noteeraamaton
						S noteeraamaton alle 500 jäsenen osuuskunta
	suorlaji: 			Suorituslaji
						01 Osinko
						02 Osuuspääoman korko (ennen vuotta 2015)
						03 Reit-osingot asuntojen vuokraustoiminnasta
						04 VOPR-osinko
						05 Osuuskunnan ylijäämä (vuodesta 2015)
						06 Osuuskunnan VOPR-ylijäämä (vuodesta 2015)
	netvar:				Osakeomistuksen osuus yhtiön nettovarallisuudesta
	osinkoe:			Maksettu osinko/osuuspääoman korko, euroa
	HenkYhtOsVapOsuus:	Listaamattoman yhtiön osinkojen nettovarallisuusosuus
						verovapaille osingoille
	JulkPOOsuus:		Listattujen yhtiöiden osinkojen pääomaverotulon alainen osuus	
	HenkYhtOsAnsOsuus:	Listaamattomien yhtiöiden nettovarallisuusrajan ylittävän
						osuuden ansiotuloveron alainen osuus
	JulkOSPOOsuus:		Julkisesti noteeratun osuuskunnan ylijäämän pääomatuloveron alainen osuus

*/

%macro OsinkojenJakoErillis(
		vuosi, jaktyypp, suorlaji, netvar, osinkoe,
		HenkYhtOsVapOsuus, JulkPOOsuus, HenkYhtOsAnsOsuus, JulkOSPOOsuus);

		/*=====================================================================
		Noteeraamattomat yritykset:
		---------------------------------------------------------------------*/
		if &jaktyypp = "M" and &suorlaji in ("01", "04") then do;

			RAJA = &HenkYhtOsVapOsuus * &netvar;

			/*=====================================================================
			Alle X% matemaattisesta arvosta:
				- kaikki verovapaata
			---------------------------------------------------------------------*/
			if &osinkoe <= RAJA then do;
				EILIST_VAPM = &osinkoe;
			end;

			/*=====================================================================
			Yli X% matemaattisesta arvosta:
				- vapa (vapaata), eli alle jäävä osa
				- at eli ansiotulo-osuus Y%:a
			---------------------------------------------------------------------*/
			else if &osinkoe > RAJA then do;
				EILIST_VAPM = RAJA;
				EILIST_AT = sum(&osinkoe, -RAJA) * &HenkYhtOsAnsOsuus;
			end;		

			/*=====================================================================
			Kaikki asetetaan eilistattujen bruttoon
			---------------------------------------------------------------------*/
			EILIST_BR = &osinkoe;

		end;

		/*=====================================================================
		Julkisesti noteeratut yritykset:
			- X%:a pääomatuloveron alaista, 1-X%a vapaata
		---------------------------------------------------------------------*/
		else if (&jaktyypp = "J" and &suorlaji in ("01", "04")) 
			or (&jaktyypp = '' and &suorlaji in ("01", "04"))
			then do;
				LIST_BR = &osinkoe;
				LIST_POT = &JulkPOOsuus * &osinkoe;
				LIST_VAPAA = sum(LIST_BR, -LIST_POT);	
		end;

		/*=====================================================================
		Noteeraamattomat REIT-yritykset:
			- kokonaan veronalaista, mutta jaetaan kuin muutkin
			  noteeraamattomat yritykset
		---------------------------------------------------------------------*/
		else if &jaktyypp = "M" and &suorlaji = "03" then do;

			RAJA = &HenkYhtOsVapOsuus * &netvar;

			/*=====================================================================
			Alle X% matemaattisesta arvosta:
				- luetaan pääomatuloksi
			---------------------------------------------------------------------*/
			if &osinkoe <= RAJA then do;
				EILISTREIT_POT = &osinkoe;
			end;

			/*=====================================================================
			Yli X% matemaattisesta arvosta:
				- vapa (vapaata), eli alle jäävä osa
				- at eli ansiotulo-osuus Y%:a
			---------------------------------------------------------------------*/
			else if &osinkoe > RAJA then do;
				EILISTREIT_POT = RAJA;
				EILISTREIT_AT = sum(&osinkoe, -RAJA);
			end;		

			/*=====================================================================
			Kaikki asetetaan eilistattujen REIT-yhtiöiden bruttoon
			---------------------------------------------------------------------*/
			EILISTREIT_BR = &osinkoe;

		end;

		/*=====================================================================
		Julkisesti noteeratut REIT-yritykset:
			- Kokonaan pääomatuloa
		---------------------------------------------------------------------*/

		else if &jaktyypp = "J" and &suorlaji = "03" then do;
			LISTREIT_POT = &osinkoe;
			LISTREIT_BR = &osinkoe;
		end;

		/*=============================================================================
		Noteeraamattomat osuuskunnat:
			- rajan ylittävältä osalta X%:a pääomatuloveron alaista, 1-X%:a vapaata,
			  lasketaan henkilötasolla loppuun
		-----------------------------------------------------------------------------*/

		else if (&jaktyypp = "M" and &suorlaji in ("02", "05", "06"))
			or (&jaktyypp = '' and &suorlaji in ("02", "05", "06"))
			then do;
				EILISTOS_PBR = &osinkoe;
				EILISTOS_BR = &osinkoe;
		end;

		/*=============================================================================
		Noteeraamattomat alle 500 jäsenen osuuskunnat:
		-----------------------------------------------------------------------------*/
		else if (&jaktyypp = "S" and &suorlaji in ("02", "05", "06")) then do;

			RAJA = &HenkYhtOsVapOsuus * &netvar;

			/*=====================================================================
			Alle X% matemaattisesta arvosta (tai jos simuloidaan lainsäädäntöä
			ennen vuotta 2015):
				- käsitellään kuin muitakin noteeraamattomia osuuskuntia
			---------------------------------------------------------------------*/
			if &osinkoe <= RAJA or &vuosi < 2015 then do;
				EILISTOS_PBR = &osinkoe;
			end;

			/*=====================================================================
			Yli X% matemaattisesta arvosta:
				- rajaan asti käsitellään kuin muitakin noteeraamattomia
				  osuuskuntia
				- rajan jälkeen Y%:a ansiotuloa
			---------------------------------------------------------------------*/	
			else do;
				EILISTOS_PBR = RAJA;
				EILISTOS_AT = sum(&osinkoe, -RAJA) * &HenkYhtOsAnsOsuus;
			end;
			
			/*=====================================================================
			Joka tapauksessa merkitään kaikki bruttoon
			---------------------------------------------------------------------*/	
			EILISTOS_BR = &osinkoe;

		end;

		/*==================================================================================================
		Julkisesti noteeratut osuuskunnat:
			- X%:a pääomatuloveron alaista, 1-X%:a vapaata
		---------------------------------------------------------------------------------------------------*/

		else if (&jaktyypp = "J" and &suorlaji in ("02", "05", "06"))
			then do;
				LISTOS_BR = &osinkoe;
				LISTOS_POT = &JulkOSPOOsuus * &osinkoe;
				LISTOS_VAPAA = (1-&JulkOSPOOsuus) * &osinkoe;
		end;

%mend OsinkojenJakoErillis;

/* Makro henkilötason osinkotulojen jaottelulle
vuosi:				Lainsäädäntövuosi
EILIST_VAPM:		Listaamattomien yhtiöiden osingot, alle X% matemaattisesta 
					nettovarallisuusarvosta
EILISTOS_PBR:		Se osa noteeraamattomien osuuskuntien ylijäämästä, josta
					päätellään pääomatuloveron alainen osuus
HenkYhtVapRaja:		Listaamattomien yhtiöden nettovarallisuusarvon alittavien 
					kevennetyn verotuksen osuus
HenkYhtPOOsuus1:	Noteeraamattomien yhtiöiden tuottorajan ja osinkorajan alittava 
					pääomatuloveronalainen osuus
HenkYhtPOOsuus2:	Noteeraamattomien yhtiöiden tuottorajan alittava ja osinkorajan ylittävä 
					pääomatuloveronalainen osuus
OspKorVeroVap:		Osuuspääoman korkojen verovapauden raja
OspKorkoPOOsuus:	Osuuspääoman korkojen pääomatulonveronalainen osuus
EiJulkOSPORaja:		Noteeraamattoman osuuskunnan ylijäämän verotuksen euroraja (€)
EiJulkOSPOOsuus1:	Noteeraamattoman osuuskunnan ylijäämän eurorajan alittavasta osuudesta 
					pääomatuloveron alaista
EiJulkOSPOOsuus2:	Noteeraamattoman osuuskunnan ylijäämän eurorajan ylittävästä osuudesta 
					pääomatuloveron alaista
*/

%macro HenkiloJaottelu(vuosi, eilist_vapm, eilistos_pbr, 
			HenkYhtVapRaja, HenkYhtPOOsuus1, HenkYhtPOOsuus2, OspKorVeroVap, 
		    OspKorkoPOOsuus, EiJulkOSPORaja, EiJulkOSPOOsuus1, EiJulkOSPOOsuus2); 

		/*=====================================================================
		Noteerattomat yhtiöt:
		---------------------------------------------------------------------*/

		if &HenkYhtVapRaja GT 0 then do;

			/*=====================================================================
			Jos noteeraamattomien yhtiöiden osinkojen vapaaprosentin alittavien
			yhteissumma ylittää kattorajan X euroa, tällöin:
			- raja*ali% + yli%:a rajan ylittävistä ovat veronalaista pääomatuloa.
			---------------------------------------------------------------------*/

			if &eilist_vapm > &HenkYhtVapRaja then do;
				EILIST_POT = sum(&HenkYhtVapRaja * (&HenkYhtPOOsuus1), sum(&eilist_vapm, -&HenkYhtVapRaja) * (&HenkYhtPOOsuus2));
			end;

			/*=====================================================================
			Jos noteeraamattomien yhtiöiden vapaaprosentin alittavien yhteissumma
			alittaa kattorajan X euroa.
			- raja*ali% on veronalaista pääomatuloa.
			---------------------------------------------------------------------*/
			else if &eilist_vapm <= &HenkYhtVapRaja then do;
				EILIST_POT = &eilist_vapm * (&HenkYhtPOOsuus1);
			end;

		end;

		/*=====================================================================
		Osuuskunnat (ennen vuotta 2015):
		---------------------------------------------------------------------*/
		if &vuosi < 2015 then do;

			/*=====================================================================
			- kattorajan alittava osa osuuspääoman koroista on verovapaata.
			- kattorajan ylittävä osuus pääomatulona verotettavaa.
			---------------------------------------------------------------------*/
			if &eilistos_pbr > &OspKorVeroVap then do;
				EILISTOS_POT = sum(&eilistos_pbr, -&OspKorVeroVap) * &OspKorkoPOOsuus;
			end;

		end;

		/*=============================================================================
		Noteerattomat osuuskunnat (vuodesta 2015 lähtien):
		-----------------------------------------------------------------------------*/
		else if &vuosi >= 2015 then do;

			/*=============================================================================
			Laskenta riippuu siitä ylittääkö bruttomäärä rajan. Jos alittaa:
			- brutto*ali% on veronalaista pääomatuloa.
			-----------------------------------------------------------------------------*/
			if &eilistos_pbr <= &EiJulkOSPORaja then do; 
				EILISTOS_POT = &EiJulkOSPOOsuus1 * &eilistos_pbr;
			end;

			/*=============================================================================
			Jos raja ylittyy:
			- raja*ali% + yli%:a rajan ylittävistä ovat veronalaista pääomatuloa
			-----------------------------------------------------------------------------*/
			else if &eilistos_pbr > &EiJulkOSPORaja then do;
				EILISTOS_POT = sum(&EiJulkOSPORaja * (&EiJulkOSPOOsuus1), sum(&eilistos_pbr, -&EiJulkOSPORaja) * (&EiJulkOSPOOsuus2));
			end;

		end;
	
%mend HenkiloJaottelu;


/*=============================================================================
Varsinainen simulointiohjelma:
1. Osinkosarjatason laskelmat
-----------------------------------------------------------------------------*/

* Lähtötaulun nimi ;

%let osavuosi = %substr(&avuosi., 3, 2); 
%let osdata = r&osavuosi._osingot;

data startdat.start_osinko; set pohjadat.&osdata;

	/* Luodaan muuttujat tyhjinä numeerisina */
	length RAJA EILIST_VAPM EILIST_AT EILIST_BR LIST_BR LIST_POT
		LIST_VAPAA EILISTREIT_BR EILISTREIT_AT EILISTREIT_POT
		LISTREIT_BR LISTREIT_POT LISTOS_BR LISTOS_POT LISTOS_VAPAA
		EILISTOS_AT EILISTOS_PBR EILISTOS_BR 8;

%OsinkojenJakoErillis(
		&LVUOSI, jaktyypp, suorlaji, dmat, osinkoe,
		&HenkYhtOsVapOsuus, &JulkPOOsuus, &HenkYhtOsAnsOsuus, &JulkOSPOOsuus);

	/*=========================================================================
	Korot ja osingot, brutto
	-------------------------------------------------------------------------*/
	OSINGOT_BR = osinkoe;

run;

/*=============================================================================
Varsinainen simulointiohjelma:
2. Summaus henkilötasolle
-----------------------------------------------------------------------------*/

proc sql;
create view temp.osingot_summa as select hnro,
	sum(OSINGOT_BR) as OSINGOT_BR,
	sum(EILIST_BR) as EILIST_BR,
	sum(EILIST_AT) as EILIST_AT,
	sum(EILIST_VAPM) as EILIST_VAPM,
	sum(LIST_BR) as LIST_BR,
	sum(LIST_POT) as LIST_POT,
	sum(LIST_VAPAA) as LIST_VAPAA,
	sum(EILISTREIT_BR) as EILISTREIT_BR,
	sum(EILISTREIT_AT) as EILISTREIT_AT,
	sum(EILISTREIT_POT) as EILISTREIT_POT,
	sum(LISTREIT_BR) as LISTREIT_BR,
	sum(LISTREIT_POT) as LISTREIT_POT,
	sum(EILISTOS_AT) as EILISTOS_AT,
	sum(EILISTOS_PBR) as EILISTOS_PBR,
	sum(EILISTOS_BR) as EILISTOS_BR,
	sum(LISTOS_BR) as LISTOS_BR,
	sum(LISTOS_POT) as LISTOS_POT,
	sum(LISTOS_VAPAA) as LISTOS_VAPAA
	
	from startdat.start_osinko
	group by hnro
	order by hnro;
quit;

/*=============================================================================
Varsinainen simulointiohjelma:
3. Henkilötason laskelma
-----------------------------------------------------------------------------*/

data temp.osingot_simuloitu;
	set temp.osingot_summa;

	%HenkiloJaottelu(&LVUOSI, EILIST_VAPM, EILISTOS_PBR, 
		&HenkYhtVapRaja, &HenkYhtPOOsuus1, &HenkYhtPOOsuus2, &OspKorVeroVap, 
		&OspKorkoPOOsuus, &EiJulkOSPORaja, &EiJulkOSPOOsuus1, &EiJulkOSPOOsuus2); 

	/*=====================================================================
	Lasketaan verovapaat osinkotulot ja verovapaat ylijäämät
	noteeraamattomista sekä kaikkien verovapaiden summat.
	---------------------------------------------------------------------*/
	EILIST_VAPAA = sum(EILIST_BR, -EILIST_POT, -EILIST_AT);
	EILISTOS_VAPAA = sum(EILISTOS_BR, -EILISTOS_POT, -EILISTOS_AT);

	OSIN_VAPAA = sum(LIST_VAPAA, EILIST_VAPAA);
	OSU_VAPAA= sum(LIST_VAPAA, EILIST_VAPAA, LISTOS_VAPAA, EILISTOS_VAPAA);

	drop EILIST_VAPM EILISTOS_PBR;

	/*=========================================================================
	Nimeämiset
	-------------------------------------------------------------------------*/
	label 
	OSINGOT_BR = "Osingot ja osuuspääoman ylijäämä yhtensä, MALLI"

	EILIST_BR = "Osingot noteeraamattomista yhtiöistä, MALLI"
	EILIST_AT = "Osingot noteeraamattomista yhtiöistä, ansiotuloveron alainen, MALLI"
	EILIST_POT = "Osingot noteeraamattomista yhtiöistä, pääomatuloveron alainen, MALLI"
	EILIST_VAPAA = "Osingot noteeraamattomista yhtiöistä, verovapaa osuus, MALLI"

	LIST_BR = "Osingot julkisesti noteeratuista yhtiöistä, MALLI"
	LIST_POT = "Osingot julkisesti noteeratuista yhtiöistä, pääomatuloveron alainen, MALLI"
	LIST_VAPAA = "Osingot julkisesti noteeratuista yhtiöistä, verovapaa osuus, MALLI"

	EILISTREIT_BR = "Osingot noteeraamattomista REIT-yhtiöistä, MALLI"
	EILISTREIT_AT = "Osingot noteeraamattomista REIT-yhtiöistä, ansiotuloveron alainen, MALLI"
	EILISTREIT_POT = "Osingot noteeraamattomista REIT-yhtiöistä, pääomatuloveron alainen, MALLI"

	LISTREIT_BR = "Osingot julkisesti noteeratuista REIT-yhtiöistä, MALLI"
	LISTREIT_POT = "Osingot julkisesti noteeratuista REIT-yhtiöistä, pääomatuloveron alainen, MALLI"

	EILISTOS_BR = "Noteeraamattomien osuuskuntien ylijäämä, MALLI"
	EILISTOS_AT = "Noteeraamattomien osuuskuntien ylijäämä, ansiotuloveron alainen, MALLI"
	EILISTOS_POT = "Noteeraamattomien osuuskuntien ylijäämä, pääomatuloveron alainen, MALLI"
	EILISTOS_VAPAA = "Noteeraamattomien osuuskuntien ylijäämä, verovapaa osuus, MALLI"

	LISTOS_BR = "Julkisesti noteerattujen osuuskuntien ylijäämä, MALLI"
	LISTOS_POT = "Julkisesti noteerattujen osuuskuntien ylijäämä, pääomatuloveron alainen, MALLI"
	LISTOS_VAPAA = "Julkisesti noteerattujen osuuskuntien ylijäämä, verovapaa osuus, MALLI"

	OSIN_VAPAA = "Osingot, verovapaat yhteensä, MALLI"
	OSU_VAPAA = "Osingot ja osuuspääoman ylijäämä, verovapaat yhteensä, MALLI";

run;

