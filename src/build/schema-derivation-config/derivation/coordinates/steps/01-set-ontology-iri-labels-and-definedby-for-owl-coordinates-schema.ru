# owl-coordinates-derive step 01
# Message: Set ontology IRI, labels and definedBy for OWL coordinates schema

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                                    PREFIX sh: <http://www.w3.org/ns/shacl#>

                                                    DELETE {
                                                        GRAPH <work:coordinate:derived> {
                                                            ?oldOntology ?p ?o .
                                                            ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinate> .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:coordinate:derived> {
                                                            <http://qudt.org/$$QUDT_VERSION$$/schema/coordinate> a owl:Ontology ;
                                                                owl:imports <http://www.linkedmodel.org/schema/dtype> ;
                                                                owl:imports <http://www.linkedmodel.org/schema/vaem> ;
                                                                owl:imports <http://www.w3.org/2004/02/skos/core> ;
                                                                owl:versionIRI <http://qudt.org/$$QUDT_VERSION$$/schema/coordinate> ;
                                                                rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/coordinate> ;
                                                                rdfs:label "QUDT SCHEMA - Coordinate Systems" .
                                                            ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/coordinate> .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:coordinate:derived> {
                                                            OPTIONAL {
                                                                ?oldOntology a owl:Ontology ;
                                                                             ?p ?o .
                                                                FILTER(STR(?oldOntology) = "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinate")
                                                                FILTER(
                                                                    ?p != owl:imports
                                                                    && ?p != owl:versionIRI
                                                                    && ?p != rdfs:label
                                                                    && ?p != sh:declare
                                                                )
                                                            }
                                                            OPTIONAL { ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/coordinate> . }
                                                        }
                                                    }
