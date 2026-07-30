# owl-schema-derive step 60
# Message: Remove orphaned restriction blank nodes left after subject pruning

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?bn ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?bn a owl:Restriction ;
                                                        ?p ?o .
                                                    FILTER(isBlank(?bn))
                                                }
                                                FILTER NOT EXISTS {
                                                    GRAPH <work:schema:derived> {
                                                        ?refS ?refP ?bn .
                                                    }
                                                }
                                            }
