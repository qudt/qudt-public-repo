# owl-schema-derive step 36
# Message: Remove owl:inverseOf from properties without owl:ObjectProperty typing

PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p owl:inverseOf ?inv .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?p owl:inverseOf ?inv .
                                                    FILTER NOT EXISTS { ?p a owl:ObjectProperty . }
                                                }
                                            }
