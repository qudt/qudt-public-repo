# Array as NTuple-parallel — design discussion

**Opened:** 2026-05-16 (branch `rh-pr1440`, post-merge with `main`)
**Status:** open — flat representation confirmed; data order **implemented**. **Design revised
2026-08-22 (branch `rh-arrays`): the blueprint node is back as `qudt:ArrayKind`, reached by
`qudt:datatypeKind`.** This reverses the 2026-07-27 "self-describing array" decision. Array
constraints are **validated** (valid examples clean, every invalid example flagged); three
portability defects in the shared tuple engine were found and fixed in the process.
Read the revisions newest-first: "Design revision (2026-08-22)" supersedes
"Design revision (2026-07-27)", which in turn supersedes the `qudt:ArraySpec` sketch further down.
**Related file:** `src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES-STRUCTURED_NoOWL.ttl`
(split out of the former `SCHEMA_QUDT-DATATYPES_NoOWL.ttl` on 2026-08-24)

## Goal

Give `qudt:Array` the same spec-plus-values treatment as `qudt:NTuple`, so that the two structured
datatypes share a single modelling story. Stay entirely within the SHACL datatype schema; do not
touch the parallel OWL side (`SCHEMA_QUDT-DATATYPE.ttl`) as part of this work.

## Design revision (2026-08-22) — the `Array` / `ArrayKind` split

**This section supersedes "Design revision (2026-07-27)" below.** The self-describing array is
withdrawn: the type-level description of an array is separated from the instance that carries data.

**Decisions:**

1. **`qudt:ArrayKind` is a reusable blueprint**, reached from an instance by the new property
   `qudt:datatypeKind`. It holds rank (`qudt:dimensionality`), extents (`qudt:dimensions`), total
   cell count (`qudt:elementCount`), the linearisation (`qudt:dataOrder`), the
   homogeneous/heterogeneous flag (`qudt:isHeterogeneous`) and the element type(s)
   (`qudt:elementType` or `qudt:conformsToTupleSpec`).
2. **`qudt:Array` is the instance** and carries only two things: the flat value list
   (`qudt:values`) and a mandatory `qudt:datatypeKind` pointer (`sh:minCount 1`, `sh:maxCount 1`,
   `sh:class qudt:ArrayKind`).
3. **Why the reversal.** The 2026-07-27 rationale was that a blueprint pays off only when many
   instances share it, and an array's `dimensions` vary per instance. In practice they don't vary as
   much as assumed — `ex:3DHomogeneousArray1` and `ex:3DHomogeneousArray2` share one
   `ex:3DHomogeneousArrayKind`, and two temperature arrays share another. The split also removes the
   accepted trade-off of the previous revision: heterogeneous arrays **can** now share a reusable
   positional-type blueprint, because the `qudt:conformsToTupleSpec` pointer lives on the kind.
4. **Naming.** The blueprint is `ArrayKind`, not `ArraySpec`, and the link is the general
   `qudt:datatypeKind` rather than an array-specific `conformsToArraySpec` — leaving room for other
   structured datatypes to acquire a kind without a new property each time.
5. **Which node a violation is reported against** follows from where the data lives: rank faults are
   reported on the `ArrayKind` (it holds `dimensionality` and `dimensions`); length and element-type
   faults are reported on the `Array` (it holds `qudt:values`).

**Schema as implemented (now `SCHEMA_QUDT-DATATYPES-STRUCTURED_NoOWL.ttl`):**

Every array-shaped datatype now comes as an **instance/kind pair**: the instance carries the values,
the kind carries the description.

|                       Instance shape                        |                                                                                         Kind shape                                                                                         |               Instance-side constraints               |
|-------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| `qudt:Array` (`qudt:ValuesList`, `qudt:Array-datatypeKind`) | `qudt:ArrayKind` (`qudt:ArrayKind-dataOrder`, `-isHeterogeneous`, `-elementType`, `-elementCount`, `-conformsToTupleSpec`, plus `DimensionalityPropertyShape` / `DimensionsPropertyShape`) | `ValuesListLengthCheck`, `ValuesListElementTypeCheck` |
| `qudt:HomogeneousArray`                                     | `qudt:HomogeneousArrayKind`                                                                                                                                                                | inherited                                             |
| `qudt:HeterogenousArray`                                    | `qudt:HeterogenousArrayKind`                                                                                                                                                               | inherited, plus the four `NTuple*` checks             |
| `qudt:Vector`                                               | `qudt:VectorKind`                                                                                                                                                                          | `ValuesListLengthCheck`, `ValuesListElementTypeCheck` |

`ArrayRankCheck` is the one kind-side constraint (rank is a blueprint property). The value-list shape
and its two checks are named `qudt:ValuesList` / `ValuesListLengthCheck` / `ValuesListElementTypeCheck`
rather than `Array*`, because `qudt:Vector` shares them.

**The instance/kind distinction is load-bearing for the tuple checks.** The four `NTuple*`
constraints read `$this qudt:values`, so they must hang off the *instance* class
(`qudt:HeterogenousArray`), never the kind. Putting them on `qudt:HeterogenousArrayKind` makes them
match nothing on a real blueprint and pass silently — a whole dimension of checking disappears with
no error.

Property shapes declared on a kind are named for that kind (`qudt:ArrayKind-*`); only the shapes
genuinely declared on the instance keep the instance prefix. (`DimensionalityPropertyShape` and
`DimensionsPropertyShape` are shared and keep their generic names — renaming them is a separate
decision.)

**`qudt:Vector` is a sibling of `qudt:Array`, not a subclass.** It is `rdfs:subClassOf
qudt:StructuredDatatype` and carries its own `qudt:ValuesList` + `qudt:Vector-datatypeKind`; the
"a vector is a rank-1 array" relationship is expressed on the kind side, where `qudt:VectorKind`
is `rdfs:subClassOf qudt:ArrayKind`. `qudt:Vector-datatypeKind` is deliberately `sh:minCount 0`
for now: the four existing vector instances (`ex:Vector3D_FLOAT-DP`, `-SP`,
`ex:Vector_DroneVelocities_3D`, `datatype:QuaternionVector-DP`) still describe themselves in the
legacy `qudt:datatype` / `qudt:dimensions` / `qudt:value` (singular) style and have no kind.
Tighten to `sh:minCount 1` once they are migrated.

**Validation — no longer deferred.** Item A of the old "Still to do" list is closed. All three array
constraints plus the five tuple constraints were exercised against both example files (with the unit
and quantity-kind vocabularies loaded, which `sh:class qudt:Unit` checks need):

- **Valid examples: clean on all eight checks.**
- **Invalid examples: every one flagged, on its own check and no other** — `badExampleArrayRank`
  (rank, on the kind), `badExampleHomogeneousArrayLength` (length), `badExampleHomogeneousArrayType`
  (element type), `badExampleHeterogeneousArrayType` (position 3, via the tuple engine), and the
  IFC `cpaBad*` tuples correctly split across type / range / length / missing-value.

**Three portability defects found and fixed while validating.** All three were pre-existing and
affected plain `qudt:NTuple` as much as arrays; they are what the old "Validation status" section was
seeing but misattributed to a `$this` pre-binding quirk. Each was isolated to a specific SPARQL
construct — see `spec-plus-values-pattern.md`, Idioms 3 and 4, for the portable replacements.

1. **`UNION` branches inside `FILTER NOT EXISTS`** (`NTupleTypeCheck`, `ArrayElementTypeCheck`).
   A single branch works; UNION the branches and outer bindings stop being substituted, so every
   position is flagged. Replaced by one `OPTIONAL { … BIND(true AS ?xMatch) }` per alternative plus a
   `!BOUND(…)` filter.
2. **An aggregate alias joined across a sub-SELECT boundary** (`NTupleTypeCheck`,
   `NTupleRangeCheck`). `(COUNT(?previousCell) + 1 AS ?index)` was expected to join with the outer
   `?memberSpec qudt:index ?index`; engines are not required to do so, and a 6-position tuple
   produced a 6x6 cross product. Fixed by projecting the aggregate as `?position` and correlating
   explicitly with `FILTER ( ?position = ?index )`.
3. **`NTupleMissingRequiredValueCheck` was logically inverted** — it used `FILTER EXISTS`, firing when
   a required value *was* present, and reported every position of a valid tuple as missing. Rewritten
   without correlation at all: positions in a flat list are contiguous from 1, so a required position
   is missing exactly when `?index > ?valueCount`, where `?valueCount` is one uncorrelated `COUNT`
   joined on `$this`.

**Examples updated to the split.** Valid: each array now points at a kind
(`ex:3DHomogeneousArrayKind` shared by two arrays, `ex:3DTemperatureArrayKind` shared by two more,
`ex:2by3HeterogeneousArrayKind`). Invalid: each bad array gained a companion kind, and
`ex:badExampleArrayRank` **is** the `ArrayKind` (rank is a blueprint-level property), with a
well-formed companion array so the violation is attributable to the kind alone.

Also fixed in passing: `EXAMPLES_QUDT-DATATYPES.ttl` did not parse — an unclosed `qudt:values` list
in `ex:exampleTuple3` (pre-existing) and an undeclared `x:` prefix on `ex:3DTemperatureArray2`.

**Still open from this revision:**

- ~~`qudt:Vector`, `qudt:Matrix`, `qudt:HomogeneousArray` and `qudt:HeterogenousArray` straddle the
  split.~~ **Resolved for three of the four (2026-08-24)** — `Homogeneous`/`HeterogenousArray` and
  `Vector` now each have an instance/kind pair, as tabulated above. A heterogeneous array must be
  typed `qudt:HeterogenousArray` (not bare `qudt:Array`) for its per-position types to be checked.
  **Still open: `qudt:Matrix`**, along with `qudt:MultiDimensionalArray` and
  `qudt:AssociativeArray`, which remain instance-side subclasses of `qudt:Array` with no
  corresponding kind. A `qudt:MatrixKind` under `qudt:ArrayKind` is the obvious parallel, but nothing
  currently requires it.
- `qudt:TableType` and `qudt:TimeSeriesArrayType` were renamed with a `Type` suffix while the array
  blueprints use `Kind`. `TimeSeriesArrayType` is `rdfs:subClassOf qudt:ArrayKind`, so it is a kind
  in all but name; the two suffixes should be reconciled.
- `qudt:Table-*` and `qudt:TimeSeriesArray-*` property shapes still carry the pre-rename prefixes.
- `qudt:StructuredDatatype-nTuple` and `qudt:TimeSeriesArray-vector` are defined but no longer
  referenced by any `sh:property` — deliberate detachment, pending a decision to delete them.
- `qudt:ArrayKind`'s `dcterms:description` is still a near-verbatim copy of `qudt:Array`'s (it
  describes `qudt:values` as living on the kind), its `rdfs:label` is still `"Array"`, and whether
  `rdfs:subClassOf qudt:StructuredDatatype` is right for a blueprint node is unsettled.
- `ex:badExampleQuantityValueTuple` is defined twice in the invalid examples file, so its
  position-3 fault is reported twice.

## Design revision (2026-07-27) — self-describing array, no `qudt:ArraySpec` (Option B)

> **SUPERSEDED by "Design revision (2026-08-22)" above.** The blueprint node was reinstated as
> `qudt:ArrayKind`, and the validation status recorded below ("DEFERRED") is out of date — the
> constraints are validated, and the `NOT EXISTS` anomaly was diagnosed as three specific
> non-portable SPARQL constructs, not a `$this` pre-binding quirk. Kept for the record.

**This section supersedes the `qudt:ArraySpec` / `qudt:ArrayElementTypeSpec` /
`qudt:arrayElementTypeSpecs` sketches later in this document.** After working through the temperature
and heterogeneous examples, the decision was to **not** give arrays a separate spec/blueprint node.

**Decisions:**

1. **Drop `qudt:ArraySpec` and `qudt:conformsToArraySpec`.** The array is **self-describing**: rank
   (`qudt:dimensionality`), extents (`qudt:dimensions`), total cell count (`qudt:elementCount`), the
   flat value list (`qudt:values`), its linearisation (`qudt:dataOrder`), and the element type(s) all
   live directly on the one `qudt:Array` instance. Rationale: a blueprint pays off only when many
   instances share it, but an array's `dimensions` vary per instance, so the indirection buys little.
   Accepted trade-off: heterogeneous arrays can't share a reusable positional-type blueprint the way
   `NTupleSpec` allows — each restates its per-position types (but see the reuse in point 3).
2. **`qudt:elementCount` is a scalar total on the instance**, `= ∏(dimensions)` — *not* a per-dimension
   list (that is already `qudt:dimensions`). It exists solely because SPARQL has no `PRODUCT` aggregate,
   so `ArrayLengthCheck` can be `COUNT(values) = elementCount`. Held explicitly / modeller-asserted;
   `elementCount = ∏(dimensions)` is not SPARQL-checked at arbitrary rank.
3. **Element types use a hybrid (Option B):**
   - **Homogeneous** → the flat `qudt:elementType` facet (one shared type), plus any shared
     `qudt:hasQuantityKind` / `qudt:unit` stated once on the array. "Temperature" is a quantity kind,
     not a datatype, so `qudt:elementType` fixes only the literal datatype (e.g. `xsd:decimal`) and the
     quantity kind/unit sit on the array.
   - **Heterogeneous** → `qudt:conformsToTupleSpec` → a `qudt:NTupleSpec` (borrows the tuple engine,
     one type per position, addressed 1-based over the flat value list).
   - **Known limitation:** the flat `qudt:elementType` is only unambiguous for a plain `xsd:` datatype
     — a bare IRI object can't distinguish a datatype facet from a class facet. Richer element types
     push metadata to the array level or fall back to the structured/tuple form. (This is why Option B
     is inherently a *hybrid*: the flat shortcut can't express per-position types, so heterogeneous
     arrays must use a second mechanism.)

**Implemented in the datatypes schema (2026-07-27; the file was still monolithic then):**

- On `qudt:Array`: added property shapes `qudt:Array-values` (`sh:node qudt:RDFListShape`),
  `qudt:Array-elementType` (`sh:nodeKind sh:IRI`), `qudt:Array-elementCount` (`xsd:integer`),
  `qudt:Array-conformsToTupleSpec` (`sh:class qudt:NTupleSpec`) — all optional (`sh:maxCount 1`), so
  legacy `qudt:value`/`qudt:datatype` arrays still parse.
- Three `sh:sparql` constraints on `qudt:Array`: `qudt:ArrayRankCheck`
  (`COUNT(dimensions) = dimensionality`), `qudt:ArrayLengthCheck` (`COUNT(values) = elementCount`),
  `qudt:ArrayElementTypeCheck` (homogeneous — each cell matches the single `qudt:elementType`, as a
  literal datatype or a class).
- On `qudt:HeterogenousArray`: reuse the tuple engine — `sh:sparql` references to
  `qudt:NTupleTypeCheck`, `NTupleLengthCheck`, `NTupleExtraValueCheck`, `NTupleMissingRequiredValueCheck`.
- Retired the broken `qudt:DimensionalityShape` (walked `qudt:value` singular, fired per-dimension,
  didn't project `$this`) — replaced by the two array checks above. **Side effect:** its
  `qudt:List` target is gone, and the legacy old-style invalid array examples that relied on it
  (`qudt:Array1D_Integers-INVALID`, `qudt:EX_Array1D_INVALID`) are no longer flagged.
- Relaxed `qudt:HeterogenousArray-datatype` to optional (removed `sh:minCount 1`) — bridges the legacy
  `qudt:datatype` pointer and the new `qudt:conformsToTupleSpec`.
- Declared new properties `qudt:elementCount` and `qudt:elementType`.

**Examples added:** valid — `ex:example3DHomogeneousArray`, `ex:example3DTemperatureArray`,
`ex:example2x3HeterogeneousArray` (+ `ex:TempPressureArraySpec`) in `EXAMPLES_QUDT-DATATYPES.ttl`;
invalid — `ex:badExampleHomogeneousArrayLength` / `…ArrayType` / `ex:badExampleArrayRank` /
`ex:badExampleHeterogeneousArrayType` (each isolating one violation) in `EXAMPLES_QUDT-INVALID-DATATYPES.ttl`.
All files parse (rdflib); array count invariants cross-checked.

**Validation status — DEFERRED (not signed off).** `ArrayRankCheck` and `ArrayLengthCheck` were
confirmed correct via raw SPARQL with `$this` pre-bound (bad rank / bad length flagged, valid clean).
`ArrayElementTypeCheck` and the reused `NTuple*` checks showed **anomalies under both pyshacl 0.25 and
rdflib** — valid decimals flagged, cross-product violations. The **existing, unmodified**
`NTupleTypeCheck` reproduced the same anomaly on a known-valid tuple, pointing at a `$this`
pre-binding / `NOT EXISTS` correlation quirk in those engines rather than a definite logic error (the
schema targets TopBraid/Jena ARQ). **To resolve when validation resumes:** confirm behaviour in the
project's actual SHACL engine, and settle whether `ArrayElementTypeCheck`'s `NOT EXISTS` needs
restructuring to avoid re-referencing `$this` inside it. (pyshacl also has a naive scan that rejects
any query containing the token `values`, so `qudt:values` must be aliased to test with it.)

## What already exists on the branch

> **HISTORICAL (as of 2026-05-16).** Line numbers, shape names and the wiring below describe the
> schema *before* both revisions. `qudt:DimensionalityShape` has since been deleted, the
> `qudt:Array-*` shapes listed here were renamed `qudt:ArrayKind-*` and moved onto `qudt:ArrayKind`,
> and `qudt:ArrayKind` itself did not yet exist. See "Design revision (2026-08-22)" for the current
> shape.

**Classes / node shapes** (all `sh:NodeShape` + `rdfs:Class`):

|                Shape                 |    Line    |                                                                                 Notes                                                                                 |
|--------------------------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `qudt:Array`                         | 104        | Root shape — declares `qudt:DimensionalityShape` (SPARQL, has bugs), `qudt:Array-isHeterogeneous`, `qudt:DimensionalityPropertyShape`, `qudt:DimensionsPropertyShape` |
| `qudt:HomogeneousArray`              | 722        | Subclass — all elements same datatype (via a bare `qudt:datatype`)                                                                                                    |
| `qudt:HeterogenousArray`             | 678        | Subclass — carries `qudt:datatype` pointing at a list of per-position datatypes                                                                                       |
| `qudt:Matrix`                        | 892        | Subclass of `qudt:Array`, N-dimensional                                                                                                                               |
| `qudt:MultiDimensionalArray`         | 924        | Subclass — elements are described as N-tuples in the docs                                                                                                             |
| `qudt:Vector`                        | 2086       | 1-D                                                                                                                                                                   |
| `qudt:TypeMatrix`, `qudt:TypeVector` | 1968, 1978 | Matrices/vectors whose *cells are datatypes* — analogous to `qudt:NTupleMemberTypeSpec`                                                                               |
| `qudt:Array2DvalueList`              | 143        | Purpose-built list shape for 2-D case: `[[…],[…],[…]]`                                                                                                                |
| `qudt:IntegerListShape`              | 785        | Recursive `RDFListShape` whose elements are `xsd:integer` — reusable for the extent list                                                                              |

**Dimensionality machinery** (usable as-is):

- `qudt:dimensionality` — single `xsd:integer` = rank. Enforced by `qudt:DimensionalityPropertyShape` (line 3239).
- `qudt:dimensions` — list of `xsd:integer` = extent per dimension. Enforced by `qudt:DimensionsPropertyShape` (line 3246) via `sh:node qudt:IntegerListShape`.
- `qudt:ArrayDataOrder` — enumeration `qudt:InnermostIndexFastest` / `qudt:OutermostIndexFastest`
  (see "Data order (IMPLEMENTED)").

**Generic list shapes** (reusable):

- `qudt:RDFListShape` (line 1939) — recursive well-formed-list check.
- `qudt:IntegerListShape` (line 785) — recursive list-of-integers check.

## What's missing for the NTuple-parallel pattern

|                                           NTuple pattern                                           |                                                            Array analog                                                            |                                                              Currently present?                                                              |
|----------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `qudt:NTuple-values` → `sh:node qudt:RDFListShape`                                                 | `qudt:Array-values` → same                                                                                                         | **No** — `qudt:Array` doesn't declare a `qudt:values` property shape                                                                         |
| `qudt:NTuple-conformsToTupleSpec` → `qudt:NTupleSpec`                                              | `qudt:Array-conformsToArraySpec` → `qudt:ArraySpec`                                                                                | **No** — the array's "spec" is fused into the instance shape (dimensionality/dimensions/datatype live directly on `qudt:Array`)              |
| `qudt:NTupleMemberTypeSpec` with 4 type-facet alternatives                                         | `qudt:ArrayElementTypeSpec` with the same 4 alternatives (no `qudt:index` since all cells share the facet in the homogeneous case) | **No** — homogeneous arrays use bare `qudt:datatype`, heterogenous ones a list of `qudt:datatype`, neither reuses the four-alternative facet |
| `NTupleTypeCheck`, `NTupleExtraValueCheck`, `NTupleMissingRequiredValueCheck`, `NTupleLengthCheck` | Analogous array constraints                                                                                                        | Only `qudt:DimensionalityShape` (line 490) exists, and it has three bugs (see below)                                                         |

## Existing `qudt:DimensionalityShape` — known-broken

Lines 495–511:

```sparql
$this qudt:dimensionality $dimensionality .
$this qudt:dimensions ?dimensions .
?dimensions rdf:rest*/rdf:first $specifiedDimensions .
{ SELECT $this (COUNT(?listValue ) AS $actualDimensions)
  WHERE {
    $this qudt:value/rdf:rest*/rdf:first ?listValue .    ← walks qudt:value (singular)
  } GROUP BY $this
}
FILTER ($actualDimensions != $specifiedDimensions)
```

Three defects:

1. **Walks `qudt:value` (singular)** — arrays don't consistently declare that property. NTuple uses
   `qudt:values` (plural). No array instance would ever match.
2. **Compares actual leaf count against every element of the dimensions list** — the FILTER fires
   per dimension entry. A valid 3×4 matrix (dimensions = `(3 4)`, 12 leaves) fires twice: 12 ≠ 3
   and 12 ≠ 4.
3. **Sub-SELECT doesn't project `$this`** — SHACL pre-binding won't carry through. Same defect we
   just fixed on the four NTuple constraints.

Recommendation: **replace, don't extend**. Two new constraints (`ArrayRankCheck`,
`ArrayLengthCheck`) cover the intended checks correctly.

## Two design choices for the value list

### Option A — nested lists

- 1-D: `qudt:values ( a b c )`
- 2-D: `qudt:values ( ( a b ) ( c d ) ( e f ) )` — 3×2 matrix
- N-D: N levels of nesting.

**Pros:** natural structural fit; the current docs on `qudt:Array` describe arrays this way;
`qudt:RDFListShape` recursively validates each nested list.

**Cons:** validating "at depth *d* the sublist length equals `dimensions[d]`" for **arbitrary** *d*
in one SPARQL query is awkward. SHACL property paths don't parameterise on depth, so N-D
validation either requires one shape per depth (won't scale to arbitrary N) or a bespoke recursive
SPARQL that walks the tree adaptively (fragile).

### Option B — flat list plus dimensions

- Store cells in row-major (or column-major) order: `qudt:values ( a b c d e f )` for a 3×2 matrix.
- Use `qudt:arrayDataOrder` (already exists, line 159) to fix the linearisation.
- Total length must equal ∏(dimensions).

**Pros:** SPARQL-friendly. Total-length check is a single COUNT vs a precomputed product. Element
indexing (linear ↔ logical) can be done in application code or via SPARQL arithmetic.

**Cons:** loses the natural nested-structure view; needs the product of dimensions. SPARQL has no
`PRODUCT` aggregate, so either (a) add a derived `qudt:elementCount` datatype property that stores
∏(dimensions), or (b) accept a small-N-only inline computation.

### Recommendation

Lean toward **Option B**. Nested-list validation for arbitrary N doesn't cleanly fit SHACL, and the
existing `qudt:ArrayDataOrder` enumeration already anticipates a linearised representation.
`qudt:Matrix` and `qudt:Vector` can still be represented as arrays with `dimensionality` 2 and 1
respectively.

## Sketched Turtle (Option B)

> **HISTORICAL — never implemented.** This sketch proposes `qudt:ArraySpec` /
> `qudt:conformsToArraySpec`, which the 2026-07-27 revision dropped. The blueprint idea returned on
> 2026-08-22, but as `qudt:ArrayKind` reached by `qudt:datatypeKind`, and with a different shape.

```turtle
qudt:Array
    a rdfs:Class, sh:NodeShape ;
    rdfs:subClassOf qudt:StructuredDatatype ;
    sh:property qudt:Array-conformsToArraySpec ;
    sh:property qudt:Array-values ;
    sh:property qudt:Array-dataOrder ;             # on the instance, next to the values
    sh:property qudt:Array-isHeterogeneous ;      # keep as-is
    sh:sparql qudt:ArrayRankCheck ;
    sh:sparql qudt:ArrayLengthCheck ;              # replaces the broken DimensionalityShape
    sh:sparql qudt:ArrayElementTypeCheck .

qudt:Array-conformsToArraySpec
    a sh:PropertyShape ;
    sh:path qudt:conformsToArraySpec ;
    sh:class qudt:ArraySpec ;
    sh:minCount 1 ; sh:maxCount 1 .

qudt:Array-values
    a sh:PropertyShape ;
    sh:path qudt:values ;
    sh:node qudt:RDFListShape ;
    sh:minCount 1 ; sh:maxCount 1 .

qudt:Array-dataOrder
    a sh:PropertyShape ;
    sh:path qudt:dataOrder ;                       # reused; see "Data order (IMPLEMENTED)" below
    sh:class qudt:ArrayDataOrder ;
    sh:maxCount 1 .                                # optional — absence ⇒ qudt:InnermostIndexFastest

qudt:ArraySpec
    a rdfs:Class, sh:NodeShape ;
    sh:property [
        sh:path qudt:dimensions ;
        sh:node qudt:IntegerListShape ;    # reused
        sh:minCount 1 ; sh:maxCount 1 ;
    ] ;
    sh:property [
        sh:path qudt:dimensionality ;      # reused
        sh:datatype xsd:integer ;
        sh:minCount 1 ; sh:maxCount 1 ;
    ] ;
    sh:property [
        sh:path qudt:elementTypeSpec ;
        sh:node qudt:ArrayElementTypeSpec ;
        sh:minCount 1 ; sh:maxCount 1 ;
    ] .

qudt:ArrayElementTypeSpec
    a rdfs:Class, sh:NodeShape ;
    # Same 4-alternative type facet as NTupleMemberTypeSpec-type, minus qudt:index —
    # every cell shares one facet in the homogeneous case.
    # For heterogenous arrays, allow multiple ArrayElementTypeSpec instances with qudt:index —
    # then the machinery collapses onto the NTuple pattern.
    sh:node (
        [ sh:or qudt:NumericTypeUnion ]
        [ sh:property [ sh:path sh:class ; sh:class qudt:Concept ] ]
        [ sh:property [ sh:path qudt:value ; sh:class qudt:EnumeratedValue ] ]
        [ sh:nodeKind sh:IRI ]
    ) ;
    sh:minCount 1 ; sh:maxCount 1 .
```

## Data order (IMPLEMENTED) — how the flat list linearises

The flat representation needs one more datum: **how the single `qudt:values` list maps back to
logical N-D positions.** We reuse the `qudt:dataOrder` property already in the schema.

**Placement: superseded — `qudt:dataOrder` now sits on `qudt:ArrayKind`** (as
`qudt:ArrayKind-dataOrder`), alongside the extents it linearises. The original argument below was for
putting it on the instance next to `qudt:values`; it is kept for the record.

> ~~**Placement: `qudt:dataOrder` on the instance (`qudt:Array`), next to `qudt:values`** — not on the
>
>> spec. Rationale: the linearisation is a property of *this particular value's* list, so the same
>> logical array (same `qudt:dimensions`, same `qudt:ArraySpec` blueprint) can be shipped in different
>> orders without needing a distinct spec per order.~~

Consequence of the move: two arrays sharing a kind necessarily share its linearisation. Shipping the
same logical array in a different order now means a second `ArrayKind`. The property remains
**optional**; absence means the default (`qudt:InnermostIndexFastest`), matching the array class prose.

### What was orphaned, now wired

Both pieces existed but were wired to nothing:

- `qudt:dataOrder` — was a bare `rdf:Property` with only a label. Now carries `rdfs:range
  qudt:ArrayDataOrder` and an `rdfs:comment`.
- `qudt:ArrayDataOrder` — enum shape whose description was a placeholder and whose `sh:in` listed
  three vocab individuals (`datatype:ByColumn/ByRow/ByLeftMostIndex`).

Wiring done: the `sh:class qudt:ArrayDataOrder` / `sh:maxCount 1` property shape — originally
`qudt:Array-dataOrder` on `qudt:Array`, now `qudt:ArrayKind-dataOrder` on `qudt:ArrayKind`; `qudt:ArrayDataOrder` given a real description and `sh:in ( qudt:InnermostIndexFastest
qudt:OutermostIndexFastest )`.

### Enum values — renamed, redefined, relocated

The old `datatype:ByRow` / `datatype:ByColumn` / `datatype:ByLeftMostIndex` were **retired** — "row",
"column" and "leftmost index" are 2-D-only or ambiguous (`ByLeftMostIndex` could be read two opposite
ways). Replaced by **two** first-class enumerated-value individuals stated purely as *which index
varies fastest*, so they read the same at any rank:

|            Value             |                                                                                        Meaning                                                                                        |       `arr[2][3]` sequence       |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| `qudt:InnermostIndexFastest` | The **innermost (last) index varies fastest**; values sharing the same outer indices occur contiguously before the outer index advances. **Default** when `qudt:dataOrder` is absent. | (0,0)(0,1)(0,2) (1,0)(1,1)(1,2)  |
| `qudt:OutermostIndexFastest` | The **outermost (first) index varies fastest**; values sharing the same inner indices occur contiguously before the inner index advances.                                             | (0,0)(1,0) (0,1)(1,1) (0,2)(1,2) |

Decisions baked in:

- **Namespace `qudt:`, not `datatype:`** — the individuals are now integral to the schema, so they
  live in the SHACL datatype schema (not the vocab), `rdfs:isDefinedBy` the schema graph,
  alongside precedents like `qudt:UNARY-FUNCTION`. Since the names are brand new, there was no
  migration cost to choosing `qudt:`.
- **Two values, no row/column/leftmost** — the innermost/outermost-fastest framing is complete for
  the two canonical orders and dispenses with the old three-value asymmetry entirely (no need for a
  `ByRightMostIndex`).
- The OWL side (`SCHEMA_QUDT-DATATYPE.ttl`) `owl:oneOf` and both schemas' `vaem:usesNonImportedResource`
  lists were updated to match; the three retired IRIs are gone repo-wide.

## Three SPARQL constraints (sketches)

**`ArrayRankCheck`** — length of `qudt:dimensions` list equals `qudt:dimensionality`. Fixes bug #2
of the current `DimensionalityShape`.

**`ArrayLengthCheck`** — count of leaves in `qudt:values` equals ∏(dimensions). Since SPARQL has
no `PRODUCT` aggregate, either add a derived `qudt:elementCount` property to `qudt:ArraySpec` (and
validate it separately with a rank check) or compute inline for small N via nested aggregates.

**`ArrayElementTypeCheck`** — same four-alternative UNION as `NTupleTypeCheck`, but simpler because
the type facet is fixed for all cells (no per-position spec). If the heterogenous case is unified
with the NTuple pattern (see next section), this becomes almost a copy of `NTupleTypeCheck`.

All three must follow the SHACL pre-binding rule for sub-SELECTs (see
[spec-plus-values-pattern.md](spec-plus-values-pattern.md), "Idiom 2").

## Unifying heterogeneous arrays with NTuples

`qudt:HeterogenousArray` is really *an array of positions with independent types* — i.e. an N-Tuple
laid out as an array. Two options:

1. **Model it as `qudt:NTuple`.** `qudt:HeterogenousArray` becomes a convenience subclass whose
   `qudt:conformsToTupleSpec` uses one memberSpec per cell.
2. **Give `qudt:ArrayElementTypeSpec` an optional `qudt:index`.** A homogeneous array's spec has
   one instance with no `qudt:index`; a heterogeneous one has multiple, one per position. Then
   `ArrayElementTypeCheck` becomes almost a copy of `NTupleTypeCheck`.

Option 2 unifies the two models with minimum duplication. **Preferred direction.**

## What we haven't decided

- ~~Nested vs flat list (leaning flat).~~ **Resolved: flat** — see "Worked examples (step 1)".
- Whether to add `qudt:elementCount` as a materialised product, or compute in SPARQL.
- Naming: `qudt:conformsToArraySpec` or reuse `qudt:conformsToTupleSpec` if we unify with NTuple?
- Backwards compatibility: `qudt:HeterogenousArray-datatype` (line 3363) — deprecate or bridge?
- What to do with `qudt:MultiDimensionalArray`'s existing docs ("elements are N-tuples") — with the
  flat-list-plus-dimensions approach, this description would need updating.

## Worked examples (step 1) — flat vs nested

Two concrete cases, each shown in both representations, to lock the decision. Vocabulary is
real where it already exists (`qudt:dimensions`, `qudt:dimensionality`, `qudt:dataOrder` →
`qudt:InnermostIndexFastest`/`qudt:OutermostIndexFastest`); the spec shapes
(`qudt:ArraySpec`, `qudt:ArrayElementTypeSpec`, `qudt:conformsToArraySpec`,
`qudt:arrayElementTypeSpecs`) are the proposed additions and are **not yet in the schema** — so
these examples live here, not in the validated `EXAMPLES_*` files, until step 2 lands.

### Case 1 — 2×3 heterogeneous array

Semantics: a heterogeneous array *is* an N-Tuple laid out in a grid (per "Unifying heterogeneous
arrays" above). `dimensions = (2 3)`, six positions, each with an independent type. Row-major.
Contents: row 0 = `("Temp", 23.7, °C)`, row 1 = `("Pressure", 101.3, Pa)`.

**Option B — flat (row-major), one `ArrayElementTypeSpec` per position (with `qudt:index`):**

```turtle
ex:Example2x3HeterogeneousArraySpec
    a qudt:ArraySpec ;
    qudt:dimensionality 2 ;
    qudt:dimensions ( 2 3 ) ;
    qudt:arrayElementTypeSpecs (
        [ a qudt:ArrayElementTypeSpec ; qudt:index 1 ; sh:datatype xsd:string ]
        [ a qudt:ArrayElementTypeSpec ; qudt:index 2 ; sh:datatype xsd:decimal ]
        [ a qudt:ArrayElementTypeSpec ; qudt:index 3 ; sh:class qudt:Unit ]
        [ a qudt:ArrayElementTypeSpec ; qudt:index 4 ; sh:datatype xsd:string ]
        [ a qudt:ArrayElementTypeSpec ; qudt:index 5 ; sh:datatype xsd:decimal ]
        [ a qudt:ArrayElementTypeSpec ; qudt:index 6 ; sh:class qudt:Unit ]
    ) ;
.
ex:example2x3HeterogeneousArray
    a qudt:HeterogenousArray ;
    qudt:conformsToArraySpec ex:Example2x3HeterogeneousArraySpec ;
    qudt:dataOrder qudt:InnermostIndexFastest ;    # order lives on the instance, with the values
    qudt:values ( "Temp" 23.7 unit:DEG_C "Pressure" 101.3 unit:PA ) ;
.
```

The spec/values pair is now **structurally identical to `qudt:NTuple`** — same `qudt:index`,
same four-alternative facet, same `NTupleTypeCheck`/`NTupleLengthCheck` idioms apply verbatim
(walk `qudt:values` via `rdf:rest*/rdf:first`, COUNT-preceding-cells for the 1-based index). The
only array-specific check is that `∏(dimensions) = 6 = list length`.

**Option A — nested:**

```turtle
qudt:values ( ( "Temp" 23.7 unit:DEG_C ) ( "Pressure" 101.3 unit:PA ) ) ;
```

To type-check cell (r,c) you must walk *two* levels and derive a per-position index from
(row-length × r + c). The `qudt:index` on the member spec no longer lines up with a single
`rdf:rest*/rdf:first` walk, so `NTupleTypeCheck` can't be reused as-is — you'd need a
depth-2-specific variant.

### Case 2 — 3-D (2×2×2) homogeneous array

Semantics: every cell shares one type (`xsd:decimal`), so **one** `ArrayElementTypeSpec` with
**no** `qudt:index`. `dimensions = (2 2 2)`, 8 cells.

**Option B — flat:**

```turtle
ex:Example3DHomogeneousArraySpec
    a qudt:ArraySpec ;
    qudt:dimensionality 3 ;
    qudt:dimensions ( 2 2 2 ) ;
    qudt:arrayElementTypeSpecs (
        [ a qudt:ArrayElementTypeSpec ; sh:datatype xsd:decimal ]   # shared — no qudt:index
    ) ;
.
ex:example3DHomogeneousArray
    a qudt:HomogeneousArray ;
    qudt:conformsToArraySpec ex:Example3DHomogeneousArraySpec ;
    qudt:dataOrder qudt:OutermostIndexFastest ;    # order lives on the instance, with the values
    qudt:values ( 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 ) ;
.
```

Type check ignores position entirely (every cell must satisfy the one shared facet). Length check
is `∏(2,2,2) = 8 = list length`. Both are single flat-list walks.

**Option A — nested:**

```turtle
qudt:values ( ( ( 1.0 2.0 ) ( 3.0 4.0 ) ) ( ( 5.0 6.0 ) ( 7.0 8.0 ) ) ) ;
```

Validating "at depth *d* every sublist has length `dimensions[d]`" needs a depth-3 walk here, and
a *different* query for every rank. This is the arbitrary-N problem from the "Common pitfalls" of
the pattern doc — SHACL property paths don't parameterise on depth.

### Verdict

**Flat wins on both cases, decisively:**

|                                    |            Flat (Option B)            |       Nested (Option A)       |
|------------------------------------|---------------------------------------|-------------------------------|
| Reuses `NTuple*` constraints       | Yes, verbatim                         | No — needs per-depth variants |
| Type check                         | one `rdf:rest*/rdf:first` walk        | walk N levels, derive index   |
| Length/shape check                 | `∏(dims) = COUNT`                     | one shape per rank            |
| Scales to arbitrary N              | Yes                                   | No                            |
| Heterogeneous ≡ NTuple unification | Falls out for free                    | Breaks                        |
| Cost                               | needs `∏(dims)` (no SPARQL `PRODUCT`) | —                             |

The single cost of flat — computing `∏(dimensions)` without a SPARQL `PRODUCT` aggregate — is
the `qudt:elementCount` question below, and is far cheaper than per-rank nested validation.

**Decisions this confirms / surfaces:**

- **Flat, innermost-index-fastest by default, confirmed.** `qudt:dataOrder` pins the linearisation.
- **`qudt:index` is the homogeneous/heterogeneous switch.** Present ⇒ per-position (tuple-like);
  absent ⇒ one shared facet. This is exactly Option 2 of "Unifying heterogeneous arrays" — the
  worked examples confirm it works with zero new machinery on the heterogeneous side.
- **New naming introduced:** `qudt:arrayElementTypeSpecs` (list, parallels `qudt:tupleMemberSpecs`).
  Open question below still stands: keep `Array*` names or fold heterogeneous arrays entirely into
  `qudt:NTuple` and drop the parallel vocabulary.
- **Docs conflict:** the current `qudt:HomogeneousArray` / `qudt:HeterogenousArray` /
  `qudt:MultiDimensionalArray` prose all say "a 2D array is … a list, where each member is a list"
  and "higher dimensional arrays … nested lists". Going flat means **rewriting that prose** on all
  three shapes, not just `MultiDimensionalArray`.

## Open discussion (next session) — specifying the types of an array's values

**To be discussed, not yet decided.** Just as the *values* of an array are held in a specified
construct (the flat `qudt:values` list, ordered by `qudt:dataOrder`), the **types** of those values
should be given by a **parallel specified construct** rather than ad-hoc properties. In other words,
apply the spec-plus-values pattern to the *type* side too: a type-specification construct that mirrors
the shape of the value construct.

Rough shape to explore:

- A **type-specification construct** analogous to the value list — most likely a list of per-cell
  type facets (each facet being the four-alternative `qudt:ArrayElementTypeSpec-type` we already
  sketched), aligned to the same linearisation/dimensions as the values.
- The **homogeneous case collapses to a single type specification** — all cells share one facet, so
  one spec entry suffices (no per-position index), exactly as `qudt:NTupleMemberTypeSpec` does when
  there is one shared type.

**Point to resolve (flagged):** the note above from this session said *"if the array is heterogeneous,
then we only need one type specification."* That appears to invert the relationship assumed elsewhere
in this document ("Unifying heterogeneous arrays with NTuples"), where **homogeneous** arrays need one
shared spec and **heterogeneous** arrays need one spec per position. The discussion should settle:

1. Which case collapses to a single type specification (homogeneous, per the NTuple pattern — or is
   there a reading in which heterogeneous does?).
2. How the type-specification construct aligns to the values — one facet per position vs one shared
   facet — and whether it reuses `qudt:arrayElementTypeSpecs` / `qudt:ArrayElementTypeSpec` from the
   step-2 sketch or a new parallel list.
3. Whether this simply *is* the `qudt:ArraySpec` element-type machinery already sketched, or a
   distinct construct.

## Next session — where to pick up

1. ~~Confirm the flat-vs-nested direction with a small worked example.~~ **Done — flat.**
   1b. ~~Wire `qudt:dataOrder` on the instance + define the enum values.~~ **Done — implemented.**
2. ~~Decide `qudt:elementCount`, draft the spec + constraints.~~ **Done, revised** — `qudt:ArraySpec`
   **dropped**; `qudt:elementCount` is a scalar on the instance; three array constraints + tuple-engine
   reuse for heterogeneous. See "Design revision (2026-07-27)".
3. ~~Add valid/invalid example instances.~~ **Done** — see "Examples added" in the revision section.
4. ~~Fix or delete `qudt:DimensionalityShape`.~~ **Done — deleted**, replaced by
   `ArrayRankCheck` + `ArrayLengthCheck`.
5. ~~Decide the fate of `qudt:HeterogenousArray-datatype`.~~ **Partial** — relaxed to optional
   (bridge). Full deprecation/removal still open.

**Still to do:**

A. ~~**Resume SHACL validation (deferred).**~~ **Done (2026-08-22)** — all eight array and tuple
constraints validated against both example files. The `NOT EXISTS` question was not a `$this`
pre-binding issue: it was `UNION` inside `NOT EXISTS`, an aggregate alias joined across a
sub-SELECT boundary, and an inverted `FILTER EXISTS`. All three fixed; see "Design revision
(2026-08-22)". Confirmation in the project's own SHACL engine (TopBraid/Jena ARQ) is still worth
doing, but the constraints no longer depend on the constructs that diverge between engines.
B. **Migrate or retire the legacy old-style array examples** (`qudt:Array1D_Integers[-INVALID]`,
`qudt:EX_Array1D_INVALID`, `qudt:Array_MassProperties_Rocket`, `qudt:Matrix-*`) that still use
`qudt:value` (singular) / `qudt:datatype` — the retired `DimensionalityShape` no longer covers the
invalid ones.
C. **Finish deprecating `qudt:HeterogenousArray-datatype`** in favour of `qudt:conformsToTupleSpec`.
D. Rewrite the nested-list prose on `qudt:HomogeneousArray`, `qudt:HeterogenousArray`, and
`qudt:MultiDimensionalArray` to match the flat representation.
E. Hold the "specifying the types of an array's values" discussion (see "Open discussion" above), now
in light of the Option-B hybrid decision.
