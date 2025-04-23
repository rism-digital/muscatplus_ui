module Page.RecordTypes exposing (RecordType(..), recordTypeFromJsonType)

import Dict


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Holding
    | Incipit
    | CollectionSearchResult
    | Front
    | ExternalRecord
    | Unknown


recordTypeFromJsonType : String -> RecordType
recordTypeFromJsonType jsonType =
    Dict.fromList recordTypeOptions
        |> Dict.get jsonType
        |> Maybe.withDefault Unknown


recordTypeOptions : List ( String, RecordType )
recordTypeOptions =
    [ ( "rism:Source", Source )
    , ( "rism:Person", Person )
    , ( "rism:Institution", Institution )
    , ( "rism:Incipit", Incipit )
    , ( "rism:Place", Place )
    , ( "rism:Holding", Holding )
    , ( "rism:Exemplar", Holding ) -- alias for now.
    , ( "Collection", CollectionSearchResult )
    , ( "rism:Front", Front )
    , ( "rism:ExternalRecord", ExternalRecord )
    ]
