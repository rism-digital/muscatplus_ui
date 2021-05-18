module Page.RecordTypes.Incipit exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias IncipitBody =
    { id : String
    , label : LanguageMap
    , partOf : Maybe IncipitParentSourceBody
    }


type alias IncipitParentSourceBody =
    { id : String
    , label : LanguageMap
    }


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "partOf" (Decode.maybe incipitParentSourceBodyDecoder) Nothing


incipitParentSourceBodyDecoder : Decoder IncipitParentSourceBody
incipitParentSourceBodyDecoder =
    Decode.succeed IncipitParentSourceBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
