# YOUR OPINION NEEDED!

We are considering simplifying the OWL schema for QUDT for several reasons.

1. We perform all of our development and maintenance work using the SHACL schemas
1. We have been told that few users are actually trying to do OWL reasoning on QUDT
2. The OWL axioms concerning between annotation properties and object properties is a maintenance timesink

Before we take any action, we need to hear from you! We are considering any of the following options:

1. Trim the OWL schema to just a "classonomy" composed of the class definitions and the rdfs:subClassOf relations among them.
2. Trim the OWL schema to the class definitions and the object property relations
3. Leave things as is, recognizing that errors occasionally creep in (e.g. try loading it in Protege right now - there are 3 errors)

The vocabularies are all just RDFS, so they remain untouched by this change.

Please give us feedback by entering a comment on our GitHub Discussions page [here](this will be a URL). We will wait for your feedback until December 15, 2025 before deciding on our course of action.

