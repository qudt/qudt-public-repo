# owl-datatypes-derive step 02
# Message: Convert SHACL node shapes to OWL classes

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c a owl:Class .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c a sh:NodeShape .
                                                        }
                                                    }
