module Page.RecordTypes.Front exposing (..)

import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (required)
import Page.RecordTypes.Shared exposing (LabelNumericValue, LabelValue, labelNumericValueDecoder, labelValueDecoder)


type alias FrontBody =
    { stats : Stats }


type alias Stats =
    { sources : LabelNumericValue }


frontBodyDecoder : Decoder FrontBody
frontBodyDecoder =
    Decode.succeed FrontBody
        |> required "stats" statsDecoder


statsDecoder : Decoder Stats
statsDecoder =
    Decode.succeed Stats
        |> required "sources" labelNumericValueDecoder
