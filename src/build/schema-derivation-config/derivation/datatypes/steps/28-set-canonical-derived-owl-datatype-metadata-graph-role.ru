# owl-datatypes-derive step 28
# Message: Set canonical derived OWL datatype metadata graph role

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE vaem:hasGraphRole ?oldRole .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE vaem:hasGraphRole vaem:SchemaGraph .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            OPTIONAL { vaem:GMD_SCHEMA-DATATYPE vaem:hasGraphRole ?oldRole . }
                                                        }
                                                    }
