## Improved support for commensurability of units

- `skos:broader` now means precisely one thing: *"X is a specialisation of Y, and any quantity of kind X can be compared and converted with one of kind Y."* Nothing else.
- Quantity kinds that share a dimension (e.g. both measured in s⁻¹) but are genuinely *not* interchangeable — such as frequency (Hz) and radioactive activity (Bq) — are placed in **separate, unconnected skos:broader hierarchies (towers)**. A commensurability check will correctly report them as incompatible.
- Abstract grouping nodes such as "Dimensionless" are no longer used as hierarchy parents. Instead, each distinct dimensionless quantity kind (strain, efficiency, refractive index, information content, …) is its own root. Browsing by dimension is the recommended way to discover related quantity kinds.

**What does this mean for you?**

- If you use QUDT to **validate unit compatibility** in your application — checking that the units on both sides of an addition or comparison are comparable — the results will be more precise and less likely to give a false "yes."
- If you write SPARQL queries that traverse the `skos:broader` hierarchy to find related units or quantity kinds, those queries now return tighter, semantically correct results.
- If your code simply looks up units and their conversion factors, nothing changes for you. All conversion multipliers and dimension vectors are unaffected.

