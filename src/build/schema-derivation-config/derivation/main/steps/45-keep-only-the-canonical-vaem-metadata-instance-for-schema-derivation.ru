# owl-schema-derive step 45
# Message: Keep only the canonical VAEM metadata instance for schema derivation

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?m ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?m a vaem:GraphMetaData ;
                                                       ?p ?o .
                                                    FILTER(?m NOT IN (vaem:GMD_QUDT-SCHEMA, vaem:GMD_SHACLQUDT-SCHEMA))
                                                }
                                            }
