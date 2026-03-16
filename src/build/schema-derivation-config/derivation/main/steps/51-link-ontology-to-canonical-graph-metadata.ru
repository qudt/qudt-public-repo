# owl-schema-derive step 51
# Message: Link ontology to canonical graph metadata

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> vaem:hasGraphMetadata ?oldMetadata .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> vaem:hasGraphMetadata vaem:GMD_QUDT-SCHEMA .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    OPTIONAL {
                                                        <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> vaem:hasGraphMetadata ?oldMetadata .
                                                    }
                                                }
                                            }
