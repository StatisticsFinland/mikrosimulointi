/********************************************************************
*  Kuvaus: Makro kahden yksikkötason aineiston vertailuun			*
*  Viimeksi päivitetty: 18.12.2014									* 
********************************************************************/

%MACRO Aloitus;
	/* Luodaan paikalliset muuttujat */
	%LOCAL muuttujat luokat tunnusluvut suff1 suff2 paino1 paino2 inputTaulu1 inputTaulu2 tulos;

	%LET tulos = WORK.Tulos; /* Tulostiedoston nimi */

	%LET inputTaulu1 = POHJADAT.PALV2012(obs = 10k); /* Ensimmäinen taulu */
	%LET inputTaulu2 = POHJADAT.PALV2012(firstobs = 100 obs = 10k); /* Toinen liitettävä taulu */

	%LET suff1 = _palv1; /* Jos yhdistetään useampia tauluna, käytetään suff1 = ; */
	%LET suff2 = _palv2;
	%LET paino1 = ykor;
	%LET paino2 = ykor;

	%LET tunnusluvut = sum; /* Vertailtavat tunnusluvut */
	%LET luokat = ikavu ; /* desmod variable | rake variable | ikavu ... */
	%LET muuttujat = palkatyht sahko; /* Valitut muuttujat */

	/* Ajetaan makro yllä olevilla asetuksilla, älä muuta */
	%Vertaile(&inputTaulu1, &inputTaulu2, paino1 = &paino1, paino2 = &paino2,
	tunnusluvut = &tunnusluvut, luokat = &luokat, muuttujat = &muuttujat, suff1 = &suff1, suff2 = &suff2, tulos = &tulos);

%MEND Aloitus;

%Aloitus;
