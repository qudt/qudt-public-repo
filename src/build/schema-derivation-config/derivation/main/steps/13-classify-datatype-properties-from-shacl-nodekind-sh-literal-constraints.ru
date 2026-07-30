# owl-schema-derive step 13
# Message: Classify datatype properties from SHACL nodeKind sh:Literal constraints

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:DatatypeProperty .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:typing-evidence> {
                                                    ?ps a sh:PropertyShape ;
                                                        sh:path ?p ;
                                                        sh:nodeKind sh:Literal .
                                                    FILTER(isIRI(?p))
                                                    FILTER EXISTS {
                                                        GRAPH <work:schema:derived> {
                                                            ?targetPs a sh:PropertyShape ;
                                                                      sh:path ?p .
                                                        }
                                                    }
                                                }
                                            }
