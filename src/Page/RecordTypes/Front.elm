module Page.RecordTypes.Front exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Page.RecordTypes.Search exposing (Facets, facetsDecoder)
import Page.RecordTypes.Shared exposing (FacetAlias, LabelNumericValue, LabelValue, labelNumericValueDecoder)


type alias FrontBody =
    { stats : Stats
    , facets : Facets
    }


type alias Stats =
    { sources : LabelNumericValue }


frontBodyDecoder : Decoder FrontBody
frontBodyDecoder =
    Decode.succeed FrontBody
        |> required "stats" statsDecoder
        |> optional "facets" facetsDecoder Dict.empty


statsDecoder : Decoder Stats
statsDecoder =
    Decode.succeed Stats
        |> required "sources" labelNumericValueDecoder
