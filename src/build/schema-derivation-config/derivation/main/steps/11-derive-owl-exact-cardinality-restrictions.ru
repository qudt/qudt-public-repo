# owl-schema-derive step 11
# Message: Derive OWL exact cardinality restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf [
                                                        a owl:Restriction ;
                                                        owl:onProperty ?path ;
                                                        owl:cardinality ?exactCount
                                                    ] .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a sh:NodeShape ;
                                                       a rdfs:Class ;
                                                       sh:property ?ps .
                                                    ?ps sh:path ?path ;
                                                        sh:minCount ?minRaw ;
                                                        sh:maxCount ?maxRaw .
                                                    FILTER(isIRI(?path))
                                                    FILTER(?minRaw = ?maxRaw)
                                                    BIND(xsd:nonNegativeInteger(?minRaw) AS ?exactCount)
                                                }
                                            }
