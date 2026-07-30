# owl-schema-derive step 63
# Message: Final cleanup of orphaned RDF list blank-node chains

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?n ?np ?no .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?head rdf:first ?headFirst .
                                                    FILTER(isBlank(?head))
                                                    FILTER NOT EXISTS {
                                                        ?ref ?refP ?head .
                                                        FILTER(?ref != ?head)
                                                    }

                                                    ?head rdf:rest* ?n .
                                                    FILTER(isBlank(?n))
                                                    ?n ?np ?no .
                                                }
                                            }
