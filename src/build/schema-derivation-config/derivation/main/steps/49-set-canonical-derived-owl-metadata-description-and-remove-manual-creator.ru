# owl-schema-derive step 49
# Message: Set canonical derived OWL metadata description and remove manual creator field

PREFIX dcterms: <http://purl.org/dc/terms/>
                                            PREFIX prov: <http://www.w3.org/ns/prov#>
                                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA dcterms:description ?oldDescription .
                                                    vaem:GMD_QUDT-SCHEMA dcterms:creator ?oldCreator .
                                                    vaem:GMD_QUDT-SCHEMA prov:derivedFrom ?oldDerivedFrom .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    vaem:GMD_QUDT-SCHEMA dcterms:description "<p>This OWL schema is derived from the SHACL schema found at http://qudt.org/$$QUDT_VERSION$$/schema/shacl/qudt. </p>"^^rdf:HTML .
                                                    vaem:GMD_QUDT-SCHEMA prov:derivedFrom <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/qudt> .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    OPTIONAL { vaem:GMD_QUDT-SCHEMA dcterms:description ?oldDescription . }
                                                    OPTIONAL { vaem:GMD_QUDT-SCHEMA dcterms:creator ?oldCreator . }
                                                    OPTIONAL { vaem:GMD_QUDT-SCHEMA prov:derivedFrom ?oldDerivedFrom . }
                                                }
                                            }
