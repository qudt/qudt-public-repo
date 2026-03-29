# owl-coordinates-derive step 20
# Message: Make SHACL dcterms:description values authoritative for datatype OWL derivation

PREFIX dcterms: <http://purl.org/dc/terms/>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s dcterms:description ?oldDescription .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s dcterms:description ?shaclDescription .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:shacl-source> {
                                                            ?s dcterms:description ?shaclDescription .
                                                        }
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?anyP ?anyO .
                                                            FILTER(isIRI(?s))
                                                            OPTIONAL { ?s dcterms:description ?oldDescription . }
                                                        }
                                                    }
