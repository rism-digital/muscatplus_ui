module Page.RecordTypes.Inventory exposing
    ( InventoryInfoBody
    , InventoryItemBody
    , InventoryItemSummary
    , InventoryItemsBody
    , inventoryItemBodyDecoder
    , inventoryItemsBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, list, maybe, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.ReferencesNotes exposing (ReferencesNotesSectionBody, referencesNotesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, RelationshipsSectionBody, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (RecordHistory, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, contentsSectionBodyDecoder)


type alias InventoryItemsBody =
    { id : String
    , sectionLabel : LanguageMap
    , items : List InventoryItemSummary
    }


type alias InventoryItemSummary =
    { id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , inventory : Maybe InventoryInfoBody
    }


type alias InventoryInfoBody =
    { source : Maybe String
    , section : Maybe String
    , number : Maybe String
    }


type alias InventoryItemBody =
    { id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , contents : Maybe ContentsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , referencesNotes : Maybe ReferencesNotesSectionBody
    , inventory : Maybe InventoryInfoBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , recordHistory : RecordHistory
    }


inventoryItemsBodyDecoder : Decoder InventoryItemsBody
inventoryItemsBodyDecoder =
    Decode.succeed InventoryItemsBody
        |> required "id" string
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list inventoryItemSummaryDecoder)


inventoryItemSummaryDecoder : Decoder InventoryItemSummary
inventoryItemSummaryDecoder =
    Decode.succeed InventoryItemSummary
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "inventory" (maybe inventoryInfoBodyDecoder) Nothing


inventoryItemBodyDecoder : Decoder InventoryItemBody
inventoryItemBodyDecoder =
    Decode.succeed InventoryItemBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "contents" (maybe contentsSectionBodyDecoder) Nothing
        |> optional "relationships" (maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "referencesNotes" (maybe referencesNotesSectionBodyDecoder) Nothing
        |> optional "inventory" (maybe inventoryInfoBodyDecoder) Nothing
        |> optional "externalResources" (maybe externalResourcesSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


inventoryInfoBodyDecoder : Decoder InventoryInfoBody
inventoryInfoBodyDecoder =
    Decode.succeed InventoryInfoBody
        |> optional "inventorySource" (maybe string) Nothing
        |> optional "inventorySection" (maybe string) Nothing
        |> optional "inventoryNumber" (maybe string) Nothing
