This release introduces support for **community extensions**: optional, domain-specific sets of vocabularies and even schema changes that can be included in the QUDT build alongside the core vocabulary. Extensions are maintained in `src/main/rdf/community/extensions/{id}/` and activated at build time by supplying one or more extension IDs:

```
mvn -Dqudt.supported.extensions=id1,id2 install
```

Extensions receive the same validation, inference, and serialisation treatment as core vocabulary. This capability is **fully backward compatible**: users who continue to use the default 'mvn install' will see no change.

As part of this release, 31 quantity kinds that are highly specific to the field of propulsion have been migrated from the core vocabulary into an extension called **`propulsion`**. Users who currently reference those quantity kinds and wish to continue doing so should include `-Dqudt.supported.extensions=propulsion` in their build invocation. Users who do not work in the propulsion domain and did not use those quantity kinds need take no action.

A second major addition is the concept of an ExtendedDimensionVector that disambiguates angular and count-based quantity kind and unit dimensions beyond what is possible through the seven base SI dimensions. This is discussed in PR #1460 [here](https://github.com/qudt/qudt-public-repo/pull/1460).