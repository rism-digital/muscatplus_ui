module Page.RecordTypes.Search exposing (SearchBody, SearchPagination, SearchResult, searchBodyDecoder)

import Json.Decode as Decode exposing (Decoder, int, nullable, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder, typeDecoder)


type alias SearchBody =
    { id : String
    , items : List SearchResult
    , pagination : SearchPagination
    , facets : List Facet
    , modes : Facet
    }


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : RecordType
    }


type alias SearchPagination =
    { next : Maybe String
    , previous : Maybe String
    , first : String
    , last : Maybe String
    , totalPages : Int
    , thisPage : Int
    }


type alias FacetList =
    { items : List Facet
    }


type alias Facet =
    { alias : String
    , label : LanguageMap
    , items : List FacetItem
    }


{-|

    FacetItem is a facet name, a query value, a label (language map),
    and the count of documents in the response.

    E.g.,

    FacetItem "source" {'none': {'some label'}} 123

-}
type FacetItem
    = FacetItem String LanguageMap Int


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody
        |> required "id" string
        |> optional "items" (Decode.list searchResultDecoder) []
        |> required "view" searchPaginationDecoder
        |> optionalAt [ "facets", "items" ] (Decode.list facetDecoder) []
        |> required "modes" facetDecoder


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> required "type" typeDecoder


searchPaginationDecoder : Decoder SearchPagination
searchPaginationDecoder =
    Decode.succeed SearchPagination
        |> optional "next" (nullable string) Nothing
        |> optional "previous" (nullable string) Nothing
        |> required "first" string
        |> optional "last" (nullable string) Nothing
        |> required "totalPages" int
        |> required "thisPage" int


facetListDecoder : Decoder FacetList
facetListDecoder =
    Decode.succeed FacetList
        |> required "items" (Decode.list facetDecoder)


facetDecoder : Decoder Facet
facetDecoder =
    Decode.succeed Facet
        |> required "alias" string
        |> required "label" languageMapLabelDecoder
        |> required "items" (Decode.list facetItemDecoder)


facetItemDecoder : Decoder FacetItem
facetItemDecoder =
    Decode.succeed FacetItem
        |> required "value" string
        |> required "label" languageMapLabelDecoder
        |> optional "count" int 0
