# owl-schema-derive step 68
# Message: Final cleanup: remove cardinality restrictions on properties left untyped after mixed-use property normalization

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

DELETE {
    GRAPH <work:schema:derived> {
        ?c rdfs:subClassOf ?r .
        ?r ?rp ?ro .
    }
}
WHERE {
    GRAPH <work:schema:derived> {
        ?c rdfs:subClassOf ?r .
        ?r a owl:Restriction ;
           owl:onProperty ?p ;
           ?rp ?ro .
        FILTER(
            EXISTS { ?r owl:minCardinality ?min . }
            || EXISTS { ?r owl:maxCardinality ?max . }
            || EXISTS { ?r owl:cardinality ?card . }
        )
        FILTER NOT EXISTS { ?p a owl:ObjectProperty . }
        FILTER NOT EXISTS { ?p a owl:DatatypeProperty . }
    }
}
