module Page.RecordTypes.WorkBasic exposing (..)

import Json.Decode exposing (Decoder, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias BasicWorkBody =
    { id : String
    , label : LanguageMap
    }


basicWorkBodyDecoder : Decoder BasicWorkBody
basicWorkBodyDecoder =
    succeed BasicWorkBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
