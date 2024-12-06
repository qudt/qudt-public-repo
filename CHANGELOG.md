# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project is in the process of adopting [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add the qudt:altSymbol relation
- Add "mph" and "kph" as `qudt:altSymbol` 
- Add quantitykind `qk:CoefficientOfPerformance`
- Add "mph" and "kph" as `qudt:altSymbol`
- Add quantitykinds `qk:CompoundPlaneAngle`, `qk:CountRate` and `qk:RotationalFrequency`
- Add quantitykind `qk:CountRate` to `unit:NUM-PER-SEC`, `unit:NUM-PER-HR`, `unit:NUM-PER-YR`
- Add quantitykind  `qk:RotationalFrequency` to `unit:Hz`, `unit:REV-PER-MIN`, `unit:REV-PER-HR`, `unit:REV-PER-SEC`
- Add units `unit:CYC-PER-SEC`, `unit:KiloLM`, `unit:CD-PER-KiloLM`
- Add `qk:VaporPermeability` to `unit:KiloGM-PER-PA-SEC-M`
- Add quantitykind `qk:VaporPermeance`


### Changed

- Enforce at most a single qudt:symbol for all instances.
- Delete spurious qudt:symbol values in a number of quantity kinds
- Correct the conversion offset for MilliDEG_C
- Rename `qk:VaporPermeability` to `qk:VaporPermeance` and change all unit associations accordingly.
- Unify `PER-X` symbols to the 15:1 majority pattern, `"/x"` where `"1/x"` is used
- Unify `NUM-PER-X` symbols to always represent `NUM` as `#` (as has already been used in `unit:NUM`) 
- Remove `qk:NumberDensity` from `unit:PER-M3`

## Fixed

- Rename incorrectly named Unit `unit:Ci` to `unit:CI`
- Rename incorrectly named Unit `unit:Flight` to `unit:FLIGHT`
- Rename incorrectly named quantitykind `qk:CurrentOfTheAmountOfSubtance` to `qk:CurrentOfTheAmountOfSubstance`

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
  (thanks @J-meirlaen).  (MassDensity and Density are already declared as qudt:exactMatch.
  MassConcentration will be included in these declarations in the future.)

[Unreleased]: https://github.com/qudt/qudt-public-repo/compare/v2.1.45...HEAD
[2.1.45]: https://github.com/qudt/qudt-public-repo/compare/v2.1.44...v2.1.45
