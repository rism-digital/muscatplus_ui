module Api.DataTypes exposing (RecordType(..), recordTypeFromJsonType, typeDecoder)

import Json.Decode as Decode exposing (Decoder, andThen)


type RecordType
    = Source
    | Person
    | Institution
    | Place
    | Incipit
    | Unknown


typeDecoder : Decoder RecordType
typeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (recordTypeFromJsonType str))


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
