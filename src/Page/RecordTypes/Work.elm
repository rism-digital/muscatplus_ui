module Page.RecordTypes.Work exposing (FormOfWorkSectionBody, PersonExternalWorkReferencesBody, PersonWorksSectionBody, SourceWorksSectionBody, WorkBody, WorkReference, WorksCatalogue, WorksCatalogueSectionBody, personWorksSectionBodyDecoder, sourceWorksSectionBodyDecoder, workBodyDecoder)

import Json.Decode exposing (Decoder, int, list, maybe, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Incipit exposing (IncipitsSectionBody, incipitsSectionBodyDecoder)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, relatedToBodyDecoder, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory, labelValueDecoder, languageMapLabelDecoder, recordHistoryDecoder)


type alias PersonWorksSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , workReferences : Maybe PersonExternalWorkReferencesBody
    , worksCatalogs : Maybe WorksCatalogueSectionBody
    }


type alias PersonExternalWorkReferencesBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List WorkReference
    }


type alias SourceWorksSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , workReference : Maybe WorkReference
    }


type alias WorkReference =
    { relatedTo : RelatedToBody
    , label : LanguageMap
    , value : String
    , searchUrl : String
    , authorityUrl : String
    , externalIdentifier : String
    , sourceCount : Int
    }


type alias WorksCatalogueSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List WorksCatalogue
    }


type alias WorksCatalogue =
    { id : String
    , label : LanguageMap
    }


type alias WorkBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , creator : Maybe RelationshipBody
    , summary : Maybe (List LabelValue)
    , incipits : Maybe IncipitsSectionBody
    , sources : Maybe String
    , formOfWork : Maybe FormOfWorkSectionBody
    , recordHistory : RecordHistory
    }


type alias FormOfWorkSectionBody =
    { label : LanguageMap
    , items : List FormOfWork
    }


type alias FormOfWork =
    { id : String
    , label : LanguageMap
    }


sourceWorksSectionBodyDecoder : Decoder SourceWorksSectionBody
sourceWorksSectionBodyDecoder =
    succeed SourceWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReference" (maybe workReferenceDecoder) Nothing


personWorksSectionBodyDecoder : Decoder PersonWorksSectionBody
personWorksSectionBodyDecoder =
    succeed PersonWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReferences" (maybe personExternalWorkReferencesSectionDecoder) Nothing
        |> optional "worksCatalogs" (maybe worksCatalogueSectionBodyDecoder) Nothing


personExternalWorkReferencesSectionDecoder : Decoder PersonExternalWorkReferencesBody
personExternalWorkReferencesSectionDecoder =
    succeed PersonExternalWorkReferencesBody
        |> hardcoded "person-external-work-references"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list workReferenceDecoder)


workReferenceDecoder : Decoder WorkReference
workReferenceDecoder =
    succeed WorkReference
        |> required "relatedTo" relatedToBodyDecoder
        |> required "label" languageMapLabelDecoder
        |> required "value" string
        |> required "search" string
        |> required "url" string
        |> required "externalIdentifier" string
        |> required "sourceCount" int


worksCatalogueSectionBodyDecoder : Decoder WorksCatalogueSectionBody
worksCatalogueSectionBodyDecoder =
    succeed WorksCatalogueSectionBody
        |> hardcoded "works-catalogue-section-body"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list worksCatalogueDecoder)


worksCatalogueDecoder : Decoder WorksCatalogue
worksCatalogueDecoder =
    succeed WorksCatalogue
        |> required "id" string
        |> required "label" languageMapLabelDecoder


workBodyDecoder : Decoder WorkBody
workBodyDecoder =
    succeed WorkBody
        |> hardcoded "work-body-section"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> optional "incipits" (maybe incipitsSectionBodyDecoder) Nothing
        |> optional "sources" (maybe string) Nothing
        |> optional "formOfWork" (maybe formOfWorkSectionBodyDecoder) Nothing
        |> required "recordHistory" recordHistoryDecoder


formOfWorkSectionBodyDecoder : Decoder FormOfWorkSectionBody
formOfWorkSectionBodyDecoder =
    succeed FormOfWorkSectionBody
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list formOfWorkDecoder)


formOfWorkDecoder : Decoder FormOfWork
formOfWorkDecoder =
    succeed FormOfWork
        |> required "id" string
        |> required "label" languageMapLabelDecoder
