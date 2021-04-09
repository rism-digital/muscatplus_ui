module Search.Decoders exposing (..)

import Json.Decode as Decode exposing (Decoder, int, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, optionalAt, required)
import Search.DataTypes
    exposing
        ( Facet
        , FacetItem(..)
        , FacetList
        , SearchPagination
        , SearchResponse
        , SearchResult
        )
import Shared.Decoders exposing (labelDecoder, typeDecoder)


resultDecoder : Decoder SearchResult
resultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" labelDecoder
        |> required "type" typeDecoder
        |> required "typeLabel" labelDecoder


searchPaginationDecoder : Decoder SearchPagination
searchPaginationDecoder =
    Decode.succeed SearchPagination
        |> optional "next" (nullable string) Nothing
        |> optional "previous" (nullable string) Nothing
        |> required "first" string
        |> optional "last" (nullable string) Nothing
        |> required "totalPages" int


facetListDecoder : Decoder FacetList
facetListDecoder =
    Decode.succeed FacetList
        |> required "items" (Decode.list facetDecoder)


facetDecoder : Decoder Facet
facetDecoder =
    Decode.succeed Facet
        |> required "alias" string
        |> required "label" labelDecoder
        |> required "items" (Decode.list facetItemDecoder)


facetItemDecoder : Decoder FacetItem
facetItemDecoder =
    Decode.succeed FacetItem
        |> required "value" string
        |> required "label" labelDecoder
        |> optional "count" int 0


searchResponseDecoder : Decoder SearchResponse
searchResponseDecoder =
    Decode.succeed SearchResponse
        |> required "id" string
        |> optional "items" (Decode.list resultDecoder) []
        |> required "view" searchPaginationDecoder
        |> optionalAt [ "facets", "items" ] (Decode.list facetDecoder) []
        |> required "modes" facetDecoder
        |> required "totalItems" int
