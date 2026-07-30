# owl-schema-derive step 55
# Message: Remove restrictions that point to datatype-schema subjects (managed separately)

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
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
                                                       owl:allValuesFrom ?range ;
                                                       ?rp ?ro .
                                                    FILTER(isBlank(?r))
                                                    FILTER(!isBlank(?range))
                                                }
                                                GRAPH <work:schema:datatypes-shacl> {
                                                    ?range ?datatypeP ?datatypeO .
                                                    FILTER(!isBlank(?range))
                                                }
                                            }
