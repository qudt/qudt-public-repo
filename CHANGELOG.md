# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project is in the process of adopting [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Removed erroneous `^^qudt:LatexString`/`^^rdf:HTML` datatype tags from three plain-text `dcterms:description` values added in this PR (`quantitykind:GustatoryThreshold`, `quantitykind:TouchThresholds`, `unit:NAT`) — none contain LaTeX or HTML markup, and each already carries an untagged `qudt:plainTextDescription` with equivalent content.
- Fixed the purple-submitted changes to IEC quantity kinds, mostly iec61360Code values and one label
- Closed out the unit-less G/H-named quantity kinds:
  - `GyromagneticRatio`: corrected its dimension vector from A·m² (`A0E1L2I0M0H0T0D0`, the magnetic-moment dimension) to charge-per-mass (`A0E1L0I0M-1H0T1D0`, C/kg ≡ rad·s⁻¹·T⁻¹, as its own definition requires) and made it `specializationOf ElectricChargePerMass` so it inherits `unit:PER-T-SEC` and `unit:C-PER-KiloGM`; also fixed the description's ambiguous unit statement (the SI coherent unit is rad·s⁻¹·T⁻¹, equal to C·kg⁻¹ because the radian is dimensionless — the previous text wrote `T^{1}`).
  - `HamiltonFunction`: retyped from `organizedUnder` to `specializationOf quantitykind:Energy` so it inherits the energy units, and rewrote its description — which previously described the Hamilton–Jacobi equation (whose principal function is the action, J·s) — to describe the Hamiltonian itself (`H = Σ pᵢq̇ᵢ − L`, the total energy of the system), repointing the informative reference from the HJE article to Hamiltonian mechanics.
  - `GustatoryThreshold`: corrected from dimensionless to amount-of-substance concentration (`A1E0L-3I0M0H0T0D0`) and made it `specializationOf quantitykind:Concentration` — a taste detection threshold is the detectable concentration of a tastant, mirroring how `OlfactoryThreshold` is already modelled — so it inherits the concentration units.
- Worked through the rest of the sensory-threshold quantity-kind family, on the principle (established for `ActivityThresholds` in #1494) that a threshold is the impact on the receiver, in the units the receiver experiences, not the source:
  - `WarmReceptorThreshold`: dimension corrected from `NotApplicable` to thermodynamic temperature (`A0E0L0I0M0H1T0D0`) and made `specializationOf quantitykind:Temperature`, mirroring its twin `ColdReceptorThreshold`.
  - `PhotoThresholdOfAwarenessFunction`: corrected from a pure time to luminous energy (`A0E0L0I1M0H0T1D0`) and made `specializationOf quantitykind:LuminousEnergy` — a light-detection threshold governed by temporal summation (Bloch's law) is a luminous energy (lm·s); the description also notes that at fixed presentation duration the same threshold may be reported as a luminance or illuminance, with `rdfs:seeAlso` links to both. The previous pure-time dimension looks like a dropped luminous-intensity factor.
  - `SignalDetectionThreshold`: added an interpretation-neutral description (the dimensionless threshold for detecting a signal against noise — a detection proportion/probability, a sensitivity index such as d′, or another dimensionless ratio) and gave the previously bare entry `unit:UNITLESS`, `unit:FRACTION` and `unit:PERCENT` as applicable units.
  - `TouchThresholds`: left as an umbrella term (dimension `NotApplicable`, no units) because tactile thresholds have no single dimension — light-touch detection is a force (von Frey, mN), vibration detection a length (displacement amplitude), two-point discrimination a length (separation); the description now records these possible specializations. Treated the same way as `VisionThresholds`, which remains an abstract umbrella.
- Follow-up to the event-rate cluster reorganisation (#1498): corrected `IncidenceProportion`'s dimension vector from T⁻¹ to dimensionless (`A0E0L0I0M0H0T0D1`) and made it `organizedUnder quantitykind:DimensionlessRatio`, since it is a proportion of a population (cases/population), not a rate — gave it `unit:UNITLESS`/`unit:PERCENT`/`unit:FRACTION` as applicable units, mirroring the sibling `quantitykind:Prevalence`. Repointed `MorbidityRate` and `MortalityRate` from `organizedUnder IncidenceProportion` to `organizedUnder CountRate`, alongside their siblings `Incidence`/`IncidenceRate`, since they remain T⁻¹ rates.
- Closed out unit-less I-named quantity kinds:
  - `InductanceBasedTimeConstant`: made `specializationOf quantitykind:Time` (τ = L/R, in seconds) with a description added, and linked directly to `unit:SEC`/`unit:MilliSEC`/`unit:MicroSEC`. The direct links matter: a quantity kind with none of its own inherits its `specializationOf` parent's entire set, and `Time`'s spans calendar and astronomical units, so the time constant would otherwise have advertised `DAY`, `MO_Synodic`, `YR_Sidereal` and `PlanckTime`. (Its ECLASS twin `ResistanceBasedInductance` is linked to it by `exactMatch` in #1505, which also repoints the henry-per-ohm units — H/Ω being the defining expression of this quantity — from `Time` to the pair.)
  - `HamiltonFunction` is likewise linked directly to `unit:J`/`unit:ERG`/`unit:EV`, so that it no longer inherits all 44 of `Energy`'s units: a Hamiltonian expressed in quads, therms or tonnes of oil equivalent is not useful guidance. Its Lagrangian counterpart is given the same treatment in #1501.
  - `InverseTime` left abstract (the reciprocal-time head that `Frequency`/`CountRate` are organized under). (The `Incidence`/`IncidenceRate`/`IncidenceProportion` cluster is handled separately in #1498 and a follow-up, to avoid colliding with it.)
- Split the `InformationContent` (self-information) family from `InformationEntropy` and renamed its base-variants to the `Binary/Common/NaturalLogarithmic…` convention adopted in #1214: `InformationContent` gained a description and the `unit:SHANNON`/`unit:NAT`/`unit:HART` applicable units (with `rdfs:seeAlso quantitykind:InformationEntropy`); the three new `BinaryLogarithmicInformationContent` (Sh), `CommonLogarithmicInformationContent` (Hart) and `NaturalLogarithmicInformationContent` (nat) are each `specializationOf InformationContent`, carry their single base-unit, and `rdfs:seeAlso` one another. The old `InformationContentExpressedAsALogarithmToBase2/10/E` URIs are deprecated (`qudt:deprecated true`, `qudt:deprecatedInVersion "4.0.0"`, `dcterms:isReplacedBy` the new names). Base-10 information content is carried by both `unit:HART` and `unit:BAN`; and the stale `unit:NAT`/`unit:BAN` descriptions that defined themselves against "the bit" were reconciled to reference the shannon, consistent with the counting/entropy separation from #1497.
- Closed out the unit-less M-named quantity kinds:
  - Linked duplicate concepts to their canonical twins with `qudt:exactMatch`, so units propagate through the exactMatch closure: `MolarThermalCapacity`→`MolarHeatCapacity` (J/(mol·K)); `MolarDensity`→`InverseAmountOfSubstance` (/mol — note the ECLASS concept is reciprocal amount of substance, not a density); `MassRelatedElectricalCurrent`→`MassicElectricCurrent` (A/kg).
  - Corrected `MolarOpticalRotationalAbility`'s dimension vector from `A0E0L2I0M-1H0T0D0` (rad·m²/kg) to `A-1E0L2I0M0H0T0D0` (rad·m²/mol) and pointed its `qudt:exactMatch` at `MolarOpticalRotatoryPower` rather than `SpecificOpticalRotatoryPower`. The ECLASS pair BAJ425/BAJ426 has its dimension vectors swapped, not its names: this entry is defined against *Stoffmengenkonzentration* (amount-of-substance concentration), so it is a molar quantity, while its sibling `SpecificOpticalRotationalAbility` (BAJ425) is defined against *Massenkonzentration* and is the mass-based one. That sibling is S-named and is corrected in #1505.
  - Gave `LagrangeFunction` and `MechanicalSurfaceImpedance` their conventional units directly, so they no longer inherit their parent's entire set. A quantity kind with no direct units takes all of its `specializationOf` parent's, which left the Lagrangian advertising all 44 of `Energy`'s units — including quads, therms, tonnes of oil equivalent and kilowatt-hours — and left the surface impedance advertising `MassPerAreaTime`'s agricultural deposition rates such as `TONNE-PER-HA-YR` and `GM_Carbon-PER-M2-DAY`. They now carry `J`/`ERG`/`EV` and `RAYL`/`RAYL_MKS`/`PA-SEC-PER-M`/`N-SEC-PER-M3` respectively. (`MolecularViscosity` keeps its inherited set: all 22 are genuine viscosity units, and it has the same value as the dynamic viscosity by definition.)
  - `MolecularViscosity` is `specializationOf DynamicViscosity` (its own description already noted it "has the same value as the dynamic viscosity"); `ModulusOfAdmittance` is `specializationOf Admittance`, mirroring the existing `ModulusOfImpedance`→`Impedance`; `MagneticDipoleMomentOfAMolecule` is `specializationOf MagneticMoment` (A·m² — *not* `MagneticDipoleMoment`, which uses the Wb·m convention); `MechanicalSurfaceImpedance` is `specializationOf MassPerAreaTime` (Pa·s/m), mirroring `SpecificAcousticImpedance` from #1495.
  - `MassieuFunction` (J = −A/T) gains `unit:J-PER-K`. `MassicTorque` gains `unit:N-M-PER-KiloGM`, and is deliberately **not** made a specialisation of `SpecificEnergy` despite sharing the m²/s² dimension, preserving the torque/energy split. That unit's previous `unitForQuantityKind quantitykind:SpecificEnergy` link was removed for the same reason: N·m is the torque spelling of the product, whereas a specific energy is expressed in J/kg — `SpecificEnergy` retains thirteen applicable units, including `J-PER-KiloGM` and `J-PER-GM`.
  - `MechanicalImpedance` (Z = F/v) gains `unit:N-SEC-PER-M` and a description. That unit's previous `unitForQuantityKind quantitykind:MassPerTime` link was removed: N·s/m is not a way anyone expresses mass per time, and `MassPerTime` retains ten other applicable units.
  - Corrected `MagneticPolarization`'s dimension vector from A/m (`A0E1L-1I0M0H0T0D0` — magnetization's dimension) to tesla (`A0E-1L0I0M1H0T-2D0`), as its own definition *J*ₘ = μ₀*M* requires; it is now `organizedUnder MagneticFluxDensity` with `unit:T` and `unit:GAUSS` linked directly (same dimension, distinct quantity).
  - Defined `MotorConstant` as the **motor size constant** *K*ₘ = τ/√*P*, correcting its dimension from `A0E0L1I0M0H0T0D0` (metre) to the fractional `A0E0L1I0M0dot5H0T-0dot5D0` (L¹M^½T^−½) and linking the existing `unit:N-M-PER-W0dot5` (N·m/√W), whose `hasFactorUnit` decomposition already implied that dimension but which carried the same incorrect metre dimension and `categorizedByQuantityKind quantitykind:Unknown`. The description records that "motor constant" is also used for the torque constant *K*ₜ = τ/*I* (`rdfs:seeAlso quantitykind:TorqueConstant`) and the back-EMF constant *K*ₑ = *V*/ω.
  - Deprecated `MassAmountOfSubstance` (`qudt:deprecated true`, `qudt:deprecatedInVersion "3.5.0"`, `dcterms:isReplacedBy quantitykind:AmountOfSubstancePerMass`): its mol·kg dimension was unique in the vocabulary and matched no known quantity, and is understood to have been a sign error for mol/kg.
  - Deprecated `MicrobialFormation` with no replacement: it entered QUDT with the initial bulk vocabulary import and has never carried a description, external reference or applicable unit, and no source defining it could be found.
  - Removed `qudt:hasReferenceQuantityKind quantitykind:MassAmountOfSubstance` from `qkdv:A1E0L0I0M1H0T0D0`, which would otherwise have named a deprecated quantity kind as the reference for the mol·kg dimension. That dimension vector now has no reference quantity kind, since no live quantity kind carries it.
- Closed out the unit-less L-named quantity kinds:
  - Linked the IEC-61360-vs-ECLASS duplicate pairs via `qudt:exactMatch` so units propagate through the exactMatch closure: `LinearPower`→`LineicPower` (W/m); `LinearElectricCharge` and `LineicCharge`→`ElectricChargeLineDensity` (C/m); `LineicDataVolume`→`LinearBitDensity` (bit/m); `LineicMass`→`MassPerLength` (kg/m); `LineicTorque`→`TorquePerLength` (N·m/m); `LineicResistance`→`LinearResistance` (Ω/m), also correcting `LineicResistance`'s dimension from `NotApplicable` to `A0E-2L1I0M1H0T-3D0`.
  - `LagrangeFunction`: retyped from `organizedUnder` to `specializationOf quantitykind:Energy` (the Lagrangian L = T − V is an energy, J), so it inherits the energy units.
  - `LinearVoltageCoefficient`: made `specializationOf quantitykind:MagneticFluxPerLength` (the EMF-per-velocity coefficient k = B·L has unit V·s/m ≡ Wb/m), inheriting `V-SEC-PER-M`/`T-M`/`N-PER-A`, mirroring the `ForceConstant` treatment.
  - `LengthPerElectricCurrent`: added the SI coherent unit `unit:M-PER-A` (metre per ampere) and a description; the QK previously had no unit and no twin.
  - `LineicQuantity` left as an abstract `NotApplicable` umbrella (per-length quantities share no single dimension), consistent with other umbrella terms.
- Applied the Common/Natural/Binary logarithm naming convention to the logarithmic ratio and frequency-interval quantity kinds, deprecating the base-explicit names (`qudt:deprecated true`, `qudt:deprecatedInVersion "3.5.0"`, `dcterms:isReplacedBy`):
  - New `CommonLogarithmicRatio` (base 10, carries `unit:DECADE`) replaces `LogarithmRatioToBase10` and `Log10Ratio`; new `NaturalLogarithmicRatio` (base e, carries `unit:NP`) replaces `LogarithmRatioToBaseE` and `LogERatio`.
  - New `CommonLogarithmicFrequencyInterval` (base 10, `unit:DECADE`) replaces `Log10FrequencyInterval` and `LogarithmicFrequencyIntervalToBase10`; new `BinaryLogarithmicFrequencyInterval` (base 2, `unit:OCT`) replaces `LogarithmicFrequencyInterval`. The `unit:DECADE`, `unit:NP` and `unit:OCT` `unitForQuantityKind` links were repointed from the deprecated quantity kinds to the new preferred ones.
  - New `CommonLogarithmicRatioPerLength` (B/m, dB/m, dB/km — all base-10 units by definition of the bel) replaces both `LineicLogarithmicRatio` (ECLASS) and `LinearLogarithmicRatio` (IEC 61360), whose descriptions left the base unstated; the `unit:B-PER-M`, `unit:DeciB-PER-M` and `unit:DeciB-PER-KiloM` links were repointed to it. No natural-log sibling is minted until requested (the natural-log per-length concept is effectively `LinearAttenuationCoefficient`, and no Np/m unit exists).
  - The external references (`qudt:eclassCode`, `qudt:iec61360Code`, `qudt:siExactMatch`, `qudt:wikidataMatch`) of the deprecated quantity kinds are carried by their replacements as well, following the `InformationContent` precedent.
- Wired up the `PressureBased…` quantity-kind family (ECLASS "X divided by the related pressure"). Twelve of its members carried `qkdv:NotApplicable` although their dimensions are entirely determined by the quantity they divide, and matching `…-PER-PA` units already existed in the vocabulary, most of them orphaned as `qudt:categorizedByQuantityKind quantitykind:Unknown`. Each member's dimension is now computed (X's dimension with L+1, M−1, T+2), and the eight with an existing unit are linked to it: `PressureBasedElectricCurrent`→`unit:A-PER-PA`, `PressureBasedTemperature`→`unit:K-PER-PA`, `PressureBasedMass`→`unit:KiloGM-PER-PA`, `PressureBasedLength`→`unit:M-PER-PA`, `PressureBasedVolume`→`unit:M3-PER-PA`, `PressureBasedKinematicViscosity`→`unit:ST-PER-PA`, `PressureBasedDynamicViscosity`→`unit:POISE-PER-PA`, `PressureBasedElectricVoltage`→`unit:V-PER-PA`. Each computed dimension was confirmed against the corresponding unit's own dimension. `PressureBasedAmountOfSubstanceConcentration`, `PressureBasedDensity`, `PressureBasedMassFlow`, `PressureBasedVelocity`, `PressureBasedVolumeFlow` and `PressureBasedMolality` get corrected dimensions but no unit, since no corresponding unit exists; `PressureBasedQuantity` stays an abstract `NotApplicable` umbrella.
  - `unit:POISE-PER-PA`'s `unitForQuantityKind quantitykind:Time` link was replaced by `PressureBasedDynamicViscosity`: P/Pa reduces to a time dimensionally, but it is not a way anyone expresses a duration.
  - Corrected the English description of `PressureBasedAmountOfSubstanceConcentration`, which described a molality (amount of substance divided by the mass of the solvent) although its name, its German text and the separate `PressureBasedMolality` all indicate an amount-of-substance concentration (divided by the volume of the solution).
- Closed out the remaining unit-less O-, P- and Q-named quantity kinds:
  - `QuantityOfLight` `exactMatch quantitykind:LuminousEnergy` (lm·s) and `PhotonLuminance` `exactMatch quantitykind:PhotonRadiance` (/(s·m²·sr)) — ECLASS/IEC names for quantity kinds QUDT already had.
  - `PowerPerAreaAngle` gets `unit:W-PER-M2-SR` directly. It is not the same quantity kind as `Radiance` — `Radiance` is already its `specializationOf` child, being the interpreted radiometric quantity defined against the projected area (the 1/cos α in its definition), while `PowerPerAreaAngle` is the generic W/(m²·sr) family head — so the unit is linked to the parent rather than the two being merged (units propagate parent→child, not child→parent).
  - `OsmoticConcentration` is `specializationOf quantitykind:AmountOfSubstanceConcentration` (mol/L, mol/m³); `PeltierCoefficient` is `specializationOf quantitykind:EnergyPerElectricCharge` (volts) — Π is the heat energy carried per unit charge, as its own description says.
- Retyped the `AreaPerTime` children from `qudt:specializationOf` to `qudt:organizedUnder`, and gave each its conventional units directly. A circulation, a kinematic viscosity, a thermal diffusivity, a diffusion coefficient and a specific angular momentum all have the dimension m²/s but are not mutually convertible, so `specializationOf` wrongly placed them in a single commensurability family; `DiffusionCoefficient` was already `organizedUnder`, and the rest now match it. Because a quantity kind inherits its `specializationOf` parent's units only when it has none of its own, `Circulation`, `ThermalDiffusivity` and `OrbitalAngularMomentumPerMass` had been drawing all eight of `AreaPerTime`'s units — including ft²/h and in²/s — purely by inheritance, and would have been left with no unit at all by the retype. Each is now linked directly to the units it is actually expressed in: `Circulation` and `OrbitalAngularMomentumPerMass` to `unit:M2-PER-SEC`; `ThermalDiffusivity` to `M2-PER-SEC`, `MilliM2-PER-SEC`, `CentiM2-PER-SEC` and `FT2-PER-HR`; `DiffusionCoefficient` additionally to `CentiM2-PER-SEC` (the usual spelling in chemistry). `KinematicViscosity` keeps its conventional `ST`/`CentiST` and additionally gains `M2-PER-SEC` and `MilliM2-PER-SEC` (≡ cSt), which the inheritance had been hiding — it previously resolved to stokes and centistokes only, with no SI-coherent unit at all. `AreaPerTime` itself keeps the full set as the generic head.
  - `PictureElement` is linked to `unit:PIXEL_COUNT`. Its only unit had been `unit:PIXEL`, deprecated in 3.1.2 as ambiguous and split into `unit:PIXEL_AREA` (an area, belonging to `Area`) and `unit:PIXEL_COUNT` (a dimensionless `qudt:CountingUnit`); since deprecated entities are excluded from the inference, `PictureElement` was left with no applicable unit. `PIXEL_COUNT`, whose dimension matches, now carries `qudt:unitForQuantityKind quantitykind:Count` and `quantitykind:PictureElement` in place of its `qudt:categorizedByQuantityKind quantitykind:Count`, consistent with how `unit:COUNT`, `unit:BIT` and `unit:BYTE` are modelled and with the invariant that no unit carries both properties.
  - `ProductOfInertia` is `organizedUnder quantitykind:MomentOfInertia` with a direct `unit:KiloGM-M2` link: a product of inertia is an off-diagonal component of the inertia tensor rather than a kind of moment of inertia, so it is not made a specialisation, but it shares the unit. `ProductOfInertia_X`, `_Y` and `_Z` inherit the unit through their existing `specializationOf ProductOfInertia`.
  - `ParticleCurrentDensity` is `organizedUnder quantitykind:ParticleFluenceRate` with a direct `unit:PER-M2-SEC` link, honouring the ISO 80000-10 distinction (a fluence rate counts particles from all directions; a current density is the net flux through a surface) rather than collapsing them with `exactMatch`.
  - Separated the two senses of `PlanckFunction`. Its dimension was `A0E0L2I0M1H0T-2D0` (energy), which matched neither sense. It is now the ISO thermodynamic Planck function *Y* = −*G*/*T* (`A0E0L2I0M1H-1T-2D0`, J/K, `unit:J-PER-K`), the Gibbs-energy counterpart of the `MassieuFunction` — consistent with its ISO 80000-5 reference and its `seeAlso MassieuFunction`. The blackbody spectral radiance *B*(*T*) material it also carried describes a different quantity of a different dimension, already modelled as `quantitykind:SpectralRadiance`, which it now `seeAlso`s; its `organizedUnder quantitykind:Energy` is dropped.
- Closed out the unit-less T-named quantity kinds (20 in scope; `TouchThresholds` is owned by #1500's sensory-threshold family and excluded).
  - The `TemperatureBased*`/`TemperatureRelated*` family (ECLASS "X divided by the related temperature") mirrors the `PressureBased*` family closed out in #1502: 9 of 12 sat at `NotApplicable` with computable dimensions, and matching `*-PER-K`/`*-PER-DEG_C` units already existed, several orphaned as `categorizedByQuantityKind quantitykind:Unknown`. `TemperatureBasedMass` gains `GM-PER-K`/`KiloGM-PER-K`/`MilliGM-PER-K`/`TONNE-PER-K`/`TON_Metric-PER-K`/`GM-PER-DEG_C`; `TemperatureBasedDynamicViscosity` gains the poise-per-K family and `PA-SEC-PER-K`; `TemperatureBasedKinematicViscosity` gains `ST-PER-K`; `TemperatureBasedLength` and `TemperatureRelatedVolume` gain `M-PER-K`/`M3-PER-K` directly (see below). `TemperatureBasedAmountOfSubstanceConcentration`, `TemperatureBasedDensity`, `TemperatureBasedMassFlowRate`, `TemperatureBasedVelocity`, `TemperatureBasedVolumeFlowRate` and `TemperatureRelatedMolarMass` get corrected dimensions but no unit — none exists, and none is minted speculatively. `TemperatureBasedQuantity` stays an abstract `NotApplicable` umbrella, like `PressureBasedQuantity`.
  - `TemperatureBasedLength`/`TemperatureRelatedVolume` are **not** the same quantity as `LinearThermalExpansion`/`VolumeThermalExpansion` despite sharing a dimension: the ECLASS entries are generic "quantity ÷ temperature" ratios, while thermal expansion is the specific physical response dL/dT. Rather than merge them, the (pre-existing) expansion quantity kinds are made `qudt:organizedUnder` the newly-dimensioned generic ones — `LinearThermalExpansion` under `TemperatureBasedLength`, `VolumeThermalExpansion` under `TemperatureRelatedVolume` — keeping their own conventional units (`M-PER-K` etc., `FT-PER-DEG_F`, `BTU_IT-PER-LB_F-DEG_F`, …) as the specific case grouped under the generic head, mirroring how `AreaPerTime` was structured in #1502.
  - Duplicates linked with `qudt:exactMatch`: `ThermalInsulation` (ECLASS BAJ404) → `ThermalInsulance` (m²·K/W, CLO — same "ΔT ÷ areic heat flow" definition); `ThermalCoefficientOfLinearExpansion` (ECLASS BAJ473) → `LinearExpansionCoefficient` (%/K); `TransmissionRatioBetweenRotationAndTranslation` (ECLASS BAJ400) → `RotaryTranslatoryMotionConversion` (m/rad, in/rev — "how an angle is converted into a linear path"); `TotalRadiance` (ECLASS BAJ318) → `EnergyFluenceRate`, whose own description states the identical formula ψ = dΨ/dt.
  - `TorqueConstant` (ECLASS BAJ298 / IEC UAD201) gains `unit:N-M-PER-A` directly, per ECLASS 16.0 data supplied on #1503 (`0173-1#05-AAA136#005`, newton-metre-per-ampere); `rdfs:seeAlso` links to `ForceConstant` (the related N/A quantity, one length short) and `MotorConstant` (corrected in #1501 to the motor size constant that already `seeAlso`s this entry).
  - `ThrustCoefficient` carried the dimension of pressure (`A0E0L-1I0M1H0T-2D0`), but its own description — "thrust force per unit of frontal area per unit of incompressible dynamic pressure" — is force ÷ (area × pressure), which is dimensionless, as its name implies. Corrected to `A0E0L0I0M0H0T0D1`, `organizedUnder DimensionlessRatio` with `UNITLESS`/`FRACTION`, and given an `informativeReference` to Wikipedia's Thrust coefficient article.
  - `TimeRelatedLogarithmicRatio` (ECLASS BAJ415, "logarithm of a ratio … divided by the related time") states no base, so its name needs no change — but the only per-time logarithmic unit that exists is `unit:NP-PER-SEC` (neper per second, orphaned as `Unknown`), which is base-*e*. Rather than assert an unstated base onto the ECLASS entry, a new `TimeRelatedNaturalLogarithmicRatio` is added as its `specializationOf`, carrying `NP-PER-SEC` directly (the ISO 80000-3 damping coefficient δ); the parent also keeps a direct link to the same unit, since `specializationOf` inheritance only reaches a child with no unit of its own — here both have one.
  - Discovered while linking `TotalRadiance`: `qudt:exactMatch` only propagates a target's *direct* `unitForQuantityKind` links, not units the target itself only inherits via `specializationOf`. `EnergyFluenceRate` has no direct units of its own (all inherited from `PowerPerArea`), so `TotalRadiance`'s `exactMatch` alone produced zero applicable units; `TotalRadiance` now also carries a direct `specializationOf quantitykind:PowerPerArea`, matching `EnergyFluenceRate`'s own relation, giving it a working one-hop inheritance path alongside the semantic `exactMatch`.
- Closed out the unit-less E-named quantity kinds: `EinsteinTransitionProbabilityForSpontaneousOrInducedEmissionAndAbsorption` `exactMatch` `EinsteinCoefficients`; `ExposureOfIonizingRadiation` `exactMatch` `Exposure`; `ExposureRateOfIonizingRadiation` `exactMatch` `ExposureRate`; `EvaporativeHeatTransfer` dimension corrected from W/(m²·K) to W (matching its Φ-family siblings) and made `specializationOf HeatFlowRate`, with its truncated description completed.
- Corrected the swapped dimension vectors of `EquilibriumConstantBasedOnConcentration` (now mol/m³) and `EquilibriumConstantBasedOnPressure` (now Pa); gave them direct applicable units (`MOL-PER-L`/`MOL-PER-M3` and `PA`/`BAR`) and `rdfs:seeAlso` links to their dimensionless `EquilibriumConstantOn…Basis` counterparts.
- Retyped `EquilibriumConstantOnConcentrationBasis` and `EquilibriumConstantOnPressureBasis` from `qudt:specializationOf` to `qudt:organizedUnder quantitykind:EquilibriumConstant` — Kc, Kp and the thermodynamic K° are all dimensionless but have no fixed inter-conversion, so they are not commensurable; their `UNITLESS` applicable unit is preserved via direct `unitForQuantityKind` links. Replaced the copy-pasted descriptions across the equilibrium-constant cluster with texts documenting each entity's dimension convention (dimensionless ISO 80000/IEC 61360 vs dimensional ECLASS) and why both forms are maintained.
- Corrected the `rdfs:label` of `quantitykind:EvaporativeHeatTransferCoefficient` (was a copy of "Combined Non Evaporative Heat Transfer Coefficient").
- Removed the `qudt:CountingUnit` type from `unit:UNITLESS` — it is the unit for plain dimensionless values (refractive index, Reynolds number, equilibrium constants, …), not a count of entities; it remains a `qudt:DimensionlessUnit`.
- Closed out the unit-less F-named quantity kinds: `FailureRate` gets `NUM-PER-HR`/`NUM-PER-YR` directly; `ForceConstant` (the electromechanical N/A constant, not the mechanics spring constant) is `specializationOf MagneticFluxPerLength`, inheriting `N-PER-A`/`T-M`/`V-SEC-PER-M`, with a disambiguating description; `FundamentalReciprocalLatticeVector` is `specializationOf InverseLength` with direct `PER-ANGSTROM`/`PER-M` units, mirroring `FundamentalLatticeVector`.
- Closed out the unit-less D-named quantity kinds: `DatasetOfBytes` (IEC 61360) `exactMatch ByteDataVolume` + `specializationOf AmountOfData`, mirroring `DatasetOfBits`, with a description added; `DataTransmissionRate` dimension corrected from `NotApplicable` to T⁻¹ and made `specializationOf DataRate` (a transmission-context specialisation; `DataRate` itself also covers non-transmission contexts such as storage or bus throughput); `DecayConstant` (λ) given direct `unitForQuantityKind` on the plain reciprocal-time units `PER-SEC`/`PER-MIN`/`PER-HR`/`PER-DAY`/`PER-WK`/`PER-MO`/`PER-YR`/`PER-MilliSEC` (previously only `Frequency`), since a decay constant is not itself a cyclic frequency.
- Reorganised the event-rate cluster: `Incidence` (IEC 61360) is now `qudt:exactMatch quantitykind:IncidenceRate`, with its description corrected from the probability (incidence-proportion) reading to the rate reading and a `seeAlso` to `IncidenceProportion`; `Incidence`, `IncidenceRate` and `FailureRate` are `organizedUnder quantitykind:CountRate` (`FailureRate`'s former `specializationOf Incidence` removed — reliability and epidemiological rates are not mutually comparable); `IncidenceRate` gets `NUM-PER-YR` directly, which propagates to `Incidence` via the exactMatch closure (the population-normalised `CASES-PER-…INDIV-YR` units stay with `MorbidityRate` — converting a per-capita rate to a plain rate requires the population size, so they are not units of `IncidenceRate`).
- Added `unit:CASES-PER-HUNDRED-THOUSAND-INDIV-YR` (→ `MorbidityRate`) and `unit:DEATHS-PER-HUNDRED-THOUSAND-INDIV-YR` (→ `MortalityRate`), the standard per-100 000 epidemiology scale missing from the `…INDIV-YR` contextual-unit family (10⁵ has no SI prefix, hence the spelled-out names).
- Corrected the acoustic impedance quantity-kind family: `AcousticImpedance` dimension vector fixed from L⁻² to L⁻⁴ (p/q, Pa·s/m³) with `specializationOf PressureInRelationToVolumeFlow`; `SpecificAcousticImpedance` (p/v, Pa·s/m) enriched and made `specializationOf MassPerAreaTime`; `CharacteristicAcousticImpedance` repointed to `SpecificAcousticImpedance`; unit–QK links corrected accordingly; `PressureInRelationToVolumeFlow` and `PressureInRelationToVolumeFlowRate` linked as `exactMatch`.
- Tagged `rdfs:label` values on `qudt:QuantityKind` and `qudt:Prefix` that were missing a language tag. The existing title-case fix (`mvn -Pfix install`) now also defaults an untagged label to `@en` (consistent with `qudt:RdfsLabelInTitleCaseShapeWarning`, which already treated untagged labels as English), and a new dedup rule removes untagged labels that were redundant leftovers alongside an identical, already-`en`/`en-US`/`en-UK`-tagged label. Deprecated entities are left untouched, as before. This is now enforced automatically on every build rather than needing a one-off cleanup.
- Corrected `quantitykind:ActivityThresholds`: description changed from physical/metabolic activity to absorbed-dose safety thresholds (gray), matching its existing specific-energy dimension; added `qudt:specializationOf quantitykind:AbsorbedDose` so it inherits the gray unit family; removed the `qudt:latexSymbol` (duplicated `TouchThresholds`'s `T_t`) and the `qudt:isoNormativeReference` (unverified for this reading).

### Changed

- **BREAKING:** Redefined `unit:BIT`, `unit:BYTE`, `unit:OCTET` and the entire prefixed (SI + binary) and compound (`-PER-SEC`, `-PER-M`/`M2`/`M3`) BIT/BYTE ladder as **counting/storage** units. Their `conversionMultiplier` values are now clean counts (`BIT`=1, `BYTE`=8, `KiloBYTE`=8000, `GibiBYTE`=8589934592, …) instead of the former information-entropy scaling (× ln2), and they carry `qudt:CountingUnit` and point to `quantitykind:BitDataVolume`/`ByteDataVolume` (density/rate compounds keep their `LinearBitDensity`/`DataRate`/etc. kinds). The information-entropy sense is unchanged and remains on `unit:SHANNON` (base 2), `unit:NAT` (base e) and `unit:HART` (base 10); `unit:BIT` no longer duplicates the shannon. This aligns with ISO/IEC 80000-13. Migration: consumers using `unit:BIT`/`unit:BYTE` for information entropy should switch to `unit:SHANNON`.
- Added `quantitykind:AmountOfData` as the general "amount of digital data" kind (`organizedUnder quantitykind:Count`), with `BitDataVolume`, `ByteDataVolume` and `DatasetOfBits` as its `qudt:specializationOf` so bits and bytes remain mutually commensurable; `BitDataVolume` and `DatasetOfBits` are additionally `qudt:exactMatch`.
- The symmetric-relation inference (driven by `qudt:SymmetricRelation`, currently only `qudt:exactMatch`) now materialises the inverse triple for **quantity kinds**, **physical constants**, and **prefixes**, as well as units, so `qudt:exactMatch` need only be authored in one direction. (Coordinate reference frames and datatypes also use `qudt:exactMatch` but aren't yet covered, pending a way to target their multi-level subclass hierarchies; see the `rdfs:comment` on `qudt:SymmetricRelationShape`.) Previously the inference was wired up for units only — broadening `sh:targetClass` to other classes had no effect unless their graph was also fed into the inference step, which it wasn't.
- `qudt:unitForQuantityKind` is now propagated across the `qudt:exactMatch` equivalence closure before applicable-unit inference, so every member of an `exactMatch` clique shares the same applicable units even when a unit is authored on only one member. Applicable-unit inference itself still traverses `qudt:specializationOf` only; this pre-step is what lets it reach `exactMatch` siblings without crossing the relation directly.
- Cleaned up the applicableUnit values for BitRate and ByteRate.
- Reclassified `unit:IU` (International Unit) from amount of substance to mass-equivalent: `qudt:hasDimensionVector` is now mass (`M`), and it measures `quantitykind:AmountOfBiologicallyActiveSubstance` (also re-dimensioned to `M`, `qudt:organizedUnder quantitykind:MassEquivalent`). The IU/volume and IU/mass derived units cascade accordingly: `IU-PER-L`/`IU-PER-MilliL` become mass concentration under `PlasmaLevel`/`SerumLevel`, and `IU-PER-MilliGM` becomes dimensionless under `quantitykind:MassFraction`.
- Reclassified `quantitykind:ReactivePower` from `qudt:organizedUnder quantitykind:ElectricPower` to `qudt:specializationOf quantitykind:NonActivePower`: reactive power is the sinusoidal special case of non-active power (they are commensurable — both measured in var — but equal only under sinusoidal conditions). The var unit family (`VAR` and its prefixes) now attaches to `quantitykind:NonActivePower` via `qudt:unitForQuantityKind`, and `quantitykind:ReactivePower` inherits them through `qudt:specializationOf`, so its `qudt:applicableUnit` set is unchanged.
- Changed `quantitykind:Magnetization` `qudt:specializationOf` from `quantitykind:LinearElectricCurrent` to `quantitykind:ElectricCurrentPerLength`.

### Added

- Added `quantitykind:DataCapacity` (`specializationOf quantitykind:AmountOfData`) for the storage/transmission capacity sense, replacing the deprecated `quantitykind:Capacity`; having no direct units of its own, it inherits the full bit+byte unit set from `AmountOfData`.
- Modelled the median-information-flow family on the `ElectricPower` pattern: the base-specific quantity kinds `BinaryLogarithmicMedianInformationFlow`, `CommonLogarithmicMedianInformationFlow` and `NaturalLogarithmicMedianInformationFlow` are each `qudt:specializationOf quantitykind:InformationFlowRate` and carry a single direct unit (`SHANNON-PER-SEC`, `HART-PER-SEC`, `NAT-PER-SEC` respectively), while `InformationFlowRate` keeps all three. A direct `qudt:unitForQuantityKind` overrides `specializationOf` inheritance, so each specialization advertises only its own log-base unit even though all three are commensurable.
- Closed out the remaining unit-less C-named quantity kinds: `CurrentOfTheAmountOfSubstance` `exactMatch quantitykind:MolarFlowRate`; and `CutoffCurrentRating` (the fuse I²t-value) dimension corrected from `NotApplicable` to A²·s (`qkdv:A0E2L0I0M0H0T1D0`), with `unit:A2-SEC` retyped from `categorizedByQuantityKind quantitykind:Unknown` to `unitForQuantityKind`.
- Added `qudt:exactMatch` between `quantitykind:Activity` and `quantitykind:RadioactiveDecay`, and between `quantitykind:Magnetization` and `quantitykind:MagnetizationField`. The radioactivity units (the `BQ`/`CI` families) now also carry `qudt:unitForQuantityKind quantitykind:RadioactiveDecay`.
- Added `qudt:qkdvNumerator`/`qudt:qkdvDenominator` to `quantitykind:RelativeHumidity` and `quantitykind:RelativePartialPressure`.
- Added `qudt:unitForQuantityKind quantitykind:BodyMassIndex` to `unit:KiloGM-PER-M2`.
- Gave `quantitykind:AtomicStoppingPower`, `AreaBitDensity`, and `Currency` commensurability links (`exactMatch`/`specializationOf`) so they inherit applicable units; abstract parents `AreicDataVolume` and `Asset` left unit-less by design.
- Assigned the `N·m/m²` unit family to `quantitykind:AreicTorque`; added `qudt:organizedUnder quantitykind:ForcePerLength`.
- Added `qudt:qkdvNumerator`/`qkdvDenominator` (mass/mass) to `MassFraction`, `MassFractionOfDryMatter`, `MassFractionOfWater`, and `MassRatio`.
- Added `unit:PERCENT`/`unit:FRACTION` to `quantitykind:MassFraction`, and `unit:FRACTION` to `quantitykind:MassRatio`; cross-linked the two with `rdfs:seeAlso`.
- Added bidirectional `qudt:exactMatch` between `quantitykind:LinearElectricCurrent` and `quantitykind:ElectricCurrentPerLength` (same quantity, two source vocabularies).
- Added `qudt:specializationOf quantitykind:CountRate` to `quantitykind:StochasticProcess`.
- Gave the remaining unit-less B-named quantity kinds commensurability links: `BandwidthDistanceProduct` `specializationOf` `BandwidthLengthProduct` (with `unit:MegaHZ-KiloM` retyped from `Unknown` to `BandwidthLengthProduct`). (The `BinaryLogarithmicMedianInformationFlow` treatment is superseded by the median-information-flow family model under Changed.)
- Added a release-pipeline validation gate that checks the distribution zip — archive integrity, presence of the core artifacts (units, quantity kinds, the normative SHACL schema, and the all-in-one files), and a sanity floor on the Turtle-file count — before the GitHub Release is published and before the qudt-r2 website publish is triggered, so a corrupted or incomplete build cannot reach the live site. When a release aborts before the GitHub Release is published, the workflow now also deletes the tag and branch that `release:prepare` had already pushed, so the same version can simply be re-run without manual cleanup.
- Added a version-increment guard to the Release workflow: the requested release version must be a single step from the last released `vX.Y.Z` tag (PATCH+1, MINOR+1 with PATCH reset, or MAJOR+1 with MINOR/PATCH reset), failing fast otherwise. The `next_snapshot_version` input is now optional and defaults to the release version with PATCH+1 and `-SNAPSHOT` (e.g. `3.4.1` → `3.4.2-SNAPSHOT`) when left blank.

### Deprecated

- Deprecated `quantitykind:Capacity` (vague — its definition conflated data-storage capacity with fuel/food capacity, symbol `"TBD"`), `dcterms:isReplacedBy` the new `quantitykind:DataCapacity`.

## [3.4.0] - 2026-06-25

### Added

- Added `qudt:SpecializationOfAndOrganizedUnderDisjointShape`, a Violation-severity QA check that fires when a non-deprecated quantity kind carries both an outgoing `qudt:specializationOf` and an outgoing `qudt:organizedUnder`. The two properties are mutually exclusive by design.
- Added rigor to building the quantity kind commensurability families. Now, a quantity kind family now constitutes the necessary and sufficient requirement for commensurability.
- Added code to automatically convert labels for quantity kinds into Title Case
- Added qudt:eclassCode
- Added `qudt:organizedUnder`, an organizational grouping relation (a sub-property of `skos:broader`) that does **not** assert commensurability and does **not** confer units on its members; commensurability and `qudt:applicableUnit` are both derived from `qudt:specializationOf` (and `qudt:exactMatch`) only. (Applicable-unit inference originally traversed `skos:broader`/`qudt:organizedUnder` as well; this was tightened later in this release — see the `qudt:applicableUnit` entries under Changed.)
- Added a Warning-severity QA check that `qudt:organizedUnder` only groups quantity kinds of the same dimension.
- Added a Violation-severity QA check that `qudt:specializationOf` only relates quantity kinds of the same dimension (a stricter counterpart to the `qudt:organizedUnder` check, since a commensurable specialisation must share its parent's dimension).
- Added explicit, individually-validatable relations for the precise meanings that had been overloaded onto `skos:broader` and `qudt:hasQuantityKind`: `qudt:specializationOf` (a quantity kind that is a more-specific, *commensurable* kind of its parent — a sub-property of `skos:broader`), `qudt:unitForQuantityKind` (a unit that measures, and is convertible within, a commensurable family — a sub-property of `qudt:hasQuantityKind`), and `qudt:categorizedByQuantityKind` (a unit filed under a non-commensurate quantity-kind category such as `quantitykind:Unknown` or `quantitykind:DimensionlessRatio`, with no convertibility claim — a sub-property of `qudt:hasQuantityKind`). Authors assert the precise sub-property; the build materialises the super-property (`skos:broader` / `qudt:hasQuantityKind`) into the released graphs, so existing consumers see no change.
- Added equivalent concentration units for clinical chemistry (Eq/L family)
- Added RateOfChangeOfFrequency and HZ-PER-SEC to support power systems

### Changed

- Changed all qudt:symbol annotations with an ECLASS IRDI to qudt:eclassCode
- Decoupled the dimensionless quantity kinds from commensurability. The abstract grouping nodes `quantitykind:Dimensionless` and `quantitykind:DimensionlessRatio` (and the ratio/factor groupings beneath them) were linked by `skos:broader`, which made all ~90 dimensionless quantity kinds one commensurability family — wrongly reporting e.g. strain, efficiency, Mach number and quantum numbers as mutually comparable. Those 89 `skos:broader` edges are now `qudt:organizedUnder`, so each is its own family; applicable units are unchanged.
- Rehomed several units that were mis-parked on `quantitykind:Dimensionless` to their proper quantity kinds (e.g. `SUSCEPTIBILITY_ELEC`→`ElectricSusceptibility`, `NP`→`LogarithmRatioToBaseE`, `DECADE`→`LogarithmRatioToBase10`), so only genuinely generic units are inherited by dimensionless kinds.
- Moved the `loop3d` community extension's graph IRIs from `http://qudt.org/community/loop3d` (and `…/community/loop3d/voc`) to `http://qudt.org/extension/loop3d` (and `…/extension/loop3d/voc`), with the maintainer's agreement, so that all community extensions live under a consistent `extension/{id}/` path. The vocabulary content (units) is unchanged.
- Moved the `qudt-skos-integration` community extension's schema graph IRI from `http://qudt.org/community/extensions/qudt-skos-integration` to `http://qudt.org/extension/qudt-skos-integration/schema`, continuing the migration of community extensions onto the consistent `extension/{id}/` path. The content (`qudt:Concept rdfs:subClassOf skos:Concept`) is unchanged.
- Re-typed the unambiguous, judgement-free cases to the new relations: 228 same-dimension `skos:broader` edges to `qudt:specializationOf`, 2598 `qudt:hasQuantityKind` links to `qudt:unitForQuantityKind`, and 454 `qudt:hasQuantityKind quantitykind:Unknown` links to `qudt:categorizedByQuantityKind`. This is fully backward compatible — the released `skos:broader`, `qudt:hasQuantityKind`, and `qudt:applicableUnit` triples are unchanged (only the new sub-property triples are added). The remaining cases that need judgement — coincidence-prone hierarchy edges, generic dimensionless units, cross-family unit links, and physical constants — are left unchanged pending review.
- Completed the quantity-kind commensurability families by re-typing the remaining reviewed hierarchy edges: 154 `skos:broader` edges to `qudt:specializationOf`; 5 to `qudt:organizedUnder`, decoupling the inverse-time "rate zoo" whose members only share a dimension (`Frequency`/`DecayConstant`/`RateOfChange` under `InverseTime`, and `Activity`/`RadioactiveDecay` under `StochasticProcess`); and 11 `qudt:organizedUnder` edges to `qudt:specializationOf` for genuine dimensionless specialisations (e.g. `Strain`→`LengthRatio`, `RelativePartialPressure`→`PressureRatio`). `qudt:applicableUnit` values are unchanged; this only corrects which quantity kinds are reported as commensurable. (`Speed`/`Velocity` are kept non-commensurate, pending explicit scalar/vector datatypes.)
- Moved commensurability-family inference off `skos:broader` and onto the precise relations: the family closure now traverses `qudt:specializationOf` (together with `qudt:exactMatch`) instead of `skos:broader`, and `qudt:organizedUnder` is now declared a sub-property of `skos:broader` whose super-property the build materialises into the released graphs. This is fully backward compatible: released `skos:broader` regains every organizational grouping edge (it gains the 91 `qudt:organizedUnder` edges and loses none), while `qudt:applicableUnit` and `qudt:hasQuantityKind` are byte-for-byte unchanged. The substantive effect is that `skos:broader` no longer implies commensurability — organizational groupings can again be carried on `skos:broader` without making their members comparable.
- Extended the quantity-kind hierarchy with further `qudt:specializationOf`, `qudt:organizedUnder`, and `qudt:exactMatch` edges, completing the family structure across the remaining reviewed dimension clusters. Corrected all non-English `rdfs:label` values on `quantitykind:ElectricPower`, which had previously read "active power" in every language other than English.
- Converted the next tier of `qudt:hasQuantityKind` links to the precise sub-properties: 14 links targeting `quantitykind:Unknown` → `qudt:categorizedByQuantityKind`; 25 links from units pointing exclusively to generic dimensionless placeholders → `qudt:categorizedByQuantityKind`; 271 links where all QK targets lie in one `(qudt:specializationOf | qudt:exactMatch)` commensurability family → `qudt:unitForQuantityKind`. Deprecated units are left unchanged. 653 cross-family links remain pending individual review.
- Converted the remaining cross-family (`§4`) `qudt:hasQuantityKind` links: the 19 reviewed unit–quantity-kind signatures are now expressed with `qudt:unitForQuantityKind` (commensurate cases) or `qudt:categorizedByQuantityKind` (non-commensurate cases). The union of quantity kinds for `unit:NUM` and `unit:COUNT` (which are `qudt:exactMatch`) is now symmetric across both units; their link to `quantitykind:Count` was `qudt:categorizedByQuantityKind` at this point and was later promoted to `qudt:unitForQuantityKind` (see below). Added `qudt:exactMatch` between `quantitykind:ElectricChargeLineDensity` and `quantitykind:LinearElectricChargeDensity`. Added `qudt:organizedUnder quantitykind:Count` to `quantitykind:NumberOfParticles` (joining the other count sub-kinds that already had it). Added `qudt:specializationOf quantitykind:MagneticFieldStrength` to `quantitykind:Coercivity`; removed the now-redundant `qudt:hasQuantityKind quantitykind:Coercivity` from `unit:A-PER-M`.
- Converted 17 more `§4` `qudt:hasQuantityKind` links to `qudt:unitForQuantityKind`: the 12 `quantitykind:SpecificEntropy` units (`J-PER-KiloGM-K`, `CAL_IT-PER-GM-DEG_C`, `BTU_IT-PER-LB-DEG_F`, etc.) and the 5 `quantitykind:MeanMassRange` units (`GM-PER-MilliM2`, `KiloGM-PER-M2`, `LB-PER-IN2`, `LB-PER-YD2`, `OZ-PER-IN2`). Added `qudt:organizedUnder quantitykind:MassPerArea` to `quantitykind:MeanMassRange`: a mean mass range (linear range × mass density) shares `MassPerArea`'s dimension but is not the same kind of quantity as an areal mass density, so it is grouped under it without asserting commensurability; its own 5 units remain its sole, self-contained commensurability family. 13 cross-family links remain pending review.
- Restricted `qudt:applicableUnit` inference to traverse only `qudt:specializationOf` (previously `skos:broader|qudt:organizedUnder`), so every applicable unit is now guaranteed commensurable with its quantity kind. `qudt:organizedUnder` no longer confers units on its members — it remains a pure organizational/navigational relation (still materialised onto `skos:broader`, still validated to link only same-dimension quantity kinds). **This is a substantive change to released `qudt:applicableUnit` values**, unlike the prior entries in this work-stream, which only added relations without changing inferred output. Three quantity kinds would otherwise have gone from a unit list to none, by inheriting units across a non-commensurable `qudt:organizedUnder` edge: `quantitykind:ElectricEnergy`/`quantitykind:ActiveEnergy` (from `quantitykind:Energy`) and `quantitykind:ShannonDiversityIndex` (from `quantitykind:InformationEntropy`); likewise 34 dimensionless coefficient/ratio quantity kinds (e.g. `Efficiency`, `DragCoefficient`, `MoleFraction`, `Transmittance`) would have lost the generic units they only ever had via inheritance from `quantitykind:Dimensionless`/`quantitykind:DimensionlessRatio`. All 37 were given their own direct `qudt:unitForQuantityKind` triples so none go empty: the 34 dimensionless cases received the same unit set they previously inherited, now as a direct, self-contained family (13 of them only ever had `UNITLESS`, so they get a one-member family; the other 21 get the shared 14-unit `DimensionlessRatio` scale-notation set — `FRACTION`, `PERCENT`, `PPM`, etc.); `quantitykind:ElectricEnergy` received its own electrically-relevant subset of `Energy`'s units (`J` + SI prefixes, `W-HR` + prefixes, `W-SEC`), mirroring the existing `quantitykind:ElectricPower`/`quantitykind:Power` pattern, with `quantitykind:ActiveEnergy` inheriting them via `qudt:specializationOf`; `quantitykind:ShannonDiversityIndex` received the information-theoretic subset of `quantitykind:InformationEntropy`'s units (`BIT`, `NAT`, `SHANNON`), excluding the storage-capacity units that don't apply to a diversity index. A further 169 quantity kinds have no `qudt:applicableUnit` value either before or after this change (a pre-existing gap, out of scope here). Corrected the `qudt:organizedUnder` schema description (`SCHEMA_QUDT.ttl` and its NoOWL variant), which had stated that applicable-unit inference traverses `qudt:organizedUnder` and, in one of the two copies, that commensurability is tested via `skos:broader` rather than `qudt:specializationOf`.
- Further restricted `qudt:applicableUnit` inference to attach units via `qudt:unitForQuantityKind` only, rather than the materialised `qudt:hasQuantityKind` super-property. `qudt:categorizedByQuantityKind` (and any not-yet-classified legacy `qudt:hasQuantityKind`) makes no commensurability claim, but the build pipeline materialises both `qudt:unitForQuantityKind` and `qudt:categorizedByQuantityKind` into `qudt:hasQuantityKind` *before* applicable-unit inference runs, so the old query (which read `qudt:hasQuantityKind`) let categorised, non-vetted units leak into `qudt:applicableUnit` indistinguishably from vetted ones — most visibly on `quantitykind:Unknown`, whose `qudt:categorizedByQuantityKind` units span 87 distinct dimensions. This closes that gap. 10 quantity kinds were newly orphaned and addressed: `quantitykind:Dimensionless` (`UNITLESS`), `quantitykind:Ratio` (`ONE-PER-ONE`), and `quantitykind:DimensionlessRatio` (`FRACTION`, `GR`, `ONE-PER-ONE`, `PERCENT`, `PERMILLE`, `PERMITTIVITY_REL`, `PPB`, `PPM`, `PPQ`, `PPT`, `PPTH`, `PPTM`, `PSU`, `UNITLESS`) had their own `qudt:categorizedByQuantityKind` triples promoted to `qudt:unitForQuantityKind` — these are genuinely interconvertible alternate notations of the same dimensionless ratio, unlike the broader set of quantity kinds organised under `Dimensionless`/`DimensionlessRatio`, which remain decoupled. `quantitykind:NormalizedDimensionlessRatio` and `quantitykind:PositiveDimensionlessRatio` needed no direct edit, regaining their units automatically by inheriting from the now-fixed `quantitykind:DimensionlessRatio` via `qudt:specializationOf`. Four quantity kinds whose only unit attachment was an unclassified legacy `qudt:hasQuantityKind` were converted to `qudt:unitForQuantityKind` as clean, unambiguous own-unit cases: `quantitykind:AngularReciprocalLatticeVector` (`RAD-PER-M`), `quantitykind:BloodGlucoseLevel` (`MilliMOL-PER-L`), `quantitykind:CombinedNonEvaporativeHeatTransferCoefficient` (`KiloW-PER-M2-K`, `W-PER-M2-K`), `quantitykind:RecombinationCoefficient` (`M3-PER-SEC`). `quantitykind:Count`'s 19 `qudt:categorizedByQuantityKind` units (`BEAT`, `CASES`, `DEATHS`, `FLIGHT`, etc.) were deliberately *not* all promoted: they are counts of different discrete things, not alternate notations of one number, and asserting them all commensurable would reintroduce the same false-commensurability pattern this work-stream has been removing elsewhere. Only `COUNT` and `NUM` (already `qudt:exactMatch` of each other, and the genuinely generic/abstract count units) were promoted to `qudt:unitForQuantityKind quantitykind:Count`; the other 17 keep their `qudt:categorizedByQuantityKind` and so no longer contribute to `Count`'s `qudt:applicableUnit`. Added the missing `qudt:CountingUnit` type to `unit:BasePair`, `unit:GigaBasePair`, and `unit:PIXEL_COUNT`, which had it omitted.
- A few more vocabulary tweaks: changed `quantitykind:MorbidityRate` and `quantitykind:MortalityRate` from `qudt:specializationOf` to `qudt:organizedUnder quantitykind:IncidenceProportion` — both share `IncidenceProportion`'s dimension (`A0E0L0I0M0H0T-1D0`, a rate) but a case rate and a death rate are not interconvertible, so the shared `qudt:specializationOf` parent was falsely placing `unit:CASES-PER-KiloINDIV-YR` and `unit:DEATHS-PER-KiloINDIV-YR` in the same commensurability family, the same "rate zoo" pattern already fixed for `InverseTime`'s children. `qudt:applicableUnit` is unaffected, since both quantity kinds already resolve to their own direct units. Reclassified `unit:M2-PER-N` from `qudt:unitForQuantityKind quantitykind:Unknown` to `quantitykind:Compressibility`.
- Cleaned up numerous references from Units to QuantityKinds to provide more meaningful applicableUnit values.
- Converted the last 8 `qudt:hasQuantityKind` links to `qudt:unitForQuantityKind`, completing the migration off the legacy relation for all non-deprecated units: `unit:A-HR-PER-M2`/`unit:C-PER-M2` (`quantitykind:ElectricPolarization`), `unit:GigaHZ-M` (`quantitykind:LinearVelocity`), `unit:M2-PER-KiloGM` (`quantitykind:SpecificSurfaceArea`), and `unit:PER-BAR`/`unit:PER-MegaPA`/`unit:PER-PA`/`unit:PERMILLE-PER-PSI` (`quantitykind:InversePressure`). Each had exactly one quantity-kind target, and every other unit already pointing at that target used `qudt:unitForQuantityKind`, so no judgement call was involved.
- Filled in further `qudt:specializationOf`/`qudt:organizedUnder`/`qudt:exactMatch` gaps surfaced by the same-dimension family review: `BitRate`/`ByteRate` → `specializationOf DataRate`; `ElectromagneticWavePhaseSpeed` → `organizedUnder Speed`; `EnergyExpenditure` → `specializationOf MassicPower` (also corrected its dimension vector, which had been Power's rather than SpecificPower's); `GasLeakRate` → `specializationOf EnergyFluence` (dimension vector corrected likewise); `HamiltonFunction`/`LagrangeFunction`/`PlanckFunction` → `organizedUnder Energy`; `HeartRate`/`RespiratoryRate` → `organizedUnder CountRate`; `NonActivePower` → `organizedUnder ElectricPower`; `Period`/`SpecificImpulse` → `organizedUnder Time`; `VentilationRatePerFloorArea` → `specializationOf SurfaceRelatedVolumeFlowRate`. Added `qudt:exactMatch` between several synonym pairs that had drifted apart with separate `qudt:applicableUnit` sets (`RotationalStiffness`/`TorsionalRigidity`, `SurfaceRelatedVolumeFlow`/`SurfaceRelatedVolumeFlowRate`/`VolumetricFlux`, `VapourPermeability`/`WaterVapourPermeability`), and `qudt:specializationOf TorquePerAngle` to `TorsionalRigidity`. Reclassified `SpecificImpulseByWeight` from a (incorrect, dual-parent) `specializationOf` of both `SpecificImpulse` and `Time` to a single `organizedUnder SpecificImpulse`. `qudt:applicableUnit` changes follow from the new `exactMatch`/`specializationOf` edges: e.g. units of `SurfaceRelatedVolumeFlow` now also apply to `SurfaceRelatedVolumeFlowRate` and `VolumetricFlux`, and `SEC`/`MilliSEC` now also apply to `SpecificImpulse`.

### Fixed

- Fixed `inferApplicableUnits` to union units from all equidistant unit-bearing ancestors instead of arbitrarily picking one. The previous `ORDER BY … LIMIT 1` pattern was non-deterministic when two parents sat at the same minimum distance; the new query computes `MIN(?steps)` and keeps every ancestor at that distance, deterministically unioning their units.
- Fixed a missing qudt:element property for datatype:ONstate and datatype:OFFstate

## [3.3.0] - 2026-05-25

### Added

- Added support for community extensions: domain-specific vocabularies and even schema changes can now be maintained separately in `src/main/rdf/community/extensions/{id}/` and included in the build using `-Dqudt.supported.extensions=id1,id2`. Extensions are validated and inference-corrected alongside core vocabulary. This capability is fully backward compatible — users who do not supply extension IDs see no change in build behaviour or output.
- Added quantitykind:ProductOfInertia as a replacement for the deprecated quantitykind:PRODUCT-OF-INERTIA
- Added unit:OHM-FT (Ohm Foot), the imperial counterpart to unit:OHM-M, for resistivity in well-logging and petrophysics applications
- Added unit:HectoHZ (Hectohertz), the 100-fold SI prefix scaling of unit:HZ
- Added  quantitykind:ApparentEnergy and completed the ElectricEnergy specialization hierarchy
- Added unit:BAR-PER-M (Bar per Metre), unit:PSI-PER-FT (Psi per Foot), and unit:PSI-PER-M (Psi per Metre) for pressure gradients.
- Added 6 energy intensity units: W-HR-PER-FT2, KiloW-HR-PER-FT2, MegaW-HR-PER-FT2, GigaW-HR-PER-FT2, MegaW-HR-PER-M2, GigaW-HR-PER-M2
- Added quantitykind:LiquidLevel

### Changed

- Housecleaning: Removed zero-valued conversion offset triples since they are assumed to be zero if missing.
- Migrated 31 quantity kinds that are specific to the field of propulsion to the extensions folder.
- Dimension vector exponent properties (`qudt:dimensionExponentFor*`, `qudt:dimensionlessExponent`) are now inferred from the dimension vector IRI local name during the build rather than stored explicitly in source. `VOCAB_QUDT-DIMENSION-VECTORS.ttl` is ~2200 lines shorter as a result. The sole exception is `qkdv:NotApplicable`, which has no parseable IRI structure.

### Deprecated

- `qkdv:A0E-2L2I0M1H-1T-2.5D0` — replaced by `qkdv:A0E-2L2I0M1H-1T-2dot5D0`; standardises on `dot` encoding for fractional exponents in dimension vector IRIs
- `unit:J-PER-M2-SEC0pt5-K` — replaced by `unit:J-PER-M2-SEC0dot5-K`; standardises on `dot` encoding in unit IRIs

### Fixed

- Fixed missing `a qudt:DerivedUnit, qudt:Unit` declarations on `unit:J-PER-M2-SEC0pt5-K` and `unit:J-PER-M2-SEC0dot5-K`
- Added missing `qudt:hasFactorUnit` triples (J¹·m⁻²·s⁻⁰·⁵·K⁻¹) to `unit:J-PER-M2-SEC0dot5-K` and `unit:J-PER-M2-SEC0pt5-K`, following the pattern of `unit:MegaPA-M0dot5`
- Fixed build pipeline filters in four `sparql2shacl` queries (`factorUnits`, `conversionMultiplier`, `conversionMultiplierPrecision`, `scalingOf`): the exclusion for units with fractional-exponent IRIs used `CONTAINS(...,"dot")`, missing units with the older `pt` decimal encoding; updated to a regex covering both
- Removed some erroneous references from the datatypes schema metadata to the coordinate systems schema under construction
- Fixed some small errors in qudt:ArrayDataOrder, qudt:MassPropertiesArray, qkdv:A0E1L0I0M-1H0T0D0, and unit:RT
- Fixed the types of datatype:ONstate, datatype:OFFstate, datatype:WDST_WET, and datatype:WDST_DRY
- Removed datatype:True and datatype:Yes (use datatype:TRUE and datatype:YES instead)
- Added explicit property declarations for qudt:baseCGSUnitDimensions, qudt:baseImperialUnitDimensions, qudt:baseISOUnitDimensions, qudt:baseSIUnitDimensions, and qudt:baseUSCustomaryUnitDimensions
- Added explicit property declaration for qudt:enumeratedValue

## [3.2.1] - 2026-04-02

### Added

- Added numerators and denominators to angular concepts

### Changed

- Refactored the datatypes schema and vocabulary to have a separate set for coordinate systems schema and vocabulary

### Fixed

- Moved datatype instances from qudt: to datatype: namespace, along with all references to them
- Addressed remaining issues raised in comments to PR 1418
- Moved datatypes validation queries out of datatypes schema
- Fixed IEC 61360 informative references
- Fixed unit:GRAIN-PER-LB_M that contained qudt:scalingOf. Not used for compound units.
- Copied some missing labels from deprecated quantity kinds to their replacement

## [3.2.0] - 2026-03-25

### Added

- Added `unit:PicoCI` (picocurie, pCi)
- Added `unit:PicoCI-PER-L` (picocuries per litre)
- Added `unit:GRAIN-PER-LB_M` (grains per pound-mass): dimensionless mass-ratio unit
- Added `quantitykind:SpecificHumidity`: ratio of mass of water vapour to total mass of air parcel, with `skos:broader quantitykind:MassRatio`
- Added `unit:DU` (Dobson Unit), with thanks to @larsbarring.
- Added `quantitykind:ZenithAngle`: angle from zenith to an object; broader: `PlaneAngle`
- Added `quantitykind:ElectricEnergy`: integral of electric power over time (e.g. kWh); broader: `Energy`
- Added `quantitykind:ThermalPower`: rate of thermal energy transfer (e.g. heating/cooling output); broader: `Power`
- Added `quantitykind:ReactiveEnergy`: integral of reactive power over time (e.g. kvarh); broader: `Energy`
- Added `quantitykind:ElectricCurrentImbalance`: phase current deviation from average in polyphase systems; broader: `DimensionlessRatio`
- Added `quantitykind:VoltageImbalance`: phase voltage deviation from average in polyphase systems; broader: `DimensionlessRatio`
- Changed `hasQuantityKind` on VAR-hour units (`VAR-HR`, `KiloVAR-HR`, `MegaVAR-HR` and their deprecated V-A Reactive equivalents) from `Energy` to `ReactiveEnergy`

### Changed

- Switched from hand-curated OWL main and datatype schemas to derivations from the SHACL schemas.
- Refactored the SHACL Datatypes schema and the Datatypes vocabulary
- Renamed graph metadata object names (vaem:GMD_...) for consistency
- Make use of correct symbol `var` for reactive power quantities
- Expanded the use of the conversion multiplier calculation in the build to recalculate and validate existing values as well

### Deprecated

- `quantitykind:CENTER-OF-MASS`
- `quantitykind:CONTRACT-END-ITEM-SPECIFICATION-MASS`
- `quantitykind:CONTROL-MASS`
- `quantitykind:DELTA-V`
- `quantitykind:DRY-MASS`
- `quantitykind:FLIGHT-PERFORMANCE-RESERVE-PROPELLANT-MASS`
- `quantitykind:FUEL-BIAS`
- `quantitykind:GROSS-LIFT-OFF-WEIGHT`
- `quantitykind:INERT-MASS`
- `quantitykind:MASS-DELIVERED`
- `quantitykind:MASS-GROWTH-ALLOWANCE`
- `quantitykind:MASS-MARGIN`
- `quantitykind:MASS-PROPERTY-UNCERTAINTY`
- `quantitykind:NOMINAL-ASCENT-PROPELLANT-MASS`
- `quantitykind:PREDICTED-MASS`
- `quantitykind:PRODUCT-OF-INERTIA`
- `quantitykind:RESERVE-MASS`
- `quantitykind:TARGET-BOGIE-MASS`
- `quantitykind:Debye-WallerFactor` (replacement: `quantitykind:DebyeWallerFactor`)
- `quantitykind:ElectricChargeLinearDensity` (replacement: `quantitykind:LinearElectricChargeDensity`)
- `quantitykind:EnergyInternal` (replacement: `quantitykind:InternalEnergy`)
- `quantitykind:EnergyKinetic` (replacement: `quantitykind:KineticEnergy`)
- `quantitykind:Half-Life` (replacement: `quantitykind:HalfLife`)
- `quantitykind:Half-ValueThickness` (replacement: `quantitykind:HalfValueThickness`)
- `quantitykind:IntinsicCarrierDensity` (replacement: `quantitykind:IntrinsicCarrierDensity`)
- `quantitykind:Landau-GinzburgNumber` (replacement: `quantitykind:LandauGinzburgNumber`)
- `quantitykind:Long-RangeOrderParameter` (replacement: `quantitykind:LongRangeOrderParameter`)
- `quantitykind:MaximumBeta-ParticleEnergy` (replacement: `quantitykind:MaximumBetaParticleEnergy`)
- `quantitykind:Non-LeakageProbability` (replacement: `quantitykind:NonLeakageProbability`)
- `quantitykind:RF-Power` (replacement: `quantitykind:RFPower`)
- `quantitykind:RelaxationTIme` (replacement: `quantitykind:RelaxationTime`)
- `quantitykind:RiseOfOffStateVoltage` (replacement: `quantitykind:RateOfRiseOfOffStateVoltage`)
- `quantitykind:Rotary-TranslatoryMotionConversion` (replacement: `quantitykind:RotaryTranslatoryMotionConversion`)
- `quantitykind:Short-RangeOrderParameter` (replacement: `quantitykind:ShortRangeOrderParameter`)
- `quantitykind:Slowing-DownArea` (replacement: `quantitykind:SlowingDownArea`)
- `quantitykind:Slowing-DownDensity` (replacement: `quantitykind:SlowingDownDensity`)
- `quantitykind:Slowing-DownLength` (replacement: `quantitykind:SlowingDownLength`)
- `quantitykind:VaporPressure` (replacement: `quantitykind:VapourPressure`)
- `quantitykind:WaterVaporDiffusionCoefficient` (replacement: `quantitykind:WaterVapourDiffusionCoefficient`)
- `unit:CH` (replacement: `unit:CHAIN`)
- `unit:CD_IN` (replacement: `unit:CD_IT`)

### Fixed

- Tracked down and fixed errors in the OWL schema that were causing problems in Protege
- Fixed the `qudt:hasQuantityKind` of `unit:MicroS-PER-M`
- Fixed the `rdfs:isDefinedBy` of `unit:MicroM-PER-SEC2`
- Fixed a couple of hard-coded dcterms:modified dates so they auto-update during build
- Added some missing metadata in the datatypes vocabulary graph, needed for publication
- Improve definitions of arcmin, min_angle, min, arcsec
- Corrected conversionMultipliers for statfarad (unit:FARAD_Stat), Lambert (unit:LA), and Part per Quadrillion (unit:PPQ), as well as factorUnitScalar for Lambert (unit:LA)
- Corrected statfarad multiplier that was off by a factor of 1e6
- Fixed various errors (mostly conversion multipliers) for DENIER, PENNYWEIGHT, DWT, THERM_EC, THERM_EEC, PT, HP_Brake and more (thanks to @larsbarring
  )

## [3.1.11] - 2026-02-19

### Added

- Added LatexSymbol:gamma to quantityKind:ElectricConductivity

### Changed

- Cleaned up skos:broader relationships between the variants of quantitykind:Strain, including LinearStrain, ShearStrain, VolumeStrain.
- Redefined quantitykind:IonConcentration to the commonly used meaning of moles per volume, not number per volume. quantitykind:IonDensity remains number per volume but is no longer qudt:exactMatch with quantitykind:IonConcentration.
- Moved applicableUnits from quantityKind: Conductivity to quantityKind: ElectricConductivity

### Deprecated

- Removed quantityKind:Conductivity in favour of explicit quantitykind: ElectricConductivity

### Fixed

- Corrected the conversion multiplier for unit:MegaPA-M-dot5
- Fixed incorrect metadata in the SHACL datatypes schema
- Fixed some corrupted Powerpoint and pdf slide decks in src/main/docs
- Changed units derived from `unit:INDIV`, such as `unit:KiloIndiv` to have the correct `qudt:conversionMultiplier`, not `0.0` (which incorrectly indicates that no conversion is possible).

## [3.1.10] - 2026-01-15

### Added

- Added a validation constraint to ensure consistent dimension vectors between a deprecated entity and its replacement
- Added unit symbols for `unit:CYC`, `unit:FRAME`, `unit:MIL_Angle`, and `unit:MIL_Length`.
- Added the following quantity kinds for unit:UNITLESS: `quantitykind:LengthRatio`, `quantitykind:LuminousFluxRatio`, `quantitykind:ResistanceRatio`, `quantitykind:VoltageRatio`, and `quantitykind:TimeRatio`.

### Fixed

- Fixed the conversion multiplier inference to fix values in src that incorrectly assert 0.0. As a result, corrected the conversion multiplier for unit:MilliEQ-PER-HectoGM
- Fixed erroneous dimension vectors found with the validation constraint described above
- Augmented the type declaration for 5 dimension vectors
- Not a true fix, but a workaround to leave untouched any units that contain non-integer exponents (e.g. unit:PA-M0dot5). Currently we cannot compute the conversion multipliers and factor declarations for such (rare) occurrences.

## [3.1.9] - 2025-12-16

### Added

- Added unit:MicroMOL-PER-KiloGM-YR
- Added unit:L-PER-HA
- Added quantitykind:CATION-EXCHANGE-CAPACITY, unit:EQ, unit:MilliEQ, and unit:MilliEQ-PER-HectoGM

### Changed

- Increased the precision of conversion multipliers for unit:DEG, unit:REV and related units

### Fixed

- Found and fixed some erroneous values for rdfs:isDefinedBy
- Fixed the FactorUnit type declaration build error that was discovered since 3.1.8
- Explicitly typed some URI references as xsd:anyURI

## [3.1.8] - 2025-11-13

### Added

- Added quantityKind:CoolingPerformanceRatio & unit:KiloW-PER-TON_FG
- Added a new class and instances for crypto currency units
- Added an inference in the build that causes inheritance of rdfs:type down the skos:broader hierarchy.

### Changed

- sh:prefixes now uses ontology declaration for datatypes sh:select queries
- Fixed spelling errors in descriptions for CurrencyUnit, fieldCode, normativeReference, BaseDimensionMagnitude. For both OWL and SHACL schemas. ([Vlad Korolev](https://github.com/vladistan))

### Deprecated

- Replaced CM_H2O with CentiM_H2O

### Fixed

- Added a type declaration (qudt:FactorUnit) for the anonymous nodes describing factor units.

## [3.1.7] - 2025-10-27

### Added

- Defined some missing factor units, such as unit:MicroGALILEO
- Added unit:PERMILLE, analogous to unit:PERCENT
- Added quantityKind:RateOfChange & unit:PERCENT-PER-SEC
- Added unit:TON_UK-PER-HR
- Added unit:RAYL_MKS to distinguish it from the CGS version, unit:RAYL

### Changed

- Build process
  - with `-DdeprecatedInVersion=[releaseVersion]`, a maven build now generates all vocab files from that `releaseVersion` into
    `target/deprecated-in-[releaseVersion]`, containing only the entities that are `qudt:deprecated` in that
    release
- Declared a few more units as being of type qudt:ContextualUnit, such as unit:SAMPLE-PER-SEC.
- Modified the build process to generate all component units. If a compound unit is a qudt:ContextualUnit, then so are the **newly generated** component units. So, for example, unit:SAMPLE is now generated as a ContextualUnit to support unit:SAMPLE-PER-SEC. This is needed to allow consistent validation of factor units, dimension vectors and other relations. Converseley, if an **existing** ContextualUnit is a component of a compound unit, then that compound unit is also declared as a ContextualUnit.
- Further modified the build process to define new dimension vectors if they are referred to by a unit, but do not yet exist.
- Another build update, to add rdfs:isDefinedBy triple for any units where it is missing
- Replaced quantityKind:Frequency to quantityKind:RateOfChange for unit:PERCENT-PER-YR & unit:PERCENT-PER-WK

### Deprecated

- Replaced OHM_CIRC-MIL-PER-FT with OHM-MIL_Circ-PER-FT
- Replaced unit:PER-MILLE-PSI with unit:PERMILLE-PER-PSI
- Replaced unit:MIL with unit:MIL_Angle and unit:MIL_Length to distinguish the two meanings
- Deprecated unit:HeartBeat in favor of unit:BEAT

### Fixed

- Fixed the distinction between unit:MI_US (U.S. Survey Mile) and unit:MI (International mile).
- Corrected errors in the definition of the variants of constant:MolarVolumeOfIdealGas...
- Fixed 17 unmatched HTML tags in description fields.
- Fixed some missing rdfs:isDefinedBy triples in the datatypes vocabulary.

## [3.1.6] - 2025-09-29

### Added

- `quantitykind:NumberOfElectricalPhases` for use with AC circuits

### Changed

- Build process
  - 'qudt:ucumCode' is now calculated based on factor units or base units, the same way `qudt:symbol` is. The 'canonical'
    form is used throughout no (`/`), just multiplication of factors with positive or negative exponents, in the order
    they appear in the unit's localname
- SHACL shapes: enforce at most one `qudt:ucumCode` per unit.

### Deprecated

- Deprecated dimension vector A0E0L0I0M0H0T0D0, which has no valid definition. A unit or quantity kind either has a dimension based on the 7 base SI dimensions, or it is dimensionless, with a "D1".

### Fixed

- Fixed typo in `qudt:ucumCode` of `unit:MegaN-PER-M2`
- Tweaked some multi-line validation error messages for environments that only display the first line (e.g. TopBraid)
- Fixed `qudt:ucumCode` of many units, such that they all follow the same pattern (see 'Changed' below), and such that
  no unit has more than one.
- Fixed descriptions of `quantitykind:Activity` and `quantitykind:ActivityConcentration` ([Henrike Fleischhack](https://github.com/henrikef)).

## [3.1.5] - 2025-08-28

### Added

- `unit:NCM` to support the Dutch hydrocarbons sector
- `unit:NCM_1ATM_0DEG_C_NL` which is quantified further by `unit:NCM`
- `unit:SCM_1ATM_0DEG_C` which is a contextual unit of `unit:SCM`
- `unit:SCM_1ATM_15DEG_C_ISO` which is a contextual unit of `unit:SCM`
- `unit:SCM_1ATM_15DEG_C_NL` which is a Dutch hydrocarbons sector quantification of `unit:SCM`
- `unit:MicroM-PER-SEC2`, originally requested by @nicholascar
- Explicitly declared all the xsd datatypes to be instances of rdfs:Datatype in the SHACL datatypes schema file
- Added links to the matching Wikidata entities that point to QUDT entities
- Added altSymbol mM to MillMOL-PER-L
- Added new relation qudt:hasReciprocalUnit to link units that are reciprocal, such as `unit:W-PER-K` and `unit:K-PER-W`.
- Added `qk:TimePerCount` and units `unit:SEC-PER-NUM`, with scaled versions
  - `unit:MIN-PER-NUM`
  - `unit:HR-PER-NUM`
  - `unit:DAY-PER-NUM`
  - `unit:WK-PER-NUM`
  - `unit:MO-PER-NUM`
  - `unit:YR-PER-NUM`
- Added `qk:PowerPerVolume` and equivalent `qk:PowerDensity`
- Added
  - `unit:KiloN-PER-CentiM2`
  - `unit:KiloN-PER-MillM2`
  - `unit:MegaN-PER-M2`
  - `unit:MegaN-PER-M3`
- Added a check enforcing a `rdf:type qudt:Unit` triple for each unit.
- Added
  - `unit:MIN-PER-KiloM`, `unit:MIN-PER-MI` and `qk:Pace`

### Changed

- Build process change by [Florian Kleedorfer](https://github.com/fkleedorfer)
  - Unit labels are now autogenerated for a number of languages, wherever possible
  - Title Case is now enforced in unit labels for many languages and warned about in other entity labels

### Deprecated

- Removed schema/extensions/FUNCTIONS_QUDT.spin.ttl that is no longer used in the calculation of applicable units
- Removed src/build/all-in-one/all-in-one-ontology.ttl that is no longer used in creating the all-in-one files
- Depecated quantitykind:DensityOfStates in favor of quantitykind:VibrationalDensityOfStates, to clarify its distinction from quantitykind:EnergyDensityOfStates

### Fixed

- Fixed datatype definitions missing rdfs:isDefinedBy triples
- Fixed the case of qudt:SIGNED and UNSIGNED to be qudt:Signed and qudt:Unsigned
- Corrected `quantitykind:BohrMagneton` to `constant:BohrMagneton`
- Corrected `quantitykind:MagneticFluxQuantum` to `constant:MagneticFluxQuantum`
- Fixed some typos
- Fixed source formatting with `mvn spotless:apply`, which was broken by a recent change.
- Fixed a variety of entities that were referred to but not defined (thanks to @ektrah).
- Updated src/main/rdf/schema/SCHEMA-FACADE_QUDT.ttl to remove obsolete imports
- Moved and renamed some files in src/build for future collection files
- Renamed folder `src/build/srcgen` to `src/build/sparql2shacl` to reflect the folder's purpose more precisely
- Fixed a typo in the `quantitykind:Length` description
- Cleaned up treatment of Imperial Gallons and exact matches
- Fixed typo in MilliL & MilliMOL-PER-L
- Moved `qudt-shacl-functions.ttl` from `src/main/rdf/validation` to
  `src/build/validation` because this file is only used during the build and are not to be distibuted with the release.
- Removed all import references to `COLLECTION_QUDT_QA_TESTS_ALL.ttl`, but left it in the src/main/rdf/validation folder for development users (especially those using environments like TopBraid that follow transitive import closures). Validating that file will validate the entire QUDT vocabulary & ontology graph set against the development tests, as well as the user tests.
- Moved the triples from `src/build/inference/factorUnits/predefined-factor-units-and-scalings.ttl` to the units file
- Fixed symbol of `unit:BFT`
- `unit:W-PER-M3` used to be `qk:ForcePerAreaTime` which is weird, it is assciated with new `qk:PowerPerVolume`,  `qk:PowerDensity`
- Moved some constraints that were in the SHACL-SCHEMA-SUPPLEMENT file over to the SCHEMA_QUDT_NoOWL.ttl file where they belong
- Fixed error in qfn:bound function

## [3.1.4] - 2025-07-18

### Added

- New Distribution Files
  - dist/QUDT-all-in-one-SHACL.ttl: the union of all vocab files and the shacl schema.
  - dist/QUDT-all-in-one-OWL.ttl: the union of all vocab files and the OWL schema.
  - Users can load just one of these files as a convenience, without needing to follow transitive owl:imports.
- New Units
  - `M2-PER-HR` to support the Netherlands water pumping sector
  - `unit:BAR_A` which is implied by `unit:MilliBar_A`
  - `unit:BasePair` which is implied by `unit:GigaBasePair`
  - `unit:FLOPS` which is implied by e.g `unit:TeraFLOPS`
  - `unit:Ci` (deprecated) which is implied by e.g. now-deprecated `unit:KiloCi`

### Changed

- Build process
  - Recoverable data errors in `src` are now automatically fixed with the `fix` profile, ie using `mvn -Pfix install`
    Autocorrection is only possible for units that are either derived or scaled. Derived units are those for which
    `qudt:hasFactorUnit` triples are generated during the build. Scaled units are those for which `qudt:scalingOf`
    triples are generated.
    The following properties will be auto-generated or corrected for such units:
    - `qudt:conversionMulitplier`
    - `qudt:conversionMulitplierSN`
    - `qudt:hasDimensionVector`
    - `qudt:symbol`
    - `qudt:hasQuantityKind`
    - `qudt:hasReferenceQuantityKind`
    - `qudt:systemDerivedQuantityKind`
    - `skos:broader`
    - `rdfs:seeAlso`
  - Improved consistency checks
    - Checks for dimension vectors based on factors / scalingOf
    - Checks for missing deprecation triples
    - Checks for mixing of factors and scalingOf
  - Inference calculations during the build process were sped up by an order of magnitude
  - Dimension vectors for scaled units and derived units can now be inferred
  - Set conversion multiplier 1.0 on each currency unit (in `unit:` namespace)
  - Set conversion multiplier for any unit that does not have one to 0.0 at the end of the build process
  - Every unit now has a conversion multiplier
  - Certain consistency problems can now be fixed in the source with the `fix-src` pipeline (`mvn rdfio:pipeline@fix-src`)
  - Replaced references to deprecated concepts with the replacement concepts
- Descriptions
  - Changed "Thermal heat capacity" to "total energy per unit mass, commonly known as specific enthalpy" for unit:BTU_TH-PER-LB
  - Changed "Thermal heat capacity" to "total energy per unit mass, commonly known as specific enthalpy" for unit:J-PER-KiloGM
  - Further specified sources for, and applications of, unit:SCM and derivatives, including linking to unit:NCM

### Deprecated

- `unit:MicroGAL-PER-M` (new unit: `unit:MicroGALILEO-PER-M`)
- `unit:MilliGAL` (new unit: `unit:MilliGALILEO`)
- `unit:MilliGAL-PER-MO` (new unit: `unit:MilliGALILEO-PER-MO`)
- `unit:Ci` (added for consistency, new unit: `unit:CI`)
- `unit:KiloCi` (new unit: `unit:KiloCI`)
- `unit:MicroCi` (new unit: `unit:MicroCI`)
- `unit:MilliCi` (new unit: `unit:MilliCI`)
- `unit:CAL_15_DEG_C` (new unit: `unit:CAL_15DEG_C`)
- `quantitykind:ConductivityVariance_NEON` (replacement: `quantitykind:ConductivityVariance`)
- `quantitykind:MolarFluxDensityVariance_NEON` (replacement: `quantitykind:MolarFluxDensityVariance`)
- `quantitykind:TemperatureVariance_NEON` (replacement: `quantitykind:TemperatureVariance`)
- Deprecated quantity kinds that represented the union of several other quantity kinds. Treatment of alternatives should be handled by applications.

### Fixed

- Added `qudt:hasQuantityKind quantitykind:AmountOfSubstanceFraction` to `unit:PPM`, `unit:PPB`, `unit:PPT`, `unit:PPQ`, `unit:PPTM`, `unit:PPTH`, and removed it from `unit:UNITLESS`
- Fix wrong `qudt:isReplacedBy CCY_CCY_AED` statement in old currency units file `src/main/rdf/vocab/currency/VOCAB_QUDT-UNITS-CURRENCY.ttl`.
- Corrected dimension vectors of units
  - `unit:VAR`
  - `unit:VAR-PER-K`
  - `unit:KiloVAR-PER-K`
  - `unit:MicroVAR-PER-K`
  - `unit:MilliVAR-PER-K`
  - `unit:W-PER-M2-MicroM` (also required using a different QuantityKind)
- Add factor units to `unit:VAR`
- Add `unit:KiloCubicFT qudt:scalingOf unit:FT3
- Corrected mixing factors and scalingOf in `unit:DEG_C`
- Prefixes and scalingOf are now always consistent: all units with scaling prefix (e.g. `KiloM`) now have `qudt:scalingOf`
- Make `rdfs:label`s treatment of Titlecase more consistent for units
- Corrected multiplier of `unit:MIL`
- Added `unit:GM qudt:scalingOf unit:KiloGM`, such that the standard algorithm for determining conversion multipliers (following factor units and scalings recursively) applies correctly.
  E.g, for `unit:DecaGM`: `conversionMultiplier = prefix:Deca.prefixMultiplier * unit:GM.conversionMultiplier = 10.0 * 0.001 = 0.01`
- Corrected 136 unit symbols
- Prevent title case violations in `rdfs:label` values of `qudt:Unit, qudt:QuantityKind, qudt:Prefix, qudt:PhysicalConstant, qudt:ConstantValue`.

## [3.1.3] - 2025-06-26

### Added

- Added an updated intro slide deck in the doc folder
- New Units
  - `unit:CCY_CHF-PER-HA`
- Auto-generate labels for units wherever possible

### Changed

- All instances of `xsd:decimal` are limited to a maximum precision of 34 significant digits
- Build process by [Florian Kleedorfer](https://github.com/fkleedorfer)
  - New maven goal `rdfio:pipeline` that allows for fine-grained rdf file manipulation
  - New `mainPipeline` execution for the bulk of rdf munging
  - New `src/main/rdf/validation/qudt-shacl-functions.ttl` to make some intricate functionality
    available to SPARQL and SHACL
  - New `unitTestPipeline` for unit testing the SHACL functions
  - Derived units: recalculation of `qudt:conversionMultiplier` and `qudt:conversionMultiplierSN`
    - During the build, all derived units' conversion multipliers are checked based on their `qudt:factorUnits`
      and replaced with the calculated result if necessary

### Deprecated

- Deprecated unit:CHF-PER-KiloGM in favor of unit:CCY_CHF-PER-KiloGM
- Deprecated roughly 36 Quantity Kinds in favor of more consistently-named and natural-language-friendly URIs. Specifically, URIs containing
  underscores are renamed except when the underscore identifies a component (e.g. x, y, z, imaginary, real).
  Quantity Kinds raised to a power are renamed (e.g. Time_Squared becomes SquareTime)
- Cleaned up some confusion regarding unit:PERM_US and unit:PERM_Metric, resulting in the deprecation of some related units. The summary
  is that the magnitude of a PERM does not change with temperature, but measurements made on materials will have different measured values
  at different temperatures.

### Fixed

- Fixed erroneous prefix definition for cross-references to SI Quantity (equivalent to qudt:QuantityKind)
- Corrected symbol for `unit:IN_H2O` from `inH₂0` to `inH₂O` [Reto Schneebeli](https://github.com/reto-siemens)
- Removed wrong `qudt:conversionMultipliers` from `src` (they are now generated correctly in `target`, see 'Changed'). Affected units:
  - `unit:MicroKAT-PER-L, unit:MilliKAT-PER-L, unit:NanoKAT-PER-L, unit:PicoKAT-PER-L, unit:MilliOSM-PER-KiloGM`

## [3.1.2] - 2025-05-30

### Added

- New Units
  - unit:KiloPOISE
  - unit:PIXEL_Count
  - unit:PIXEL_Area
  - unit:CCY_BGN-PER-KiloW-HR
  - unit:CCY_CHF-PER-KiloW-HR
  - unit:CCY_CZK-PER-KiloW-HR
  - unit:CCY_DKK-PER-KiloW-HR
  - unit:CCY_GBP-PER-KiloW-HR
  - unit:CCY_HUF-PER-KiloW-HR
  - unit:CCY_NOK-PER-KiloW-HR
  - unit:CCY_PLN-PER-KiloW-HR
  - unit:CCY_RON-PER-KiloW-HR
  - unit:CCY_SEK-PER-KiloW-HR
  - unit:DEG_C-HR
  - unit:DEG_C-DAY
  - unit:DEG_F-DAY
  - unit:MilliBAR_A by [Toby Broom](https://github.com/Toby-Broom/)

### Changed

- Increased the severity of some validation constraints
- Added description to unit:DEG_F-DAY
- Changed qualifiers on unit:PIXEL to be uppercase, for consistency with current use
- Added qudt:Unit to hasUnit, hasDefinedUnit & hasAllowedUnit
- Added `qudt:hasQuantityKind quantitykind:BatteryCapacity` to `unit:A-HR`, `unit:A-SEC`, `unit:KiloA-HR` and `unit:MilliA-HR`
- conversion multipliers:
  a SHACL check was added to compare the conversion multipliers of derived units withthe conversion multiplier obtained from the factor units, failing the build if there is a discrepancy. This is a first step toward more stability with regard to conversion multipliers.

### Deprecated

- Deprecated unit:2PiRAD as a unit, replaced with unit:REV.
- Deprecated unit:IN-PER-2PiRAD, replaced with unit:IN-PER-REV.
- Deprecated the ambiguous unit:PIXEL, with seeAlso notes to unit:PIXEL_Area and unit:PIXEL_Count.

### Fixed

- Corrected symbol of `unit:BU_US` and `unit:GAL_US`, which both were `in³`.
- Fixed some units with rdfs:isDefinedBy lacking version, and added a constraint to check for this.
- Corrected conversion multipliers for unit:DEG_F-DAY

## [3.1.1] - 2025-04-23

### Added

- New Units
  - Counting units for some powers of ten; specifically TEN, HUNDRED, THOUSAND, MILLION, BILLION_Short and BILLION_Long.
    This allows some dimensionless counts to have more intuitive URIs, such as unit:PERCENT-PER-TEN-THOUSAND instead of
    unit:PERCENT-PER-DecaKiloCOUNT.
  - unit:COUNT was added as an exact match with unit:NUM. Both units have a quantity kind of Count (and others).
- New Coordinate Systems SHACL schema.
  - OWL schema for coordinate systems is work-in-progress.

### Changed

- Updated and fixed constraint for use of hasFactorUnit in OWL schema
- Added `qk:Emissivity` to `unit:PERCENT`
- Fixed mistakes on MicroW-PER-CentiM2-MicroM-SR, unit:W-PER-M2-MicroM, unit:W-PER-M2-MicroM-SR, J-PER-M2-SEC0pt5-K variously replacing qudit:unit to qudt:Unit, adding SI as applicable system, and removing @en-us tag from a plainTextDescription, changing conversionMultiplierSM to conversionMultiplierSN, and adding decimal point to xsd:double values, and avoiding using explicit datatypes on conversion factors.
- Upgraded the closed world validation constraint from sh:Info to sh:Violation. Errors will now cause the build to fail.
- Untangled unit:AWG and unit:CCY_AWG that had become combined in migration of currency into units graph
- Refactored and cleaned up applicable units for ElectricPower subtree, deprecating ComplexPower
- Updated the SHACL schema for datatypes to specify qudt:Concept as the ultimate parent. OWL schema for datatypes
  is work-in-progress.
- Refactored coordinate systems into a new SHACL schema for coordinate systems. OWL schema for coordinate systems
  is work-in-progress.
- Tweaked the definition and applicableUnits for quantitykind:StateOfCharge

### Deprecated

- Removed 8 invalid dimension vectors (without deprecation since they were invalid)
- Quantity kind ComplexPower, replaced by ElectricPower. ActivePower, ReactivePower and ApparentPower are still available, having skos:broader of ElectricPower.

## [3.1.0] - 2025-03-20

### Added

- New Units
  - `unit:MilliGM-PER-DeciM2` by [Matt Goldberg](https://github.com/mgberg)
- Factor Units by [Florian Kleedorfer](https://github.com/fkleedorfer):
  - During the build process, multiple SPARQL queries determine the 'factor units' that derived
    units are made up of. The factor units are associated with their derived units via `qudt:hasFactorUnit' triples.
  - Units that are 'scaled', ie. derived from another, non-derived unit with conversionMultiplier 1.0 by multiplication,
    are connected with that unit via `qudt:scalingOf`.
  - Wherever the connection cannot be determined from the units' localnames, the triples are explicitly listed
    in the file `src/build/inference/factorUnits/predefined-factors-and-scalings.ttl`, which are added to
    the units file (`target/dist/vocab/unit/VOCAB_QUDT-UNITS-ALL.ttl`) during the build
- a new BUILDING.md file
- Added the ContextualUnit class, to identify units that are common, but are really specializations of generic units.
- New Quantity Kinds: ServiceFactor, DutyCycle, WetBulbTemperature, DryBulbTemperature, supporting building management
- New Quantity Kind: State of Charge for batteries https://github.com/lazlop

### Changed

- Removed invalid qudt:iec61360Code values (most in the 'UAD' range) from about 40 units, most notably unit:M that was submitted as a bug.
- Cleaned out some remaining shape and restriction references to deprecated properties.

### Deprecated

- Replaced unit:PPTR_VOL with unit:PPT_VOL
- Deprecated 13 remaining units with non-uppercase URIs, replacing as appropriate.
- Replaced the volt ampere family of units having URIs with V-A, to have VA instead.
- Further, replaced ..V-A_Reactive with ...VAR.
- Deprecated all currency units in the currency graph, with redirection from cur:<currency> to unit:CCY_<currency> in the unit graph.
  The "class preamble" is there to avoid collisions of URI with non-currency units (Notably unit:CUP and unit:CCY_CUP).

## [3.0.0] - 2025-02-13

### Changed

- Replaced `2.1` with `$$QUDT_VERSION$$` in all graph URI references. This will result in URIs containing
  full semantic versions, such as 3.0.0, moving forward. Note that this is a breaking change, hence
  the transition to QUDT version 3. Versionless graph URIs are still dereferenceable on the web.

### Deprecated

- Removed all previously deprecated entities, to begin a new cycle of deprecation when needed.

### Fixed

- Corrected unit symbols containing some kind of conversion artifact, e.g. '<C2>'
- Fix dimension vector of unit:MicroMOL-PER-M2-SEC2
- Added the newly referred-to dimension vector to the dv vocabulary
- Corrected 456 unit symbols of derived unist by generating them based on their factors. Note: correcting
  derived unit symbols without correcting their factor units (e.g. `km/hr` -> `km/h` without `hr`->`h`)
  will not solve the problem in the long term. We are not yet automatically detecting and correcting
  incorrect derived unit symbols but it might happen in the future. If we started doing that, the factors
  would take precedence.
- Corrected the language tag `@en-us` to `@en-US`
- Corrected a small number of conversion multipliers

## [2.1.47] - 2025-01-28

### Added

- New SHACL Schema for Datatypes
  - Changed file name from `SCHEMA_QUDT-DATATYPE_NoOWL.ttl` to `SCHEMA_QUDT-DATATYPES_NoOWL.ttl`
  - Scalar datatypes unchanged
  - Structured datatypes have extensive changes
  - Future work:
    - completion of heterogeneous and multi-dimensional arrays and vectors
    - completion of structured datatypes such as records and tables
    - completion of SHACL rules for validation
- New folder `examples` under `src/`
- New graphs with examples of Quantities and Datatypes
  - `EXAMPLES_QUDT-DATATYPES.ttl` for valid examples
  - `EXAMPLES_QUDT-INVALID-DATATYPES.ttl` has invalid examples
- New classes and shapes added to SHACL QUDT Schema:
  - `DataItem` was added as a parent class for `Data`, supporting scalar values,
    and, with subtypes for structured values
- New QuantityKinds
  - `qk:OsmoticConcentration` by [Toby Broom](https://github.com/Toby-Broom/)
  - `qk:AmountOfCloudCover` by [Jeffrey Vervoort](https://github.com/Jeffrey-Vervoort-KNMI)
  - 7 new QuantityKinds for the [EDI](https://github.com/EDIorg/Units-WG) community, by [Margaret O'Brien](https://github.com/mobb)
- New Units
  - `unit:MegaTONNE-PER-YR` by [Jurek Müller](https://github.com/JurekMueller)
  - `unit:OSM` by [Toby Broom](https://github.com/Toby-Broom/)
  - `unit:MilliOSM-PER-KiloGM` by [Toby Broom](https://github.com/Toby-Broom/)
  - `unit:OKTA` by [Jeffrey Vervoort](https://github.com/Jeffrey-Vervoort-KNMI)
  - `unit:REV-PER-MIN-SEC` by [Vladimir Alexiev](https://github.com/VladimirAlexiev)
  - 31 new Units for the [EDI](https://github.com/EDIorg/Units-WG) community, by [Margaret O'Brien](https://github.com/mobb)
- New Dimension Vectors
  - 5 new Dimension Vectors for the [EDI](https://github.com/EDIorg/Units-WG) community, by [Margaret O'Brien](https://github.com/mobb)
- New QA Tests
  - Added SHACL shapes for checking content under `src/` only
- New Inferences
  - Added a SHACL rule to generate inverse triples for symmetric relations (such as qudt:exactMatch)

### Changed

- Migrated constructs for datatypes to:
  - new SHACL Schema for Datatypes
    - Updated OWL Schema is work-in-progress
  - existing VOCAB for Datatypes
- Changes to the SHACL QUDT schema:
  - Added a `value` constraint to the property shape `qudt:Quantifiable-value` to allow a value
    to be a `qudt:EnumeratedValue`, and to allow a list of values.
  - `qudt:informativeReference` can now refer to instances of `qudt:Citation` as well as `xsd:anyURI`
- Removed the vaem:revision triples that were causing retention of v2.1 strings in the URIs
- `qudt:informativeReference` triples added/replaced by a link to IEC CDD generated based on `qudt:iec61360Code` triples by [Vladimir Alexiev](https://github.com/VladimirAlexiev)

### Fixed

- Corrected numerous issues in the datatypes SHACL schema and the QUDT SHACL schema
- Corrected the `qudt:ucumCode` of `unit:TeraW-HR-PER-YR` to "TW.h/a" by [Jurek Müller](https://github.com/JurekMueller)
- Fixed non-working informativeReference links in units vocabulary [Phil Blackwood](https://github.com/philblackwood)
- Added some missing rdfs:isDefinedBy triples

## [2.1.46] - 2024-12-09

### Added

- QUDT Schema
  - Add the `qudt:altSymbol` property to support using multiple symbols with a unit/quantitykind alongside
    the primary one, which is`qudt:symbol`
- New QuantityKinds
  - `qk:AmountOfSubstanceIonConcentration` as a narrower kind of `qk:Concentration`.
  - `qk:CoefficientOfPerformance` by [lazlop](https://github.com/lazlop)
  - `qk:CompoundPlaneAngle`
  - `qk:CountRate` (units: `unit:NUM-PER-SEC`, `unit:NUM-PER-HR`, `unit:NUM-PER-YR`)
  - `qk:CurrentOfTheAmountOfSubstance` (replaces`qk:CurrentOfTheAmountOfSubtance`)
  - `qk:RotationalFrequency` (units: `unit:Hz`, `unit:REV-PER-MIN`, `unit:REV-PER-HR`, `unit:REV-PER-SEC`)
  - `qk:VaporPermeability` (unit: `unit:KiloGM-PER-PA-SEC-M`)
  - `qk:VaporPermeance` (for what used to be `qk:VaporPermeability`, see 'Changed')
- New Units
  - `unit:CYC-PER-SEC`
  - `unit:KiloLM`
  - `unit:CD-PER-KiloLM`
  - `unit:CI` (replaces `unit:Ci`)
  - `unit:FLIGHT` (replaces `unit:Flight`)
- Other Additions
  - Add "mph" as `qudt:altSymbol` of `unit:M-PER-HR` from [Toby Broom](https://github.com/Toby-Broom/)
  - Add "kph" as `qudt:altSymbol` of `unit:KiloM-PER-HR` from [Toby Broom](https://github.com/Toby-Broom/)
  - SHACL validation of SHACL shapes by [Dimitris Kontokostas](https://github.com/jimkont)

### Changed

- Enforce at most a single qudt:symbol for all instances.
- Delete spurious qudt:symbol values in a number of quantity kinds
- Correct the conversion offset for MilliDEG_C
- Rename `qk:VaporPermeability` to `qk:VaporPermeance` and change all unit associations accordingly.
- Unify `PER-X` symbols to the 15:1 majority pattern, `"/x"` where `"1/x"` is used
- Unify `NUM-PER-X` symbols to always represent `NUM` as `#` (as has already been used in `unit:NUM`)
- Remove `qk:NumberDensity` from `unit:PER-M3`
- Make `qk:RotationalFrequency` exactMatch of `qk:RotationalVelocity`, remove broader qk
- Make `qk:AngularFrequency` exactMatch of `qk:AngularVelocity`, remove broader qk

### Deprecated

- `unit:Ci` (replaced by: `unit:CI`)
- `unit:Flight` (replaced by: `unit:FLIGHT`)
- `qk:CurrentOfTheAmountOfSubtance` (replaced by `qk:CurrentOfTheAmountOfSubstance`)
- `unit:CFU` (replaced by: `unit:NUM`) - The CFU (colony forming unit) is a context-dependent unit that should
  be part of an ontology with narrower scope than QUDT.

## [2.1.45] - 2024-11-15

### Changed

- Changed the name of the `collections` folder to `validation`.
- Remove all version suffixes from all source files, i.e., `-v2.1.ttl` becomes `.ttl`

### Fixed

- Added `skos:broader` relations to a number of quantity kinds that had none. Note that it is ok for a
  quantity kind to have no broader quantity kind, but these were missing.
- Changed the erroneously used 'qudt:hasDimensionVector' property in `vocab/types/VOCAB_QUDT_DATATYPES-v2.1.ttl`
  file with with a new property qudt:dimensions that denotes the dimensions of a matrix.
- Introduced a maven based build process to automate the manual tasks required for merging PRs and making releases.
  This change does not affect the content of the ontologies.
- Replaced (hopefully) all occurrences of `hr` as a symbol for `unit:HR` with `h`.
- Add `unit:NUM-PER-MilliL`

## 2.1.44 - 2024-10-27

### Fixed

- A new quantity kind, ElevationRelativeToNAP, has been added to support the Amsterdam Ordnance
  System (thanks @RiX012).
- **Big housecleaning month!** Many of the unused graphs that have been lying around the repository
  have been moved to a behind-the-scenes repository, including references to some of the unused
  concepts in our active graphs. If you have been quietly using them yourself in your own work and
  would like us to restore any of them, please let us know in a new Issue. Otherwise, we now have a
  more streamlined repository while retaining all the functionality you have been depending on.
- The qudt:currencyNumber relation now points to a string with the currency code, rather than an
  integer. This makes sense because it is not used for computation - it is a code in the true
  sense. (Thanks for this fix, @fkleedorfer)
- A number of units now point to quantitykind:MassConcentration in addition to MassDensity and Density.
  (thanks @J-meirlaen). (MassDensity and Density are already declared as qudt:exactMatch.
  MassConcentration will be included in these declarations in the future.)

[Unreleased]: https://github.com/qudt/qudt-public-repo/compare/v3.4.0...HEAD
[3.4.0]: https://github.com/qudt/qudt-public-repo/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/qudt/qudt-public-repo/compare/v3.2.1...v3.3.0
[3.2.1]: https://github.com/qudt/qudt-public-repo/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/qudt/qudt-public-repo/compare/v3.1.11...v3.2.0
[3.1.11]: https://github.com/qudt/qudt-public-repo/compare/v3.1.10...v3.1.11
[3.1.10]: https://github.com/qudt/qudt-public-repo/compare/v3.1.9...v3.1.10
[3.1.9]: https://github.com/qudt/qudt-public-repo/compare/v3.1.8...v3.1.9
[3.1.8]: https://github.com/qudt/qudt-public-repo/compare/v3.1.7...v3.1.8
[3.1.7]: https://github.com/qudt/qudt-public-repo/compare/v3.1.6...v3.1.7
[3.1.6]: https://github.com/qudt/qudt-public-repo/compare/v3.1.5...v3.1.6
[3.1.5]: https://github.com/qudt/qudt-public-repo/compare/v3.1.4...v3.1.5
[3.1.4]: https://github.com/qudt/qudt-public-repo/compare/v3.1.3...v3.1.4
[3.1.3]: https://github.com/qudt/qudt-public-repo/compare/v3.1.2...v3.1.3
[3.1.2]: https://github.com/qudt/qudt-public-repo/compare/v3.1.1...v3.1.2
[3.1.1]: https://github.com/qudt/qudt-public-repo/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/qudt/qudt-public-repo/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/qudt/qudt-public-repo/compare/v2.1.47...v3.0.0
[2.1.47]: https://github.com/qudt/qudt-public-repo/compare/v2.1.46...v2.1.47
[2.1.46]: https://github.com/qudt/qudt-public-repo/compare/v2.1.45...v2.1.46
[2.1.45]: https://github.com/qudt/qudt-public-repo/compare/v2.1.44...v2.1.45

