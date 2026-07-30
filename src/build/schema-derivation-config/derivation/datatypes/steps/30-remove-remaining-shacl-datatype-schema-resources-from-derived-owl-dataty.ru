# owl-datatypes-derive step 30
# Message: Remove remaining SHACL datatype schema resources from derived OWL datatype schema

DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?s ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?s ?p ?o .
                                                            FILTER(
                                                                isIRI(?s)
                                                                && STRSTARTS(STR(?s), "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/")
                                                            )
                                                        }
                                                    }
