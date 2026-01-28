/*******************************************************************
*  Kuvaus: Tuloverotuksen lains‰‰d‰ntˆ‰ makroina                   *
*******************************************************************/

/* SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/* 
1. TulonHankVahS = Tulonhankkimisv‰hennys
2. TyoMatkaVahS = Tyˆmatkakuluv‰hennys
3. AsuntoVahennysS = Asuntov‰hennys (ns. kakkosasunnon verov‰hennys)
4. TulonHankKulutS = Tulonankkimisv‰hennys, tyˆmatkakuluv‰hkennys ja ay-j‰senmaksujen v‰hennys yhdistettyn‰
5. TyoelMaksuS = Palkansaajan tyˆel‰kemaksu
6. TyotMaksuS = Palkansaajan tyˆttˆmyysvakuutusmaksu
7. SvPRahaMaksuS = Sairausvakuutuksen p‰iv‰rahamaksu, perusversio
8. SvPRahaMaksuYS = Sairausvakuutuksen p‰iv‰rahamaksu, yritystulon korotettu maksu huomioon otettuna
9. KunnAnsVahS = Kunnallisverotuksen ansiotulov‰hennys (voimassa vuoteen 2022 asti)
10. KunnElTulVahS = Kunnallisverotuksen el‰ketulov‰hennys (voimassa vuoteen 2022 asti)
11. KunnOpRahVahS = Kunnallisverotuksen opintorahav‰hennys (voimassa vuoteen 2022 asti)
12. KunnVerInvVahS = Kunnallisverotuksen invalidiv‰hennys (voimassa vuoteen 2022 asti)
13. KunnPerVahS = Kunnallisverotuksen perusv‰hennys (voimassa vuoteen 2022 asti)
14. SairVakMaksuS = Sairausvakuutusmaksu, lyhennetty kaava
15. KanselVakMaksuS = Kansanel‰kevakuutusmaksu, lyhennetty kaava
16. KunnVeroS = Kunnallisvero: joko keskim‰‰r‰inen tai valittu veroprosentti
17. KirkVeroS = Kirkollisvero: joko keskim‰‰r‰inen tai valittu veroprosentti
18. ValtTyoTuloVahS = Valtionverotuksen tyˆtulov‰hennys (voimassa vuoteen 1988 asti)
19. ValtElTulVahS = Valtionverotuksen el‰ketulov‰hennys (voimassa vuoteen 2022 asti)
20. TyotVahS = Tyˆtulov‰hennys (ent. valtionverotuksen ansiotulov‰hennys) (v‰hennys verosta)
21. ValtVerInvVahS = Valtionverotuksen invalidiv‰hennys (v‰hennys verosta) (voimassa vuoteen 2022 asti)
22. ValtVerElVelvVahS = Valtionverotuksen elatusvelvollisuusv‰hennys (v‰hennys verosta)
23. ValtTuloVeroS = Valtion tulovero (veroasteikko)
24. TuloVerot_SimpleS = Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa
25. TuloVerot_SimpleMargS = Marginaaliveroaste palkkaverotuksen yksinkertaisessa perustapauksessa
26. BruttotuloS = Nettokuukausitulosta johdettu bruttotulo palkansaajalla
27. TuloVerot_Simple_ElakeS = El‰ketulon verot yksinkertaisessa perustapauksessa
28. TuloVerot_Simple_PRahaS = P‰iv‰rahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa
29. PomaOsuusS = Jaettavan yritystulon tai muun kuin pˆrssiyhtiˆn osingon tai siihen liittyv‰n yhtiˆveron hyvityksen p‰‰omatulo-osuus
30. OsinkojenJakoS  = Osinkotulojen jakaminen p‰‰omatuloksi, ansiotuloiksi ja verottomiksi tuloksi
31. AlijHyvS = Alij‰‰m‰hyvitys
32. AlijHyvKotitS = Alij‰‰m‰hyvitys kotitaloustasolla
33. AlijHyvEritS = Erityinen alij‰‰m‰hyvitys
34. YhtHyvS = Yhtiˆveron hyvitys
35. VahAsKorotS = V‰hennyskelpoiset asuntolainan korot
36. POTulonVeroEritS = P‰‰omatulon vero, vapaaeht. el‰kevakuutusmaksut huomioon otettuna
37. KotiTalVahS = Kotitalousv‰hennys
38. VahennJakoS = V‰hennysten jakaminen eri verolajeille
39. AlijHyvJakoS = Alij‰‰m‰hyvityksen jakaminen eri verolajeille
40. YhtHyvJakoS = Yhtiˆveron hyvityksen jakaminen eri verolajeille
41. ValtLapsVahS = Valtionverotuksen lapsenhoitov‰hennys (nimen‰ myˆs ylim‰‰r‰inen tyˆtulov‰hennys)
42. KunnLapsVahS = Kunnallisverotuksen lapsenhoitov‰hennys (huom! sis‰lt‰‰ myˆs yksinhuoltajav‰hennyksen) 
43. KunnYksVahS = Kunnallisverotuksen yksinhuoltajav‰hennys
44. VarallVeroS = Varallisuusvero
45. KunnElTulVahMaxS = Kunnallisverotuksen el‰ketulov‰hennyksen maksimiarvo = t‰ysi el‰ketulov‰hennys
46. ValtElTulVahMaxS = Valtionverotuksen el‰ketulov‰hennyksen maksimiarvo = t‰ysi el‰ketulov‰hennys
47. ElVeroRajaS = Raja, josta el‰ketulon verotus alkaa
48. ValtVerRajaS =  Valtion tuloverotuksen alaraja
49. KunnVerRajaS = Kunnan tuloverotuksen alaraja
50. YleVeroS = YLE-vero
51. ValtVero_Final = Valtionvero kun verotuksen kattos‰‰nnˆs otetaan huomioon
52. ElakeLisaVero = El‰ketulon lis‰vero
53. ValtVerLapsVah = Lapsiv‰hennys
54. KunnVerMeriVahS = Kunnallisverotuksen merityˆtulov‰hennys (voimassa vuoteen 2022 asti)
55. ValtVerMeriVahS = Valtionverotuksen merityˆtulov‰hennys (voimassa vuoteen 2022 asti)
56. TuloVerot_Simple_PRahTyoS = Tuloverot yksinkertaisessa perustapauksessa, jossa p‰iv‰raha ja palkkatuloja
57. KotitVahErillS = Kotitalousv‰hennyksen lis‰datan laskentamakro
58. KotitVahErillJakoS = Kotitalousv‰hennyksen lis‰datan laskentamakro tyˆn lajeittain
59. YrittajaVahS = Yritt‰j‰v‰hennys
60. KunnVerKerroin = Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen veroprosentin muuntamiseen tarvittavat kertoimet
61. VahennysSwap = Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken
61. VerMeriVahS = Merityˆtulov‰hennys (voimassa vuodesta 2023 alkaen)
62. OpRahVahS = Opintorahav‰hennys (voimassa vuodesta 2023 alkaen)
63. AnsVahS = Ansiotulov‰hennys (voimassa vuosina 2023-2024)
64. ElTulVahS = El‰ketulov‰hennys (voimassa vuodesta 2023 alkaen)
65. PerVahS = Perusv‰hennys (voimassa vuodesta 2023 alkaen)

*/

/* 1. Tulonhankkimisv‰hennys. 
	  Tuottaa palkkatuloista automaattisen v‰hennyksen. 
      Jos tulonhankkimiskulut ovat suurempia kuin automaattinen v‰hennys, 
      edelliset m‰‰rittelev‰t v‰hennyksen suuruuden */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonhankkimisv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut;

%MACRO TulonHankVahS(tulos, mvuosi, minf, palkkatulo, tulonhankkulut)/
DES = 'VERO: Tulonhankkimisv‰hennys';

%HAKU;

&tulos = &TulonHankkAlaRaja + &TulonHankPros * &palkkatulo;

IF &tulos > &TulonHankk THEN &tulos = &TulonHankk;

IF &tulos > &palkkatulo THEN &tulos = &palkkatulo;

IF &tulonhankkulut > &tulos THEN &tulos = min(&tulonhankkulut, &palkkatulo);
	
%MEND TulonHankVahS;


/* 2. Tyˆmatkakuluv‰hennys.
	  V‰hennyksess‰ otetaan huomioon alennettu omavastuu tyˆttˆmille, joka
	  on ollut parametreissa vuodesta 1999 l‰htien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tyˆmatkakuluv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	tyomatkakulut: Ilmoitetut tyˆmatkakulut
	tyotkuuk: Tyˆttˆmyyskuukaudet;

%MACRO TyoMatkaVahS(tulos, mvuosi, minf, tyomatkakulut, tyotkuuk)/
DES = 'VERO: Tyˆmatkakuluv‰hennys';

%HAKU;

omavast = &MatkOmaVast;

IF &tyotkuuk > 0 THEN DO;
	omavast = &MatkOmaVast - &tyotkuuk * &TyotMatkOmVast;

	IF (omavast < &MatkOmVastVahimm) THEN omavast = &MatkOmVastVahimm;
END;

&tulos = &tyomatkakulut - omavast;

IF &tulos < 0 THEN &tulos = 0;

IF &tulos > &MatkYlaRaja THEN &tulos = &MatkYlaRaja;

DROP omavast;

%MEND TyoMatkaVahS;


/* 3. Asuntov‰hennys (ns. kakkosasunnon v‰hennys).
      Parametreissa vuodesta 2008 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Asuntov‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kuukausia: Kakkosasunnon k‰yttˆkuukausien lukum‰‰r‰
	vuokra: V‰hennykseen ilmoitettu vuokra;

%MACRO AsuntoVahennysS(tulos, mvuosi, minf, kuukausia, vuokra)/
DES = 'VERO: Asuntov‰hennys (ns. kakkosasunnon verov‰hennys)';

%HAKU;

IF &mvuosi < 2008 THEN &tulos = 0;

ELSE DO; 

	IF &vuokra > &TyoAsVah THEN &tulos = &kuukausia * &TyoAsVah;

	ELSE &tulos = &kuukausia * &vuokra;

END;

%MEND AsuntoVahennysS;


/* 4. Yhdistetty v‰hennys: tulonhannkimisv‰hennys, tyˆmatkav‰hennys ja ay-j‰senmaksut.
	  Kaava ottaa huomioon sen, ett‰ nykyisin n‰m‰ v‰hennykset ovat itsen‰isi‰ kun
	  taas aikaisemmin ne olivat osittain toisiinsa kytkettyj‰ */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonankkimisv‰hennys, tyˆmatkakuluv‰hkennys ja ay-j‰senmaksujen v‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	anstulo: Ansiotulot
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut
	aymaksut: Tyˆmarkkinaj‰rjestˆn v‰hennyskelpoiset j‰senmaksut
	tyomatkakulut: Ilmoitetut tyˆmatkakulut
	tyotkuuk: Tyˆttˆmyyskuukaudet;

%MACRO TulonHankKulutS(tulos, mvuosi, minf, palkkatulo, tulhankkulut, aymaksut, tyomatkakulut, tyotkuuk)/
DES = 'VERO: Tulonankkimisv‰hennys, tyˆmatkakuluv‰hkennys ja ay-j‰senmaksujen v‰hennys yhdistettyn‰';

%TyoMatkaVahS(tyom, &mvuosi, &minf, &tyomatkakulut, &tyotkuuk);

IF &mvuosi < 1989 THEN kulut = &tulhankkulut + tyom;

ELSE IF &mvuosi >= 1989 THEN kulut = &tulhankkulut;

%TulonHankVahS(tulvah, &mvuosi, &minf, &palkkatulo, kulut);

IF &mvuosi < 1989 THEN &tulos = tulvah + &aymaksut;

IF (&mvuosi < 2026 AND &mvuosi >= 1989) THEN &tulos = tyom + tulvah + &aymaksut;

IF &mvuosi >= 2026 THEN &tulos = tyom + tulvah;

DROP tyom kulut tulvah;

%MEND TulonHankKulutS;


/* 5. Palkansaajan tyˆel‰kemaksu */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan tyˆel‰kemaksu
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	ika: Henkilˆn ik‰
	palkkatulo: Palkkatulo;

%MACRO TyoelMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Palkansaajan tyˆel‰kemaksu';

%HAKU;

* Ei maksua ennen vuotta 1993 eik‰ henkilˆlle, jonka ik‰ alittaa alarajan tai ylitt‰‰ yl‰rajan;
IF &mvuosi < 1993 OR &ika < &ElVakAlaIkaRaja OR &ika > &ElVakYlaIkaRaja THEN &tulos = 0;

* Vuodesta 2005 l‰htien korotettu maksu siihen velvoitetuille;
ELSE IF &mvuosi >= 2005 AND &ika >= &KorElVakAlaIkaRaja AND &ika <= &KorElVakYlaIkaRaja THEN &tulos = &KorElVakMaksu * &palkkatulo;

* Muissa tapauksissa lasketaan normaali maksu;
ELSE &tulos = &ElVakMaksu * &palkkatulo;

%MEND TyoelMaksuS;


/* 6. Palkansaajan tyˆttˆmyysvakuutusmaksu */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan tyˆttˆmyysvakuutusmaksu
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	ika: Henkilˆn ik‰
	palkkatulo: Palkkatulo;

%MACRO TyotMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Palkansaajan tyˆttˆmyysvakuutusmaksu';

%HAKU;

* Ei maksua ennen vuotta 1993 eik‰ henkilˆlle, jonka ik‰ alittaa alarajan tai ylitt‰‰ yl‰rajan;
IF &mvuosi < 1993 OR &ika < &TyotVakAlaIkaRaja OR &ika > &TyotVakYlaIkaRaja THEN &tulos = 0;

* Muissa tapauksissa lasketaan normaali maksu;
ELSE &tulos = &TyotVakMaksu * &palkkatulo;

%MEND TyotMaksuS;

/* 7. Sairausvakuutuksen p‰iv‰rahamaksu: vain normaaleista palkka- ja tyˆtulosta.
	  Parametreissa vuodesta 2006 l‰htien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen p‰iv‰rahamaksu 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	ika: Henkilˆn ik‰
	palkkatulo: Palkkatulo tai muu tyˆtulo;

%MACRO SvPRahaMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Sairausvakuutuksen p‰iv‰rahamaksu, perusversio';

%HAKU;

* Ei maksua ennen vuotta 2006 eik‰ henkilˆille, jonka ik‰ alittaa alarajan tai ylitt‰‰ yl‰rajan
eik‰ silloin kun tulot alittavat tulorajan;
IF &mvuosi < 2006 OR &ika < &SvPrAlaIkaRaja OR &ika > &SvPrYlaIkaRaja OR &palkkatulo < &SvPrMaksuRaja THEN &tulos = 0;

ELSE &tulos = &SvPrMaksu * &palkkatulo;

%MEND SvPRahaMaksuS;


/* 8. Sairausvakuutuksen p‰iv‰rahamaksu.
	   Otetaan huomioon yritystulon korotettu maksu. 
	   (Huom! Korotettu maksu kohdistuu vain yritt‰jien el‰kelain mukaiseen tyˆtuloon) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen p‰iv‰rahamaksu
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	ika: Henkilˆn ik‰
	yrit = On yritt‰j‰ (1/0) 
	tyotulo = Tyˆtulo;

%MACRO SvPRahaMaksuYS (tulos, mvuosi, minf, ika, yrit, tyotulo)/
DES = 'VERO: Sairausvakuutuksen p‰iv‰rahamaksu, yritystulon korotettu maksu huomioon otettuna';

%HAKU;

* Ei maksua ennen vuotta 2006 eik‰ henkilˆille, jonka ik‰ alittaa alarajan tai ylitt‰‰ yl‰rajan
eik‰ silloin kun tulot alittavat tulorajan;
IF &mvuosi < 2006 OR &ika < &SvPrAlaIkaRaja OR &ika > &SvPrYlaIkaRaja OR &tyotulo < &SvPrMaksuRaja THEN &tulos = 0;

ELSE &tulos = IFN(&yrit = 0, &SvPrMaksu  * &tyotulo, SUM(&SvPrMaksu, &SairVakYrit)* &tyotulo);

%MEND SvPRahaMaksuYS;


/* 9. Kunnallisverotuksen ansiotulov‰hennys. 
	   Parametreissa vuosille 1991-2022.
	   Kaavassa otetaan huomioon tulok‰sitteiden muutos */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen ansiotulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puhdanstulo: Puhdas ansiotulo
	anstulo2: Muu ansiotulo kuin el‰ketulo
	tyotulo: Tyˆtulo
	palkkatulo: Palkkatulo
	kokontulo: Kokonaistulo;

%MACRO KunnAnsVahS(tulos, mvuosi, minf, puhdanstulo, anstulo2, tyotulo, palkkatulo, kokontulo)/
DES = 'VERO: Kunnallisverotuksen ansiotulov‰hennys';

%HAKU;

/* Kunnallisverotuksen ansiotulov‰hennys voimassa vuoteen 2022 asti */

	vahtulo = &tyotulo;

	IF &mvuosi <= 1996 THEN vahtulo = &anstulo2;

	IF &mvuosi = 1991 THEN vahtulo = &palkkatulo;

	IF vahtulo <  &KunnAnsRaja1 THEN &tulos = 0;

	ELSE IF vahtulo >= &KunnAnsRaja1 THEN &tulos = &KunnAnsPros1 * (vahtulo - &KunnAnsRaja1);

	IF vahtulo >= &KunnAnsRaja2 
	THEN &tulos = &KunnAnsPros1 * (&KunnAnsRaja2 - &KunnAnsRaja1) + &KunnAnsPros2 * (vahtulo -  &KunnAnsRaja2);

	IF &tulos > &KunnAnsEnimm THEN &tulos = &KunnAnsEnimm;

	verttulo = &puhdanstulo;

	IF &mvuosi < 1993 THEN verttulo = &kokontulo;

	IF verttulo > &KunnAnsRaja3 THEN &tulos = &tulos - &KunnAnsPros3 * (verttulo -  &KunnAnsRaja3);

	IF &tulos < 0 THEN &tulos = 0;

	IF &tulos > verttulo THEN &tulos = verttulo;

	DROP vahtulo verttulo;

%MEND KunnAnsVahS;


/* 10. Kunnallisverotuksen el‰ketulov‰hennys.
	   Parametreissa 1983-2022.
	   Kaavassa otetaan huomioon tulok‰sitteiden muutos. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen el‰ketulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	oikeusyksi96: On ollut oikeus yksin‰isen v‰hennykseen, vaikka puoliso vuonna 1996 (1/0)
	elaketulo: El‰ketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO KunnElTulVahS (tulos, mvuosi, minf, puoliso, oikeusyks96, elaketulo, puhdansiotulo, kokontulo)/
DES = 'VERO: Kunnallisverotuksen el‰ketulov‰hennys';

%HAKU;

/* Kunnallisverotuksen el‰ketulov‰hennys voimassa vuoteen 2022 asti */

	IF &mvuosi < 2010 THEN perusvah = &KunnPerEnimm;
	ELSE perusvah = &KunnElVakio;

	IF &puoliso = 0 THEN taysivah = &KunnElKerr * &KelaYks - perusvah;

	IF &puoliso NE 0 THEN taysivah = &KunnElKerr * &KelaPuol - perusvah;

	IF (&puoliso NE 0) AND (&oikeusyks96 NE 0) AND (&mvuosi > 1996) 
	THEN taysivah = &KunnElKerr * &KelaYks - perusvah;

	IF taysivah < 0 THEN taysivah = 0;

	IF &mvuosi < 2002 THEN DO;
		%pyoristys100mk(utaysivah, taysivah);
	END;

	ELSE DO;
		%pyoristys10e(utaysivah, taysivah);
	END;

	/* Erilaiset tulok‰sitteet ennen ja j‰lkeen vuoden 1993 uudistuksen */
	IF &mvuosi >=  1993 THEN tulo = &puhdansiotulo;

	ELSE IF &mvuosi < 1993 THEN tulo = &kokontulo;

	/* V‰hennyst‰ pienennet‰‰n eri tavoin ennen vuotta 1989 ja v:sta 1989 l‰htien */
	IF (&mvuosi < 1989) THEN DO;

		IF tulo > (2 * perusvah + utaysivah) THEN utaysivah = utaysivah - (tulo - 2 * perusvah - utaysivah);

	END;

	ELSE IF (&mvuosi >= 1989) THEN DO;

		IF tulo > utaysivah THEN utaysivah = utaysivah - &KunnElPros * (tulo - utaysivah);

	END;

	IF (utaysivah < 0) OR (&mvuosi < 1983) THEN utaysivah = 0;

	/* V‰hennys ei voi olla el‰ketuloa suurempi */

	vah = utaysivah;

	IF vah > &elaketulo THEN vah = &elaketulo;

	IF &elaketulo > 0 THEN vah = vah + &KunnVanhVah;

	&tulos = vah;

	DROP perusvah tulo taysivah utaysivah vah;

%MEND KunnElTulVahS;


/* 11. Kunnallisverotuksen opintorahav‰hennys.
	   Huom! Jos opisk-muuttuja <> 0, laskee opiskelijav‰hennyksen ennen vuotta 1993 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen opintorahav‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	opisk: On opiskelija (1/0)
	opraha: Opintoraha (veronalainen opintukilain mukainen opintoraha)
	anstulo: Ansiotulo
	puhdanstulo: Puhdas ansiotulo;

%MACRO KunnOpRahVahS (tulos, mvuosi, minf, opisk, opraha, anstulo, puhdanstulo)/
DES = 'VERO: Kunnallisverotuksen opintorahav‰hennys';

%HAKU;

/* Kunnallisverotuksen opintorahav‰hennys voimassa vuoteen 2022 asti */

	IF &mvuosi  < 1993 AND &opisk = 0 THEN &tulos = 0;

	ELSE DO;

		IF &mvuosi  > 1992 AND &opraha = 0 THEN &tulos = 0;

		ELSE DO;

			IF &mvuosi < 1993 AND &opisk NE 0 THEN &tulos = &KunnOpiskVah;

		       IF &mvuosi > 1992 THEN DO;

				&tulos = &OpRahVah;

				tulo = &puhdanstulo;

				IF &mvuosi < 1995 THEN tulo = &anstulo;
				
				IF tulo > &OpRahVah THEN  &tulos =  &OpRahVah - &OpRahPros * (tulo  - &OpRahVah);

				IF &tulos < 0 THEN &tulos = 0;

				IF &tulos > &opraha THEN &tulos = &opraha;
			END;
		END;
	END;

	DROP tulo;


%MEND KunnOpRahVahS;


/* 12. Kunnallisverotuksen invalidiv‰hennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen invalidiv‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	oikeus_1982: Oikeus el‰ketulosta tehtyyn invalidiv‰hennykseen vuonna 1982 (1/0)
	invpros: Invaliditeettiprosentti eli haitta-aste (kokonaislukuna 0-100)
	puhdanstulo: Puhdas ansiotulo
	elaketulo: El‰ketulo;

%MACRO KunnVerInvVahS(tulos, mvuosi, minf, oikeus_1982, invpros, puhdanstulo, elaketulo)/
DES = 'VERO: Kunnallisverotuksen invalidiv‰hennys';

%HAKU;

/* Kunnallisverotuksen invalidiv‰hennys voimassa vuoteen 2022 asti */
	IF &invpros < 30 THEN &TULOS = 0;

	ELSE DO;
		vah = 0.01 * &invpros *  &KunnInvVah;

		*Vuodesta 1983 l‰htien v‰hennys vain muusta ansiotulosta kuin el‰ketulosta.
		 Siirtym‰s‰‰nnˆs otettiin k‰yttˆˆn 1984: v‰hennys myˆs el‰ketulosta, jos oikeus v‰hennykseen vuonna 1982;
		IF &mvuosi > 1982 THEN DO;

			IF vah > &puhdanstulo THEN vah = &puhdanstulo;

			IF &mvuosi = 1983 AND vah > MAX((&puhdanstulo - &elaketulo), 0)
			THEN vah = MAX((&puhdanstulo - &elaketulo), 0);

			IF &mvuosi > 1983 AND &oikeus_1982 = 0 AND vah > MAX((&puhdanstulo - &elaketulo), 0)
			THEN vah = MAX((&puhdanstulo - &elaketulo), 0);

		END;

		&tulos = vah;

	END;

DROP vah;

%MEND KunnVerInvVahS;


/* 13. Kunnallisverotuksen perusv‰hennys */	

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen perusv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	kunnvertuloA: Kunnallisverotuksessa verotettava tulo ennen perusv‰hennyst‰;

%MACRO KunnPerVahS(tulos, mvuosi, minf, kunnvertuloA)/
DES = 'VERO: Kunnallisverotuksen perusv‰hennys';

%HAKU;

/* Kunnallisverotuksen perusv‰hennys voimassa vuoteen 2022 asti */
IF &kunnvertuloA <= &KunnPerEnimm THEN &tulos = &kunnvertuloA;

ELSE &tulos =  &KunnPerEnimm - &KunnPerPros * (&kunnvertuloA - &KunnPerEnimm);

IF &tulos < 0 THEN &tulos = 0;

%MEND KunnPerVahS;


/* 14. Sairausvakuutusmaksu.
	   Makro ottaa huomioon 1990- ja 2000-luvun korotetut maksut sek‰
	   muusta kuin tyˆtulosta peritt‰v‰t korotetut maksut 2006- */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutusmaksu 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: El‰ketulo
	prahamtulo: Sair.vak. p‰iv‰rahamaksun perusteena oleva tulo;

%MACRO SairVakMaksuS(tulos, mvuosi, minf, kunnvertulo, elaketulo, prahamtulo)/
DES = 'VERO: Sairausvakuutusmaksu, lyhennetty kaava';

%HAKU;

&tulos = &SvPros * &kunnvertulo;

*Sairausvakuutusmaksun korotus, parametrien mukaan ollut voimassa 1991-1998;

IF &kunnvertulo >  &KorSvMaksuRaja 
THEN &tulos = (&SvPros + &SvKorotus) * (&kunnvertulo - &KorSvMaksuRaja) + &SvPros * &KorSvMaksuRaja;

*El‰ketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-2002.
 Huom! Samaa parametria &ElKorSvMaksu k‰ytet‰‰n eri tarkoitukseen vuodesta 2006 l‰htien;

elkor = 0;

IF &mvuosi < 2006 THEN DO;

	IF &kunnvertulo > &elaketulo THEN elkor = &ElKorSvMaksu * &elaketulo;
	ELSE elkor = &ElKorSvMaksu * &kunnvertulo;

END;

*Muusta kuin tyˆtulosta peritt‰v‰ korotettu maksu;

IF (&mvuosi > 2005) THEN DO;

	IF &kunnvertulo > &prahamtulo THEN elkor = &ElKorSvMaksu * (&kunnvertulo - &prahamtulo);

END;

&tulos = &tulos + elkor;

DROP elkor;

%MEND SairVakMaksuS;


/* 15. Kansanel‰kevakuutusmaksu.
	   Huom! Poistunut lains‰‰d‰nnnˆst‰ ja parametreista vuonna 1996. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kansanel‰kevakuutusmaksu 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: El‰ketulo;

%MACRO KanselVakMaksuS (tulos, mvuosi, minf, kunnvertulo, elaketulo)/
DES = 'VERO: Kansanel‰kevakuutusmaksu, lyhennetty kaava';

%HAKU;

*El‰ketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-1995;

&tulos = &KevPros * &kunnvertulo;

elkorkev = 0;

IF (&mvuosi < 1996) AND (&kunnvertulo > &elaketulo) THEN  elkorkev = &ElKorKevMaksu * &elaketulo;
ELSE elkorkev = &ElKorKevMaksu * &kunnvertulo;

&tulos = &tulos + elkorkev;

DROP elkorkev;

%MEND KanselVakMaksuS;


/* 16. Kunnallisvero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisvero 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	keskimm: K‰ytet‰‰nkˆ keskim‰‰r‰ist‰ veroprosenttia (1/0)
	kunnpros: Kunnallisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KunnVeroS(tulos, mvuosi, minf, keskimm, kunnpros, kunnvertulo)/
DES = 'VERO: Kunnallisvero: joko keskim‰‰r‰inen tai valittu veroprosentti';

%HAKU;

IF &keskimm = 0 THEN &tulos = 0.01 * &kunnpros * &kunnvertulo;

ELSE &tulos = &KeskKunnPros * 0.01 * &kunnvertulo;

%MEND KunnVeroS;


/* 17. Kirkollisvero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kirkollisvero
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	keskimm: K‰ytet‰‰nkˆ keskim‰‰r‰ist‰ veroprosenttia (1/0)
	kirkpros: Kirkollisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KirkVeroS(tulos, mvuosi, minf, keskimm, kirkpros, kunnvertulo)/
DES = 'VERO: Kirkollisvero: joko keskim‰‰r‰inen tai valittu veroprosentti';

%HAKU;

IF &keskimm = 0 THEN &tulos = 0.01 * &kirkpros * &kunnvertulo;

ELSE &tulos = &KirkVeroPros * 0.01 * &kunnvertulo;

%MEND KirkVeroS;


/* 18. Valtion verotuksen tyˆtulov‰hennys.
	   Makro laskee myˆs palkkav‰hennyksen.
	   Huom! Poistunut v‰hennys, lains‰‰d‰nnˆss‰ vuoteen 1988 asti. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen tyˆtulov‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	ansiotulo: Ansiotulo
	palkkatulo: Palkkatulo;

%MACRO ValtTyoTuloVahS(tulos, mvuosi, minf, ansiotulo, palkkatulo)/
DES = 'VERO: Valtionverotuksen tyˆtulov‰hennys';

%HAKU;

temp = &ValtTyotVahPros * &ansiotulo;

IF temp > &ValtTyotVahYlaRaja THEN temp = &ValtTyotVahYlaRaja;

temp2 = &PalkVahPros * &palkkatulo;

IF temp2 > &PalkVahYlaRaja THEN temp2 = &PalkVahYlaRaja;

&tulos = temp + temp2;

DROP temp temp2;

%MEND ValtTyoTuloVahS;

/* 19. Valtionverotuksen el‰ketulov‰hennys.
	   Lains‰‰d‰nnˆss‰ ja parametreissa 1983-2022 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen el‰ketulov‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	elaketulo: El‰ketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO ValtElTulVahS(tulos, mvuosi, minf, elaketulo, puhdansiotulo, kokontulo)/
DES = 'VERO: Valtionverotuksen el‰ketulov‰hennys';

%HAKU;

/* Valtionverotuksen el‰ketulov‰hennys voimassa vuoteen 2022 asti */

	%ValtTyoTuloVahS(ttvah, &mvuosi, &minf, ( &KelaYks), 0);

	taysivah = &ValtElKerr * ( &KelaYks) - ttvah -  &Raja2;

	IF taysivah < 0 THEN taysivah = 0;

	IF &mvuosi < 2002 THEN DO;
		%pyoristys100mk(utaysivah, taysivah);
	END;

	ELSE DO;
		%pyoristys10e(utaysivah, taysivah);
	END;

	tulo = &puhdansiotulo;

	IF &mvuosi < 1993 THEN tulo = &kokontulo;

	IF tulo > utaysivah THEN utaysivah = utaysivah - &ValtElPros * (tulo - utaysivah);

	IF utaysivah < 0 THEN utaysivah = 0;

	IF utaysivah > &elaketulo THEN utaysivah = &elaketulo;

	&tulos = utaysivah;

	DROP ttvah taysivah utaysivah tulo;


%MEND ValtElTulVahS;


/* 20. Tyˆtulov‰hennys (vuosina 2006-2008 tuloverolaissa nimell‰ valtionverotuksen ansiotulov‰hennys).
	   Huom! Verosta teht‰v‰ v‰hennys. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tyˆtulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tyotulo: Tyˆtulo
	puhdanstulo: Puhdas ansiotulo
	ika: Henkilˆn ik‰
	ykshuolt: Onko yksinhuoltaja (0/1)
	lapsia: Alaik‰isten lasten lukum‰‰r‰;

%MACRO TyotVahS(tulos, mvuosi, minf, tyotulo, puhdanstulo, ika, ykshuolt, lapsia)/
DES = 'VERO: Tyˆtulov‰hennys (ent. valtionverotuksen ansiotulov‰hennys) (v‰hennys verosta)';

%HAKU;

	&tulos = 0;
	enimm = &TyotVahEnimm;

	IF &mvuosi >= 2023 THEN DO;

		IF &ika >= &TyotVahKorIka3  AND &ika < &TyotVahKorIka2	 	THEN enimm = SUM(&TyotVahEnimm, &TyotVahKorEuro3);
		IF &ika >= &TyotVahKorIka2  AND &ika < &TyotVahKorIka1		THEN enimm = SUM(&TyotVahEnimm, &TyotVahKorEuro2);
		IF &ika >= &TyotVahKorIka1									THEN enimm = SUM(&TyotVahEnimm, &TyotVahKorEuro1);

		/* Tyˆtulov‰hennyksen lapsikorotus*/	
		IF &mvuosi >= 2025 THEN DO;
			IF &lapsia NE 0 THEN enimm = SUM(enimm, ((&ykshuolt=1) + 1) * &lapsia * &TyotVahLapKor); 
		END;

		&tulos = MIN(&TyotVahPros1 * &tyotulo, enimm);

		IF &puhdanstulo > &TyotVahAlaRaja AND &puhdanstulo <= &TyotVahYlaRaja 
		THEN &tulos = SUM(&tulos, -SUM(&puhdanstulo, -&TyotVahAlaRaja) * &TyotVahPros2);

		IF &puhdanstulo > &TyotVahYlaRaja 
		THEN &tulos = SUM(&tulos, -SUM(&TyotVahYlaRaja, -&TyotVahAlaRaja) * &TyotVahPros2, -SUM(&puhdanstulo, -&TyotVahYlaRaja) * &TyotVahPros3);

	END;
	ELSE DO;

		IF &tyotulo > &TyotVahAlaRaja 
		THEN &tulos = MIN(SUM(&tyotulo, -&TyotVahAlaRaja) * &TyotVahPros1, &TyotVahEnimm);

		IF &puhdanstulo > &TyotVahYlaRaja 
		THEN &tulos = SUM(&tulos, -SUM(&puhdanstulo, -&TyotVahYlaRaja) * &TyotVahPros2);

	END;

	IF &tulos < 0 THEN &tulos = 0;

	DROP enimm;

%MEND TyotVahS;


/* 21. Valtionverotuksen invalidiv‰hennys.
	   Huom! Verosta teht‰v‰ v‰hennys.
	   Makro laskee myˆs laissa ennen vuotta 1983 olleen vanhuusv‰hennyksen, jos elaketulo > 0 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen invalidiv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	invpros: Invaliditeettiprosentti eli haitta-aste, kokonaislukuna 0 - 100
	elaketulo: El‰ketulo;

%MACRO ValtVerInvVahS(tulos, mvuosi, minf, invpros, elaketulo)/
DES = 'VERO: Valtionverotuksen invalidiv‰hennys (v‰hennys verosta)';

%HAKU;

/* Valtionverotuksen invalidiv‰hennys voimassa vuoteen 2022 asti */

	IF &invpros < 30 THEN &tulos = 0;

	ELSE &tulos = 0.01 * &invpros * &ValtInvVah;

	IF &elaketulo > 0 THEN &tulos = &tulos + &ValtVanhVah;


%MEND ValtVerInvVahS;


/* 22. Valtionverotuksen elatusvelvollisuusv‰hennys.
	   Huom! Verosta teht‰v‰ v‰hennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen elatusvelvollisuusv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	evlapsia: Elatusvelvollisten lasten lukum‰‰r‰
	elmaksut: Elatusmaksut;

%MACRO ValtVerElVelvVahS(tulos, mvuosi, minf, evlapsia, elmaksut)/
DES = 'VERO: Valtionverotuksen elatusvelvollisuusv‰hennys (v‰hennys verosta)';

%HAKU;

IF &evlapsia = 0 OR &elmaksut = 0 THEN &tulos = 0;

ELSE DO;

	&tulos = &ElVelvPros * &elmaksut;

	IF &tulos > &evlapsia * &ValtElVelvVah THEN &tulos = &evlapsia * &ValtElVelvVah;

END;

%MEND ValtVerElVelvVahS;


/* 23. Valtion tulovero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtion tulovero 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tulo: Valtion verotuksessa verotettava tulo eli tulo v‰hennysten j‰lkeen 
	      (vuodesta 1993 l‰htien koskee vain ansiotuloa)
	maakunta: Jos maakunta on Ahvenanmaa ('21') lasketaan valtion tulovero eri asteikolla vuodesta 2023 alkaen;
	

%MACRO ValtTuloVeroS(tulos, mvuosi, minf, tulo, maakunta)/
DES = 'VERO: Valtion tulovero (veroasteikko)';

%HAKU;

IF &tulo <= 0 THEN &tulos = 0;

ELSE DO;
	/* Valtion tulovero (ml. Ahvenanmaa vuoteen 2022 asti) */
	IF &maakunta NE 21 OR &mvuosi <= 2022 THEN DO; 

			IF &tulo >= &Raja12 THEN
				&tulos = SUM(&Pros12 * SUM(&tulo, -&Raja12), &Vakio12);

			ELSE IF &tulo >= &Raja11 THEN
				&tulos = SUM(&Pros11 * SUM(&tulo, -&Raja11), &Vakio11);

			ELSE IF &tulo >= &Raja10 THEN
				&tulos = SUM(&Pros10 * SUM(&tulo, -&Raja10), &Vakio10);

			ELSE IF &tulo >= &Raja9 THEN
				&tulos = SUM(&Pros9 * SUM(&tulo, -&Raja9), &Vakio9);

			ELSE IF &tulo >= &Raja8 THEN
				&tulos = SUM(&Pros8 * SUM(&tulo, -&Raja8), &Vakio8);

			ELSE IF &tulo >= &Raja7 THEN
				&tulos = SUM(&Pros7 * SUM(&tulo, -&Raja7), &Vakio7);

			ELSE IF &tulo >= &Raja6 THEN
				&tulos = SUM(&Pros6 * SUM(&tulo, -&Raja6), &Vakio6);

			ELSE IF &tulo >= &Raja5 THEN
				&tulos = SUM(&Pros5 * SUM(&tulo, -&Raja5), &Vakio5);

			ELSE IF &tulo >= &Raja4 THEN
				&tulos = SUM(&Pros4 * SUM(&tulo, -&Raja4), &Vakio4);

			ELSE IF &tulo >= &Raja3 THEN
				&tulos = SUM(&Pros3 * SUM(&tulo, -&Raja3), &Vakio3);

			ELSE IF &tulo >= &Raja2 THEN
				&tulos = SUM(&Pros2 * SUM(&tulo, -&Raja2), &Vakio2);

			ELSE IF &tulo >= &Raja1 THEN
				&tulos = SUM(&Pros1 * SUM(&tulo, -&Raja1), &Vakio1);
	END;

	/* Ahvenanmaan valtion tulovero (eroaa muista maakunnista vuodesta 2023 alkaen) */
	IF &maakunta = 21 AND &mvuosi >= 2023 THEN DO; 	

		/* Lasketaan Ahvenanmaan tuloverasteikon prosentit (12 askelta) */
		%LOCAL i j;
		%DO i = 1 %TO 12;
			%LET AhvenanmaaPros&i = SUM(&&Pros&i, -&AhvenanmaaProsEro);
		%END;

		/* Lasketaan Ahvenanmaan tuloverasteikon vakioarvot (12 askelta) */
		%LET AhvenanmaaVakio1 = &Vakio1; 
		%DO i = 2 %TO 12;
			%LET j = %EVAL(&i - 1);
			%LET AhvenanmaaVakio&i = SUM(&&AhvenanmaaPros&j * SUM(&&Raja&i, -&&Raja&j), &&AhvenanmaaVakio&j);
		%END;

		IF &tulo >= &Raja12 THEN
			&tulos = SUM(&AhvenanmaaPros12 * SUM(&tulo, -&Raja12), &AhvenanmaaVakio12);

		ELSE IF &tulo >= &Raja11 THEN
			&tulos = SUM(&AhvenanmaaPros11 * SUM(&tulo, -&Raja11), &AhvenanmaaVakio11);

		ELSE IF &tulo >= &Raja10 THEN
			&tulos = SUM(&AhvenanmaaPros10 * SUM(&tulo, -&Raja10), &AhvenanmaaVakio10);

		ELSE IF &tulo >= &Raja9 THEN
			&tulos = SUM(&AhvenanmaaPros9 * SUM(&tulo, -&Raja9), &AhvenanmaaVakio9);

		ELSE IF &tulo >= &Raja8 THEN
			&tulos = SUM(&AhvenanmaaPros8 * SUM(&tulo, -&Raja8), &AhvenanmaaVakio8);

		ELSE IF &tulo >= &Raja7 THEN
			&tulos = SUM(&AhvenanmaaPros7 * SUM(&tulo, -&Raja7), &AhvenanmaaVakio7);

		ELSE IF &tulo >= &Raja6 THEN
			&tulos = SUM(&AhvenanmaaPros6 * SUM(&tulo, -&Raja6), &AhvenanmaaVakio6);

		ELSE IF &tulo >= &Raja5 THEN
			&tulos = SUM(&AhvenanmaaPros5 * SUM(&tulo, -&Raja5), &AhvenanmaaVakio5);

		ELSE IF &tulo >= &Raja4 THEN
			&tulos = SUM(&AhvenanmaaPros4 * SUM(&tulo, -&Raja4), &AhvenanmaaVakio4);

		ELSE IF &tulo >= &Raja3 THEN
			&tulos = SUM(&AhvenanmaaPros3 * SUM(&tulo, -&Raja3), &AhvenanmaaVakio3);

		ELSE IF &tulo >= &Raja2 THEN
			&tulos = SUM(&AhvenanmaaPros2 * SUM(&tulo, -&Raja2), &AhvenanmaaVakio2);

		ELSE IF &tulo >= &Raja1 THEN
			&tulos = SUM(&AhvenanmaaPros1 * SUM(&tulo, -&Raja1), &AhvenanmaaVakio1);

	END;
END;

%MEND ValtTuloVeroS;


/* 24. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat vain palkkatuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tuloverot
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	palkkatulo: Palkkatulo;

%MACRO TuloVerot_SimpleS(tulos, mvuosi, minf, palkkatulo, ika)/
DES = 'VERO: Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa';
 
%TulonHankKulutS(tulhanksums2, &mvuosi, &minf, &palkkatulo, 0, 0, 0, 0);

puhdanstulos2 = &palkkatulo - tulhanksums2;

IF puhdanstulos2 < 0 THEN puhdanstulos2 = 0;

%TyoElMaksuS (elmaksus2, &mvuosi, &minf, 30, &palkkatulo);

%TyotMaksuS(tyotvaks2, &mvuosi, &minf, 30, &palkkatulo);

%SvPrahaMaksuS(spmaksus2, &mvuosi, &minf, 30, &palkkatulo);

IF &mvuosi >=2023 THEN DO;
	/* 2023-2024 */
	%AnsVahS(anss2, &mvuosi, &minf, puhdanstulos2, &palkkatulo);
	vtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - anss2;
	IF vtuloAs2 < 0 THEN vtuloAs2 = 0;
END;
ELSE DO;
	/* -2022 */
	%KunnAnsVahS(kunnanss2, &mvuosi, &minf, puhdanstulos2, &palkkatulo, &palkkatulo, &palkkatulo, &palkkatulo);
	kunnvtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - kunnanss2;
	IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;
END;

IF &mvuosi >=2023 THEN DO;
	/* Perusv‰hennys 2023- */
	%PerVahS (pervahs2, &mvuosi, &minf, vtuloAs2);
	vertulos2 = vtuloAs2 - pervahs2;
END;
ELSE DO;
	/* Perusv‰hennys -2022 */
	%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);
	kunnvertulos2 = kunnvtuloAs2 - pervahs2;
END;

IF &mvuosi >=2023 THEN DO;
	/* 2023- */
	%SairVakMaksuS(svmaksus2, &mvuosi, &minf, vertulos2, 0, &palkkatulo);
	%KansElVakMaksuS(kevmaksus2, &mvuosi, &minf, vertulos2, 0);
	%KunnVeroS(kunnveros2, &mvuosi, &minf, 1, 18, vertulos2);
	IF vertulos2 < 0 THEN vertulos2 = 0;
	%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, vertulos2, 0);
END;
ELSE DO;
	/* -2022 */
	%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, &palkkatulo);
	%KansElVakMaksuS(kevmaksus2, &mvuosi, &minf, kunnvertulos2, 0);
	%KunnVeroS(kunnveros2, &mvuosi, &minf, 1, 18, kunnvertulos2);
	%ValtTyoTuloVahS(valttvahs2, &mvuosi, &minf, &palkkatulo, &palkkatulo);
	valtvertulos2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - valttvahs2;
	IF valtvertulos2 < 0 THEN valtvertulos2 = 0;
	%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2, 0);
END;

%TyotVahS(valtansvahss2, &mvuosi, &minf,  &palkkatulo, puhdanstulos2, &ika, 0, 0);

%YleVeroS(ylevero2, &mvuosi, &minf, 18, puhdanstulos2, 0); 

&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + ylevero2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

DROP 	tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 anss2 vtuloAs2 pervahs2
		vertulos2 svmaksus2 kevmaksus2 kunnveros2 valttuloveros2 valtansvahss2 
		ylevero2 kunnanss2 kunnvtuloAs2 kunnvertulos2 valttvahs2 valtvertulos2;

%MEND TuloVerot_SimpleS;


%MACRO TuloVerot_Simple_Palkka_OsinkoS(tulos, mvuosi, minf, palkkatulo, osinkotulo)/
DES = 'VERO: Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa';

%TulonHankKulutS(tulhanksums2, &mvuosi, &minf, &palkkatulo, 0, 0, 0, 0);

puhdanstulos2 = SUM(&palkkatulo, &osinkotulo) - tulhanksums2;

IF puhdanstulos2 < 0 THEN puhdanstulos2 = 0;

%TyoElMaksuS (elmaksus2, &mvuosi, &minf, 30, &palkkatulo);

%TyotMaksuS(tyotvaks2, &mvuosi, &minf, 30, &palkkatulo);

%SvPrahaMaksuS(spmaksus2, &mvuosi, &minf, 30, &palkkatulo);

%KunnAnsVahS(kunnanss2, &mvuosi, &minf, puhdanstulos2, SUM(&palkkatulo, &osinkotulo), SUM(&palkkatulo, &osinkotulo), &palkkatulo, SUM(&palkkatulo, &osinkotulo));

kunnvtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - kunnanss2;

IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;

%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);

kunnvertulos2 = kunnvtuloAs2 - pervahs2;

%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, &palkkatulo);

%KansElVakMaksuS(kevmaksus2, &mvuosi, &minf, kunnvertulos2, 0);

%KunnVeroS(kunnveros2, &mvuosi, &minf, 1, 18, kunnvertulos2);

%ValtTyoTuloVahS(valttvahs2, &mvuosi, &minf, &palkkatulo, &palkkatulo);

valtvertulos2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - valttvahs2;

IF valtvertulos2 < 0 THEN valtvertulos2 = 0;

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2, 0);

%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  SUM(&palkkatulo, &osinkotulo), puhdanstulos2);

valttuloveros2 = valttuloveros2 - valtansvahss2;

%YleVeroS(ylevero2, &mvuosi, &minf, 18, puhdanstulos2, 0);

&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + ylevero2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);


DROP tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 kunnanss2 kunnvtuloAs2 pervahs2
	 kunnvertulos2 svmaksus2 kevmaksus2 kunnveros2 valttvahs2 valtvertulos2 valttuloveros2 valtansvahss2
	 ylevero2;

%MEND TuloVerot_Simple_Palkka_OsinkoS;


%MACRO TuloVerot_Simple_OsinkoS(tulos, mvuosi, minf, osinkotulo)/
DES = 'VERO: Tuloverot ansiotulo-osingosta, jos se on ainoa tulolaji';

%KunnAnsVahS(kunnanss2, &mvuosi, &minf, &osinkotulo, &osinkotulo, &osinkotulo, &osinkotulo, &osinkotulo);

kunnvtuloAs2 = &osinkotulo - kunnanss2;

IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;

%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);

kunnvertulos2 = kunnvtuloAs2 - pervahs2;

%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, 0);

%KansElVakMaksuS(kevmaksus2, &mvuosi, &minf, kunnvertulos2, 0);

%KunnVeroS(kunnveros2, &mvuosi, &minf, 1, 18, kunnvertulos2);

valtvertulo = &osinkotulo;

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulo, 0);

%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  &osinkotulo, &osinkotulo);

valttuloveros2 = valttuloveros2 - valtansvahss2;

%YleVeroS(ylevero2, &mvuosi, &minf, 18, valttuloveros2, 0); 

&tulos = MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2 + ylevero2, 0);

DROP kunnanss2 kunnvtuloAs2 pervahs2 kunnvertulos2 svmaksus2 kevmaksus2 
	 kunnveros2 valttuloveros2 valtansvahss2 ylevero2; 

%MEND TuloVerot_Simple_OsinkoS;


/* 25. Marginaaliveroaste yksinkertaisessa perustapauksessa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Marginaaliveroaste 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	palkkatulo: Palkkatulo
	askel: Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa;

%MACRO TuloVerot_SimpleMargS(tulos, mvuosi, minf, palkkatulo, askel, ika)/
DES = 'VERO: Marginaaliveroaste palkkaverotuksen yksinkertaisessa perustapauksessa';

%TuloVerot_SimpleS(temp1, &mvuosi, &minf, &palkkatulo, &ika);

%TuloVerot_SimpleS(temp2, &mvuosi, &minf, (&palkkatulo + &askel), &ika);

&tulos = (temp2-temp1) / &askel;

DROP temp1 temp2;

%MEND TuloVerot_SimpleMargS;


/* 26. Bruttokuukausitulo johdettuna nettokuukausitulosta,
	   kun tulo on palkkatuloa ja erityisi‰ v‰hennyksi‰ ei ole */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Bruttotulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	nettokuuktulo: Nettopalkka, e/kk;

%MACRO BruttotuloS(tulos, mvuosi, minf, nettokuuktulo, ika)/
DES = 'VERO: Nettokuukausitulosta johdettu bruttotulo palkansaajalla';

IF &nettokuuktulo > 100000 THEN &tulos = -1;

ELSE DO;

	DO i = 1 TO 20 UNTIL (i*10000 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*i*10000, &ika);

	END;

	DO j = -9 TO 10 UNTIL (i*10000 + j*1000 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000), &ika);

	END;

	DO k = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100), &ika);

	END;
	DO l = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10), &ika);

	END;

	DO m = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 + m -testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10 + m), &ika);

	END;

	DO n = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 + m + n/10 -testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10 + m + n/10), &ika);

	END;

	&tulos = i*10000 + j*1000 + k* 100 + l*10 + m + n/10;

END;

DROP i j k l m n testi;

%MEND BruttotuloS;


/* 27. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat pelk‰st‰‰n el‰ketuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, El‰ketulon verot 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	elaketulo: El‰ketulo;

%MACRO TuloVerot_Simple_ElakeS(tulos, mvuosi, minf, puoliso, elaketulo)/ 
DES = 'VERO: El‰ketulon verot yksinkertaisessa perustapauksessa';


	%ElTulVahS (elvahse, &mvuosi, &minf, 0, &elaketulo); /* 2023- */
	%KunnElTulVahS (elvahk, &mvuosi, &minf, &puoliso, 0, &elaketulo, &elaketulo, &elaketulo); /* -2022 */

IF &mvuosi >= 2023 THEN DO;
	/* 2023- */
	%PerVahS (pervahse, &mvuosi, &minf, MAX(&elaketulo - elvahk, 0));
	vertuloe = &elaketulo - elvahse - pervahse;
	IF vertuloe < 0 THEN vertuloe = 0;
	%SairVakMaksuS(svmaksuse, &mvuosi, &minf, vertuloe, &elaketulo, 0);
	%KansElVakMaksuS(kevmaksuse, &mvuosi, &minf, vertuloe, &elaketulo);
	%KunnVeroS(kunnverose, &mvuosi, &minf, 1, 18, vertuloe);
	%ValtTuloVeroS(valttuloverose, &mvuosi, &minf, vertuloe, 0);
	%ElakeLisaVeroS(elakelvero, &mvuosi, &minf, &elaketulo, elvahse);
END;
ELSE DO;
	/* -2022 */
	%KunnPerVahS (pervahse, &mvuosi, &minf, MAX(&elaketulo - elvahk, 0));
	kunnvertuloe = &elaketulo - elvahk - pervahse;
	IF kunnvertuloe < 0 THEN kunnvertuloe = 0;

	%SairVakMaksuS(svmaksuse, &mvuosi, &minf, kunnvertuloe, &elaketulo, 0);
	%KansElVakMaksuS(kevmaksuse, &mvuosi, &minf, kunnvertuloe, &elaketulo);
	%KunnVeroS(kunnverose, &mvuosi, &minf, 1, 18, kunnvertuloe);

	%ValtTyoTuloVahS(valttvahse, &mvuosi, &minf, &elaketulo, 0);
	%ValtElTulVahS(valtelvahse, &mvuosi, &minf, &elaketulo, &elaketulo, &elaketulo);
	valtvertuloE = &elaketulo - valttvahse - valtelvahse;
	IF valtvertuloE < 0 THEN valtvertuloE = 0;
	%ValtTuloVeroS(valttuloverose, &mvuosi, &minf, valtvertuloE, 0);
	%ElakeLisaVeroS(elakelvero, &mvuosi, &minf, &elaketulo, valtelvahse);
END;

	%YleVeroS(yleveroe, &mvuosi, &minf, 18, &elaketulo, 0);

	&tulos = svmaksuse + kevmaksuse + kunnverose + valttuloverose + elakelvero + yleveroe;

DROP 	elvahse pervahse vertuloe svmaksuse kevmaksuse kunnverose valttuloverose elakelvero yleveroe
		elvahk kunnvertuloe valttvahse valtelvahse valtvertuloE;

%MEND TuloVerot_Simple_ElakeS;


/* 28. Tuloverot yksinkertaisessa perustapauksessa, kun tulot
	   ovat pelk‰st‰‰n tyˆttˆmyysturvaa tai muuta vastaavaa sosiaalietuutta (ei tyˆtuloa eik‰ el‰kett‰) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, P‰iv‰rahatulon tai muun ansiotulon verot 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	prahatulo: P‰iv‰rahatulo, esim. tyˆttˆmyysturva;

%MACRO TuloVerot_Simple_PRahaS(tulos, mvuosi, minf, prahatulo)/
DES = 'VERO: P‰iv‰rahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa';

/* 2023-2024 */
	%AnsVahS(anss, &mvuosi, &minf, &prahatulo, &prahatulo);
/* -2022 */
	%KunnAnsVahS(kunnanss, &mvuosi, &minf, &prahatulo, &prahatulo, 0, 0, &prahatulo);

IF &mvuosi>=2023 THEN DO;
	/* 2023- */
	%PerVahS (pervahsp, &mvuosi, &minf, MAX(&prahatulo - anss,0));
	vertulop = &prahatulo - anss - pervahsp;
	IF vertulop < 0 THEN vertulop = 0;

	%SairVakMaksuS(svmaksusp, &mvuosi, &minf, vertulop, 0, 0);
	%KansElVakMaksuS(kevmaksusp, &mvuosi, &minf, vertulop, 0);
	%KunnVeroS(kunnverosp, &mvuosi, &minf, 1, 18, vertulop);
	%ValtTuloVeroS(valttuloverosp, &mvuosi, &minf, vertulop, 0);
END;
ELSE DO;
	/* -2022 */
	%KunnPerVahS (pervahsp, &mvuosi, &minf, MAX(&prahatulo - kunnanss,0));
	kunnvertulop = &prahatulo - kunnanss - pervahsp;
	IF kunnvertulop < 0 THEN kunnvertulop = 0;

	%SairVakMaksuS(svmaksusp, &mvuosi, &minf, kunnvertulop, 0, 0);
	%KansElVakMaksuS(kevmaksusp, &mvuosi, &minf, kunnvertulop, 0);
	%KunnVeroS(kunnverosp, &mvuosi, &minf, 1, 18, kunnvertulop);
	%ValtTyoTuloVahS(valttvahsp, &mvuosi, &minf, &prahatulo, 0);

	valtvertulop = &prahatulo - valttvahsp;
	IF valtvertulop < 0 THEN valtvertulop = 0;
	%ValtTuloVeroS(valttuloverosp, &mvuosi, &minf, valtvertulop, 0);
END;

	%YleVeroS(yleverosp, &mvuosi, &minf, 18, &prahatulo, 0);

	&tulos = svmaksusp + kevmaksusp + kunnverosp + valttuloverosp + yleverosp;


DROP anss pervahsp vertulop svmaksusp kevmaksusp kunnverosp  
	 valttuloverosp yleverosp kunnanss kunnvertulop valtvertulop valttvahsp; 

%MEND TuloVerot_Simple_PRahaS;


/* 29. P‰‰omatulo-osuus: jaettavan yritystulon tai muun kuin pˆrssiyhtiˆn osingon tai 
	   siihen liittyv‰n yhtiˆveron hyvityksen p‰‰omatulo-osuus. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, P‰‰omatulo-osuus 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	tulolaji: 1 = Jaettava yritystulos, 2 = osinkotulo, 3 = yhtiˆveron hyvitys
	vaiht: 1/0, jos <> 0 jos on valittu vaihtoehtoinen alhaisempi p‰‰omatulo-osuus
	tulo: Tulo, jota jaetaan eri osiin
	yritvarall: Yrityksen nettovarallisuus tai osakkeiden arvo osinkoja jaettaessa
	palkat: Palkkasumma;

%MACRO PomaOsuusS(tulos, mvuosi, minf, tulolaji, vaiht, tulo, yritvarall, palkat) /
DES = 'VERO: Jaettavan yritystulon tai muun kuin pˆrssiyhtiˆn osingon tai 
siihen liittyv‰n yhtiˆveron hyvityksen p‰‰omatulo-osuus';

%HAKU;

tempx = 0;

IF &tulo = 0 THEN &tulos = 0;

ELSE DO;

	SELECT (&tulolaji);

	*JAETTAVA YRITYSTULO;

	WHEN (1) DO; 

		tmposuus = &POOsuus;

		/* Voidaan valita vaihtoehtoisesti alempi p‰‰omatulon osuus (2001 -) */
			
		IF (&vaiht NE 0) THEN tmposuus = &VaihtPOOsuus;
					
		/* Yritysvarallisuuteen lis‰t‰‰n osuus palkoista (1997 -) */

		varall = &yritvarall + tmposuus * &palkat;

		*Mahdollinen p‰‰omatulon osuus tulosta;

		tempx = tmposuus * varall;

		*P‰‰omatulo ei voi olla koko tuloa suurempi;

		IF tempx > &tulo THEN tempx = &tulo;

		END;	
	
	*OSINKOTULO EI-JULKISESTI NOTEERATUISTA YHTI÷ISTƒ;

	WHEN (2) DO; 

		*Kriteerin‰ on osingon ja yhtiˆveron hyvityksen suhde yritysvarallisuuden
		 m‰‰riteltyyn osuuteen;
			
		%YhtHyvS(hyvit, &mvuosi, &minf, &tulo);

		summa = &tulo + hyvit;

		tempx = &OsPOOsuus * &yritvarall;

		IF tempx >= summa THEN temp = &tulo;

		ELSE tempx = tempx * &tulo / summa;
			
	END;

	*YHTI÷VERON HYVITYS;

	WHEN (3) DO; 

	%YhtHyvS(hyvit, &mvuosi, &minf, &tulo);

		summa = &tulo + hyvit;

		tempx = &OsPOOsuus * &yritvarall;
			
	 	IF tempx >= summa THEN temp = hyvit;
		
		ELSE  tempx = tempx * hyvit / summa;

	END;

END;

&tulos = tempx;

END;

DROP tempx summa tmposuus varall;

%MEND PomaOsuusS;


/* 30. Osinkojen jako eri tulolajeihin uudessa j‰rjestelm‰ss‰ 2005- */ 

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulolajiin kuuluvan osingon m‰‰r‰ 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	ospkorko: Onko tulo osuusp‰‰‰oman korkoa (1/0). 2015 j‰lkeen listatun tai listaamattoman osuuskunnan ylij‰‰m‰
	tulolaji: 1 = verovapaa, 2 = p‰‰omatulo, 3 = ansiotulo
	julkosinko: Julkisesti noteeratusta yhtiˆst‰ saatu osinko
	eijulkosinko: Ei julkisesti noteeratusta yhtiˆst‰ saatu osinko tai ei julkisesti noteeratusta osuuskunnasta saatu ylij‰‰m‰
	osakkarvo: Osakkeiden arvo
;

%MACRO OsinkojenJakoS (tulos, mvuosi, minf, ospkorko, tulolaji, julkosinko, eijulkosinko, osakkarvo)/
DES = 'VERO: Osinkotulojen jakaminen p‰‰omatuloksi, ansiotuloiksi ja verottomiksi tuloksi';

%HAKU;

temp = 0;


*Jos ei osinkoja, annetaan heti tulokseksi 0;
IF SUM(&julkosinko, &eijulkosinko) = 0 THEN &tulos = 0;

ELSE DO;

	*L‰htˆkohtana ei-julk. noteeratuissa yhtiˆiss‰ tietty suhde osakkeiden arvoon.
 	 Se m‰‰rittelee, miten osingot jaetaan p‰‰oma- ja ansiotuloiksi;
	
	vert = &HenkYhtOsVapOsuus * &osakkarvo;
	
	*Jos osakkeiden arvoa ei tiedet‰, voidaan muuttujalle osakkaarvo antaa
  	 negatiivinen arvo, jolloin oletetaan, ett‰ ei-julkisesti noteeratun
 	 yhtiˆn osinko on kokonaisuudessaan p‰‰omatuloa (joka kuitenkin viel‰ jaetaan
	 verottomaksi ja veronalaiseksi tuloksi);

	IF &EiJulkOsinko > 0 AND &OsakkArvo < 0 THEN vert =&EiJulkOsinko;

	SELECT (&tulolaji);

	*VEROVAPAAT OSINGOT;

	WHEN (1) DO;

		*Ennen vuotta 2005 verovapaita osinkoja ei ole;
		IF  (&mvuosi  < 2005) THEN temp = 0; 

		ELSE DO;
			*Ensin k‰sitell‰‰n noteeraamattomista osakkeista maksettavat osingot;
			*Suhde kiinte‰‰n eurom‰‰r‰iseen rajaan ja tuottorajaan;
			IF vert > &HenkYhtVapRaja THEN DO;

				IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN
					temp = (1 - &HenkYhtPOOsuus1) * &eijulkosinko;

				IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN
					temp = (1 - &HenkYhtPOOsuus1) * &HenkYhtVapRaja + (1 - &HenkYhtPOOsuus2) * (&eijulkosinko - &HenkYhtVapRaja);

				IF &eijulkosinko > vert THEN
					temp = (1 - &HenkYhtPOOsuus1) * &HenkYhtVapRaja + (1 - &HenkYhtPOOsuus2) * (vert - &HenkYhtVapRaja) + ( 1 - &HenkYhtOsAnsOsuus) * (&eijulkosinko - vert) ;
			END;

			ELSE IF vert <= &HenkYhtVapRaja THEN temp = ( 1 - &HenkYhtPOOsuus1) * MIN(&eijulkosinko, vert) + (1 - &HenkYhtOsAnsOsuus) * MAX (&eijulkosinko - vert, 0);
				
			*Pˆrssiyhtiˆiden osinkojen verovapaa osuus lis‰t‰‰n;

			IF &ospkorko = 0 THEN temp =  SUM(temp, (1 - &JulkPOOsuus) * &julkosinko);

			*Osuusp‰‰oman korkojen verovapaa osuus lis‰t‰‰n;
			IF &ospkorko = 1 AND &mvuosi >= 2015 THEN DO;
				IF &eijulkosinko > 0 THEN temp = SUM((1 - &EiJulkOSPOOsuus2) * MAX(&eijulkosinko - &EiJulkOSPORaja, 0), (1 - &EiJulkOSPOOsuus1) * MIN(&eijulkosinko, &EiJulkOSPORaja));
				IF &julkosinko > 0 THEN temp = SUM((1 - &JulkOsPOOsuus) * &julkosinko, 0);
			END;
			ELSE IF &ospkorko = 1 THEN temp = SUM((1 - &OspKorkoPOOsuus) * MAX(&eijulkosinko - &OspKorVeroVap, 0), MIN(&eijulkosinko, &OspKorVerovap)) ;
		
		END;
	END;

	*PƒƒOMATULOT;

	WHEN (2) DO;

		*Lasketaan ei-julkosinkgon p‰‰omatuloiksi laskettava osuus makron PomaOsuusS avulla;
		%PomaOsuusS(paaomaosuus, &mvuosi, &minf, 2, 0, &eijulkosinko, &osakkarvo, 0);

		*Ennen vuotta 2005 edell‰ laskettu osuus on p‰‰omatuloa ja se lis‰t‰‰n julkisesti
		 noteerattujen yhtiˆiden osinkoihin;
		IF &mvuosi < 2005 THEN &tulos = &JulkOsinko + paaomaosuus;

		ELSE DO;

			*Ensin k‰sitell‰‰n noteeraamattomien osakkeiden osingot samassa j‰rjestyksess‰ kuin edell‰;

			IF vert > &HenkYhtVapRaja THEN DO;

				IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN
					temp = &HenkYhtPOOsuus1 * &eijulkosinko;

				IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN
					temp = &HenkYhtPOOsuus1 * &HenkYhtVapRaja + &HenkYhtPOOsuus2 * (&eijulkosinko - &HenkYhtVapRaja);

				IF &eijulkosinko > vert THEN
					temp = &HenkYhtPOOsuus1 * &HenkYhtVapRaja + &HenkYhtPOOsuus2 * (vert - &HenkYhtVapRaja) ;
			END;

			ELSE IF vert <= &HenkYhtVapRaja THEN temp = &HenkYhtPOOsuus1 * MIN(&eijulkosinko, vert);

			*Lis‰t‰‰n pˆrssiyhtiˆiden osinkojen verollinen osuus;

			IF &ospkorko = 0 THEN temp = SUM(temp, &JulkPOOsuus * &julkosinko);

			*Osuusp‰‰oman korot;

			IF &ospkorko = 1 AND &mvuosi >= 2015 THEN DO;
				IF &eijulkosinko > 0 THEN temp = SUM(&EiJulkOSPOOsuus2 * MAX(&eijulkosinko - &EiJulkOSPORaja, 0), &EiJulkOSPOOsuus1 * MIN(&eijulkosinko, &EiJulkOSPORaja));
				IF &julkosinko > 0 THEN temp = SUM(&JulkOsPOOsuus * &julkosinko, 0);
			END;
			ELSE IF &ospkorko = 1 THEN temp = SUM(&OspKorkoPOOsuus * MAX(&eijulkosinko - &OspKorVeroVap, 0));
				

		 END;

	END;

	*ANSIOTULOT;
	
	WHEN (3) DO;

		*Ennen vuotta 2005 katsotaan ei-julk. noteerattujen osakkeiden osinkojen p‰‰omatulo-osuus
		 ja v‰hennet‰‰n se koko osingosta;
		IF &mvuosi < 2005 THEN DO;
			%PomaOsuusS(paaomaosuus, &mvuosi, &minf, 2, 0, &eijulkosinko, &osakkarvo, 0);
			temp = &eijulkosinko - paaomaosuus;
		END;

		*Muuten katsotaan kiinte‰n tuottorajan ylitt‰v‰st‰ osuudesta ansiotulojen osuus;
		IF &mvuosi > 2004 AND &eijulkosinko > vert THEN temp = &HenkYhtOsAnsOsuus * (&eijulkosinko - vert);

		ELSE temp = 0;
	END;

	OTHERWISE temp = 0;

	END;
END;

&tulos = temp;

DROP temp vert paaomaosuus;
%MEND OsinkojenJakoS;

/* 31. Alij‰‰m‰hyvitys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Alij‰‰m‰hyvitys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puoliso (1/0)
	lapsia: Alaik‰isten lasten lukum‰‰r‰
	potulo: Veronalainen p‰‰omatulo
	povahenn: P‰‰omatulon hankkimiseen liittyv‰t v‰hennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	kulkorot: Kulutusluoton korot (vaikutusta vain 1994 ja 1995)
	puolalij: Puolisolta siirtyv‰ alij‰‰m‰hyvitys;

%MACRO AlijHyvS(tulos, mvuosi, minf, puoliso, lapsia, potulo, povahenn, askorot, ensaskorot, kulkorot, puolalij)/
DES = 'VERO: Alij‰‰m‰hyvitys';

%HAKU;

vahlapsia = MIN (&lapsia, 2);

alijenimm = (&AlijYlaRaja + vahlapsia * &AlijLapsiKor);

IF (&puoliso NE 0) THEN alijenimm = alijenimm + &puolalij;

/* Kulutusluottojen korot eiv‰t vaikuta alij‰‰m‰hyvitykseen vuoden 1994 j‰lkeen */

kulkorotx = &KulKorot;

IF &mvuosi > 1994 THEN kulkorotx = 0;

temp = 0;

*Ei p‰‰omatuloja;
IF &potulo = 0 THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros * (&povahenn + &AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos p‰‰omatuloja mutta v‰hennykset ovat v‰hint‰‰n yht‰ suuret;
IF &potulo > 0 AND &potulo <= &povahenn THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros * (&povahenn - &potulo + &AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos p‰‰omatulot suuremmat kuin v‰hennykset mutta pienemm‰t tai yht‰ suuret jos kulutuskorot huomioidaan;
IF (&potulo > &povahenn) AND (&potulo <= &povahenn + kulkorotx) THEN DO;

	 temp = &PaaomaVeroPros * (&povahenn + kulkorotx - &potulo);

	 IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	 temp = temp + &PaaomaVeroPros * (&AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos p‰‰omatulot suuremmat kuin yhteenlasketut v‰hennykset ja kulutusluoton korot mutta pienemm‰t tai yht‰ suuret jos huomioidaan asuntolainan korkojen v‰hennett‰v‰ osuus;
IF (&potulo > &povahenn + kulkorotx) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) THEN DO;

	temp = &PaaomaVeroPros *  (&povahenn + kulkorotx - &potulo +  &AsKorkoOsuus * &askorot);

	temp = temp + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos p‰‰omatulot suuremmat kuin yhteenlasketut v‰hennykset, kulutusluoton korot ja asuntolainan korkojen v‰hennett‰v‰ osuus mutta pienemm‰t tai yht‰ suuret jos huomioidaan ensiasunnon lainan korot; 
IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * (&askorot + &ensaskorot)) THEN DO;

	temp =  &EnsAsKor * (&AsKorkoOsuus * (&povahenn + kulkorotx + &askorot + &ensaskorot - &potulo));

END;

IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot +  &AsKorkoOsuus * &ensaskorot) THEN temp = 0;

IF temp > alijenimm THEN temp = alijenimm;

&tulos = temp;

DROP temp;

%MEND AlijHyvS;

/* 32. Alij‰‰m‰hyvitys kotitaloustasolla
	   Makrossa lasketaan kotitalouden alij‰‰m‰hyvitys yhteens‰. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Alij‰‰m‰hyvitys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puoliso (1/0)
	lapsia: Alaik‰isten lasten lukum‰‰r‰
	potulo: Veronalainen p‰‰omatulo
	povahenn: P‰‰omatulon hankkimiseen liittyv‰t v‰hennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	kulkorot: Kulutusluoton korot (vaikutusta vain 1994 ja 1995);

%MACRO AlijHyvKotitS(tulos, mvuosi, minf, puoliso, lapsia, potulo, povahenn, askorot, ensaskorot, kulkorot)/
DES = 'VERO: Alij‰‰m‰hyvitys kotitaloustasolla';

%HAKU;

/* Oletetaan ett‰ puolisolta siirtyy maksimim‰‰r‰ ja lasketaan sitten henkilˆtasolla */

IF (&puoliso NE 0) THEN puolisolisa = &AlijYlaRaja;
ELSE puolisolisa = 0;

%AlijHyvS(temp, &mvuosi, &minf, &puoliso, &lapsia, &potulo, &povahenn, &askorot, &ensaskorot, &kulkorot, puolisolisa);

&tulos = temp;

DROP temp puolisolisa;

%MEND AlijHyvKotitS;


/* 33. Erityinen alij‰‰m‰hyvitys.
	   Lains‰‰d‰nnˆss‰ vuodesta 2005 l‰htien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Erityinen alij‰‰m‰hyvitys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	potulo: P‰‰omatulot
	povahenn: P‰‰omatulon hankkimiseen liittyv‰t v‰hennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	elvakuutusmaksu: P‰‰omatulosta v‰hennett‰v‰t v‰hennyskelpoiset vapaaehtoiset el‰kevakuutusmaksut;

%MACRO AlijHyvEritS (tulos, mvuosi, minf, potulo, povahenn, askorot, ensaskorot, elvakuutusmaksu)/
DES = 'VERO: Erityinen alij‰‰m‰hyvitys';

IF &mvuosi < 2005 THEN &tulos = 0;
ELSE DO;

	%HAKU;

	vahmaksu = &elvakuutusmaksu;

	IF vahmaksu > &VapEhtRaja1 THEN vahmaksu = &VapEhtRaja1;

	IF &potulo = 0 Or &potulo <= &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot)  THEN &tulos = &PaaomaVeroPros * vahmaksu;

	IF &potulo > &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot)  AND &potulo <= &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu
	THEN &tulos = &PaaomaVeroPros * (&povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu - &potulo);

	IF &potulo > &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu THEN &tulos = 0;

END;

DROP vahmaksu;

%MEND AlijHyvEritS;


/* 34. Yhtiˆveron hyvitys.
	   Lains‰‰d‰nnˆss‰ vuoteen 2004 asti. 
	   Huom! Makrossa oletetaan, ett‰ osingot ovat lains‰‰d‰ntˆvuotta edelt‰v‰lt‰ tilivuodelta */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yhtiˆveron hyvitys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	osinkotulo: Hyvitykseen oikeuttava osinkotulo;

%MACRO YhtHyvS(tulos, mvuosi, minf, osinkotulo)/
DES = 'VERO: Yhtiˆveron hyvitys';

%HAKU;

IF &mvuosi > 2004 THEN &tulos = 0;

ELSE DO;
	&tulos = &YhtHyvPros * &osinkotulo;
	IF &mvuosi = 1993 THEN &tulos = &PaaomaVeroPros * &osinkotulo / (1 - &PaaomaVeroPros);
END;

%MEND YhtHyvS;

/* 35. V‰hennyskelpoinen osuus asuntolainan koroista;

*Makron parametrit:
    tulos: Makron tulosmuuttuja, P‰‰omatulon vero
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	asuntokorot: Asuntolainan korot

T‰ll‰ makrolla otetaan huomioon korko-oikeuden rajaus vuodesta 2012 l‰htien
*/


%MACRO VahAsKorotS (tulos, mvuosi, minf, asuntokorot)/
DES = 'VERO: V‰hennyskelpoiset asuntolainan korot p‰‰omatulon verotuksessa';

%HAKU;

&tulos = &AsKorkoOsuus * &asuntokorot;

%MEND VahAsKorotS;


/* 36. P‰‰omatulon vero: makro joka ottaa huomioon vapaaehtoiset el‰kevakuutusmaksut. 
	   Huom! Makro lis‰‰ tuloihin yhtiˆveron hyvityksen. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, P‰‰omatulon vero
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	osinkotulo: Osinkotulo
	muupotulo: Muu p‰‰omastulo
	povahenn: P‰‰omatulosta teht‰v‰t v‰hennykset (muut kuin kulutusluoton korot)
	kulkorot: Kulutusluoton korot (vaikutusta 1994 ja 1995)
	elvakuutusmaksu: P‰‰omatulosta v‰hennett‰v‰t vapaaehtoiset el‰kevakuutusmaksut;

%MACRO POTulonVeroEritS (tulos, mvuosi, minf, osinkotulo, muupotulo, povahenn, kulkorot, elvakuutusmaksu)/
DES = 'VERO: P‰‰omatulon vero, vapaaeht. el‰kevakuutusmaksut huomioon otettuna';

%HAKU;

%YhtHyvS(hyvit, &mvuosi, &minf, &osinkotulo);

IF &mvuosi > 1994 THEN kulkorotx = 0;

ELSE kulkorotx = &kulkorot;

IF &mvuosi < 2005 THEN elvakmaksux = 0;

ELSE elvakmaksux = MIN(&elvakuutusmaksu,  &VapEhtRaja1);

vertulo = MAX(SUM(&osinkotulo, hyvit, &muupotulo, -&povahenn, -kulkorotx, -elvakmaksux), 0);

IF &mvuosi > 2011 AND vertulo > &PORaja THEN

	&tulos = &PaaomaVeroPros * &PORaja + &POPros2 * (vertulo - &PORaja);
	
ELSE
	&tulos = &PaaomaVeroPros * vertulo;

DROP hyvit kulkorotx vertulo;

%MEND PoTulonVeroEritS;


/* 37. Kotitalousv‰hennys
	   Huom! Makro ottaa huomioon pelk‰st‰‰n v‰hennyksen alarajan
       ja yl‰rajan, mutta ei v‰hennyksen muodostumista eri menolajeista */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kotitalousv‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	kotitmeno: Kotitalousv‰hennykseen oikeuttavat menot;

%MACRO KotiTalVahS(tulos, mvuosi, minf, kotitmeno)/
DES = 'VERO: Kotitalousv‰hennys';

%HAKU;

&tulos = MAX(&kotitmeno - &KotitVahOmavast, 0);

IF &tulos > &KotitVahEnimm THEN &tulos = &KotitVahEnimm;

%MEND KotiTalVahS;


/* 38. V‰hennysten jakaminen eri verolajeille:
	   Makroa voi k‰ytt‰‰ jaettaessa kotitalousv‰hennyst‰, valtionverotuksen
	   ansiotulov‰hennyst‰ ja erityist‰ alij‰‰m‰hyvityst‰ eri verolajeille */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron m‰‰r‰ 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	vahennys: V‰hennys, jota jaetaan
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero, 6 = po-tulon vero
	valtansvero: Ansiotulon valtionvero ennen v‰hennyst‰
	kunnvero: Kunnallinen tulovero ennen v‰hennyst‰
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen v‰hennyst‰
	kevmaksu: Kansanel‰kevakuutusmaksu ennen v‰hennyst‰ (koska kevmaksua ei perit‰ vuoden 1995 j‰lkeen, t‰m‰ muuttuja on yleens‰ = 0)
	kirkvero: Kirkollisvero
	potulonvero: P‰‰omatulon vero (jos jaetaan ansiotulov‰hennyst‰ tai erityist‰ alij‰‰m‰hyvityst‰, t‰m‰ = 0);

%MACRO VahennJakoS (tulos, mvuosi, vahennys, verolaji, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero, potulonvero)/
DES = 'VERO: V‰hennysten jakaminen eri verolajeille';

/* Verolajit */

valt =  &valtansvero + &potulonvero;

muutverot = &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

*Jos ei veroja, tulos on aina 0;

IF valt = 0 AND  muutverot = 0 THEN DO;
	&tulos = 0;
END;

ELSE DO;

	/* Lasketaan v‰hennys eri verolajeille, ensi sijassa valtion verosta 
   	   ansiotulojen valtionverolle ja p‰‰omatulon verolle n‰iden verolajien suhteessa.
       Jos valtionverot eiv‰t riit‰, loppuosa muille verolajeille niiden suhteessa.
       Ennen vuotta 2001 v‰hennys vain valtionverosta */
	
	/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero, 6 = po-tulon vero */

	SELECT (&verolaji);

		*VALT. ANS.VERO;

		WHEN (1) DO;

			IF &vahennys = 0 THEN &tulos = &valtansvero;

			IF valt = 0 OR &valtansvero = 0 THEN &tulos = 0;

			IF &valtansvero >= 0 and valt > 0 AND &vahennys > 0 AND &vahennys <= valt THEN DO;

				suhde = &valtansvero / valt;

				&tulos = &valtansvero - suhde* &vahennys;

			END;

			IF &vahennys > valt AND valt >= 0 THEN &tulos = 0;

			IF valt < 0 or &valtansvero < 0 THEN &tulos = &valtansvero;

		END;

		*KUNN.VERO;

		WHEN (2) DO;

			IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kunnvero;

			IF &kunnvero = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kunnvero / muutverot;

				&tulos = &kunnvero - suhde * (&vahennys - valt);

			END;

		END;

		*SV-MAKSU;

		WHEN (3) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &svmaksu;

			IF &svmaksu = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &svmaksu / muutverot;

				&tulos = &svmaksu - suhde * (&vahennys - valt);

			END;

		END;

		*KEV-MAKSU;

		WHEN (4) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kevmaksu;

			IF &kevmaksu = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kevmaksu / muutverot;

				&tulos = &kevmaksu - suhde * (&vahennys - valt);

			END;

		END;

		*KIRK.VERO;

		WHEN (5) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kirkvero;

			IF &kirkvero = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kirkvero / muutverot;

				&tulos = &kirkvero - suhde * (&vahennys - valt);

			END;

		END;

		*PO-TULO;

		WHEN (6) DO;

			IF &vahennys = 0 THEN &tulos = &potulonvero;

			IF &potulonvero = 0 OR valt = 0 OR &vahennys > valt THEN &tulos = 0;

			IF &vahennys > 0 AND &vahennys < valt THEN DO;

				suhde = &potulonvero / valt;

				&tulos = &potulonvero - suhde * &vahennys;

			END; 
		END;

		OTHERWISE &tulos = 0;

	END;

	IF &tulos < 0 THEN &tulos = 0;

END;

DROP valt muutverot suhde;

%MEND VahennJakoS;


/* 39. Alij‰‰m‰hyvityksen jakaminen eri verolajeille;
	   Hyvityksen jakamista valtionveron ja muiden verojen kesken s‰‰telee laissa oleva parametri */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron m‰‰r‰
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	alijhyv: Alij‰‰m‰hyvitys, jota jaetaan
	valtansvero: Ansiotulon valtionvero ennen v‰hennyst‰
	kunnvero: Kunnallinen tulovero ennen v‰hennyst‰
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen v‰hennyst‰
	kevmaksu: Kansanel‰kevakuutusmaksu ennen v‰hennyst‰ (koska kevmaksua ei perit‰ vuoden 1995 j‰lkeen, t‰m‰ muuttuja on yleens‰ = 0)
	kirkvero: Kirkollisvero;

%MACRO AlijHyvJakoS (tulos, mvuosi, verolaji, alijhyv, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/
DES = 'VERO: Alij‰‰m‰hyvityksen jakaminen eri verolajeille';

IF SUM(&valtansvero + &kunnvero + &svmaksu + &kevmaksu + &kirkvero) = 0 THEN &tulos = 0;

ELSE DO;

	valtos = &ValtAlijOsuus * &alijhyv;

	IF valtos < &valtansvero THEN jaettava = MAX(&alijhyv - valtos, 0);

	ELSE jaettava = &alijhyv - &valtansvero;
	
	jakopohja = MAX(&valtansvero - valtos, 0) + &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

	/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero */
		
	SELECT (&verolaji);

		*VALT. ANS.VERO;

		WHEN (1) DO;
	
			IF jakopohja > 0 THEN tmposuus = MAX(&valtansvero - valtos, 0) / jakopohja;

			ELSE tmposuus = 0;
			
			&tulos = MAX(&valtansvero - valtos,  0)- tmposuus * jaettava;
       	END;

		*KUNN.VERO;

		WHEN (2) DO;

			IF jakopohja > 0 THEN tmposuus = &kunnvero / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kunnvero - tmposuus * jaettava;

		END;

		*SV-MAKSU;
					
		WHEN (3) DO;

			IF jakopohja > 0 THEN tmposuus = &svmaksu / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &svmaksu - tmposuus * jaettava;

		END;

		*KEV-MAKSU;

		WHEN (4) DO;

			IF jakopohja > 0 THEN tmposuus = &kevmaksu / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kevmaksu - tmposuus * jaettava;

		END;
			
		*KIRK.VERO;

		WHEN (5) DO;

			IF jakopohja > 0 THEN tmposuus = &kirkvero / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kirkvero - tmposuus * jaettava;

		END;

		OTHERWISE  &tulos = 0;
		
	END;

END;

IF &tulos < 0 THEN &tulos = 0;

DROP valtos jaettava jakopohja tmposuus;

%MEND AlijHyvJakoS;


/* 40. Yhtiˆveron hyvityksen jakaminen eri verolajeille. 
       Huom! Lains‰‰d‰ntˆvuodesta riippumaton makro. */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron m‰‰r‰ 
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	yhthyvans: Ansiotulo-osinkoon kohdistuva yhtiˆveron hyvitys
	yhthyvpo: P‰‰omatulo-osinkoon kohdistuva yhtiˆveron hyvitys
	valtvero: Valtionverot
	valtansvero: Ansiotulon valtionvero ennen v‰hennyst‰
	kunnvero: Kunnallinen tulovero ennen v‰hennyst‰
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen v‰hennyst‰
	kevmaksu: Kansanel‰kevakuutusmaksu ennen v‰hennyst‰ (koska kevmaksua ei perit‰ vuoden 1995 j‰lkeen, t‰m‰ muuttuja on yleens‰ = 0)
	kirkvero: Kirkollisvero;

%MACRO YhtHyvJakoS(tulos, verolaji, yhthyvans, yhthyvpo, valtvero, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/
DES = 'VERO: Yhtiˆveron hyvityksen jakaminen eri verolajeille';

IF (&valtansvero >= 0) AND (&kunnvero >= 0) AND  (&svmaksu >= 0) AND
	(&kevmaksu >= 0) AND  (&kirkvero >= 0) THEN
	ansverosumma = &valtansvero + &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

ELSE ansverosumma = 0;

/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero */

SELECT(&verolaji);

	*VALT. ANS.VERO;

	WHEN (1) DO;

		IF ansverosumma > 0 THEN &tulos = &valtvero - &yhthyvpo - &valtansvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &valtvero - &yhthyvpo - &yhthyvans;

	END;

	*KUNN.VERO;

	WHEN (2) DO;

		IF ansverosumma > 0 THEN &tulos = &kunnvero - &kunnvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &kunnvero;

	END;

	*SV-MAKSU;

	WHEN (3) DO;

		IF ansverosumma > 0 THEN &tulos = &svmaksu - &svmaksu * &yhthyvans / ansverosumma;

		ELSE &tulos = &svmaksu;

	END;

	*KEV-MAKSU;

	WHEN (4) DO;

		IF ansverosumma > 0 THEN &tulos = &kevmaksu - &kevmaksu * &yhthyvans / ansverosumma;

		ELSE &tulos = &kevmaksu;

	END;

	*KIRK.VERO;

	WHEN (5) DO;

		IF ansverosumma > 0 THEN &tulos = &kirkvero - &kirkvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &kirkvero;

	END;

	OTHERWISE &tulos = -100;
END;

DROP ansverosumma;

%MEND YhtHyvJakoS;


/* 41. Valtionverotuksen lapsenhoitov‰hennys (nimen‰ myˆs ylim‰‰r‰inen tyˆtulov‰hennys) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen lapsenhoitov‰hennys
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1)
		lapsia: Huollettavina olevia alaik‰isi‰ lapsia (0/1)
		lapsia_3_7_v: 3-7-vuotiaita lapsia (0/1)
		lapsia_7_v: Alle 7-vuotiaita lapsia (0/1)
		puhdanstulo: Puhdas ansiotulo,  
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus valtionverotuksen lapsenhoitov‰hennyksest‰;

%MACRO ValtLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, lapsia_3_7_v, lapsia_7_v, puhdanstulo, kokontulo, puolisonos)/ 
DES = 'VERO: Valtionverotuksen lapsiv‰hennys';

%HAKU;

* Ennen vuotta 1989 v‰hennyksen voi saada puolisoista vain pienituloisempi ;
IF &mvuosi < 1989 AND &puoliso NE 0 AND &pientul NE 1 THEN &tulos = 0;

ELSE DO;
	* Korjataan lapsimuuttujien mahdollinen ep‰johdonmukaisuus ;
	IF &lapsia_3_7_v NE 0 OR &lapsia_7_v NE 0 THEN DO;
		%LET lapsia = 1;
	END;
	IF &lapsia_3_7_v NE 0 THEN DO;
		%LET lapsia_7_v = 1;
	END;

	* Ennen vuotta 1989 alle 7-vuotiaat lapset korottavat v‰hennyksen enimm‰ism‰‰r‰‰ ;
	IF &mvuosi < 1989 THEN DO;
		IF &lapsia_7_v NE 0 THEN vah1 = &ValtLapsiVah + &ValtLapsKorotus;
	END;

	* Ennen vuotta 1989 v‰hennys lasketaan puhtaasta ansiotulosta, sen j‰lkeen 
	  kokonaistulosta ja vuodesta 1993 l‰htien puhtaasta ansiotulosta ;
	IF &mvuosi < 1989 THEN tulo = &puhdanstulo;
	IF &mvuosi > 1988 AND &mvuosi < 1993 THEN tulo = &kokontulo;
	IF &mvuosi > 1992 THEN tulo = &puhdanstulo;

	* Vuoden 1989 j‰lkeen vain 3-7-vuotiaat lapset oikeuttavat v‰hennykseen, sit‰ ennen kaikki lapset ;
	IF &mvuosi > 1989 THEN DO;
		IF &lapsia_3_7_v NE 0 THEN vah2 = &ValtLapsPros * &ValtLapsiVah;
	END;

	ELSE DO; 
		IF &lapsia NE 0 THEN vah2 = &ValtLapsPros * tulo;
	END;

	* Rajoitetaan v‰hennys v‰hennyksen enimm‰ism‰‰r‰‰n ;
	IF vah2 > &ValtLapsiVah THEN vah2 = &ValtLapsiVah;

	* Vuodesta 1989 l‰htien v‰hennys voidaan jakaa puolisoiden kesken ;
	IF &mvuosi > 1988 AND &puoliso NE 0 THEN vah2 = vah2 - &puolisonos;
	IF vah2 < 0 THEN vah2 = 0;

	* Varmistetaan, ettei v‰hennys ole suurempi kuin se tulo, josta se voidaan myˆnt‰‰ ;
	IF vah2 > tulo THEN vah2 = tulo;

END;

&tulos = vah2;

DROP vah1 vah2 tulo;

%MEND ValtLapsVahS;

/* 42. Kunnallisverotuksen lapsenhoitov‰hennys (huom! sis‰lt‰‰ myˆs yksinhuoltajav‰hennyksen) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen lapsenhoitov‰hennys
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1)
		pientul: Pienituloisempi puoliso (0/1)
		lapsia: Huollettavina olevien alaik‰isten lasten lukum‰‰r‰
		puhdanstulo: Puhdas ansiotulo 
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus kunnallisverotuksen lapsiv‰hennyksest‰;

%MACRO KunnLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, puhdanstulo, kokontulo, puolisonos)/ 
DES = 'VERO: Kunnallisverotuksen lapsiv‰hennys';

%HAKU;

temp = 0;
kerroin = 0;

* Ennen vuotta 1989 v‰hennyksen voi saada puolisoista vain suurempituloisempi ;
IF &mvuosi < 1989 AND &puoliso = 1 AND &pientul = 1 THEN temp = 0;

ELSE DO;

	SELECT (&lapsia);

		WHEN (0) DO;
			temp = 0;
		END;

		WHEN (1) DO;
			temp = &KunnLapsiVah;
		END;

		WHEN (2) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2;
		END;

		WHEN (3) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3;
		END;

		WHEN (4) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3 + &KunnLapsVah4;
		END;

		OTHERWISE temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3 + &KunnLapsVah4 + ((&lapsia - 4) * &KunnLapsVahMuu);

	END;
	
	* Yksinhuoltajav‰hennys otetaan huomioon kertoimella 1 ;
	IF &puoliso NE 1 AND &lapsia NE 0 THEN DO;
		kerroin = 1; 
		&puolisonos = 0;
	END;

	temp = temp + kerroin * &KunnYksHuoltVah;
	temp = temp - (temp * &puolisonos);

	IF temp < 0 THEN temp = 0;
	IF &mvuosi < 1993 AND temp > &kokontulo THEN temp = &kokontulo;
	IF &mvuosi > 1992 AND temp > &puhdanstulo THEN temp = &puhdanstulo;

&tulos = temp;

END;

DROP temp kerroin;

%MEND KunnLapsVahS;

/* 43. Kunnallisverotuksen yksinhuoltajav‰hennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen yksinhuoltajav‰hennys
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1)
		lapsia: Huollettavina olevien alaik‰isten lasten lukum‰‰r‰
		puhdanstulo: Puhdas ansiotulo; 

%MACRO KunnYksVahS(tulos, mvuosi, minf, puoliso, lapsia, puhdanstulo)/
DES = 'VERO: Kunnallisverotuksen yksinhuoltajav‰hennys';

%HAKU;

IF &lapsia <= 0 OR &puoliso NE 0 THEN &tulos = 0;

ELSE DO;

	vah = &KunnYksHuoltVah;

	IF &mvuosi > 1992 THEN DO;

		IF vah > &puhdanstulo THEN vah = &puhdanstulo;

	END;

&tulos = vah;

END;

DROP vah;

%MEND KunnYksVahS;

/* 44. Varallisuusvero */ 

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Varallisuusvero
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1)
		lapsia: Huollettavina olevien alaik‰isten lasten lukum‰‰r‰
		vakasu: Vakituinen asunto varallisuuden osana (0/1)
		nettovarall: Nettovarallisuus, e;

%MACRO VarallVeroS(tulos, mvuosi, minf , puoliso, lapsia, vakasu, nettovarall)/ 
DES = 'VERO: Varallisuusvero';

%HAKU;
%HAKUVV;

puolvah = 0;
vaka = 0;

IF &puoliso NE 0 THEN puolvah = &VarPuolVah;

IF &vakasu NE 0 THEN vaka = &VakAs;

* Otetaan huomioon puoliso- ja lapsiv‰hennykset sek‰ v‰hennys vakituisesta asunnosta ;
temp = &nettovarall - puolvah - (&lapsia * &VarLapsiVah) - vaka;

IF temp <= 0 THEN &tulos = 0;

* Lasketaan varallisuusverotaulukon avulla varallisuusvero ;
ELSE DO;

	IF temp GE &VarRaja6 THEN
		temp = &VarPros6 * (temp - &VarRaja6) + &VarVakio6;
	
	ELSE IF temp GE &VarRaja5 THEN
		temp = &VarPros5 * (temp - &VarRaja5) + &VarVakio5;
	
	ELSE IF temp GE &VarRaja4 THEN
		temp = &VarPros4 * (temp - &VarRaja4) + &VarVakio4;
	
	ELSE IF temp GE &VarRaja3 THEN
		temp = &VarPros3 * (temp - &VarRaja3) + &VarVakio3;
	
	ELSE IF temp GE &VarRaja2 THEN
		temp = &VarPros2 * (temp - &VarRaja2) + &VarVakio2;

	ELSE IF temp GE &VarRaja1 THEN
		temp = &VarPros1 * (temp - &VarRaja1) + &VarVakio1;

	&tulos = temp;

END; 

DROP temp puolvah vaka;

%MEND VarallVeroS;

/* 45. Kunnallisverotuksen el‰ketulov‰hennyksen maksimiarvo = t‰ysi el‰ketulov‰hennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen t‰ysi el‰ketulov‰hennys
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1);

%MACRO KunnElTulVahMaxS (tulos, mvuosi, minf, puoliso)/
DES = 'VERO: Kunnallisverotuksen el‰ketulov‰hennyksen maksimiarvo (t‰ysi el‰ketulov‰hennys)';

tulo = 0;
erotus = 1;

DO TULO = 0 TO 50000 BY 1000;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO = TULO -1000 TO TULO + 1000 BY 100;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO =  TULO -100 TO TULO + 100 BY 10;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 2;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo t t1 ;

%MEND KunnElTulVahMaxS;

/* 46. Valtionverotuksen el‰ketulov‰hennyksen maksimiarvo = t‰ysi el‰ketulov‰hennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen t‰ysi el‰ketulov‰hennys
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi;

%MACRO ValtElTulVahMaxS (tulos, mvuosi, minf)/
DES = 'VERO: Valtionverotuksen el‰ketulov‰hennyksen maksimiarvo (t‰ysi el‰ketulov‰hennys)';

tulo = 0;
erotus = 1;
	
DO TULO = 1000 TO 50000 BY 1000;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 2;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo t t1;

%MEND ValtElTulVahMaxS;

/* 47. Raja, josta el‰ketulon verotus alkaa */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Raja josta el‰ketulon verotus alkaa
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		puoliso: Onko henkilˆll‰ puoliso (0/1);

%MACRO ElVeroRajaS (tulos, mvuosi, minf, puoliso)/
DES = 'VERO: Raja, josta el‰ketulon verotus alkaa';

tulo = 0;
vero = 0;

DO TULO = 0 TO 50000 BY 1000;
	%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo vero;

%MEND ElVeroRajaS;

/* 48. Valtion tuloverotuksen alaraja */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtion tuloverotuksen alaraja
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = el‰ke, 3 = muu tulo;

%MACRO ValtVerRajaS (tulos, mvuosi, minf, tulolaji)/
DES = 'VERO: Valtion tuloverotuksen alaraja';

IF &tulolaji = 3 THEN DO;

	%HAKU;
	&tulos = &Raja2;
END;

IF &tulolaji = 2 THEN DO;

DO TULO = 0 TO 50000 BY 1000;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &Raja2 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &Raja2 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &Raja2 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &Raja2 THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &Raja2 THEN LEAVE;
END;

&tulos = tulo;

END;

IF &tulolaji = 1 THEN DO;

DO TULO = 0 TO 50000 BY 1000;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, 0, 0, 0, 0);
	%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
	%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
	%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
	vertulo = tulo - temp2 - temp3 - temp4 - temp5;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo, 0);
	%ValtVerAnsVahS (temp6, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp6;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, 0, 0, 0, 0);
	%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
	%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
	%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
	vertulo = tulo - temp2 - temp3 - temp4 - temp5;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo, 0);
	%ValtVerAnsVahS (temp6, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp6;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, 0, 0, 0, 0);
	%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
	%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
	%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
	vertulo = tulo - temp2 - temp3 - temp4 - temp5;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo, 0);
	%ValtVerAnsVahS (temp6, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp6;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, 0, 0, 0, 0);
	%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
	%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
	%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
	vertulo = tulo - temp2 - temp3 - temp4 - temp5;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo, 0);
	%ValtVerAnsVahS (temp6, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp6;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, 0, 0, 0, 0);
	%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
	%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
	%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
	vertulo = tulo - temp2 - temp3 - temp4 - temp5;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo, 0);
	%ValtVerAnsVahS (temp6, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp6;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

&tulos = tulo;

END;

DROP tulo temp1 temp2 temp3 temp4 temp5 temp6 vertulo vero vero2;

%MEND ValtVerRajaS;

/* 49. Kunnan tuloverotuksen alaraja */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnan tuloverotuksen alaraja
		mvuosi: Vuosi, jonka lains‰‰d‰ntˆa k‰ytet‰‰n
		minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = el‰ke, 3 = muu tulo;

%MACRO KunnVerRajaS (tulos, mvuosi, minf, puoliso, tulolaji)/
DES = 'VERO: Kunnan tuloverotuksen alaraja';

IF &tulolaji = 3 THEN DO;

	%HAKU;

	&tulos = &KunnPerEnimm;

END;

IF &tulolaji = 2 THEN DO;

	%ElVeroRajaS (elraja1, &mvuosi, &minf, &puoliso);

	&tulos = elraja1;

END;

IF &tulolaji = 1 THEN DO;
	
	DO TULO = 0 TO 50000 BY 1000;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
		%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
		%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 - temp4 - temp5;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp6, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp6;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
		%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
		%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 - temp4 - temp5;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp6, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp6;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 100 TO TULO + 100 BY 10;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
		%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
		%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 - temp4 - temp5;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp6, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp6;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 10 TO TULO + 10 BY 1;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
		%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
		%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 - temp4 - temp5;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp6, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp6;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%TyoelMaksuS(temp3, &mvuosi, &minf, 30, tulo);
		%TyotMaksuS(temp4, &mvuosi, &minf, 30, tulo);
		%SvPRahaMaksuS (temp5, &mvuosi, &minf, 30, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 - temp4 - temp5;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp6, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp6;
		IF vertulo1 > 0 THEN LEAVE;	
	END;

	&tulos = tulo;

END;

DROP tulo elraja1 temp1 temp2 temp3 temp4 temp5 temp6 vertulo vertulo1;

%MEND KunnVerRajaS;

/* 50. Yle-vero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yle-vero 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
    ika: Henkilˆn ik‰ vuosina
	tulo: Puhdas ansio- ja p‰‰omatulo yhteens‰
	maakunta: Henkilˆn maakunta;

%MACRO YleVeroS(tulos, mvuosi, minf, ika, tulo, maakunta)/
DES = 'VERO: Yle-vero';

	%HAKU;

	* Ei Yle-veroa alle 18-vuotiaille eik‰ henkilˆille, joiden kotikunta on Ahvenanmaa;
	IF &ika < &YleIkaRaja OR &maakunta = 21 THEN temp = 0;

	ELSE DO;

		* Korkeintaan &YleTuloRaja-parametrin suuruisista tuloista Yle-veroa ei makseta lainkaan;
		IF &tulo <= &YleTuloRaja THEN temp = 0;

		ELSE DO;

			temp = &YlePros * (&tulo - &YleTuloRaja);

			IF temp < &YleAlaRaja THEN temp = 0;

			IF temp > &YleYlaRaja THEN temp = &YleYlaRaja;

		END;

	END;

	&tulos = temp;

	DROP temp;

%MEND YleVeroS;

/* 51. Makro, joka laskee valtionveron, kun verotuksen kattos‰‰nnˆs otetaan huomioon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionvero kun verotuksen kattos‰‰nnˆs on otettu huomioon
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	valtvertulot: Valtionverotuksessa verotettava tulo 
	valttulovero: Valtion tulovero
	varallvero: Varallisuusvero
	muutverot: Kunnallisvero, Sairausvakuutusmaksu/sairaanhoitomaku, Kansanel‰kevakuutusmaksu,
	           Kirkollisvero, P‰‰omatulon vero;

%MACRO ValtVero_FinalS(tulos, mvuosi, valtvertulot, valttuloverot, varallvero, muutverot)/
DES = 'VERO: Valtionvero, kun verotuksen kattos‰‰nnˆs otetaan huomioon';

temp = &valttuloverot + &varallvero;

/* Kattoveros‰‰nnˆst‰ ei ole vuodesta 2006 l‰htien */

IF &mvuosi > 2005 THEN &tulos = temp;

IF temp = 0 THEN &tulos = 0;

/* Lasketaan verokatto */

osuus = &Kattovero * &valtvertulot;

verot = temp + &muutverot;

IF verot > osuus THEN temp = osuus - &muutverot;

/* Osa varallisuusverosta silti maksettava (vuoteen 1986)*/

IF temp <= (1 - &VarallKattoPros) * &varallvero 
THEN temp = (1- &VarallKattoPros) * &varallvero;

IF temp < 0 THEN temp = 0;

&tulos = temp;

DROP temp osuus verot;

%MEND ValtVero_FinalS;

/* 52. El‰ketulon lis‰vero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, El‰ketulon verot 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	elaketulo: El‰ketulo
	eltulvah: Valtioverotuksen el‰ketulov‰hennys;

%MACRO ElakeLisaVeroS(tulos, mvuosi, minf, elaketulo, eltulvah)/
DES = 'VERO: El‰ketulon lis‰vero';

%HAKU;

temp = 0;

IF &mvuosi > 2012 THEN DO; 

	elakevvah = &elaketulo - &eltulvah;

	IF elakevvah > &ElLisaVRaja THEN DO;
		temp = (elakevvah - &ElLisaVRaja) * &ElLisaVPros;
	END;

END;

&tulos = temp;

DROP elakevvah temp;

%MEND ElakeLisaVeroS;

/* 53. Lapsiperhev‰hennys */

/*	Makron parametrit:

    tulos: Makron tulosmuuttuja, Lapsiv‰hennyksen m‰‰r‰ 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	ykshuolt: Onko yksinhuoltaja (0/1) YKSINHUOLTAJA
	lapsia: V‰hennykseen oikeuttavien lasten (alle 18v) lukum‰‰r‰ (v‰hennykseen oikeuttaa max 4) cllkm
	puhdtulo: Yhteenlaskettu puhtaan ansiotulon ja p‰‰omatulon m‰‰r‰ , Ä/v SUM(PUHD_ANSIO, PUHD_PO)

	Parametritaulukosta tulevat parametrit:

	&LapsiVah: Parametri: Lapsiv‰hennyksen m‰‰r‰ / lapsi
	&LapsiLkmYlaRaja: Parametri: Lapsiv‰hennyksen lasten lukum‰‰r‰n yl‰raja
	&LapsiVahYlaRaja: Parametri: Lapsiv‰hennyksen raja, mink‰ alle v‰hennys maksetaan t‰ysim‰‰r‰isen‰
	&LapsiVahAlenema: Parametri: Osuus, mill‰ lapsiv‰hennys laskee kun &LapsVMYR rajan ylitt‰v‰lt‰ osalta */

%MACRO ValtVerLapsVahS(tulos, mvuosi, minf, ykshuolt, lapsia, puhdtulo)/
DES = 'VERO: Valtionverotuksen lapsiv‰hennys (v‰hennys verosta)';

%HAKU;

temp = 0;

IF &lapsia > 0 THEN DO;

	temp = MIN(&lapsia, &LapsiLkmYlaRaja) * &LapsiVah * ((&ykshuolt=1) + 1);
	IF &puhdtulo > &LapsiVahYlaRaja THEN temp = SUM(temp, -&LapsiVahAlenema * SUM(&puhdtulo, -&LapsiVahYlaRaja));
	
END;

&tulos = MAX(temp, 0);

DROP temp;

%MEND ValtVerLapsVahS;

/* 54. Kunnallisverotuksen merityˆtulov‰hennys */

/* Makron parametrit
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen merityˆtulov‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	merityˆtulo: Veronalainen merityˆtulo */

%MACRO KunnVerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Kunnallisverotuksen merityˆtulov‰hennys';

%HAKU;

/* Kunnallisverotuksen merityˆtulov‰hennys voimassa vuoteen 2022 asti */

	temp = 0;

	IF &merityotulo GT 0 THEN DO;

		temp = MIN((&merityotulo * (&MeriVahKunPros)), &MeriVahKunMax);

		yliraja = SUM(&merityotulo, -&MeriVahYli) * (&MeriVahYliPros);
		IF &merityotulo GT &MeriVahYli AND &mvuosi GT 2015 THEN
			temp = SUM(-yliraja, temp);

	END;
		
	&tulos = MAX(temp, 0);

	DROP temp;

%MEND KunnVerMeriVahS;

/* 55. Valtionverotuksen merityˆtulov‰hennys */

/* Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen merityˆtulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	merityˆtulo: Veronalainen merityˆtulo */

%MACRO ValtVerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Valtionverotuksen merityˆtulov‰hennys';

%HAKU;

/* Valtionverotuksen merityˆtulov‰hennys voimassa vuoteen 2022 asti */

	temp = 0;

	IF &merityotulo GT 0 THEN DO;

		temp = MIN((&merityotulo * (&MeriVahValPros)), &MeriVahValMax);

		yliraja = SUM(&merityotulo, -&MeriVahYli) * (&MeriVahYliPros); 
		IF &merityotulo GT &MeriVahYli AND &mvuosi GT 2015 THEN
			temp = SUM(-yliraja, temp);

	END;
		
	&tulos = MAX(temp, 0);

	DROP temp;


%MEND ValtVerMeriVahS;


/* 56. Tuloverot yksinkertaisessa perustapauksessa, kun tulot
	   ovat pelk‰st‰‰n vanhempainp‰iv‰rahaa tai muuta vastaavaa sosiaalietuutta (ei tyˆtuloa eik‰ el‰kett‰)
       ja palkkatuloja. */

/* Makron parametrit:
    tulos: Makron tulosmuuttuja, P‰iv‰rahatulon tai muun ansiotulon verot 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	prahatulo: P‰iv‰rahatulo, esim. vanhenpainp‰iv‰raha
	palkkatulo: palkkatulo
	ykshuolt: Onko yksinhuoltaja (0/1)
	a17vlapsia: alle 17v lapsien lukum‰‰r‰ */

%MACRO TuloVerot_Simple_PRahTyoS(tulos, mvuosi, minf, prahatulo, palkkatulo, yksinh, a17vlapsia)/
DES = 'VERO: Tuloverot yksinkertaisessa perustapauksessa, jossa p‰iv‰raha ja palkkatuloja';

%TulonHankKulutS(tulhanksum, &mvuosi, &minf, &palkkatulo, 0, 0, 0, 0);
ansiotulo = SUM(&prahatulo,&palkkatulo);
puhdansiotulo = MAX(SUM(ansiotulo, -tulhanksum), 0);

%TyoElMaksuS (tyelmaksu, &mvuosi, &minf, 30, &palkkatulo);
%TyotMaksuS(tyotmaksu, &mvuosi, &minf, 30, &palkkatulo);
%SvPrahaMaksuS(sairpmaksu, &mvuosi, &minf, 30, &palkkatulo);

%KunnAnsVahS(kunnans, &mvuosi, &minf, puhdansiotulo, ansiotulo, &palkkatulo, &palkkatulo, ansiotulo);
kunnverotulo = MAX(SUM(puhdansiotulo, -tyelmaksu, -tyotmaksu, -sairpmaksu, -kunnans), 0);
%KunnPerVahS (kunnper, &mvuosi, &minf, kunnverotulo);
kunnverotulo = MAX(SUM(kunnverotulo, -kunnper), 0);
%KunnVeroS(kunnvero, &mvuosi, &minf, 1, 18, kunnverotulo);

%SairVakMaksuS(sairvmaksu, &mvuosi, &minf, kunnverotulo, 0, &palkkatulo);

valtverotulo = MAX(SUM(puhdansiotulo, -tyelmaksu, -tyotmaksu, -sairpmaksu), 0);
%ValtTuloVeroS(valtvero, &mvuosi, &minf, valtverotulo, 0);
%ValtVerAnsVahS(valtansvah, &mvuosi, &minf, &palkkatulo, puhdansiotulo);
%ValtVerLapsVahS(valtlapsvah, &mvuosi, &minf,  &yksinh, &a17vlapsia, puhdansiotulo);

%YleVeroS(ylevero, &mvuosi, &minf, 18, puhdansiotulo, 0); 

&tulos = SUM(tyelmaksu, tyotmaksu, sairpmaksu, ylevero, MAX(0, SUM(sairvmaksu, kunnvero, valtvero, -valtansvah, -valtlapsvah))); 

DROP tulhanksum ansiotulo puhdansiotulo tyelmaksu tyotmaksu sairvmaksu sairpmaksu kunnans kunnverotulo kunnper kunnvero valtverotulo valtvero valtansvah ylevero valtlapsvah; 

%MEND TuloVerot_Simple_PRahTyoS;

/* 57. Kotitalousv‰hennyksen lis‰datan laskentamakro.
	Laskee kotitalousv‰hennyksen ostoihin, palkkakuluihin ja palkan sivukuluihin erittelyst‰
	datasta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousv‰hennysoikeus
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	palksiku: palkatun tyˆntekij‰n palkan sivukulut, oma osuus
	palkomos: palkatun tyˆntekij‰n palkka, oma osuus
	tyonosuu: tyˆn osuus yrityksen tyˆst‰
*/

%MACRO KotitVahErillS(tulos, mvuosi, minf, palksiku, palkomos, tyonosuu)/
DES = 'VERO: Kotitalousv‰hennys erillisdatasta';

	%HAKU;

	IF &tyonosuu > 0 THEN DO;
		temp1 = 0 + &tyonosuu * &KotitVahTyoKerroin;
	END;

	IF &palkomos > 0 THEN DO;
		temp2 = 0 + &palksiku + &palkomos * &KotitVahPalKerroin;
	END;

	&tulos = sum(temp1, temp2);

	VAHOIKUS_SIMUL = &tulos;
	
	IF SUM(&tulos, -&KotitVahOmavast) > &KotitVahEnimm THEN &tulos = &KotitVahEnimm;
	ELSE IF SUM(&tulos, -&KotitVahOmavast) < 0 THEN &tulos = 0;
	ELSE &tulos = &tulos - &KotitVahOmavast;

%MEND KotitVahErillS;


/* 58. Kotitalousv‰hennyksen lis‰datan laskentamakro tyˆn lajeittain.
	Laskee kotitalousv‰hennyksen ostoihin, palkkakuluihin ja palkan sivukuluihin sek‰ 
	kotitalous-, hoiva- tai hoitotyˆhˆn ja asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyˆhˆn
	eritellyst‰	datasta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousv‰hennysoikeus
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	palksiku_remontti: palkatun tyˆntekij‰n palkan sivukulut, oma osuus, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyˆ
	palksiku_koti: palkatun tyˆntekij‰n palkan sivukulut, oma osuus, kotitalous-, hoiva- tai hoitotyˆ
	palksiku_oljy: palkatun tyˆntekij‰n palkan sivukulut, oma osuus, kotitalous-, ˆljyl‰mmityksest‰ luopuminen
	palkomos_remontti: palkatun tyˆntekij‰n palkka, oma osuus, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyˆ
	palkomos_koti: palkatun tyˆntekij‰n palkka, oma osuus, kotitalous-, hoiva- tai hoitotyˆ
	palkomos_oljy: palkatun tyˆntekij‰n palkka, oma osuus, ˆljyl‰mmityksest‰ luopuminen
	tyonosuu_remontti: tyˆn osuus yrityksen tyˆst‰, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyˆ
	tyonosuu_koti: tyˆn osuus yrityksen tyˆst‰, kotitalous-, hoiva- tai hoitotyˆ
	tyonosuu_oljy: tyˆn osuus yrityksen tyˆst‰, ˆljyl‰mmityksest‰ luopuminen
*/


%MACRO KotitVahErillJakoS(tulos, mvuosi, minf, palksiku_remontti, palksiku_koti, palksiku_oljy, palkomos_remontti, palkomos_koti, palkomos_oljy, tyonosuu_remontti, tyonosuu_koti, tyonosuu_oljy)/
DES = 'VERO: Kotitalousv‰hennys erillisdatasta';

	%HAKU;

	/*Asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyˆ*/
	IF &tyonosuu_remontti > 0 THEN
		temp1_remontti = 0 + &tyonosuu_remontti * &KotitVahTyoKerroinRemontti;
	ELSE temp1_remontti = 0;

	IF &palkomos_remontti > 0 THEN
		temp2_remontti = 0 + &palksiku_remontti + &palkomos_remontti * &KotitVahPalKerroinRemontti;
	ELSE temp2_remontti = 0;

	remonttiYht = sum(temp1_remontti, temp2_remontti);

	IF SUM(remonttiYht, -&KotitVahOmavast) >= &kotitVahEnimmRemontti THEN tulosRemontti = &kotitVahEnimmRemontti;
	ELSE IF SUM(remonttiYht, -&KotitVahOmavast) <= 0 THEN tulosRemontti = 0;
	ELSE tulosRemontti = SUM(remonttiYht, -&KotitVahOmavast);

	/*Kotitalous-, hoiva- tai hoitotyˆ*/
	IF &tyonosuu_koti > 0 THEN
		temp1_koti = 0 + &tyonosuu_koti * &KotitVahTyoKerroin;
	ELSE temp1_koti = 0;

	IF &palkomos_koti > 0 THEN
		temp2_koti = 0 + &palksiku_koti + &palkomos_koti * &KotitVahPalKerroin;
	ELSE temp2_koti = 0;

	kotiYht = sum(temp1_koti, temp2_koti);

	/* Huomioidaan t‰ss‰ vaiheessa v‰hennetty omavastuu */
	OmavastuuVahennetty1 = MIN(remonttiYht, &KotitVahOmavast); 			/* K‰ytetty omavastuu remonttikustannuksen verran, kuitenkin enint‰‰n omavastuun verran */
	OmavastuuJaljella1 = sum(&KotitVahOmavast, -OmavastuuVahennetty1); 	/* J‰ljell‰ oleva omavastuu on enimm‰isomavastuun ja t‰ss‰ v‰hennetyn verran */

	/*Huomioidaan t‰ss‰ vaiheessa j‰ljell‰ oleva enimm‰ism‰‰r‰*/
	EnimmaisJaljella = MAX(0, SUM(&kotitVahEnimm, -tulosRemontti));

	IF SUM(kotiYht, -OmavastuuJaljella1) >= EnimmaisJaljella THEN tulosKoti = EnimmaisJaljella;
	ELSE IF SUM(kotiYht, -OmavastuuJaljella1) <= 0 THEN tulosKoti = 0;
	ELSE tulosKoti = SUM(kotiYht, -OmavastuuJaljella1);

	/*÷ljyl‰mmityksest‰ luopuminen*/
	IF &tyonosuu_oljy > 0 THEN
		temp1_oljy = 0 + &tyonosuu_oljy * &KotitVahTyoKerroinOljy;
	ELSE temp1_oljy = 0;

	IF &palkomos_oljy > 0 THEN
		temp2_oljy = 0 + &palksiku_oljy + &palkomos_oljy * &KotitVahPalKerroinOljy;
	ELSE temp2_oljy = 0;

	oljyYht = sum(temp1_oljy, temp2_oljy);

	/* Huomioidaan t‰ss‰ vaiheessa v‰hennetty omavastuu */
	OmavastuuVahennetty2 = MIN(kotiYht, OmavastuuJaljella1); 				/* K‰ytetty omavastuu kotitalous-, hoiva- tai hoitotyˆkustannuksen verran, kuitenkin enint‰‰n omavastuun verran */
	OmavastuuJaljella2 = sum(OmavastuuJaljella1, -OmavastuuVahennetty2); 	/* J‰ljell‰ oleva omavastuu on enimm‰isomavastuun ja t‰ss‰ v‰hennetyn verran */

	/*Huomioidaan t‰ss‰ vaiheessa j‰ljell‰ oleva enimm‰ism‰‰r‰*/
	EnimmaisJaljella = MAX(0, SUM(&kotitVahEnimmOljy, -tulosRemontti, -tulosKoti));

	IF SUM(oljyYht, -OmavastuuJaljella2) >= EnimmaisJaljella THEN tulosOljy = EnimmaisJaljella;
	ELSE IF SUM(oljyYht, -OmavastuuJaljella2) <= 0 THEN tulosOljy = 0;
	ELSE tulosOljy = SUM(oljyYht, -OmavastuuJaljella2);

	/*Kaikki kotitalousv‰hennykset yhteens‰*/
	IF SUM(tulosRemontti, tulosKoti, tulosOljy) > 0 THEN &tulos = SUM(tulosRemontti, tulosKoti, tulosOljy);
	ELSE &tulos = 0;

%MEND KotitVahErillJakoS;


/* 59. Yritt‰j‰v‰hennys 

Parametrit:
    tulos: Makron tulosmuuttuja, Yritt‰j‰v‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	yrtulo: yritt‰j‰tulo
*/

%MACRO YrittajaVahS(tulos, mvuosi, minf, yrtulo)/
DES = 'VERO: Yritt‰j‰v‰hennys';

%HAKU;

temp = 0;

IF &mvuosi > 2016 THEN temp = &YrVahPros * &yrtulo;

&tulos = MAX(temp,0);

DROP temp;

%MEND YrittajaVahS;


/* 60. Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen
    veroprosentin muuntamiseen tarvittavat kertoimet

Makron parametrit:
	ainvuosi: Aineiston perusvuosi 
	lsvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
*/

%MACRO KunnVerKerroin(ainvuosi, lsvuosi)/
DES = 'VERO: Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen veroprosentin muuntamiseen tarvittavat kertoimet';

PROC MEANS DATA = PARAM.&PVERO MAX MIN NOPRINT;
VAR vuosi;
OUTPUT OUT = VEROVUODET MAX(vuosi) = maxvuosi MIN(vuosi) = minvuosi;
RUN;

DATA _NULL_;
SET VEROVUODET;
CALL SYMPUT ('maxvuosi', maxvuosi);
CALL SYMPUT ('minvuosi', minvuosi);
RUN;

DATA _NULL_;
SET PARAM.&PVERO;
IF vuosi = MIN(MAX(&ainvuosi, &minvuosi), &maxvuosi) THEN DO;
	CALL SYMPUT ('ayria', KeskKunnPros);
	CALL SYMPUT ('kayria', KirkVeroPros);
END;
IF vuosi = MIN(MAX(&lsvuosi, &minvuosi), &maxvuosi) THEN DO;
	CALL SYMPUT  ('ayrib', KeskKunnPros);
	CALL SYMPUT  ('kayrib', KirkVeroPros);
END;
RUN;

%LET KunnKerroin = %SYSEVALF(&ayrib/&ayria);
%LET KirkKerroin = %SYSEVALF(&kayrib/&kayria);

%MEND KunnVerKerroin;


/* 61. Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken

Makron parametrit:
	vahennys: Jaettavan v‰hennyksen m‰‰r‰, e/vuosi
	vero: Vero, josta v‰hennys tehd‰‰n, e/vuosi
*/

%MACRO VahennysSwap (vahennys, vero)/
DES = 'VERO: Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken veromallissa';

IF &VAHENNYS.1 > 0 OR &VAHENNYS.2 > 0 THEN DO;
			&VAHENNYS.1FINAL = MIN(&VERO.1, &VAHENNYS.1);
			&VAHENNYS.1SIIRT = MAX(&VAHENNYS.1 - &VERO.1, 0);
			&VAHENNYS.2FINAL = MIN(&VERO.2, &VAHENNYS.2);
			&VAHENNYS.2SIIRT = MAX(&VAHENNYS.2 - &VERO.2, 0);
			&VAHENNYS.1FINAL = &VAHENNYS.1FINAL + &VAHENNYS.2SIIRT;
			&VAHENNYS.2FINAL = &VAHENNYS.2FINAL + &VAHENNYS.1SIIRT;
			*&VERO.1 = MAX(&VERO.1 - &VAHENNYS.1FINAL, 0);
			*&VERO.2 = MAX(&VERO.2 - &VAHENNYS.2FINAL, 0);
END;
ELSE DO;
	&VAHENNYS.1FINAL = 0;
	&VAHENNYS.2FINAL = 0;
END;
%MEND VahennysSwap;

 /* 61. Merityˆtulov‰hennys  

	Makron parametrit:
    tulos: Makron tulosmuuttuja, Merityˆtulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	merityˆtulo: Veronalainen merityˆtulo */

%MACRO VerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Merityˆtulov‰hennys';

%HAKU;

/* Yhdistetty merityˆtulov‰hennys voimassa vuodesta 2023 l‰htien, ei en‰‰ erillisist‰ laskentaa valtionverotuksessa ja kunnallisessa verotuksessa */

	temp = 0;

	IF &merityotulo GT 0 THEN DO;

		temp = MIN((&merityotulo * (&MeriVahPros)), &MeriVahMax);

		yliraja = SUM(&merityotulo, -&MeriVahYli) * (&MeriVahYliPros); 
		IF &merityotulo GT &MeriVahYli THEN temp = SUM(-yliraja, temp); 

	END;
		
	&tulos = MAX(temp, 0);

	DROP temp;


%MEND VerMeriVahS;

/* 62. Opintorahav‰hennys 

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Opintorahav‰hennys 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	opraha: Opintoraha (veronalainen opintukilain mukainen opintoraha)
	puhdanstulo: Puhdas ansiotulo; */

%MACRO OpRahVahS (tulos, mvuosi, minf, opraha, puhdanstulo)/
DES = 'VERO: Opintorahav‰hennys';

%HAKU;

/* Yhdistetty opintorahav‰hennys voimassa vuodesta 2023 l‰htien */

	IF &opraha = 0 THEN &tulos = 0;

	ELSE DO;

		&tulos = &YhdOpRahVah;

		IF &puhdanstulo > &YhdOpRahVah THEN  &tulos =  &YhdOpRahVah - &YhdOpRahPros * (&puhdanstulo  - &YhdOpRahVah);

		IF &tulos < 0 THEN &tulos = 0;

		IF &tulos > &opraha THEN &tulos = &opraha;
	END;


%MEND OpRahVahS;

/* 63. Ansiotulov‰hennys

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Ansiotulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puhdanstulo: Puhdas ansiotulo
	tyotulo: Tyˆtulo */

%MACRO AnsVahS(tulos, mvuosi, minf, puhdanstulo, tyotulo)/
DES = 'VERO: Ansiotulov‰hennys';

%HAKU;

/* Yhdistetty ansiotulov‰hennys voimassa 2023-2024 */

	vahtulo = &tyotulo;

	IF vahtulo < &AnsRaja1 THEN &tulos = 0;

	ELSE IF vahtulo >= &AnsRaja1 THEN &tulos = &AnsPros1 * (vahtulo - &AnsRaja1);

	IF vahtulo >= &AnsRaja2 THEN &tulos = &AnsPros1 * (&AnsRaja2 - &AnsRaja1) + &AnsPros2 * (vahtulo -  &AnsRaja2);

	IF &tulos > &AnsEnimm THEN &tulos = &AnsEnimm;

	verttulo = &puhdanstulo;

	IF verttulo > &AnsRaja3 THEN &tulos = &tulos - &AnsPros3 * (verttulo -  &AnsRaja3);

	IF &tulos < 0 THEN &tulos = 0;

	IF &tulos > verttulo THEN &tulos = verttulo;

	DROP vahtulo verttulo;


%MEND AnsVahS;


/* 64. El‰ketulov‰hennys 

Makron parametrit:
    tulos: Makron tulosmuuttuja, El‰ketulov‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	elaketulo: El‰ketulo
	puhdansiotulo: Puhdas ansiotulo */


%MACRO ElTulVahS (tulos, mvuosi, minf, elaketulo, puhdansiotulo)/
DES = 'VERO:El‰ketulov‰hennys';

%HAKU;

/* Yhdistetty el‰ketulov‰hennys voimassa vuodesta 2023 l‰htien, ei en‰‰ erillisist‰ laskentaa valtionverotuksessa ja kunnallisessa verotuksessa */

	taysivah = &ElKerr * &KelaYks;

	%pyoristys10e(utaysivah, taysivah);

	tulo = &puhdansiotulo;

	/* V‰hennyst‰ pienennet‰‰n */

	IF tulo > utaysivah AND tulo <= &ElRaja THEN utaysivah = utaysivah - &ElPros * (tulo - utaysivah);

	IF tulo > &ElRaja THEN utaysivah = utaysivah - &ElPros * (&ElRaja - utaysivah)- &ElPros2 * (tulo - &ElRaja);

	IF utaysivah < 0 THEN utaysivah = 0;

	/* V‰hennys ei voi olla el‰ketuloa suurempi */

	vah = utaysivah;

	IF vah > &elaketulo THEN vah = &elaketulo;

	&tulos = vah;

	DROP tulo taysivah utaysivah vah;


%MEND ElTulVahS;

/* 65. Perusv‰hennys 

Makron parametrit:
    tulos: Makron tulosmuuttuja, Perusv‰hennys
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	vertuloA: Verotettava tulo ennen perusv‰hennyst‰ */	

%MACRO PerVahS(tulos, mvuosi, minf, vertuloA)/
DES = 'VERO: Perusv‰hennys';

%HAKU;

/* Yhdistetty perusv‰hennys voimassa vuodesta 2023 l‰htien */

IF &vertuloA <= &PerEnimm THEN &tulos = &vertuloA;

ELSE &tulos =  &PerEnimm - &PerPros * (&vertuloA - &PerEnimm);

IF &tulos < 0 THEN &tulos = 0;

%MEND PerVahS;