module Page.RecordTypes.Search exposing (Facet, FacetItem(..), SearchBody, SearchPagination, SearchResult, searchBodyDecoder)

import Json.Decode as Decode exposing (Decoder, bool, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder, typeDecoder)
import Page.RecordTypes.Source exposing (BasicSourceBody, PartOfSectionBody, basicSourceBodyDecoder, partOfSectionBodyDecoder)


type alias SearchBody =
    { id : String
    , totalItems : Int
    , items : List SearchResult
    , pagination : SearchPagination
    , facets : List Facet
    , modes : Facet
    }


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : RecordType
    , partOf : Maybe PartOfSectionBody
    , summary : Maybe (List LabelValue)
    , flags : SearchResultFlags
    }


type alias SearchResultFlags =
    { hasDigitization : Bool
    , hasIIIFManifest : Bool
    , isItemRecord : Bool
    , hasIncipits : Bool
    }


defaultSearchResultFlags : SearchResultFlags
defaultSearchResultFlags =
    { hasDigitization = False
    , hasIIIFManifest = False
    , isItemRecord = False
    , hasIncipits = False
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
    = FacetItem String LanguageMap Float


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody
        |> required "id" string
        |> required "totalItems" int
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
        |> optional "partOf" (Decode.maybe partOfSectionBodyDecoder) Nothing
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "flags" searchResultFlagsDecoder defaultSearchResultFlags


searchResultFlagsDecoder : Decoder SearchResultFlags
searchResultFlagsDecoder =
    Decode.succeed SearchResultFlags
        |> optional "hasDigitization" bool False
        |> optional "hasIIIFManifest" bool False
        |> optional "isItem" bool False
        |> optional "hasIncipits" bool False


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
        |> required "count" float
