# owl-datatypes-derive step 25
# Message: Normalize canonical datatype metadata links from SHACL resources to OWL schema resources

PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>
                                                    PREFIX owl: <http://www.w3.org/2002/07/owl#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE ?p ?oldObj .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE ?p ?newObj .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE ?p ?oldObj .
                                                            FILTER(isIRI(?oldObj))
                                                            FILTER(
                                                                ?p IN (vaem:isMetadataFor, owl:versionIRI)
                                                                && CONTAINS(STR(?oldObj), "/schema/shacl/")
                                                            )
                                                            BIND(IRI(REPLACE(STR(?oldObj), "/schema/shacl/", "/schema/")) AS ?newObj)
                                                        }
                                                    }
