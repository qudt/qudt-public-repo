# owl-coordinates-derive step 32
# Message: Remove redundant rdf:type rdfs:Class when owl:Class is present

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdf:type rdfs:Class .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdf:type rdfs:Class ;
                                                               rdf:type owl:Class .
                                                        }
                                                    }
