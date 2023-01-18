QUDT - Quantities, Units, Dimensions and dataTypes - public repository
======================================================================

Overview
--------

This QUDT<sup>1</sup> public repository contains the schema and vocabulary source files for the graphs making up the QUDT collection. It is probably the most convenient way for software developers to include the QUDT ontologies in their work, and is the most up-to-date. However, for those who prefer the linked data world, each QUDT graph is also available in both a versioned and an unversioned form on the <a href="http://qudt.org">qudt.org</a> website.

DOI reference for citations: https://doi.org/10.25504/FAIRsharing.d3pqw7


Here is the core design pattern of the QUDT ontology:

![QUDT Triad Pattern](https://github.com/qudt/qudt-public-repo/wiki/Quantity_Triad_Pattern.png)

Here is the imports closure graph, so you can see which files you need to explicitly import, depending on your application:

![image](https://user-images.githubusercontent.com/1130189/213201003-c41c911b-c1b1-479f-a271-f5f19569dda1.png)

Note that the default schema is expressed in SHACL. You can change this to use the OWL schema if you prefer, as documented [here](https://github.com/qudt/qudt-public-repo/wiki/Advanced-User-Guide#5-using-the-shacl-schema-instead-of-the-owl-schema).

Our current plan is to deliver this material in even more powerful ways. The website now hosts an engine supporting SPARQL and GraphQL queries. Fully resolvable URIs at the graph and instance level are available online. Eventually we will also support resolvable class URIs as well. We are also creating a series of <a href="https://github.com/qudt/qudt-public-repo/wiki/User-Guide-for-QUDT"> User Guides</a> on the wiki for this repository.

We encourage you to get involved. If you have particular needs or see errors, please create an Issue and/or make changes or additions yourself (please see our <a href="https://github.com/qudt/qudt-public-repo/wiki">   Wiki</a> for more detailed instructions, and specifically <a href="https://github.com/qudt/qudt-public-repo/wiki/Unit-Vocabulary-Submission-Guidelines"> the Units Submission Guide</a> if you would like to suggest additional units.) We are a volunteer-staffed effort, but we do have infrastructural expenses. Please consider making a [DONATION](https://github.com/sponsors/qudt).

Installation / Configuration instructions
-----------------------------------------

The QUDT ontology is provided in two forms: OWL and SHACL. By default, the vocabularies are configured to use the OWL schema. To configure it to use the SHACL schema instead, just make the following single change in the file schema/shacl/SHEMA-FACADE_QUDT-v2.1.\<release-number\>.ttl. You can see in the imports closure diagram above how all the vocabularies import this single "facade" file to make it easy to switch the ontology.

```
Change this line:
  owl:imports <http://qudt.org/2.1/schema/qudt> ;  
To:
  owl:imports <http://qudt.org/2.1/schema/shacl/qudt> ;
```

If you are using the tools from TopQuadrant, you should also change the comment line at the top of the same file:

```
Change this line:
# imports: http://qudt.org/2.1/schema/qudt
To:
# imports: http://qudt.org/2.1/schema/shacl/qudt
```

Status
------

Please see the [New Features and Releases](https://github.com/qudt/qudt-public-repo/discussions/315) topic in the Discussions section for status updates.



<hr/>
<p style="font-size=xx-small;"><sup>1</sup> QUDT.org is a 501(c)(3) not-for-profit organization founded to provide semantic specifications for units of measure, quantity kind, dimensions and data types.   QUDT is an advocate for the development and implementation of standards to quantify data expressed in RDF and JSON.   Our mission is to improve interoperability of data and the specification of information structures through industry standards for Units of Measure, Quantity Kinds, Dimensions and Data Types. <a href="https://github.com/sponsors/qudt">Sponsorships</a> are greatly appreciated!

QUDT.org is a member of the World Wide Web Consortium (W3C)



<hr/>


Last updated by: Steve Ray (steve.ray@qudt.org)

Last updated: August 4, 2022
