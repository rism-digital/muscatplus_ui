module Page.RecordTypes.ExternalAuthorities exposing
    ( ExternalAuthoritiesSectionBody
    , ExternalAuthorityBody
    , externalAuthoritiesSectionBodyDecoder
    )

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias ExternalAuthoritiesSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List ExternalAuthorityBody
    }


type alias ExternalAuthorityBody =
    { label : LanguageMap
    , url : Maybe String
    }


externalAuthoritiesSectionBodyDecoder : Decoder ExternalAuthoritiesSectionBody
externalAuthoritiesSectionBodyDecoder =
    Decode.succeed ExternalAuthoritiesSectionBody
        |> hardcoded "person-external-authorities-section"
        |> required "label" languageMapLabelDecoder
        |> required "items" (list externalAuthorityBodyDecoder)


externalAuthorityBodyDecoder : Decoder ExternalAuthorityBody
externalAuthorityBodyDecoder =
    Decode.succeed ExternalAuthorityBody
        |> required "label" languageMapLabelDecoder
        |> optional "url" (Decode.maybe string) Nothing
