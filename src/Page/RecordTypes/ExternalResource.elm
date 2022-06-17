module Page.RecordTypes.ExternalResource exposing
    ( ExternalResourceBody
    , ExternalResourceType(..)
    , ExternalResourcesSectionBody
    , externalResourceBodyDecoder
    , externalResourceTypeConverter
    , externalResourceTypeDecoder
    , externalResourcesSectionBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Language exposing (LanguageMap)
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
    , items : List ExternalResourceBody
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
        |> required "label" languageMapLabelDecoder
        |> required "items" (list externalResourceBodyDecoder)
