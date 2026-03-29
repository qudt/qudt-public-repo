# owl-coordinates-derive step 27
# Message: Set canonical derived OWL coordinates metadata description and remove manual creator field

PREFIX dcterms: <http://purl.org/dc/terms/>
                                                    PREFIX prov: <http://www.w3.org/ns/prov#>
                                                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                                                    PREFIX vaem: <http://www.linkedmodel.org/schema/vaem#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES dcterms:description ?oldDescription .
                                                            vaem:GMD_SCHEMA-COORDINATES dcterms:creator ?oldCreator .
                                                            vaem:GMD_SCHEMA-COORDINATES prov:derivedFrom ?oldDerivedFrom .
                                                            vaem:GMD_SCHEMA-COORDINATES dcterms:subject ?oldSubject .
                                                            vaem:GMD_SCHEMA-COORDINATES rdfs:label ?oldLabel .
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:graphTitle ?oldGraphTitle .
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:title ?oldTitle .
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:latestPublishedVersion ?oldLatestPublishedVersion .
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:previousPublishedVersion ?oldPreviousPublishedVersion .
                                                            vaem:GMD_SCHEMA-COORDINATES vaem:turtleFileURL ?oldTurtleFileURL .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            vaem:GMD_SCHEMA-COORDINATES
                                                                dcterms:description "<p>This OWL schema is derived from the SHACL schema found at http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinatesystems. </p>"^^rdf:HTML ;
                                                                dcterms:subject "Coordinate Systems" ;
                                                                rdfs:label "QUDT Schema for Coordinate Systems - Version $$QUDT_VERSION$$" ;
                                                                vaem:graphTitle "QUDT Schema for Coordinate Systems - Version $$QUDT_VERSION$$" ;
                                                                vaem:title "QUDT Schema for Coordinate Systems - Version $$QUDT_VERSION$$" ;
                                                                vaem:latestPublishedVersion "https://qudt.org/doc/$$CURRENT_YEAR$$/$$CURRENT_MONTH$$/DOC_SCHEMA-COORDINATES.html"^^xsd:anyURI ;
                                                                vaem:previousPublishedVersion "https://qudt.org/doc/$$QUDT_PREV_RELEASE_YEAR$$/$$QUDT_PREV_RELEASE_MONTH$$/DOC_SCHEMA-COORDINATES.html"^^xsd:anyURI ;
                                                                vaem:turtleFileURL "http://qudt.org/$$QUDT_VERSION$$/schema/coordinatesystems.ttl"^^xsd:anyURI .
                                                            vaem:GMD_SCHEMA-COORDINATES prov:derivedFrom <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinatesystems> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES dcterms:description ?oldDescription . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES dcterms:creator ?oldCreator . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES prov:derivedFrom ?oldDerivedFrom . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES dcterms:subject ?oldSubject . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES rdfs:label ?oldLabel . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:graphTitle ?oldGraphTitle . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:title ?oldTitle . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:latestPublishedVersion ?oldLatestPublishedVersion . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:previousPublishedVersion ?oldPreviousPublishedVersion . }
                                                            OPTIONAL { vaem:GMD_SCHEMA-COORDINATES vaem:turtleFileURL ?oldTurtleFileURL . }
                                                        }
                                                    }
