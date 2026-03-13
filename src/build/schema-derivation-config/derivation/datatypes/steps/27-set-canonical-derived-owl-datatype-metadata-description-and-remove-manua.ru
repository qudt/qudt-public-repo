# owl-datatypes-derive step 27
# Message: Set canonical derived OWL datatype metadata description and remove manual creator field

PREFIX dcterms: <http://purl.org/dc/terms/>
                                                    PREFIX prov: <http://www.w3.org/ns/prov#>
                                                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

                                                    DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/schema/datatype/GMD_datatype> dcterms:description ?oldDescription .
                                                            <http://qudt.org/schema/datatype/GMD_datatype> dcterms:creator ?oldCreator .
                                                            <http://qudt.org/schema/datatype/GMD_datatype> prov:derivedFrom ?oldDerivedFrom .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/schema/datatype/GMD_datatype> dcterms:description "<p>This OWL schema is derived from the SHACL schema found at http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype. </p>"^^rdf:HTML .
                                                            <http://qudt.org/schema/datatype/GMD_datatype> prov:derivedFrom <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/datatype> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            OPTIONAL { <http://qudt.org/schema/datatype/GMD_datatype> dcterms:description ?oldDescription . }
                                                            OPTIONAL { <http://qudt.org/schema/datatype/GMD_datatype> dcterms:creator ?oldCreator . }
                                                            OPTIONAL { <http://qudt.org/schema/datatype/GMD_datatype> prov:derivedFrom ?oldDerivedFrom . }
                                                        }
                                                    }
