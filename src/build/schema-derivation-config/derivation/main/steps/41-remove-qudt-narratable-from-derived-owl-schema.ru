# owl-schema-derive step 41
# Message: Remove qudt:Narratable from derived OWL schema

PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                    FILTER(?s = qudt:Narratable || ?o = qudt:Narratable)
                                                }
                                            }
