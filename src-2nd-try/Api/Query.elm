module Api.Query exposing (QueryArgs, buildQueryParameters, defaultQueryArgs, queryParamsParser)

import Api.RecordTypes exposing (Filter(..))
import Api.Response exposing (ResultMode(..), parseResultModeToString, parseStringToResultMode)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


type alias QueryArgs =
    { query : Maybe String
    , filters : List Filter
    , sort : Maybe String
    , page : Int
    , mode : ResultMode
    }


defaultQueryArgs : QueryArgs
defaultQueryArgs =
    QueryArgs Nothing [] Nothing 1 SourcesMode


buildQueryParameters : QueryArgs -> List QueryParameter
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


queryParamsParser : Q.Parser QueryArgs
queryParamsParser =
    Q.map5 QueryArgs (Q.string "q") fqParamParser (Q.string "sort") pageParamParser modeParamParser


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
        |> Maybe.withDefault SourcesMode


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
