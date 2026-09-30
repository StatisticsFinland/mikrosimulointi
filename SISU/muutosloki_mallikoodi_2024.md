# SISU-mallin muutosloki

**Aineistovuosi 2024**

Tähän dokumenttiin merkitään SISU-mikrosimulointimallin mallikoodiin tehdyt muutokset. Muutoslokista ilmenee yleiskuvaus muutoksesta ja tiedostot, joihin muutoksia on tehty.

## Malliversio 26.30, jaettu 21.9.2026

- Julkaistu VM:n syksyn 2026 ennusteen mukaisesti ajantasaistetut rekisteriaineistot ja parametritaulut vuosille 2025-2030.

- Päivitetty ALKUsimul-ohjelma, jotta koodi toimii Fiona-etäkäyttöjärjestelän päivitetyssä versiossa. 
  - /SIMUL_2024/ALKUsimul.sas

- Korjattu korotettujen vanhempainpäivärahojen laskenta. Aikaisemmin korotetut vanhempainpäivärahat eivät simuloituneet oikein 8/2022 jälkeiselle lainsäädännölle.
  - /MAKROT/SAIRVAKlakimakrot.sas

- Korjattu peruspäivärahan ja työmarkkinatuen korotusosien simulointi lainsäädäntövuodelle 2024 ja sitä edeltäville vuosille.
  - /MAKROT/TTURVAlakimakrot.sas

- Tarkennettu työttömyysturvan kuukausitason simuloinnissa käytettyjen summamuuttujien muodostussääntöjä.
  - /DATA/POHJADAT/tulrek_summaus.sas

- Tarkennettu tulonhankkimiskulujen huomioimista toimeentulotuen laskennassa.
  - /SIMUL_2024/TOIMTUKIsimul.sas
  - /MAKROT/TOIMTUKIlakimakrot.sas

- Yhtenäistetty datan tulosmuuttujia vähentämällä kulukorvaukset työttömyysturvan KOKOsimul-ohjelman tulosmuuttujasta TTURVA_DATA ('Työttömyysturva ja koulutustuki yhteensä, DATA'). Tämän seurauksena datan tietoja kuvaava tulosmuuttuja on vertailukelpoisempi KOKOsimul- ja TTURVAsimul-osamallien välillä.
  - /SIMUL_2024/KOKOsimul.sas

## Malliversio 26.20, jaettu 12.5.2026

- Tarkennettu 16-vuotta täyttäneen ja alle 16-vuotiaan vammaistuen sekä eläkkeensaajan hoitotuen simulointia uusien tarkempien kuukausien määrämuuttujien avulla.
  - /SIMUL_2024/KANSELsimul.sas

- Selkeytetty kansaneläkkeeseen, takuueläkkeeseen ja eläkkeensaajan asumistukeen oikeutettujen ehtoja uusien tulorekisteristä muodostettujen eläkemuuttujien ja vakinaisten asuinvuosien avulla. Lisäksi korvattu tarkemmilla eläkkeiden kuukausimuuttujilla aiemmin imputoitujen elak- ja ELAKUUK-muuttujien käyttö.
  - /SIMUL_2024/KANSELsimul.sas
  - /SIMUL_2024/ELASUMTUKIsimul.sas

- Tarkennettu työmatkakuluvähennyksen laskentaa korvaamalla aiemmin käytetty tyot-muuttuja uudella alematka_kk-muuttujalla. Uusi muuttuja ottaa huomioon työttömyyskuukausien lisäksi myös sairausvakuutuslain perusteella kertyneet korvauskuukaudet.
  - /SIMUL_2024/VEROsimul.sas

- Korjattu rintamalisän määrää kuvaavan RiLi-parametrin virheellinen arvo vuodelle 2024. Aikaisemmin arvo oli 2400,11, korjattu arvoon 2185,20.
  - /PARAM/pkansel.sas7bdat