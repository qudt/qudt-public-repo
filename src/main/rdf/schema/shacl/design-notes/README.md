# SHACL Datatype Schema — Design Notes

Design decisions, patterns, and open threads for the SHACL datatype schema
(`SCHEMA_QUDT-DATATYPES_NoOWL.ttl`, graph `<http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype>`).
It was split into core, scalar and structured schemas on 2026-08-24 and merged back into one
on 2026-10-23. Read the pattern doc before touching one
of the open threads; the open-thread docs assume familiarity with it.

## Patterns

- **[spec-plus-values-pattern.md](spec-plus-values-pattern.md)** — the canonical
  way structured datatypes are modelled in this schema: kind plus values, for tuples, arrays,
  vectors, collections and maps. A value holds its data in `qudt:values` and points with
  `qudt:datatypeKind` at a reusable kind. Covers the three cooperating shapes (value / kind /
  member type spec); how a kind describes its cells, either per position in member specs or with one
  shared type (`qudt:elementType`, or `qudt:elementSpec` for a type a single IRI cannot express);
  the four-alternative type facet and its refinements (numeric bounds, `sh:languageIn`); quantity
  kinds and units; optional tuple positions (the `qudt:Maybe…UnionType` family, with an `rdf:nil`
  placeholder); why the lists must be well formed (`qudt:RDFListShape`); and SPARQL-constraint
  idioms — the SHACL pre-binding rule for sub-SELECTs that walk RDF lists via
  `rdf:rest*/rdf:first`, and two constructs (`UNION` inside `FILTER NOT EXISTS`,
  and joining on an aggregate alias across a sub-SELECT boundary) that are
  silently non-portable and have each already caused a whole constraint to
  misfire. Read idioms 3 and 4 before writing a new `sh:sparql` constraint.

## How-to

- **[validating-with-the-shacl-engine.md](validating-with-the-shacl-engine.md)** *(written 2026-10-19)* —
  how to run the tuple, array, vector, collection and map constraints against the examples in the
  build's own SHACL engine (TopBraid SHACL 1.4.3), which the build itself never does, using the
  checker in `src/build/engine-check/`. Gives the expected result for every bad example, which file
  it is in, and how to compare a change against an earlier version. Run
  `src/build/engine-check/engine-check.sh` after changing any `sh:sparql` constraint, type union or
  example. Its section "Units of the examples" describes the one check that runs in the build
  instead: whether each unit is an applicable unit of its quantity kind
  (`src/main/rdf/validation/QUDT_DATATYPE_UNIT_QA_TESTS.ttl`), which needs the inferred
  `qudt:applicableUnit` links in `target/dist`.

## Open threads

- **[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md)** *(opened 2026-05-16)* —
  Giving `qudt:Array` a structured-datatype treatment, which grew into the kind-plus-values
  model for all the structured datatypes. **Current design (since 2026-08-22): the `Array` /
  `ArrayKind` split.** A `qudt:Array` carries only `qudt:values` plus a mandatory
  `qudt:datatypeKind` pointer; the reusable `qudt:ArrayKind` blueprint holds rank, extents,
  `qudt:elementCount`, `qudt:dataOrder` and the element types, either one shared type or one member
  spec per position (`qudt:tupleMemberSpecs`), exactly one of the two. Vectors, tuples, collections
  and maps follow the same model with their own kinds. The constraints are **validated**, and
  confirmed in TopBraid — the note records four defects found in the shared tuple engine while
  doing so. **All twelve lettered items, A to L, are closed** (the last on 2026-10-26). **Still
  open:** `qudt:Matrix` and `qudt:MultiDimensionalArray` have no kind of their own, and three
  unattached shapes (`qudt:StructuredDatatype-nTuple`, `qudt:TimeSeriesArray-vector`,
  `qudt:TimeSeriesArray-dimensions`) await a keep-or-delete decision.
- **[quantity-value-cells.md](quantity-value-cells.md)** *(opened 2026-10-26)* —
  Instances of `qudt:QuantityValue` as the values of tuples, arrays, vectors, collections and maps.
  They already work with no schema change: `sh:class qudt:QuantityValue` in a member spec, or
  `qudt:elementType qudt:QuantityValue` on a kind, confirmed in TopBraid. **Still open:** a cell's
  unit can contradict its kind's (A), sets and map keys compare quantity values as terms (B), and an
  optional quantity-value tuple position probably fails `qudt:NTupleTypeCheck` (C).

## Adding a new note

When opening a new design thread:

1. Add a file here named for the topic (no date in the filename — use
   `snake-case-topic.md` or `kebab-case-topic.md`).
2. In the file itself, include headers for **Opened**, **Status**, and
   **Related file(s)** so a cold reader can orient quickly.
3. Add a bullet under **Open threads** above with a one-line summary and the
   opened date in parentheses.

When a thread closes, either delete the file or move it to a "Resolved" section
here with a one-line note of the outcome.
