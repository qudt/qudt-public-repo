# owl-coordinates-derive step 07
# Message: Derive OWL maximum cardinality restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?c rdfs:subClassOf [
                                                                a owl:Restriction ;
                                                                owl:onProperty ?path ;
                                                                owl:maxCardinality ?maxCardinality
                                                            ] .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?c a sh:NodeShape ;
                                                               sh:property ?ps .
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?path ;
                                                                sh:maxCount ?maxCardinality .
                                                            FILTER(isIRI(?path))
                                                        }
                                                    }
