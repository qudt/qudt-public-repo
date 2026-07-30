# owl-coordinates-derive step 33
# Message: Remove rdfs:subClassOf rdfs:Resource from OWL classes

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?c rdfs:subClassOf rdfs:Resource .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?c a owl:Class ;
                                                               rdfs:subClassOf rdfs:Resource .
                                                        }
                                                    }
