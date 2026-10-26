# Validating the datatype constraints with the SHACL engine

**Written:** 2026-10-19 (branch `rh-arrays-cusp2`)
**Status:** current — keep the expected results below in step with the examples
**Related files:** the checker in `src/build/engine-check/`, the datatype and main SHACL schemas in
`src/main/rdf/schema/shacl/`, and the example files in `src/main/rdf/examples/valid_examples/` and
`src/main/rdf/examples/invalid_examples/`

## Why this is needed

The build never runs the structured-datatype constraints against the examples. It validates
the examples only against `src/main/rdf/validation/QUDT_SRC_QA_TESTS.ttl`, and the schema
files only against `src/build/validation/SHACL-SHACL.ttl`. A passing `mvn clean install`
therefore says nothing about whether `NTupleTypeCheck`, `ArrayRankCheck` and the other
`sh:sparql` constraints accept the valid examples and reject the bad ones. Run the check
below after changing any of those constraints, the type unions they read, or the examples.

## Which engine

TopBraid SHACL 1.4.3 on Jena 4.10.0 — the versions `io.github.qudtlib:shacl-maven-plugin`
1.0.5 runs in the build. The check uses that plugin's exact classpath, so its results are
what the build's engine reports.

## Why the plugin can't be used directly

The plugin hard-codes `setReportDetails(true)` (and `setValidateShapes(false)`); its only
settings are `validations`, `failOnSeverity` and `logSeverity`. With the schemas as the
shapes graph, TopBraid's detailed report contains more than one `sh:ValidationReport`, and
the plugin's call to Jena's `ValidationReport.fromModel` fails with *Multiple reports found in
graph*. The checker in `src/build/engine-check/` calls TopBraid directly, with report details off.

## Running the check

The checker and its script are in the repository, in `src/build/engine-check/`:

- `EngineCheck.java` calls TopBraid directly, with report details off, and prints one
  tab-separated line per result: focus node, severity, source constraint, message, value and path.
- `engine-check.sh` builds the two graphs, reads the plugin's exact classpath from Maven, runs the
  checker and summarises the results.

You need Maven, a JDK 11 or newer (for single-file `java EngineCheck.java` launches; tested
with JDK 25), and the plugin's jars in `~/.m2`, which any normal build puts there. Maven runs
offline, only to resolve the classpath. Run the script from any directory:

```bash
src/build/engine-check/engine-check.sh
```

It prints one line per (example, check) with a count, then the total. The graphs, Maven's debug
output and the full `results.tsv` go to `target/engine-check/`, which `mvn clean` removes.
The script reads the `shacl-maven-plugin` version from `pom.xml`, so it always runs the build's
engine. Options, as environment variables:

|         Variable         |                                  Effect                                  |
|--------------------------|--------------------------------------------------------------------------|
| `WORK=<dir>`             | write to this directory instead of `target/engine-check/`                |
| `COORDINATES=1`          | also load the coordinates schema and vocabulary, which the default omits |
| `DATATYPE_SCHEMA=<file>` | use this file in place of `SCHEMA_QUDT-DATATYPES_NoOWL.ttl`              |
| `BASELINE=<results.tsv>` | compare the results with an earlier run's, ignoring blank-node labels    |

Until 2026-10-24 this note embedded both files, to be copied into a scratch directory; a copy
there was lost once, which is why they now live in the repository.

### What goes into each graph, and why

- **Shapes graph:** the datatype and main SHACL schemas and the ten example files. The examples must be
  shapes too, because some constraints are defined in them
  (`ex:IfcCompoundPlaneAngleConsistentSign`); leave them out and those constraints silently
  don't run.
- **Data graph:** the same files, plus `VOCAB_QUDT-DATATYPES.ttl` and the stub. With
  `COORDINATES=1`, both graphs also get the coordinates schema and `VOCAB_QUDT-COORDINATES.ttl`,
  which the state-space vector types need.
  - SPARQL constraints are evaluated against the data graph, so the union lists they walk
    (`qudt:NumericUnionType`, the `qudt:Maybe…UnionType` family) must be in it.
  - The datatype vocabulary supplies the `qudt:Datatype` instances the examples refer to.
  - The stub gives a type to every `unit:` and `quantitykind:` IRI the examples use, so
    `sh:class qudt:Unit` facets resolve. Loading the full unit and quantity-kind
    vocabularies also works, but is slower and adds results to ignore.
- Concatenating the Turtle files is safe: repeated `@prefix` lines are allowed, and the files
  use anonymous blank nodes, so blank-node labels can't collide.
- Results on resources other than the examples — the stub's units, schema resources — are
  expected; the script's summary leaves them out. The full list is in `results.tsv`.

## Expected results (2026-10-25)

Every bad example fires exactly its intended check. All of them are in
`src/main/rdf/examples/invalid_examples/`:

|                     Example                      |                       File                       |                                                  Check(s)                                                   |
|--------------------------------------------------|--------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `ex:Array1D_Integers-INVALID`                    | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:ValuesListLengthCheck`                                                                                |
| `ex:List_3_Strings_INVALID`                      | `EXAMPLES_QUDT-INVALID-DATATYPES.ttl`            | `qudt:ListElementTypeCheck`                                                                                 |
| `ex:List_Decimal_Values_INVALID`                 | `EXAMPLES_QUDT-INVALID-DATATYPES.ttl`            | `qudt:ListElementTypeCheck` (reported four times, once per element)                                         |
| `ex:Quantity_RoomTemperature-INVALID`            | `EXAMPLES_QUDT-INVALID-QUANTITIES.ttl`           | `sh:OrConstraintComponent` (from `qudt:Quantifiable-value`)                                                 |
| `ex:badExampleArrayRank`                         | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:ArrayRankCheck`                                                                                       |
| `ex:badExampleCollectionElementType`             | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `qudt:ValuesListElementTypeCheck`                                                                           |
| `ex:badExampleCollectionNoKind`                  | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `sh:MinCountConstraintComponent` (from `qudt:Collection-datatypeKind`)                                      |
| `ex:badExampleHeterogeneousArrayKindElementType` | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:NodeConstraintComponent` (from `qudt:HeterogenousArrayKind`: not a `qudt:HeterogeneousCellsShape`)      |
| `ex:badExampleHeterogeneousArrayLength`          | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:NTupleExtraValueCheck`, `qudt:NTupleLengthCheck`, `qudt:ValuesListLengthCheck`                        |
| `ex:badExampleHeterogeneousArrayType`            | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleHeterogeneousVectorLength`         | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:NTupleLengthCheck`, `qudt:NTupleMissingRequiredValueCheck`, `qudt:ValuesListLengthCheck`              |
| `ex:badExampleHomogeneousArrayKindMemberSpecs`   | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:NodeConstraintComponent` (from `qudt:HomogeneousArrayKind`: not a `qudt:HomogeneousCellsShape`)         |
| `ex:badExampleHomogeneousArrayLength`            | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:ValuesListLengthCheck`                                                                                |
| `ex:badExampleHomogeneousArrayType`              | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:ValuesListElementTypeCheck`                                                                           |
| `ex:badExampleMapDuplicateKey`                   | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `qudt:MapDistinctKeysCheck`                                                                                 |
| `ex:badExampleMapKeyType`                        | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `qudt:MapKeyTypeCheck`                                                                                      |
| `ex:badExampleMapLength`                         | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `qudt:MapKeysLengthCheck`                                                                                   |
| `ex:badExampleMemberSpecKindSharedUnit`          | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:OrConstraintComponent` (from `qudt:VectorKind`: neither alternative of `qudt:CellDescriptionUnionType`) |
| `ex:badExampleMemberSpecQuantityKind`            | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `sh:ClassConstraintComponent` (from `qudt:NTupleMemberTypeSpec-hasQuantityKind`)                            |
| `ex:badExampleQuantityValueTuple`                | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleSetDuplicate`                      | `EXAMPLES_QUDT-INVALID-COLLECTION-DATATYPES.ttl` | `qudt:SetDistinctValuesCheck`                                                                               |
| `ex:badExampleTuple2a`                           | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleTuple2b`                           | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleExtraValueCheck`, `qudt:NTupleLengthCheck`                                                      |
| `ex:badExampleTuple3`                            | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleTupleDateInDateTimePosition`       | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleTupleIntegerInIntPosition`         | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleTupleKindElementType`              | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `sh:NodeConstraintComponent` (from `qudt:NTupleKind`: not a `qudt:HeterogeneousCellsShape`)                 |
| `ex:badExampleTupleKindEmptyMemberSpecs`         | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `sh:NotConstraintComponent` (from `qudt:StructuredDataKind-nonEmptyTupleMemberSpecs`)                       |
| `ex:badExampleTupleLabelLanguage`                | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleLanguageCheck`                                                                                  |
| `ex:badExampleTupleNothingInRequiredPosition`    | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleTupleTimeInAnyDatePosition`        | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |
| `ex:badExampleVectorKindBothCellDescriptions`    | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:OrConstraintComponent` (from `qudt:VectorKind`: neither alternative of `qudt:CellDescriptionUnionType`) |
| `ex:badExampleVectorKindDatatype`                | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:MaxCountConstraintComponent` (from `qudt:StructuredDataKind-datatype`)                                  |
| `ex:badExampleVectorKindNoCellDescription`       | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `sh:OrConstraintComponent` (from `qudt:VectorKind`: neither alternative of `qudt:CellDescriptionUnionType`) |
| `ex:badExampleVectorLatitudeRange`               | `EXAMPLES_QUDT-INVALID-ARRAY-DATATYPES.ttl`      | `qudt:NTupleRangeCheck`                                                                                     |
| `ex:cpaBadLengthShort`                           | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleLengthCheck`, `qudt:NTupleMissingRequiredValueCheck`                                            |
| `ex:cpaBadMicroseconds`                          | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleRangeCheck`                                                                                     |
| `ex:cpaBadMinutes`                               | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleRangeCheck`                                                                                     |
| `ex:cpaBadSeconds`                               | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleRangeCheck`                                                                                     |
| `ex:cpaBadSign`                                  | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `ex:IfcCompoundPlaneAngleConsistentSign` (reported twice)                                                   |
| `ex:cpaBadType`                                  | `EXAMPLES_QUDT-INVALID-TUPLE-DATATYPES.ttl`      | `qudt:NTupleTypeCheck`                                                                                      |

The units of the examples are not checked here but by the build, against the built quantity-kind
vocabulary, since `qudt:applicableUnit` is inferred there (see "Units of the examples" below).

`ex:cpaBadSign` is reported once per positive/negative pair in `( 52 -31 12 )`, because a
`SELECT` constraint yields one result per solution row; `SELECT DISTINCT $this` would make it
one.

The six malformed kinds, added on 2026-10-24, are reported against the kind itself, with the engine's
generic message for `sh:or` or `sh:node`. A kind with both an element type and member specs, or
with neither, fails `qudt:CellDescriptionUnionType`; a kind that picks the wrong alternative for its
class passes the union but fails the class's own `sh:node`.

The valid examples are clean. Until 2026-10-25 `ex:NTupleKind_ResourceLabelRating` was not: its
position 2 gave only `sh:languageIn ( "en" )`, which is not a type facet, so the kind failed
`qudt:NTupleMemberTypeSpec-type`, reported both on the kind and on the member spec, and the position
was never type-checked. It now gives `sh:datatype rdf:langString` as well, and the new
`qudt:NTupleLanguageCheck` checks the language tag.

No legacy examples remain (resolved 2026-10-25). The four `ex:StateSpaceMatrix-*` and the two legacy
invalid arrays used to lack `qudt:datatypeKind` and were reported only for that. The matrices became
array kinds (`qudt:StateSpaceMatrix` is now a `qudt:HomogeneousArrayKind`). The two invalid arrays
were identical, so `ex:EX_Array1D_INVALID` was removed and `ex:Array1D_Integers-INVALID` now points at
a kind of two integer cells, so it is reported for its intended fault, three values. The two
invalid lists were tested by nothing until `qudt:ListElementTypeCheck` was added; the invalid
quantity now has a string value, which `qudt:Quantifiable-value` rejects; and a duplicate list, a
collection that stated no fault, and the collection's quantity were removed. See "Still to do" B in
[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md).

`ex:Quantity_DroneVelocity3D`, whose value is a vector, failed `qudt:Quantifiable-value` from
2026-10-21, when the shape first checked anything, until 2026-10-22, when it began accepting any
`qudt:StructuredDatatype` instance. See "Still to do" F in
[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md).

Any other result on an example subject is a regression.

## Units of the examples

Where a kind or member spec gives both a quantity kind and a unit, the unit should be one of the
quantity kind's applicable units. `src/main/rdf/validation/QUDT_DATATYPE_UNIT_QA_TESTS.ttl` checks this
with one warning shape, `qudt:UnitNotApplicableToQuantityKindWarning`, and two SPARQL constraints:
`qudt:QuantityKindWithoutApplicableUnitsCheck`, when the quantity kind lists no applicable units, and
`qudt:UnitApplicableToQuantityKindCheck`, when the unit is not among them. Both read
`qudt:applicableUnit` on the quantity kind, which only the build infers, so the check runs in the
Maven build, not in the engine check, against the built quantity-kind vocabulary in `target/dist`
and the SHACL datatype schema, which gives the target classes' subclasses:

- The valid examples must raise no warning; the build fails if they do
  (`target/validation/validationReport-unitQuantityKind-valid.ttl`).
- The invalid examples are reported only
  (`target/validation/validationReport-unitQuantityKind-invalid.ttl`), and should raise exactly two
  warnings, both from `qudt:UnitApplicableToQuantityKindCheck`:
  `ex:badExampleVectorKindUnitNotApplicable` (unit:M for quantitykind:LinearVelocity) and
  `ex:badExampleMemberSpecUnitNotApplicable` (unit:J for quantitykind:Torque).

Anyone can run the same check on their own data, with the shapes file and data that include the
built quantity-kind vocabulary.

## Comparing against an earlier version

To see what a constraint change does, run the check once against an earlier copy of the datatype
schema and once against the current files, comparing the second run with the first:

```bash
git show <rev>:src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES_NoOWL.ttl > target/datatypes-old.ttl
DATATYPE_SCHEMA=target/datatypes-old.ttl WORK=target/engine-check-old src/build/engine-check/engine-check.sh
BASELINE=target/engine-check-old/results.tsv src/build/engine-check/engine-check.sh
```

For a revision between 2026-08-24 and 2026-10-23, when the schema was split, concatenate the
three split files into the old copy instead.

This is how the `qudt:Maybe…UnionType` change to `NTupleTypeCheck` was confirmed: with the
check as it was before `73ed45d2`, every `( )` cell in the Maybe examples is flagged, and so is
`23.7` in `ex:MaybeTuple2_JustValues`; with the current check, none are.

## Pitfalls

- **A stale `sh:prefixes` target.** If the node a constraint's `sh:prefixes` points at no longer
  exists, the query can't be parsed and the constraint doesn't run. TopBraid reports a single
  result on the *shape* (`sh:SPARQLConstraintComponent`) and none on the data, which is easy to
  miss. This happened to `ConsistentSign` when the datatype schema was split on 2026-08-24.
  When the files were merged back on 2026-10-23, every `sh:prefixes` was pointed at the merged
  graph `<…/schema/shacl/datatype>`.
- **The same resource defined in two example files.** Loaded together, a duplicated tuple spec
  has two member lists, giving spurious max-count and length violations. Define each resource
  in one file and import that file where it's needed.
- **Missing vocabularies.** Without the datatype vocabulary and typed units and quantity kinds,
  class facets report false violations.
- **The XSD datatype declarations are load-bearing.** `VOCAB_QUDT-DATATYPES.ttl` declares every
  XSD datatype the schemas use (`xsd:boolean a rdfs:Datatype` and so on), because
  `qudt:ScalarDatatype-rdfsDatatype` requires `sh:class rdfs:Datatype` on `qudt:rdfsDatatype`, and
  `sh:class` is checked against the data graph. Without them, every datatype in the vocabulary that
  names an XSD type fails that shape (33 results on 2026-10-23). The Maven build never validates the
  vocabulary against these shapes, so only this check notices. Until 2026-10-23 the declarations
  lived in the SHACL datatype schema, which works only when the schema is loaded as data too.
- **Examples left out of the shapes graph.** Constraints defined in the examples don't run, and
  nothing reports their absence.

