# owl-datatypes-derive step 40
# Message: Remove named SHACL SPARQL constraints

PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c a sh:SPARQLConstraint ;
                                                               ?p ?o .
                                                        }
                                                    }
