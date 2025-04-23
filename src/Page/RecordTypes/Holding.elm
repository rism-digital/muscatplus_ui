module Page.RecordTypes.Holding exposing (BoundWithSectionBody, HoldingBody, HoldingParentSourceBody, holdingBodyDecoder)

import Json.Decode as Decode exposing (Decoder, list, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody, basicInstitutionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)


type alias HoldingParentSourceBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias BoundWithSectionBody =
    { sectionLabel : LanguageMap
    , source : BasicSourceBody
    }


type alias HoldingBody =
    { id : String
    , sectionToc : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , boundWith : Maybe BoundWithSectionBody
    , partOf : Maybe HoldingParentSourceBody
    , recordHistory : Maybe RecordHistory
    }


holdingBodyDecoder : Decoder HoldingBody
holdingBodyDecoder =
    Decode.succeed HoldingBody
        |> required "id" string
        |> hardcoded "record-holding"
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalResources" (maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "notes" (maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "boundWith" (maybe boundWithSectionBodyDecoder) Nothing
        |> optional "partOf" (maybe holdingParentSourceBodyDecoder) Nothing
        |> optional "recordHistory" (maybe recordHistoryDecoder) Nothing


boundWithSectionBodyDecoder : Decoder BoundWithSectionBody
boundWithSectionBodyDecoder =
    Decode.succeed BoundWithSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


holdingParentSourceBodyDecoder : Decoder HoldingParentSourceBody
holdingParentSourceBodyDecoder =
    Decode.succeed HoldingParentSourceBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder
