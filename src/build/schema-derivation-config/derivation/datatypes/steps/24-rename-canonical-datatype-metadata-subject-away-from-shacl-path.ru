# owl-datatypes-derive step 24
# Message: Rename canonical datatype metadata subject away from SHACL path

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-SHACL-DATATYPE ?p ?o .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-SHACL-DATATYPE ?p ?o .
                                                        }
                                                    }
