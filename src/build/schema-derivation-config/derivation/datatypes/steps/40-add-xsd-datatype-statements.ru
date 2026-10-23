# owl-datatypes-derive step 40
# Message: Add rdfs:Datatype declarations for the XSD datatypes

# Declares, in the derived OWL datatype schema, every XSD datatype that the SHACL datatype schema
# uses, whatever the earlier steps keep. The SHACL schema declares the same datatypes, because
# qudt:ScalarDatatype-rdfsDatatype requires sh:class rdfs:Datatype; keep the two lists in step,
# and extend both whenever the schema starts using another XSD datatype.

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

INSERT DATA {
    GRAPH <work:datatype:derived> {
        xsd:anySimpleType a rdfs:Datatype .
        xsd:anyURI a rdfs:Datatype .
        xsd:base64Binary a rdfs:Datatype .
        xsd:boolean a rdfs:Datatype .
        xsd:byte a rdfs:Datatype .
        xsd:date a rdfs:Datatype .
        xsd:dateTime a rdfs:Datatype .
        xsd:dateTimeStamp a rdfs:Datatype .
        xsd:dayTimeDuration a rdfs:Datatype .
        xsd:decimal a rdfs:Datatype .
        xsd:double a rdfs:Datatype .
        xsd:duration a rdfs:Datatype .
        xsd:float a rdfs:Datatype .
        xsd:gDay a rdfs:Datatype .
        xsd:gMonth a rdfs:Datatype .
        xsd:gMonthDay a rdfs:Datatype .
        xsd:gYear a rdfs:Datatype .
        xsd:gYearMonth a rdfs:Datatype .
        xsd:hexBinary a rdfs:Datatype .
        xsd:int a rdfs:Datatype .
        xsd:integer a rdfs:Datatype .
        xsd:long a rdfs:Datatype .
        xsd:negativeInteger a rdfs:Datatype .
        xsd:nonNegativeInteger a rdfs:Datatype .
        xsd:nonPositiveInteger a rdfs:Datatype .
        xsd:NOTATION a rdfs:Datatype .
        xsd:positiveInteger a rdfs:Datatype .
        xsd:QName a rdfs:Datatype .
        xsd:short a rdfs:Datatype .
        xsd:string a rdfs:Datatype .
        xsd:time a rdfs:Datatype .
        xsd:unsignedByte a rdfs:Datatype .
        xsd:unsignedInt a rdfs:Datatype .
        xsd:unsignedLong a rdfs:Datatype .
        xsd:unsignedShort a rdfs:Datatype .
        xsd:yearMonthDuration a rdfs:Datatype .
    }
}
