# owl-coordinates-derive step 18
# Message: Remove object/datatype-only OWL property characteristics from annotation properties

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a ?characteristicType .
                                                        }
                                                    }
                                                    WHERE {
                                                        VALUES ?characteristicType {
                                                            owl:FunctionalProperty
                                                            owl:InverseFunctionalProperty
                                                            owl:SymmetricProperty
                                                            owl:TransitiveProperty
                                                            owl:AsymmetricProperty
                                                            owl:ReflexiveProperty
                                                            owl:IrreflexiveProperty
                                                        }
                                                        GRAPH <work:coordinate:derived> {
                                                            ?p a owl:AnnotationProperty ;
                                                               a ?characteristicType .
                                                        }
                                                    }
