/*******************************************************************
*  Kuvaus: Tuloverotuksen lainsäädäntöä makroina                   *
*******************************************************************/

/* SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/* 
1. TulonHankVahS = Tulonhankkimisvähennys
2. TyoMatkaVahS = Työmatkakuluvähennys
3. AsuntoVahennysS = Asuntovähennys (ns. kakkosasunnon verovähennys)
4. TulonHankKulutS = Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys yhdistettynä
5. TyoelMaksuS = Palkansaajan työeläkemaksu
6. TyotMaksuS = Palkansaajan työttömyysvakuutusmaksu
7. SvPRahaMaksuS = Sairausvakuutuksen päivärahamaksu, perusversio
8. SvPRahaMaksuYS = Sairausvakuutuksen päivärahamaksu, yritystulon korotettu maksu huomioon otettuna
9. KunnAnsVahS = Kunnallisverotuksen ansiotulovähennys
10. KunnElTulVahS = Kunnallisverotuksen eläketulovähennys
11. KunnOpRahVahS = Kunnallisverotuksen opintorahavähennys
12. KunnVerInvVahS = Kunnallisverotuksen invalidivähennys
13. KunnPerVahS = Kunnallisverotuksen perusvähennys
14. SairVakMaksuS = Sairausvakuutusmaksu, lyhennetty kaava
15. KanselVakMaksuS = Kansaneläkevakuutusmaksu, lyhennetty kaava
16. KunnVeroS = Kunnallisvero: joko keskimääräinen tai valittu veroprosentti
17. KirkVeroS = Kirkollisvero: joko keskimääräinen tai valittu veroprosentti
18. ValtTyoTuloVahS = Valtionverotuksen työtulovähennys
19. ValtElTulVahS = Valtionverotuksen eläketulovähennys
20. ValtVerAnsVahS = Valtionverotuksen ansiotulovähennys/työtulovähennys (vähennys verosta)
21. ValtVerInvVahS = Valtionverotuksen invalidivähennys (vähennys verosta)
22. ValtVerElVelvVahS = Valtionverotuksen elatusvelvollisuusvähennys (vähennys verosta)
23. ValtTuloVeroS = Valtion tulovero (veroasteikko)
24. TuloVerot_SimpleS = Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa
25. TuloVerot_SimpleMargS = Marginaaliveroaste palkkaverotuksen yksinkertaisessa perustapauksessa
26. BruttotuloS = Nettokuukausitulosta johdettu bruttotulo palkansaajalla
27. TuloVerot_Simple_ElakeS = Eläketulon verot yksinkertaisessa perustapauksessa
28. TuloVerot_Simple_PRahaS = Päivärahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa
29. PomaOsuusS = Jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus
30. OsinkojenJakoS  = Osinkotulojen jakaminen pääomatuloksi, ansiotuloiksi ja verottomiksi tuloksi
31. AlijHyvS = Alijäämähyvitys
32. AlijHyvKotitS = Alijäämähyvitys kotitaloustasolla
33. AlijHyvEritS = Erityinen alijäämähyvitys
34. YhtHyvS = Yhtiöveron hyvitys
35. VahAsKorotS = Vähennyskelpoiset asuntolainan korot
36. POTulonVeroEritS = Pääomatulon vero, vapaaeht. eläkevakuutusmaksut huomioon otettuna
37. KotiTalVahS = Kotitalousvähennys
38. VahennJakoS = Vähennysten jakaminen eri verolajeille
39. AlijHyvJakoS = Alijäämähyvityksen jakaminen eri verolajeille
40. YhtHyvJakoS = Yhtiöveron hyvityksen jakaminen eri verolajeille
41. ValtLapsVahS = Valtionverotuksen lapsenhoitovähennys (nimenä myös ylimääräinen työtulovähennys)
42. KunnLapsVahS = Kunnallisverotuksen lapsenhoitovähennys (huom! sisältää myös yksinhuoltajavähennyksen) 
43. KunnYksVahS = Kunnallisverotuksen yksinhuoltajavähennys
44. VarallVeroS = Varallisuusvero
45. KunnElTulVahMaxS = Kunnallisverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys
46. ValtElTulVahMaxS = Valtionverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys
47. ElVeroRajaS = Raja, josta eläketulon verotus alkaa
48. ValtVerRajaS =  Valtion tuloverotuksen alaraja
49. KunnVerRajaS = Kunnan tuloverotuksen alaraja
50. YleVeroS = YLE-vero
51. ValtVero_Final = Valtionvero kun verotuksen kattosäännös otetaan huomioon
52. ElakeLisaVero = Eläketulon lisävero
53. ValtVerLapsVah = Lapsivähennys
54. KunnVerMeriVahS = Kunnallisverotuksen merityötulovähennys
55. ValtVerMeriVahS = Valtionverotuksen merityötulovähennys
56. TuloVerot_Simple_PRahTyoS = Tuloverot yksinkertaisessa perustapauksessa, jossa päiväraha ja palkkatuloja
57. KotitVahErillS = Kotitalousvähennyksen lisädatan laskentamakro
58. KotitVahErillJakoS = Kotitalousvähennyksen lisädatan laskentamakro työn lajeittain
59. YrittajaVahS = Yrittäjävähennys
60. KunnVerKerroin = Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen veroprosentin muuntamiseen tarvittavat kertoimet
61. VahennysSwap = Makro, jonka avulla vähennyksiä siirretään puolisoiden kesken
61. VerMeriVahS = Merityötulovähennys (Sotemuutokset, 2023 alkaen)
62. OpRahVahS = Opintorahavähennys (Sotemuutokset, 2023 alkaen)
63. AnsVahS = Ansiotulovähennys (Sotemuutokset, 2023 alkaen)
64. ElTulVahS = Eläketulovähennys (Sotemuutokset, 2023 alkaen)
65. PerVahS = Perusvähennys (Sotemuutokset, 2023 alkaen)
66. ValtVerTyotVahS_2023 = Valtionverotuksen työtulovähennys (Sotemuutokset, 2023 alkaen)
67. ValtTuloVeroS_sote =  Valtion tulovero (sotemuutosten poikkeustapauksia varten)

*/

/* 1. Tulonhankkimisvähennys. 
	  Tuottaa palkkatuloista automaattisen vähennyksen. 
      Jos tulonhankkimiskulut ovat suurempia kuin automaattinen vähennys, 
      edelliset määrittelevät vähennyksen suuruuden */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonhankkimisvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut;

%MACRO TulonHankVahS(tulos, mvuosi, minf, palkkatulo, tulonhankkulut)/
DES = 'VERO: Tulonhankkimisvähennys';

%HAKU;

&tulos = &TulonHankkAlaRaja + &TulonHankPros * &palkkatulo;

IF &tulos > &TulonHankk THEN &tulos = &TulonHankk;

IF &tulos > &palkkatulo THEN &tulos = &palkkatulo;

IF &tulonhankkulut> &tulos THEN &tulos = &tulonhankkulut;
	
%MEND TulonHankVahS;


/* 2. Työmatkakuluvähennys.
	  Vähennyksessä otetaan huomioon alennettu omavastuu työttömille, joka
	  on ollut parametreissa vuodesta 1999 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Työmatkakuluvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tyomatkakulut: Ilmoitetut työmatkakulut
	tyotkuuk: Työttömyyskuukaudet;

%MACRO TyoMatkaVahS(tulos, mvuosi, minf, tyomatkakulut, tyotkuuk)/
DES = 'VERO: Työmatkakuluvähennys';

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


/* 3. Asuntovähennys (ns. kakkosasunnon vähennys).
      Parametreissa vuodesta 2008 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Asuntovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kuukausia: Kakkosasunnon käyttökuukausien lukumäärä
	vuokra: Vähennykseen ilmoitettu vuokra;

%MACRO AsuntoVahennysS(tulos, mvuosi, minf, kuukausia, vuokra)/
DES = 'VERO: Asuntovähennys (ns. kakkosasunnon verovähennys)';

%HAKU;

IF &mvuosi < 2008 THEN &tulos = 0;

ELSE DO; 

	IF &vuokra > &TyoAsVah THEN &tulos = &kuukausia * &TyoAsVah;

	ELSE &tulos = &kuukausia * &vuokra;

END;

%MEND AsuntoVahennysS;


/* 4. Yhdistetty vähennys: tulonhannkimisvähennys, työmatkavähennys ja ay-jäsenmaksut.
	  Kaava ottaa huomioon sen, että nykyisin nämä vähennykset ovat itsenäisiä kun
	  taas aikaisemmin ne olivat osittain toisiinsa kytkettyjä */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	anstulo: Ansiotulot
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut
	aymaksut: Työmarkkinajärjestön vähennyskelpoiset jäsenmaksut
	tyomatkakulut: Ilmoitetut työmatkakulut
	tyotkuuk: Työttömyyskuukaudet;

%MACRO TulonHankKulutS(tulos, mvuosi, minf, palkkatulo, tulhankkulut, aymaksut, tyomatkakulut, tyotkuuk)/
DES = 'VERO: Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys yhdistettynä';

%TyoMatkaVahS(tyom, &mvuosi, &minf, &tyomatkakulut, &tyotkuuk);

IF &mvuosi < 1989 THEN kulut = &tulhankkulut + tyom;

ELSE IF &mvuosi >= 1989 THEN kulut = &tulhankkulut;

%TulonHankVahS(tulvah, &mvuosi, &minf, &palkkatulo, kulut);

IF &mvuosi < 1989 THEN &tulos = tulvah + &aymaksut;

IF &mvuosi >= 1989 THEN &tulos = tyom + tulvah + &aymaksut;

DROP tyom kulut tulvah;

%MEND TulonHankKulutS;


/* 5. Palkansaajan työeläkemaksu */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan työeläkemaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ika: Henkilön ikä
	palkkatulo: Palkkatulo;

%MACRO TyoelMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Palkansaajan työeläkemaksu';

%HAKU;

* Ei maksua ennen vuotta 1993 eikä henkilölle, jonka ikä alittaa alarajan tai ylittää ylärajan;
IF &mvuosi < 1993 OR &ika < &ElVakAlaIkaRaja OR &ika > &ElVakYlaIkaRaja THEN &tulos = 0;

* Vuodesta 2005 lähtien korotettu maksu siihen velvoitetuille;
ELSE IF &mvuosi >= 2005 AND &ika >= &KorElVakAlaIkaRaja AND &ika <= &KorElVakYlaIkaRaja THEN &tulos = &KorElVakMaksu * &palkkatulo;

* Muissa tapauksissa lasketaan normaali maksu;
ELSE &tulos = &ElVakMaksu * &palkkatulo;

%MEND TyoelMaksuS;


/* 6. Palkansaajan työttömyysvakuutusmaksu */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan työttömyysvakuutusmaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ika: Henkilön ikä
	palkkatulo: Palkkatulo;

%MACRO TyotMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Palkansaajan työttömyysvakuutusmaksu';

%HAKU;

* Ei maksua ennen vuotta 1993 eikä henkilölle, jonka ikä alittaa alarajan tai ylittää ylärajan;
IF &mvuosi < 1993 OR &ika < &TyotVakAlaIkaRaja OR &ika > &TyotVakYlaIkaRaja THEN &tulos = 0;

* Muissa tapauksissa lasketaan normaali maksu;
ELSE &tulos = &TyotVakMaksu * &palkkatulo;

%MEND TyotMaksuS;

/* 7. Sairausvakuutuksen päivärahamaksu: vain normaaleista palkka- ja työtulosta.
	  Parametreissa vuodesta 2006 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen päivärahamaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	ika: Henkilön ikä
	palkkatulo: Palkkatulo tai muu työtulo;

%MACRO SvPRahaMaksuS (tulos, mvuosi, minf, ika, palkkatulo)/
DES = 'VERO: Sairausvakuutuksen päivärahamaksu, perusversio';

%HAKU;

* Ei maksua ennen vuotta 2006 eikä henkilöille, jonka ikä alittaa alarajan tai ylittää ylärajan
eikä silloin kun tulot alittavat tulorajan;
IF &mvuosi < 2006 OR &ika < &SvPrAlaIkaRaja OR &ika > &SvPrYlaIkaRaja OR &palkkatulo < &SvPrMaksuRaja THEN &tulos = 0;

ELSE &tulos = &SvPrMaksu * &palkkatulo;

%MEND SvPRahaMaksuS;


/* 8. Sairausvakuutuksen päivärahamaksu.
	   Otetaan huomioon yritystulon korotettu maksu. 
	   (Huom! Korotettu maksu kohdistuu vain yrittäjien eläkelain mukaiseen työtuloon) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen päivärahamaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	ika: Henkilön ikä
	yrit = On yrittäjä (1/0) 
	tyotulo = Työtulo;

%MACRO SvPRahaMaksuYS (tulos, mvuosi, minf, ika, yrit, tyotulo)/
DES = 'VERO: Sairausvakuutuksen päivärahamaksu, yritystulon korotettu maksu huomioon otettuna';

%HAKU;

* Ei maksua ennen vuotta 2006 eikä henkilöille, jonka ikä alittaa alarajan tai ylittää ylärajan
eikä silloin kun tulot alittavat tulorajan;
IF &mvuosi < 2006 OR &ika < &SvPrAlaIkaRaja OR &ika > &SvPrYlaIkaRaja OR &tyotulo < &SvPrMaksuRaja THEN &tulos = 0;

ELSE &tulos = IFN(&yrit = 0, &SvPrMaksu  * &tyotulo, SUM(&SvPrMaksu, &SairVakYrit)* &tyotulo);

%MEND SvPRahaMaksuYS;


/* 9. Kunnallisverotuksen ansiotulovähennys. 
	   Parametreissa vuodesta 1991 lähtien.
	   Kaavassa otetaan huomioon tulokäsitteiden muutos */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen ansiotulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puhdanstulo: Puhdas ansiotulo
	anstulo2: Muu ansiotulo kuin eläketulo
	tyotulo: Työtulo
	palkkatulo: Palkkatulo
	kokontulo: Kokonaistulo;

%MACRO KunnAnsVahS(tulos, mvuosi, minf, puhdanstulo, anstulo2, tyotulo, palkkatulo, kokontulo)/
DES = 'VERO: Kunnallisverotuksen ansiotulovähennys';

%HAKU;

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


/* 10. Kunnallisverotuksen eläketulovähennys.
	   Parametreissa vuodesta 1983 lähtien.
	   Kaavassa otetaan huomioon tulokäsitteiden muutos. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen eläketulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	oikeusyksi96: On ollut oikeus yksinäisen vähennykseen, vaikka puoliso vuonna 1996 (1/0)
	elaketulo: Eläketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO KunnElTulVahS (tulos, mvuosi, minf, puoliso, oikeusyks96, elaketulo, puhdansiotulo, kokontulo)/
DES = 'VERO: Kunnallisverotuksen eläketulovähennys';

%HAKU;

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

/* Erilaiset tulokäsitteet ennen ja jälkeen vuoden 1993 uudistuksen */
iF &mvuosi >=  1993 THEN tulo = &puhdansiotulo;

ELSE IF &mvuosi < 1993 THEN tulo = &kokontulo;

/* Vähennystä pienennetään eri tavoin ennen vuotta 1989 ja v:sta 1989 lähtien */
IF (&mvuosi < 1989) THEN DO;

	IF tulo > (2 * perusvah + utaysivah) THEN utaysivah = utaysivah - (tulo - 2 * perusvah - utaysivah);

END;

ELSE IF (&mvuosi >= 1989) THEN DO;

	IF tulo > utaysivah THEN utaysivah = utaysivah - &KunnElPros * (tulo - utaysivah);

END;

IF (utaysivah < 0) OR (&mvuosi < 1983) THEN utaysivah = 0;

/* Vähennys ei voi olla eläketuloa suurempi */

vah = utaysivah;

IF vah > &elaketulo THEN vah = &elaketulo;

IF &elaketulo > 0 THEN vah = vah + &KunnVanhVah;

&tulos = vah;

DROP perusvah tulo taysivah utaysivah vah;

%MEND KunnElTulVahS;


/* 11. Kunnallisverotuksen opintorahavähennys.
	   Huom! Jos opisk-muuttuja <> 0, laskee opiskelijavähennyksen ennen vuotta 1993 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen opintorahavähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	opisk: On opiskelija (1/0)
	opraha: Opintoraha (veronalainen opintukilain mukainen opintoraha)
	anstulo: Ansiotulo
	puhdanstulo: Puhdas ansiotulo;

%MACRO KunnOpRahVahS (tulos, mvuosi, minf, opisk, opraha, anstulo, puhdanstulo)/
DES = 'VERO: Kunnallisverotuksen opintorahavähennys';

%HAKU;

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


/* 12. Kunnallisverotuksen invalidivähennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen invalidivähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	oikeus_1982: Oikeus eläketulosta tehtyyn invalidivähennykseen vuonna 1982 (1/0)
	invpros: Invaliditeettiprosentti eli haitta-aste (kokonaislukuna 0-100)
	puhdanstulo: Puhdas ansiotulo
	elaketulo: Eläketulo;

%MACRO KunnVerInvVahS(tulos, mvuosi, minf, oikeus_1982, invpros, puhdanstulo, elaketulo)/
DES = 'VERO: Kunnallisverotuksen invalidivähennys';

%HAKU;

IF &invpros < 30 THEN &TULOS = 0;

ELSE DO;
	vah = 0.01 * &invpros *  &KunnInvVah;

	*Vuodesta 1983 lähtien vähennys vain muusta ansiotulosta kuin eläketulosta.
	 Siirtymäsäännös otettiin käyttöön 1984: vähennys myös eläketulosta, jos oikeus vähennykseen vuonna 1982;
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


/* 13. Kunnallisverotuksen perusvähennys */	

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen perusvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kunnvertuloA: Kunnallisverotuksessa verotettava tulo ennen perusvähennystä;

%MACRO KunnPerVahS(tulos, mvuosi, minf, kunnvertuloA)/
DES = 'VERO: Kunnallisverotuksen perusvähennys';

%HAKU;

IF &kunnvertuloA <= &KunnPerEnimm THEN &tulos = &kunnvertuloA;

ELSE &tulos =  &KunnPerEnimm - &KunnPerPros * (&kunnvertuloA - &KunnPerEnimm);

IF &tulos < 0 THEN &tulos = 0;

%MEND KunnPerVahS;


/* 14. Sairausvakuutusmaksu.
	   Makro ottaa huomioon 1990- ja 2000-luvun korotetut maksut sekä
	   muusta kuin työtulosta perittävät korotetut maksut 2006- */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutusmaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: Eläketulo
	prahamtulo: Sair.vak. päivärahamaksun perusteena oleva tulo;

%MACRO SairVakMaksuS(tulos, mvuosi, minf, kunnvertulo, elaketulo, prahamtulo)/
DES = 'VERO: Sairausvakuutusmaksu, lyhennetty kaava';

%HAKU;

&tulos = &SvPros * &kunnvertulo;

*Sairausvakuutusmaksun korotus, parametrien mukaan ollut voimassa 1991-1998;

IF &kunnvertulo >  &KorSvMaksuRaja 
THEN &tulos = (&SvPros + &SvKorotus) * (&kunnvertulo - &KorSvMaksuRaja) + &SvPros * &KorSvMaksuRaja;

*Eläketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-2002.
 Huom! Samaa parametria &ElKorSvMaksu käytetään eri tarkoitukseen vuodesta 2006 lähtien;

elkor = 0;

IF &mvuosi < 2006 THEN DO;

	IF &kunnvertulo > &elaketulo THEN elkor = &ElKorSvMaksu * &elaketulo;
	ELSE elkor = &ElKorSvMaksu * &kunnvertulo;

END;

*Muusta kuin työtulosta perittävä korotettu maksu;

IF (&mvuosi > 2005) THEN DO;

	IF &kunnvertulo > &prahamtulo THEN elkor = &ElKorSvMaksu * (&kunnvertulo - &prahamtulo);

END;

&tulos = &tulos + elkor;

DROP elkor;

%MEND SairVakMaksuS;


/* 15. Kansaneläkevakuutusmaksu.
	   Huom! Poistunut lainsäädännnöstä ja parametreista vuonna 1996. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kansaneläkevakuutusmaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: Eläketulo;

%MACRO KanselVakMaksuS (tulos, mvuosi, minf, kunnvertulo, elaketulo)/
DES = 'VERO: Kansaneläkevakuutusmaksu, lyhennetty kaava';

%HAKU;

*Eläketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-1995;

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
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	keskimm: Käytetäänkö keskimääräistä veroprosenttia (1/0)
	kunnpros: Kunnallisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KunnVeroS(tulos, mvuosi, minf, keskimm, kunnpros, kunnvertulo)/
DES = 'VERO: Kunnallisvero: joko keskimääräinen tai valittu veroprosentti';

%HAKU;

IF &keskimm = 0 THEN &tulos = 0.01 * &kunnpros * &kunnvertulo;

ELSE &tulos = &KeskKunnPros * 0.01 * &kunnvertulo;

%MEND KunnVeroS;


/* 17. Kirkollisvero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kirkollisvero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	keskimm: Käytetäänkö keskimääräistä veroprosenttia (1/0)
	kirkpros: Kirkollisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KirkVeroS(tulos, mvuosi, minf, keskimm, kirkpros, kunnvertulo)/
DES = 'VERO: Kirkollisvero: joko keskimääräinen tai valittu veroprosentti';

%HAKU;

IF &keskimm = 0 THEN &tulos = 0.01 * &kirkpros * &kunnvertulo;

ELSE &tulos = &KirkVeroPros * 0.01 * &kunnvertulo;

%MEND KirkVeroS;


/* 18. Valtion verotuksen työtulovähennys.
	   Makro laskee myös palkkavähennyksen.
	   Huom! Poistunut vähennys, lainsäädännössä vuoteen 1988 asti. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen työtulovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ansiotulo: Ansiotulo
	palkkatulo: Palkkatulo;

%MACRO ValtTyoTuloVahS(tulos, mvuosi, minf, ansiotulo, palkkatulo)/
DES = 'VERO: Valtionverotuksen työtulovähennys';

%HAKU;

temp = &ValtTyotVahPros * &ansiotulo;

IF temp > &ValtTyotVahYlaRaja THEN temp = &ValtTyotVahYlaRaja;

temp2 = &PalkVahPros * &palkkatulo;

IF temp2 > &PalkVahYlaRaja THEN temp2 = &PalkVahYlaRaja;

&tulos = temp + temp2;

DROP temp temp2;

%MEND ValtTyoTuloVahS;

/* 19. Valtionverotuksen eläketulovähennys.
	   Lainsäädännössä ja parametreissa vuodesta 1983 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen eläketulovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	elaketulo: Eläketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO ValtElTulVahS(tulos, mvuosi, minf, elaketulo, puhdansiotulo, kokontulo)/
DES = 'VERO: Valtionverotuksen eläketulovähennys';

%HAKU;

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


/* 20. Valtionverotuksen ansiotulovähennys/työtulovähennys.
	   Huom! Verosta tehtävä vähennys.
	   Lainsäädännössä vuodesta 2006 lähtien. Vähennyksen nimeä muutettu tuloverolaissa. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen ansiotulovähennys/työtulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tyotulo: Työtulo
	puhdanstulo: Puhdas ansiotulo;

%MACRO ValtVerAnsVahS(tulos, mvuosi, minf, tyotulo, puhdanstulo)/
DES = 'VERO: Valtionverotuksen ansiotulovähennys/työtulovähennys (vähennys verosta)';

%HAKU;

&tulos = 0;

IF &tyotulo > &ValtAnsAlaRaja THEN &tulos = &ValtAnsPros1 * (&tyotulo -  &ValtAnsAlaRaja);

IF &tulos > &ValtAnsEnimm THEN &tulos = &ValtAnsEnimm;

IF &puhdanstulo > &ValtAnsYlaRaja THEN &tulos = &tulos - &ValtAnsPros2 * (&puhdanstulo - &ValtAnsYlaRaja);

IF &tulos < 0 THEN &tulos = 0;

%MEND ValtVerAnsVahS;


/* 21. Valtionverotuksen invalidivähennys.
	   Huom! Verosta tehtävä vähennys.
	   Makro laskee myös laissa ennen vuotta 1983 olleen vanhuusvähennyksen, jos elaketulo > 0 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen invalidivähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	invpros: Invaliditeettiprosentti eli haitta-aste, kokonaislukuna 0 - 100
	elaketulo: Eläketulo;

%MACRO ValtVerInvVahS(tulos, mvuosi, minf, invpros, elaketulo)/
DES = 'VERO: Valtionverotuksen invalidivähennys (vähennys verosta)';

%HAKU;

IF &invpros < 30 THEN &tulos = 0;

ELSE &tulos = 0.01 * &invpros * &ValtInvVah;

IF &elaketulo > 0 THEN &tulos = &tulos + &ValtVanhVah;

%MEND ValtVerInvVahS;


/* 22. Valtionverotuksen elatusvelvollisuusvähennys.
	   Huom! Verosta tehtävä vähennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen elatusvelvollisuusvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	evlapsia: Elatusvelvollisten lasten lukumäärä
	elmaksut: Elatusmaksut;

%MACRO ValtVerElVelvVahS(tulos, mvuosi, minf, evlapsia, elmaksut)/
DES = 'VERO: Valtionverotuksen elatusvelvollisuusvähennys (vähennys verosta)';

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
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tulo = Valtion verotuksessa verotettava tulo eli tulo vähennysten jälkeen 
	      (vuodesta 1993 lähtien koskee vain ansiotuloa)
	ahv= 1 , jos korjataan verotusta Ahvenanmaalle, muulloin 0;
	

%MACRO ValtTuloVeroS(tulos, mvuosi, minf, tulo)/
DES = 'VERO: Valtion tulovero (veroasteikko)';

%HAKU;

IF &tulo <= 0 THEN &tulos = 0;

ELSE DO;
		IF &tulo GE  &Raja12 THEN
			&tulos =  &Vakio12 + &Pros12 * (&tulo -  &Raja12);

		ELSE IF &tulo GE  &Raja11 THEN
			&tulos =  &Vakio11 + &Pros11 * (&tulo -  &Raja11);

		ELSE IF &tulo GE  &Raja10 THEN
			&tulos =  &Vakio10 + &Pros10 * (&tulo -  &Raja10);

		ELSE IF &tulo GE  &Raja9 THEN
			&tulos =  &Vakio9 + &Pros9 * (&tulo -  &Raja9);

		ELSE IF &tulo GE  &Raja8 THEN
			&tulos =  &Vakio8 + &Pros8 * (&tulo -  &Raja8);

		ELSE IF &tulo GE  &Raja7 THEN
			&tulos =  &Vakio7 + &Pros7 * (&tulo -  &Raja7);

		ELSE IF &tulo GE  &Raja6 THEN
			&tulos =  &Vakio6 + &Pros6 * (&tulo -  &Raja6);

		ELSE IF &tulo GE  &Raja5 THEN
			&tulos =  &Vakio5 + &Pros5 * (&tulo -  &Raja5);

		ELSE IF &tulo GE  &Raja4 THEN
			&tulos =  &Vakio4 + &Pros4 * (&tulo -  &Raja4);

		ELSE IF &tulo GE  &Raja3 THEN
			&tulos =  &Vakio3 + &Pros3 * (&tulo -  &Raja3);

		ELSE IF &tulo GE  &Raja2 THEN
			&tulos =  &Vakio2 + &Pros2 * (&tulo -  &Raja2);

		ELSE IF &tulo GE  &Raja1 THEN
			&tulos =  &Vakio1 + &Pros1 * (&tulo -  &Raja1);
END;

%MEND ValtTuloVeroS;


/* 24. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat vain palkkatuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tuloverot
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	palkkatulo: Palkkatulo;

%MACRO TuloVerot_SimpleS(tulos, mvuosi, minf, palkkatulo, ika)/
DES = 'VERO: Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa';
 
%TulonHankKulutS(tulhanksums2, &mvuosi, &minf, &palkkatulo, 0, 0, 0, 0);

puhdanstulos2 = &palkkatulo - tulhanksums2;

IF puhdanstulos2 < 0 THEN puhdanstulos2 = 0;

%TyoElMaksuS (elmaksus2, &mvuosi, &minf, 30, &palkkatulo);

%TyotMaksuS(tyotvaks2, &mvuosi, &minf, 30, &palkkatulo);

%SvPrahaMaksuS(spmaksus2, &mvuosi, &minf, 30, &palkkatulo);

 ************************************************************************************************************************************************************;
 * Makro haarautuu kahteen osaan, joista ensimmäisessä otetaan käyttöön sotemuutokset (vuodesta 2023 eteenpäin) ja toisessa noudatetaan vanhaa lainsäädäntöä*; 
 ************************************************************************************************************************************************************;
%IF &mvuosi>=2023 %THEN %DO; 
	******************************************************************;
	* Tässä otetaan huomioon sote-uudistuksen aiheuttamat muutokset  *;
	******************************************************************;

	%AnsVahS(anss2, &mvuosi, &minf, puhdanstulos2, &palkkatulo);

	vtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - anss2;

	IF vtuloAs2 < 0 THEN vtuloAs2 = 0;

	%PerVahS (pervahs2, &mvuosi, &minf, vtuloAs2);

	vertulos2 = vtuloAs2 - pervahs2;

	%SairVakMaksuS(svmaksus2, &mvuosi, &minf, vertulos2, 0, &palkkatulo);

	%KansElVakMaksuS(kevmaksus2, &mvuosi, &minf, vertulos2, 0);

	%KunnVeroS(kunnveros2, &mvuosi, &minf, 1, 18, vertulos2);
	
	IF vertulos2 < 0 THEN vertulos2 = 0;

	%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, vertulos2);

	%ValtVerTyotVahS_2023(valtansvahss2, &mvuosi, &minf,  &palkkatulo, puhdanstulos2, &ika);

	valttuloveros2 = valttuloveros2 - valtansvahss2;

	%YleVeroS(ylevero2, &mvuosi, &minf, 18, puhdanstulos2, 0); 

	&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + ylevero2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

	DROP tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 anss2 vtuloAs2 pervahs2
		 vertulos2 svmaksus2 kevmaksus2 kunnveros2 valttuloveros2 valtansvahss2 
		 ylevero2;
%END;
%ELSE %DO;
	********************************************************************************************************;
	* Tässä ei oteta huomioon sote-uudistuksen aiheuttamia muutoksia eli noudatetaan vanhaa lainsäädäntöä  *;
	********************************************************************************************************;	

	%KunnAnsVahS(kunnanss2, &mvuosi, &minf, puhdanstulos2, &palkkatulo, &palkkatulo, &palkkatulo, &palkkatulo);

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

	%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2);

	%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  &palkkatulo, puhdanstulos2);

	valttuloveros2 = valttuloveros2 - valtansvahss2;

	%YleVeroS(ylevero2, &mvuosi, &minf, 18, puhdanstulos2, 0); 

	&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + ylevero2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

	DROP tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 kunnanss2 kunnvtuloAs2 pervahs2
		 kunnvertulos2 svmaksus2 kevmaksus2 kunnveros2 valttvahs2 valtvertulos2 valttuloveros2 valtansvahss2 
		 ylevero2;
%END;

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

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2);

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

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulo);

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
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
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
	   kun tulo on palkkatuloa ja erityisiä vähennyksiä ei ole */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Bruttotulo, e/kk
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
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


/* 27. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat pelkästään eläketuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Eläketulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	elaketulo: Eläketulo;

%MACRO TuloVerot_Simple_ElakeS(tulos, mvuosi, minf, puoliso, elaketulo)/ 
DES = 'VERO: Eläketulon verot yksinkertaisessa perustapauksessa';

************************************************************************************************************************************************************;
 * Makro haarautuu kahteen osaan, joista ensimmäisessä otetaan käyttöön sotemuutokset (vuodesta 2023 eteenpäin) ja toisessa noudatetaan vanhaa lainsäädäntöä*; 
 ************************************************************************************************************************************************************;
%IF &mvuosi>=2023 %THEN %DO; 
	******************************************************************;
	* Tässä otetaan huomioon sote-uudistuksen aiheuttamat muutokset  *;
	******************************************************************;

	%ElTulVahS (elvah, &mvuosi, &minf, 0, &elaketulo);

	%PerVahS (pervahse, &mvuosi, &minf, MAX(&elaketulo - elvahk, 0));

	vertuloe = &elaketulo - elvah - pervahse;

	IF vertuloe < 0 THEN vertuloe = 0;

	%SairVakMaksuS(svmaksuse, &mvuosi, &minf, vertuloe, &elaketulo, 0);

	%KansElVakMaksuS(kevmaksuse, &mvuosi, &minf, vertuloe, &elaketulo);

	%KunnVeroS(kunnverose, &mvuosi, &minf, 1, 18, vertuloe);

	%ValtTuloVeroS(valttuloverose, &mvuosi, &minf, vertuloe);

	%ElakeLisaVeroS(elakelvero, &mvuosi, &minf, &elaketulo, elvah);

	%YleVeroS(yleveroe, &mvuosi, &minf, 18, &elaketulo, 0); 

	&tulos = svmaksuse + kevmaksuse + kunnverose + valttuloverose + elakelvero + yleveroe; 

	DROP elvahk pervahse vertuloe svmaksuse kevmaksuse kunnverose  
		  valttuloverose elakelvero yleveroe;

%END;
%ELSE %DO;
	********************************************************************************************************;
	* Tässä ei oteta huomioon sote-uudistuksen aiheuttamia muutoksia eli noudatetaan vanhaa lainsäädäntöä  *;
	********************************************************************************************************;	
	%KunnElTulVahS (elvahk, &mvuosi, &minf, &puoliso, 0, &elaketulo, &elaketulo, &elaketulo);

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

	%ValtTuloVeroS(valttuloverose, &mvuosi, &minf, valtvertuloE);

	%ElakeLisaVeroS(elakelvero, &mvuosi, &minf, &elaketulo, valtelvahse);

	%YleVeroS(yleveroe, &mvuosi, &minf, 18, &elaketulo, 0); 

	&tulos = svmaksuse + kevmaksuse + kunnverose + valttuloverose + elakelvero + yleveroe; 

	DROP elvahk pervahse kunnvertuloe svmaksuse kevmaksuse kunnverose valttvahse 
		 valtelvahse valtvertuloE valttuloverose elakelvero yleveroe;
%END;

%MEND TuloVerot_Simple_ElakeS;


/* 28. Tuloverot yksinkertaisessa perustapauksessa, kun tulot
	   ovat pelkästään työttömyysturvaa tai muuta vastaavaa sosiaalietuutta (ei työtuloa eikä eläkettä) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Päivärahatulon tai muun ansiotulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	prahatulo: Päivärahatulo, esim. työttömyysturva;

%MACRO TuloVerot_Simple_PRahaS(tulos, mvuosi, minf, prahatulo)/
DES = 'VERO: Päivärahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa';

************************************************************************************************************************************************************;
 * Makro haarautuu kahteen osaan, joista ensimmäisessä otetaan käyttöön sotemuutokset (vuodesta 2023 eteenpäin) ja toisessa noudatetaan vanhaa lainsäädäntöä*; 
 ************************************************************************************************************************************************************;
%IF &mvuosi>=2023 %THEN %DO; 
	******************************************************************;
	* Tässä otetaan huomioon sote-uudistuksen aiheuttamat muutokset  *;
	******************************************************************;
	%AnsVahS(anss, &mvuosi, &minf, &prahatulo, &prahatulo);

	%PerVahS (pervahsp, &mvuosi, &minf, MAX(&prahatulo - anss,0));

	vertulop = &prahatulo - anss - pervahsp;

	IF vertulop < 0 THEN vertulop = 0;

	%SairVakMaksuS(svmaksusp, &mvuosi, &minf, vertulop, 0, 0);

	%KansElVakMaksuS(kevmaksusp, &mvuosi, &minf, vertulop, 0);

	%KunnVeroS(kunnverosp, &mvuosi, &minf, 1, 18, vertulop);

	%ValtTuloVeroS(valttuloverosp, &mvuosi, &minf, vertulop);

	%YleVeroS(yleverosp, &mvuosi, &minf, 18, &prahatulo, 0); 

	&tulos = svmaksusp + kevmaksusp + kunnverosp + valttuloverosp + yleverosp; 

	DROP anss pervahsp vertulop svmaksusp kevmaksusp kunnverosp  
	 valttuloverosp yleverosp; 
%END;
%ELSE %DO;
	********************************************************************************************************;
	* Tässä ei oteta huomioon sote-uudistuksen aiheuttamia muutoksia eli noudatetaan vanhaa lainsäädäntöä  *;
	********************************************************************************************************;	

	%KunnAnsVahS(kunnanss, &mvuosi, &minf, &prahatulo, &prahatulo, 0, 0, &prahatulo);

	%KunnPerVahS (pervahsp, &mvuosi, &minf, MAX(&prahatulo - kunnanss,0));

	kunnvertulop = &prahatulo - kunnanss - pervahsp;

	IF kunnvertulop < 0 THEN kunnvertulop = 0;

	%SairVakMaksuS(svmaksusp, &mvuosi, &minf, kunnvertulop, 0, 0);

	%KansElVakMaksuS(kevmaksusp, &mvuosi, &minf, kunnvertulop, 0);

	%KunnVeroS(kunnverosp, &mvuosi, &minf, 1, 18, kunnvertulop);

	%ValtTyoTuloVahS(valttvahsp, &mvuosi, &minf, &prahatulo, 0);

	valtvertulop = &prahatulo - valttvahsp;

	IF valtvertulop < 0 THEN valtvertulop = 0;

	%ValtTuloVeroS(valttuloverosp, &mvuosi, &minf, valtvertulop);

	%YleVeroS(yleverosp, &mvuosi, &minf, 18, &prahatulo, 0); 

	&tulos = svmaksusp + kevmaksusp + kunnverosp + valttuloverosp + yleverosp; 

	DROP kunnanss pervahsp kunnvertulop svmaksusp kevmaksusp kunnverosp valtvertulop 
		 valttuloverosp valttvahsp yleverosp; 
%END;

%MEND TuloVerot_Simple_PRahaS;


/* 29. Pääomatulo-osuus: jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai 
	   siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulo-osuus 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tulolaji: 1 = Jaettava yritystulos, 2 = osinkotulo, 3 = yhtiöveron hyvitys
	vaiht: 1/0, jos <> 0 jos on valittu vaihtoehtoinen alhaisempi pääomatulo-osuus
	tulo: Tulo, jota jaetaan eri osiin
	yritvarall: Yrityksen nettovarallisuus tai osakkeiden arvo osinkoja jaettaessa
	palkat: Palkkasumma;

%MACRO PomaOsuusS(tulos, mvuosi, minf, tulolaji, vaiht, tulo, yritvarall, palkat) /
DES = 'VERO: Jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai 
siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus';

%HAKU;

tempx = 0;

IF &tulo = 0 THEN &tulos = 0;

ELSE DO;

	SELECT (&tulolaji);

	*JAETTAVA YRITYSTULO;

	WHEN (1) DO; 

		tmposuus = &POOsuus;

		/* Voidaan valita vaihtoehtoisesti alempi pääomatulon osuus (2001 -) */
			
		IF (&vaiht NE 0) THEN tmposuus = &VaihtPOOsuus;
					
		/* Yritysvarallisuuteen lisätään osuus palkoista (1997 -) */

		varall = &yritvarall + tmposuus * &palkat;

		*Mahdollinen pääomatulon osuus tulosta;

		tempx = tmposuus * varall;

		*Pääomatulo ei voi olla koko tuloa suurempi;

		IF tempx > &tulo THEN tempx = &tulo;

		END;	
	
	*OSINKOTULO EI-JULKISESTI NOTEERATUISTA YHTIÖISTÄ;

	WHEN (2) DO; 

		*Kriteerinä on osingon ja yhtiöveron hyvityksen suhde yritysvarallisuuden
		 määriteltyyn osuuteen;
			
		%YhtHyvS(hyvit, &mvuosi, &minf, &tulo);

		summa = &tulo + hyvit;

		tempx = &OsPOOsuus * &yritvarall;

		IF tempx >= summa THEN temp = &tulo;

		ELSE tempx = tempx * &tulo / summa;
			
	END;

	*YHTIÖVERON HYVITYS;

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


/* 30. Osinkojen jako eri tulolajeihin uudessa järjestelmässä 2005- */ 

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulolajiin kuuluvan osingon määrä 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ospkorko: Onko tulo osuuspäääoman korkoa (1/0). 2015 jälkeen listatun tai listaamattoman osuuskunnan ylijäämä
	tulolaji: 1 = verovapaa, 2 = pääomatulo, 3 = ansiotulo
	julkosinko: Julkisesti noteeratusta yhtiöstä saatu osinko
	eijulkosinko: Ei julkisesti noteeratusta yhtiöstä saatu osinko tai ei julkisesti noteeratusta osuuskunnasta saatu ylijäämä
	osakkarvo: Osakkeiden arvo
;

%MACRO OsinkojenJakoS (tulos, mvuosi, minf, ospkorko, tulolaji, julkosinko, eijulkosinko, osakkarvo)/
DES = 'VERO: Osinkotulojen jakaminen pääomatuloksi, ansiotuloiksi ja verottomiksi tuloksi';

%HAKU;

temp = 0;


*Jos ei osinkoja, annetaan heti tulokseksi 0;
IF SUM(&julkosinko, &eijulkosinko) = 0 THEN &tulos = 0;

ELSE DO;

	*Lähtökohtana ei-julk. noteeratuissa yhtiöissä tietty suhde osakkeiden arvoon.
 	 Se määrittelee, miten osingot jaetaan pääoma- ja ansiotuloiksi;
	
	vert = &HenkYhtOsVapOsuus * &osakkarvo;
	
	*Jos osakkeiden arvoa ei tiedetä, voidaan muuttujalle osakkaarvo antaa
  	 negatiivinen arvo, jolloin oletetaan, että ei-julkisesti noteeratun
 	 yhtiön osinko on kokonaisuudessaan pääomatuloa (joka kuitenkin vielä jaetaan
	 verottomaksi ja veronalaiseksi tuloksi);

	IF &EiJulkOsinko > 0 AND &OsakkArvo < 0 THEN vert =&EiJulkOsinko;

	SELECT (&tulolaji);

	*VEROVAPAAT OSINGOT;

	WHEN (1) DO;

		*Ennen vuotta 2005 verovapaita osinkoja ei ole;
		IF  (&mvuosi  < 2005) THEN temp = 0; 

		ELSE DO;
			*Ensin käsitellään noteeraamattomista osakkeista maksettavat osingot;
			*Suhde kiinteään euromääräiseen rajaan ja tuottorajaan;
			IF vert > &HenkYhtVapRaja THEN DO;

				IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN
					temp = (1 - &HenkYhtPOOsuus1) * &eijulkosinko;

				IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN
					temp = (1 - &HenkYhtPOOsuus1) * &HenkYhtVapRaja + (1 - &HenkYhtPOOsuus2) * (&eijulkosinko - &HenkYhtVapRaja);

				IF &eijulkosinko > vert THEN
					temp = (1 - &HenkYhtPOOsuus1) * &HenkYhtVapRaja + (1 - &HenkYhtPOOsuus2) * (vert - &HenkYhtVapRaja) + ( 1 - &HenkYhtOsAnsOsuus) * (&eijulkosinko - vert) ;
			END;

			ELSE IF vert <= &HenkYhtVapRaja THEN temp = ( 1 - &HenkYhtPOOsuus1) * MIN(&eijulkosinko, vert) + (1 - &HenkYhtOsAnsOsuus) * MAX (&eijulkosinko - vert, 0);
				
			*Pörssiyhtiöiden osinkojen verovapaa osuus lisätään;

			IF &ospkorko = 0 THEN temp =  SUM(temp, (1 - &JulkPOOsuus) * &julkosinko);

			*Osuuspääoman korkojen verovapaa osuus lisätään;
			IF &ospkorko = 1 AND &mvuosi >= 2015 THEN DO;
				IF &eijulkosinko > 0 THEN temp = SUM((1 - &EiJulkOSPOOsuus2) * MAX(&eijulkosinko - &EiJulkOSPORaja, 0), (1 - &EiJulkOSPOOsuus1) * MIN(&eijulkosinko, &EiJulkOSPORaja));
				IF &julkosinko > 0 THEN temp = SUM((1 - &JulkOsPOOsuus) * &julkosinko, 0);
			END;
			ELSE IF &ospkorko = 1 THEN temp = SUM((1 - &OspKorkoPOOsuus) * MAX(&eijulkosinko - &OspKorVeroVap, 0), MIN(&eijulkosinko, &OspKorVerovap)) ;
		
		END;
	END;

	*PÄÄOMATULOT;

	WHEN (2) DO;

		*Lasketaan ei-julkosinkgon pääomatuloiksi laskettava osuus makron PomaOsuusS avulla;
		%PomaOsuusS(paaomaosuus, &mvuosi, &minf, 2, 0, &eijulkosinko, &osakkarvo, 0);

		*Ennen vuotta 2005 edellä laskettu osuus on pääomatuloa ja se lisätään julkisesti
		 noteerattujen yhtiöiden osinkoihin;
		IF &mvuosi < 2005 THEN &tulos = &JulkOsinko + paaomaosuus;

		ELSE DO;

			*Ensin käsitellään noteeraamattomien osakkeiden osingot samassa järjestyksessä kuin edellä;

			IF vert > &HenkYhtVapRaja THEN DO;

				IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN
					temp = &HenkYhtPOOsuus1 * &eijulkosinko;

				IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN
					temp = &HenkYhtPOOsuus1 * &HenkYhtVapRaja + &HenkYhtPOOsuus2 * (&eijulkosinko - &HenkYhtVapRaja);

				IF &eijulkosinko > vert THEN
					temp = &HenkYhtPOOsuus1 * &HenkYhtVapRaja + &HenkYhtPOOsuus2 * (vert - &HenkYhtVapRaja) ;
			END;

			ELSE IF vert <= &HenkYhtVapRaja THEN temp = &HenkYhtPOOsuus1 * MIN(&eijulkosinko, vert);

			*Lisätään pörssiyhtiöiden osinkojen verollinen osuus;

			IF &ospkorko = 0 THEN temp = SUM(temp, &JulkPOOsuus * &julkosinko);

			*Osuuspääoman korot;

			IF &ospkorko = 1 AND &mvuosi >= 2015 THEN DO;
				IF &eijulkosinko > 0 THEN temp = SUM(&EiJulkOSPOOsuus2 * MAX(&eijulkosinko - &EiJulkOSPORaja, 0), &EiJulkOSPOOsuus1 * MIN(&eijulkosinko, &EiJulkOSPORaja));
				IF &julkosinko > 0 THEN temp = SUM(&JulkOsPOOsuus * &julkosinko, 0);
			END;
			ELSE IF &ospkorko = 1 THEN temp = SUM(&OspKorkoPOOsuus * MAX(&eijulkosinko - &OspKorVeroVap, 0));
				

		 END;

	END;

	*ANSIOTULOT;
	
	WHEN (3) DO;

		*Ennen vuotta 2005 katsotaan ei-julk. noteerattujen osakkeiden osinkojen pääomatulo-osuus
		 ja vähennetään se koko osingosta;
		IF &mvuosi < 2005 THEN DO;
			%PomaOsuusS(paaomaosuus, &mvuosi, &minf, 2, 0, &eijulkosinko, &osakkarvo, 0);
			temp = &eijulkosinko - paaomaosuus;
		END;

		*Muuten katsotaan kiinteän tuottorajan ylittävästä osuudesta ansiotulojen osuus;
		IF &mvuosi > 2004 AND &eijulkosinko > vert THEN temp = &HenkYhtOsAnsOsuus * (&eijulkosinko - vert);

		ELSE temp = 0;
	END;

	OTHERWISE temp = 0;

	END;
END;

&tulos = temp;

DROP temp vert paaomaosuus;
%MEND OsinkojenJakoS;

/* 31. Alijäämähyvitys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Alijäämähyvitys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: Onko puoliso (1/0)
	lapsia: Alaikäisten lasten lukumäärä
	potulo: Veronalainen pääomatulo
	povahenn: Pääomatulon hankkimiseen liittyvät vähennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	kulkorot: Kulutusluoton korot (vaikutusta vain 1994 ja 1995)
	puolalij: Puolisolta siirtyvä alijäämähyvitys;

%MACRO AlijHyvS(tulos, mvuosi, minf, puoliso, lapsia, potulo, povahenn, askorot, ensaskorot, kulkorot, puolalij)/
DES = 'VERO: Alijäämähyvitys';

%HAKU;

vahlapsia = MIN (&lapsia, 2);

alijenimm = (&AlijYlaRaja + vahlapsia * &AlijLapsiKor);

IF (&puoliso NE 0) THEN alijenimm = alijenimm + &puolalij;

/* Kulutusluottojen korot eivät vaikuta alijäämähyvitykseen vuoden 1994 jälkeen */

kulkorotx = &KulKorot;

IF &mvuosi > 1994 THEN kulkorotx = 0;

temp = 0;

*Ei pääomatuloja;
IF &potulo = 0 THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros * (&povahenn + &AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos pääomatuloja mutta vähennykset ovat vähintään yhtä suuret;
IF &potulo > 0 AND &potulo <= &povahenn THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros * (&povahenn - &potulo + &AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos pääomatulot suuremmat kuin vähennykset mutta pienemmät tai yhtä suuret jos kulutuskorot huomioidaan;
IF (&potulo > &povahenn) AND (&potulo <= &povahenn + kulkorotx) THEN DO;

	 temp = &PaaomaVeroPros * (&povahenn + kulkorotx - &potulo);

	 IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	 temp = temp + &PaaomaVeroPros * (&AsKorkoOsuus * &askorot) + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos pääomatulot suuremmat kuin yhteenlasketut vähennykset ja kulutusluoton korot mutta pienemmät tai yhtä suuret jos huomioidaan asuntolainan korkojen vähennettävä osuus;
IF (&potulo > &povahenn + kulkorotx) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) THEN DO;

	temp = &PaaomaVeroPros *  (&povahenn + kulkorotx - &potulo +  &AsKorkoOsuus * &askorot);

	temp = temp + &EnsAsKor * (&AsKorkoOsuus * &ensaskorot);

END;

*Jos pääomatulot suuremmat kuin yhteenlasketut vähennykset, kulutusluoton korot ja asuntolainan korkojen vähennettävä osuus mutta pienemmät tai yhtä suuret jos huomioidaan ensiasunnon lainan korot; 
IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * (&askorot + &ensaskorot)) THEN DO;

	temp =  &EnsAsKor * (&AsKorkoOsuus * (&povahenn + kulkorotx + &askorot + &ensaskorot - &potulo));

END;

IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot +  &AsKorkoOsuus * &ensaskorot) THEN temp = 0;

IF temp > alijenimm THEN temp = alijenimm;

&tulos = temp;

DROP temp;

%MEND AlijHyvS;

/* 32. Alijäämähyvitys kotitaloustasolla
	   Makrossa lasketaan kotitalouden alijäämähyvitys yhteensä. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Alijäämähyvitys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: Onko puoliso (1/0)
	lapsia: Alaikäisten lasten lukumäärä
	potulo: Veronalainen pääomatulo
	povahenn: Pääomatulon hankkimiseen liittyvät vähennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	kulkorot: Kulutusluoton korot (vaikutusta vain 1994 ja 1995);

%MACRO AlijHyvKotitS(tulos, mvuosi, minf, puoliso, lapsia, potulo, povahenn, askorot, ensaskorot, kulkorot)/
DES = 'VERO: Alijäämähyvitys kotitaloustasolla';

%HAKU;

/* Oletetaan että puolisolta siirtyy maksimimäärä ja lasketaan sitten henkilötasolla */

IF (&puoliso NE 0) THEN puolisolisa = &AlijYlaRaja;
ELSE puolisolisa = 0;

%AlijHyvS(temp, &mvuosi, &minf, &puoliso, &lapsia, &potulo, &povahenn, &askorot, &ensaskorot, &kulkorot, puolisolisa);

&tulos = temp;

DROP temp puolisolisa;

%MEND AlijHyvKotitS;


/* 33. Erityinen alijäämähyvitys.
	   Lainsäädännössä vuodesta 2005 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Erityinen alijäämähyvitys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	potulo: Pääomatulot
	povahenn: Pääomatulon hankkimiseen liittyvät vähennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	elvakuutusmaksu: Pääomatulosta vähennettävät vähennyskelpoiset vapaaehtoiset eläkevakuutusmaksut;

%MACRO AlijHyvEritS (tulos, mvuosi, minf, potulo, povahenn, askorot, ensaskorot, elvakuutusmaksu)/
DES = 'VERO: Erityinen alijäämähyvitys';

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


/* 34. Yhtiöveron hyvitys.
	   Lainsäädännössä vuoteen 2004 lähtien. 
	   Huom! Makrossa oletetaan, että osingot ovat lainsäädäntövuotta edeltävältä tilivuodelta */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yhtiöveron hyvitys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	osinkotulo: Hyvitykseen oikeuttava osinkotulo;

%MACRO YhtHyvS(tulos, mvuosi, minf, osinkotulo)/
DES = 'VERO: Yhtiöveron hyvitys';

%HAKU;

&tulos = &YhtHyvPros * &osinkotulo;

IF &mvuosi = 1993 THEN &tulos = &PaaomaVeroPros * &osinkotulo / (1 - &PaaomaVeroPros);

%MEND YhtHyvS;

/* 35. Vähennyskelpoinen osuus asuntolainan koroista;

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulon vero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	asuntokorot: Asuntolainan korot

Tällä makrolla otetaan huomioon korko-oikeuden rajaus vuodesta 2012 lähtien
*/


%MACRO VahAsKorotS (tulos, mvuosi, minf, asuntokorot)/
DES = 'VERO: Vähennyskelpoiset asuntolainan korot pääomatulon verotuksessa';

%HAKU;

&tulos = &AsKorkoOsuus * &asuntokorot;

%MEND VahAsKorotS;


/* 36. Pääomatulon vero: makro joka ottaa huomioon vapaaehtoiset eläkevakuutusmaksut. 
	   Huom! Makro lisää tuloihin yhtiöveron hyvityksen. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulon vero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	osinkotulo: Osinkotulo
	muupotulo: Muu pääomastulo
	povahenn: Pääomatulosta tehtävät vähennykset (muut kuin kulutusluoton korot)
	kulkorot: Kulutusluoton korot (vaikutusta 1994 ja 1995)
	elvakuutusmaksu: Pääomatulosta vähennettävät vapaaehtoiset eläkevakuutusmaksut;

%MACRO POTulonVeroEritS (tulos, mvuosi, minf, osinkotulo, muupotulo, povahenn, kulkorot, elvakuutusmaksu)/
DES = 'VERO: Pääomatulon vero, vapaaeht. eläkevakuutusmaksut huomioon otettuna';

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


/* 37. Kotitalousvähennys
	   Huom! Makro ottaa huomioon pelkästään vähennyksen alarajan
       ja ylärajan, mutta ei vähennyksen muodostumista eri menolajeista */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kotitalousvähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kotitmeno: Kotitalousvähennykseen oikeuttavat menot;

%MACRO KotiTalVahS(tulos, mvuosi, minf, kotitmeno)/
DES = 'VERO: Kotitalousvähennys';

%HAKU;

&tulos = MAX(&kotitmeno - &KotitVahOmavast, 0);

IF &tulos > &KotitVahEnimm THEN &tulos = &KotitVahEnimm;

%MEND KotiTalVahS;


/* 38. Vähennysten jakaminen eri verolajeille:
	   Makroa voi käyttää jaettaessa kotitalousvähennystä, valtionverotuksen
	   ansiotulovähennystä ja erityistä alijäämähyvitystä eri verolajeille */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	vahennys: Vähennys, jota jaetaan
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero, 6 = po-tulon vero
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero
	potulonvero: Pääomatulon vero (jos jaetaan ansiotulovähennystä tai erityistä alijäämähyvitystä, tämä = 0);

%MACRO VahennJakoS (tulos, mvuosi, vahennys, verolaji, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero, potulonvero)/
DES = 'VERO: Vähennysten jakaminen eri verolajeille';

/* Verolajit */

valt =  &valtansvero + &potulonvero;

muutverot = &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

*Jos ei veroja, tulos on aina 0;

IF valt = 0 AND  muutverot = 0 THEN DO;
	&tulos = 0;
END;

ELSE DO;

	/* Lasketaan vähennys eri verolajeille, ensi sijassa valtion verosta 
   	   ansiotulojen valtionverolle ja pääomatulon verolle näiden verolajien suhteessa.
       Jos valtionverot eivät riitä, loppuosa muille verolajeille niiden suhteessa.
       Ennen vuotta 2001 vähennys vain valtionverosta */
	
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


/* 39. Alijäämähyvityksen jakaminen eri verolajeille;
	   Hyvityksen jakamista valtionveron ja muiden verojen kesken säätelee laissa oleva parametri */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	alijhyv: Alijäämähyvitys, jota jaetaan
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero;

%MACRO AlijHyvJakoS (tulos, mvuosi, verolaji, alijhyv, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/
DES = 'VERO: Alijäämähyvityksen jakaminen eri verolajeille';

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


/* 40. Yhtiöveron hyvityksen jakaminen eri verolajeille. 
       Huom! Lainsäädäntövuodesta riippumaton makro. */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä 
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	yhthyvans: Ansiotulo-osinkoon kohdistuva yhtiöveron hyvitys
	yhthyvpo: Pääomatulo-osinkoon kohdistuva yhtiöveron hyvitys
	valtvero: Valtionverot
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero;

%MACRO YhtHyvJakoS(tulos, verolaji, yhthyvans, yhthyvpo, valtvero, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/
DES = 'VERO: Yhtiöveron hyvityksen jakaminen eri verolajeille';

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


/* 41. Valtionverotuksen lapsenhoitovähennys (nimenä myös ylimääräinen työtulovähennys) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen lapsenhoitovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevia alaikäisiä lapsia (0/1)
		lapsia_3_7_v: 3-7-vuotiaita lapsia (0/1)
		lapsia_7_v: Alle 7-vuotiaita lapsia (0/1)
		puhdanstulo: Puhdas ansiotulo,  
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus valtionverotuksen lapsenhoitovähennyksestä;

%MACRO ValtLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, lapsia_3_7_v, lapsia_7_v, puhdanstulo, kokontulo, puolisonos)/ 
DES = 'VERO: Valtionverotuksen lapsivähennys';

%HAKU;

* Ennen vuotta 1989 vähennyksen voi saada puolisoista vain pienituloisempi ;
IF &mvuosi < 1989 AND &puoliso NE 0 AND &pientul NE 1 THEN &tulos = 0;

ELSE DO;
	* Korjataan lapsimuuttujien mahdollinen epäjohdonmukaisuus ;
	IF &lapsia_3_7_v NE 0 OR &lapsia_7_v NE 0 THEN DO;
		%LET lapsia = 1;
	END;
	IF &lapsia_3_7_v NE 0 THEN DO;
		%LET lapsia_7_v = 1;
	END;

	* Ennen vuotta 1989 alle 7-vuotiaat lapset korottavat vähennyksen enimmäismäärää ;
	IF &mvuosi < 1989 THEN DO;
		IF &lapsia_7_v NE 0 THEN vah1 = &ValtLapsiVah + &ValtLapsKorotus;
	END;

	* Ennen vuotta 1989 vähennys lasketaan puhtaasta ansiotulosta, sen jälkeen 
	  kokonaistulosta ja vuodesta 1993 lähtien puhtaasta ansiotulosta ;
	IF &mvuosi < 1989 THEN tulo = &puhdanstulo;
	IF &mvuosi > 1988 AND &mvuosi < 1993 THEN tulo = &kokontulo;
	IF &mvuosi > 1992 THEN tulo = &puhdanstulo;

	* Vuoden 1989 jälkeen vain 3-7-vuotiaat lapset oikeuttavat vähennykseen, sitä ennen kaikki lapset ;
	IF &mvuosi > 1989 THEN DO;
		IF &lapsia_3_7_v NE 0 THEN vah2 = &ValtLapsPros * &ValtLapsiVah;
	END;

	ELSE DO; 
		IF &lapsia NE 0 THEN vah2 = &ValtLapsPros * tulo;
	END;

	* Rajoitetaan vähennys vähennyksen enimmäismäärään ;
	IF vah2 > &ValtLapsiVah THEN vah2 = &ValtLapsiVah;

	* Vuodesta 1989 lähtien vähennys voidaan jakaa puolisoiden kesken ;
	IF &mvuosi > 1988 AND &puoliso NE 0 THEN vah2 = vah2 - &puolisonos;
	IF vah2 < 0 THEN vah2 = 0;

	* Varmistetaan, ettei vähennys ole suurempi kuin se tulo, josta se voidaan myöntää ;
	IF vah2 > tulo THEN vah2 = tulo;

END;

&tulos = vah2;

DROP vah1 vah2 tulo;

%MEND ValtLapsVahS;

/* 42. Kunnallisverotuksen lapsenhoitovähennys (huom! sisältää myös yksinhuoltajavähennyksen) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen lapsenhoitovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		pientul: Pienituloisempi puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
		puhdanstulo: Puhdas ansiotulo 
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus kunnallisverotuksen lapsivähennyksestä;

%MACRO KunnLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, puhdanstulo, kokontulo, puolisonos)/ 
DES = 'VERO: Kunnallisverotuksen lapsivähennys';

%HAKU;

temp = 0;
kerroin = 0;

* Ennen vuotta 1989 vähennyksen voi saada puolisoista vain suurempituloisempi ;
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
	
	* Yksinhuoltajavähennys otetaan huomioon kertoimella 1 ;
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

/* 43. Kunnallisverotuksen yksinhuoltajavähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen yksinhuoltajavähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
		puhdanstulo: Puhdas ansiotulo; 

%MACRO KunnYksVahS(tulos, mvuosi, minf, puoliso, lapsia, puhdanstulo)/
DES = 'VERO: Kunnallisverotuksen yksinhuoltajavähennys';

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
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
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

* Otetaan huomioon puoliso- ja lapsivähennykset sekä vähennys vakituisesta asunnosta ;
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

/* 45. Kunnallisverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen täysi eläketulovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1);

%MACRO KunnElTulVahMaxS (tulos, mvuosi, minf, puoliso)/
DES = 'VERO: Kunnallisverotuksen eläketulovähennyksen maksimiarvo (täysi eläketulovähennys)';

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

/* 46. Valtionverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen täysi eläketulovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi;

%MACRO ValtElTulVahMaxS (tulos, mvuosi, minf)/
DES = 'VERO: Valtionverotuksen eläketulovähennyksen maksimiarvo (täysi eläketulovähennys)';

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

/* 47. Raja, josta eläketulon verotus alkaa */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Raja josta eläketulon verotus alkaa
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1);

%MACRO ElVeroRajaS (tulos, mvuosi, minf, puoliso)/
DES = 'VERO: Raja, josta eläketulon verotus alkaa';

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
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = eläke, 3 = muu tulo;

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
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
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
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
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
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
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
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
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
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
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
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = eläke, 3 = muu tulo;

%MACRO KunnVerRajaS (tulos, mvuosi, minf, puoliso, tulolaji)/
DES = 'VERO: Kunnan tuloverotuksen alaraja';

IF &tulolaji = 3 THEN DO;

	%HAKU;

	&tulos = &KunnPerEnimm;

END;

IF &tulolaji = 2 THEN DO;

	%ElVeroRajaS (elraja, &mvuosi, &minf, &puoliso);

	&tulos = elraja;

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

DROP tulo elraja temp1 temp2 temp3 temp4 temp5 temp6 vertulo vertulo1;

%MEND KunnVerRajaS;

/* 50. Yle-vero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yle-vero 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
    ika: Henkilön ikä vuosina
	tulo: Puhdas ansio- ja pääomatulo yhteensä
	maakunta: Henkilön maakunta;

%MACRO YleVeroS(tulos, mvuosi, minf, ika, tulo, maakunta)/
DES = 'VERO: Yle-vero';

	%HAKU;

	* Ei Yle-veroa alle 18-vuotiaille eikä henkilöille, joiden kotikunta on Ahvenanmaa;
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

/* 51. Makro, joka laskee valtionveron, kun verotuksen kattosäännös otetaan huomioon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionvero kun verotuksen kattosäännös on otettu huomioon
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	valtvertulot: Valtionverotuksessa verotettava tulo 
	valttulovero: Valtion tulovero
	varallvero: Varallisuusvero
	muutverot: Kunnallisvero, Sairausvakuutusmaksu/sairaanhoitomaku, Kansaneläkevakuutusmaksu,
	           Kirkollisvero, Pääomatulon vero;

%MACRO ValtVero_FinalS(tulos, mvuosi, valtvertulot, valttuloverot, varallvero, muutverot)/
DES = 'VERO: Valtionvero, kun verotuksen kattosäännös otetaan huomioon';

temp = &valttuloverot + &varallvero;

/* Kattoverosäännöstä ei ole vuodesta 2006 lähtien */

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

/* 52. Eläketulon lisävero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Eläketulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	elaketulo: Eläketulo
	eltulvah: Valtioverotuksen eläketulovähennys;

%MACRO ElakeLisaVeroS(tulos, mvuosi, minf, elaketulo, eltulvah)/
DES = 'VERO: Eläketulon lisävero';

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

/* 53. Lapsiperhevähennys */

/*	Makron parametrit:

    tulos: Makron tulosmuuttuja, Lapsivähennyksen määrä 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ykshuolt: Onko yksinhuoltaja (0/1) YKSINHUOLTAJA
	lapsia: Vähennykseen oikeuttavien lasten (alle 18v) lukumäärä (vähennykseen oikeuttaa max 4) cllkm
	puhdtulo: Yhteenlaskettu puhtaan ansiotulon ja pääomatulon määrä , €/v SUM(PUHD_ANSIO, PUHD_PO)

	Parametritaulukosta tulevat parametrit:

	&LapsiVah: Parametri: Lapsivähennyksen määrä / lapsi
	&LapsiLkmYlaRaja: Parametri: Lapsivähennyksen lasten lukumäärän yläraja
	&LapsiVahYlaRaja: Parametri: Lapsivähennyksen raja, minkä alle vähennys maksetaan täysimääräisenä
	&LapsiVahAlenema: Parametri: Osuus, millä lapsivähennys laskee kun &LapsVMYR rajan ylittävältä osalta */

%MACRO ValtVerLapsVahS(tulos, mvuosi, minf, ykshuolt, lapsia, puhdtulo)/
DES = 'VERO: Valtionverotuksen lapsivähennys (vähennys verosta)';

%HAKU;

temp = 0;

IF &lapsia > 0 THEN DO;

	temp = MIN(&lapsia, &LapsiLkmYlaRaja) * &LapsiVah * ((&ykshuolt=1) + 1);
	IF &puhdtulo > &LapsiVahYlaRaja THEN temp = SUM(temp, -&LapsiVahAlenema * SUM(&puhdtulo, -&LapsiVahYlaRaja));
	
END;

&tulos = MAX(temp, 0);

DROP temp;

%MEND ValtVerLapsVahS;

/* 54. Kunnallisverotuksen merityötulovähennys */

/* Makron parametrit
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen merityötulovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	merityötulo: Veronalainen merityötulo */

%MACRO KunnVerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Kunnallisverotuksen merityötulovähennys';

%HAKU;

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

/* 55. Valtionverotuksen merityötulovähennys */

/* Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen merityötulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	merityötulo: Veronalainen merityötulo */

%MACRO ValtVerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Valtionverotuksen merityötulovähennys';

%HAKU;

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
	   ovat pelkästään vanhempainpäivärahaa tai muuta vastaavaa sosiaalietuutta (ei työtuloa eikä eläkettä)
       ja palkkatuloja. */

/* Makron parametrit:
    tulos: Makron tulosmuuttuja, Päivärahatulon tai muun ansiotulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	prahatulo: Päivärahatulo, esim. vanhenpainpäiväraha
	palkkatulo: palkkatulo
	ykshuolt: Onko yksinhuoltaja (0/1)
	a17vlapsia: alle 17v lapsien lukumäärä */

%MACRO TuloVerot_Simple_PRahTyoS(tulos, mvuosi, minf, prahatulo, palkkatulo, yksinh, a17vlapsia)/
DES = 'VERO: Tuloverot yksinkertaisessa perustapauksessa, jossa päiväraha ja palkkatuloja';

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
%ValtTuloVeroS(valtvero, &mvuosi, &minf, valtverotulo);
%ValtVerAnsVahS(valtansvah, &mvuosi, &minf, &palkkatulo, puhdansiotulo);
%ValtVerLapsVahS(valtlapsvah, &mvuosi, &minf,  &yksinh, &a17vlapsia, puhdansiotulo);

%YleVeroS(ylevero, &mvuosi, &minf, 18, puhdansiotulo, 0); 

&tulos = SUM(tyelmaksu, tyotmaksu, sairpmaksu, ylevero, MAX(0, SUM(sairvmaksu, kunnvero, valtvero, -valtansvah, -valtlapsvah))); 

DROP tulhanksum ansiotulo puhdansiotulo tyelmaksu tyotmaksu sairvmaksu sairpmaksu kunnans kunnverotulo kunnper kunnvero valtverotulo valtvero valtansvah ylevero valtlapsvah; 

%MEND TuloVerot_Simple_PRahTyoS;

/* 57. Kotitalousvähennyksen lisädatan laskentamakro.
	Laskee kotitalousvähennyksen ostoihin, palkkakuluihin ja palkan sivukuluihin erittelystä
	datasta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousvähennysoikeus
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	palksiku: palkatun työntekijän palkan sivukulut, oma osuus
	palkomos: palkatun työntekijän palkka, oma osuus
	tyonosuu: työn osuus yrityksen työstä
*/

%MACRO KotitVahErillS(tulos, mvuosi, minf, palksiku, palkomos, tyonosuu)/
DES = 'VERO: Kotitalousvähennys erillisdatasta';

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



/* 58. Kotitalousvähennyksen lisädatan laskentamakro työn lajeittain.
	Laskee kotitalousvähennyksen ostoihin, palkkakuluihin ja palkan sivukuluihin sekä 
	kotitalous-, hoiva- tai hoitotyöhön ja asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyöhön
	eritellystä	datasta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousvähennysoikeus
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	palksiku_remontti: palkatun työntekijän palkan sivukulut, oma osuus, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyö
	palksiku_koti: palkatun työntekijän palkan sivukulut, oma osuus, kotitalous-, hoiva- tai hoitotyö
	palkomos_remontti: palkatun työntekijän palkka, oma osuus, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyö
	palkomos_koti: palkatun työntekijän palkka, oma osuus, kotitalous-, hoiva- tai hoitotyö
	tyonosuu_remontti: työn osuus yrityksen työstä, asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyö
	tyonosuu_koti: työn osuus yrityksen työstä, kotitalous-, hoiva- tai hoitotyö
*/


%MACRO KotitVahErillJakoS(tulos, mvuosi, minf, palksiku_remontti, palksiku_koti, palkomos_remontti, palkomos_koti, tyonosuu_remontti, tyonosuu_koti)/
DES = 'VERO: Kotitalousvähennys erillisdatasta';

	%HAKU;

	/*Asunnon tai vapaa-ajan asunnon kunnossapito- tai perusparannustyö*/

	IF &tyonosuu_remontti > 0 THEN DO;
		temp1_remontti = 0 + &tyonosuu_remontti * &KotitVahTyoKerroinRemontti;
	END;

	IF &palkomos_remontti > 0 THEN DO;
		temp2_remontti = 0 + &palksiku_remontti + &palkomos_remontti * &KotitVahPalKerroinRemontti;
	END;

	remonttiYht = sum(temp1_remontti, temp2_remontti);
	
	IF SUM(remonttiYht, -&KotitVahOmavast) > &kotitVahEnimmRemontti THEN tulosRemontti = &kotitVahEnimmRemontti;
	ELSE IF SUM(remonttiYht, -&KotitVahOmavast) < 0 THEN tulosRemontti = 0;
	ELSE tulosRemontti = remonttiYht;

	/* Huomioidaan tässä vaiheessa vähennetty omavastuu */
	OmavastuuVahennetty = MIN(remonttiYht, &KotitVahOmavast); 			/* Käytetty omavastuu remonttikustannuksen verran, kuitenkin enintään omavastuun verran */
	OmavastuuJaljella = sum(&KotitVahOmavast, -OmavastuuVahennetty); 	/* Jäljellä oleva omavastuu on enimmäisomavastuun ja tässä vähennetyn verran */

	/*kotitalous-, hoiva- tai hoitotyö*/

	IF &tyonosuu_koti > 0 THEN DO;
		temp1_koti = 0 + &tyonosuu_koti * &KotitVahTyoKerroin;
	END;

	IF &palkomos_koti > 0 THEN DO;
		temp2_koti = 0 + &palksiku_koti + &palkomos_koti * &KotitVahPalKerroin;
	END;

	kotiYht = sum(temp1_koti, temp2_koti);

	/* Huomioidaan tässä vaiheessa vähennetty omavastuu sekä jäljellä oleva enimmäismäärä*/
	EnimmaisJaljella = MAX(0, SUM(&kotitVahEnimm, -tulosRemontti));

	IF SUM (kotiYht, -OmavastuuJaljella) > EnimmaisJaljella THEN tulosKoti = EnimmaisJaljella;
	ELSE IF SUM(kotiYht, -OmavastuuJaljella) < 0 THEN tulosKoti = 0;
	ELSE tulosKoti = kotiYht;

	/*Kaikki kotitalousvähennykset yhteensä*/

	&tulos = SUM(tulosRemontti, tulosKoti);	

%MEND KotitVahErillJakoS;


/* 59. Yrittäjävähennys 

Parametrit:
    tulos: Makron tulosmuuttuja, Yrittäjävähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	yrtulo: yrittäjätulo
*/

%MACRO YrittajaVahS(tulos, mvuosi, minf, yrtulo)/
DES = 'VERO: Yrittäjävähennys';

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
	lsvuosi: Vuosi, jonka lainsäädäntöä käytetään
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


/* 61. Makro, jonka avulla vähennyksiä siirretään puolisoiden kesken

Makron parametrit:
	vahennys: Jaettavan vähennyksen määrä, e/vuosi
	vero: Vero, josta vähennys tehdään, e/vuosi
*/

%MACRO VahennysSwap (vahennys, vero)/
DES = 'VERO: Makro, jonka avulla vähennyksiä siirretään puolisoiden kesken veromallissa';

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

***************** UUDET MAKROT ************************************;

 /* 61. Merityötulovähennys  
	yhdistetty, ei enää erillisistä laskentaa valtionverotuksessa ja kunnallisessa verotuksessa */

/* Makron parametrit:
    tulos: Makron tulosmuuttuja, verotuksen merityötulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	merityötulo: Veronalainen merityötulo */

%MACRO VerMeriVahS(tulos, mvuosi, minf, merityotulo)/
DES = 'VERO: Merityötulovähennys';

%HAKU;

temp = 0;

IF &merityotulo GT 0 THEN DO;

	temp = MIN((&merityotulo * (&MeriVahPros)), &MeriVahMax);

	yliraja = SUM(&merityotulo, -&MeriVahYli) * (&MeriVahYliPros); 
	IF &merityotulo GT &MeriVahYli THEN temp = SUM(-yliraja, temp); 

END;
	
&tulos = MAX(temp, 0);

DROP temp;

%MEND VerMeriVahS;
/* 62. Opintorahavähennys 
Ennen ollut vain kunnallisverotuksessa, nyt yhteinen

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintorahavähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	opraha: Opintoraha (veronalainen opintukilain mukainen opintoraha)
	puhdanstulo: Puhdas ansiotulo; */

%MACRO OpRahVahS (tulos, mvuosi, minf, opraha, puhdanstulo)/
DES = 'VERO: Opintorahavähennys';

%HAKU;

IF &opraha = 0 THEN &tulos = 0;

ELSE DO;

	&tulos = &YhdOpRahVah;

	IF &puhdanstulo > &YhdOpRahVah THEN  &tulos =  &YhdOpRahVah - &YhdOpRahPros * (&puhdanstulo  - &YhdOpRahVah);

	IF &tulos < 0 THEN &tulos = 0;

	IF &tulos > &opraha THEN &tulos = &opraha;
END;

%MEND OpRahVahS;
/* 63. Ansiotulovähennys. 
	   Ennen ollut vain kunnallisverotuksessa, nyt yhteinen
 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen ansiotulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puhdanstulo: Puhdas ansiotulo
	tyotulo: Työtulo;
	
	

%MACRO AnsVahS(tulos, mvuosi, minf, puhdanstulo, tyotulo)/
DES = 'VERO: Ansiotulovähennys';

%HAKU;

vahtulo = &tyotulo;

IF vahtulo <  &AnsRaja1 THEN &tulos = 0;

ELSE IF vahtulo >= &AnsRaja1 THEN &tulos = &AnsPros1 * (vahtulo - &AnsRaja1);

IF vahtulo >= &AnsRaja2 THEN &tulos = &AnsPros1 * (&AnsRaja2 - &AnsRaja1) + &AnsPros2 * (vahtulo -  &AnsRaja2);

IF &tulos > &AnsEnimm THEN &tulos = &AnsEnimm;

verttulo = &puhdanstulo;

IF verttulo > &AnsRaja3 THEN &tulos = &tulos - &AnsPros3 * (verttulo -  &AnsRaja3);

IF &tulos < 0 THEN &tulos = 0;

IF &tulos > verttulo THEN &tulos = verttulo;

DROP vahtulo verttulo;

%MEND AnsVahS;



/* 64. Eläketulovähennys.
	   Parametreissa vuodesta 1983 lähtien.
	   Kaavassa otetaan huomioon tulokäsitteiden muutos. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Eläketulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	elaketulo: Eläketulo
	puhdansiotulo: Puhdas ansiotulo;


%MACRO ElTulVahS (tulos, mvuosi, minf, elaketulo, puhdansiotulo)/
DES = 'VERO:Eläketulovähennys';

%HAKU;

taysivah = &ElKerr * &KelaYks;

%pyoristys10e(utaysivah, taysivah);

tulo = &puhdansiotulo;

/* Vähennystä pienennetään */

IF tulo > utaysivah AND tulo <= &ElRaja THEN utaysivah = utaysivah - &ElPros * (tulo - utaysivah);

IF tulo > &ElRaja THEN utaysivah = utaysivah - &ElPros * (&ElRaja - utaysivah)- &ElPros2 * (tulo - &ElRaja);

IF utaysivah < 0 THEN utaysivah = 0;

/* Vähennys ei voi olla eläketuloa suurempi */

vah = utaysivah;

IF vah > &elaketulo THEN vah = &elaketulo;

&tulos = vah;

DROP tulo taysivah utaysivah vah;

%MEND ElTulVahS;

/* 65. Perusvähennys */	

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen perusvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	vertuloA: Verotettava tulo ennen perusvähennystä;

%MACRO PerVahS(tulos, mvuosi, minf, vertuloA)/
DES = 'VERO: Perusvähennys';

%HAKU;

IF &vertuloA <= &PerEnimm THEN &tulos = &vertuloA;

ELSE &tulos =  &PerEnimm - &PerPros * (&vertuloA - &PerEnimm);

IF &tulos < 0 THEN &tulos = 0;

%MEND PerVahS;

/* 66. Valtionverotuksen työtulovähennys.
	   Huom! Verosta tehtävä vähennys.

SOTEUUDISTUS huomioitu tässä versiossa
	    */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen ansiotulovähennys/työtulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tyotulo: Työtulo
	puhdanstulo: Puhdas ansiotulo
	ika: Henkilön ikä;

%MACRO ValtVerTyotVahS_2023(tulos, mvuosi, minf, tyotulo, puhdanstulo, ika)/
DES = 'VERO: Valtionverotuksen ansiotulovähennys/työtulovähennys (vähennys verosta), sotemuutokset huomioitu';

%HAKU;

enimm=&ValtTyotEnimm;

IF &ika > 59 AND &ika < 62 THEN enimm = SUM(enimm, 200);

IF &ika > 61 AND &ika < 65  THEN enimm = SUM(enimm, 400);

IF &ika > 64 THEN enimm = SUM(enimm, 600);

vah = MIN(&ValtTyotPros1 * &tyotulo, enimm);

IF &puhdanstulo > &ValtTyotAlaRaja AND &puhdanstulo <= &ValtTyotYlaRaja THEN vah = vah - &ValtTyotPros2 * (&puhdanstulo - &ValtTyotAlaRaja);

IF &puhdanstulo > &ValtTyotYlaRaja THEN vah = vah - &ValtTyotPros2 * (&ValtTyotYlaRaja - &ValtTyotAlaRaja) - &ValtTyotPros3 * (&puhdanstulo - &ValtTyotYlaRaja);

&tulos=vah;

IF &tulos < 0 THEN &tulos = 0;

DROP vah;

%MEND ValtVerTyotVahS_2023;

/* 67. Valtion tulovero Ahvenanmaalle sotemuutosten jälkeen */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtion tulovero 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tulo = Valtion verotuksessa verotettava tulo eli tulo vähennysten jälkeen 
	      (vuodesta 1993 lähtien koskee vain ansiotuloa);
	
%MACRO ValtTuloVeroS_sote(tulos, mvuosi, minf, tulo)/
DES = 'VERO: Valtion tulovero (veroasteikko, Ahvenanmaa)';

%HAKU;

IF &tulo <= 0 THEN &tulos = 0;

ELSE DO;
		/* Ahvenanmaan valtionverotus sotemuutosten jälkeen */
		IF &tulo GE  &Raja12ahven THEN
			&tulos =  &Vakio12ahven + &Pros12ahven * (&tulo -  &Raja12ahven);

		ELSE IF &tulo GE  &Raja11ahven THEN
			&tulos =  &Vakio11ahven + &Pros11ahven * (&tulo -  &Raja11ahven);

		ELSE IF &tulo GE  &Raja10ahven THEN
			&tulos =  &Vakio10ahven + &Pros10ahven * (&tulo -  &Raja10ahven);

		ELSE IF &tulo GE  &Raja9ahven THEN
			&tulos =  &Vakio9ahven + &Pros9ahven * (&tulo -  &Raja9ahven);

		ELSE IF &tulo GE  &Raja8ahven THEN
			&tulos =  &Vakio8ahven + &Pros8ahven * (&tulo -  &Raja8ahven);

		ELSE IF &tulo GE  &Raja7ahven THEN
			&tulos =  &Vakio7ahven + &Pros7ahven * (&tulo -  &Raja7ahven);

		ELSE IF &tulo GE  &Raja6ahven THEN
			&tulos =  &Vakio6ahven + &Pros6ahven * (&tulo -  &Raja6ahven);

		ELSE IF &tulo GE  &Raja5ahven THEN
			&tulos =  &Vakio5ahven + &Pros5ahven * (&tulo -  &Raja5ahven);

		ELSE IF &tulo GE  &Raja4ahven THEN
			&tulos =  &Vakio4ahven + &Pros4ahven * (&tulo -  &Raja4ahven);

		ELSE IF &tulo GE  &Raja3ahven THEN
			&tulos =  &Vakio3ahven + &Pros3ahven * (&tulo -  &Raja3ahven);

		ELSE IF &tulo GE  &Raja2ahven THEN
			&tulos =  &Vakio2ahven + &Pros2ahven * (&tulo -  &Raja2ahven);

		ELSE IF &tulo GE  &Raja1ahven THEN
			&tulos =  &Vakio1ahven + &Pros1ahven * (&tulo -  &Raja1ahven);
END;

%MEND ValtTuloVeroS_sote;
