module Page.RecordTypes.Institution exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, externalAuthoritiesSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceRelationships exposing (SourceRelationshipsSectionBody, sourceRelationshipsSectionBodyDecoder)


type alias BasicInstitutionBody =
    { id : String
    , label : LanguageMap
    }


type alias InstitutionBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , summary : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , notes : Maybe NotesSectionBody
    , externalAuthorities : Maybe ExternalAuthoritiesSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , location : Maybe LocationSectionBody
    , sources : Maybe SourceRelationshipsSectionBody
    , recordHistory : RecordHistory
    }


type alias LocationSectionBody =
    { label : LanguageMap
    , coordinates : List String
    }


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
        |> hardcoded "institution-record-top"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "notes" (Decode.maybe notesSectionBodyDecoder) Nothing
        |> optional "externalAuthorities" (Decode.maybe externalAuthoritiesSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "location" (Decode.maybe locationSectionBodyDecoder) Nothing
        |> optional "sources" (Decode.maybe sourceRelationshipsSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


basicInstitutionBodyDecoder : Decoder BasicInstitutionBody
basicInstitutionBodyDecoder =
    Decode.succeed BasicInstitutionBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder


locationSectionBodyDecoder : Decoder LocationSectionBody
locationSectionBodyDecoder =
    Decode.succeed LocationSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "coordinates" (list string)
