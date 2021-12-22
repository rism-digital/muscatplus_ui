module Page.Query exposing
    ( QueryArgs
    , buildQueryParameters
    , defaultQueryArgs
    , queryParamsParser
    , resetPage
    , setFacetBehaviours
    , setFacetSorts
    , setFilters
    , setKeywordQuery
    , setMode
    , setNextQuery
    , setSort
    , toFacetBehaviours
    , toFacetSorts
    , toFilters
    , toKeywordQuery
    , toMode
    , toNextQuery
    )

import Config as C
import Dict exposing (Dict)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseResultModeToString, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, parseFacetBehaviourToString, parseFacetSortToString, parseStringToFacetBehaviour, parseStringToFacetSort)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q
import Utlities exposing (fromListDedupe)


type alias QueryArgs =
    { keywordQuery : Maybe String
    , filters : Dict FacetAlias (List String)
    , sort : Maybe String
    , page : Int
    , rows : Int
    , mode : ResultMode
    , facetBehaviours : Dict FacetAlias FacetBehaviours
    , facetSorts : Dict FacetAlias FacetSorts
    }


toNextQuery : { a | nextQuery : QueryArgs } -> QueryArgs
toNextQuery activeSearch =
    activeSearch.nextQuery


setNextQuery : QueryArgs -> { a | nextQuery : QueryArgs } -> { a | nextQuery : QueryArgs }
setNextQuery newQuery oldRecord =
    { oldRecord | nextQuery = newQuery }


toMode : { a | mode : ResultMode } -> ResultMode
toMode queryArgs =
    queryArgs.mode


toFilters : { a | filters : Dict FacetAlias (List String) } -> Dict FacetAlias (List String)
toFilters queryArgs =
    queryArgs.filters


setFilters : Dict FacetAlias (List String) -> { a | filters : Dict FacetAlias (List String) } -> { a | filters : Dict FacetAlias (List String) }
setFilters newFilters oldRecord =
    { oldRecord | filters = newFilters }


setMode : ResultMode -> { a | mode : ResultMode } -> { a | mode : ResultMode }
setMode newMode oldRecord =
    { oldRecord | mode = newMode }


toKeywordQuery : { a | keywordQuery : Maybe String } -> Maybe String
toKeywordQuery qargs =
    qargs.keywordQuery


setKeywordQuery : Maybe String -> { a | keywordQuery : Maybe String } -> { a | keywordQuery : Maybe String }
setKeywordQuery newQuery oldRecord =
    { oldRecord | keywordQuery = newQuery }


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


toFacetBehaviours : { a | facetBehaviours : Dict FacetAlias FacetBehaviours } -> Dict FacetAlias FacetBehaviours
toFacetBehaviours query =
    query.facetBehaviours


setFacetBehaviours : Dict FacetAlias FacetBehaviours -> { a | facetBehaviours : Dict FacetAlias FacetBehaviours } -> { a | facetBehaviours : Dict FacetAlias FacetBehaviours }
setFacetBehaviours newBehaviours oldRecord =
    { oldRecord | facetBehaviours = newBehaviours }


toFacetSorts : { a | facetSorts : Dict FacetAlias FacetSorts } -> Dict FacetAlias FacetSorts
toFacetSorts query =
    query.facetSorts


setFacetSorts : Dict FacetAlias FacetSorts -> { a | facetSorts : Dict FacetAlias FacetSorts } -> { a | facetSorts : Dict FacetAlias FacetSorts }
setFacetSorts newValues oldRecord =
    { oldRecord | facetSorts = newValues }


{-| Resets the page number to the first page.
-}
resetPage : { a | page : Int } -> { a | page : Int }
resetPage oldRecord =
    setPage 1 oldRecord


defaultQueryArgs : QueryArgs
defaultQueryArgs =
    { keywordQuery = Nothing
    , filters = Dict.empty
    , sort = Nothing
    , page = 1
    , rows = C.defaultRows
    , mode = SourcesMode
    , facetBehaviours = Dict.empty
    , facetSorts = Dict.empty
    }


{-|

    Converts our application's QueryArgs to a set of QueryParameters
    suitable for Elm's internal URL handling.

-}
buildQueryParameters : QueryArgs -> List QueryParameter
buildQueryParameters queryArgs =
    let
        qParam =
            case queryArgs.keywordQuery of
                Just q ->
                    [ Url.Builder.string "q" q ]

                Nothing ->
                    []

        modeParam =
            [ Url.Builder.string "mode" (parseResultModeToString queryArgs.mode) ]

        fqParams =
            List.concatMap
                (\( alias, filts ) ->
                    let
                        createPrefixedField val =
                            if String.isEmpty val == True then
                                Nothing

                            else
                                Just (alias ++ ":" ++ val)

                        allFilts =
                            List.filterMap (\s -> createPrefixedField s) filts
                    in
                    List.map (Url.Builder.string "fq") allFilts
                )
                (Dict.toList queryArgs.filters)

        fbParams =
            List.map
                (\( alias, facetBehaviour ) ->
                    Url.Builder.string "fb" (alias ++ ":" ++ parseFacetBehaviourToString facetBehaviour)
                )
                (Dict.toList queryArgs.facetBehaviours)

        fsParams =
            List.map
                (\( alias, sort ) ->
                    Url.Builder.string "fs" (alias ++ ":" ++ parseFacetSortToString sort)
                )
                (Dict.toList queryArgs.facetSorts)

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


fqParamParser : Q.Parser (Dict FacetAlias (List String))
fqParamParser =
    Q.custom "fq" (\a -> filterQueryStringToFilter a)


fbParamParser : Q.Parser (Dict FacetAlias FacetBehaviours)
fbParamParser =
    Q.custom "fb" (\a -> facetBehaviourQueryStringToBehaviour a)


facetBehaviourQueryStringToBehaviour : List String -> Dict FacetAlias FacetBehaviours
facetBehaviourQueryStringToBehaviour fbList =
    List.filterMap stringSplitToList fbList
        |> Dict.fromList
        |> Dict.map
            (\_ value ->
                List.head value
                    |> Maybe.withDefault "intersection"
                    |> parseStringToFacetBehaviour
            )


fsParamParser : Q.Parser (Dict String FacetSorts)
fsParamParser =
    Q.custom "fs" (\a -> facetSortQueryStringToFacetSort a)


facetSortQueryStringToFacetSort : List String -> Dict String FacetSorts
facetSortQueryStringToFacetSort fsList =
    List.filterMap stringSplitToList fsList
        |> Dict.fromList
        |> Dict.map
            (\_ value ->
                List.head value
                    |> Maybe.withDefault "alpha"
                    |> parseStringToFacetSort
            )


modeParamParser : Q.Parser ResultMode
modeParamParser =
    Q.custom "mode" (\a -> modeQueryStringToResultMode a)


filterQueryStringToFilter : List String -> Dict FacetAlias (List String)
filterQueryStringToFilter fqList =
    -- discards any filters that do not conform to the expected values
    -- TODO: Convert this to a parser that can handle colons in the 'values'
    List.filterMap stringSplitToList fqList
        |> fromListDedupe (\a b -> List.append a b)


stringSplitToList : String -> Maybe ( String, List String )
stringSplitToList str =
    case String.split ":" str of
        alias :: values ->
            Just ( alias, values )

        _ ->
            Nothing


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
