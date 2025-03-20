## Please note!

This new Release adds some significant new functionality by generating 'factor units' for most units. This will be a new relation that could help when defining profiles (still coming). For this reason the semantic version is incremented from 3.0.0 to 3.1.0.

We are also introducing the idea of a ContextualUnit that allows users to introduce domain-specific units (recall our discussion about CFU, Colony Forming Units, suggested by @Toby-Broom and @dr-shorthair). We will depend on the introduction of profiles to keep these additions from overwhelming the vocabularies. Such ContextualUnits will be related to more generic versions of units using skos:broader.

Finally, we are continuing to refine the automation of our build process to minimize human error, while hopefully not making the contribution process too complicated. Feedback is always welcome.

