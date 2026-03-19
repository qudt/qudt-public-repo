# owl-schema-derive step 17
# Message: Apply explicit property type overrides for mixed SHACL constraints

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

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
                                                VALUES ?p {
                                                    qudt:exponent
                                                }
                                                GRAPH <work:schema:derived> {
                                                    OPTIONAL { ?p a owl:DatatypeProperty . }
                                                    OPTIONAL { ?p a owl:ObjectProperty . }
                                                }
                                            }
