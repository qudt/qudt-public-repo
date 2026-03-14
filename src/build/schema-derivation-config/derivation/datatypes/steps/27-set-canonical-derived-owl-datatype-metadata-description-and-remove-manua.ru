# owl-datatypes-derive step 27
# Message: Set canonical derived OWL datatype metadata description and remove manual creator field

PREFIX dcterms: <http://purl.org/dc/terms/>
                                                    PREFIX prov: <http://www.w3.org/ns/prov#>
                                                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE dcterms:description ?oldDescription .
                                                            vaem:GMD_SCHEMA-DATATYPE dcterms:creator ?oldCreator .
                                                            vaem:GMD_SCHEMA-DATATYPE prov:derivedFrom ?oldDerivedFrom .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            vaem:GMD_SCHEMA-DATATYPE dcterms:description "<p>This OWL schema is derived from the SHACL schema found at http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype. </p>"^^rdf:HTML .
                                                            vaem:GMD_SCHEMA-DATATYPE prov:derivedFrom <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            OPTIONAL { vaem:GMD_SCHEMA-DATATYPE dcterms:description ?oldDescription . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-DATATYPE dcterms:creator ?oldCreator . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-DATATYPE prov:derivedFrom ?oldDerivedFrom . }
                                                        }
                                                    }
