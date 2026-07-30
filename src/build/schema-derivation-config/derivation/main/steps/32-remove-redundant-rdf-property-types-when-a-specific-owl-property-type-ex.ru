# owl-schema-derive step 32
# Message: Remove redundant rdf:Property types when a specific OWL property type exists

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p rdf:type rdf:Property .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?p rdf:type rdf:Property ;
                                                       rdf:type ?specificType .
                                                    FILTER(?specificType IN (
                                                        owl:ObjectProperty,
                                                        owl:DatatypeProperty,
                                                        owl:AnnotationProperty
                                                    ))
                                                }
                                            }
