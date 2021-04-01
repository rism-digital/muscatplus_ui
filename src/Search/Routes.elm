module Search.Routes exposing (..)

import Config as C
import Http
import Search.DataTypes exposing (Filter(..), SearchQueryArgs, SearchResponse)
import Search.Decoders exposing (searchResponseDecoder)
import Shared.Request exposing (createRequest)
import Url.Builder exposing (QueryParameter)


buildQueryParameters : SearchQueryArgs -> List QueryParameter
buildQueryParameters queryArgs =
    let
        qParam =
            case queryArgs.query of
                Just q ->
                    [ Url.Builder.string "q" q ]

                Nothing ->
                    []

        fqParams =
            List.map
                (\f ->
                    let
                        (Filter field value) =
                            f

                        fieldValue =
                            field ++ ":" ++ value
                    in
                    Url.Builder.string "fq" fieldValue
                )
                queryArgs.filters

        pageParam =
            [ Url.Builder.string "page" (String.fromInt queryArgs.page) ]

        sortParam =
            case queryArgs.sort of
                Just s ->
                    [ Url.Builder.string "sort" s ]

                Nothing ->
                    []
    in
    List.concat [ qParam, fqParams, pageParam, sortParam ]


searchUrl : SearchQueryArgs -> String
searchUrl queryArgs =
    Url.Builder.crossOrigin C.serverUrl [ "search/" ] (buildQueryParameters queryArgs)


searchRequest : (Result Http.Error SearchResponse -> msg) -> SearchQueryArgs -> Cmd msg
searchRequest responseMsg queryArgs =
    let
        url =
            searchUrl queryArgs

        responseDecoder =
            searchResponseDecoder
    in
    createRequest responseMsg responseDecoder url
