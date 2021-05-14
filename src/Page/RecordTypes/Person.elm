module Page.RecordTypes.Person exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias PersonBody =
    {}


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
