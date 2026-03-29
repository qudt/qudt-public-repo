# owl-coordinates-derive step 24
# Message: Rename canonical datatype metadata subject away from SHACL path

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-SHACL-COORDINATES ?p ?o .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-SHACL-COORDINATES ?p ?o .
                                                        }
                                                    }
