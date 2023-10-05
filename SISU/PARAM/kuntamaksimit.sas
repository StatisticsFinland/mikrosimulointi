
/***********************************************************/
/*Ohjelma TOTU:n asumiskustannusten maksimien p‰ivitt‰miseen
/***********************************************************/

/*Ks. ohje TOTU:n kuntamaksimien p‰ivitt‰miseen teams-kanavalta Lakip‰ivitykset-kansiosta*/
libname out "g:/sas";
proc import out = out.asumnormit
	datafile = "G:\sas\asummenot2023.xlsx"
	dbms = xlsx replace;
	getnames = yes;
run;

/*=============================================================================
Liitet‰‰n kuntavero-aineistoon kuntanumerot luokitus-kirjastosta (Selected Server = SASTuotanto1)
-----------------------------------------------------------------------------*/

data kuntakoodit;
	set luok.kunta_1_20_s;
	nimike = upcase(nimike);
run;

/*Kopioi t‰ss‰ kohtaa asumnormit-data localin workista SASTuontanto1:n workiin*/

data asumnormit2; *Korotetaan kuntanimet isoiksi liitt‰mist‰ varten;
	length nimike $18.;
	set asumnormit;
	nimike = upcase(nimike);	
run;

proc sql; *Liitet‰‰n kuntanumero dataan;
	create table yhd as 
	select a.*,
			b.koodi
	from asumnormit2 as a 
	left join kuntakoodit as b 
	on a.nimike = b.nimike;
quit;

/*Tarkistetaan, ett‰ kaikille tuli koodi*/


proc sql; *Tarkista ett‰ t‰m‰ on 0 (ei puuttuvia koodeja);
	select nimike, koodi
	from yhd
	where koodi='';

quit;


/*Tallennetaan. Kopioi data "yhd" ensin localin workiin ja vaihda localille*/

*libname kansio 'G:\Mikrosimulointi\Mallip‰ivitykset\totu_asumisnormit';

data out.asummenorajat2023;
set yhd;
run;