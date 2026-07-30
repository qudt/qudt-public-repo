# owl-schema-derive step 51
# Message: Link ontology to canonical graph metadata and child schema imports

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> vaem:hasGraphMetadata ?oldMetadata .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> owl:imports <http://qudt.org/$$QUDT_VERSION$$/schema/coordinateSystems> .
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> owl:imports <http://qudt.org/$$QUDT_VERSION$$/schema/datatype> .
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
