# owl-schema-derive step 56
# Message: Remove datatype restrictions that use custom non-XSD datatypes in main OWL schema

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf ?r .
                                                    ?r ?rp ?ro .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf ?r .
                                                    ?r a owl:Restriction ;
                                                       owl:onProperty ?p ;
                                                       owl:allValuesFrom ?range ;
                                                       ?rp ?ro .
                                                    ?p a owl:DatatypeProperty .
                                                    FILTER(isIRI(?range))
                                                    FILTER(!STRSTARTS(STR(?range), "http://www.w3.org/2001/XMLSchema#"))
                                                    FILTER(?range != rdf:HTML)
                                                    FILTER(?range != rdfs:Literal)
                                                }
                                            }
