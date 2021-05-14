module Page.RecordTypes.Institution exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias InstitutionBody =
    {}


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
