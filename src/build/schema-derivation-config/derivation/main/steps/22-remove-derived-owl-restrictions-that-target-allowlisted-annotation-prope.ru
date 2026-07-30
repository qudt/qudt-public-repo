# owl-schema-derive step 22
# Message: Remove derived OWL restrictions that target allowlisted annotation properties

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX dcterms: <http://purl.org/dc/terms/>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf ?r .
                                                    ?r ?rp ?ro .
                                                }
                                            }
                                            WHERE {
                                                VALUES ?p {
                                                    dcterms:abstract
                                                    dcterms:creator
                                                    dcterms:rights
                                                    dcterms:source
                                                    dcterms:subject
                                                    dcterms:title
                                                    qudt:example
                                                    qudt:expression
                                                    qudt:wikidataMatch
                                                }
                                                GRAPH <work:schema:derived> {
                                                    ?c rdfs:subClassOf ?r .
                                                    ?r a owl:Restriction ;
                                                       owl:onProperty ?p ;
                                                       ?rp ?ro .
                                                }
                                            }
