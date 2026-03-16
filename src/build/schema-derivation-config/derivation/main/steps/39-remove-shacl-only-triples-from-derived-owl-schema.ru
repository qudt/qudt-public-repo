# owl-schema-derive step 39
# Message: Remove SHACL-only triples from derived OWL schema

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?s ?p ?o .
                                                    FILTER(
                                                        STRSTARTS(STR(?p), STR(sh:))
                                                        || EXISTS { ?s a sh:PropertyShape . }
                                                        || (?p = rdf:type && ?o IN (sh:NodeShape, sh:PropertyShape, sh:PrefixDeclaration))
                                                    )
                                                }
                                            }
