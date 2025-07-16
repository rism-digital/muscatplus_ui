module ActiveSearch exposing
    ( ActiveSearchConfig
    , empty
    , init
    , load
    , setActiveSearch
    , setActiveSuggestion
    , setActiveSuggestionDebouncer
    , setAliasLabelMap
    , setDownloader
    , setExpandedFacets
    , setKeyboard
    , setQueryBuilder
    , setQueryFacetValues
    , setRangeFacetValues
    , setResultsNotInCurrentMode
    , toActiveSearch
    , toExpandedFacets
    , toKeyboard
    , toQueryFacetValues
    , toRangeFacetValues
    , toResultsNotInCurrentMode
    )

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer, debounce, fromSeconds, toDebouncer)
import Dict exposing (Dict)
import Language exposing (LanguageMap)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (KeyboardQuery, setKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs, setRows)
import Page.QueryBuilder as QueryBuilder
import Page.RecordTypes.Search exposing (FacetItem)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import SearchPreferences exposing (SearchPreferences)
import Set exposing (Set)


type alias ActiveSearchConfig =
    { queryArgs : QueryArgs
    , keyboardQueryArgs : Maybe KeyboardQuery
    , searchPreferences : Maybe SearchPreferences
    }


empty : Maybe SearchPreferences -> ActiveSearch msg
empty searchPreferences =
    let
        queryArgs =
            Maybe.map .resultsPerPage searchPreferences
                |> Page.Query.defaultQueryArgs
    in
    { nextQuery = queryArgs
    , expandedFacets = Set.empty
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , aliasLabelMap = Dict.empty
    , keyboard = Just Keyboard.initModel
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , queryBuilder = Nothing
    , resultsNotInCurrentMode = []
    , downloader = Nothing
    }


init : ActiveSearchConfig -> ActiveSearch msg
init cfg =
    let
        keyboardQuery =
            Maybe.map
                (\kq ->
                    Keyboard.initModel
                        |> setKeyboardQuery kq
                )
                cfg.keyboardQueryArgs

        queryArgs =
            case cfg.searchPreferences of
                Just q ->
                    setRows q.resultsPerPage cfg.queryArgs

                Nothing ->
                    cfg.queryArgs
    in
    { nextQuery = queryArgs
    , expandedFacets = Set.empty
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , aliasLabelMap = Dict.empty
    , keyboard = keyboardQuery
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , queryBuilder = Nothing
    , resultsNotInCurrentMode = []
    , downloader = Nothing
    }


load : ActiveSearch msg -> ActiveSearch msg
load oldActiveSearch =
    { oldActiveSearch
        | rangeFacetValues = Dict.empty
        , queryFacetValues = Dict.empty
        , activeSuggestion = Nothing
    }


setActiveSearch : ActiveSearch msg -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
setActiveSearch newSearch oldRecord =
    { oldRecord | activeSearch = newSearch }


setActiveSuggestion : Maybe ActiveSuggestion -> { a | activeSuggestion : Maybe ActiveSuggestion } -> { a | activeSuggestion : Maybe ActiveSuggestion }
setActiveSuggestion newValue oldRecord =
    { oldRecord | activeSuggestion = newValue }


setAliasLabelMap : Dict FacetAlias LanguageMap -> { a | aliasLabelMap : Dict FacetAlias LanguageMap } -> { a | aliasLabelMap : Dict FacetAlias LanguageMap }
setAliasLabelMap newValue oldRecord =
    { oldRecord | aliasLabelMap = newValue }


setActiveSuggestionDebouncer : Debouncer msg -> { a | activeSuggestionDebouncer : Debouncer msg } -> { a | activeSuggestionDebouncer : Debouncer msg }
setActiveSuggestionDebouncer newValue oldRecord =
    { oldRecord | activeSuggestionDebouncer = newValue }


setExpandedFacets : Set String -> { a | expandedFacets : Set String } -> { a | expandedFacets : Set String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


setKeyboard : Maybe (Keyboard.Model KeyboardMsg) -> { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) } -> { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) }
setKeyboard newKeyboard oldRecord =
    { oldRecord | keyboard = newKeyboard }


setQueryBuilder : Maybe QueryBuilder.Model -> { a | queryBuilder : Maybe QueryBuilder.Model } -> { a | queryBuilder : Maybe QueryBuilder.Model }
setQueryBuilder newQueryBuilder oldRecord =
    { oldRecord | queryBuilder = newQueryBuilder }


setDownloader : Maybe DownloaderModel -> { a | downloader : Maybe DownloaderModel } -> { a | downloader : Maybe DownloaderModel }
setDownloader newDownloader oldRecord =
    { oldRecord | downloader = newDownloader }


setQueryFacetValues : Dict FacetAlias String -> { a | queryFacetValues : Dict FacetAlias String } -> { a | queryFacetValues : Dict FacetAlias String }
setQueryFacetValues newFacetValues oldRecord =
    { oldRecord | queryFacetValues = newFacetValues }


setRangeFacetValues : Dict FacetAlias ( String, String ) -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) }
setRangeFacetValues newValue oldRecord =
    { oldRecord | rangeFacetValues = newValue }


setResultsNotInCurrentMode : List FacetItem -> { a | resultsNotInCurrentMode : List FacetItem } -> { a | resultsNotInCurrentMode : List FacetItem }
setResultsNotInCurrentMode newValue oldRecord =
    { oldRecord | resultsNotInCurrentMode = newValue }


toActiveSearch : { a | activeSearch : ActiveSearch msg } -> ActiveSearch msg
toActiveSearch model =
    model.activeSearch


toExpandedFacets : { a | expandedFacets : Set String } -> Set String
toExpandedFacets model =
    model.expandedFacets


toKeyboard : { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) } -> Maybe (Keyboard.Model KeyboardMsg)
toKeyboard model =
    model.keyboard


toQueryFacetValues : { a | queryFacetValues : Dict FacetAlias String } -> Dict FacetAlias String
toQueryFacetValues model =
    model.queryFacetValues


toRangeFacetValues : { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> Dict FacetAlias ( String, String )
toRangeFacetValues model =
    model.rangeFacetValues


toResultsNotInCurrentMode : { a | resultsNotInCurrentMode : List FacetItem } -> List FacetItem
toResultsNotInCurrentMode model =
    model.resultsNotInCurrentMode
