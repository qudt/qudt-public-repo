# owl-coordinates-derive step 35
# Message: Remove orphaned restriction blank nodes

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?r ?rp ?ro .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?r a owl:Restriction ;
                                                               ?rp ?ro .
                                                            FILTER(isBlank(?r))
                                                            FILTER NOT EXISTS { ?anyS ?anyP ?r . }
                                                        }
                                                    }
