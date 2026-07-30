# owl-schema-derive step 20
# Message: Apply allowlist for owl:AnnotationProperty

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX dcterms: <http://purl.org/dc/terms/>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?p a owl:AnnotationProperty .
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
                                            }
