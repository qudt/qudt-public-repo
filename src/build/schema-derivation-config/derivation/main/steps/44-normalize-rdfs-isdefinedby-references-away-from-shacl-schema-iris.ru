# owl-schema-derive step 44
# Message: Normalize rdfs:isDefinedBy references away from SHACL schema IRIs

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?s rdfs:isDefinedBy ?oldDefinedBy .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?s rdfs:isDefinedBy ?oldDefinedBy .
                                                    FILTER(
                                                        isIRI(?oldDefinedBy)
                                                        && STRSTARTS(STR(?oldDefinedBy), "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/")
                                                    )
                                                }
                                            }
