module Page.RecordTypes.Root exposing (..)

import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (required)
import Page.RecordTypes.Shared exposing (LabelNumericValue, LabelValue, labelValueDecoder)


type alias RootBody =
    { stats : List LabelValue }


frontBodyDecoder : Decoder RootBody
frontBodyDecoder =
    Decode.succeed RootBody
        |> required "stats" (list labelValueDecoder)
