# owl-coordinates-derive step 21
# Message: Remove SHACL-only triples from derived OWL datatypes schema

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?p ?o .
                                                            FILTER(
                                                                STRSTARTS(STR(?p), STR(sh:))
                                                                || EXISTS { ?s a sh:PropertyShape . }
                                                                || (?p = rdf:type && ?o IN (sh:NodeShape, sh:PropertyShape, sh:PrefixDeclaration))
                                                            )
                                                        }
                                                    }
