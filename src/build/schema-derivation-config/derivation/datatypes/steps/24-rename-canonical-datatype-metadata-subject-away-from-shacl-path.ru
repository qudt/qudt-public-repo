# owl-datatypes-derive step 24
# Message: Rename canonical datatype metadata subject away from SHACL path

DELETE {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/schema/shacl/datatype/GMD_datatype> ?p ?o .
                                                        }
                                                    }
                                                    INSERT {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/schema/datatype/GMD_datatype> ?p ?o .
                                                        }
                                                    }
                                                    WHERE {
                                                        GRAPH <work:datatype:derived> {
                                                            <http://qudt.org/schema/shacl/datatype/GMD_datatype> ?p ?o .
                                                        }
                                                    }
