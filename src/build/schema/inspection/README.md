# Schema Inspection Allowlists

This folder contains helper files used by the Maven inspection command:

`mvn -DskipTests -Powl-schema-inspect rdfio:pipeline@inspect-owl-schema-diff -Drdfio.pipeline.forceRun=true`

That command compares two OWL schema files:

- `src/main/rdf/schema/SCHEMA_QUDT.ttl.backup`
  This is the older reference OWL file.
- `src/main/rdf/schema/SCHEMA_QUDT.ttl`
  This is the newly generated OWL file (derived from SHACL).

When the command compares those files, it finds added triples and removed triples.
Some of those differences are expected, and some are real problems.
The files in this folder define what should be treated as expected.

Think of these files as a "known differences" policy.

## What each file does

### `legacy-range-properties.ttl`

This file lists properties for which a missing `rdfs:range` triple is acceptable.

Plainly:
- If the old backup file had a range triple for one of these properties,
- and the new generated file does not,
- inspection will allow that removal.

Use this when old range statements are legacy behavior you no longer want to keep.

### `stub-range-properties.ttl`

This file lists properties for which a new `rdfs:range` triple is acceptable.

Plainly:
- If the new generated file has a range triple for one of these properties,
- and the backup file did not,
- inspection will allow that addition.

Use this when ranges are now being produced from newer SHACL/stub behavior.

### `metadata-predicates.ttl`

This file lists predicates that inspection should treat like metadata fields.

For these predicates, differences are interpreted more leniently when they match SHACL-driven expectations.
This helps avoid false alarms for descriptive metadata fields.

### `expected-metadata-added.ttl`

This file lists exact triples that are allowed to be newly added.

"Exact" means all three parts must match:
- subject
- predicate
- object

If one part is different, it is not considered a match.

### `expected-legacy-removals.ttl`

This file lists exact triples that are allowed to disappear.

Again, matching is exact:
- subject + predicate + object must be identical.

Use this for specific old triples you intentionally want gone.

### `property-type-objects.ttl`

This file lists allowed `rdf:type` object values used in property-type normalization
(for example `owl:ObjectProperty`, `owl:DatatypeProperty`).

These help inspection treat SHACL-derived type classifications consistently.

### `shacl-type-objects.ttl`

This file lists SHACL-only type objects (for example `sh:NodeShape`).

If these SHACL typing triples are missing from the OWL output, inspection treats that as expected.
That is normal, because OWL output is not meant to carry SHACL-only typing.

## Safe way to edit these files

When you change one of these files:

1. Make one small change at a time.
2. Run the inspection command.
3. Read:
   - `target/inspection/schema-diff/summary.txt`
   - `target/inspection/schema-diff/unexpected-added.txt`
   - `target/inspection/schema-diff/unexpected-removed.txt`
4. Keep or revert your change based on whether the result matches your intent.

This keeps inspection strict, and prevents the allowlists from growing without reason.

## Why this README exists

Turtle comments at the top of `.ttl` files may be reformatted or removed by tooling.
This Markdown file is the stable place for explanations written for humans.
