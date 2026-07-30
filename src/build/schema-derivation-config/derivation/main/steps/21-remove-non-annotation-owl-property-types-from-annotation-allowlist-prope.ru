# owl-schema-derive step 21
# Message: Remove non-annotation OWL property types from annotation allowlist properties

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX dcterms: <http://purl.org/dc/terms/>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p a ?typeToRemove .
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
                                                VALUES ?typeToRemove {
                                                    owl:DatatypeProperty
                                                    owl:ObjectProperty
                                                    owl:FunctionalProperty
                                                }
                                                GRAPH <work:schema:derived> {
                                                    ?p a ?typeToRemove .
                                                }
                                            }
