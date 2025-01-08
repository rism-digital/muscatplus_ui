module Page.RecordTypes.Front exposing (FrontBody, frontBodyDecoder)

import Dict
import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (optional)
import Page.RecordTypes.Search exposing (Facets, QueryField, aliasLabelDecoder, facetsDecoder)


type alias FrontBody =
    { facets : Facets
    , queryFields : List QueryField
    }


frontBodyDecoder : Decoder FrontBody
frontBodyDecoder =
    Decode.succeed FrontBody
        |> optional "facets" facetsDecoder Dict.empty
        |> optional "queryFields" (list (aliasLabelDecoder QueryField)) []
