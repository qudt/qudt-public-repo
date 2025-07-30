QUDT - ***Q***uantities, ***U***nits, ***D***imensions and Data***T***ypes
==========================================================================

## Quick-Start Guide

There are three ways to bring the QUDT ontology into your environment.
1. Download the latest GitHub Release [here](https://github.com/qudt/qudt-public-repo/releases) and load one of: 
    -    QUDT-all-in-one-SHACL.ttl
    -    QUDT-all-in-one-OWL.ttl

    depending on whether you are using OWL or SHACL as your modeling approach.

2. Use the resolved graph and instance URIs, one of:
    - http://qudt.org/shacl/qudt-all
    - http://qudt.org/qudt-all
3. Use GitHub fork to get the sources and build them using the instructions [here](https://github.com/qudt/qudt-public-repo/wiki/Installing-QUDT-for-Contributors).

Overview
--------

This QUDT<sup>1</sup> public repository contains the schema and vocabulary source files for the graphs making up the QUDT collection. It is probably the most convenient way for software developers to include the QUDT ontologies in their work, and is the most up-to-date. However, for those who prefer the linked data world, each QUDT graph is also available in both a versioned and an unversioned form on the <a href="http://qudt.org">qudt.org</a> website.

DOI reference for citations: https://doi.org/10.25504/FAIRsharing.d3pqw7

Here is the core design pattern of the QUDT ontology:

![QUDT Triad Pattern](https://github.com/qudt/qudt-public-repo/wiki/Quantity_Triad_Pattern.png)

Our current plan is to deliver this material in even more powerful ways. The [website](https://qudt.org) now hosts a SPARQL endpoint, as well as an engine supporting SPARQL and GraphQL queries. Fully resolvable URIs at the graph and instance level are available online. Eventually we will also support resolvable class URIs as well. We are also creating a series of <a href="https://github.com/qudt/qudt-public-repo/wiki/User-Guide-for-QUDT"> User Guides</a> on the wiki for this repository.

We encourage you to get involved. If you have particular needs or see errors, please create an Issue and/or make changes or additions yourself (please see our <a href="https://github.com/qudt/qudt-public-repo/wiki">   Wiki</a> for more detailed instructions, and specifically <a href="https://github.com/qudt/qudt-public-repo/wiki/Unit-Vocabulary-Submission-Guidelines"> the Units Submission Guide</a> if you would like to suggest additional units.) We are a volunteer-staffed effort, but we do have infrastructural expenses. Please consider making a [DONATION](https://github.com/sponsors/qudt).

Installation instructions
-------------------------

[Installing QUDT for Consumers](https://github.com/qudt/qudt-public-repo/wiki/Installing-QUDT-for-Consumers)

[Installing QUDT for Contributors](https://github.com/qudt/qudt-public-repo/wiki/Installing-QUDT-for-Contributors)


SHACL Validation for QUDT Users versus QUDT Developers
---------------------------------------------------

QUDT SHACL for users is supported by a set of validation rules that check for references to deprecated instances or properties and recommend the updated instance or property. 

QUDT SHACL for contributors (accessed by using the individual graphs rather than QUDT-all-in-one-SHACL.ttl in the Release or fork) is supported by a much larger set of validation rules that check the integrity of the QUDT ontologies themselves.

Protege Users
-------------

The QUDT ontologies have been tested to load without error in Protege 5.6.4.

To load QUDT into Protege, choose "Open from URI" from the file menu, and enter http://qudt.org/qudt-all 

This will load the latest version of the distribution file containing the OWL schema and all vocabularies for QUDT. You can also load a specific version by including the semantic version number, such as http://qudt.org/3.1.4/qudt-all

Ontology libraries
------------------

Please note that various libraries exhibit different behaviors when importing the QUDT ontology, see this [discussion](https://github.com/qudt/qudt-public-repo/issues/842#issuecomment-1879114604).

Status
------

Please see the documentation supporting each Release. There are also [New Features and Releases](https://github.com/qudt/qudt-public-repo/discussions/315) discussed in the Discussions section.

<hr/>
<p style="font-size:xx-small;"><sup>1</sup> QUDT.org is a 501(c)(3) not-for-profit organization founded to provide semantic specifications for units of measure, quantity kind, dimensions and data types.   QUDT is an advocate for the development and implementation of standards to quantify data expressed in RDF and JSON.   Our mission is to improve interoperability of data and the specification of information structures through industry standards for Units of Measure, Quantity Kinds, Dimensions and Data Types. <a href="https://github.com/sponsors/qudt">Sponsorships</a> are greatly appreciated!

QUDT.org is a member of the World Wide Web Consortium (W3C)

<hr/>

Last updated by: Steve Ray (steve.ray@qudt.org)

Last updated: July 30, 2025
