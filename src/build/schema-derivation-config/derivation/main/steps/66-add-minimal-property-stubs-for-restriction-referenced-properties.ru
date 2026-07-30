# owl-schema-derive step 66
# Message: Add minimal property stubs for restriction-referenced properties missing top-level declarations

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX sh: <http://www.w3.org/ns/shacl#>

INSERT {
    GRAPH <work:schema:derived> {
        ?p a ?propertyType ;
           rdfs:isDefinedBy ?nativeGraph .
    }
}
WHERE {
    {
        SELECT ?p ?propertyType (SAMPLE(?normalizedDefinedBy) AS ?nativeGraph)
        WHERE {
            GRAPH <work:schema:derived> {
                ?r a owl:Restriction ;
                   owl:onProperty ?p .
                FILTER(isIRI(?p))
                FILTER(STRSTARTS(STR(?p), "http://qudt.org/schema/qudt/"))
            }
            FILTER NOT EXISTS {
                GRAPH <work:schema:derived> {
                    ?p a ?existingType .
                    FILTER(
                        ?existingType IN (
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
            }
            BIND(
                IF(
                    EXISTS {
                        GRAPH <work:schema:typing-evidence> {
                            ?ps a sh:PropertyShape ;
                                sh:path ?p .
                            {
                                ?ps sh:datatype ?datatype .
                            } UNION {
                                ?ps sh:or ?datatypeList .
                                ?datatypeList rdf:rest*/rdf:first ?datatypeChoice .
                                ?datatypeChoice sh:datatype ?orDatatype .
                            } UNION {
                                ?ps sh:nodeKind sh:Literal .
                            }
                        }
                    },
                    owl:DatatypeProperty,
                    IF(
                        EXISTS {
                            GRAPH <work:schema:typing-evidence> {
                                ?ps a sh:PropertyShape ;
                                    sh:path ?p .
                                {
                                    ?ps sh:class ?classRange .
                                } UNION {
                                    ?ps sh:node ?nodeShape .
                                } UNION {
                                    ?ps sh:nodeKind ?nodeKind .
                                    FILTER(?nodeKind IN (sh:IRI, sh:BlankNodeOrIRI))
                                } UNION {
                                    ?ps sh:or ?classList .
                                    ?classList rdf:rest*/rdf:first ?classChoice .
                                    ?classChoice sh:class ?orClass .
                                }
                            }
                        },
                        owl:ObjectProperty,
                        IF(
                            EXISTS {
                                GRAPH <work:schema:derived> {
                                    ?datatypeRestriction a owl:Restriction ;
                                                         owl:onProperty ?p ;
                                                         owl:allValuesFrom ?range .
                                    FILTER(
                                        STRSTARTS(STR(?range), "http://www.w3.org/2001/XMLSchema#")
                                        || ?range = rdf:HTML
                                        || EXISTS { ?range a rdfs:Datatype . }
                                    )
                                }
                            },
                            owl:DatatypeProperty,
                            IF(
                                EXISTS {
                                    GRAPH <work:schema:derived> {
                                        ?objectRestriction a owl:Restriction ;
                                                           owl:onProperty ?p ;
                                                           owl:allValuesFrom ?range .
                                        FILTER(
                                            !STRSTARTS(STR(?range), "http://www.w3.org/2001/XMLSchema#")
                                            && ?range != rdf:HTML
                                            && !EXISTS { ?range a rdfs:Datatype . }
                                        )
                                    }
                                },
                                owl:ObjectProperty,
                                rdf:Property
                            )
                        )
                    )
                ) AS ?propertyType
            )
            OPTIONAL {
                GRAPH <work:schema:typing-evidence> {
                    {
                        ?p rdfs:isDefinedBy ?rawDefinedBy .
                    } UNION {
                        ?ps a sh:PropertyShape ;
                            sh:path ?p ;
                            rdfs:isDefinedBy ?rawDefinedBy .
                    }
                }
            }
            BIND(
                IF(
                    BOUND(?rawDefinedBy),
                    IRI(REPLACE(STR(?rawDefinedBy), "/schema/shacl/", "/schema/")),
                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt>
                ) AS ?normalizedDefinedBy
            )
        }
        GROUP BY ?p ?propertyType
    }
}
