module Page.Query exposing (FacetBehaviour(..), Filter(..), QueryArgs, buildQueryParameters, defaultQueryArgs, parseStringToFacetBehaviour, queryParamsParser)

import Config as C
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseResultModeToString, parseStringToResultMode)
import Page.UI.Keyboard.Query exposing (notationParamParser)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


{-|

    A filter represents a selected filter query; The values are the
    field name and the value, e.g., "Filter type source". This will then
    get converted to a list of URL parameters, `fq=type:source`.

-}
type Filter
    = Filter String String


{-|

    The behaviour carries the facet alias as a parameter

    IntersectionBehaviour "source-type"
    UnionBehaviour "holding-institution"
    etc.

-}
type FacetBehaviour
    = IntersectionBehaviour String
    | UnionBehaviour String


type FacetSort
    = CountSort String
    | AlphaSort String


type alias QueryArgs =
    { query : Maybe String
    , filters : List Filter
    , sort : Maybe String
    , page : Int
    , rows : Int
    , mode : ResultMode
    , facetBehaviours : List FacetBehaviour
    , facetSorts : List FacetSort
    }


defaultQueryArgs : QueryArgs
defaultQueryArgs =
    { query = Nothing
    , filters = []
    , sort = Nothing
    , page = 1
    , rows = C.defaultRows
    , mode = SourcesMode
    , facetBehaviours = []
    , facetSorts = []
    }


{-|

    Returns a partially-applied Facet Behaviour to which a
    facet alias can be given.

-}
parseStringToFacetBehaviour : String -> (String -> FacetBehaviour)
parseStringToFacetBehaviour inp =
    case inp of
        "union" ->
            UnionBehaviour

        _ ->
            IntersectionBehaviour


{-|

    Converts our application's QueryArgs to a set of QueryParameters
    suitable for Elm's internal URL handling.

-}
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
                (\filt ->
                    let
                        (Filter fieldName fieldValue) =
                            filt

                        queryStringValue =
                            fieldName ++ ":" ++ fieldValue
                    in
                    Url.Builder.string "fq" queryStringValue
                )
                queryArgs.filters

        fbParams =
            List.map
                (\facetBehaviour ->
                    let
                        behaviourStringValue =
                            case facetBehaviour of
                                IntersectionBehaviour fieldName ->
                                    fieldName ++ ":intersection"

                                UnionBehaviour fieldName ->
                                    fieldName ++ ":union"
                    in
                    Url.Builder.string "fb" behaviourStringValue
                )
                queryArgs.facetBehaviours

        fsParams =
            List.map
                (\facetSort ->
                    let
                        sortStringValue =
                            case facetSort of
                                AlphaSort fieldName ->
                                    fieldName ++ ":alpha"

                                CountSort fieldName ->
                                    fieldName ++ ":count"
                    in
                    Url.Builder.string "fs" sortStringValue
                )
                queryArgs.facetSorts

        pageParam =
            [ Url.Builder.string "page" (String.fromInt queryArgs.page) ]

        sortParam =
            case queryArgs.sort of
                Just s ->
                    [ Url.Builder.string "sort" s ]

                Nothing ->
                    []
    in
    List.concat [ qParam, modeParam, fqParams, fbParams, fsParams, pageParam, sortParam ]


queryParamsParser : Q.Parser QueryArgs
queryParamsParser =
    -- See the note on `map8` for how to define these pipelines:
    -- https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    Q.map QueryArgs (Q.string "q")
        |> apply fqParamParser
        |> apply (Q.string "sort")
        |> apply pageParamParser
        |> apply rowsParamParser
        |> apply modeParamParser
        |> apply fbParamParser
        |> apply fsParamParser


fqParamParser : Q.Parser (List Filter)
fqParamParser =
    Q.custom "fq" (\a -> filterQueryStringToFilter a)


fbParamParser : Q.Parser (List FacetBehaviour)
fbParamParser =
    Q.custom "fb" (\a -> facetBehaviourQueryStringToBehaviour a)


facetBehaviourQueryStringToBehaviour : List String -> List FacetBehaviour
facetBehaviourQueryStringToBehaviour fbList =
    List.concat
        (List.map
            (\a ->
                case String.split ":" a of
                    [ field, value ] ->
                        case value of
                            "union" ->
                                [ UnionBehaviour field ]

                            _ ->
                                [ IntersectionBehaviour field ]

                    _ ->
                        []
            )
            fbList
        )


fsParamParser : Q.Parser (List FacetSort)
fsParamParser =
    Q.custom "fs" (\a -> facetSortQueryStringToFacetSort a)


facetSortQueryStringToFacetSort : List String -> List FacetSort
facetSortQueryStringToFacetSort fsList =
    List.concat
        (List.map
            (\a ->
                case String.split ":" a of
                    [ field, value ] ->
                        case value of
                            "alpha" ->
                                [ AlphaSort field ]

                            _ ->
                                [ CountSort field ]

                    _ ->
                        []
            )
            fsList
        )


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


rowsParamParser : Q.Parser Int
rowsParamParser =
    -- returns the default rows if the rows parameter cannot be parsed to an int.
    Q.custom "rows"
        (\stringList ->
            case stringList of
                [ str ] ->
                    Maybe.withDefault 1 (String.toInt str)

                _ ->
                    C.defaultRows
        )
