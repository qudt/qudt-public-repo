# owl-schema-derive step 64
# Message: Carry over one backup dcterms:description when SHACL has none

PREFIX dcterms: <http://purl.org/dc/terms/>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?s dcterms:description ?carryDescription .
                                                }
                                            }
                                            WHERE {
                                                {
                                                    SELECT ?s (MIN(?backupDescriptionCandidate) AS ?carryDescription)
                                                    WHERE {
                                                        GRAPH <work:schema:backup> {
                                                            ?s dcterms:description ?backupDescriptionCandidate .
                                                            FILTER(isIRI(?s))
                                                        }
                                                    }
                                                    GROUP BY ?s
                                                }
                                                GRAPH <work:schema:derived> {
                                                    ?s ?anyP ?anyO .
                                                    FILTER(isIRI(?s))
                                                }
                                                FILTER NOT EXISTS {
                                                    GRAPH <work:schema:shacl-source> {
                                                        ?s dcterms:description ?shaclDescription .
                                                    }
                                                }
                                                FILTER NOT EXISTS {
                                                    GRAPH <work:schema:derived> {
                                                        ?s dcterms:description ?existingDescription .
                                                    }
                                                }
                                            }
