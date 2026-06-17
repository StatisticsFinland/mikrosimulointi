options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/MAKROT/YLEISET/YleisMakrot.sas (macro IkaKuuk)

   IkaKuuk computes, for a given lower/upper age bound, how many months of the
   reference year a person spends inside that age interval. It emits a DATA
   step block (IF / SELECT / WHEN). The macro definition below is reproduced
   verbatim from YleisMakrot.sas (Finnish DES= transliterated to ASCII).
   --------------------------------------------------------------------------- */

%MACRO IkaKuuk(ika_kuuk, ika_ala, ika_yla, ikakk)/
DES = 'YleisMakrot: months a person is within a given age interval during the year';

IF (&ika_ala < 0 OR &ika_yla < 0 OR &ika_yla < &ika_ala) THEN temp = 0;

ELSE DO;

	ala_kuuk = 12 * &ika_ala;
	yla_kuuk = 12 * &ika_yla + 11;

	SELECT;
		WHEN (&ikakk < ala_kuuk) DO;
			temp = 0;
		END;
		WHEN (&ikakk > yla_kuuk) DO;
			temp = 13 - (&ikakk - yla_kuuk);
			IF temp < 0 THEN temp = 0;
		END;
		WHEN (ala_kuuk <= &ikakk <= yla_kuuk) DO;
			temp = &ikakk - ala_kuuk;
			IF temp > 12 THEN temp = 12;
		END;
	END;

END;

&ika_kuuk = temp;
DROP ala_kuuk yla_kuuk temp;
%MEND IkaKuuk;
