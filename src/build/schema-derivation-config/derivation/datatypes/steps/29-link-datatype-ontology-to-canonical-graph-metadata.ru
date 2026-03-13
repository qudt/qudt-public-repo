# owl-datatypes-derive step 29
# Message: Link datatype ontology to canonical graph metadata

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/$$QUDT_VERSION$$/schema/datatype> vaem:hasGraphMetadata ?oldMetadata .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/$$QUDT_VERSION$$/schema/datatype> vaem:hasGraphMetadata <http://qudt.org/schema/datatype/GMD_datatype> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            OPTIONAL {
                                                                <http://qudt.org/$$QUDT_VERSION$$/schema/datatype> vaem:hasGraphMetadata ?oldMetadata .
                                                            }
                                                        }
                                                    }
