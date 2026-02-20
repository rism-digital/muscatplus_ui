module Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)

import Json.Decode exposing (Decoder, list, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, externalResourceBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceShared exposing (SourceRecordDescriptors, sourceRecordDescriptorsDecoder)


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , sourceTypes : SourceRecordDescriptors
    , summary : Maybe (List LabelValue)
    , externalResources : Maybe (List ExternalResourceBody)
    }


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    succeed BasicSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> required "sourceTypes" sourceRecordDescriptorsDecoder
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> optional "externalResources" (maybe (list externalResourceBodyDecoder)) Nothing
