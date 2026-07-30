# owl-coordinates-derive step 38
# Message: Carry over one backup dcterms:description when SHACL datatypes schema has none

PREFIX dcterms: <http://purl.org/dc/terms/>

                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s dcterms:description ?carryDescription .
                                                        }
                                                    }
                                                    WHERE {
                                                        {
                                                            SELECT ?s (MIN(?backupDescriptionCandidate) AS ?carryDescription)
                                                            WHERE {
                                                                GRAPH <work:coordinate:backup> {
                                                                    ?s dcterms:description ?backupDescriptionCandidate .
                                                                    FILTER(isIRI(?s))
                                                                }
                                                            }
                                                            GROUP BY ?s
                                                        }
                                                        GRAPH <work:coordinate:derived> {
                                                            ?s ?anyP ?anyO .
                                                            FILTER(isIRI(?s))
                                                        }
                                                        FILTER NOT EXISTS {
                                                            GRAPH <work:coordinate:shacl-source> {
                                                                ?s dcterms:description ?shaclDescription .
                                                            }
                                                        }
                                                        FILTER NOT EXISTS {
                                                            GRAPH <work:coordinate:derived> {
                                                                ?s dcterms:description ?existingDescription .
                                                            }
                                                        }
                                                    }
