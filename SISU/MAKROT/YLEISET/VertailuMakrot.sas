/*******************************************************************
*  Kuvaus: Apumakroja tulostaulujen kokoamiseen, vertailuun ja 	   *
*		   tarkastamiseen.            							   * 
*  Viimeksi p‰ivitetty: 24.1.2018 					               * 
*******************************************************************/

/* SISƒLLYS
0. K‰yttˆohje
1. RenameNum
2. LaskeMuutos
3. Korosta
4. LaskeErotus - P‰‰makro, tulostaulujen vertailu
5. Vertaile - P‰‰makro, aineistojen tarkastus ja vertailu
6. LaskeSimple

################################################################### */

/* ##### 0. K‰yttˆohje #####


Seuraavissa tiedostoissa on k‰yttˆliittym‰ tulostiedostojen ja aineistojen vertailuun:

	Taulukointi.sas				Summataulujen vertailu
	TaulukointiAineisto.sas		Aineistojen vertailu

Makrot ja k‰yttˆtarkoitus:

### LaskeErotus
Makroa k‰ytet‰‰n summataulujen yhdist‰miseen:

%LaskeErotus(tulos, inputTaulu1, inputTaulu2, tunnusluvut, suff1, suff2)

### Vertaile
Makroa k‰ytet‰‰n aineistojen tarkastamiseen ja aineistojen vertailemiseen:

%Vertaile(inputTaulu1, inputTaulu2, paino1 = ykor, paino2 = ykor,
	tunnusluvut = sum, luokat = , muuttujat = _NUMERIC_, suff1 = _1, suff2 = _2, tulos = varkastus);

# K‰yttˆohje 1: %LaskeErotus -makro

	%LaskeErotus(tulos, inputTaulu1, inputTaulu2, tunnusluvut, suff1, suff2)

	 tulos - tulostaulun osoite ja nimi
	 inputTaulu1 ja inputTaulu2 - saman kokoisia samoilla tunnusluvuilla laskettuja
		SISU-mallin tai muun taulun summatauluja
	 tunnusluvut - ne tunnusluvut mit‰ lˆytyy summataulusta (esim sum, mean jne.)
	 suff1 - p‰‰te ensimm‰isen taulun muuttujille
	 suff2 - p‰‰te toisen taulun muuttujille

	Yll‰ oleva esimerkki yhdist‰‰ kolme taulua ja vertaa ensimm‰isen taulun sum-sarakkeeseen.

Lis‰ksi alla olevalla koodilla voi laskea mist‰ tahansa aineistosta summataulun painolla ykor:

	PROC MEANS DATA = OUTPUT.tulostaulu SUM STACKODS;
	var _ALL_; * tai _NUMERIC_;
	ODS OUTPUT SUMMARY = OUTPUT.tulostaulu_s;
	WEIGHT ykor;
	RUN;

# K‰yttˆohje 2: %Vertaile -makro

Vertaile-makro summaa kaksi taulua, pakollisia parametreja ovat inputTaulu1 ja inputTaulu2,
jotka voivat olla mit‰ tahansa yksikkˆ- tai kotitaloustason tauluja.

	%Vertaile(inputTaulu1, inputTaulu2)

tai tarkastellessa vain tiettyj‰ muuttujia

	%Vertaile(inputTaulu1, inputTaulu2, muuttujat = lista muuttujista);

*/

/* ################### Summataulujen yhdist‰minen ################### */

/* ##### 1. RenameNum #####

Makro joka lis‰‰ data-askeleeseen yhden rivin RENAME-komentoja loopaten yli mlista-listan
ja lis‰ten alkuper‰isiin nimiin suff1-loppup‰‰tteen

Sis‰‰n:
	mlista
	suff1
*/

%MACRO RenameNum(mlista, suff1)/
DES = "VertailuMakrot: Apumakro muuttujien uudelleennime‰miseksi annetulla p‰‰tteell‰";
	%LOCAL apu_muuttuja k;
	%LET k = 1;
	%LET apu_muuttuja = %SCAN(&mlista,&k);
	%DO %WHILE ("&apu_muuttuja" NE "");
		RENAME &apu_muuttuja = &apu_muuttuja.&suff1;
		LABEL  &apu_muuttuja = &apu_muuttuja.&suff1;
		%LET k = %EVAL(&k+1);
		%LET apu_muuttuja = %SCAN(&mlista,&k);
	%END;
%MEND RenameNum;

/* ##### 2. LaskeMuutos #####

Macro joka laskee kahden muuttujan erotuksen loopaten yli mlista-listan, joka on lista  vertailtavista
tunnusluvuista. Makro palauttaa tarkastaustyˆkalua varten myˆs colorLista-makromuuttujan.

Sis‰‰n:
	mlista (tunnusluvut)
	suff1
	suff2

Uusien muuttujien nimiin yhdistet‰‰n suff1 ja suff2 p‰‰te p‰‰tteeksi suff1suff2 */

%MACRO LaskeMuutos(mlista, suff1, suff2)/
DES = "VertailuMakrot: Apumakro vertailtavien muuttujien erotuksen laskentaan";
	%LOCAL apu_muuttuja k;
	%LET k = 1;
	%LET apu_muuttuja = %SCAN(&mlista,&k);
	%DO %WHILE ("&apu_muuttuja" NE "");
		/* Laskutoimitukset */
		&apu_muuttuja._ero&suff1.&suff2 = &apu_muuttuja.&suff2 - &apu_muuttuja.&suff1;
		&apu_muuttuja._muutos&suff1.&suff2 = &apu_muuttuja._ero&suff1.&suff2 /  &apu_muuttuja.&suff1;
		LABEL &apu_muuttuja._ero&suff1.&suff2 = "Erotus &apu_muuttuja &suff2 - &suff1";
		LABEL &apu_muuttuja._muutos&suff1.&suff2 = "Muutospros &apu_muuttuja &suff2 - &suff1";

		%LET colorLista = &colorLista &apu_muuttuja._muutos&suff1.&suff2;

		%LET k = %EVAL(&k+1);
		%LET apu_muuttuja = %SCAN(&mlista,&k);
	%END;
%MEND LaskeMuutos;

/* ##### 3. Korosta #####

Makro, jolla lis‰t‰‰n v‰rikoodaus, jos v‰rikoodaus optio on p‰‰ll‰. Toimii PROC REPORT sis‰ll‰.


Sis‰‰n:
	lista
	raja1
	raja2

Listan muuttujien t‰ytyy lˆyty‰ ja olla uniikkeja. */

%MACRO Korosta(lista, raja1, raja2)/
DES = "VertailuMakrot: Apumakro v‰rikoodauksen lis‰‰miseksi vertailtaviin tauluihin";
  %LOCAL k haly_apu raja;
  %LET k=1;
  %LET haly_apu = %SCAN(&lista, &k);
     %DO %WHILE("&haly_apu" NE "");
	  DEFINE &haly_apu / DISPLAY;
	  COMPUTE &haly_apu;
		  IF abs(&haly_apu) >= &raja2 THEN CALL DEFINE(_col_,"style","style={background=yellow}");
		  IF abs(&haly_apu) >= &raja1 THEN CALL DEFINE(_col_,"style","style={background=red}");
	  ENDCOMP;
	  %LET k = %EVAL(&k + 1);
	  %LET haly_apu = %SCAN(&lista, &k);
  %END;
%MEND;

/* ##### 4. LaskeErotus #####

Makro luo work-hakemistoon tauluista kopiot, joihin tunnusluvut uudelleen nimet‰‰n loppup‰‰tteiden suff1 ja suff2 mukaan.
Makro yhdist‰‰ byvar mukaan, esimerkiksi: byvar = desmod ikavu variable.
Makro laskee tunnuslukujen eron.
Makro v‰ritt‰‰ muutokset, jotka ylitt‰v‰t ylemm‰n tai alemman rajan, jos tulostus ja v‰ri -asetukset on valittu.

Sis‰‰n ja keyword variablejen oletusarvot:
	tulos
	inputTaulu1
	inputTaulu2
	tunnusluvut
	suff1
	suff2
	byvar = variable
	tulosta = 1
	color = 1
	yRaja=0.01
	aRaja = 0.00001 

Makro k‰ytt‰‰ makroja:
	%RenameNum
	%LaskeMuutos
	%Korosta
*/

%MACRO LaskeErotus(tulos, inputTaulu1, inputTaulu2, tunnusluvut, suff1, suff2, byvar = variable, tulosta = 1, color = 1, yRaja=0.01, aRaja = 0.00001)/
DES = "VertailuMakrot: Yhdistett‰vien taulujen muuttujien erotuksen laskenta";

/* Lista johon tallennetaan muuttujat v‰rikoodausta varten */
%LOCAL colorLista;
%LET colorLista=;

/* Uudelleen nimet‰‰n taulujen muuttuja loppup‰‰tteiden mukaan */
DATA apu1_yhd;
	SET &inputTaulu1;
	%IF %TRIM("&suff1") NE "" %THEN %DO;
	%RenameNum(&tunnusluvut, &suff1);
	%END;
RUN;

DATA apu2_yhd;
	SET &inputTaulu2;
	%RenameNum(&tunnusluvut, &suff2);
RUN;

/* Yhdistet‰‰n */
PROC SORT DATA = apu1_yhd; BY &byvar; RUN;
PROC SORT DATA = apu2_yhd; BY &byvar; RUN;

DATA yhd_temp;
	MERGE apu1_yhd apu2_yhd;
	BY &byvar;
RUN;

DATA &tulos;
	SET yhd_temp;
	%LaskeMuutos(&tunnusluvut, &suff1, &suff2);
RUN;

/* Valitaan muutokset vertailtaviksi ja v‰rikoodattaviksi */
%IF &tulosta EQ 1 and &color EQ 1 %THEN %DO;
	PROC CONTENTS DATA = &tulos (DROP = %VarExist(&byvar label)) OUT = nimet (keep=NAME) NOPRINT; RUN;

	PROC SQL NOPRINT;
		SELECT NAME INTO :color_lista separated by ' ' 
		FROM nimet
		WHERE NAME like '%muutos%';
	QUIT;
%END;

/* Proc report avulla color coding t‰h‰n, jos optio = tosi
 HUOM! Jos columns _ALL_ -kohta tuottaa ongelmia (esim. tunnusluvun ollessa sum, mean, yms.)
SAS saattaa tulkita v‰‰rin: T‰llˆin muuta PROC PRINT tai RENAME tai tulosta erikseen */
%IF &tulosta EQ 1 %THEN %DO;
	PROC REPORT DATA = &tulos;
	%IF &color = 1 %THEN %DO;
		%Korosta(&colorLista, &yRaja, &aRaja);
		FORMAT _NUMERIC_ tuhat.;
		FORMAT &color_lista percentn6.2;
	%END;
	RUN;
%END;


%MEND;

/* ##### 5. Vertaile #####

Makro, joka laskee summataulun kahdelle sis‰‰n syˆtetylle taululle samalla tavalla kuin KOKOtulokset-makrossa.

Sis‰‰n ja oletusarvot:
	inputTaulu1
	inputTaulu2
	paino1 = ykor
	paino2 = ykor
	tunnusluvut = sum
	luokat = 
	suff1 = _1
	suff2 = _2
	tulos = tarkastus

*/

%MACRO Vertaile(inputTaulu1, inputTaulu2, paino1 = ykor, paino2 = ykor, tunnusluvut = sum, luokat = , muuttujat = _NUMERIC_, suff1 = _1, suff2 = _2, tulos = tarkastus)/
DES = "VertailuMakrot: Yhdistetty summataulujen tuottaminen kahdesta taulusta ja tulosten yhdist‰minen";
	%LOCAL i;
	%LET i = 1;
	%DO %WHILE (&i < 3);
	PROC MEANS DATA = &&inputTaulu&i &tunnusluvut STACKODS;
		VAR &muuttujat;
		CLASS &luokat / MLF PRELOADFMT;
		/*FORMAT _NUMERIC_ tuhat. ;*/
		%DO k = 1 %TO 3; 
			%IF %LENGTH (%SCAN(&luokat, &k)) >0 %THEN %DO;
				FORMAT %SCAN(&luokat, &k) %SCAN(&luokat, &k). ;
			%END;
		%END;
		ODS OUTPUT SUMMARY = valitulos&i;
		WEIGHT &&paino&i;
	RUN;
	%LET i = %EVAL(&i + 1);
	%END;

	%LaskeErotus(&tulos, valitulos1, valitulos2, &tunnusluvut, &suff1, &suff2, byvar = &luokat variable, color = 1);
%MEND Vertaile;


/* ##### 6. LaskeSimple #####

Yksinkertainen taulukointi. Ei laske muuttujien erotusta.

Makro luo work-hakemistoon tauluista kopiot, joihin tunnusluvut uudelleen nimet‰‰n loppup‰‰tteiden suff1 ja suff2 mukaan.
Makro yhdist‰‰ byvar mukaan, esimerkiksi: byvar = desmod ikavu variable.

Sis‰‰n ja keyword variablejen oletusarvot:
	tulos
	inputTaulu1
	inputTaulu2
	tunnusluvut
	suff1
	suff2
	byvar = variable

Makro k‰ytt‰‰ makroa:
	%RenameNum

*/
%MACRO LaskeSimple(tulos, inputTaulu1, inputTaulu2, tunnusluvut, suff1, suff2, byvar = variable)/
DES = "VertailuMakrot: Yksinkertainen tulostaulukoiden yhdist‰minen";

/* Uudelleen nimet‰‰n taulujen muuttuja loppup‰‰tteiden mukaan */
DATA apu1_yhd;
	SET &inputTaulu1;
	%IF %TRIM("&suff1") NE "" %THEN %DO;
	%RenameNum(&tunnusluvut, &suff1);
	%END;
RUN;

DATA apu2_yhd;
	SET &inputTaulu2;
	%RenameNum(&tunnusluvut, &suff2);
RUN;

/* Yhdistet‰‰n */
%IF "&byvar" NE "" %THEN %DO;
PROC SORT DATA = apu1_yhd; BY &byvar; RUN;
PROC SORT DATA = apu2_yhd; BY &byvar; RUN;
%END;

DATA &tulos;
	MERGE apu1_yhd apu2_yhd;
	%IF "&byvar" NE "" %THEN %DO;
		BY &byvar;
	%END;
RUN;

%MEND LaskeSimple;