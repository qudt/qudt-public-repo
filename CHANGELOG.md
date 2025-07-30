# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project is in the process of adopting [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `unit:NCM` to support the Dutch hydrocarbons sector
- `unit:NCM_1ATM_0DEG_C_NL` which is quantified further by `unit:NCM`
- `unit:SCM_1ATM_0DEG_C` which is a contextual unit of `unit:SCM`
- `unit:SCM_1ATM_15DEG_C_ISO` which is a contextual unit of `unit:SCM`
- `unit:SCM_1ATM_15DEG_C_NL` which is a Dutch hydrocarbons sector quantification of `unit:SCM`
- Explicitly declared all the xsd datatypes to be instances of rdfs:Datatype in the SHACL datatypes schema file

### Changed

### Deprecated

- Removed schema/extensions/FUNCTIONS_QUDT.spin.ttl that is no longer used in the calculation of applicable units
- Removed src/build/all-in-one/all-in-one-ontology.ttl that is no longer used in creating the all-in-one files

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

## [3.1.3] - 2025-06-26

### Added

- Added an updated intro slide deck in the doc folder
- New Units
  - `unit:CCY_CHF-PER-HA`

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

[Unreleased]: https://github.com/qudt/qudt-public-repo/compare/v3.1.4...HEAD
[3.1.4]: https://github.com/qudt/qudt-public-repo/compare/v3.1.3...v3.1.4
[3.1.3]: https://github.com/qudt/qudt-public-repo/compare/v3.1.2...v3.1.3
[3.1.2]: https://github.com/qudt/qudt-public-repo/compare/v3.1.1...v3.1.2
[3.1.1]: https://github.com/qudt/qudt-public-repo/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/qudt/qudt-public-repo/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/qudt/qudt-public-repo/compare/v2.1.47...v3.0.0
[2.1.47]: https://github.com/qudt/qudt-public-repo/compare/v2.1.46...v2.1.47
[2.1.46]: https://github.com/qudt/qudt-public-repo/compare/v2.1.45...v2.1.46
[2.1.45]: https://github.com/qudt/qudt-public-repo/compare/v2.1.44...v2.1.45

