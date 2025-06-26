# Highlights

With this Release we have made our treatment of conversion multipliers more consistent, by:

1. Requiring all units to have a conversion multiplier, even if it is zero. A value of zero is for units with nonlinear or undefined multipliers.

2. Computing conversion multipliers automatically for compound units, based on its components (aka factors).

3. Limiting all conversion multipliers to at most 34 significant digits. Units with exact values for conversion multipliers will typically have fewer digits.
We plan to treat uncertainty values for conversion multipliers in an upcoming Release.

