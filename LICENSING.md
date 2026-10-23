# Licensing

QUDT is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
The root [`LICENSE`](LICENSE) file is the unmodified CC BY 4.0 legal code, which is what lets GitHub detect and display the license.

## Attribution is required

CC BY 4.0 permits any use, including commercial use, on condition of attribution (Section 3(a) of the license). When you share QUDT material, or material adapted from it, you must:

- credit **QUDT.org**, the organization, as the creator;
- link to the license, https://creativecommons.org/licenses/by/4.0/;
- indicate whether you made changes.

A suitable attribution is:

> QUDT — Quantities, Units, Dimensions and Types, by QUDT.org (https://qudt.org), release _x.y.z_, licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/).

Please name the release you used. QUDT is released monthly, and the release identifies exactly which definitions you relied on.
[`CITATION.cff`](CITATION.cff) provides the same information in machine-readable form, and GitHub renders it behind the *Cite this repository* button.

## What is covered

| Material | License | Where stated |
|---|---|---|
| QUDT ontology sources under `src/main/rdf/`, the release distributions, and the graphs served at qudt.org | CC BY 4.0 | [`LICENSE`](LICENSE); `dcterms:rights` in each graph |
| Everything else in this repository authored by QUDT.org and its contributors (build files, documentation) | CC BY 4.0 | [`LICENSE`](LICENSE) |
| **Third party:** UCUM codes (the `qudt:ucumCode` values) and the archived UCUM resources under [`src/main/rdf/community/general/UCUM/`](src/main/rdf/community/general/UCUM/) | UCUM license, Regenstrief Institute, Inc. and The UCUM Organization | `dcterms:rights` in the units vocabulary and schema graphs; https://unitsofmeasure.org |

The UCUM material is not QUDT.org's to license. Your use of it is also subject to the UCUM license terms.

## Contributions

By contributing to this repository you agree that your contribution is licensed under CC BY 4.0.
