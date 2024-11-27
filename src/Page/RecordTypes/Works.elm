module Page.RecordTypes.Works exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias WorksSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , workReference : Maybe WorkReference
    }


type alias WorkReference =
    { label : LanguageMap
    , value : String
    , searchUrl : String
    , authorityUrl : String
    }


worksSectionBodyDecoder : Decoder WorksSectionBody
worksSectionBodyDecoder =
    Decode.succeed WorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReference" (Decode.maybe workReferenceDecoder) Nothing


workReferenceDecoder : Decoder WorkReference
workReferenceDecoder =
    Decode.succeed WorkReference
        |> required "label" languageMapLabelDecoder
        |> required "value" string
        |> required "search" string
        |> required "url" string
