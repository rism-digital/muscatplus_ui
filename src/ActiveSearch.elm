module ActiveSearch exposing (ActiveSearchConfig, empty, init, load, setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setExpandedFacetPanels, setExpandedFacets, setKeyboard, setQueryFacetValues, setRangeFacetValues, toActiveSearch, toExpandedFacetPanels, toExpandedFacets, toKeyboard, toQueryFacetValues, toRangeFacetValues, toggleExpandedFacetPanel, toggleExpandedFacets)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer, debounce, fromSeconds, toDebouncer)
import Dict exposing (Dict)
import List.Extra as LE
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (KeyboardQuery, setKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Set exposing (Set)


type alias ActiveSearchConfig =
    { queryArgs : QueryArgs
    , keyboardQueryArgs : Maybe KeyboardQuery
    }


empty : ActiveSearch msg
empty =
    { nextQuery = Page.Query.defaultQueryArgs
    , expandedFacets = Set.empty
    , expandedFacetPanels = Set.empty
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , keyboard = Just Keyboard.initModel
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    }


init : ActiveSearchConfig -> ActiveSearch msg
init cfg =
    let
        keyboardQuery =
            case cfg.keyboardQueryArgs of
                Just kq ->
                    Keyboard.initModel
                        |> setKeyboardQuery kq
                        |> Just

                Nothing ->
                    Nothing
    in
    { nextQuery = cfg.queryArgs
    , expandedFacets = Set.empty
    , expandedFacetPanels = Set.empty
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , keyboard = keyboardQuery
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
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


setActiveSuggestionDebouncer : Debouncer msg -> { a | activeSuggestionDebouncer : Debouncer msg } -> { a | activeSuggestionDebouncer : Debouncer msg }
setActiveSuggestionDebouncer newValue oldRecord =
    { oldRecord | activeSuggestionDebouncer = newValue }


setExpandedFacets : Set String -> { a | expandedFacets : Set String } -> { a | expandedFacets : Set String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


setExpandedFacetPanels : Set String -> { a | expandedFacetPanels : Set String } -> { a | expandedFacetPanels : Set String }
setExpandedFacetPanels newPanels oldRecord =
    { oldRecord | expandedFacetPanels = newPanels }


setKeyboard : Maybe (Keyboard.Model KeyboardMsg) -> { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) } -> { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) }
setKeyboard newKeyboard oldRecord =
    { oldRecord | keyboard = newKeyboard }


setQueryFacetValues : Dict FacetAlias String -> { a | queryFacetValues : Dict FacetAlias String } -> { a | queryFacetValues : Dict FacetAlias String }
setQueryFacetValues newFacetValues oldRecord =
    { oldRecord | queryFacetValues = newFacetValues }


setRangeFacetValues : Dict FacetAlias ( String, String ) -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) }
setRangeFacetValues newValue oldRecord =
    { oldRecord | rangeFacetValues = newValue }


toActiveSearch : { a | activeSearch : ActiveSearch msg } -> ActiveSearch msg
toActiveSearch model =
    model.activeSearch


toExpandedFacets : { a | expandedFacets : Set String } -> Set String
toExpandedFacets model =
    model.expandedFacets


toExpandedFacetPanels : { a | expandedFacetPanels : Set String } -> Set String
toExpandedFacetPanels model =
    model.expandedFacetPanels


toKeyboard : { a | keyboard : Maybe (Keyboard.Model KeyboardMsg) } -> Maybe (Keyboard.Model KeyboardMsg)
toKeyboard model =
    model.keyboard


toQueryFacetValues : { a | queryFacetValues : Dict FacetAlias String } -> Dict FacetAlias String
toQueryFacetValues model =
    model.queryFacetValues


toRangeFacetValues : { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> Dict FacetAlias ( String, String )
toRangeFacetValues model =
    model.rangeFacetValues


toggleExpandedFacets : String -> Set String -> Set String
toggleExpandedFacets newFacet oldFacets =
    if Set.member newFacet oldFacets then
        Set.remove newFacet oldFacets

    else
        Set.insert newFacet oldFacets


toggleExpandedFacetPanel : String -> Set String -> Set String
toggleExpandedFacetPanel alias panels =
    if Set.member alias panels then
        Set.remove alias panels

    else
        Set.insert alias panels


toActiveSuggestion : { a | activeSuggestion : Maybe ActiveSuggestion } -> Maybe ActiveSuggestion
toActiveSuggestion model =
    model.activeSuggestion
