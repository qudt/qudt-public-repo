# Schema Inspection Allowlists (Plain-English Guide)

This folder contains small Turtle files that tell the inspection pipelines:

1. which schema differences are expected and acceptable
2. which schema differences should still fail the build

In short, these files are the "rules of interpretation" for schema diffs.

## Which commands use these files

Main OWL schema inspection:

`mvn -DskipTests -Powl-schema-inspect rdfio:pipeline@inspect-owl-schema-diff`

Datatype OWL schema inspection:

`mvn -DskipTests -Powl-datatypes-inspect rdfio:pipeline@inspect-owl-datatypes-schema-diff`

Each inspection compares:

1. a backup OWL schema (`*.ttl.backup`) as the old baseline
2. the newly derived OWL schema (`*.ttl`)

Then it writes reports under `target/inspection/...`.

## Mental model

Inspection first computes raw differences:

1. triples added in derived OWL
2. triples removed from derived OWL

After that, inspection filters out differences that are expected.
The files in this directory define those expected cases.

So if you edit one of these files, you are changing what inspection treats as:

1. acceptable differences
2. unexpected differences

## File-by-file: what changes if you edit it

### `expected-legacy-removals.ttl`

Scope: main OWL schema.

This file contains exact triples that are allowed to disappear from the derived OWL schema.

What happens if you add a triple here:

1. if that exact triple is missing in the derived OWL file
2. it will be counted as expected
3. it will not show up as an unexpected removal

Use this for one-off legacy triples you intentionally retired.

### `expected-metadata-added.ttl`

Scope: main OWL schema.

This file contains exact triples that are allowed to appear newly in the derived OWL schema.

What happens if you add a triple here:

1. if that exact triple appears in derived OWL and was not in backup
2. it is treated as expected
3. it does not fail the inspection gate

Use this mostly for approved metadata additions.

### `legacy-range-properties.ttl`

Scope: main OWL schema.

This file lists properties for which dropped `rdfs:range` statements are acceptable.

What happens if you add a property here:

1. if backup had `<thatProperty> rdfs:range ...`
2. and derived OWL removed it
3. removal is treated as expected

Use when an old range statement is known legacy behavior and should stay removed.

### `stub-range-properties.ttl`

Scope: main OWL schema.

This file lists properties for which newly added `rdfs:range` statements are acceptable.

What happens if you add a property here:

1. if derived OWL adds `<thatProperty> rdfs:range ...`
2. and backup did not have that range
3. addition is treated as expected

Use when new SHACL/stub modeling now produces ranges that did not exist before.

### `metadata-predicates.ttl`

Scope: main OWL schema.

This file lists predicates considered "metadata-like" in diff normalization.

What happens if you add a predicate here:

1. differences using that predicate may be treated more leniently
2. especially when SHACL carries corresponding subject/predicate evidence
3. fewer metadata-only false alarms in `unexpected-*` reports

Use carefully; this broadens filtering for that predicate.

### `property-type-objects.ttl`

Scope: main OWL schema.

This file lists allowed `rdf:type` objects for property typing normalization
(for example `owl:ObjectProperty`, `owl:DatatypeProperty`).

What happens if you add a type object here:

1. type shifts to that object may be considered expected
2. when supported by SHACL path/type derivation logic

Use when a type object is a valid SHACL-driven property classification.

### `shacl-type-objects.ttl`

Scope: main and datatype schema inspection.

This file lists SHACL-only class objects (for example `sh:NodeShape`, `sh:PropertyShape`).

What happens if you add an object here:

1. removal of `rdf:type <thatObject>` from OWL output is treated as expected
2. because OWL output intentionally strips SHACL-only typing

Use only for SHACL vocabulary types that should not survive in OWL files.

### `datatype-expected-legacy-removals.ttl`

Scope: datatype OWL schema.

Same idea as `expected-legacy-removals.ttl`, but for datatype schema.

This file contains exact removed triples that are accepted in datatype OWL derivation.

### `datatype-expected-metadata-added.ttl`

Scope: datatype OWL schema.

Same idea as `expected-metadata-added.ttl`, but for datatype schema.

This file contains exact metadata triples that are allowed to be newly added.

### `datatype-expected-added.ttl`

Scope: datatype OWL schema.

This file contains exact non-metadata triples that are allowed to be newly added.

Use this when datatype OWL derivation now produces a real schema triple you accept
(for example, a new `rdfs:range` inferred from SHACL), and you want inspection to
stop reporting it as unexpected.

### `datatype-metadata-predicates.ttl`

Scope: datatype OWL schema.

Same idea as `metadata-predicates.ttl`, but for datatype schema.

This file defines which predicates are treated as metadata-like during datatype diff filtering.

## Practical editing workflow

When you change any file in this folder:

1. make a small, focused change
2. rerun the relevant inspection command
3. check these outputs first:
   1. `summary.txt`
   2. `unexpected-added.txt`
   3. `unexpected-removed.txt`
   4. `unexpected-by-predicate.txt`
4. confirm that only intended differences moved from unexpected to expected

## What not to do

1. Do not add large batches to allowlists just to "make it green".
2. Do not treat these files as a place to hide unknown regressions.
3. Do not put general SHACL/OWL modeling rules here if they belong in derivation logic.

These files should stay small and explicit.
If a pattern is truly general, prefer implementing it in derivation or normalization SPARQL, not by listing many one-off triples.

## Why this README is in Markdown (not Turtle comments)

Tooling can reformat Turtle files and remove or rearrange comments.
This README is meant to be the stable, human-readable explanation of what each allowlist does.
