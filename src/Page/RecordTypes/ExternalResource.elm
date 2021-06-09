module Page.RecordTypes.ExternalResource exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


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


type alias ExternalResourceBody =
    { url : String
    , label : LanguageMap
    , type_ : ExternalResourceType
    }


externalResourcesSectionBodyDecoder : Decoder ExternalResourcesSectionBody
externalResourcesSectionBodyDecoder =
    Decode.succeed ExternalResourcesSectionBody
        |> hardcoded "record-external-resources-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list externalResourceBodyDecoder)


externalResourceBodyDecoder : Decoder ExternalResourceBody
externalResourceBodyDecoder =
    Decode.succeed ExternalResourceBody
        |> required "url" string
        |> required "label" languageMapLabelDecoder
        |> required "resourceType" externalResourceTypeDecoder


externalResourceTypeDecoder : Decoder ExternalResourceType
externalResourceTypeDecoder =
    Decode.string
        |> andThen externalResourceTypeConverter


externalResourceTypeConverter : String -> Decoder ExternalResourceType
externalResourceTypeConverter typeString =
    case typeString of
        "rism:IIIFManifestLink" ->
            Decode.succeed IIIFManifestResourceType

        "rism:DigitizationLink" ->
            Decode.succeed DigitizationResourceType

        "rism:OtherLink" ->
            Decode.succeed OtherResourceType

        _ ->
            Decode.succeed UnknownResourceType
