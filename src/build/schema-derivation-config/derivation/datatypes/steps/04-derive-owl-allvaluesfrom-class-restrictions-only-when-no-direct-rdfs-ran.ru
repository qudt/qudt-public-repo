# owl-datatypes-derive step 04
# Message: Derive OWL allValuesFrom class restrictions only when no direct rdfs:range exists

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c rdfs:subClassOf [
                                                                a owl:Restriction ;
                                                                owl:onProperty ?path ;
                                                                owl:allValuesFrom ?range
                                                            ] .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c a sh:NodeShape ;
                                                               sh:property ?ps .
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?path ;
                                                                sh:class ?range .
                                                            FILTER(isIRI(?path))
                                                            FILTER NOT EXISTS { ?path rdfs:range ?anyRange . }
                                                        }
                                                    }
