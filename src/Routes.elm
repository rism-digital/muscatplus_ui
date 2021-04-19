module Routes exposing (..)

import Config as C
import DataTypes exposing (Filter(..), ResultMode(..), Route(..), SearchBody, SearchQueryArgs, ServerResponse, parseResultModeToString, parseStringToResultMode)
import Decoders exposing (recordResponseDecoder, searchResponseDecoder)
import Http
import Request exposing (createRequest)
import Url exposing (Url)
import Url.Builder exposing (QueryParameter)
import Url.Parser as P exposing ((</>), (<?>), s)
import Url.Parser.Query as Q


buildQueryParameters : SearchQueryArgs -> List QueryParameter
buildQueryParameters queryArgs =
    let
        qParam =
            case queryArgs.query of
                Just q ->
                    [ Url.Builder.string "q" q ]

                Nothing ->
                    []

        modeParam =
            [ Url.Builder.string "mode" (parseResultModeToString queryArgs.mode) ]

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
    List.concat [ qParam, modeParam, fqParams, pageParam, sortParam ]


searchUrl : SearchQueryArgs -> String
searchUrl queryArgs =
    Url.Builder.crossOrigin C.serverUrl [ "search/" ] (buildQueryParameters queryArgs)



--searchRequest : (Result Http.Error ServerResponse -> msg) -> SearchQueryArgs -> Cmd msg
--searchRequest responseMsg queryArgs =
--    let
--        url =
--            searchUrl queryArgs
--
--        responseDecoder =
--            searchResponseDecoder
--    in
--    createRequest responseMsg responseDecoder url


requestFromServer : (Result Http.Error ServerResponse -> msg) -> String -> Cmd msg
requestFromServer responseMsg path =
    let
        pathSegments =
            path
                |> String.dropLeft 1
                |> String.split "/"

        url =
            recordUrl pathSegments
    in
    createRequest responseMsg recordResponseDecoder url


parseUrl : Url -> Route
parseUrl url =
    case P.parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map FrontPageRoute P.top
        , P.map SearchPageRoute (s "search" <?> queryParamsParser)
        , P.map SourceRoute (s "sources" </> P.int)
        , P.map PersonRoute (s "people" </> P.int)
        , P.map InstitutionRoute (s "institutions" </> P.int)
        , P.map PlaceRoute (s "places" </> P.int)
        , P.map FestivalRoute (s "festivals" </> P.int)
        ]


routeMatches : Url -> Maybe Route
routeMatches url =
    P.parse routeParser url


recordUrl : List String -> String
recordUrl pathSegments =
    Url.Builder.crossOrigin C.serverUrl pathSegments []


queryParamsParser : Q.Parser SearchQueryArgs
queryParamsParser =
    Q.map5 SearchQueryArgs (Q.string "q") fqParamParser (Q.string "sort") pageParamParser modeParamParser


fqParamParser : Q.Parser (List Filter)
fqParamParser =
    Q.custom "fq" (\a -> filterQueryStringToFilter a)


modeParamParser : Q.Parser ResultMode
modeParamParser =
    Q.custom "mode" (\a -> modeQueryStringToResultMode a)


filterQueryStringToFilter : List String -> List Filter
filterQueryStringToFilter fqlist =
    -- discards any filters that do not conform to the expected values
    -- TODO: Convert this to a parser that can handle colons in the 'values'
    List.concat
        (List.map
            (\a ->
                case String.split ":" a of
                    [ field, value ] ->
                        [ Filter field value ]

                    _ ->
                        []
            )
            fqlist
        )


modeQueryStringToResultMode : List String -> ResultMode
modeQueryStringToResultMode modelist =
    List.map (\a -> parseStringToResultMode a) modelist
        |> List.head
        |> Maybe.withDefault Sources


pageParamParser : Q.Parser Int
pageParamParser =
    -- returns 1 if the page parameter cannot be parsed to an int.
    Q.custom "page"
        (\stringList ->
            case stringList of
                [ str ] ->
                    Maybe.withDefault 1 (String.toInt str)

                _ ->
                    1
        )
