module Page.RecordTypes.ReferencesNotes exposing (LiturgicalFestivalsSectionBody, PerformanceLocationsSectionBody, ReferencesNotesSectionBody, referencesNotesSectionBodyDecoder)

import Json.Decode exposing (Decoder, list, maybe, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody, liturgicalFestivalBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias PerformanceLocationsSectionBody =
    { label : LanguageMap
    , items : List RelationshipBody
    }


type alias ReferencesNotesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , notes : Maybe (List LabelValue)
    , performanceLocations : Maybe PerformanceLocationsSectionBody
    , liturgicalFestivals : Maybe LiturgicalFestivalsSectionBody
    }


type alias LiturgicalFestivalsSectionBody =
    { label : LanguageMap
    , items : List LiturgicalFestivalBody
    }


liturgicalFestivalsSectionBodyDecoder : Decoder LiturgicalFestivalsSectionBody
liturgicalFestivalsSectionBodyDecoder =
    succeed LiturgicalFestivalsSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list liturgicalFestivalBodyDecoder)


performanceLocationsSectionBodyDecoder : Decoder PerformanceLocationsSectionBody
performanceLocationsSectionBodyDecoder =
    succeed PerformanceLocationsSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


referencesNotesSectionBodyDecoder : Decoder ReferencesNotesSectionBody
referencesNotesSectionBodyDecoder =
    succeed ReferencesNotesSectionBody
        |> hardcoded "source-record-references-notes-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "notes" (maybe (list labelValueDecoder)) Nothing
        |> optional "performanceLocations" (maybe performanceLocationsSectionBodyDecoder) Nothing
        |> optional "liturgicalFestivals" (maybe liturgicalFestivalsSectionBodyDecoder) Nothing
