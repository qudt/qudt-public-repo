# owl-coordinates-derive step 14
# Message: Fallback typing: convert remaining rdf:Property declarations to owl:AnnotationProperty

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a rdf:Property .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a owl:AnnotationProperty .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a rdf:Property .
                                                            FILTER NOT EXISTS { ?p a owl:ObjectProperty . }
                                                            FILTER NOT EXISTS { ?p a owl:DatatypeProperty . }
                                                            FILTER NOT EXISTS { ?p a owl:AnnotationProperty . }
                                                        }
                                                    }
