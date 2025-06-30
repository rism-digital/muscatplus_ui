module Page.RecordTypes.Work exposing (PersonExternalWorkReferencesBody, PersonWorksSectionBody, SourceWorksSectionBody, WorkBody, WorkReference, WorksCatalogue, WorksCatalogueSectionBody, personWorksSectionBodyDecoder, sourceWorksSectionBodyDecoder, workBodyDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody, relatedToBodyDecoder, relationshipBodyDecoder)
import Page.RecordTypes.Shared exposing (RecordHistory, languageMapLabelDecoder, recordHistoryDecoder)


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
    , incipits : Maybe String
    , sources : Maybe String
    , recordHistory : RecordHistory
    }


sourceWorksSectionBodyDecoder : Decoder SourceWorksSectionBody
sourceWorksSectionBodyDecoder =
    Decode.succeed SourceWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReference" (maybe workReferenceDecoder) Nothing


personWorksSectionBodyDecoder : Decoder PersonWorksSectionBody
personWorksSectionBodyDecoder =
    Decode.succeed PersonWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReferences" (Decode.maybe personExternalWorkReferencesSectionDecoder) Nothing
        |> optional "worksCatalogs" (maybe worksCatalogueSectionBodyDecoder) Nothing


personExternalWorkReferencesSectionDecoder : Decoder PersonExternalWorkReferencesBody
personExternalWorkReferencesSectionDecoder =
    Decode.succeed PersonExternalWorkReferencesBody
        |> hardcoded "person-external-work-references"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list workReferenceDecoder)


workReferenceDecoder : Decoder WorkReference
workReferenceDecoder =
    Decode.succeed WorkReference
        |> required "relatedTo" relatedToBodyDecoder
        |> required "label" languageMapLabelDecoder
        |> required "value" string
        |> required "search" string
        |> required "url" string
        |> required "externalIdentifier" string
        |> required "sourceCount" int


worksCatalogueSectionBodyDecoder : Decoder WorksCatalogueSectionBody
worksCatalogueSectionBodyDecoder =
    Decode.succeed WorksCatalogueSectionBody
        |> hardcoded "works-catalogue-section-body"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list worksCatalogueDecoder)


worksCatalogueDecoder : Decoder WorksCatalogue
worksCatalogueDecoder =
    Decode.succeed WorksCatalogue
        |> required "id" string
        |> required "label" languageMapLabelDecoder


workBodyDecoder : Decoder WorkBody
workBodyDecoder =
    Decode.succeed WorkBody
        |> hardcoded "work-body-section"
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "creator" (maybe relationshipBodyDecoder) Nothing
        |> optional "incipits" (maybe string) Nothing
        |> optional "sources" (maybe string) Nothing
        |> required "recordHistory" recordHistoryDecoder
