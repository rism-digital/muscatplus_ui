module Api.Search exposing (..)

import Api.DataTypes exposing (RecordType(..), typeDecoder)
import Api.Request exposing (createRequest)
import Config as C
import Http
import Json.Decode as Decode exposing (Decoder, andThen, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (Language(..), LanguageMap, LanguageValues(..), languageMapDecoder)
import Url.Builder


type ApiResponse
    = Loading
    | Response SearchResponse
    | ApiError


type alias SearchResponse =
    { id : String
    , items : List SearchResult
    , view : SearchPagination
    }


type alias SearchQueryArgs =
    { query : String
    , filters : List String
    , sort : String
    }


type alias SearchPagination =
    { next : Maybe String
    , previous : Maybe String
    , first : String
    , last : Maybe String
    , totalPages : Int
    }


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : RecordType
    , typeLabel : LanguageMap
    }


resultDecoder : Decoder SearchResult
resultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" labelDecoder
        |> required "type" typeDecoder
        |> required "typeLabel" labelDecoder


labelDecoder : Decoder LanguageMap
labelDecoder =
    Decode.keyValuePairs (list string)
        |> andThen languageMapDecoder


searchPaginationDecoder : Decoder SearchPagination
searchPaginationDecoder =
    Decode.succeed SearchPagination
        |> optional "next" (nullable string) Nothing
        |> optional "previous" (nullable string) Nothing
        |> required "first" string
        |> optional "last" (nullable string) Nothing
        |> required "totalPages" int


searchResponseDecoder : Decoder SearchResponse
searchResponseDecoder =
    Decode.succeed SearchResponse
        |> required "id" string
        |> required "items" (Decode.list resultDecoder)
        |> required "view" searchPaginationDecoder


searchUrl : SearchQueryArgs -> String
searchUrl queryArgs =
    let
        qstring =
            Url.Builder.string "q" queryArgs.query
    in
    Url.Builder.crossOrigin C.serverUrl [ "search/" ] [ qstring ]


searchRequest : (Result Http.Error SearchResponse -> msg) -> SearchQueryArgs -> Cmd msg
searchRequest responseMsg queryArgs =
    let
        url =
            searchUrl queryArgs

        responseDecoder =
            searchResponseDecoder
    in
    createRequest responseMsg responseDecoder url
