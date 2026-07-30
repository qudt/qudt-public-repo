# owl-schema-derive step 10
# Message: Derive OWL maximum cardinality restrictions

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf [
                                                        a owl:Restriction ;
                                                        owl:onProperty ?path ;
                                                        owl:maxCardinality ?maxCount
                                                    ] .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?c a sh:NodeShape ;
                                                       a rdfs:Class ;
                                                       sh:property ?ps .
                                                    ?ps sh:path ?path ;
                                                        sh:maxCount ?maxRaw .
                                                    FILTER(isIRI(?path))
                                                    BIND(xsd:nonNegativeInteger(?maxRaw) AS ?maxCount)
                                                }
                                            }
