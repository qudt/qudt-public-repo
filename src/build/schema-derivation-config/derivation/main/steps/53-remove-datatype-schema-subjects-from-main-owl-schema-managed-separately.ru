# owl-schema-derive step 53
# Message: Remove datatype-schema subjects from main OWL schema (managed separately)

DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                    FILTER(!isBlank(?s))
                                                }
                                                GRAPH <work:schema:datatypes-shacl> {
                                                    ?s ?datatypeP ?datatypeO .
                                                    FILTER(!isBlank(?s))
                                                }
                                                FILTER NOT EXISTS {
                                                    GRAPH <work:schema:overlay> {
                                                        ?s ?overlayP ?overlayO .
                                                    }
                                                }
                                            }
