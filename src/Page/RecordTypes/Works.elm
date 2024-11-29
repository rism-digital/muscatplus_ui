module Page.RecordTypes.Works exposing (PersonExternalWorkReferencesBody, PersonWorksSectionBody, SourceWorksSectionBody, WorkReference, personWorksSectionBodyDecoder, sourceWorksSectionBodyDecoder)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Relationship exposing (RelatedToBody, relatedToBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias PersonWorksSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , workReferences : Maybe PersonExternalWorkReferencesBody
    }


type alias PersonExternalWorkReferencesBody =
    { label : LanguageMap
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
    }


sourceWorksSectionBodyDecoder : Decoder SourceWorksSectionBody
sourceWorksSectionBodyDecoder =
    Decode.succeed SourceWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReference" (Decode.maybe workReferenceDecoder) Nothing


personWorksSectionBodyDecoder : Decoder PersonWorksSectionBody
personWorksSectionBodyDecoder =
    Decode.succeed PersonWorksSectionBody
        |> hardcoded "record-works-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "workReferences" (Decode.maybe personExternalWorkReferencesSectionDecoder) Nothing


personExternalWorkReferencesSectionDecoder : Decoder PersonExternalWorkReferencesBody
personExternalWorkReferencesSectionDecoder =
    Decode.succeed PersonExternalWorkReferencesBody
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
