# owl-coordinates-derive step 28
# Message: Set canonical derived OWL datatype metadata graph role

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:hasGraphRole ?oldRole .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:hasGraphRole vaem:SchemaGraph .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:hasGraphRole ?oldRole . }
                                                        }
                                                    }
