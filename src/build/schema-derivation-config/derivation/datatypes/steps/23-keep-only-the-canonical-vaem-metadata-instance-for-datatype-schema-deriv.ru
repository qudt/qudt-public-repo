# owl-datatypes-derive step 23
# Message: Keep only the canonical VAEM metadata instance for datatype schema derivation

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?m ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?m a vaem:GraphMetaData ;
                                                               ?p ?o .
                                                            FILTER(
                                                                ?m NOT IN (
                                                                    vaem:GMD_SCHEMA-DATATYPE,
                                                                    vaem:GMD_SCHEMA-SHACL-DATATYPE
                                                                )
                                                            )
                                                        }
                                                    }
