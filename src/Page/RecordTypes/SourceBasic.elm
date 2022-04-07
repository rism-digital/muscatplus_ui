module Page.RecordTypes.SourceBasic exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceShared exposing (SourceRecordDescriptors, sourceRecordDescriptorsDecoder)


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , record : SourceRecordDescriptors
    , summary : Maybe (List LabelValue)
    }


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> required "record" sourceRecordDescriptorsDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
