# owl-schema-derive step 62
# Message: Remove SHACL helper list resources from derived OWL schema

PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?helper ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                VALUES ?helper {
                                                    qudt:NumericTypeUnion
                                                    qudt:NumericListShape
                                                }
                                                GRAPH <work:schema:derived> {
                                                    ?helper ?p ?o .
                                                }
                                            }
