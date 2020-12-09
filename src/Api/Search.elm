module Api.Search exposing (..)

import Api.Request exposing (createRequest)
import Config as C
import Http
import Json.Decode as Decode exposing (Decoder, andThen, int, list, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (Language(..), LanguageMap, LanguageValues(..), parseLocaleToLanguage)
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


type SearchRecordType
    = Source
    | Person
    | Institution


type alias SearchResult =
    { id : String
    , label : LanguageMap
    , type_ : SearchRecordType
    , typeLabel : LanguageMap
    }


resultDecoder : Decoder SearchResult
resultDecoder =
    Decode.succeed SearchResult
        |> required "id" string
        |> required "label" labelDecoder
        |> required "type" typeDecoder
        |> required "typeLabel" labelDecoder


typeDecoder : Decoder SearchRecordType
typeDecoder =
    Decode.string
        |> andThen (\str -> Decode.succeed (recordTypeFromJsonType str))


languageDecoder : String -> Decoder Language
languageDecoder locale =
    let
        lang =
            parseLocaleToLanguage locale
    in
    Decode.succeed lang


languageValuesDecoder : ( String, List String ) -> Decoder LanguageValues
languageValuesDecoder ( locale, translations ) =
    languageDecoder locale
        |> Decode.map (\lang -> LanguageValues lang translations)


{-|

    A custom decoder that takes a JSON-LD Language Map and produces a list of
    LanguageValues Language (List String), representing each of the translations
    available for this particular field.

-}
languageMapDecoder : List ( String, List String ) -> Decoder LanguageMap
languageMapDecoder json =
    List.foldl
        (\map maps -> Decode.map2 (::) (languageValuesDecoder map) maps)
        (Decode.succeed [])
        json


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


recordTypeFromJsonType : String -> SearchRecordType
recordTypeFromJsonType jsonType =
    case jsonType of
        "rism:Source" ->
            Source

        "rism:Person" ->
            Person

        "rism:Institution" ->
            Institution

        _ ->
            Source


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
