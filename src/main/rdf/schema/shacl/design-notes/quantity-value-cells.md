# Quantity values as cells — design discussion

**Opened:** 2026-10-26 (branch `rh-arrays-cusp3`)
**Status:** open. Quantity values already work as cells of every structured datatype; three gaps
(A to C below) remain, none fixed yet, and no committed example uses a quantity-value cell.
**Related files:** `src/main/rdf/schema/shacl/SCHEMA_QUDT-DATATYPES_NoOWL.ttl`,
`src/main/rdf/schema/shacl/SCHEMA_QUDT_NoOWL.ttl` (`qudt:Quantifiable` and its property shapes)

## Question

How can an instance of `qudt:QuantityValue` be a valid value of a tuple, an array, a vector, a
collection or a map?

## Finding: no schema change is needed

A cell may be any resource of a class, so a kind only has to name `qudt:QuantityValue` as the type
(see "the four-alternative type facet" in [spec-plus-values-pattern.md](spec-plus-values-pattern.md)):

- **Tuples and heterogeneous arrays and vectors:** a member spec with `sh:class qudt:QuantityValue`,
  which `qudt:NTupleTypeCheck` matches through its concept-class branch.
- **Homogeneous arrays and vectors, collections, and the values of a map:** a kind with
  `qudt:elementType qudt:QuantityValue`, which `qudt:ValuesListElementTypeCheck` matches through
  `rdf:type/rdfs:subClassOf*`.

```turtle
ex:QVArrayKind a qudt:HomogeneousArrayKind ;
  qudt:dimensionality 1 ; qudt:dimensions ( 2 ) ; qudt:elementCount 2 ;
  qudt:elementType qudt:QuantityValue ; qudt:hasQuantityKind quantitykind:Temperature .
ex:QVArray a qudt:Array ; qudt:datatypeKind ex:QVArrayKind ;
  qudt:values ( [ a qudt:QuantityValue ; qudt:value 23.7 ; qudt:hasUnit unit:DEG_C ]
                [ a qudt:QuantityValue ; qudt:value 74.6 ; qudt:hasUnit unit:DEG_F ] ) .
```

Every cell must state `a qudt:QuantityValue` (or a subclass) itself: both checks match on the type,
so a node with only `qudt:value` and `qudt:hasUnit` fails. A quantity-value cell is also a focus
node of QUDT's own shapes for `qudt:Quantifiable`, so its value and unit are checked as anywhere
else.

Plain numbers with the unit on the kind remain the shorter form when every cell shares one unit.
Quantity-value cells are for cells that differ in unit, or that carry their own uncertainty.

This is the reverse of what `qudt:Quantifiable-value` already allows: a quantity value whose
`qudt:value` is a structured datatype (one unit around a whole array of numbers).

## Evidence (2026-10-26)

Scratch examples, not committed, were appended to the datatype schema with `DATATYPE_SCHEMA` and run
with `src/build/engine-check/engine-check.sh` (see
[validating-with-the-shacl-engine.md](validating-with-the-shacl-engine.md)). The 92 results of the
committed examples were unchanged; the scratch examples gave:

|                                   Example                                    |                                    Result                                    |
|------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| Quantity values as a tuple position, array cells, set members and map values | no results                                                                   |
| A bare `23.7` in an array whose kind wants quantity values                   | `qudt:ValuesListElementTypeCheck`                                            |
| A cell without `a qudt:QuantityValue`                                        | `qudt:ValuesListElementTypeCheck`                                            |
| A quantity-value cell with `qudt:value "warm"`                               | `sh:OrConstraintComponent` from `qudt:Quantifiable-value`, on the blank node |
| Kind with `qudt:hasUnit unit:DEG_C`, cell with `qudt:hasUnit unit:DEG_F`     | **no result** (gap A)                                                        |
| A set of two distinct blank nodes, each 20.0 °C                              | **no result** (gap B)                                                        |

Not tried: vectors, quantity values as map keys, and `COORDINATES=1`.

## Gaps

**A. A cell's unit can contradict its kind's.** A kind whose cells are quantity values may still
give `qudt:hasUnit` and `qudt:hasQuantityKind`, and nothing compares them with each cell's own.
Proposal: one SPARQL constraint next to `qudt:ValuesListElementTypeCheck`: where both the kind and
the cell give a unit (or a quantity kind), they must be the same. A tuple member spec's unit and
quantity kind need the same check. The alternative, forbidding a unit on such a kind, loses the
case where the kind fixes the unit and the cells add uncertainty.

**B. Sets and map keys compare cells as terms.** `qudt:SetDistinctValuesCheck` and
`qudt:MapDistinctKeysCheck` compare with `=`, so two blank-node quantity values with the same value
and unit are distinct. Proposal: document it rather than fix it. Comparing quantity values by value
means converting units (20 °C equals 68 °F).

**C. An optional quantity-value position probably fails.** Branch (2) of `qudt:NTupleTypeCheck`
reads only an `sh:class` written directly on the member spec, so
`sh:or ( [ sh:class qudt:QuantityValue ] [ sh:hasValue rdf:nil ] )` would accept `rdf:nil` and
reject a real quantity value. Found by reading the constraint, not yet run. Proposal: let branch (2)
also follow `(sh:or/rdf:rest*/rdf:first)+/sh:class`, as branch (1) already does for `sh:datatype`.

A smaller point: a bad quantity-value cell is reported on its own blank node, not on the tuple or
array that holds it.

## Next steps

1. Add valid examples of quantity-value cells (a tuple, an array, a collection and a map) and
   invalid ones for each check above, with their rows in the expected-results table.
2. Gap A: the unit and quantity-kind consistency constraint.
3. Gap C: run the optional-position case; if it fails, extend branch (2).
4. Gap B: a sentence in the pattern doc.

