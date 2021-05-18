module Page.RecordTypes.Festival exposing (..)

import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias LiturgicalFestivalBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    }


liturgicalFestivalBodyDecoder : Decoder LiturgicalFestivalBody
liturgicalFestivalBodyDecoder =
    Decode.succeed LiturgicalFestivalBody
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
