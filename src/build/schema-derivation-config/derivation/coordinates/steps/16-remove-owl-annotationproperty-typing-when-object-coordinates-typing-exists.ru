# owl-coordinates-derive step 16
# Message: Remove owl:AnnotationProperty typing when object/datatype typing exists

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a owl:AnnotationProperty .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a owl:AnnotationProperty ;
                                                               a ?specificType .
                                                            FILTER(?specificType IN (owl:ObjectProperty, owl:DatatypeProperty))
                                                        }
                                                    }
