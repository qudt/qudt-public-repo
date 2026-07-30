# owl-datatypes-derive step 13
# Message: Infer owl:FunctionalProperty when all SHACL property shapes for a path have sh:maxCount 1

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?path a owl:FunctionalProperty .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:typing-evidence> {
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?path ;
                                                                sh:maxCount 1 .
                                                            FILTER(isIRI(?path))
                                                            FILTER EXISTS {
                                                                GRAPH <work:datatype:derived> {
                                                                    ?targetPs a sh:PropertyShape ;
                                                                              sh:path ?path .
                                                                }
                                                            }
                                                        }
                                                        FILTER NOT EXISTS {
                                                            GRAPH <work:datatype:typing-evidence> {
                                                                ?otherPs a sh:PropertyShape ;
                                                                         sh:path ?path .
                                                                FILTER NOT EXISTS { ?otherPs sh:maxCount 1 . }
                                                            }
                                                        }
                                                    }
