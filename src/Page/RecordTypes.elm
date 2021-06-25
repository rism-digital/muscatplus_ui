module Page.RecordTypes exposing (..)


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | Festival
    | CollectionSearchResult
    | Root
    | Unknown


recordTypeFromJsonType : String -> RecordType
recordTypeFromJsonType jsonType =
    case jsonType of
        "rism:Source" ->
            Source

        "rism:Person" ->
            Person

        "rism:Institution" ->
            Institution

        "rism:Incipit" ->
            Incipit

        "rism:Place" ->
            Place

        "rism:LiturgicalFestival" ->
            Festival

        "Collection" ->
            CollectionSearchResult

        "rism:Root" ->
            Root

        _ ->
            Unknown
