module Page.RecordTypes.Work exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias WorkBody =
    {}


workBodyDecoder : Decoder WorkBody
workBodyDecoder =
    Decode.succeed WorkBody
