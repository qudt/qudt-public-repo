# SHACL Datatype Schema — Design Notes

Design decisions, patterns, and open threads for the SHACL datatype schema
(`SCHEMA_QUDT-DATATYPES-CORE_NoOWL.ttl`, `-SCALAR_NoOWL.ttl` and
`-STRUCTURED_NoOWL.ttl`). Read the pattern doc before touching one
of the open threads; the open-thread docs assume familiarity with it.

## Patterns

- **[spec-plus-values-pattern.md](spec-plus-values-pattern.md)** — the canonical
  way structured datatypes (tuples, arrays, future variants) are modelled in
  this schema. Covers the three cooperating shapes (instance / spec / member
  type spec), the four-alternative type facet, and SPARQL-constraint idioms —
  the SHACL pre-binding rule for sub-SELECTs that walk RDF lists via
  `rdf:rest*/rdf:first`, and two constructs (`UNION` inside `FILTER NOT EXISTS`,
  and joining on an aggregate alias across a sub-SELECT boundary) that are
  silently non-portable and have each already caused a whole constraint to
  misfire. Read idioms 3 and 4 before writing a new `sh:sparql` constraint.

## Open threads

- **[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md)** *(opened 2026-05-16)* —
  Giving `qudt:Array` a structured-datatype treatment. **Current design
  (2026-08-22): the `Array` / `ArrayKind` split.** A `qudt:Array` carries only
  `qudt:values` plus a mandatory `qudt:datatypeKind` pointer; the reusable
  `qudt:ArrayKind` blueprint holds rank, extents, `qudt:elementCount`,
  `qudt:dataOrder` and the element type(s) (flat `qudt:elementType` for
  homogeneous, `qudt:conformsToTupleSpec` → `qudt:NTupleSpec` for heterogeneous).
  This reverses the brief 2026-07-27 "self-describing array" revision. Array and
  tuple constraints are now **validated** — the note records three portability
  defects found in the shared tuple engine while doing so. **Still open:** where
  `qudt:Vector` / `qudt:Matrix` / `Homogeneous` / `Heterogenous` sit relative to
  the split, plus the "still to do" B–E list in the note.

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
