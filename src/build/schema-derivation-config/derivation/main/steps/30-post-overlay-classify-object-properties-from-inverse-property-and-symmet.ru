# owl-schema-derive step 30
# Message: Post-overlay classify object properties from inverse-property and symmetry evidence

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:ObjectProperty .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    {
                                                        ?p owl:inverseOf ?other .
                                                    } UNION {
                                                        ?other owl:inverseOf ?p .
                                                    } UNION {
                                                        ?p a qudt:SymmetricRelation .
                                                    }
                                                    FILTER(isIRI(?p))
                                                }
                                            }
