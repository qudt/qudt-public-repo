# owl-schema-derive step 57
# Message: Remove non-XSD custom datatype ranges from main OWL schema datatype properties

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p rdfs:range ?range .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:DatatypeProperty ;
                                                       rdfs:range ?range .
                                                    FILTER(isIRI(?range))
                                                    FILTER(!STRSTARTS(STR(?range), "http://www.w3.org/2001/XMLSchema#"))
                                                    FILTER(?range != rdf:HTML)
                                                    FILTER(?range != rdfs:Literal)
                                                }
                                            }
