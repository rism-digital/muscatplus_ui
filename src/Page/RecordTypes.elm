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


{-|

    A filter represents a selected filter query; The values are the
    field name and the value, e.g., "Filter type source". This will then
    get converted to a list of URL parameters, `fq=type:source`.

-}
type Filter
    = Filter String String


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
