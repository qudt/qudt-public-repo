# Infer qudt:dimensionExponentFor* properties on dimension vector instances
# from the structure of their IRI local names.
#
# Fractional exponents are encoded with "dot" in the IRI local name:
#   L-0dot5  → -0.5 (xsd:decimal)
#   M0dot5   →  0.5 (xsd:decimal)
# Integer exponents (T-1, M1, …) map to xsd:integer.
#
# IRI local-name formats:
#   qkdv:  A{a}E{e}L{l}I{i}M{m}H{h}T{t}D{d}
#
# Matching strategy: IRI namespace prefix, not rdf:type.
#   - qkdv: instances span five type variants (base + four system-specific),
#     and the system-specific subClassOf declarations live in the schema graph,
#     not in the vocabulary graph — so property-path subclass traversal is
#     unavailable here.
#
# Instances already carrying qudt:dimensionExponentForAmountOfSubstance are
# skipped (idempotent — safe to run against a fully-populated qkdv: vocabulary).

PREFIX qudt: <http://qudt.org/schema/qudt/>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>

# ── SI dimension exponents (8 dimensions) ────────────────────────────────────
# Applies to qkdv: instances (http://qudt.org/vocab/dimensionvector/…).

INSERT {
    GRAPH ?g {
        ?dv qudt:dimensionExponentForAmountOfSubstance        ?aExp ;
            qudt:dimensionExponentForElectricCurrent          ?eExp ;
            qudt:dimensionExponentForLength                   ?lExp ;
            qudt:dimensionExponentForLuminousIntensity        ?iExp ;
            qudt:dimensionExponentForMass                     ?mExp ;
            qudt:dimensionExponentForThermodynamicTemperature ?hExp ;
            qudt:dimensionExponentForTime                     ?tExp ;
            qudt:dimensionlessExponent                        ?dExp .
    }
}
WHERE {
    GRAPH ?g {
        ?dv a [] .
        FILTER(
            STRSTARTS(STR(?dv), "http://qudt.org/vocab/dimensionvector/")
        )
        FILTER NOT EXISTS { ?dv qudt:dimensionExponentForAmountOfSubstance ?any . }
    }
    BIND(REPLACE(STR(?dv), "^.*[/#]", "") AS ?local)

    BIND(REPLACE(?local, "^.*A(-?[0-9]+(?:dot[0-9]+)?)E.*$",          "$1") AS ?aRaw)
    BIND(REPLACE(?local, "^.*E(-?[0-9]+(?:dot[0-9]+)?)L.*$",          "$1") AS ?eRaw)
    BIND(REPLACE(?local, "^.*L(-?[0-9]+(?:dot[0-9]+)?)I.*$",          "$1") AS ?lRaw)
    BIND(REPLACE(?local, "^.*I(-?[0-9]+(?:dot[0-9]+)?)M.*$",          "$1") AS ?iRaw)
    BIND(REPLACE(?local, "^.*M(-?[0-9]+(?:dot[0-9]+)?)H.*$",          "$1") AS ?mRaw)
    BIND(REPLACE(?local, "^.*H(-?[0-9]+(?:dot[0-9]+)?)T.*$",          "$1") AS ?hRaw)
    # T is followed by D in qkdv: IRIs
    BIND(REPLACE(?local, "^.*T(-?[0-9]+(?:dot[0-9]+)?)D.*$",          "$1") AS ?tRaw)
    # D is last in qkdv: IRIs
    BIND(REPLACE(?local, "^.*D(-?[0-9]+(?:dot[0-9]+)?)$",             "$1") AS ?dRaw)

    BIND(IF(CONTAINS(?aRaw,"dot"), xsd:decimal(REPLACE(?aRaw,"dot",".")), xsd:integer(?aRaw)) AS ?aExp)
    BIND(IF(CONTAINS(?eRaw,"dot"), xsd:decimal(REPLACE(?eRaw,"dot",".")), xsd:integer(?eRaw)) AS ?eExp)
    BIND(IF(CONTAINS(?lRaw,"dot"), xsd:decimal(REPLACE(?lRaw,"dot",".")), xsd:integer(?lRaw)) AS ?lExp)
    BIND(IF(CONTAINS(?iRaw,"dot"), xsd:decimal(REPLACE(?iRaw,"dot",".")), xsd:integer(?iRaw)) AS ?iExp)
    BIND(IF(CONTAINS(?mRaw,"dot"), xsd:decimal(REPLACE(?mRaw,"dot",".")), xsd:integer(?mRaw)) AS ?mExp)
    BIND(IF(CONTAINS(?hRaw,"dot"), xsd:decimal(REPLACE(?hRaw,"dot",".")), xsd:integer(?hRaw)) AS ?hExp)
    BIND(IF(CONTAINS(?tRaw,"dot"), xsd:decimal(REPLACE(?tRaw,"dot",".")), xsd:integer(?tRaw)) AS ?tExp)
    BIND(IF(CONTAINS(?dRaw,"dot"), xsd:decimal(REPLACE(?dRaw,"dot",".")), xsd:integer(?dRaw)) AS ?dExp)
}
