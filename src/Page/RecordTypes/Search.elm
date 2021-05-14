module Page.RecordTypes.Search exposing (SearchBody, SearchPagination, SearchResult, searchBodyDecoder)

import Json.Decode as Decode exposing (Decoder, int, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType)
import Page.RecordTypes.Shared exposing (labelDecoder, typeDecoder)


type alias SearchBody =
    { id : String
    , items : List SearchResult
    , pagination : SearchPagination
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


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody
        |> required "id" string
        |> optional "items" (Decode.list searchResultDecoder) []
        |> required "view" searchPaginationDecoder


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" labelDecoder
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
