# owl-coordinates-derive step 15
# Message: Remove redundant rdf:Property types when a specific OWL property type exists

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a rdf:Property .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a rdf:Property .
                                                            FILTER(
                                                                EXISTS { ?p a owl:ObjectProperty . }
                                                                || EXISTS { ?p a owl:DatatypeProperty . }
                                                                || EXISTS { ?p a owl:AnnotationProperty . }
                                                            )
                                                        }
                                                    }
