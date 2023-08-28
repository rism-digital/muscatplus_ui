module Page.RecordTypes.Institution exposing
    ( BasicInstitutionBody
    , CoordinatesSection
    , InstitutionBody
    , LocationAddressSectionBody
    , basicInstitutionBodyDecoder
    , institutionBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, float, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required, requiredAt)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, externalAuthoritiesSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelStringValue, LabelValue, RecordHistory, labelStringValueDecoder, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceRelationships exposing (SourceRelationshipsSectionBody, sourceRelationshipsSectionBodyDecoder)


type alias BasicInstitutionBody =
    { id : String
    , label : LanguageMap
    }


type alias CoordinatesSection =
    { id : String
    , label : LanguageMap
    , coordinates : List Float
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
    , location : Maybe LocationAddressSectionBody
    , sources : Maybe SourceRelationshipsSectionBody
    , recordHistory : RecordHistory
    }


type alias LocationAddressSectionBody =
    { label : LanguageMap
    , mailingAddress : Maybe (List LabelValue)
    , coordinates : Maybe CoordinatesSection
    , website : Maybe LabelStringValue
    , email : Maybe LabelStringValue
    }


basicInstitutionBodyDecoder : Decoder BasicInstitutionBody
basicInstitutionBodyDecoder =
    Decode.succeed BasicInstitutionBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder


coordinatesSectionDecoder : Decoder CoordinatesSection
coordinatesSectionDecoder =
    Decode.succeed CoordinatesSection
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> requiredAt [ "geometry", "coordinates" ] (list float)


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
        |> optional "location" (Decode.maybe locationAddressSectionBodyDecoder) Nothing
        |> optional "sources" (Decode.maybe sourceRelationshipsSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


locationAddressSectionBodyDecoder : Decoder LocationAddressSectionBody
locationAddressSectionBodyDecoder =
    Decode.succeed LocationAddressSectionBody
        |> required "label" languageMapLabelDecoder
        |> optional "mailingAddress" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "coordinates" (Decode.maybe coordinatesSectionDecoder) Nothing
        |> optional "website" (Decode.maybe labelStringValueDecoder) Nothing
        |> optional "email" (Decode.maybe labelStringValueDecoder) Nothing
