# The spec-plus-values pattern

**Applies to:** `src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES_NoOWL.ttl`

Every structured datatype in this schema — tuples, arrays, matrices, vectors,
and whatever comes next — should follow the same three-shape pattern. This
document describes what the pattern is, why the SPARQL constraint idioms look
the way they do, and how to apply the pattern to a new datatype.

## The three cooperating shapes

```
┌─────────────────────┐                    ┌───────────────────────┐
│  <InstanceShape>    │───conformsToXSpec──▶│   <SpecShape>         │
│  (the value)        │                    │  (the blueprint)      │
│                     │                    │                       │
│  qudt:values ───┐   │                    │  ordered list of      │
└─────────────────┼───┘                    │   <MemberTypeSpec>s   │
                  ▼                        └───────────────────────┘
             rdf:List of
           actual values
```

1. **Instance shape** (e.g. `qudt:NTuple`) — what a *value* of the datatype
   looks like. Two property shapes are always present:
   - `qudt:values` — the ordered list of values, constrained by
     `sh:node qudt:RDFListShape`.
   - `qudt:conformsToXSpec` (e.g. `qudt:conformsToTupleSpec`) — points at the
     spec instance.
2. **Spec shape** (e.g. `qudt:NTupleSpec`) — the *blueprint*. Holds an
   ordered list of per-position or per-element specs, walked via
   `sh:zeroOrMorePath rdf:rest / rdf:first`.
3. **Member-type spec shape** (e.g. `qudt:NTupleMemberTypeSpec`) — one entry
   per position (for tuples) or one shared entry (for homogeneous arrays).
   Carries `qudt:index` for positional variants, and a **type facet** that
   must be one of the four alternatives below.

The canonical worked example is `qudt:NTuple`, defined at
`SCHEMA_QUDT-DATATYPES_NoOWL.ttl:988`. When designing a new structured
datatype, start by reading that block.

## The four-alternative type facet

`qudt:NTupleMemberTypeSpec-type` (line 1234) declares that every member spec
must satisfy exactly one of four kinds of type expectation:

1. **Numeric datatype union** — `sh:or qudt:NumericTypeUnion` (or a bare
   `sh:datatype`).
2. **Concept-class membership** — `sh:class <C>` where `<C> a qudt:Concept`.
3. **Enumerated value** — `qudt:value <e1>, <e2>, …`.
4. **Any IRI** — `sh:nodeKind sh:IRI`.

New structured datatypes should reuse this pattern rather than invent parallel
type-facet machinery. When a datatype's cells all share one type (homogeneous
array, vector of scalars), reuse the facet without the `qudt:index` — one
shared spec instead of one-per-position.

## SPARQL constraint idioms

Every structured-datatype instance shape hangs one or more `sh:sparql`
constraints off itself. `qudt:NTuple` uses four:

| Constraint | Purpose |
|---|---|
| `NTupleTypeCheck` | Value at position `?index` satisfies the position's type facet |
| `NTupleExtraValueCheck` | No value sits at a position with no matching spec |
| `NTupleMissingRequiredValueCheck` | Every required spec position is filled |
| `NTupleLengthCheck` | Length of values list equals number of spec positions |

All four rely on the same three idioms.

### Idiom 1: 1-based position via COUNT of preceding cells

The list-walk trick that computes each cell's 1-based `?index` without any
explicit position triple:

```sparql
?values rdf:rest* ?valueCell .
?valueCell rdf:first ?value .

OPTIONAL {
    ?values rdf:rest* ?previousCell .
    ?previousCell rdf:rest+ ?valueCell .
}
# ... GROUP BY ... ?valueCell
# ... (COUNT(?previousCell) + 1 AS ?index)
```

`?valueCell` discriminates each list position (each cell is a unique blank
node), so grouping by it gives one row per position. `COUNT(?previousCell) + 1`
yields the 1-based index. This same idiom walks any RDF list.

### Idiom 2: SHACL pre-binding in sub-SELECTs

**This is the single most common defect in constraints on structured
datatypes.** SHACL pre-binds `$this` (the focus node) into the outer query,
but pre-binding **only carries into a sub-SELECT if the sub-SELECT projects
`$this`**. Every sub-SELECT that references `$this` (directly or via a
variable that depends on it) must:

1. **Anchor to `$this` via a triple pattern** inside the sub-query (e.g.
   `$this qudt:values ?values`), rather than binding `?values` outside the
   sub-query and passing it in.
2. **`SELECT $this …`** — project it.
3. **`GROUP BY $this …`** — group by it (in addition to whatever position
   discriminator you're using, typically `?valueCell`).

This is what makes the sub-query benefit from the focus-node pre-binding
rather than scanning every `rdf:List` in the dataset. The symptom of getting
this wrong is either silent (the constraint doesn't fire) or noisy (phantom
violations on unrelated focus nodes), depending on the SHACL engine.

### Idiom 3: Four-alternative UNION for type validation

The `NTupleTypeCheck` constraint uses a `FILTER NOT EXISTS { … UNION … UNION
… UNION … }` with one branch per type-facet alternative. New "does this cell
match its spec" constraints should reuse that four-branch pattern verbatim —
see lines 1042–1059 in the schema file for the canonical version.

## Checklist for a new structured datatype

When adding a new structured-datatype variant (e.g. `qudt:Table`, `qudt:Tensor`,
some future `qudt:Foo`), work through this checklist:

1. **Instance vs blueprint.** Does the datatype need its own spec/blueprint, or
   does it reuse an existing one? Rule of thumb: if the number/kind of
   positions can vary across instances, you need a spec.
2. **List representation.** Are values a flat list, a nested list, or something
   else? A flat list with a companion `qudt:dimensions` extent list is usually
   easier to validate in SPARQL than deeply nested lists (nested-list
   validation for arbitrary depth is awkward with SHACL property paths).
3. **Position semantics.** Do positions matter? (Tuple: yes. Bag: no.
   Homogeneous array: only for type validation, not for a per-position spec.)
   If positions matter, follow the NTuple idiom verbatim. If not, reuse the
   type-facet machinery without `qudt:index`.
4. **Constraint set.** Which of the four NTuple constraints does the new
   datatype need? Most structured datatypes need type check + length/shape
   check; some don't need extra-value or missing-required checks.
5. **Existing infrastructure to reuse.** Before adding new properties, check
   whether one of these already-defined pieces fits:
   - `qudt:dimensionality` (rank), `qudt:dimensions` (extent list),
     `qudt:elementCount`
   - `qudt:RDFListShape` (recursive well-formed-list shape)
   - `qudt:IntegerListShape` (list of integers)
   - `qudt:Array2DvalueList` (2-D-specific shape)
   - `qudt:ArrayDataOrder` (`qudt:InnermostIndexFastest` / `qudt:OutermostIndexFastest`
     enumeration)
   - `qudt:NumericTypeUnion` (numeric datatype disjunction)

## Common pitfalls

- **Pre-binding drift** — see idiom 2. If a sub-SELECT doesn't project
  `$this`, either the constraint won't fire (some engines) or it will scan
  the whole dataset and fire on unrelated focus nodes (others). Silent
  failure mode — you'll only notice when a validation report contains
  phantom violations.
- **Confusing `qudt:value` (singular) with `qudt:values` (plural)** — the
  existing `qudt:DimensionalityShape` constraint (line 490) walks
  `qudt:value`, which no structured datatype actually declares. Don't copy
  that shape verbatim; treat it as a known-broken example.
- **Nested-list validation is hard in one SPARQL query** — for arbitrary-depth
  arrays, SHACL SPARQL can't easily walk N levels. Either fix N (specialise
  for `qudt:Matrix` / `qudt:Vector`) or switch to the
  flat-list-plus-dimensions representation.
- **Not reusing `qudt:RDFListShape`** — new list-shaped values should point
  at `qudt:RDFListShape` via `sh:node`, not redefine list well-formedness
  inline.
- **Adding a new "kind of thing" without a spec/blueprint** — if the class is
  a structured datatype at all, it should carry the spec/values split. Don't
  stuff constraints directly on the instance shape.

## Scope of this pattern

This pattern applies to the SHACL datatype schema
(`SCHEMA_QUDT-DATATYPES_NoOWL.ttl`) only. The parallel OWL datatype schema
(`SCHEMA_QUDT-DATATYPE.ttl`) has its own older class hierarchy
(`qudt:TwoTuple`, `qudt:ThreeTuple`, `qudt:TupleMember`, etc.) with
`qudt:elementDatatype` restrictions. The two sides do not yet share a single
story for structured datatypes; reconciling them is a separate concern.
