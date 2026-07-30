# owl-schema-derive step 16
# Message: Infer owl:FunctionalProperty when all SHACL property shapes for a path have sh:maxCount 1

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:FunctionalProperty .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:typing-evidence> {
                                                    ?ps a sh:PropertyShape ;
                                                        sh:path ?p ;
                                                        sh:maxCount 1 .
                                                    FILTER(isIRI(?p))
                                                    FILTER EXISTS {
                                                        GRAPH <work:schema:derived> {
                                                            ?targetPs a sh:PropertyShape ;
                                                                      sh:path ?p .
                                                        }
                                                    }
                                                    FILTER NOT EXISTS {
                                                        ?otherPs a sh:PropertyShape ;
                                                                 sh:path ?p .
                                                        FILTER NOT EXISTS {
                                                            ?otherPs sh:maxCount 1 .
                                                        }
                                                    }
                                                }
                                            }
