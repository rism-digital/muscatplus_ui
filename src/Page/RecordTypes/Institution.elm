module Page.RecordTypes.Institution exposing
    ( BasicInstitutionBody
    , CoordinatesSection
    , InstitutionBody
    , LocationAddressSectionBody
    , OrganizationDetailsSectionBody
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
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , coordinates : List Float
    , coordinatesLabel : LanguageMap
    }


type alias OrganizationDetailsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , summary : List LabelValue
    }


type alias InstitutionBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , organizationDetails : Maybe OrganizationDetailsSectionBody
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
    , website : Maybe LabelValue
    , email : Maybe LabelValue
    }


basicInstitutionBodyDecoder : Decoder BasicInstitutionBody
basicInstitutionBodyDecoder =
    Decode.succeed BasicInstitutionBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder


organizationDetailsSectionBodyDecoder : Decoder OrganizationDetailsSectionBody
organizationDetailsSectionBodyDecoder =
    Decode.succeed OrganizationDetailsSectionBody
        |> hardcoded "institution-summary-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "summary" (list labelValueDecoder)


coordinatesSectionDecoder : Decoder CoordinatesSection
coordinatesSectionDecoder =
    Decode.succeed CoordinatesSection
        |> hardcoded "institution-coordinates-section"
        |> required "id" string
        |> required "sectionLabel" languageMapLabelDecoder
        |> requiredAt [ "geometry", "coordinates" ] (list float)
        |> requiredAt [ "geometry", "label" ] languageMapLabelDecoder


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
        |> hardcoded "institution-record-top"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "organizationDetails" (Decode.maybe organizationDetailsSectionBodyDecoder) Nothing
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
        |> optional "website" (Decode.maybe labelValueDecoder) Nothing
        |> optional "email" (Decode.maybe labelValueDecoder) Nothing
