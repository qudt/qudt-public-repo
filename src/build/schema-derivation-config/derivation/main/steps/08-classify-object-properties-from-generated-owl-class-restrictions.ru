# owl-schema-derive step 08
# Message: Classify object properties from generated OWL class restrictions

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:ObjectProperty .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf ?r .
                                                    ?r a owl:Restriction ;
                                                       owl:onProperty ?p ;
                                                       owl:allValuesFrom ?range .
                                                    FILTER(isIRI(?p))
                                                    FILTER(
                                                        !STRSTARTS(STR(?range), "http://www.w3.org/2001/XMLSchema#")
                                                        && ?range != rdf:HTML
                                                        && !EXISTS { ?range a rdfs:Datatype . }
                                                        && !EXISTS { ?ps2 a sh:PropertyShape ; sh:datatype ?range . }
                                                        && !EXISTS {
                                                            ?ps2 a sh:PropertyShape ; sh:or ?rangeList .
                                                            ?rangeList rdf:rest*/rdf:first ?choice .
                                                            ?choice sh:datatype ?range .
                                                        }
                                                    )
                                                }
                                            }
