# owl-schema-derive step 67
# Message: Normalize known mixed-use properties to rdf:Property

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX qudt: <http://qudt.org/schema/qudt/>

DELETE {
    GRAPH <work:schema:derived> {
        ?p a ?oldType .
        ?p rdfs:range ?range .
    }
}
INSERT {
    GRAPH <work:schema:derived> {
        ?p a rdf:Property .
    }
}
WHERE {
    VALUES ?p {
        qudt:value
    }
    GRAPH <work:schema:derived> {
        OPTIONAL {
            ?p a ?oldType .
            FILTER(
                ?oldType IN (
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
        }
        OPTIONAL { ?p rdfs:range ?range . }
    }
}
