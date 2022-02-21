module Page.RecordTypes.SourceBasic exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, SourceRecordDescriptors, contentsSectionBodyDecoder, sourceRecordDescriptorsDecoder)


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , record : SourceRecordDescriptors
    , summary : Maybe (List LabelValue)
    , contents : Maybe ContentsSectionBody
    }


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> required "record" sourceRecordDescriptorsDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "contents" (Decode.maybe contentsSectionBodyDecoder) Nothing
