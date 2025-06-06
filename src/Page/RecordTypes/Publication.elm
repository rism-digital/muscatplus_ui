module Page.RecordTypes.Publication exposing (..)

import Json.Decode as Decode exposing (Decoder, int, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, RelationshipsSectionBody, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (RecordHistory, languageMapLabelDecoder, recordHistoryDecoder)


type alias PublicationBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
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
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "notes" (Decode.maybe notesSectionBodyDecoder) Nothing
        |> optional "works" (Decode.maybe worksSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


worksSectionBodyDecoder : Decoder WorksSectionBody
worksSectionBodyDecoder =
    Decode.succeed WorksSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "url" string
        |> required "totalItems" int
