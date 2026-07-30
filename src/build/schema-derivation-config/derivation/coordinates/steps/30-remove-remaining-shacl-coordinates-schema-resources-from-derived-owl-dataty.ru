# owl-coordinates-derive step 30
# Message: Remove remaining SHACL datatype schema resources from derived OWL datatype schema

DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?p ?o .
                                                            FILTER(
                                                                isIRI(?s)
                                                                && STRSTARTS(STR(?s), "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/")
                                                            )
                                                        }
                                                    }
