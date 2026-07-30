# owl-schema-derive step 52
# Message: Derive compatibility ranges for core unconstrained properties

PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                                            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                                            PREFIX qudt: <http://qudt.org/schema/qudt/>

                                            INSERT {
                                                GRAPH <work:schema:derived> {
                                                    qudt:figure rdfs:range qudt:Figure .
                                                    qudt:hasQuantity rdfs:range qudt:Quantity .
                                                    qudt:plainTextDescription rdfs:range rdfs:Literal .
                                                    qudt:wikidataMatch rdfs:range xsd:anyURI .
                                                }
                                            }
                                            WHERE {
                                                GRAPH <work:schema:derived> {
                                                    FILTER EXISTS { qudt:figure ?p1 ?o1 . }
                                                    FILTER EXISTS { qudt:hasQuantity ?p2 ?o2 . }
                                                    FILTER EXISTS { qudt:plainTextDescription ?p3 ?o3 . }
                                                    FILTER EXISTS { qudt:wikidataMatch ?p4 ?o4 . }
                                                }
                                            }
