module Page.Query exposing
    ( FrontQueryArgs
    , QueryArgs
    , buildQueryParameters
    , defaultQueryArgs
    , frontQueryArgsToQueryArgs
    , frontQueryParamsParser
    , queryParamsParser
    , resetPage
    , setFacetBehaviours
    , setFacetSorts
    , setFilters
    , setKeywordQuery
    , setMode
    , setNationalCollection
    , setNextQuery
    , setRows
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
import Page.RecordTypes.Search
    exposing
        ( FacetBehaviours
        , FacetSorts
        , parseFacetBehaviourToString
        , parseFacetSortToString
        , parseStringToFacetBehaviour
        , parseStringToFacetSort
        )
import Page.RecordTypes.Shared exposing (FacetAlias)
import Request exposing (apply)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q
import Utlities exposing (fromListDedupe)


{-|

    A subset of the query args that are supported for the front page
    request. This is primarily to allow for a link to the initial page mode
    and national collections.

-}
type alias FrontQueryArgs =
    { mode : ResultMode
    , nationalCollection : Maybe String
    }


type alias QueryArgs =
    { keywordQuery : Maybe String
    , filters : Dict FacetAlias (List String)
    , sort : Maybe String
    , page : Int
    , rows : Int
    , mode : ResultMode
    , nationalCollection : Maybe String
    , facetBehaviours : Dict FacetAlias FacetBehaviours
    , facetSorts : Dict FacetAlias FacetSorts
    }


{-|

    Converts our application's QueryArgs to a set of QueryParameters
    suitable for Elm's internal URL handling.

-}
buildQueryParameters : QueryArgs -> List QueryParameter
buildQueryParameters queryArgs =
    let
        fbParams =
            Dict.toList queryArgs.facetBehaviours
                |> List.map
                    (\( alias, facetBehaviour ) ->
                        (alias ++ ":" ++ parseFacetBehaviourToString facetBehaviour)
                            |> Url.Builder.string "fb"
                    )

        fqParams =
            Dict.toList queryArgs.filters
                |> List.concatMap
                    (\( alias, filts ) ->
                        let
                            allFilts =
                                List.filterMap (\s -> createPrefixedField s) filts

                            createPrefixedField val =
                                if String.isEmpty val then
                                    Nothing

                                else
                                    Just (alias ++ ":" ++ val)
                        in
                        List.map (Url.Builder.string "fq") allFilts
                    )

        fsParams =
            Dict.toList queryArgs.facetSorts
                |> List.map
                    (\( alias, sort ) ->
                        (alias ++ ":" ++ parseFacetSortToString sort)
                            |> Url.Builder.string "fs"
                    )

        modeParam =
            [ Url.Builder.string "mode" <|
                parseResultModeToString queryArgs.mode
            ]

        ncParam =
            case queryArgs.nationalCollection of
                Just countryPrefix ->
                    [ Url.Builder.string "nc" countryPrefix ]

                Nothing ->
                    []

        pageParam =
            [ String.fromInt queryArgs.page
                |> Url.Builder.string "page"
            ]

        qParam =
            case queryArgs.keywordQuery of
                Just q ->
                    [ Url.Builder.string "q" q ]

                Nothing ->
                    []

        rowsParam =
            [ String.fromInt queryArgs.rows
                |> Url.Builder.string "rows"
            ]

        sortParam =
            case queryArgs.sort of
                Just s ->
                    [ Url.Builder.string "sort" s ]

                Nothing ->
                    []
    in
    List.concat [ qParam, ncParam, modeParam, fqParams, fbParams, fsParams, pageParam, sortParam, rowsParam ]


defaultQueryArgs : QueryArgs
defaultQueryArgs =
    { keywordQuery = Nothing
    , filters = Dict.empty
    , sort = Nothing
    , page = 1
    , rows = C.defaultRows
    , mode = SourcesMode
    , nationalCollection = Nothing
    , facetBehaviours = Dict.empty
    , facetSorts = Dict.empty
    }


frontQueryArgsToQueryArgs : FrontQueryArgs -> QueryArgs
frontQueryArgsToQueryArgs frontQuery =
    let
        initialQueryArgs =
            defaultQueryArgs
    in
    { initialQueryArgs
        | mode = frontQuery.mode
        , nationalCollection = frontQuery.nationalCollection
    }


frontQueryParamsParser : Q.Parser FrontQueryArgs
frontQueryParamsParser =
    Q.map FrontQueryArgs modeParamParser
        |> apply (Q.string "nc")


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
        |> apply (Q.string "nc")
        |> apply fbParamParser
        |> apply fsParamParser


{-| Resets the page number to the first page.
-}
resetPage : { a | page : Int } -> { a | page : Int }
resetPage oldRecord =
    setPage 1 oldRecord


setFacetBehaviours : Dict FacetAlias FacetBehaviours -> { a | facetBehaviours : Dict FacetAlias FacetBehaviours } -> { a | facetBehaviours : Dict FacetAlias FacetBehaviours }
setFacetBehaviours newBehaviours oldRecord =
    { oldRecord | facetBehaviours = newBehaviours }


setFacetSorts : Dict FacetAlias FacetSorts -> { a | facetSorts : Dict FacetAlias FacetSorts } -> { a | facetSorts : Dict FacetAlias FacetSorts }
setFacetSorts newValues oldRecord =
    { oldRecord | facetSorts = newValues }


setFilters : Dict FacetAlias (List String) -> { a | filters : Dict FacetAlias (List String) } -> { a | filters : Dict FacetAlias (List String) }
setFilters newFilters oldRecord =
    { oldRecord | filters = newFilters }


setKeywordQuery : Maybe String -> { a | keywordQuery : Maybe String } -> { a | keywordQuery : Maybe String }
setKeywordQuery newQuery oldRecord =
    { oldRecord | keywordQuery = newQuery }


setMode : ResultMode -> { a | mode : ResultMode } -> { a | mode : ResultMode }
setMode newMode oldRecord =
    { oldRecord | mode = newMode }


setNationalCollection : Maybe String -> { a | nationalCollection : Maybe String } -> { a | nationalCollection : Maybe String }
setNationalCollection newValue oldRecord =
    { oldRecord | nationalCollection = newValue }


setNextQuery : QueryArgs -> { a | nextQuery : QueryArgs } -> { a | nextQuery : QueryArgs }
setNextQuery newQuery oldRecord =
    { oldRecord | nextQuery = newQuery }


setRows : Int -> { a | rows : Int } -> { a | rows : Int }
setRows newRows oldRecord =
    { oldRecord | rows = newRows }


setSort : Maybe String -> { a | sort : Maybe String } -> { a | sort : Maybe String }
setSort newSort oldRecord =
    { oldRecord | sort = newSort }


toFacetBehaviours : { a | facetBehaviours : Dict FacetAlias FacetBehaviours } -> Dict FacetAlias FacetBehaviours
toFacetBehaviours query =
    query.facetBehaviours


toFacetSorts : { a | facetSorts : Dict FacetAlias FacetSorts } -> Dict FacetAlias FacetSorts
toFacetSorts query =
    query.facetSorts


toFilters : { a | filters : Dict FacetAlias (List String) } -> Dict FacetAlias (List String)
toFilters queryArgs =
    queryArgs.filters


toKeywordQuery : { a | keywordQuery : Maybe String } -> Maybe String
toKeywordQuery qargs =
    qargs.keywordQuery


toMode : { a | mode : ResultMode } -> ResultMode
toMode queryArgs =
    queryArgs.mode


toNextQuery : { a | nextQuery : QueryArgs } -> QueryArgs
toNextQuery activeSearch =
    activeSearch.nextQuery


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


fbParamParser : Q.Parser (Dict FacetAlias FacetBehaviours)
fbParamParser =
    Q.custom "fb" (\a -> facetBehaviourQueryStringToBehaviour a)


filterQueryStringToFilter : List String -> Dict FacetAlias (List String)
filterQueryStringToFilter fqList =
    -- discards any filters that do not conform to the expected values
    -- TODO: Convert this to a parser that can handle colons in the 'values'
    List.filterMap stringSplitToList fqList
        |> fromListDedupe (\a b -> List.append a b)


fqParamParser : Q.Parser (Dict FacetAlias (List String))
fqParamParser =
    Q.custom "fq" (\a -> filterQueryStringToFilter a)


fsParamParser : Q.Parser (Dict String FacetSorts)
fsParamParser =
    Q.custom "fs" (\a -> facetSortQueryStringToFacetSort a)


modeParamParser : Q.Parser ResultMode
modeParamParser =
    Q.custom "mode" (\a -> modeQueryStringToResultMode a)


modeQueryStringToResultMode : List String -> ResultMode
modeQueryStringToResultMode modeList =
    List.map (\a -> parseStringToResultMode a) modeList
        |> List.head
        |> Maybe.withDefault SourcesMode


pageParamParser : Q.Parser Int
pageParamParser =
    -- returns 1 if the page parameter cannot be parsed to an int.
    Q.custom "page" <|
        \stringList ->
            case stringList of
                [ str ] ->
                    Maybe.withDefault 1 (String.toInt str)

                _ ->
                    1


rowsParamParser : Q.Parser Int
rowsParamParser =
    -- returns the default rows if the rows parameter cannot be parsed to an int.
    Q.custom "rows" <|
        \stringList ->
            case stringList of
                [ str ] ->
                    Maybe.withDefault 1 (String.toInt str)

                _ ->
                    C.defaultRows


setPage : Int -> { a | page : Int } -> { a | page : Int }
setPage pageNum oldRecord =
    -- ensure the page number is 1 or greater
    if pageNum < 1 then
        { oldRecord | page = 1 }

    else
        { oldRecord | page = pageNum }


stringSplitToList : String -> Maybe ( String, List String )
stringSplitToList str =
    case String.split ":" str of
        alias :: values ->
            Just ( alias, values )

        _ ->
            Nothing


toNationalCollection : { a | nationalCollection : Maybe String } -> Maybe String
toNationalCollection qargs =
    qargs.nationalCollection
