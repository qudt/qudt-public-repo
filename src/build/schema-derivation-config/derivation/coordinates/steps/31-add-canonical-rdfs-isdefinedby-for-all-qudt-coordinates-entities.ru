# owl-coordinates-derive step 31
# Message: Add canonical rdfs:isDefinedBy for all QUDT datatype entities

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/coordinatesystems> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?anyP ?anyO .
                                                            FILTER(isIRI(?s))
                                                            FILTER(STRSTARTS(STR(?s), "http://qudt.org/schema/qudt/"))
                                                            FILTER(?s != <http://qudt.org/$$QUDT_VERSION$$/schema/coordinatesystems>)
                                                            FILTER NOT EXISTS {
                                                                ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/coordinatesystems> .
                                                            }
                                                        }
                                                    }
