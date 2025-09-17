module Page.RecordTypes.Publication exposing (BasicPublicationBody, PublicationBody, PublicationProperties, WorkCatalogueStatus(..), WorksSectionBody, basicPublicationBodyDecoder, publicationBodyDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, fail, int, list, maybe, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, RelationshipsSectionBody, relatedToBodyDecoder, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelStringValue, LabelValue, RecordHistory, labelStringValueDecoder, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)


type WorkCatalogueStatus
    = Completed LanguageMap
    | Partial LanguageMap
    | Alternate LanguageMap


type alias BasicPublicationBody =
    { id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , composer : Maybe RelatedToBody
    , properties : Maybe PublicationProperties
    , status : WorkCatalogueStatus
    }


type alias PublicationBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , status : LabelStringValue
    , relationships : Maybe RelationshipsSectionBody
    , referencesNotes : Maybe NotesSectionBody
    , works : Maybe WorksSectionBody
    , recordHistory : RecordHistory
    , properties : Maybe PublicationProperties
    }


type alias PublicationProperties =
    { shortTitle : Maybe LanguageMap
    , publicationDates : Maybe LanguageMap
    }


type alias WorksSectionBody =
    { sectionLabel : LanguageMap
    , url : String
    , totalItems : Int
    }


publicationBodyDecoder : Decoder PublicationBody
publicationBodyDecoder =
    Decode.succeed PublicationBody
        |> hardcoded "publication-body"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> required "status" labelStringValueDecoder
        |> optional "relationships" (maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "notes" (maybe notesSectionBodyDecoder) Nothing
        |> optional "works" (maybe worksSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder
        |> optional "properties" (maybe publicationPropertiesDecoder) Nothing


worksSectionBodyDecoder : Decoder WorksSectionBody
worksSectionBodyDecoder =
    Decode.succeed WorksSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "url" string
        |> required "totalItems" int


basicPublicationBodyDecoder : Decoder BasicPublicationBody
basicPublicationBodyDecoder =
    Decode.succeed BasicPublicationBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "composer" (maybe relatedToBodyDecoder) Nothing
        |> optional "properties" (maybe publicationPropertiesDecoder) Nothing
        |> required "status" workCatalogueStatusDecoder


publicationPropertiesDecoder : Decoder PublicationProperties
publicationPropertiesDecoder =
    Decode.succeed PublicationProperties
        |> optional "shortTitle" (maybe languageMapLabelDecoder) Nothing
        |> optional "publicationDates" (maybe languageMapLabelDecoder) Nothing


workCatalogueStatusDecoder : Decoder WorkCatalogueStatus
workCatalogueStatusDecoder =
    labelStringValueDecoder
        |> andThen stringToWorkCatalogueStatus


stringToWorkCatalogueStatus : LabelStringValue -> Decoder WorkCatalogueStatus
stringToWorkCatalogueStatus { label, value } =
    case value of
        "completed" ->
            succeed (Completed label)

        "partial" ->
            succeed (Partial label)

        "alternate" ->
            succeed (Alternate label)

        _ ->
            fail ("Could not determine work catalogue status: " ++ value)
