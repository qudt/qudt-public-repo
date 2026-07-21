# Array as NTuple-parallel — design discussion

**Opened:** 2026-05-16 (branch `rh-pr1440`, post-merge with `main`)
**Status:** open — flat representation confirmed; data order **implemented** (`qudt:dataOrder` on the
instance; enum `qudt:InnermostIndexFastest` (default) / `qudt:OutermostIndexFastest`). Array spec/values
apparatus (step 2) still pending sign-off.
**Related file:** `src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES_NoOWL.ttl`

## Goal

Give `qudt:Array` the same spec-plus-values treatment as `qudt:NTuple`, so that the two structured
datatypes share a single modelling story. Stay entirely within the SHACL datatype schema; do not
touch the parallel OWL side (`SCHEMA_QUDT-DATATYPE.ttl`) as part of this work.

## What already exists on the branch

**Classes / node shapes** (all `sh:NodeShape` + `rdfs:Class`):

| Shape | Line | Notes |
|---|---|---|
| `qudt:Array` | 104 | Root shape — declares `qudt:DimensionalityShape` (SPARQL, has bugs), `qudt:Array-isHeterogeneous`, `qudt:DimensionalityPropertyShape`, `qudt:DimensionsPropertyShape` |
| `qudt:HomogeneousArray` | 722 | Subclass — all elements same datatype (via a bare `qudt:datatype`) |
| `qudt:HeterogenousArray` | 678 | Subclass — carries `qudt:datatype` pointing at a list of per-position datatypes |
| `qudt:Matrix` | 892 | Subclass of `qudt:Array`, N-dimensional |
| `qudt:MultiDimensionalArray` | 924 | Subclass — elements are described as N-tuples in the docs |
| `qudt:Vector` | 2086 | 1-D |
| `qudt:TypeMatrix`, `qudt:TypeVector` | 1968, 1978 | Matrices/vectors whose *cells are datatypes* — analogous to `qudt:NTupleMemberTypeSpec` |
| `qudt:Array2DvalueList` | 143 | Purpose-built list shape for 2-D case: `[[…],[…],[…]]` |
| `qudt:IntegerListShape` | 785 | Recursive `RDFListShape` whose elements are `xsd:integer` — reusable for the extent list |

**Dimensionality machinery** (usable as-is):

- `qudt:dimensionality` — single `xsd:integer` = rank. Enforced by `qudt:DimensionalityPropertyShape` (line 3239).
- `qudt:dimensions` — list of `xsd:integer` = extent per dimension. Enforced by `qudt:DimensionsPropertyShape` (line 3246) via `sh:node qudt:IntegerListShape`.
- `qudt:ArrayDataOrder` — enumeration `qudt:InnermostIndexFastest` / `qudt:OutermostIndexFastest`
  (see "Data order (IMPLEMENTED)").

**Generic list shapes** (reusable):

- `qudt:RDFListShape` (line 1939) — recursive well-formed-list check.
- `qudt:IntegerListShape` (line 785) — recursive list-of-integers check.

## What's missing for the NTuple-parallel pattern

| NTuple pattern | Array analog | Currently present? |
|---|---|---|
| `qudt:NTuple-values` → `sh:node qudt:RDFListShape` | `qudt:Array-values` → same | **No** — `qudt:Array` doesn't declare a `qudt:values` property shape |
| `qudt:NTuple-conformsToTupleSpec` → `qudt:NTupleSpec` | `qudt:Array-conformsToArraySpec` → `qudt:ArraySpec` | **No** — the array's "spec" is fused into the instance shape (dimensionality/dimensions/datatype live directly on `qudt:Array`) |
| `qudt:NTupleMemberTypeSpec` with 4 type-facet alternatives | `qudt:ArrayElementTypeSpec` with the same 4 alternatives (no `qudt:index` since all cells share the facet in the homogeneous case) | **No** — homogeneous arrays use bare `qudt:datatype`, heterogenous ones a list of `qudt:datatype`, neither reuses the four-alternative facet |
| `NTupleTypeCheck`, `NTupleExtraValueCheck`, `NTupleMissingRequiredValueCheck`, `NTupleLengthCheck` | Analogous array constraints | Only `qudt:DimensionalityShape` (line 490) exists, and it has three bugs (see below) |

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

**Placement: `qudt:dataOrder` on the instance (`qudt:Array`), next to `qudt:values`** — not on the
spec. Rationale: the linearisation is a property of *this particular value's* list, so the same
logical array (same `qudt:dimensions`, same `qudt:ArraySpec` blueprint) can be shipped in different
orders without needing a distinct spec per order. Property is **optional**; absence means the
default (`qudt:InnermostIndexFastest`), matching the array class prose.

### What was orphaned, now wired

Both pieces existed but were wired to nothing:

- `qudt:dataOrder` — was a bare `rdf:Property` with only a label. Now carries `rdfs:range
  qudt:ArrayDataOrder` and an `rdfs:comment`.
- `qudt:ArrayDataOrder` — enum shape whose description was a placeholder and whose `sh:in` listed
  three vocab individuals (`datatype:ByColumn/ByRow/ByLeftMostIndex`).

Wiring done: `qudt:Array-dataOrder` property shape (`sh:class qudt:ArrayDataOrder`, `sh:maxCount 1`)
added to `qudt:Array`; `qudt:ArrayDataOrder` given a real description and `sh:in ( qudt:InnermostIndexFastest
qudt:OutermostIndexFastest )`.

### Enum values — renamed, redefined, relocated

The old `datatype:ByRow` / `datatype:ByColumn` / `datatype:ByLeftMostIndex` were **retired** — "row",
"column" and "leftmost index" are 2-D-only or ambiguous (`ByLeftMostIndex` could be read two opposite
ways). Replaced by **two** first-class enumerated-value individuals stated purely as *which index
varies fastest*, so they read the same at any rank:

| Value | Meaning | `arr[2][3]` sequence |
|---|---|---|
| `qudt:InnermostIndexFastest` | The **innermost (last) index varies fastest**; values sharing the same outer indices occur contiguously before the outer index advances. **Default** when `qudt:dataOrder` is absent. | (0,0)(0,1)(0,2) (1,0)(1,1)(1,2) |
| `qudt:OutermostIndexFastest` | The **outermost (first) index varies fastest**; values sharing the same inner indices occur contiguously before the inner index advances. | (0,0)(1,0) (0,1)(1,1) (0,2)(1,2) |

Decisions baked in:

- **Namespace `qudt:`, not `datatype:`** — the individuals are now integral to the schema, so they
  live in `SCHEMA_QUDT-DATATYPES_NoOWL.ttl` (not the vocab), `rdfs:isDefinedBy` the schema graph,
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

All three must follow the SHACL pre-binding rule for sub-SELECTs (see main `SKILL.md`, idiom 2).

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

| | Flat (Option B) | Nested (Option A) |
|---|---|---|
| Reuses `NTuple*` constraints | Yes, verbatim | No — needs per-depth variants |
| Type check | one `rdf:rest*/rdf:first` walk | walk N levels, derive index |
| Length/shape check | `∏(dims) = COUNT` | one shape per rank |
| Scales to arbitrary N | Yes | No |
| Heterogeneous ≡ NTuple unification | Falls out for free | Breaks |
| Cost | needs `∏(dims)` (no SPARQL `PRODUCT`) | — |

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

1. ~~Confirm the flat-vs-nested direction with a small worked example.~~ **Done above — flat.**
   Get sign-off, then proceed.
1b. ~~Wire `qudt:dataOrder` on the instance + define the enum values.~~ **Done — implemented**
   (`qudt:Array-dataOrder`, `qudt:InnermostIndexFastest` / `qudt:OutermostIndexFastest`; see
   "Data order (IMPLEMENTED)").
2. Draft the Turtle for `qudt:ArraySpec`, `qudt:ArrayElementTypeSpec`, and the three SPARQL
   constraints, following the SHACL pre-binding rules from `SKILL.md`. Prerequisite: decide
   `qudt:elementCount` (materialised `∏(dims)`) vs inline computation — the length check depends on it.
3. Add example instances (valid and invalid) to `src/main/rdf/examples/EXAMPLES_QUDT-DATATYPES.ttl`
   and `EXAMPLES_QUDT-INVALID-DATATYPES.ttl` (promote the Option-B blocks above).
4. Fix or delete `qudt:DimensionalityShape` (lines 490–514).
5. Decide the fate of `qudt:HeterogenousArray-datatype` (line 3363).
6. Rewrite the nested-list prose on `qudt:HomogeneousArray`, `qudt:HeterogenousArray`, and
   `qudt:MultiDimensionalArray` to match the flat representation.
7. Hold the "specifying the types of an array's values" discussion (see "Open discussion" above) —
   a type-specification construct parallel to the values, and resolve the homogeneous-vs-heterogeneous
   "one type specification" point.
