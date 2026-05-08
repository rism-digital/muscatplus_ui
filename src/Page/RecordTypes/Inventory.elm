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
import Page.RecordTypes.Relationship exposing (RelationshipBody, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)
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
    , inventory : Maybe InventoryInfoBody
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
        |> optional "inventory" (maybe inventoryInfoBodyDecoder) Nothing


inventoryInfoBodyDecoder : Decoder InventoryInfoBody
inventoryInfoBodyDecoder =
    Decode.succeed InventoryInfoBody
        |> optional "inventorySource" (maybe string) Nothing
        |> optional "inventorySection" (maybe string) Nothing
        |> optional "inventoryNumber" (maybe string) Nothing
