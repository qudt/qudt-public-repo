# owl-schema-derive step 05
# Message: Derive OWL allValuesFrom class restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf [
                                                        a owl:Restriction ;
                                                        owl:onProperty ?path ;
                                                        owl:allValuesFrom ?classRange
                                                    ] .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a sh:NodeShape ;
                                                       a rdfs:Class ;
                                                       sh:property ?ps .
                                                    ?ps sh:path ?path ;
                                                        sh:class ?classRange .
                                                    FILTER(isIRI(?path))
                                                }
                                            }
