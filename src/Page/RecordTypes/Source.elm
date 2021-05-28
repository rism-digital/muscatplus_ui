module Page.RecordTypes.Source exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody, liturgicalFestivalBodyDecoder)
import Page.RecordTypes.Incipit exposing (IncipitBody, incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody, InstitutionBody, basicInstitutionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelationshipBody, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias BasicSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    }


type alias FullSourceBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , partOf : Maybe PartOfSectionBody
    , contents : Maybe ContentsSectionBody
    , materialGroups : Maybe MaterialGroupsSectionBody
    , incipits : Maybe IncipitsSectionBody
    , referencesNotes : Maybe ReferencesNotesSectionBody
    , exemplars : Maybe ExemplarsSectionBody
    , items : Maybe SourceItemsSectionBody
    }


type alias PartOfSectionBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias ContentsSectionBody =
    { label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , subjects : Maybe SourceSubjectsBody
    }


type alias SourceSubjectsBody =
    { label : LanguageMap
    , items : List SourceSubject
    }


type alias SourceSubject =
    { id : String
    , term : LanguageMap
    }


type alias MaterialGroupsSectionBody =
    { label : LanguageMap
    , items : List MaterialGroupBody
    }


type alias MaterialGroupBody =
    { label : LanguageMap
    , summary : Maybe (List LabelValue)
    , relationships : Maybe RelationshipsSectionBody
    }


type alias RelationshipsSectionBody =
    { label : LanguageMap
    , items : List RelationshipBody
    }


type alias IncipitsSectionBody =
    { label : LanguageMap
    , items : List IncipitBody
    }


type alias ReferencesNotesSectionBody =
    { label : LanguageMap
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
    { label : LanguageMap
    , items : List ExemplarBody
    }


type alias ExemplarBody =
    { id : String
    , summary : Maybe (List LabelValue)
    , heldBy : BasicInstitutionBody
    , externalLinks : Maybe ExternalResourcesListBody
    }


type alias ExternalResourcesListBody =
    { label : LanguageMap
    , items : List ExternalResourceBody
    }


type alias ExternalResourceBody =
    { label : LanguageMap
    , url : String
    }


type alias SourceItemsSectionBody =
    { label : LanguageMap
    , items : List BasicSourceBody
    }


sourceBodyDecoder : Decoder FullSourceBody
sourceBodyDecoder =
    Decode.succeed FullSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "contents" (Decode.maybe contentsSectionBodyDecoder) Nothing
        |> optional "materialGroups" (Decode.maybe materialGroupsSectionBodyDecoder) Nothing
        |> optional "incipits" (Decode.maybe incipitsSectionBodyDecoder) Nothing
        |> optional "referencesNotes" (Decode.maybe referencesNotesSectionBodyDecoder) Nothing
        |> optional "exemplars" (Decode.maybe exemplarsSectionBodyDecoder) Nothing
        |> optional "items" (Decode.maybe sourceItemsSectionBodyDecoder) Nothing


basicSourceBodyDecoder : Decoder BasicSourceBody
basicSourceBodyDecoder =
    Decode.succeed BasicSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder


partOfSectionBodyDecoder : Decoder PartOfSectionBody
partOfSectionBodyDecoder =
    Decode.succeed PartOfSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


contentsSectionBodyDecoder : Decoder ContentsSectionBody
contentsSectionBodyDecoder =
    Decode.succeed ContentsSectionBody
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (Decode.maybe relationshipBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "subjects" (Decode.maybe sourceSubjectsBodyDecoder) Nothing


sourceSubjectsBodyDecoder : Decoder SourceSubjectsBody
sourceSubjectsBodyDecoder =
    Decode.succeed SourceSubjectsBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list sourceSubjectDecoder)


sourceSubjectDecoder : Decoder SourceSubject
sourceSubjectDecoder =
    Decode.succeed SourceSubject
        |> required "id" string
        |> required "term" languageMapLabelDecoder


materialGroupsSectionBodyDecoder : Decoder MaterialGroupsSectionBody
materialGroupsSectionBodyDecoder =
    Decode.succeed MaterialGroupsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list materialGroupBodyDecoder)


materialGroupBodyDecoder : Decoder MaterialGroupBody
materialGroupBodyDecoder =
    Decode.succeed MaterialGroupBody
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing


relationshipsSectionBodyDecoder : Decoder RelationshipsSectionBody
relationshipsSectionBodyDecoder =
    Decode.succeed RelationshipsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list relationshipBodyDecoder)


incipitsSectionBodyDecoder : Decoder IncipitsSectionBody
incipitsSectionBodyDecoder =
    Decode.succeed IncipitsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list incipitBodyDecoder)


referencesNotesSectionBodyDecoder : Decoder ReferencesNotesSectionBody
referencesNotesSectionBodyDecoder =
    Decode.succeed ReferencesNotesSectionBody
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
        |> required "label" languageMapLabelDecoder
        |> required "items" (list exemplarsBodyDecoder)


exemplarsBodyDecoder : Decoder ExemplarBody
exemplarsBodyDecoder =
    Decode.succeed ExemplarBody
        |> required "id" string
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "heldBy" basicInstitutionBodyDecoder
        |> optional "externalLinks" (Decode.maybe externalResourcesListBodyDecoder) Nothing


externalResourcesListBodyDecoder : Decoder ExternalResourcesListBody
externalResourcesListBodyDecoder =
    Decode.succeed ExternalResourcesListBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list externalResourceBodyDecoder)


externalResourceBodyDecoder : Decoder ExternalResourceBody
externalResourceBodyDecoder =
    Decode.succeed ExternalResourceBody
        |> required "label" languageMapLabelDecoder
        |> required "url" string


sourceItemsSectionBodyDecoder : Decoder SourceItemsSectionBody
sourceItemsSectionBodyDecoder =
    Decode.succeed SourceItemsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list basicSourceBodyDecoder)
