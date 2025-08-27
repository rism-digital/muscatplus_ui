module Page.RecordTypes.Holding exposing (BoundWithSectionBody, HoldingBody, HoldingType(..), holdingBodyDecoder)

import Dict
import Json.Decode as Decode exposing (Decoder, list, map, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.DigitalObjects exposing (DigitalObjectsSectionBody, digitalObjectsSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody, basicInstitutionBodyDecoder)
import Page.RecordTypes.PartOf exposing (PartOfSectionBody, partOfSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)


type HoldingType
    = PrintHolding
    | ManuscriptHolding
    | CompositeHolding


type alias BoundWithSectionBody =
    { sectionLabel : LanguageMap
    , source : BasicSourceBody
    }


type alias HoldingBody =
    { id : String
    , sectionToc : String
    , label : LanguageMap
    , holdingType : HoldingType
    , summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , boundWith : Maybe BoundWithSectionBody
    , partOf : Maybe PartOfSectionBody
    , digitalObjects : Maybe DigitalObjectsSectionBody
    , recordHistory : Maybe RecordHistory
    }


holdingBodyDecoder : Decoder HoldingBody
holdingBodyDecoder =
    Decode.succeed HoldingBody
        |> required "id" string
        |> hardcoded "record-holding"
        |> required "label" languageMapLabelDecoder
        |> required "holdingType" holdingTypeDecoder
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalResources" (maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "notes" (maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "boundWith" (maybe boundWithSectionBodyDecoder) Nothing
        |> optional "partOf" (maybe partOfSectionBodyDecoder) Nothing
        |> optional "digitalObjects" (maybe digitalObjectsSectionBodyDecoder) Nothing
        |> optional "recordHistory" (maybe recordHistoryDecoder) Nothing


boundWithSectionBodyDecoder : Decoder BoundWithSectionBody
boundWithSectionBodyDecoder =
    Decode.succeed BoundWithSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


holdingTypeDecoder : Decoder HoldingType
holdingTypeDecoder =
    map holdingTypeFromJsonType string


holdingTypeFromJsonType : String -> HoldingType
holdingTypeFromJsonType jsonType =
    Dict.fromList holdingTypeOptions
        |> Dict.get jsonType
        |> Maybe.withDefault PrintHolding


holdingTypeOptions : List ( String, HoldingType )
holdingTypeOptions =
    [ ( "rism:PrintHolding", PrintHolding )
    , ( "rism:ManuscriptHolding", ManuscriptHolding )
    , ( "rism:CompositeHolding", CompositeHolding )
    ]
