module Page.RecordTypes.ExternalRecord exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias ExternalSourceRecord =
    { id : String
    , label : LanguageMap
    , contents : Maybe ExternalSourceContents
    , exemplars : Maybe ExternalSourceExemplarsSection
    , referencesNotes : Maybe ExternalSourceReferencesNotesSection
    }


type alias ExternalSourceContents =
    { sectionToc : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    }


type alias ExternalSourceExemplarsSection =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExternalSourceExemplar
    }


type alias ExternalSourceExemplar =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , heldBy : ExternalInstitutionRecord
    }


type alias ExternalSourceReferencesNotesSection =
    { sectionToc : String
    , label : LanguageMap
    , notes : Maybe (List LabelValue)
    }


type alias ExternalPersonRecord =
    {}


type alias ExternalInstitutionRecord =
    { id : String
    , label : LanguageMap
    }


type ExternalRecord
    = ExternalSource ExternalSourceRecord
    | ExternalPerson ExternalPersonRecord
    | ExternalInstitution ExternalInstitutionRecord


type ExternalProject
    = DIAMM
    | Cantus
    | RISM -- used as a default value


type alias ExternalRecordBody =
    { id : String
    , record : ExternalRecord
    , project : ExternalProject
    }


externalRecordBodyDecoder : Decoder ExternalRecordBody
externalRecordBodyDecoder =
    Decode.succeed ExternalRecordBody
        |> required "id" string
        |> required "record"
            (Decode.field "type" string
                |> andThen externalRecordDecoder
            )
        |> required "project"
            (string
                |> andThen externalProjectDecoder
            )


externalRecordDecoder : String -> Decoder ExternalRecord
externalRecordDecoder recordType =
    case recordType of
        "rism:Institution" ->
            Decode.map ExternalInstitution externalInstitutionBodyDecoder

        "rism:Person" ->
            Decode.map ExternalPerson externalPersonBodyDecoder

        "rism:Source" ->
            Decode.map ExternalSource externalSourceBodyDecoder

        _ ->
            Decode.fail "Could not decode the external record body"


externalProjectDecoder : String -> Decoder ExternalProject
externalProjectDecoder extProj =
    case extProj of
        "https://www.diamm.ac.uk/" ->
            Decode.succeed DIAMM

        "https://cantusdatabase.org/" ->
            Decode.succeed Cantus

        _ ->
            Decode.succeed RISM


externalInstitutionBodyDecoder : Decoder ExternalInstitutionRecord
externalInstitutionBodyDecoder =
    Decode.succeed ExternalInstitutionRecord
        |> required "id" string
        |> required "label" languageMapLabelDecoder


externalPersonBodyDecoder : Decoder ExternalPersonRecord
externalPersonBodyDecoder =
    Decode.succeed ExternalPersonRecord


externalSourceBodyDecoder : Decoder ExternalSourceRecord
externalSourceBodyDecoder =
    Decode.succeed ExternalSourceRecord
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "contents" (Decode.maybe externalSourceContentsDecoder) Nothing
        |> optional "exemplars" (Decode.maybe externalSourceExemplarsSectionDecoder) Nothing
        |> optional "referencesNotes" (Decode.maybe externalSourceReferencesNotesSectionDecoder) Nothing


externalSourceExemplarsSectionDecoder : Decoder ExternalSourceExemplarsSection
externalSourceExemplarsSectionDecoder =
    Decode.succeed ExternalSourceExemplarsSection
        |> hardcoded "external-source-exemplars-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list externalSourceExemplarDecoder)


externalSourceContentsDecoder : Decoder ExternalSourceContents
externalSourceContentsDecoder =
    Decode.succeed ExternalSourceContents
        |> hardcoded "external-source-contents-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing


externalSourceExemplarDecoder : Decoder ExternalSourceExemplar
externalSourceExemplarDecoder =
    Decode.succeed ExternalSourceExemplar
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" externalInstitutionBodyDecoder


externalSourceReferencesNotesSectionDecoder : Decoder ExternalSourceReferencesNotesSection
externalSourceReferencesNotesSectionDecoder =
    Decode.succeed ExternalSourceReferencesNotesSection
        |> hardcoded "external-source-references-notes-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing