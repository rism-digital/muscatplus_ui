module Shared.DataTypes exposing (..)

import Shared.Language exposing (LanguageMap)


type alias Flags =
    { locale : String
    , windowWidth : Int
    , windowHeight : Int
    }


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | Festival
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

        "rism:LiturgicalFestival" ->
            Festival

        _ ->
            Unknown
