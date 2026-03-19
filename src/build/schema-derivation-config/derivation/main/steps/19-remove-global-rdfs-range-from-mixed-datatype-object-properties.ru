# owl-schema-derive step 19
# Message: Remove global rdfs:range from mixed datatype/object properties

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

                                            DELETE {
                                                GRAPH <work:schema:derived> {
                                                    ?p rdfs:range ?range .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?p a rdf:Property ;
                                                       rdfs:range ?range .
                                                    FILTER NOT EXISTS { ?p a <http://www.w3.org/2002/07/owl#ObjectProperty> . }
                                                    FILTER NOT EXISTS { ?p a <http://www.w3.org/2002/07/owl#DatatypeProperty> . }
                                                }
                                            }
