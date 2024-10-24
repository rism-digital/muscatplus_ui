module Page.RecordTypes.ExternalRecord exposing (ExternalBiographicalDetailsSectionBody, ExternalInstitutionRecord, ExternalOrganizationDetailsSection, ExternalPersonRecord, ExternalProject(..), ExternalRecord(..), ExternalRecordBody, ExternalRelationshipBody, ExternalRelationshipsSection, ExternalSourceContents, ExternalSourceExemplar, ExternalSourceExemplarsSection, ExternalSourceExternalResource, ExternalSourceExternalResourcesSection, ExternalSourceRecord, ExternalSourceReferencesNotesSection, externalProjectToString, externalRecordBodyDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Relationship exposing (QualifierBody, RelatedToBody, RoleBody, qualifierBodyDecoder, relatedToBodyDecoder, roleBodyDecoder)
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
    , externalResources : Maybe ExternalSourceExternalResourcesSection
    }


type alias ExternalSourceExternalResourcesSection =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExternalSourceExternalResource
    }


type alias ExternalSourceExternalResource =
    { url : String
    , label : LanguageMap
    }


type alias ExternalSourceReferencesNotesSection =
    { sectionToc : String
    , label : LanguageMap
    , notes : Maybe (List LabelValue)
    }


type alias ExternalPersonRecord =
    { id : String
    , label : LanguageMap
    , biographicalDetails : Maybe ExternalBiographicalDetailsSectionBody
    , relationships : Maybe ExternalRelationshipsSection
    }


type alias ExternalBiographicalDetailsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , summary : List LabelValue
    }


type alias ExternalInstitutionRecord =
    { id : String
    , label : LanguageMap
    , organizationDetails : Maybe ExternalOrganizationDetailsSection
    , relationships : Maybe ExternalRelationshipsSection
    }


type alias ExternalRelationshipsSection =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExternalRelationshipBody
    }


type alias ExternalRelationshipBody =
    { role : Maybe RoleBody
    , qualifier : Maybe QualifierBody
    , relatedTo : Maybe RelatedToBody
    , note : Maybe LanguageMap
    }


type alias ExternalOrganizationDetailsSection =
    { sectionToc : String
    , label : LanguageMap
    , summary : List LabelValue
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
        "https://cantusdatabase.org/" ->
            Decode.succeed Cantus

        "https://www.diamm.ac.uk/" ->
            Decode.succeed DIAMM

        _ ->
            Decode.succeed RISM


externalInstitutionBodyDecoder : Decoder ExternalInstitutionRecord
externalInstitutionBodyDecoder =
    Decode.succeed ExternalInstitutionRecord
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "organizationDetails" (Decode.maybe externalOrganizationDetailsSectionDecoder) Nothing
        |> optional "relationships" (Decode.maybe externalRelationshipsSectionDecoder) Nothing


externalRelationshipsSectionDecoder : Decoder ExternalRelationshipsSection
externalRelationshipsSectionDecoder =
    Decode.succeed ExternalRelationshipsSection
        |> hardcoded "external-relationships-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list externalRelationshipBodyDecoder)


externalRelationshipBodyDecoder : Decoder ExternalRelationshipBody
externalRelationshipBodyDecoder =
    Decode.succeed ExternalRelationshipBody
        |> optional "role" (Decode.maybe roleBodyDecoder) Nothing
        |> optional "qualifier" (Decode.maybe qualifierBodyDecoder) Nothing
        |> optional "relatedTo" (Decode.maybe relatedToBodyDecoder) Nothing
        |> optional "note" (Decode.maybe languageMapLabelDecoder) Nothing


externalOrganizationDetailsSectionDecoder : Decoder ExternalOrganizationDetailsSection
externalOrganizationDetailsSectionDecoder =
    Decode.succeed ExternalOrganizationDetailsSection
        |> hardcoded "external-organization-details-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "summary" (list labelValueDecoder)


externalPersonBodyDecoder : Decoder ExternalPersonRecord
externalPersonBodyDecoder =
    Decode.succeed ExternalPersonRecord
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "biographicalDetails" (Decode.maybe biographicalDetailsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe externalRelationshipsSectionDecoder) Nothing


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
        |> optional "externalResources" (Decode.maybe externalSourceExternalResourcesSectionDecoder) Nothing


externalSourceReferencesNotesSectionDecoder : Decoder ExternalSourceReferencesNotesSection
externalSourceReferencesNotesSectionDecoder =
    Decode.succeed ExternalSourceReferencesNotesSection
        |> hardcoded "external-source-references-notes-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing


externalSourceExternalResourcesSectionDecoder : Decoder ExternalSourceExternalResourcesSection
externalSourceExternalResourcesSectionDecoder =
    Decode.succeed ExternalSourceExternalResourcesSection
        |> hardcoded "external-source-external-resources-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list externalSourceExternalResourceDecoder)


externalSourceExternalResourceDecoder : Decoder ExternalSourceExternalResource
externalSourceExternalResourceDecoder =
    Decode.succeed ExternalSourceExternalResource
        |> required "url" string
        |> required "label" languageMapLabelDecoder


biographicalDetailsSectionBodyDecoder : Decoder ExternalBiographicalDetailsSectionBody
biographicalDetailsSectionBodyDecoder =
    Decode.succeed ExternalBiographicalDetailsSectionBody
        |> hardcoded "external-person-biographical-details-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "summary" (list labelValueDecoder)


externalProjectToString : ExternalProject -> String
externalProjectToString proj =
    case proj of
        DIAMM ->
            "DIAMM"

        Cantus ->
            "Cantus"

        RISM ->
            "RISM"
