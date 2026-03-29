# owl-coordinates-derive step 13
# Message: Infer owl:FunctionalProperty when all SHACL property shapes for a path have sh:maxCount 1

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?path a owl:FunctionalProperty .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:typing-evidence> {
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?path ;
                                                                sh:maxCount 1 .
                                                            FILTER(isIRI(?path))
                                                            FILTER EXISTS {
                                                                GRAPH <work:coordinate:derived> {
                                                                    ?targetPs a sh:PropertyShape ;
                                                                              sh:path ?path .
                                                                }
                                                            }
                                                        }
                                                        FILTER NOT EXISTS {
                                                            GRAPH <work:coordinate:typing-evidence> {
                                                                ?otherPs a sh:PropertyShape ;
                                                                         sh:path ?path .
                                                                FILTER NOT EXISTS { ?otherPs sh:maxCount 1 . }
                                                            }
                                                        }
                                                    }
