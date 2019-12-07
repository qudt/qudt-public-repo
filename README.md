QUDT - Quantities, Units, Dimensions and dataTypes - public repository
======================================================================

Overview
--------

This QUDT<sup>1</sup> public repository contains the schema and vocabulary source files for the graphs making up the QUDT collection. It is probably the most convenient way for software developers to include the QUDT ontoligies in their work. However, for those who prefer the linked data world, each QUDT graph is also available in both a versioned and an unversioned form on the <a href="http://qudt.org">qudt.org</a> website.

Our current plan is to deliver this material in even more powerful ways. The website will eventually host an engine supporting SPARQL and GraphQL queries, and fully resolvable URIs at the individual class and instance level will be available online.

We encourage you to get involved. If you have particular needs or see errors, please create an Issue and/or make changes or additions yourself (please see our <a href="https://github.com/qudt/qudt-public-repo/wiki">   Wiki</a> for more detailed instructions.)

Status
------

Release 2.1 of QUDT is being published in increments. The first increment is a release of the schemas and base vocabularies for units, quantity kinds and dimension vectors. Please check this repository or the <a href="http://qudt.org">qudt.org</a> website for the latest updates.

Content (as of November 4, 2019)
-------

<h3>Schemas</h3>

<table>
<tr>
 <th>Base URIs</th>
 <th>Prefix</th>
 <th>Release Date</th>
 <th>Dereferenceable URI</th>
</tr>
<tr>
<td>http://qudt.org/2.1/schema/qudt</td>
<td>qudt</td>
<td>October 4, 2019</td>
<td>http://qudt.org/schema/qudt</td>
</tr>
<tr>
<td>http://qudt.org/2.0/schema/qudt/science<sup>2</sup></td>
<td></td>
<td>October 4, 2019</td>
<td>http://qudt.org/schema/qudt/science</td>
</tr>
<tr>
<td>http://qudt.org/2.1/vocab/discipline<sup>2</sup></td>
<td></td>
<td>October 4, 2019</td>
<td>http://qudt.org/vocab/discipline</td>
</tr>
</table>

<h3>Vocabularies</h3>

<h4>Units, Quantity Kinds, Dimension Vectors</h4>

<table>
<tr>
 <th>Base URIs</th>
 <th>Prefix</th>
 <th>Release Date</th>
 <th>Dereferenceable URI</th>
</tr>
<tr>
<td>http://qudt.org/2.1/vocab/unit</td>
<td>unit</td>
<td>October 11, 2019</td>
<td>http://qudt.org/vocab/unit</td>
</tr>
<tr>
<td>http://qudt.org/2.1/vocab/quantitykind</td>
<td>quantitykind</td>
<td>October 4, 2019</td>
<td>http://qudt.org/vocab/quantitykind</td>
</tr>
<tr>
<td>http://qudt.org/2.1/vocab/dimensionvector</td>
<td>dimensionvector</td>
<td>October 4, 2019</td>
<td>http://qudt.org/vocab/dimensionvector</td>
</tr>
<tr>
<td>http://qudt.org/2.1/vocab/discipline</td>
<td>discipline</td>
<td>October 4, 2019</td>
<td>http://qudt.org/vocab/discipline</td>
</tr>
</table>



<hr/>
<p style="font-size=xx-small;"><sup>1</sup> QUDT.org is a 501(c)(3) not-for-profit organization founded to provide semantic specifications for units of measure, quantity kind, dimensions and data types.   QUDT is an advocate for the development and implementation of standards to quantify data expressed in RDF and JSON.   Our mission is to improve interoperability of data and the specification of information structures through industry standards for Units of Measure, Quantity Kinds, Dimensions and Data Types.

QUDT.org is a member of the World Wide Web Consortium (W3C)

<p style="font-size=xx-small;"><sup>2</sup> The science and discipline schemas may get folded into the main qudt schema to simplify things.

<hr/>


Last updated by: Steve Ray (steve.ray@qudt.org)

Last updated: November 4, 2019
