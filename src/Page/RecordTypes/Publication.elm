module Page.RecordTypes.Publication exposing (PublicationBasic, PublicationBody, WorksSectionBody, publicationBasicBodyDecoder, publicationBodyDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, RelationshipsSectionBody, relatedToBodyDecoder, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)


type alias PublicationBasic =
    { id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , composer : Maybe RelatedToBody
    }


type alias PublicationBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , referencesNotes : Maybe NotesSectionBody
    , works : Maybe WorksSectionBody
    , recordHistory : RecordHistory
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
        |> optional "relationships" (maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "notes" (maybe notesSectionBodyDecoder) Nothing
        |> optional "works" (maybe worksSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


worksSectionBodyDecoder : Decoder WorksSectionBody
worksSectionBodyDecoder =
    Decode.succeed WorksSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "url" string
        |> required "totalItems" int


publicationBasicBodyDecoder : Decoder PublicationBasic
publicationBasicBodyDecoder =
    Decode.succeed PublicationBasic
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "composer" (maybe relatedToBodyDecoder) Nothing
