# owl-coordinates-derive step 26
# Message: Normalize canonical datatype metadata literal fields by removing SHACL markers and shacl path segments

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX dcterms: <http://purl.org/dc/terms/>
                                                    PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES ?p ?oldLiteral .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES ?p ?newLiteral .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES ?p ?oldLiteral .
                                                            FILTER(isLiteral(?oldLiteral))
                                                            FILTER(
                                                                ?p IN (
                                                                    rdfs:label,
                                                                    dcterms:title,
                                                                    vaem:title,
                                                                    vaem:graphTitle,
                                                                    vaem:latestPublishedVersion,
                                                                    vaem:previousPublishedVersion,
                                                                    vaem:turtleFileURL
                                                                )
                                                            )
                                                            BIND(REPLACE(STR(?oldLiteral), "/schema/shacl/", "/schema/") AS ?v0)
                                                            BIND(REPLACE(?v0, "DOC_SCHEMA-SHACL-", "DOC_SCHEMA-") AS ?v1)
                                                            BIND(REPLACE(?v1, "SHACL-", "") AS ?v2)
                                                            BIND(REPLACE(?v2, " SHACL ", " ") AS ?v3)
                                                            BIND(REPLACE(?v3, " SHACL", "") AS ?v4)
                                                            BIND(REPLACE(?v4, "SHACL ", "") AS ?v5)
                                                            BIND(REPLACE(?v5, "SHACL", "") AS ?v6)
                                                            BIND(REPLACE(?v6, "  +", " ") AS ?normalizedLex)
                                                            BIND(
                                                                IF(
                                                                    LANG(?oldLiteral) != "",
                                                                    STRLANG(?normalizedLex, LANG(?oldLiteral)),
                                                                    STRDT(?normalizedLex, DATATYPE(?oldLiteral))
                                                                ) AS ?newLiteral
                                                            )
                                                        }
                                                    }
