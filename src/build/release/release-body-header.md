## Commensurability Framework

This release upgrades the treatment of commensurability and unit classification with explicit, individually-validatable relations:

**In the source graph** (`src/main/rdf/`):

- Quantity-kind hierarchies use `qudt:specializationOf` (commensurate specialization, a sub-property of `skos:broader`) instead of bare `skos:broader`, and `qudt:organizedUnder` (organizational grouping without commensurability, also a sub-property of `skos:broader`).
- Unit classifications use `qudt:unitForQuantityKind` (commensurate measurement, a sub-property of `qudt:hasQuantityKind`) and `qudt:categorizedByQuantityKind` (non-commensurate filing, also a sub-property of `qudt:hasQuantityKind`) instead of bare `qudt:hasQuantityKind`.
- Authors assert the precise sub-property; the build materializes the super-property (`skos:broader` / `qudt:hasQuantityKind`) into the released graphs for full backward compatibility.

**Result:**

- **Commensurability** is now derived from `qudt:specializationOf` and `qudt:exactMatch` (not `skos:broader`), so organizational groupings can be carried on `skos:broader` without implying convertibility.
- **Released graphs** are byte-for-byte identical in `qudt:applicableUnit`, `qudt:hasQuantityKind`, and `skos:broader` — fully backward compatible.
- **Precision** improves: dimension-coincident quantity kinds (e.g., frequency and radioactive activity) are correctly identified as non-commensurate.

See [Commensurability, Composition Semantics, and Context](https://github.com/qudt/qudt-public-repo/wiki/Commensurability-Composition-Semantics-and-Context) on the QUDT wiki for the design rationale, formal definitions, and examples.

