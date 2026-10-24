# Validating the datatype constraints with the SHACL engine

**Written:** 2026-10-19 (branch `rh-arrays-cusp2`)
**Status:** current — keep the expected results below in step with the examples
**Related files:** the datatype and main SHACL schemas in `src/main/rdf/schema/shacl/` and the three
`EXAMPLES_QUDT-*DATATYPES.ttl` files in `src/main/rdf/examples/`

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
graph*. The checker below calls TopBraid directly, with report details off.

## Running the check

You need Maven, a JDK 11 or newer (for single-file `java EngineCheck.java` launches; tested
with JDK 25), and the plugin's jars in `~/.m2`, which any normal build puts there. Everything
runs offline.

Save the checker as `EngineCheck.java` in a work directory, save the script as
`engine-check.sh`, and run the script from the repository root:

```bash
WORK=/tmp/qudt-engine-check bash engine-check.sh
```

### `EngineCheck.java`

```java
import org.apache.jena.rdf.model.*;
import org.apache.jena.riot.RDFDataMgr;
import org.topbraid.shacl.validation.ValidationEngineConfiguration;
import org.topbraid.shacl.validation.ValidationUtil;

/**
 * Runs the build's SHACL engine (TopBraid, via the same jars as shacl-maven-plugin) with report
 * details off — the plugin hard-codes them on, which breaks on the schema shapes.
 * Prints one TSV line per result: focus node, severity, source constraint, message, value, path.
 */
public class EngineCheck {
    static final String SH = "http://www.w3.org/ns/shacl#";

    public static void main(String[] args) {
        Model shapes = RDFDataMgr.loadModel(args[0]);
        Model data = RDFDataMgr.loadModel(args[1]);
        ValidationEngineConfiguration conf =
                new ValidationEngineConfiguration().setReportDetails(false).setValidateShapes(false);
        Resource report = ValidationUtil.validateModel(data, shapes, conf);
        Property result = report.getModel().createProperty(SH + "result");
        int n = 0;
        for (StmtIterator it = report.listProperties(result); it.hasNext(); n++) {
            Resource r = it.next().getResource();
            String source = text(data, r, "sourceConstraint");
            if (source.isEmpty() || source.equals("_:blank")) source = text(data, r, "sourceConstraintComponent");
            System.out.println(String.join("\t", text(data, r, "focusNode"), text(data, r, "resultSeverity"),
                    source, text(data, r, "resultMessage").replace('\n', ' '), text(data, r, "value"),
                    text(data, r, "resultPath")));
        }
        System.err.println("results: " + n);
    }

    static String text(Model prefixes, Resource r, String localName) {
        Statement s = r.getProperty(r.getModel().createProperty(SH + localName));
        if (s == null) return "";
        RDFNode o = s.getObject();
        if (o.isURIResource()) return prefixes.shortForm(o.asResource().getURI());
        if (o.isLiteral()) return o.asLiteral().getLexicalForm();
        return "_:blank";
    }
}
```

### `engine-check.sh`

```bash
#!/usr/bin/env bash
# Run from the repository root:  WORK=/tmp/qudt-engine-check bash engine-check.sh
set -euo pipefail
WORK=${WORK:-/tmp/qudt-engine-check}
mkdir -p "$WORK"
SH=src/main/rdf/schema/shacl
EX=src/main/rdf/examples
SCHEMAS=("$SH/SCHEMA_QUDT-DATATYPES_NoOWL.ttl" "$SH/SCHEMA_QUDT_NoOWL.ttl")
EXAMPLES=("$EX/EXAMPLES_QUDT-DATATYPES.ttl" "$EX/EXAMPLES_QUDT-INVALID-DATATYPES.ttl"
          "$EX/EXAMPLES_QUDT-IFC-DATATYPES.ttl")

# 1. Give the units and quantity kinds the examples use a type, so sh:class facets can resolve
{ echo '@prefix qudt: <http://qudt.org/schema/qudt/> .'
  echo '@prefix unit: <http://qudt.org/vocab/unit/> .'
  echo '@prefix quantitykind: <http://qudt.org/vocab/quantitykind/> .'
  grep -hoE 'unit:[A-Za-z0-9_-]+' "${EXAMPLES[@]}" | sort -u | sed 's/$/ a qudt:Unit ./'
  grep -hoE 'quantitykind:[A-Za-z0-9_-]+' "${EXAMPLES[@]}" | sort -u | sed 's/$/ a qudt:QuantityKind ./'
} > "$WORK/stub.ttl"

# 2. Shapes graph = schemas + examples; data graph = shapes graph + stub + datatype vocabulary
cat "${SCHEMAS[@]}" "${EXAMPLES[@]}" > "$WORK/shapes.ttl"
cat "$WORK/shapes.ttl" "$WORK/stub.ttl" src/main/rdf/vocab/types/VOCAB_QUDT-DATATYPES.ttl > "$WORK/data.ttl"

# 3. The plugin's exact runtime classpath, read from Maven's debug output (offline: jars are in ~/.m2)
cat > "$WORK/pom.xml" <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>local</groupId><artifactId>engine-check</artifactId><version>1</version>
  <packaging>pom</packaging>
  <build><plugins><plugin>
    <groupId>io.github.qudtlib</groupId><artifactId>shacl-maven-plugin</artifactId><version>1.0.5</version>
    <executions><execution><phase>validate</phase><goals><goal>validate</goal></goals>
      <configuration><validations><validation>
        <shapes><include>shapes.ttl</include></shapes><data><include>data.ttl</include></data>
      </validation></validations></configuration>
    </execution></executions>
  </plugin></plugins></build>
</project>
EOF
# The plugin's own validation fails here ("Multiple reports found in graph"); only the classpath is wanted.
( cd "$WORK" && mvn -o -B -X validate > debug.log 2>&1 || true )
CP=$(awk '/Populating class realm plugin>io.github.qudtlib:shacl-maven-plugin/{p=1; next}
          p && /Included:/ {print $NF}
          p && /Populating class realm/ {exit}' "$WORK/debug.log" |
     awk -F: -v m2="$HOME/.m2/repository" \
         '$3=="jar" {g=$1; gsub(/\./, "/", g); printf "%s/%s/%s/%s/%s-%s.jar:", m2, g, $2, $4, $2, $4}')
# slf4j-api is supplied to plugins by Maven core, so it is not in the plugin realm; take Maven's own copy
MAVEN_HOME=$(mvn -v | awk -F': ' '/^Maven home/ {print $2}')
CP="$CP$(ls "$MAVEN_HOME"/lib/slf4j-api-*.jar | head -1)"

# 4. Validate (EngineCheck.java must be saved in $WORK)
java -cp "$CP" "$WORK/EngineCheck.java" "$WORK/shapes.ttl" "$WORK/data.ttl" > "$WORK/results.tsv"

# 5. Results on the example subjects, one line per (focus node, check) with a count
grep -hoE '^(ex|qudt):[A-Za-z0-9_-]+$' "${EXAMPLES[@]}" | sort -u > "$WORK/subjects.txt"
awk -F'\t' 'NR==FNR {s[$1]=1; next} ($1 in s) {print $1 "\t" $3}' "$WORK/subjects.txt" "$WORK/results.tsv" |
  sort | uniq -c
```

### What goes into each graph, and why

- **Shapes graph:** the datatype and main SHACL schemas and the three example files. The examples must be
  shapes too, because some constraints are defined in them
  (`ex:IfcCompoundPlaneAngleConsistentSign`); leave them out and those constraints silently
  don't run.
- **Data graph:** the same files, plus `VOCAB_QUDT-DATATYPES.ttl` and the stub.
  - SPARQL constraints are evaluated against the data graph, so the union lists they walk
    (`qudt:NumericUnionType`, the `qudt:Maybe…UnionType` family) must be in it.
  - The datatype vocabulary supplies the `qudt:Datatype` instances the examples refer to.
  - The stub gives a type to every `unit:` and `quantitykind:` IRI the examples use, so
    `sh:class qudt:Unit` facets resolve. Loading the full unit and quantity-kind
    vocabularies also works, but is slower and adds results to ignore.
- Concatenating the Turtle files is safe: repeated `@prefix` lines are allowed, and the files
  use anonymous blank nodes, so blank-node labels can't collide.
- Results on resources other than the examples — the stub's units, schema resources — are
  expected; step 5 filters them out. The full list is in `$WORK/results.tsv`.

## Expected results (2026-10-24)

Every bad example fires exactly its intended check:

|                    Example                    |                                            Check(s)                                            |
|-----------------------------------------------|------------------------------------------------------------------------------------------------|
| `ex:badExampleArrayRank`                      | `qudt:ArrayRankCheck`                                                                          |
| `ex:badExampleHeterogeneousArrayLength`       | `qudt:NTupleExtraValueCheck`, `qudt:NTupleLengthCheck`, `qudt:ValuesListLengthCheck`           |
| `ex:badExampleHeterogeneousArrayType`         | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleHeterogeneousVectorLength`      | `qudt:NTupleLengthCheck`, `qudt:NTupleMissingRequiredValueCheck`, `qudt:ValuesListLengthCheck` |
| `ex:badExampleHomogeneousArrayLength`         | `qudt:ValuesListLengthCheck`                                                                   |
| `ex:badExampleHomogeneousArrayType`           | `qudt:ValuesListElementTypeCheck`                                                              |
| `ex:badExampleQuantityValueTuple`             | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTuple2a`                        | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTuple2b`                        | `qudt:NTupleExtraValueCheck`, `qudt:NTupleLengthCheck`                                         |
| `ex:badExampleTuple3`                         | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTupleDateInDateTimePosition`    | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTupleIntegerInIntPosition`      | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTupleNothingInRequiredPosition` | `qudt:NTupleTypeCheck`                                                                         |
| `ex:badExampleTupleTimeInAnyDatePosition`     | `qudt:NTupleTypeCheck`                                                                         |
| `ex:cpaBadLengthShort`                        | `qudt:NTupleLengthCheck`, `qudt:NTupleMissingRequiredValueCheck`                               |
| `ex:cpaBadMicroseconds`                       | `qudt:NTupleRangeCheck`                                                                        |
| `ex:cpaBadMinutes`                            | `qudt:NTupleRangeCheck`                                                                        |
| `ex:cpaBadSeconds`                            | `qudt:NTupleRangeCheck`                                                                        |
| `ex:cpaBadSign`                               | `ex:IfcCompoundPlaneAngleConsistentSign` (reported twice)                                      |
| `ex:cpaBadType`                               | `qudt:NTupleTypeCheck`                                                                         |

`ex:cpaBadSign` is reported once per positive/negative pair in `( 52 -31 12 )`, because a
`SELECT` constraint yields one result per solution row; `SELECT DISTINCT $this` would make it
one.

The valid and IFC examples are clean, apart from two open items:

- `ex:ResourceLabelRatingTupleSpec` — position 2 uses only `sh:languageIn ( "en" )`, which is
  not one of the type facets `qudt:NTupleMemberTypeSpec-type` accepts, so the spec fails that
  shape and the position is never type-checked.
- The legacy arrays lack `qudt:datatypeKind`: five valid ones (`ex:Array_MassProperties_Rocket`
  and four `ex:StateSpaceMatrix-*`) and the two legacy invalid ones
  (`qudt:Array1D_Integers-INVALID`, `qudt:EX_Array1D_INVALID`). See "Still to do" B in
  [array-as-ntuple-parallel.md](array-as-ntuple-parallel.md).

`ex:Quantity_DroneVelocity3D`, whose value is a vector, failed `qudt:Quantifiable-value` from
2026-10-21, when the shape first checked anything, until 2026-10-22, when it began accepting any
`qudt:StructuredDatatype` instance. See "Still to do" F in
[array-as-ntuple-parallel.md](array-as-ntuple-parallel.md).

Any other result on an example subject is a regression.

## Comparing against an earlier version

To see what a constraint change does, run the check once against the current files and once
against an earlier copy of the changed file, then diff the two summaries:

```bash
git show <rev>:src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES_NoOWL.ttl > /tmp/datatypes-old.ttl
# point the datatype entry of SCHEMAS in engine-check.sh at /tmp/datatypes-old.ttl,
# rerun with a different WORK directory, and diff the two outputs
# (for a revision between 2026-08-24 and 2026-10-23, take the three split files instead)
```

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

