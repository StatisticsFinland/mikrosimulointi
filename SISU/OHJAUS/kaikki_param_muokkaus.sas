%macro lisaa_parametrit(sarakenimi=, parametrit=, euromaarainen=1, taulu=ohjaus.kaikki_param);

/* Vaihe 1: Luo taulu syötearvoilla */
	%macro luo_syote_arvot;
		data parametrit;
		length arvo $32;
		%let i = 1;
			%do %while (%scan(&parametrit, &i) ne );
				arvo = "%scan(&parametrit, &i)";
				output;
				%let i = %eval(&i + 1);
			%end;
		run;
	%mend luo_syote_arvot;

	%luo_syote_arvot;

/* Vaihe 2: Päivitä pääasiallinen taulu */
	data valiaikainen_taulu;
		set &taulu;
		if _N_ = 1 then set parametrit nobs=nobs;
		retain paivitetty_lkm 0;
		point_num = paivitetty_lkm + 1; 

		/* Tarkista, että sarake on olemassa */
		if vname(&sarakenimi) ne '' then do;
			if paivitetty_lkm < nobs then do;
				if &sarakenimi = '' then do;
					set parametrit point=point_num; 
					&sarakenimi = arvo;
				if &euromaarainen then
					&sarakenimi._m = 'x';
				else
					&sarakenimi._m = "";
				paivitetty_lkm + 1;
				point_num = paivitetty_lkm + 1; 
				end;
			end;
		end;
			else put "VIRHE: Sarake &sarakenimi ei ole olemassa taulussa.";
		run;

		/* Luodaan lopullinen versio taulusta*/
		data &taulu(drop=paivitetty_lkm arvo);
		set valiaikainen_taulu;

	run;

%mend lisaa_parametrit;

/* Esimerkki makrokutsusta: 

sarakenimi: 	Kirjoita osamallin nimi, jonka parametritauluun parametri on lisätty. Tarkista tarvittaessa sarakkeen nimi kaikki_param-taulusta.
parametrit: 	Lisättävät parametrit. Jos lisäät useamman parametrin, käytä erottimena pelkkää välilyöntiä. 
euromaarainen: 	Onko lisättävät parametrit euromääräisiä, eli halutaanko niille tehdä rahanarvonmuunnoksia (kyllä=1, ei=0).
taulu: 			Päivitettävä taulu (kirjastoviite.taulun_nimi).

*/

/* Varsinainen makrokutsu, jota muokkaamalla voi lisätä haluamasi muuttujat tauluun */

*Esimerkki makrokutsusta;
%lisaa_parametrit(sarakenimi=OPINTUKI, parametrit=VuokraKatto1 VuokraKatto2 VuokraKatto3, euromaarainen=1, taulu=ohjaus.kaikki_param);

