# owl-schema-derive step 50
# Message: Set canonical derived OWL metadata graph role

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA vaem:hasGraphRole ?oldRole .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA vaem:hasGraphRole vaem:SchemaGraph .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    OPTIONAL { vaem:GMD_QUDT-SCHEMA vaem:hasGraphRole ?oldRole . }
                                                }
                                            }
