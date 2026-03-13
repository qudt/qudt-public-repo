# owl-datatypes-derive step 36
# Message: Remove orphaned malformed cardinality blank nodes with no owl:onProperty

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?r ?rp ?ro .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?r ?rp ?ro .
                                                            FILTER(isBlank(?r))
                                                            FILTER(
                                                                EXISTS { ?r owl:minCardinality ?min . }
                                                                || EXISTS { ?r owl:maxCardinality ?max . }
                                                                || EXISTS { ?r owl:cardinality ?card . }
                                                            )
                                                            FILTER NOT EXISTS { ?r owl:onProperty ?onP . }
                                                            FILTER NOT EXISTS { ?anyS ?anyP ?r . }
                                                        }
                                                    }
