# owl-schema-derive step 58
# Message: Remove malformed anonymous restrictions missing owl:Restriction type or owl:onProperty

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
                                                    FILTER(isBlank(?r))
                                                    FILTER(
                                                        EXISTS { ?r owl:minCardinality ?min . }
                                                        || EXISTS { ?r owl:maxCardinality ?max . }
                                                        || EXISTS { ?r owl:cardinality ?card . }
                                                        || EXISTS { ?r owl:allValuesFrom ?allv . }
                                                    )
                                                    FILTER(
                                                        !EXISTS { ?r a owl:Restriction . }
                                                        || !EXISTS { ?r owl:onProperty ?op . }
                                                    )
                                                    ?r ?rp ?ro .
                                                }
                                            }
