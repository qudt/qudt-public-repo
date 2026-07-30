# owl-schema-derive step 03
# Message: Derive rdfs:range from SHACL property shape class/datatype constraints and node-shape superclasses

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX sh: <http://www.w3.org/ns/shacl#>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    ?path rdfs:range ?rangeClassOrDatatype .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    ?ps a sh:PropertyShape ;
                                                        sh:path ?path .
                                                    FILTER(isIRI(?path))
                                                    {
                                                        ?ps sh:class ?rangeClassOrDatatype .
                                                    } UNION {
                                                        ?ps sh:datatype ?rangeClassOrDatatype .
                                                    } UNION {
                                                        ?ps sh:node ?nodeShape .
                                                        FILTER(isIRI(?nodeShape))
                                                        ?nodeShape rdfs:subClassOf ?rangeClassOrDatatype .
                                                        FILTER(isIRI(?rangeClassOrDatatype))
                                                        FILTER(?rangeClassOrDatatype != rdfs:Resource)
                                                    }
                                                }
                                            }
