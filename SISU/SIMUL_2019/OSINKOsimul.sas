/******************************************************************************
* Kuvaus: Osinkoverotuksen erillislaskelma
* P�ivitetty viimeksi: 27.4.2017	 
******************************************************************************/


/* Makro osinkojen sarjatason laskentaan.
	vuosi:				Lains��d�nt�vuosi
	jaktyyppi: 			Osinkoja jakaneen yhti�n tyyppi:
						J noteerattu
						M noteeraamaton
						S noteeraamaton alle 500 j�senen osuuskunta
	suorlaji: 			Suorituslaji
						01 Osinko
						02 Osuusp��oman korko (ennen vuotta 2015)
						03 Reit-osingot asuntojen vuokraustoiminnasta
						04 VOPR-osinko
						05 Osuuskunnan ylij��m� (vuodesta 2015)
						06 Osuuskunnan VOPR-ylij��m� (vuodesta 2015)
	netvar:				Osakeomistuksen osuus yhti�n nettovarallisuudesta
	osinkoe:			Maksettu osinko/osuusp��oman korko, euroa
	HenkYhtOsVapOsuus:	Listaamattoman yhti�n osinkojen nettovarallisuusosuus
						verovapaille osingoille
	JulkPOOsuus:		Listattujen yhti�iden osinkojen p��omaverotulon alainen osuus	
	HenkYhtOsAnsOsuus:	Listaamattomien yhti�iden nettovarallisuusrajan ylitt�v�n
						osuuden ansiotuloveron alainen osuus
	JulkOSPOOsuus:		Julkisesti noteeratun osuuskunnan ylij��m�n p��omatuloveron alainen osuus

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
				- vapa (vapaata), eli alle j��v� osa
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
			- X%:a p��omatuloveron alaista, 1-X%a vapaata
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
				- luetaan p��omatuloksi
			---------------------------------------------------------------------*/
			if &osinkoe <= RAJA then do;
				EILISTREIT_POT = &osinkoe;
			end;

			/*=====================================================================
			Yli X% matemaattisesta arvosta:
				- vapa (vapaata), eli alle j��v� osa
				- at eli ansiotulo-osuus Y%:a
			---------------------------------------------------------------------*/
			else if &osinkoe > RAJA then do;
				EILISTREIT_POT = RAJA;
				EILISTREIT_AT = sum(&osinkoe, -RAJA);
			end;		

			/*=====================================================================
			Kaikki asetetaan eilistattujen REIT-yhti�iden bruttoon
			---------------------------------------------------------------------*/
			EILISTREIT_BR = &osinkoe;

		end;

		/*=====================================================================
		Julkisesti noteeratut REIT-yritykset:
			- Kokonaan p��omatuloa
		---------------------------------------------------------------------*/

		else if &jaktyypp = "J" and &suorlaji = "03" then do;
			LISTREIT_POT = &osinkoe;
			LISTREIT_BR = &osinkoe;
		end;

		/*=============================================================================
		Noteeraamattomat osuuskunnat:
			- rajan ylitt�v�lt� osalta X%:a p��omatuloveron alaista, 1-X%:a vapaata,
			  lasketaan henkil�tasolla loppuun
		-----------------------------------------------------------------------------*/

		else if (&jaktyypp = "M" and &suorlaji in ("02", "05", "06"))
			or (&jaktyypp = '' and &suorlaji in ("02", "05", "06"))
			then do;
				EILISTOS_PBR = &osinkoe;
				EILISTOS_BR = &osinkoe;
		end;

		/*=============================================================================
		Noteeraamattomat alle 500 j�senen osuuskunnat:
		-----------------------------------------------------------------------------*/
		else if (&jaktyypp = "S" and &suorlaji in ("02", "05", "06")) then do;

			RAJA = &HenkYhtOsVapOsuus * &netvar;

			/*=====================================================================
			Alle X% matemaattisesta arvosta (tai jos simuloidaan lains��d�nt��
			ennen vuotta 2015):
				- k�sitell��n kuin muitakin noteeraamattomia osuuskuntia
			---------------------------------------------------------------------*/
			if &osinkoe <= RAJA or &vuosi < 2015 then do;
				EILISTOS_PBR = &osinkoe;
			end;

			/*=====================================================================
			Yli X% matemaattisesta arvosta:
				- rajaan asti k�sitell��n kuin muitakin noteeraamattomia
				  osuuskuntia
				- rajan j�lkeen Y%:a ansiotuloa
			---------------------------------------------------------------------*/	
			else do;
				EILISTOS_PBR = RAJA;
				EILISTOS_AT = sum(&osinkoe, -RAJA) * &HenkYhtOsAnsOsuus;
			end;
			
			/*=====================================================================
			Joka tapauksessa merkit��n kaikki bruttoon
			---------------------------------------------------------------------*/	
			EILISTOS_BR = &osinkoe;

		end;

		/*==================================================================================================
		Julkisesti noteeratut osuuskunnat:
			- X%:a p��omatuloveron alaista, 1-X%:a vapaata
		---------------------------------------------------------------------------------------------------*/

		else if (&jaktyypp = "J" and &suorlaji in ("02", "05", "06"))
			then do;
				LISTOS_BR = &osinkoe;
				LISTOS_POT = &JulkOSPOOsuus * &osinkoe;
				LISTOS_VAPAA = (1-&JulkOSPOOsuus) * &osinkoe;
		end;

%mend OsinkojenJakoErillis;

/* Makro henkil�tason osinkotulojen jaottelulle
vuosi:				Lains��d�nt�vuosi
EILIST_VAPM:		Listaamattomien yhti�iden osingot, alle X% matemaattisesta 
					nettovarallisuusarvosta
EILISTOS_PBR:		Se osa noteeraamattomien osuuskuntien ylij��m�st�, josta
					p��tell��n p��omatuloveron alainen osuus
HenkYhtVapRaja:		Listaamattomien yhti�den nettovarallisuusarvon alittavien 
					kevennetyn verotuksen osuus
HenkYhtPOOsuus1:	Noteeraamattomien yhti�iden tuottorajan ja osinkorajan alittava 
					p��omatuloveronalainen osuus
HenkYhtPOOsuus2:	Noteeraamattomien yhti�iden tuottorajan alittava ja osinkorajan ylitt�v� 
					p��omatuloveronalainen osuus
OspKorVeroVap:		Osuusp��oman korkojen verovapauden raja
OspKorkoPOOsuus:	Osuusp��oman korkojen p��omatulonveronalainen osuus
EiJulkOSPORaja:		Noteeraamattoman osuuskunnan ylij��m�n verotuksen euroraja (�)
EiJulkOSPOOsuus1:	Noteeraamattoman osuuskunnan ylij��m�n eurorajan alittavasta osuudesta 
					p��omatuloveron alaista
EiJulkOSPOOsuus2:	Noteeraamattoman osuuskunnan ylij��m�n eurorajan ylitt�v�st� osuudesta 
					p��omatuloveron alaista
*/

%macro HenkiloJaottelu(vuosi, eilist_vapm, eilistos_pbr, 
			HenkYhtVapRaja, HenkYhtPOOsuus1, HenkYhtPOOsuus2, OspKorVeroVap, 
		    OspKorkoPOOsuus, EiJulkOSPORaja, EiJulkOSPOOsuus1, EiJulkOSPOOsuus2); 

		/*=====================================================================
		Noteerattomat yhti�t:
		---------------------------------------------------------------------*/

		if &HenkYhtVapRaja GT 0 then do;

			/*=====================================================================
			Jos noteeraamattomien yhti�iden osinkojen vapaaprosentin alittavien
			yhteissumma ylitt�� kattorajan X euroa, t�ll�in:
			- raja*ali% + yli%:a rajan ylitt�vist� ovat veronalaista p��omatuloa.
			---------------------------------------------------------------------*/

			if &eilist_vapm > &HenkYhtVapRaja then do;
				EILIST_POT = sum(&HenkYhtVapRaja * (&HenkYhtPOOsuus1), sum(&eilist_vapm, -&HenkYhtVapRaja) * (&HenkYhtPOOsuus2));
			end;

			/*=====================================================================
			Jos noteeraamattomien yhti�iden vapaaprosentin alittavien yhteissumma
			alittaa kattorajan X euroa.
			- raja*ali% on veronalaista p��omatuloa.
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
			- kattorajan alittava osa osuusp��oman koroista on verovapaata.
			- kattorajan ylitt�v� osuus p��omatulona verotettavaa.
			---------------------------------------------------------------------*/
			if &eilistos_pbr > &OspKorVeroVap then do;
				EILISTOS_POT = sum(&eilistos_pbr, -&OspKorVeroVap) * &OspKorkoPOOsuus;
			end;

		end;

		/*=============================================================================
		Noteerattomat osuuskunnat (vuodesta 2015 l�htien):
		-----------------------------------------------------------------------------*/
		else if &vuosi >= 2015 then do;

			/*=============================================================================
			Laskenta riippuu siit� ylitt��k� bruttom��r� rajan. Jos alittaa:
			- brutto*ali% on veronalaista p��omatuloa.
			-----------------------------------------------------------------------------*/
			if &eilistos_pbr <= &EiJulkOSPORaja then do; 
				EILISTOS_POT = &EiJulkOSPOOsuus1 * &eilistos_pbr;
			end;

			/*=============================================================================
			Jos raja ylittyy:
			- raja*ali% + yli%:a rajan ylitt�vist� ovat veronalaista p��omatuloa
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

* L�ht�taulun nimi ;

%let osavuosi = %substr(&avuosi., 3, 2); 
%let osdata = r&osavuosi._osingot;

data startdat.start_osinko; set pohjadat.&osdata;

	/* Luodaan muuttujat tyhjin� numeerisina */
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
2. Summaus henkil�tasolle
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
3. Henkil�tason laskelma
-----------------------------------------------------------------------------*/

data temp.osingot_simuloitu;
	set temp.osingot_summa;

	%HenkiloJaottelu(&LVUOSI, EILIST_VAPM, EILISTOS_PBR, 
		&HenkYhtVapRaja, &HenkYhtPOOsuus1, &HenkYhtPOOsuus2, &OspKorVeroVap, 
		&OspKorkoPOOsuus, &EiJulkOSPORaja, &EiJulkOSPOOsuus1, &EiJulkOSPOOsuus2); 

	/*=====================================================================
	Lasketaan verovapaat osinkotulot ja verovapaat ylij��m�t
	noteeraamattomista sek� kaikkien verovapaiden summat.
	---------------------------------------------------------------------*/
	EILIST_VAPAA = sum(EILIST_BR, -EILIST_POT, -EILIST_AT);
	EILISTOS_VAPAA = sum(EILISTOS_BR, -EILISTOS_POT, -EILISTOS_AT);

	OSIN_VAPAA = sum(LIST_VAPAA, EILIST_VAPAA);
	OSU_VAPAA= sum(LIST_VAPAA, EILIST_VAPAA, LISTOS_VAPAA, EILISTOS_VAPAA);

	drop EILIST_VAPM EILISTOS_PBR;

	/*=========================================================================
	Nime�miset
	-------------------------------------------------------------------------*/
	label 
	OSINGOT_BR = "Osingot ja osuusp��oman ylij��m� yhtens�, MALLI"

	EILIST_BR = "Osingot noteeraamattomista yhti�ist�, MALLI"
	EILIST_AT = "Osingot noteeraamattomista yhti�ist�, ansiotuloveron alainen, MALLI"
	EILIST_POT = "Osingot noteeraamattomista yhti�ist�, p��omatuloveron alainen, MALLI"
	EILIST_VAPAA = "Osingot noteeraamattomista yhti�ist�, verovapaa osuus, MALLI"

	LIST_BR = "Osingot julkisesti noteeratuista yhti�ist�, MALLI"
	LIST_POT = "Osingot julkisesti noteeratuista yhti�ist�, p��omatuloveron alainen, MALLI"
	LIST_VAPAA = "Osingot julkisesti noteeratuista yhti�ist�, verovapaa osuus, MALLI"

	EILISTREIT_BR = "Osingot noteeraamattomista REIT-yhti�ist�, MALLI"
	EILISTREIT_AT = "Osingot noteeraamattomista REIT-yhti�ist�, ansiotuloveron alainen, MALLI"
	EILISTREIT_POT = "Osingot noteeraamattomista REIT-yhti�ist�, p��omatuloveron alainen, MALLI"

	LISTREIT_BR = "Osingot julkisesti noteeratuista REIT-yhti�ist�, MALLI"
	LISTREIT_POT = "Osingot julkisesti noteeratuista REIT-yhti�ist�, p��omatuloveron alainen, MALLI"

	EILISTOS_BR = "Noteeraamattomien osuuskuntien ylij��m�, MALLI"
	EILISTOS_AT = "Noteeraamattomien osuuskuntien ylij��m�, ansiotuloveron alainen, MALLI"
	EILISTOS_POT = "Noteeraamattomien osuuskuntien ylij��m�, p��omatuloveron alainen, MALLI"
	EILISTOS_VAPAA = "Noteeraamattomien osuuskuntien ylij��m�, verovapaa osuus, MALLI"

	LISTOS_BR = "Julkisesti noteerattujen osuuskuntien ylij��m�, MALLI"
	LISTOS_POT = "Julkisesti noteerattujen osuuskuntien ylij��m�, p��omatuloveron alainen, MALLI"
	LISTOS_VAPAA = "Julkisesti noteerattujen osuuskuntien ylij��m�, verovapaa osuus, MALLI"

	OSIN_VAPAA = "Osingot, verovapaat yhteens�, MALLI"
	OSU_VAPAA = "Osingot ja osuusp��oman ylij��m�, verovapaat yhteens�, MALLI";

run;

