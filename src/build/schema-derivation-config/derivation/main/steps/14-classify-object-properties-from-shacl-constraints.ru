# owl-schema-derive step 14
# Message: Classify object properties from SHACL constraints

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:ObjectProperty .
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
                                                        EXISTS { ?ps sh:class ?cls . }
                                                        || EXISTS { ?ps sh:node [] . }
                                                        || EXISTS {
                                                            ?ps sh:nodeKind ?nk .
                                                            FILTER(?nk IN (sh:IRI, sh:BlankNodeOrIRI))
                                                        }
                                                        || EXISTS {
                                                            ?ps sh:or ?classList .
                                                            ?classList rdf:rest*/rdf:first ?classChoice .
                                                            ?classChoice sh:class ?orCls .
                                                        }
                                                    )
                                                }
                                            }
