# owl-schema-derive step 06
# Message: Derive OWL allValuesFrom datatype restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf [
                                                        a owl:Restriction ;
                                                        owl:onProperty ?path ;
                                                        owl:allValuesFrom ?datatypeRange
                                                    ] .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a sh:NodeShape ;
                                                       a rdfs:Class ;
                                                       sh:property ?ps .
                                                    ?ps sh:path ?path ;
                                                        sh:datatype ?datatypeRange .
                                                    FILTER(isIRI(?path))
                                                }
                                            }
