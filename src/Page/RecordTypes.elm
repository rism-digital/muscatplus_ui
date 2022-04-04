module Page.RecordTypes exposing (..)


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | CollectionSearchResult
    | Front
    | Unknown


recordTypeOptions : List ( String, RecordType )
recordTypeOptions =
    [ ( "rism:Source", Source )
    , ( "rism:Person", Person )
    , ( "rism:Institution", Institution )
    , ( "rism:Incipit", Incipit )
    , ( "rism:Place", Place )
    , ( "Collection", CollectionSearchResult )
    , ( "rism:Front", Front )
    ]


recordTypeFromJsonType : String -> RecordType
recordTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) recordTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", Unknown )
        |> Tuple.second
