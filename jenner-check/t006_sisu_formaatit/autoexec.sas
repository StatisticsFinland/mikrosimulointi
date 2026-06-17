options obs=100;

/* ---------------------------------------------------------------------------
   Bundle setup for SISU/OHJAUS/SisuFormaatit.sas

   SisuFormaatit.sas defines the formats the SISU simulation programs use to
   classify and label results (income deciles, age groups, socioeconomic
   status, education level). This autoexec is empty of setup beyond OBS= --
   the PROC FORMAT block and the example data live in script.sas, so the
   format definitions are exercised exactly as written.

   The Finnish category labels in the source file are stored in Latin-1; the
   letters a-umlaut / o-umlaut are transliterated to ASCII (a / o) here so the
   labels travel cleanly, with the classification logic and value ranges left
   unchanged.
   --------------------------------------------------------------------------- */
