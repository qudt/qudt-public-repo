# YOUR OPINION NEEDED!

## First question

We are trying to get a better feel for how people are using QUDT. Do you...

1. Use QUDT with the OWL schema
2. Use QUDT with the SHACL schema
3. Use just the QUDT vocabularies as persistent, unique identifiers for units, etc.
4. Use QUDT in some other way

Please answer our brief poll [here](https://github.com/qudt/qudt-public-repo/discussions/1329)

## Second question

For the OWL users, we are considering simplifying the OWL schema for several reasons.

1. We perform all of our development and maintenance work using the SHACL schemas
2. We have been told that few users are actually trying to do OWL reasoning on QUDT
3. The OWL axioms concerning object properties is a maintenance time sink

Before we take any action, we need to hear from you! We are considering any of the following options:

1. Remove all axioms from OWL schema, such as restriction classes beyond simple cardinality constraints, possibly by adopting a version of RDFS-plus. Because there are several variants of RDFS-plus in use, we could consider a common subset of RDFS-plus being implemented. This solution still leaves the question of how to handle domain and range statements in the case of class unions.
2. Leave things as they are, recognizing that errors occasionally creep in (e.g. try loading it in Protege right now - there are 3 errors)

The vocabularies are all just RDFS, so they remain untouched by this change.

Please give us feedback by entering a comment on our GitHub Discussions page [here](https://github.com/qudt/qudt-public-repo/discussions/1330). We will wait for your feedback until December 15, 2025 before deciding on our course of action.

