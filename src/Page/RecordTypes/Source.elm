module Page.RecordTypes.Source exposing
    ( BoundWithSectionBody
    , ExemplarBody
    , ExemplarsSectionBody
    , FullSourceBody
    , IncipitsSectionBody
    , LiturgicalFestivalsSectionBody
    , MaterialGroupBody
    , MaterialGroupsSectionBody
    , PartOfSectionBody
    , PerformanceLocationsSectionBody
    , ReferencesNotesSectionBody
    , SourceItemsSectionBody
    , partOfSectionBodyDecoder
    , sourceBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.DigitalObjects exposing (DigitalObjectsSectionBody, digitalObjectsSectionBodyDecoder)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody, externalResourcesSectionBodyDecoder)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody, liturgicalFestivalBodyDecoder)
import Page.RecordTypes.Incipit exposing (IncipitBody, incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody, basicInstitutionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, RelationshipsSectionBody, relationshipBodyDecoder, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, SourceRecordDescriptors, contentsSectionBodyDecoder, sourceRecordDescriptorsDecoder)


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
    , externalResources : Maybe ExternalResourcesSectionBody
    , digitalObjects : Maybe DigitalObjectsSectionBody
    , recordHistory : RecordHistory
    }


type alias ExemplarBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , boundWith : Maybe BoundWithSectionBody
    }


type alias ExemplarsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExemplarBody
    }


type alias BoundWithSectionBody =
    { sectionLabel : LanguageMap
    , source : BasicSourceBody
    }


type alias IncipitsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List IncipitBody
    }


type alias LiturgicalFestivalsSectionBody =
    { label : LanguageMap
    , items : List LiturgicalFestivalBody
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


type alias PartOfSectionBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias PerformanceLocationsSectionBody =
    { label : LanguageMap
    , items : List RelationshipBody
    }


type alias ReferencesNotesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , notes : Maybe (List LabelValue)
    , performanceLocations : Maybe PerformanceLocationsSectionBody
    , liturgicalFestivals : Maybe LiturgicalFestivalsSectionBody
    }


type alias SourceItemsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , url : String
    , totalItems : Int
    , items : List BasicSourceBody
    }


exemplarsBodyDecoder : Decoder ExemplarBody
exemplarsBodyDecoder =
    Decode.succeed ExemplarBody
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "boundWith" (Decode.maybe boundWithSectionBodyDecoder) Nothing


exemplarsSectionBodyDecoder : Decoder ExemplarsSectionBody
exemplarsSectionBodyDecoder =
    Decode.succeed ExemplarsSectionBody
        |> hardcoded "source-record-exemplars-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list exemplarsBodyDecoder)


boundWithSectionBodyDecoder : Decoder BoundWithSectionBody
boundWithSectionBodyDecoder =
    Decode.succeed BoundWithSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


incipitsSectionBodyDecoder : Decoder IncipitsSectionBody
incipitsSectionBodyDecoder =
    Decode.succeed IncipitsSectionBody
        |> hardcoded "source-record-incipits-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list incipitBodyDecoder)


liturgicalFestivalsSectionBodyDecoder : Decoder LiturgicalFestivalsSectionBody
liturgicalFestivalsSectionBodyDecoder =
    Decode.succeed LiturgicalFestivalsSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list liturgicalFestivalBodyDecoder)


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


partOfSectionBodyDecoder : Decoder PartOfSectionBody
partOfSectionBodyDecoder =
    Decode.succeed PartOfSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


performanceLocationsSectionBodyDecoder : Decoder PerformanceLocationsSectionBody
performanceLocationsSectionBodyDecoder =
    Decode.succeed PerformanceLocationsSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


referencesNotesSectionBodyDecoder : Decoder ReferencesNotesSectionBody
referencesNotesSectionBodyDecoder =
    Decode.succeed ReferencesNotesSectionBody
        |> hardcoded "source-record-references-notes-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "performanceLocations" (Decode.maybe performanceLocationsSectionBodyDecoder) Nothing
        |> optional "liturgicalFestivals" (Decode.maybe liturgicalFestivalsSectionBodyDecoder) Nothing


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
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "digitalObjects" (Decode.maybe digitalObjectsSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


sourceItemsSectionBodyDecoder : Decoder SourceItemsSectionBody
sourceItemsSectionBodyDecoder =
    Decode.succeed SourceItemsSectionBody
        |> hardcoded "source-record-items-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "url" string
        |> required "totalItems" int
        |> required "items" (list basicSourceBodyDecoder)
