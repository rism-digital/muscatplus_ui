module Page.RecordTypes exposing (RecordType(..), recordTypeFromJsonType)


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | CollectionSearchResult
    | Front
    | Unknown


recordTypeFromJsonType : String -> RecordType
recordTypeFromJsonType jsonType =
    List.filter (\( str, _ ) -> str == jsonType) recordTypeOptions
        |> List.head
        |> Maybe.withDefault ( "", Unknown )
        |> Tuple.second


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
