# owl-schema-derive step 42
# Message: Normalize ontology resources: keep only the OWL schema ontology IRI

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?ont ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?ont a owl:Ontology ;
                                                         ?p ?o .
                                                    FILTER(?ont != <http://qudt.org/$$QUDT_VERSION$$/schema/qudt>)
                                                }
                                            }
