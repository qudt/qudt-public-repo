# owl-schema-derive step 43
# Message: Remove remaining SHACL schema resources from derived OWL schema

DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                    FILTER(
                                                        isIRI(?s)
                                                        && STRSTARTS(STR(?s), "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/")
                                                    )
                                                }
                                            }
