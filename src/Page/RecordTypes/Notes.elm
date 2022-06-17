module Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)

import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias NotesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , notes : List LabelValue
    }


notesSectionBodyDecoder : Decoder NotesSectionBody
notesSectionBodyDecoder =
    Decode.succeed NotesSectionBody
        |> hardcoded "record-notes-section"
        |> required "label" languageMapLabelDecoder
        |> required "notes" (list labelValueDecoder)
