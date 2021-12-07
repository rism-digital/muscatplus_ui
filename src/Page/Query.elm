module Page.Query exposing
    ( FacetBehaviour(..)
    , FacetMode(..)
    , FacetSort(..)
    , Filter(..)
    , QueryArgs
    , buildQueryParameters
    , defaultQueryArgs
    , parseStringToFacetBehaviour
    , queryParamsParser
    , resetPage
    , setFilters
    , setMode
    , setQuery
    , setQueryArgs
    , setSort
    , toFilters
    , toMode
    , toQuery
    , toQueryArgs
    , toggleFilters
    )

import Config as C
import Dict exposing (Dict)
import List.Extra as LE
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseResultModeToString, parseStringToResultMode)
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


{-|

    The default sort order is set by the server

-}
type FacetSort
    = CountSortOrder String
    | AlphaSortOrder String


type FacetMode
    = CheckboxSelect String
    | TextInputSelect String


type alias QueryArgs =
    { query : Maybe String
    , filters : List Filter
    , sort : Maybe String
    , page : Int
    , rows : Int
    , mode : ResultMode
    , facetBehaviours : List FacetBehaviour
    , facetSorts : Dict String FacetSort
    , facetModes : Dict String FacetMode
    }


toQueryArgs : { a | query : QueryArgs } -> QueryArgs
toQueryArgs activeSearch =
    activeSearch.query


setQueryArgs : QueryArgs -> { a | query : QueryArgs } -> { a | query : QueryArgs }
setQueryArgs newQuery oldRecord =
    { oldRecord | query = newQuery }


toMode : { a | mode : ResultMode } -> ResultMode
toMode queryArgs =
    queryArgs.mode


toFilters : { a | filters : List Filter } -> List Filter
toFilters queryArgs =
    queryArgs.filters


toggleFilters : Filter -> List Filter -> List Filter
toggleFilters newFilter oldFilters =
    if List.member newFilter oldFilters == True then
        LE.remove newFilter oldFilters

    else
        newFilter :: oldFilters


setFilters : List Filter -> { a | filters : List Filter } -> { a | filters : List Filter }
setFilters newFilters oldRecord =
    { oldRecord | filters = newFilters }


setMode : ResultMode -> { a | mode : ResultMode } -> { a | mode : ResultMode }
setMode newMode oldRecord =
    { oldRecord | mode = newMode }


toQuery : { a | query : Maybe String } -> Maybe String
toQuery qargs =
    qargs.query


setQuery : Maybe String -> { a | query : Maybe String } -> { a | query : Maybe String }
setQuery newQuery oldRecord =
    { oldRecord | query = newQuery }


setSort : Maybe String -> { a | sort : Maybe String } -> { a | sort : Maybe String }
setSort newSort oldRecord =
    { oldRecord | sort = newSort }


setPage : Int -> { a | page : Int } -> { a | page : Int }
setPage pageNum oldRecord =
    -- ensure the page number is 1 or greater
    if pageNum < 1 then
        { oldRecord | page = 1 }

    else
        { oldRecord | page = pageNum }


{-| Resets the page number to the first page.
-}
resetPage : { a | page : Int } -> { a | page : Int }
resetPage oldRecord =
    setPage 1 oldRecord


defaultQueryArgs : QueryArgs
defaultQueryArgs =
    { query = Nothing
    , filters = []
    , sort = Nothing
    , page = 1
    , rows = C.defaultRows
    , mode = SourcesMode
    , facetBehaviours = []
    , facetSorts = Dict.empty
    , facetModes = Dict.empty
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
            Dict.toList queryArgs.facetSorts
                |> List.map
                    (\( _, facetSort ) ->
                        let
                            sortStringValue =
                                case facetSort of
                                    AlphaSortOrder fieldName ->
                                        fieldName ++ ":alpha"

                                    CountSortOrder fieldName ->
                                        fieldName ++ ":count"
                        in
                        Url.Builder.string "fs" sortStringValue
                    )

        fmParams =
            Dict.toList queryArgs.facetModes
                |> List.map
                    (\( _, facetMode ) ->
                        let
                            modeStringValue =
                                case facetMode of
                                    TextInputSelect fieldName ->
                                        fieldName ++ ":text"

                                    CheckboxSelect fieldName ->
                                        fieldName ++ ":check"
                        in
                        Url.Builder.string "fm" modeStringValue
                    )

        pageParam =
            [ Url.Builder.string "page" (String.fromInt queryArgs.page) ]

        sortParam =
            case queryArgs.sort of
                Just s ->
                    [ Url.Builder.string "sort" s ]

                Nothing ->
                    []
    in
    List.concat [ qParam, modeParam, fqParams, fbParams, fsParams, fmParams, pageParam, sortParam ]


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
        |> apply fmParamParser


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


fsParamParser : Q.Parser (Dict String FacetSort)
fsParamParser =
    Q.custom "fs" (\a -> facetSortQueryStringToFacetSort a)


facetSortQueryStringToFacetSort : List String -> Dict String FacetSort
facetSortQueryStringToFacetSort fsList =
    List.filterMap
        (\a ->
            case String.split ":" a of
                [ field, value ] ->
                    case value of
                        "alpha" ->
                            Just ( field, AlphaSortOrder field )

                        "count" ->
                            Just ( field, CountSortOrder field )

                        _ ->
                            Nothing

                _ ->
                    Nothing
        )
        fsList
        |> Dict.fromList


fmParamParser : Q.Parser (Dict String FacetMode)
fmParamParser =
    Q.custom "fm" (\a -> facetModeQueryStringToFacetMode a)


facetModeQueryStringToFacetMode : List String -> Dict String FacetMode
facetModeQueryStringToFacetMode fmList =
    List.filterMap
        (\a ->
            case String.split ":" a of
                [ k, v ] ->
                    case v of
                        "check" ->
                            Just ( k, CheckboxSelect k )

                        "text" ->
                            Just ( k, TextInputSelect k )

                        _ ->
                            Nothing

                _ ->
                    Nothing
        )
        fmList
        |> Dict.fromList


modeParamParser : Q.Parser ResultMode
modeParamParser =
    Q.custom "mode" (\a -> modeQueryStringToResultMode a)


filterQueryStringToFilter : List String -> List Filter
filterQueryStringToFilter fqList =
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
            fqList
        )


modeQueryStringToResultMode : List String -> ResultMode
modeQueryStringToResultMode modeList =
    List.map (\a -> parseStringToResultMode a) modeList
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
