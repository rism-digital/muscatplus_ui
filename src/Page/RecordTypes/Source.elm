module Page.RecordTypes.Source exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
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
    , record : SourceRecordDescriptors
    , partOf : Maybe PartOfSectionBody
    , contents : Maybe ContentsSectionBody
    , materialGroups : Maybe MaterialGroupsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , incipits : Maybe IncipitsSectionBody
    , referencesNotes : Maybe ReferencesNotesSectionBody
    , exemplars : Maybe ExemplarsSectionBody
    , sourceItems : Maybe SourceItemsSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , recordHistory : RecordHistory
    }


type alias PartOfSectionBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias MaterialGroupsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List MaterialGroupBody
    }


type alias MaterialGroupBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    }


type alias IncipitsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List IncipitBody
    }


type alias ReferencesNotesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , notes : Maybe (List LabelValue)
    , performanceLocations : Maybe PerformanceLocationsSectionBody
    , liturgicalFestivals : Maybe LiturgicalFestivalsSectionBody
    }


type alias PerformanceLocationsSectionBody =
    { label : LanguageMap
    , items : List RelationshipBody
    }


type alias LiturgicalFestivalsSectionBody =
    { label : LanguageMap
    , items : List LiturgicalFestivalBody
    }


type alias ExemplarsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExemplarBody
    }


type alias ExemplarBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalResources : Maybe ExternalResourcesSectionBody
    , notes : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    }


type alias SourceItemsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List BasicSourceBody
    }


sourceBodyDecoder : Decoder FullSourceBody
sourceBodyDecoder =
    Decode.succeed FullSourceBody
        |> hardcoded "source-record-top"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (Decode.maybe relationshipBodyDecoder) Nothing
        |> required "typeLabel" languageMapLabelDecoder
        |> required "record" sourceRecordDescriptorsDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "contents" (Decode.maybe contentsSectionBodyDecoder) Nothing
        |> optional "materialGroups" (Decode.maybe materialGroupsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitsSectionBodyDecoder) Nothing
        |> optional "referencesNotes" (Decode.maybe referencesNotesSectionBodyDecoder) Nothing
        |> optional "exemplars" (Decode.maybe exemplarsSectionBodyDecoder) Nothing
        |> optional "sourceItems" (Decode.maybe sourceItemsSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


partOfSectionBodyDecoder : Decoder PartOfSectionBody
partOfSectionBodyDecoder =
    Decode.succeed PartOfSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


materialGroupsSectionBodyDecoder : Decoder MaterialGroupsSectionBody
materialGroupsSectionBodyDecoder =
    Decode.succeed MaterialGroupsSectionBody
        |> hardcoded "source-record-material-groups-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list materialGroupBodyDecoder)


materialGroupBodyDecoder : Decoder MaterialGroupBody
materialGroupBodyDecoder =
    Decode.succeed MaterialGroupBody
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing


incipitsSectionBodyDecoder : Decoder IncipitsSectionBody
incipitsSectionBodyDecoder =
    Decode.succeed IncipitsSectionBody
        |> hardcoded "source-record-incipits-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list incipitBodyDecoder)


referencesNotesSectionBodyDecoder : Decoder ReferencesNotesSectionBody
referencesNotesSectionBodyDecoder =
    Decode.succeed ReferencesNotesSectionBody
        |> hardcoded "source-record-references-notes-section"
        |> required "label" languageMapLabelDecoder
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "performanceLocations" (Decode.maybe performanceLocationsSectionBodyDecoder) Nothing
        |> optional "liturgicalFestivals" (Decode.maybe liturgicalFestivalsSectionBodyDecoder) Nothing


performanceLocationsSectionBodyDecoder : Decoder PerformanceLocationsSectionBody
performanceLocationsSectionBodyDecoder =
    Decode.succeed PerformanceLocationsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


liturgicalFestivalsSectionBodyDecoder : Decoder LiturgicalFestivalsSectionBody
liturgicalFestivalsSectionBodyDecoder =
    Decode.succeed LiturgicalFestivalsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list liturgicalFestivalBodyDecoder)


exemplarsSectionBodyDecoder : Decoder ExemplarsSectionBody
exemplarsSectionBodyDecoder =
    Decode.succeed ExemplarsSectionBody
        |> hardcoded "source-record-exemplars-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list exemplarsBodyDecoder)


exemplarsBodyDecoder : Decoder ExemplarBody
exemplarsBodyDecoder =
    Decode.succeed ExemplarBody
        --|> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing
        |> optional "notes" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing


sourceItemsSectionBodyDecoder : Decoder SourceItemsSectionBody
sourceItemsSectionBodyDecoder =
    Decode.succeed SourceItemsSectionBody
        |> hardcoded "source-record-items-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list basicSourceBodyDecoder)
