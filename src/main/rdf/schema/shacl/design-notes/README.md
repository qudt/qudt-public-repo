# SHACL Datatype Schema — Design Notes

Design decisions, patterns, and open threads for the SHACL datatype schema
(`SCHEMA_QUDT-DATATYPES_NoOWL.ttl`). Read the pattern doc before touching one
of the open threads; the open-thread docs assume familiarity with it.

## Patterns

- **[spec-plus-values-pattern.md](spec-plus-values-pattern.md)** — the canonical
  way structured datatypes (tuples, arrays, future variants) are modelled in
  this schema. Covers the three cooperating shapes (instance / spec / member
  type spec), the four-alternative type facet, and SPARQL-constraint idioms
  including the SHACL pre-binding rule for sub-SELECTs that walk RDF lists via
  `rdf:rest*/rdf:first`.

## Open threads

- **[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md)** *(opened 2026-05-16)* —
  Giving `qudt:Array` the same spec-plus-values treatment as `qudt:NTuple`.
  Includes analysis of the existing (broken) `qudt:DimensionalityShape`
  constraint and two design choices for the value-list representation
  (nested vs flat). Pending a decision.

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
