# owl-schema-derive step 18
# Message: Normalize mixed datatype/object properties to rdf:Property

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:DatatypeProperty .
                                                    ?p a owl:ObjectProperty .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a rdf:Property .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:DatatypeProperty ;
                                                       a owl:ObjectProperty .
                                                }
                                            }
