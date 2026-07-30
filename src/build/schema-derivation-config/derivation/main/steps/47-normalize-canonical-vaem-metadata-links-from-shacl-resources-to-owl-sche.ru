# owl-schema-derive step 47
# Message: Normalize canonical VAEM metadata links from SHACL resources to OWL schema resources

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>
                                            PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?oldObj .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?newObj .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA ?p ?oldObj .
                                                    FILTER(isIRI(?oldObj))
                                                    FILTER(
                                                        ?p IN (vaem:isMetadataFor, owl:versionIRI)
                                                        && CONTAINS(STR(?oldObj), "/schema/shacl/")
                                                    )
                                                    BIND(IRI(REPLACE(STR(?oldObj), "/schema/shacl/", "/schema/")) AS ?newObj)
                                                }
                                            }
