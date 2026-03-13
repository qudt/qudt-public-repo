# owl-datatypes-derive step 11
# Message: Classify datatype properties from SHACL constraints

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?p a owl:DatatypeProperty .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:typing-evidence> {
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?p .
                                                            FILTER(isIRI(?p))
                                                            FILTER EXISTS {
                                                                GRAPH <work:datatype:derived> {
                                                                    ?targetPs a sh:PropertyShape ;
                                                                              sh:path ?p .
                                                                }
                                                            }
                                                            {
                                                                ?ps sh:datatype ?datatype .
                                                            } UNION {
                                                                ?ps sh:nodeKind sh:Literal .
                                                            }
                                                        }
                                                    }
