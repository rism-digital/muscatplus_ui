module Page.RecordTypes.Front exposing (..)

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)
import Page.RecordTypes.Search exposing (Facets, facetsDecoder)


type alias FrontBody =
    { facets : Facets
    }


frontBodyDecoder : Decoder FrontBody
frontBodyDecoder =
    Decode.succeed FrontBody
        |> optional "facets" facetsDecoder Dict.empty
