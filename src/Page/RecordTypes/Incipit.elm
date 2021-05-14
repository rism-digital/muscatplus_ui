module Page.RecordTypes.Incipit exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias IncipitBody =
    {}


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
