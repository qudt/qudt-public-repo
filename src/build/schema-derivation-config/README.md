# Schema Derivation Configuration

This directory contains the checked-in configuration that controls two related
but different parts of the OWL schema workflow:

1. deriving OWL schema files from SHACL source files
2. inspecting the derived OWL schema files against accepted OWL baselines

In short:

- `derivation/` changes what the generated OWL schema files contain
- `inspection/` changes how the diff reports decide which changes are expected

That separation is intentional.
If these files were mixed together, it would be too easy to confuse:

1. rules that generate schema content
2. rules that merely classify differences during review

The result would be harder maintenance and a greater risk of hiding real
regressions.

## How To Think About This Directory

The SHACL schema files under `src/main/rdf/schema/shacl/` are the source of
truth.
The derivation pipelines use the files in `derivation/` to help turn those
SHACL sources into:

- `src/main/rdf/schema/SCHEMA_QUDT.ttl`
- `src/main/rdf/schema/SCHEMA_QUDT-DATATYPE.ttl`

The inspection pipelines then compare those derived OWL files against the
accepted backup baselines:

- `src/main/rdf/schema/SCHEMA_QUDT.ttl.backup`
- `src/main/rdf/schema/SCHEMA_QUDT-DATATYPE.ttl.backup`

The files in `inspection/` tell inspection which differences are acceptable and
which should still be treated as unexpected.

## Which Commands Use These Files

Main schema derivation:

`mvn -DskipTests -Powl-schema-derive rdfio:pipeline@derive-owl-schema`

Datatype schema derivation:

`mvn -DskipTests -Powl-datatypes-derive rdfio:pipeline@derive-owl-datatypes-schema`

Main schema inspection:

`mvn -DskipTests -Powl-schema-inspect rdfio:pipeline@inspect-owl-schema-diff`

Datatype schema inspection:

`mvn -DskipTests -Powl-datatypes-inspect rdfio:pipeline@inspect-owl-datatypes-schema-diff`

## Folder Rationale

### `derivation/`

This folder contains a very small number of files because derivation should be
driven mostly by SHACL and SPARQL logic in `pom.xml`, not by a large pile of
special-case data files.

These files exist only where a small checked-in data input is cleaner than
hard-coding the same information directly into Maven XML.

### `inspection/`

This folder contains more files because inspection has a different job.
Inspection is not generating schema.
It is reviewing the difference between:

1. the accepted OWL baseline
2. the newly derived OWL output

That means inspection needs explicit allowlists and classification files so the
reports can distinguish:

1. intended changes
2. legacy cleanup
3. metadata-only changes
4. possible regressions

## Derivation Files

### `derivation/OWL-derivation-prefixes.ttl`

This file seeds the derivation dataset with prefix declarations.
It exists so the generated OWL files can be written with readable prefixes
instead of long full IRIs.

It does not define schema semantics by itself.
It only affects serialization readability and prefix availability during
derivation.

### `derivation/OWL-derivation-overlay.ttl`

This file contains explicit triples that must be added to the derived main OWL
schema after the SHACL-driven derivation logic has run.

Use this only for cases where:

1. the SHACL source is intentionally not carrying the needed OWL statement
2. the statement is still required for current compatibility or correctness

If a rule can be derived generally from SHACL, that is usually better than
putting the triple here.

### `derivation/OWL-derivation-overlay-datatype.ttl`

This is the datatype-schema counterpart to `OWL-derivation-overlay.ttl`.

It contains explicit triples that are injected into the derived OWL datatype
schema when they should not yet be modeled directly in the SHACL datatype
source, or when a temporary compatibility override is still required.

## Inspection Files

These files do not change the generated OWL schema directly.
They only change how the diff reports classify derived-vs-backup differences.

### `inspection/expected-legacy-removals.ttl`

Scope: main OWL schema.

This file lists exact triples that are allowed to disappear from the derived
main OWL schema.

Use it when a triple exists only because of legacy OWL history and its removal
is intentional.

### `inspection/expected-metadata-added.ttl`

Scope: main OWL schema.

This file lists exact metadata triples that are allowed to appear newly in the
derived main OWL schema.

Use it for approved metadata additions that should not fail inspection.

### `inspection/legacy-range-properties.ttl`

Scope: main OWL schema.

This file lists properties whose old `rdfs:range` statements may disappear from
the derived main OWL schema without being treated as a problem.

Use it when an older OWL range is being intentionally retired.

### `inspection/stub-range-properties.ttl`

Scope: main OWL schema.

This file lists properties whose newly added `rdfs:range` statements are
acceptable in the main OWL schema.

Use it when current SHACL modeling now supports a range that the backup OWL
schema never had.

### `inspection/metadata-predicates.ttl`

Scope: main OWL schema.

This file lists predicates that inspection should treat as metadata-like.

That allows the reports to be more tolerant when SHACL already carries the same
subject/predicate pair but the value differs from the old OWL backup.

### `inspection/property-type-objects.ttl`

Scope: main OWL schema.

This file lists `rdf:type` objects that are valid as property-typing outcomes in
the main OWL inspection logic.

It helps inspection recognize some property typing changes as expected rather
than suspicious.

### `inspection/shacl-type-objects.ttl`

Scope: main and datatype OWL inspection.

This file lists SHACL-only type objects such as `sh:NodeShape` and
`sh:PropertyShape`.

It exists because those types are expected to disappear in OWL output, and
inspection should not complain about that.

### `inspection/datatype-expected-legacy-removals.ttl`

Scope: datatype OWL schema.

This is the datatype counterpart to `expected-legacy-removals.ttl`.

It lists exact triples that may disappear from the derived OWL datatype schema
without being treated as unexpected.

### `inspection/datatype-expected-metadata-added.ttl`

Scope: datatype OWL schema.

This is the datatype counterpart to `expected-metadata-added.ttl`.

It lists exact metadata triples that may be newly added to the derived OWL
datatype schema.

### `inspection/datatype-expected-added.ttl`

Scope: datatype OWL schema.

This file lists exact non-metadata triples that may be newly added to the
derived OWL datatype schema.

Use it when the datatype derivation now produces a real OWL schema statement
that is correct, accepted, and newer than the backup baseline.

### `inspection/datatype-metadata-predicates.ttl`

Scope: datatype OWL schema.

This is the datatype counterpart to `metadata-predicates.ttl`.

It lists predicates that inspection should treat as metadata-like when comparing
the derived OWL datatype schema against its backup baseline.

## Practical Editing Guidance

When changing files under `derivation/`:

1. ask whether the behavior should really be derived from SHACL instead
2. keep overlays small and explicit
3. rerun the matching derive pipeline
4. inspect the resulting OWL file and diff reports

When changing files under `inspection/`:

1. assume you are changing review policy, not schema generation
2. make the smallest possible allowlist change
3. rerun the matching inspect pipeline
4. confirm that only intended differences moved from unexpected to expected

## What Not To Do

1. Do not move general derivation logic into large allowlists.
2. Do not use inspection files to hide changes that are not yet understood.
3. Do not use overlay files when the same result can be derived cleanly from
   SHACL with a general SPARQL rule.

## Why This README Is Markdown

These configuration files are mostly Turtle, and formatting tools may reorder or
remove comments inside Turtle files.
This README is the stable, human-readable explanation of the directory as a
whole.
