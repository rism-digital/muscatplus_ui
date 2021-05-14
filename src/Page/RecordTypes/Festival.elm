module Page.RecordTypes.Festival exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias FestivalBody =
    {}


festivalBodyDecoder : Decoder FestivalBody
festivalBodyDecoder =
    Decode.succeed FestivalBody
