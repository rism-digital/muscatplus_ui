module Page.RecordTypes.Person exposing
    ( NameVariantsSectionBody
    , PersonBody
    , nameVariantsSectionBodyDecoder
    , personBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, externalAuthoritiesSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Notes exposing (NotesSectionBody, notesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceRelationships exposing (SourceRelationshipsSectionBody, sourceRelationshipsSectionBodyDecoder)


type alias NameVariantsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List LabelValue
    }


type alias PersonBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , summary : Maybe (List LabelValue)
    , nameVariants : Maybe NameVariantsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , notes : Maybe NotesSectionBody
    , externalAuthorities : Maybe ExternalAuthoritiesSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , sources : Maybe SourceRelationshipsSectionBody
    , recordHistory : RecordHistory
    }


nameVariantsSectionBodyDecoder : Decoder NameVariantsSectionBody
nameVariantsSectionBodyDecoder =
    Decode.succeed NameVariantsSectionBody
        |> hardcoded "person-name-variants-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list labelValueDecoder)


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
        |> hardcoded "person-record-top"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "nameVariants" (Decode.maybe nameVariantsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "notes" (Decode.maybe notesSectionBodyDecoder) Nothing
        |> optional "externalAuthorities" (Decode.maybe externalAuthoritiesSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "sources" (Decode.maybe sourceRelationshipsSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder
