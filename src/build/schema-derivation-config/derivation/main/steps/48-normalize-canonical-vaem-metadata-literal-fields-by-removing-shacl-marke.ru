# owl-schema-derive step 48
# Message: Normalize canonical VAEM metadata literal fields by removing SHACL markers and shacl path segments

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?oldLiteral .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?newLiteral .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?oldLiteral .
                                                    FILTER(isLiteral(?oldLiteral))
                                                    FILTER(
                                                        ?p IN (
                                                            <http://www.w3.org/2000/01/rdf-schema#label>,
                                                            <http://purl.org/dc/terms/title>,
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
