# owl-schema-derive step 46
# Message: Rename canonical metadata subject to vaem:GMD_QUDT-SCHEMA

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_SHACLQUDT-SCHEMA ?p ?o .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_SHACLQUDT-SCHEMA ?p ?o .
                                                }
                                            }
