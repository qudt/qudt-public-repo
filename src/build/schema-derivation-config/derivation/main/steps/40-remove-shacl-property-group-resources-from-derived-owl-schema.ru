# owl-schema-derive step 40
# Message: Remove SHACL property-group resources from derived OWL schema

PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?group ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?group a sh:PropertyGroup ;
                                                           ?p ?o .
                                                }
                                            }
