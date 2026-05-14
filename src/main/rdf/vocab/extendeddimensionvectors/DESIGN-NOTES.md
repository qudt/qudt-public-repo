# Extended Dimension Vectors — Design Notes

## What the R and N dimensions represent

Extended dimension vectors (`edv:`) extend the eight SI base dimensions with two
additional dimensions that are dimensionless in SI but carry distinct physical
meaning:

- **R (angle)** — tracks radian-dimension, suppressed in SI. Examples: `R=1`
  for plane angle, `R=−1` for torque (τ = dW/dθ), `R=−2` for moment of
  inertia and radiance.
- **N (count)** — tracks discrete enumerable entities. Examples: `N=1` for
  particle number, nucleon number, heartbeat count.

## Dividing line for N=1

Not every integer-valued or "countable" quantity gets `N=1`. The rule is:

> **N=1** when the quantity answers "how many of [this discrete physical
>
>> entity]?" — particles, organisms, turns of wire, nucleons, heartbeats.
>
> **N=0** when the quantity is a dimensionless ratio, a quantum-mechanical
> index, or an information-theoretic unit, even if it is always an integer.

Worked examples from the source ontology:

|       Quantity kind        | R | N |                    Rationale                     |
|----------------------------|---|---|--------------------------------------------------|
| `AtomicNumber`             | 0 | 1 | Count of protons; `skos:broader Count`           |
| `MassNumber`               | 0 | 1 | Count of nucleons; `skos:broader Count`          |
| `NucleonNumber`            | 0 | 1 | Count of nucleons                                |
| `NeutronNumber`            | 0 | 1 | Count of neutrons                                |
| `ChargeNumber`             | 0 | 0 | q/e — a ratio, `skos:broader Dimensionless`      |
| `NuclearSpinQuantumNumber` | 0 | 0 | Quantum state index                              |
| `InformationContent` (bit) | 0 | 0 | Information-theoretic unit, not a particle count |

Bits are information units. You do not measure information content by counting
discrete objects the way you count protons; the mathematical structure is
fundamentally different.

## Why unit:CYC (cycle) stays N=1, not R=1

Physically, one cycle = 2π rad, which suggests `R=1`. However,
`unit:CYC-PER-SEC` carries `qudt:exactMatch unit:HZ` and
`qudt:hasQuantityKind quantitykind:Frequency` with `conversionMultiplier 1.0`.
Making CYC angular (`R=1, conversionMultiplier = 2π`) would require reclassifying
CYC-PER-SEC as AngularFrequency and removing the HZ equivalence — directly
contradicting the standard physics usage "Hz = cycles per second" where *cycle*
means one complete oscillation (a counted event, not an angular displacement).

`unit:REV` (revolution) already fills the `R=1, conversionMultiplier = 2π` role.
CYC is kept as a counting unit (`N=1`, conversionMultiplier 1.0) consistent with
the HZ relationship.

## Documented dimensional-cancellation ambiguities (Group 2)

The following units serve quantity kinds that share the same SI dimension vector
but differ in R or N. They are assigned `R=0, N=0` as a conservative default.
The `qudt:UnitExtendedDVConflict` QA shape flags all of them on every build.

|                   Unit                    |             Conflicting QK assignments             |
|-------------------------------------------|----------------------------------------------------|
| `unit:J-SEC`                              | `AngularMomentum` (R=−1) vs `Action` (R=0)         |
| `unit:PER-M` (and scaled variants)        | `AngularWavenumber` (R=1) vs `InverseLength` (R=0) |
| `unit:COUNT`, `unit:UNITLESS`, `unit:NUM` | count QKs (N=1) vs dimensionless QKs (N=0)         |
| `unit:FT-LB_F`                            | `Torque` (R=−1) vs `Energy` (R=0)                  |

These represent genuine SI dimensional cancellation and are not expected to be
resolved without introducing dedicated angular or count unit variants.

## Minor data quality (Group 3)

`unit:NUM-PER-SEC`, `unit:NUM-PER-YR`, `unit:SAMPLE-PER-SEC` are listed as
`hasQuantityKind Frequency` in addition to `CountRate`. Frequency (T⁻¹, R=0,
N=0) and CountRate (T⁻¹, R=0, N=1) are distinct under the extended dimension
system. The `qudt:UnitExtendedDVConflict` QA shape flags these as well.
