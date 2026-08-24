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
     spec instance. `qudt:Array` is the one variant that names the link
     differently: it uses the general `qudt:datatypeKind` to reach its
     `qudt:ArrayKind`, leaving room for other datatypes to acquire a kind
     without a new property each time.
2. **Spec shape** (e.g. `qudt:NTupleSpec`) — the *blueprint*. Holds an
   ordered list of per-position or per-element specs, walked via
   `sh:zeroOrMorePath rdf:rest / rdf:first`.
3. **Member-type spec shape** (e.g. `qudt:NTupleMemberTypeSpec`) — one entry
   per position (for tuples) or one shared entry (for homogeneous arrays).
   Carries `qudt:index` for positional variants, and a **type facet** that
   must be one of the four alternatives below.

The canonical worked example is `qudt:NTuple`, defined in
`SCHEMA_QUDT-DATATYPES_NoOWL.ttl` (search for `qudt:NTuple`). When designing a
new structured datatype, start by reading that block.

## The four-alternative type facet

`qudt:NTupleMemberTypeSpec-type` declares that every member spec
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
constraints off itself. `qudt:NTuple` uses five:

| Constraint | Purpose |
|---|---|
| `NTupleTypeCheck` | Value at position `?index` satisfies the position's type facet |
| `NTupleRangeCheck` | Value at position `?index` satisfies any numeric bounds on its member spec (`sh:minInclusive` / `sh:maxInclusive` / `sh:minExclusive` / `sh:maxExclusive`) |
| `NTupleExtraValueCheck` | No value sits at a position with no matching spec |
| `NTupleMissingRequiredValueCheck` | Every required spec position is filled — tested as `?index > ?valueCount`, since values occupy positions 1..N contiguously (see idiom 4) |
| `NTupleLengthCheck` | Length of the values list lies within the range allowed by the spec — `[requiredCount, totalCount]`, where a member spec is optional (not counted as required) iff it declares `sh:minCount 0`. Assumes optional members are trailing. |

`NTupleTypeCheck` and `NTupleRangeCheck` share the "compute the 1-based position
in a sub-SELECT, then correlate it with the member spec's `qudt:index`" idiom;
all five rely on the four idioms below. Idioms 3 and 4 exist because the obvious
way to write those two steps is silently non-portable — read them before writing
a new constraint.

> **Worked example — `IfcCompoundPlaneAngleMeasure`.** The IFC4 type
> `LIST [3:4] OF INTEGER` (degrees, minutes, seconds, optional millionth-seconds)
> is modelled in the EXAMPLES files as an `NTuple` subclass: per-position
> `sh:minExclusive`/`sh:maxExclusive` drive `NTupleRangeCheck`, the optional
> 4th member (`sh:minCount 0`) exercises the length range, and a small
> `ConsistentSign` `sh:sparql` on the subclass adds the one cross-position rule
> the generic tuple machinery doesn't cover.

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

### Idiom 3: Four-alternative type validation — `OPTIONAL` probes, not `UNION`

"Does this cell match its spec" means "does it match **any** of the four type-facet
alternatives", and the obvious way to write that is a `FILTER NOT EXISTS` whose
body UNIONs one branch per alternative. **Do not.** `NTupleTypeCheck` and
`ArrayElementTypeCheck` both did, and both flagged every position of every valid
value. Bisecting the branches isolates it precisely:

| Construct | Result on a valid tuple |
|---|---|
| `FILTER NOT EXISTS { <one branch> }` | correct |
| `FILTER NOT EXISTS { <one branch with a property path> }` | correct |
| `FILTER NOT EXISTS { A UNION B UNION C UNION D }` | **every position flagged** |

A single branch is fine; UNION the branches and the outer `?value` / `?memberSpec`
bindings stop being substituted into the group, so nothing ever matches and the
`NOT EXISTS` is always true. Engines differ here, and the failure is silent —
it looks like a data problem, not a query problem.

Write the disjunction as one `OPTIONAL` probe per alternative, each binding its
own flag, then require that none of them fired:

```sparql
# (1) Numeric datatype — direct sh:datatype, or one inside an sh:or union
OPTIONAL {
    ?memberSpec ( sh:datatype | sh:or/rdf:rest*/rdf:first/sh:datatype ) ?allowedDatatype .
    FILTER ( datatype(?value) = ?allowedDatatype )
    BIND ( true AS ?datatypeMatch )
}
# (2) Concept class membership
OPTIONAL {
    ?memberSpec sh:class ?targetClass .
    ?value rdf:type/rdfs:subClassOf* ?targetClass .
    BIND ( true AS ?classMatch )
}
# (3) Enumerated value
OPTIONAL { ?memberSpec qudt:value ?value . BIND ( true AS ?enumeratedMatch ) }
# (4) Any IRI
OPTIONAL {
    ?memberSpec sh:nodeKind sh:IRI .
    FILTER ( isIRI(?value) )
    BIND ( true AS ?iriMatch )
}

FILTER ( !BOUND(?datatypeMatch) && !BOUND(?classMatch)
         && !BOUND(?enumeratedMatch) && !BOUND(?iriMatch) )
```

`OPTIONAL` is a join, so outer bindings are visible inside it by construction —
there is no substitution question to get wrong. Search the schema file for
`qudt:NTupleTypeCheck` for the canonical version.

The same rule applies to a *single* facet compared against a value: express it
as `OPTIONAL` + `BIND` + `!BOUND` rather than `NOT EXISTS` with a bare `FILTER`
inside (see `qudt:ArrayElementTypeCheck`).

### Idiom 4: Correlating a positional sub-SELECT

Idiom 1 computes a cell's 1-based position in a sub-SELECT. Joining that back to
the member spec's declared `qudt:index` is the second place these constraints go
wrong. **Do not project the aggregate under the name you want to join on:**

```sparql
# WRONG — relies on the engine joining an aggregate alias across the boundary
{ SELECT $this ?value (COUNT(?previousCell) + 1 AS ?index) WHERE { … } GROUP BY … }
?memberSpec qudt:index ?index .
```

Engines are not required to unify an aggregate alias with an outer variable of
the same name. Where they don't, you get a silent **cross product** — a 6-position
tuple yields 36 rows, one per (index, value) pair, and every position looks like a
violation. Project it under its own name and correlate explicitly:

```sparql
{ SELECT $this ?value (COUNT(?previousCell) + 1 AS ?position) WHERE { … } GROUP BY … }
?memberSpec qudt:index ?index .
FILTER ( ?position = ?index )
```

**Better still, avoid the correlation.** Some checks don't need per-position
matching at all. `NTupleMissingRequiredValueCheck` originally correlated a
positional sub-SELECT inside a `FILTER EXISTS`; values occupy positions 1..N
contiguously, so "required position `?index` is missing" is just
`?index > ?valueCount`, where `?valueCount` comes from one uncorrelated `COUNT`
joined on `$this` alone. `ArrayLengthCheck` uses the same uncorrelated shape.
An uncorrelated aggregate joined on `$this` is the most portable form available —
prefer it whenever the check can be expressed that way.

## Checklist for a new structured datatype

When adding a new structured-datatype variant (e.g. `qudt:Table`, `qudt:Tensor`,
some future `qudt:Foo`), work through this checklist:

1. **Instance vs blueprint.** Does the datatype need its own spec/blueprint, or
   does it reuse an existing one? Rule of thumb: if the number/kind of
   positions can vary across instances, you need a spec. **Arrays use a
   blueprint** (see [array-as-ntuple-parallel.md](array-as-ntuple-parallel.md)):
   a `qudt:Array` carries only `qudt:values` plus a mandatory `qudt:datatypeKind`
   pointer to a `qudt:ArrayKind`, which holds rank, extents, `qudt:elementCount`,
   `qudt:dataOrder` and the element type(s). A brief 2026-07-27 revision made
   arrays *self-describing* (everything on one instance, no blueprint); that was
   reversed on 2026-08-22 once it became clear instances do share shapes in
   practice. Each array-shaped variant comes as an **instance/kind pair** —
   `HomogeneousArray`/`HomogeneousArrayKind`, `HeterogenousArray`/`HeterogenousArrayKind`,
   `Vector`/`VectorKind`. Heterogeneous arrays reuse the tuple engine via the kind's
   `qudt:conformsToTupleSpec` → `qudt:NTupleSpec`, but the tuple constraints
   themselves hang off the **instance** class: they read `qudt:values`, which a
   blueprint never carries.
2. **List representation.** Are values a flat list, a nested list, or something
   else? A flat list with a companion `qudt:dimensions` extent list is usually
   easier to validate in SPARQL than deeply nested lists (nested-list
   validation for arbitrary depth is awkward with SHACL property paths).
3. **Position semantics.** Do positions matter? (Tuple: yes. Bag: no.
   Homogeneous array: only for type validation, not for a per-position spec.)
   If positions matter, follow the NTuple idiom verbatim. If not, reuse the
   type-facet machinery without `qudt:index`.
4. **Constraint set.** Which of the five NTuple constraints does the new
   datatype need? Most structured datatypes need type check + length/shape
   check; add the range check if positions carry numeric bounds; some don't
   need extra-value or missing-required checks.
5. **Existing infrastructure to reuse.** Before adding new properties, check
   whether one of these already-defined pieces fits:
   - `qudt:ArrayKind` (blueprint for anything array-shaped: rank, extents,
     element count, data order, element type)
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
  former `qudt:DimensionalityShape` walked `qudt:value`, which no structured
  datatype actually declares, so it never matched anything. It has since been
  deleted and replaced by `ArrayRankCheck` + `ArrayLengthCheck`; the lesson
  stands.
- **`UNION` inside `FILTER NOT EXISTS`** — see idiom 3. Silent, and it flags
  *everything*, so it reads as a data problem rather than a query problem.
- **Joining on an aggregate alias across a sub-SELECT boundary** — see idiom 4.
  Produces a silent cross product, which again looks like every position failing.
- **`FILTER EXISTS` where `NOT EXISTS` was meant** — `NTupleMissingRequiredValueCheck`
  fired when a required value *was* present. An inverted check that reports every
  position is easy to mistake for the two defects above; check the polarity first.
- **Putting a value-reading constraint on a blueprint class** — a `qudt:*Kind` never
  carries `qudt:values`, so a constraint that walks the value list matches nothing
  there and reports success. Silent loss of an entire check; after moving a
  constraint between classes, confirm a known-bad example is still flagged.
- **Testing against the schema and examples alone** — `sh:class qudt:Unit` and
  similar class facets need the unit and quantity-kind vocabularies loaded, or
  every IRI-valued cell reports a false violation.
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
