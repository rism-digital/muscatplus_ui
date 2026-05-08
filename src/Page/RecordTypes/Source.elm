module Page.RecordTypes.Source exposing
    ( ExemplarsSectionBody
    , FullSourceBody
    , InventoryItemsSectionBody
    , MaterialGroupBody
    , MaterialGroupsSectionBody
    , SourceItemsSectionBody
    , sourceBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.DigitalObjects exposing (DigitalObjectsSectionBody, digitalObjectsSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Holding exposing (HoldingBody, holdingBodyDecoder)
import Page.RecordTypes.Incipit exposing (IncipitsSectionBody, incipitsSectionBodyDecoder)
import Page.RecordTypes.PartOf exposing (PartOfSectionBody, partOfSectionBodyDecoder)
import Page.RecordTypes.ReferencesNotes exposing (ReferencesNotesSectionBody, referencesNotesSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, RelationshipsSectionBody, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, SourceRecordDescriptors, contentsSectionBodyDecoder, sourceRecordDescriptorsDecoder)
import Page.RecordTypes.Work exposing (SourceWorksSectionBody, sourceWorksSectionBodyDecoder)


type alias FullSourceBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , typeLabel : LanguageMap
    , sourceTypes : SourceRecordDescriptors
    , partOf : Maybe PartOfSectionBody
    , contents : Maybe ContentsSectionBody
    , materialGroups : Maybe MaterialGroupsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , incipits : Maybe IncipitsSectionBody
    , referencesNotes : Maybe ReferencesNotesSectionBody
    , exemplars : Maybe ExemplarsSectionBody
    , sourceItems : Maybe SourceItemsSectionBody
    , inventoryItems : Maybe InventoryItemsSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , digitalObjects : Maybe DigitalObjectsSectionBody
    , works : Maybe SourceWorksSectionBody
    , recordHistory : RecordHistory
    }


type alias ExemplarsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List HoldingBody
    }


type alias MaterialGroupBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    }


type alias MaterialGroupsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List MaterialGroupBody
    }


type alias SourceItemsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , url : String
    , totalItems : Int
    , items : Maybe (List BasicSourceBody)
    }


type alias InventoryItemsSectionBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , totalItems : Int
    }


exemplarsSectionBodyDecoder : Decoder ExemplarsSectionBody
exemplarsSectionBodyDecoder =
    Decode.succeed ExemplarsSectionBody
        |> hardcoded "source-record-exemplars-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list holdingBodyDecoder)


materialGroupBodyDecoder : Decoder MaterialGroupBody
materialGroupBodyDecoder =
    Decode.succeed MaterialGroupBody
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing


materialGroupsSectionBodyDecoder : Decoder MaterialGroupsSectionBody
materialGroupsSectionBodyDecoder =
    Decode.succeed MaterialGroupsSectionBody
        |> hardcoded "source-record-material-groups-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list materialGroupBodyDecoder)


sourceBodyDecoder : Decoder FullSourceBody
sourceBodyDecoder =
    Decode.succeed FullSourceBody
        |> hardcoded "source-record-top"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (Decode.maybe relationshipBodyDecoder) Nothing
        |> required "typeLabel" languageMapLabelDecoder
        |> required "sourceTypes" sourceRecordDescriptorsDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "contents" (Decode.maybe contentsSectionBodyDecoder) Nothing
        |> optional "materialGroups" (Decode.maybe materialGroupsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitsSectionBodyDecoder) Nothing
        |> optional "referencesNotes" (Decode.maybe referencesNotesSectionBodyDecoder) Nothing
        |> optional "exemplars" (Decode.maybe exemplarsSectionBodyDecoder) Nothing
        |> optional "sourceItems" (Decode.maybe sourceItemsSectionBodyDecoder) Nothing
        |> optional "inventoryItems" (Decode.maybe inventoryItemsSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "digitalObjects" (Decode.maybe digitalObjectsSectionBodyDecoder) Nothing
        |> optional "works" (Decode.maybe sourceWorksSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


sourceItemsSectionBodyDecoder : Decoder SourceItemsSectionBody
sourceItemsSectionBodyDecoder =
    Decode.succeed SourceItemsSectionBody
        |> hardcoded "source-record-items-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "url" string
        |> required "totalItems" int
        |> optional "items" (Decode.maybe (list basicSourceBodyDecoder)) Nothing


inventoryItemsSectionBodyDecoder : Decoder InventoryItemsSectionBody
inventoryItemsSectionBodyDecoder =
    Decode.succeed InventoryItemsSectionBody
        |> hardcoded "source-record-inventory-items-section"
        |> required "id" string
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "totalItems" int
