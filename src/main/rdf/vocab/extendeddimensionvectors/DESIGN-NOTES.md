# Extended Dimension Vectors — Design Notes

## What the R, N, and C dimensions represent

Extended dimension vectors (`edv:`) extend the eight SI base dimensions with three
additional dimensions that are dimensionless in SI but carry distinct physical or
economic meaning:

- **R (angle)** — tracks radian-dimension, suppressed in SI. Examples: `R=1`
  for plane angle, `R=2` for solid angle (sr = rad²), `R=−1` for torque
  (τ = dW/dθ), `R=−2` for torsional stiffness and radiance.
- **N (count)** — tracks discrete enumerable entities. Examples: `N=1` for
  particle number, nucleon number, heartbeat count, lumen (cd·sr), NUM/COUNT.
- **C (currency)** — tracks monetary denomination. `C=1` for quantities expressed
  in or directly representing monetary value (prices, costs, exchange amounts);
  `C=0` for all physical, information-theoretic, or dimensionless quantities.
  Unlike R and N, C has no SI factor-unit derivation; it is always set explicitly
  on the unit or quantity-kind definition.

## Dividing line for N=1

Not every integer-valued or "countable" quantity gets `N=1`. The rule is:

> **N=1** when the quantity answers "how many of [this discrete physical
>
>> entity]?" — particles, organisms, turns of wire, nucleons, heartbeats.
>
> **N=0** when the quantity is a dimensionless ratio, a quantum-mechanical
> index, or an information-theoretic unit, even if it is always an integer.

Worked examples from the source ontology:

|       Quantity kind        | R | N | C |                    Rationale                     |
|----------------------------|---|---|---|--------------------------------------------------|
| `AtomicNumber`             | 0 | 1 | 0 | Count of protons; `skos:broader Count`           |
| `MassNumber`               | 0 | 1 | 0 | Count of nucleons; `skos:broader Count`          |
| `NucleonNumber`            | 0 | 1 | 0 | Count of nucleons                                |
| `NeutronNumber`            | 0 | 1 | 0 | Count of neutrons                                |
| `ChargeNumber`             | 0 | 0 | 0 | q/e — a ratio, `skos:broader Dimensionless`      |
| `NuclearSpinQuantumNumber` | 0 | 0 | 0 | Quantum state index                              |
| `InformationContent` (bit) | 0 | 0 | 0 | Information-theoretic unit, not a particle count |

Bits are information units. You do not measure information content by counting
discrete objects the way you count protons; the mathematical structure is
fundamentally different. See also the note in `unit:BIT`'s description.

## Dividing line for C=1

`C=1` when the quantity is a monetary amount or is directly denominated in
a currency unit. `C=0` otherwise.

Worked examples from the source ontology:

|     Quantity kind      | SI dimension vector   | C |               Rationale                |
|------------------------|-----------------------|---|----------------------------------------|
| `Currency`             | `A0E0L0I0M0H0T0D1`    | 1 | Monetary amount; all SI dims zero → D=1 |
| `CurrencyPerFlight`    | `A0E0L0I0M0H0T0D1`    | 1 | Cost denominated in currency            |
| `CurrencyPerTime`      | `A0E0L0I0M0H0T-1D0`   | 1 | Monetary flow rate (e.g. M$/yr)         |
| `CostPerEnergy`        | `A0E0L-2I0M-1H0T2D0`  | 1 | Price per unit energy (e.g. EUR/kWh)    |
| `CostPerPower`         | `A0E0L-2I0M-1H0T3D0`  | 1 | Price per unit power (e.g. EUR/kW)      |
| `CostPerArea`          | `A0E0L-2I0M0H0T0D0`   | 1 | Price per unit area (e.g. EUR/m²)       |
| `CostPerMass`          | `A0E0L0I0M-1H0T0D0`   | 1 | Price per unit mass (e.g. CHF/kg)       |
| `Frequency`            | `A0E0L0I0M0H0T-1D0`   | 0 | Physical rate; no monetary character    |
| `ElectricCurrent`      | `A0E1L0I0M0H0T0D0`    | 0 | SI base quantity; not monetary          |

The D exponent follows the standard convention independently of C: D=1 when all
eight SI base exponents are zero, D=0 otherwise. For a pure currency amount
(T=0, M=0, …), D=1; for a currency rate or density, the non-zero SI exponent
forces D=0.

Because C has no SI base unit and no factor-unit derivation, the extended-DV
consistency check cannot compute C from component units. All C values are
authoritative by definition and will never produce a factor-unit mismatch warning.

## Angle and solid angle are definitional (R=1, R=2)

`unit:RAD` and `unit:SR` are assigned `R=1` and `R=2` respectively by
definition:

- `unit:RAD` has factor units m/m (dimensionless), so the factor-unit
  computation yields `R=0`. The `R=1` assignment is definitional — radian is
  the unit of angle — not derived.
- `unit:SR` = rad², so `R=2` by definition. Same factor-unit limitation applies.

The `qfn:ExtendedDVConsistencyRule` QA shape will always flag these as
warnings. This is expected and correct.

## Becquerel N=1 by convention

`unit:BQ` is assigned `N=1` (each becquerel counts one nuclear disintegration
per second). Its factor units reduce to `1/SEC` with no count factor, so the
consistency check computes `N=0`. The `N=1` assignment is a physical convention,
analogous to the torque `R=−1` convention. The warning is expected.

## Why unit:CYC (cycle) stays N=1, not R=1

Physically, one cycle = 2π rad, which suggests `R=1`. However,
`unit:CYC-PER-SEC` carries `qudt:exactMatch unit:HZ` and
`qudt:hasQuantityKind quantitykind:Frequency` with `conversionMultiplier 1.0`.
Making CYC angular (`R=1, conversionMultiplier = 2π`) would require
reclassifying CYC-PER-SEC as AngularFrequency and removing the HZ equivalence —
directly contradicting the standard physics usage "Hz = cycles per second" where
*cycle* means one complete oscillation (a counted event, not an angular
displacement).

`unit:REV` (revolution) already fills the `R=1, conversionMultiplier = 2π` role.
CYC is kept as a counting unit (`N=1`, conversionMultiplier 1.0) consistent with
the HZ relationship. The consistency check will flag `unit:CYC-PER-SEC` because
CYC has `N=1` but HZ (its exactMatch) has `N=0`.

## Documented Group 2 false positives (dimensional-cancellation conventions)

The following units are assigned R or N values by physical convention that differ
from what the factor-unit consistency check computes. All produce `sh:Warning`
results on every build; none indicate a data error.

### Torque units (R=−1 by convention)

Torque τ = r × F has SI dimension ML²T⁻², identical to energy. The `R=−1`
assignment encodes the angular character (τ = dW/dθ). The factor units N
(newton) and M (metre) carry no angle, so the computation always gives `R=0`.

Affected: `unit:N-M`, `unit:CentiN-M`, `unit:DeciN-M`, `unit:MicroN-M`,
`unit:MilliN-M`, `unit:MegaN-M`, `unit:KiloN-M`, `unit:N-CentiM`,
`unit:DYN-M`, `unit:DYN-CentiM`, `unit:LB_F-FT`, `unit:LB_F-IN`,
`unit:OZ_F-IN`, `unit:KiloGM_F-M`, `unit:PDL-FT`, `unit:PDL-IN`,
`unit:IN-PDL`, and all scaled variants.

### Angular momentum units (R=−1 by convention)

Angular momentum L = r × p = I·ω has SI dimension ML²T⁻¹. The `R=−1`
assignment distinguishes it from Action (also ML²T⁻¹, `R=0`). Factor-unit
computation gives `R=0`.

Affected: `unit:ERG-SEC`, `unit:EV-SEC`, `unit:FT-LB_F-SEC`,
`unit:J-SEC-PER-MOL`, `unit:KiloGM-M2-PER-SEC`, `unit:N-M-SEC`.

### Moment of inertia units (R=0 by convention)

Moment of inertia I = mr² has SI dimension ML². It is assigned `R=0`
(not `R=−2` as radiance also has ML²/sr²), since moment of inertia is a
purely mechanical quantity with no angular-integral interpretation.
Some factor-unit paths traverse torque-bearing intermediates and compute
a different R. The `R=0` assignment is authoritative.

Affected: `unit:KiloGM-CentiM2`, `unit:KiloGM-M2`, `unit:KiloGM-MilliM2`,
`unit:LB-FT2`, `unit:LB-IN2`.

### Cascaded torque/angle compounds

Units formed as [torque unit]/[angle unit] inherit the Group 2 convention from
their torque factor. The factor-unit check computes R from the assigned edv of
N-M (R=0, since N and M have no angle), giving R=−1; the authoritative
assignment is R=−2 (torque R=−1 divided by angle R=1).

Affected: `unit:N-M-PER-RAD`, `unit:N-M-PER-DEG`, `unit:KiloN-M-PER-DEG`,
`unit:N-M-PER-ARCMIN`, `unit:N-M-PER-MIN_Angle`, `unit:N-M-SEC-PER-RAD`,
`unit:N-M-PER-M`, `unit:KiloN-M-PER-M`, `unit:N-M-PER-M-RAD`,
`unit:N-M-PER-DEG-M`, `unit:KiloN-M-PER-DEG-M`,
`unit:LB_F-FT-PER-IN`, `unit:LB_F-IN-PER-IN`.

### Dimensionless-ratio/count cascade

`unit:HUNDRED`, `unit:THOUSAND`, and their multiples are count units (`N=1`).
Units of the form PERCENT-PER-HUNDRED therefore compute `N=−1` (ratio N=0
divided by count N=1). The intended edv is `N=0` — these are dimensionless
ratios (ppt, pph, etc.), not quantities that divide a count.

Affected: `unit:PERCENT-PER-HUNDRED`, `unit:PERCENT-PER-THOUSAND`,
`unit:PERCENT-PER-TEN-THOUSAND`, `unit:PERCENT-PER-HUNDRED-THOUSAND`.

## Factor-unit computation limitations

The `qfn:unit.eDimVec.calculate` function cannot produce a valid edv IRI when
factor-unit exponents are non-integer (fractional). For such units the function
returns no result and the consistency check is skipped; however, if the unit
*does* have an explicit `qudt:hasExtendedDimensionVector` and the function
unexpectedly returns a result (due to integer approximation in SPARQL arithmetic),
a spurious warning may appear.

Known affected units: `unit:PA-M0dot5`, `unit:MegaPA-M0dot5`,
`unit:J-PER-M2-SEC0dot5-K`, `unit:N-M-PER-W0dot5`.

## Minor data quality (Group 3)

`unit:NUM-PER-SEC`, `unit:NUM-PER-YR`, `unit:SAMPLE-PER-SEC` are listed as
`hasQuantityKind Frequency` in addition to `CountRate`. Frequency (T⁻¹, R=0,
N=0) and CountRate (T⁻¹, R=0, N=1) are distinct under the extended dimension
system. The `qudt:UnitExtendedDVConflict` QA shape flags these as well.
