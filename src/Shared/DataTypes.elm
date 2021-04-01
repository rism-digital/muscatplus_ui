module Shared.DataTypes exposing (..)

import Shared.Language exposing (LanguageMap)


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | Unknown


type alias LabelValue =
    { label : LanguageMap
    , value : LanguageMap
    }


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

        _ ->
            Unknown