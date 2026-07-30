# owl-datatypes-derive step 09
# Message: Preserve SHACL list member values as concrete rdf:first IRIs before SHACL cleanup

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?cell rdf:first ?item .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?cell rdf:first ?value .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?cell rdf:first ?item .
                                                            FILTER(isBlank(?item))
                                                            {
                                                                ?item sh:datatype ?value .
                                                            } UNION {
                                                                ?item sh:class ?value .
                                                            }
                                                        }
                                                    }
