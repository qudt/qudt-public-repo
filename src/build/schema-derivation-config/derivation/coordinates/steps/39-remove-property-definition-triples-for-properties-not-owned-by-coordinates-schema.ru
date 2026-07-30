# owl-coordinates-derive step 39
# Message: Remove property definition triples for properties not owned by the coordinates schema

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sh: <http://www.w3.org/ns/shacl#>

DELETE {
    GRAPH <work:coordinate:derived> {
        ?p ?pred ?obj .
    }
}
WHERE {
    GRAPH <work:coordinate:derived> {
        ?p ?pred ?obj .
        FILTER(isIRI(?p))
        FILTER(STRSTARTS(STR(?p), "http://qudt.org/schema/qudt/"))
    }
    FILTER NOT EXISTS {
        GRAPH <work:coordinate:shacl-source> {
            ?p a rdf:Property .
        }
    }
    FILTER EXISTS {
        {
            GRAPH <work:coordinate:shacl-source> {
                ?ps a sh:PropertyShape ;
                    sh:path ?p .
            }
        } UNION {
            GRAPH <work:coordinate:derived> {
                {
                    ?p a ?propertyType .
                    FILTER(
                        ?propertyType IN (
                            rdf:Property,
                            owl:ObjectProperty,
                            owl:DatatypeProperty,
                            owl:AnnotationProperty,
                            owl:FunctionalProperty,
                            owl:InverseFunctionalProperty,
                            owl:SymmetricProperty,
                            owl:AsymmetricProperty,
                            owl:TransitiveProperty,
                            owl:ReflexiveProperty,
                            owl:IrreflexiveProperty
                        )
                    )
                } UNION {
                    ?p rdfs:range ?anyRange .
                } UNION {
                    ?p rdfs:domain ?anyDomain .
                } UNION {
                    ?p rdfs:subPropertyOf ?anySuperProperty .
                } UNION {
                    ?p owl:inverseOf ?anyInverseProperty .
                }
            }
        }
    }
}
