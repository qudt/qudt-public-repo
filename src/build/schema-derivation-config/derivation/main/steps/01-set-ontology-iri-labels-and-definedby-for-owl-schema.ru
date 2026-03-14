# owl-schema-derive step 01
# Message: Set ontology IRI, labels and definedBy for OWL schema

PREFIX owl: <http://www.w3.org/2002/07/owl#>
                                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?oldOntology ?p ?o .
                                                    ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/qudt> .
                                                }
                                            }
                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> a owl:Ontology ;
                                                        owl:imports <http://www.linkedmodel.org/schema/dtype> ;
                                                        owl:imports <http://www.linkedmodel.org/schema/vaem> ;
                                                        owl:imports <http://www.w3.org/2004/02/skos/core> ;
                                                        owl:versionIRI <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> ;
                                                        rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> ;
                                                        rdfs:label "QUDT Schema - Version $$QUDT_VERSION$$" .
                                                    ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/qudt> .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?oldOntology a owl:Ontology .
                                                    ?oldOntology ?p ?o .
                                                    FILTER(STR(?oldOntology) = "http://qudt.org/$$QUDT_VERSION$$/schema/shacl/qudt")
                                                    FILTER(
                                                        ?p != owl:imports
                                                        && ?p != owl:versionIRI
                                                        && ?p != rdfs:label
                                                        && ?p != sh:declare
                                                    )
                                                    OPTIONAL { ?s rdfs:isDefinedBy <http://qudt.org/$$QUDT_VERSION$$/schema/shacl/qudt> . }
                                                }
                                            }
