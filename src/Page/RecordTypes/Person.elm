module Page.RecordTypes.Person exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias PersonBody =
    { id : String
    , label : LanguageMap
    , typeLabel : LanguageMap
    }


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "typeLabel" languageMapLabelDecoder
