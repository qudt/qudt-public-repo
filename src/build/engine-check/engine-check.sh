#!/usr/bin/env bash
# Validates the datatype examples against the SHACL datatype constraints in the build's own SHACL
# engine (TopBraid SHACL, on the shacl-maven-plugin's classpath). The Maven build never runs the
# tuple, array and vector constraints against the examples; this does. See
# src/main/rdf/schema/shacl/design-notes/validating-with-the-shacl-engine.md for what the results
# should be.
#
# Usage, from any directory:
#   src/build/engine-check/engine-check.sh
#
# Options, as environment variables:
#   WORK=<dir>              where to write the graphs and results (default: target/engine-check)
#   COORDINATES=1           also load the coordinates schema and vocabulary
#   DATATYPE_SCHEMA=<file>  use this file in place of SCHEMA_QUDT-DATATYPES_NoOWL.ttl, for example
#                           an earlier version taken with git show
#   BASELINE=<results.tsv>  compare the results with those of an earlier run
#
# Needs Java 11 or later and Maven, with the build's dependencies already downloaded: Maven runs
# offline here, only to resolve the plugin's classpath.
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)
CALLER=$PWD
abspath() { case "$1" in /*) echo "$1" ;; *) echo "$CALLER/$1" ;; esac; }

WORK=$(abspath "${WORK:-$ROOT/target/engine-check}")
DATATYPE_SCHEMA=${DATATYPE_SCHEMA:+$(abspath "$DATATYPE_SCHEMA")}
BASELINE=${BASELINE:+$(abspath "$BASELINE")}
cd "$ROOT"
mkdir -p "$WORK"

SH=src/main/rdf/schema/shacl
EX=src/main/rdf/examples
SCHEMAS=("${DATATYPE_SCHEMA:-$SH/SCHEMA_QUDT-DATATYPES_NoOWL.ttl}" "$SH/SCHEMA_QUDT_NoOWL.ttl")
EXAMPLES=("$EX/EXAMPLES_QUDT-DATATYPES.ttl" "$EX/EXAMPLES_QUDT-INVALID-DATATYPES.ttl"
          "$EX/EXAMPLES_QUDT-TUPLE-DATATYPES.ttl")
VOCABS=(src/main/rdf/vocab/types/VOCAB_QUDT-DATATYPES.ttl)
if [[ "${COORDINATES:-}" == 1 ]]; then
  SCHEMAS+=("$SH/SCHEMA_QUDT-COORDINATES_NoOWL.ttl")
  VOCABS+=(src/main/rdf/vocab/coordinates/VOCAB_QUDT-COORDINATES.ttl)
fi

# 1. Give the units and quantity kinds the examples use a type, so sh:class facets can resolve
{ echo '@prefix qudt: <http://qudt.org/schema/qudt/> .'
  echo '@prefix unit: <http://qudt.org/vocab/unit/> .'
  echo '@prefix quantitykind: <http://qudt.org/vocab/quantitykind/> .'
  grep -hoE 'unit:[A-Za-z0-9_-]+' "${EXAMPLES[@]}" | sort -u | sed 's/$/ a qudt:Unit ./'
  grep -hoE 'quantitykind:[A-Za-z0-9_-]+' "${EXAMPLES[@]}" | sort -u | sed 's/$/ a qudt:QuantityKind ./'
} > "$WORK/stub.ttl"

# 2. Shapes graph = schemas + examples; data graph = shapes graph + stub + vocabularies
cat "${SCHEMAS[@]}" "${EXAMPLES[@]}" > "$WORK/shapes.ttl"
cat "$WORK/shapes.ttl" "$WORK/stub.ttl" "${VOCABS[@]}" > "$WORK/data.ttl"

# 3. The plugin's exact runtime classpath, read from Maven's debug output, for the plugin version
#    the build uses
PLUGIN_VERSION=$(awk '/<artifactId>shacl-maven-plugin<\/artifactId>/ {
  getline; gsub(/.*<version>|<\/version>.*/, ""); print; exit }' pom.xml)
if [[ -z "$PLUGIN_VERSION" ]]; then
  echo "Cannot find the shacl-maven-plugin version in pom.xml" >&2
  exit 1
fi
cat > "$WORK/pom.xml" <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>local</groupId><artifactId>engine-check</artifactId><version>1</version>
  <packaging>pom</packaging>
  <build><plugins><plugin>
    <groupId>io.github.qudtlib</groupId><artifactId>shacl-maven-plugin</artifactId><version>${PLUGIN_VERSION}</version>
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
if [[ -z "$CP" ]]; then
  echo "Cannot read the plugin's classpath; see $WORK/debug.log" >&2
  exit 1
fi
# slf4j-api is supplied to plugins by Maven core, so it is not in the plugin realm; take Maven's own copy
MAVEN_HOME=$(mvn -v | awk -F': ' '/^Maven home/ {print $2}')
CP="$CP$(ls "$MAVEN_HOME"/lib/slf4j-api-*.jar | head -1)"

# 4. Validate
java -cp "$CP" "$HERE/EngineCheck.java" "$WORK/shapes.ttl" "$WORK/data.ttl" > "$WORK/results.tsv"

# 5. Results on the example subjects, one line per (focus node, check) with a count
grep -hoE '^(ex|qudt):[A-Za-z0-9_-]+$' "${EXAMPLES[@]}" | sort -u > "$WORK/subjects.txt"
awk -F'\t' 'NR==FNR {s[$1]=1; next} ($1 in s) {print $1 "\t" $3}' "$WORK/subjects.txt" "$WORK/results.tsv" |
  sort | uniq -c
echo "$(wc -l < "$WORK/results.tsv" | tr -d ' ') results in all, in $WORK/results.tsv"

# 6. Compare with an earlier run, ignoring blank-node labels
if [[ -n "${BASELINE:-}" ]]; then
  normalise() { sed -E 's/_:[0-9a-f]+/_:b/g' "$1" | sort; }
  if diff <(normalise "$BASELINE") <(normalise "$WORK/results.tsv") > "$WORK/baseline.diff"; then
    echo "Same results as $BASELINE"
  else
    echo "Differences from $BASELINE (< there, > here):"
    cat "$WORK/baseline.diff"
  fi
fi
