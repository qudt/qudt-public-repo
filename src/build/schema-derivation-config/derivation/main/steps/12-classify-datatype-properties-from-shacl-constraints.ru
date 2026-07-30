# owl-schema-derive step 12
# Message: Classify datatype properties from SHACL constraints

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
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
                                                        sh:path ?p .
                                                    FILTER(isIRI(?p))
                                                    FILTER EXISTS {
                                                        GRAPH <work:schema:derived> {
                                                            ?targetPs a sh:PropertyShape ;
                                                                      sh:path ?p .
                                                        }
                                                    }
                                                    FILTER(
                                                        EXISTS { ?ps sh:datatype ?dt . }
                                                        || EXISTS {
                                                            ?ps sh:or ?datatypeList .
                                                            ?datatypeList rdf:rest*/rdf:first ?datatypeChoice .
                                                            ?datatypeChoice sh:datatype ?orDt .
                                                        }
                                                    )
                                                }
                                            }
