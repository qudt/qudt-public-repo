# owl-datatypes-derive step 19
# Message: Remove cardinality restrictions on properties without owl:ObjectProperty/owl:DatatypeProperty typing

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c rdfs:subClassOf ?r .
                                                            ?r ?rp ?ro .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c rdfs:subClassOf ?r .
                                                            ?r a owl:Restriction ;
                                                               owl:onProperty ?p ;
                                                               ?rp ?ro .
                                                            FILTER(isBlank(?r))
                                                            FILTER(
                                                                EXISTS { ?r owl:minCardinality ?min . }
                                                                || EXISTS { ?r owl:maxCardinality ?max . }
                                                                || EXISTS { ?r owl:cardinality ?card . }
                                                            )
                                                            FILTER NOT EXISTS { ?p a owl:ObjectProperty . }
                                                            FILTER NOT EXISTS { ?p a owl:DatatypeProperty . }
                                                        }
                                                    }
