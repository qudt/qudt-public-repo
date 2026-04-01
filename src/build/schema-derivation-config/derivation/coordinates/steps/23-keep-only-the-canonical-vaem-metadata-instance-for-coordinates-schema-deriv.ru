# owl-coordinates-derive step 23
# Message: Keep only the canonical VAEM metadata instance for datatype schema derivation

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?m ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?m a vaem:GraphMetaData ;
                                                               ?p ?o .
                                                            FILTER(
                                                                ?m NOT IN (
                                                                    vaem:GMD_SCHEMA-COORDINATES,
                                                                    vaem:GMD_SCHEMA-SHACL-COORDINATES
                                                                )
                                                            )
                                                        }
                                                    }
