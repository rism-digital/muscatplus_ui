module Page.RecordTypes.Source exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias FullSourceBody =
    {}


sourceBodyDecoder : Decoder FullSourceBody
sourceBodyDecoder =
    Decode.succeed FullSourceBody
