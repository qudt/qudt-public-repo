# SHACL Datatype Schema — Design Notes

Design decisions, patterns, and open threads for the SHACL datatype schema
(`SCHEMA_QUDT-DATATYPES_NoOWL.ttl`, graph `<http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype>`).
It was split into core, scalar and structured schemas on 2026-08-24 and merged back into one
on 2026-10-23. Read the pattern doc before touching one
of the open threads; the open-thread docs assume familiarity with it.

## Patterns

- **[spec-plus-values-pattern.md](spec-plus-values-pattern.md)** — the canonical
  way structured datatypes (tuples, arrays, future variants) are modelled in
  this schema. Covers the three cooperating shapes (instance / spec / member
  type spec), the four-alternative type facet, optional tuple positions
  (the `qudt:Maybe…UnionType` family, with an `rdf:nil` placeholder), and SPARQL-constraint idioms —
  the SHACL pre-binding rule for sub-SELECTs that walk RDF lists via
  `rdf:rest*/rdf:first`, and two constructs (`UNION` inside `FILTER NOT EXISTS`,
  and joining on an aggregate alias across a sub-SELECT boundary) that are
  silently non-portable and have each already caused a whole constraint to
  misfire. Read idioms 3 and 4 before writing a new `sh:sparql` constraint.

## How-to

- **[validating-with-the-shacl-engine.md](validating-with-the-shacl-engine.md)** *(written 2026-10-19)* —
  how to run the tuple and array constraints against the examples in the build's own SHACL
  engine (TopBraid SHACL 1.4.3), which the build itself never does. Includes the checker and
  script, the expected result for every bad example, and how to compare a change against an
  earlier version. Run it after changing any `sh:sparql` constraint, type union or example.

## Open threads

- **[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md)** *(opened 2026-05-16)* —
  Giving `qudt:Array` a structured-datatype treatment. **Current design
  (2026-08-22): the `Array` / `ArrayKind` split.** A `qudt:Array` carries only
  `qudt:values` plus a mandatory `qudt:datatypeKind` pointer; the reusable
  `qudt:ArrayKind` blueprint holds rank, extents, `qudt:elementCount`,
  `qudt:dataOrder` and the element type(s) (flat `qudt:elementType` for
  homogeneous, `qudt:conformsToTupleSpec` → `qudt:NTupleSpec` for heterogeneous).
  This reverses the brief 2026-07-27 "self-describing array" revision. Array and
  tuple constraints are now **validated**, and confirmed in TopBraid on 2026-10-19 — the
  note records four defects found in the shared tuple engine while doing so. Since 2026-10-22
  `qudt:Vector` and its kind are separate from `qudt:Array` and its kind, and a vector may be
  heterogeneous (item G, resolved). **Still open:** where `qudt:Matrix` / `Homogeneous` /
  `Heterogenous` sit relative to the split, plus the "still to do" items B–E in the note (H, a time-series value class, was resolved on 2026-10-24). F (added
  2026-10-21) is resolved: quantities point at structured values directly, and their elements need
  not be numeric.

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
