module Page.RecordTypes.Front exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder, float, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Search exposing (Facets, facetsDecoder)
import Page.RecordTypes.Shared exposing (LabelNumericValue, labelNumericValueDecoder, languageMapLabelDecoder)


type alias FrontBody =
    { facets : Facets
    }


frontBodyDecoder : Decoder FrontBody
frontBodyDecoder =
    Decode.succeed FrontBody
        |> optional "facets" facetsDecoder Dict.empty
