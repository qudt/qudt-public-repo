# owl-datatypes-derive step 06
# Message: Derive OWL minimum cardinality restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c rdfs:subClassOf [
                                                                a owl:Restriction ;
                                                                owl:onProperty ?path ;
                                                                owl:minCardinality ?minCardinality
                                                            ] .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            ?c a sh:NodeShape ;
                                                               sh:property ?ps .
                                                            ?ps a sh:PropertyShape ;
                                                                sh:path ?path ;
                                                                sh:minCount ?minCardinality .
                                                            FILTER(isIRI(?path))
                                                        }
                                                    }
