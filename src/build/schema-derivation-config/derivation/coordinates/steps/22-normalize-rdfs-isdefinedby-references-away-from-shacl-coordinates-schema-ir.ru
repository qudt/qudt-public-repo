# owl-coordinates-derive step 22
# Message: Normalize rdfs:isDefinedBy references away from SHACL datatype schema IRIs

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdfs:isDefinedBy ?oldDefinedBy .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/coordinatesystems> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdfs:isDefinedBy ?oldDefinedBy .
                                                            FILTER(
                                                                isIRI(?oldDefinedBy)
                                                                && STRSTARTS(STR(?oldDefinedBy), "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinatesystems")
                                                            )
                                                        }
                                                    }
