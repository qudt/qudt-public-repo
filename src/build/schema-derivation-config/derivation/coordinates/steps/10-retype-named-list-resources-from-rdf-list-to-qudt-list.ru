# owl-coordinates-derive step 10
# Message: Retype named list resources from rdf:List to qudt:List

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX qudt: <http://qudt.org/schema/qudt/>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?list a rdf:List .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?list a qudt:List .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?list a rdf:List ;
                                                                  rdf:first ?anyFirst .
                                                            FILTER(isIRI(?list))
                                                        }
                                                    }
