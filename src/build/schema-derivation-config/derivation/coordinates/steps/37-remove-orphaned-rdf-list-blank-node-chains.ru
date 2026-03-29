# owl-coordinates-derive step 37
# Message: Remove orphaned RDF list blank-node chains

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?n ?np ?no .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?head rdf:first ?headFirst .
                                                            FILTER(isBlank(?head))
                                                            FILTER NOT EXISTS { ?anchor ?anchorP ?head . }
                                                            FILTER NOT EXISTS {
                                                                ?anchor2 ?anchor2P ?head .
                                                                FILTER(!isBlank(?anchor2))
                                                            }
                                                            ?head rdf:rest* ?n .
                                                            FILTER(isBlank(?n))
                                                            ?n ?np ?no .
                                                        }
                                                    }
