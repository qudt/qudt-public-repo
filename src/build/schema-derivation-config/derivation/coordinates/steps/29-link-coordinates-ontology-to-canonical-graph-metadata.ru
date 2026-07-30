# owl-coordinates-derive step 29
# Message: Link datatype ontology to canonical graph metadata

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            <http://qudt.org/$$QUDT_VERSION$$/schema/coordinateSystems> vaem:hasGraphMetadata ?oldMetadata .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            <http://qudt.org/$$QUDT_VERSION$$/schema/coordinateSystems> vaem:hasGraphMetadata vaem:GMD_SCHEMA-COORDINATES .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            OPTIONAL {
                                                                <http://qudt.org/$$QUDT_VERSION$$/schema/coordinateSystems> vaem:hasGraphMetadata ?oldMetadata .
                                                            }
                                                        }
                                                    }
