# owl-schema-derive step 04
# Message: Normalize OWL class typing from rdfs:Class declarations

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c a owl:Class .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a rdfs:Class .
                                                    FILTER NOT EXISTS { ?c a rdfs:Datatype . }
                                                }
                                            }
