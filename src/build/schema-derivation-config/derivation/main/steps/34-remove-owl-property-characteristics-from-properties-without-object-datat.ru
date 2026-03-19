# owl-schema-derive step 34
# Message: Remove OWL property characteristics from properties without object/datatype/annotation typing

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
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
                                                GRAPH <work:schema:derived> {
                                                    ?p a ?characteristicType .
                                                    FILTER NOT EXISTS { ?p a owl:ObjectProperty . }
                                                    FILTER NOT EXISTS { ?p a owl:DatatypeProperty . }
                                                    FILTER NOT EXISTS { ?p a owl:AnnotationProperty . }
                                                }
                                            }
