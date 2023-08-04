module Page.RecordTypes.ExternalResource exposing
    ( ExternalResourceBody
    , ExternalResourceType(..)
    , ExternalResourcesSectionBody
    , externalResourcesSectionBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, andThen, list, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..), ExternalRecordBody, externalInstitutionBodyDecoder, externalRecordBodyDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias ExternalResourceBody =
    { url : String
    , label : LanguageMap
    , type_ : ExternalResourceType
    }


type ExternalResourceType
    = IIIFManifestResourceType
    | DigitizationResourceType
    | OtherResourceType
    | UnknownResourceType


type alias ExternalResourcesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : Maybe (List ExternalResourceBody)
    , externalRecords : Maybe (List ExternalRecordBody)
    }


externalResourceBodyDecoder : Decoder ExternalResourceBody
externalResourceBodyDecoder =
    Decode.succeed ExternalResourceBody
        |> required "url" string
        |> required "label" languageMapLabelDecoder
        |> required "resourceType" externalResourceTypeDecoder


externalResourceTypeConverter : String -> Decoder ExternalResourceType
externalResourceTypeConverter typeString =
    case typeString of
        "rism:DigitizationLink" ->
            Decode.succeed DigitizationResourceType

        "rism:IIIFManifestLink" ->
            Decode.succeed IIIFManifestResourceType

        "rism:OtherLink" ->
            Decode.succeed OtherResourceType

        _ ->
            Decode.succeed UnknownResourceType


externalResourceTypeDecoder : Decoder ExternalResourceType
externalResourceTypeDecoder =
    string
        |> andThen externalResourceTypeConverter


externalResourcesSectionBodyDecoder : Decoder ExternalResourcesSectionBody
externalResourcesSectionBodyDecoder =
    Decode.succeed ExternalResourcesSectionBody
        |> hardcoded "record-external-resources-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> optional "items" (maybe (list externalResourceBodyDecoder)) Nothing
        |> optional "externalRecords" (maybe (list externalRecordBodyDecoder)) Nothing
