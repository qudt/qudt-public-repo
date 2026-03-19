# owl-schema-derive step 09
# Message: Derive OWL minimum cardinality restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf [
                                                        a owl:Restriction ;
                                                        owl:onProperty ?path ;
                                                        owl:minCardinality ?minCount
                                                    ] .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a sh:NodeShape ;
                                                       a rdfs:Class ;
                                                       sh:property ?ps .
                                                    ?ps sh:path ?path ;
                                                        sh:minCount ?minRaw .
                                                    FILTER(isIRI(?path))
                                                    BIND(xsd:nonNegativeInteger(?minRaw) AS ?minCount)
                                                }
                                            }
