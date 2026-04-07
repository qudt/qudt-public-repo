# owl-schema-derive step 03b
# Message: Derive owl:oneOf from SHACL enum class patterns

PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX sh: <http://www.w3.org/ns/shacl#>

INSERT {
    GRAPH <work:schema:derived> {
        ?class owl:oneOf ?enumList .
    }
}
WHERE {
    GRAPH <work:schema:derived> {
        ?class a owl:Class .
        FILTER(isIRI(?class))
        {
            ?class sh:in ?enumList .
        } UNION {
            FILTER NOT EXISTS { ?class sh:in ?anyDirectEnumList . }
            ?class sh:property ?ps .
            ?ps a sh:PropertyShape ;
                sh:in ?enumList ;
                sh:path [ sh:inversePath rdf:type ] .
        }
        FILTER NOT EXISTS {
            ?class owl:oneOf ?existingEnumList .
        }
    }
}
