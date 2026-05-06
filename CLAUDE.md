# QUDT Public Repo — Claude guidance

## What this project is
The QUDT (Quantities, Units, Dimensions and Types) ontology. Source files are RDF/Turtle under `src/main/rdf/`. The build pipeline derives, validates, and packages them into a release zip.

## Build system
- Maven; the main build file is `pom.xml` (~9600 lines)
- Key plugins: `gmavenplus-plugin` (Groovy scripts) and `rdfio-maven-plugin` (io.github.qudtlib, v1.5.5)
- `mvn install` runs the full pipeline; `mvn clean` wipes `target/`
- The rdfio plugin is on Maven Central; its source is in the separate qudtlib repository

### Extension builds
```
mvn -Dqudt.supported.extensions=id1,id2 -Dqudt.allInOne.extensions=id1,id2 install
```
Extension IDs must match `[a-z][a-z0-9-]*` and map to folders under `src/main/rdf/community/extensions/`.

## Key source locations
| What | Where |
|---|---|
| Quantity kinds | `src/main/rdf/vocab/quantitykinds/VOCAB_QUDT-QUANTITY-KINDS-ALL.ttl` |
| Units | `src/main/rdf/vocab/unit/VOCAB_QUDT-UNITS-ALL.ttl` |
| Community extensions | `src/main/rdf/community/extensions/{id}/` |
| Shared Groovy helpers | `src/build/extension-id-helpers.groovy` |
| Release assembly descriptor | `src/build/assembly/releaseZip.xml` |

## Naming conventions
- Recognised extension files must be named `VOCAB_QUDT-*.ttl` or `SCHEMA_QUDT-*.ttl`
- Other `.ttl` files in an extension folder (e.g. `profile.ttl`) are passed through to `target/dist` unchanged and are not fed into the RDF processing pipeline

## Ontology conventions
- Quantity kinds use `skos:broader` for the hierarchy; specialisations of `quantitykind:Foo` point to it with `skos:broader quantitykind:Foo`
- Cross-references between related quantity kinds use `rdfs:seeAlso`
- Dimension vectors are referenced as `qkdv:A{a}E{e}L{l}I{i}M{m}H{h}T{t}D{d}`
- Do **not** add `qudt:informativeReference`, `qudt:normativeReference`, or `qudt:wikidataMatch` values unless the URI has been verified; omit rather than guess

## Working with Claude
- Commit completed work but do **not** push — the user reviews before pushing
- Do not add code comments unless the WHY is non-obvious
- Do not fabricate IEV codes, ISO catalogue numbers, or Wikidata entity IDs
- Keep responses concise; no trailing summaries of what was just done

## Active work streams (2026-05)

### srr-general-extension-support
Extension pipeline fix: non-VOCAB/SCHEMA files pass through unchanged. Merged into `srr-deduplicated-pom`.

### srr-deduplicated-pom
Reducing pom.xml duplication between core and extension pipeline.
- **Done:** Groovy helpers extracted to `src/build/extension-id-helpers.groovy`
- **Waiting on rdfio plugin:** `<stepDef>`/`<invoke>` for named reusable steps (eliminates 7× repeated "refresh extension aggregate" SPARQL block)
- **Waiting on rdfio plugin:** `<forEach>` with per-item `<preamble>`/`<postamble>` (eliminates core/extension inference pairs)
- Feature spec for the plugin author was written; awaiting implementation

### srr-electric-energy
Completed the `ElectricEnergy` specialisation hierarchy to mirror `ElectricPower → ActivePower/ApparentPower/ReactivePower`:
- Added `quantitykind:ApparentEnergy`
- Fixed `quantitykind:ActiveEnergy` (`skos:broader` was `Energy`, corrected to `ElectricEnergy`)
- Enriched `quantitykind:ReactiveEnergy`
- Reclassified `unit:VA-HR`, `unit:KiloVA-HR`, `unit:MegaVA-HR` to `quantitykind:ApparentEnergy`
- IEV and ISO references for the new/enriched entries are **pending verification**
