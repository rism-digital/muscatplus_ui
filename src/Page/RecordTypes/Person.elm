module Page.RecordTypes.Person exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody, relationshipsSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    , summary : Maybe (List LabelValue)
    , nameVariants : Maybe NameVariantsSectionBody
    , relationships : Maybe RelationshipsSectionBody
    , externalAuthorities : Maybe ExternalAuthoritiesSectionBody
    }


type alias NameVariantsSectionBody =
    { label : LanguageMap
    , items : List LabelValue
    }


type alias ExternalAuthoritiesSectionBody =
    { label : LanguageMap
    , items : List ExternalAuthorityBody
    }


type alias ExternalAuthorityBody =
    { label : LanguageMap
    , url : String
    }


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "nameVariants" (Decode.maybe nameVariantsSectionBodyDecoder) Nothing
        |> optional "relationships" (Decode.maybe relationshipsSectionBodyDecoder) Nothing
        |> optional "externalAuthorities" (Decode.maybe externalAuthoritiesSectionBodyDecoder) Nothing


nameVariantsSectionBodyDecoder : Decoder NameVariantsSectionBody
nameVariantsSectionBodyDecoder =
    Decode.succeed NameVariantsSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list labelValueDecoder)


externalAuthoritiesSectionBodyDecoder : Decoder ExternalAuthoritiesSectionBody
externalAuthoritiesSectionBodyDecoder =
    Decode.succeed ExternalAuthoritiesSectionBody
        |> required "label" languageMapLabelDecoder
        |> required "items" (list externalAuthorityBodyDecoder)


externalAuthorityBodyDecoder : Decoder ExternalAuthorityBody
externalAuthorityBodyDecoder =
    Decode.succeed ExternalAuthorityBody
        |> required "label" languageMapLabelDecoder
        |> required "url" string
