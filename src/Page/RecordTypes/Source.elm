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


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , summary : Maybe (List LabelValue)
    }


type alias FullSourceBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , partOf : Maybe PartOfSectionBody
    , contents : Maybe ContentsSectionBody
    , materialGroups : Maybe MaterialGroupsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , incipits : Maybe IncipitsSectionBody
    , referencesNotes : Maybe ReferencesNotesSectionBody
    , exemplars : Maybe ExemplarsSectionBody
    , items : Maybe SourceItemsSectionBody
    , recordHistory : RecordHistory
    }


type alias PartOfSectionBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias ContentsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , subjects : Maybe SubjectsSectionBody
    }


type alias SubjectsSectionBody =
    { label : LanguageMap
    , items : List Subject
    }


type alias Subject =
    { id : String
    , term : LanguageMap
    }


type alias MaterialGroupsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List MaterialGroupBody
    }


type alias MaterialGroupBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
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
    { summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalResources : Maybe ExternalResourcesSectionBody
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
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "contents" (Decode.maybe contentsSectionBodyDecoder) Nothing
        |> optional "materialGroups" (Decode.maybe materialGroupsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitsSectionBodyDecoder) Nothing
        |> optional "referencesNotes" (Decode.maybe referencesNotesSectionBodyDecoder) Nothing
        |> optional "exemplars" (Decode.maybe exemplarsSectionBodyDecoder) Nothing
        |> optional "items" (Decode.maybe sourceItemsSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing


partOfSectionBodyDecoder : Decoder PartOfSectionBody
partOfSectionBodyDecoder =
    Decode.succeed PartOfSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


contentsSectionBodyDecoder : Decoder ContentsSectionBody
contentsSectionBodyDecoder =
    Decode.succeed ContentsSectionBody
        |> hardcoded "source-record-contents-section"
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (Decode.maybe relationshipBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "subjects" (Decode.maybe sourceSubjectsBodyDecoder) Nothing


sourceSubjectsBodyDecoder : Decoder SubjectsSectionBody
sourceSubjectsBodyDecoder =
    Decode.succeed SubjectsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list sourceSubjectDecoder)


sourceSubjectDecoder : Decoder Subject
sourceSubjectDecoder =
    Decode.succeed Subject
        |> required "id" string
        |> required "term" languageMapLabelDecoder


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
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing


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
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalResources" (Decode.maybe externalResourcesSectionBodyDecoder) Nothing


sourceItemsSectionBodyDecoder : Decoder SourceItemsSectionBody
sourceItemsSectionBodyDecoder =
    Decode.succeed SourceItemsSectionBody
        |> hardcoded "source-record-items-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list basicSourceBodyDecoder)
