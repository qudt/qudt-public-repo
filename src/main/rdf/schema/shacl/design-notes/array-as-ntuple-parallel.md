# Array as NTuple-parallel — design discussion

**Opened:** 2026-05-16 (branch `rh-pr1440`, post-merge with `main`)
**Status:** open — pending decision on nested vs flat list representation
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
- `qudt:ArrayDataOrder` (line 159) — enumeration `ByColumn` / `ByRow` / `ByLeftMostIndex`.

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

- Nested vs flat list (leaning flat).
- Whether to add `qudt:elementCount` as a materialised product, or compute in SPARQL.
- Naming: `qudt:conformsToArraySpec` or reuse `qudt:conformsToTupleSpec` if we unify with NTuple?
- Backwards compatibility: `qudt:HeterogenousArray-datatype` (line 3363) — deprecate or bridge?
- What to do with `qudt:MultiDimensionalArray`'s existing docs ("elements are N-tuples") — with the
  flat-list-plus-dimensions approach, this description would need updating.

## Next session — where to pick up

1. Confirm the flat-vs-nested direction with a small worked example (a 2×3 heterogenous array and
   a 3-D homogeneous array).
2. Draft the Turtle for `qudt:ArraySpec`, `qudt:ArrayElementTypeSpec`, and the three SPARQL
   constraints, following the SHACL pre-binding rules from `SKILL.md`.
3. Add example instances (valid and invalid) to `src/main/rdf/examples/EXAMPLES_QUDT-DATATYPES.ttl`
   and `EXAMPLES_QUDT-INVALID-DATATYPES.ttl`.
4. Fix or delete `qudt:DimensionalityShape` (lines 490–514).
5. Decide the fate of `qudt:HeterogenousArray-datatype` (line 3363).
