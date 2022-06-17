module ActiveSearch exposing (ActiveSearchConfig, empty, init, setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setExpandedFacets, setKeyboard, setQueryFacetValues, setRangeFacetValues, toActiveSearch, toActiveSuggestion, toExpandedFacets, toKeyboard, toQueryFacetValues, toRangeFacetValues, toggleExpandedFacets)

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


type alias ActiveSearchConfig =
    { queryArgs : QueryArgs
    , keyboardQueryArgs : Maybe KeyboardQuery
    }


empty : ActiveSearch msg
empty =
    { nextQuery = Page.Query.defaultQueryArgs
    , expandedFacets = []
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , keyboard = Just <| Keyboard.initModel
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
    , expandedFacets = []
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    , keyboard = keyboardQuery
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
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


setExpandedFacets : List String -> { a | expandedFacets : List String } -> { a | expandedFacets : List String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


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


toActiveSuggestion : { a | activeSuggestion : Maybe ActiveSuggestion } -> Maybe ActiveSuggestion
toActiveSuggestion model =
    model.activeSuggestion


toExpandedFacets : { a | expandedFacets : List String } -> List String
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


toggleExpandedFacets : String -> List String -> List String
toggleExpandedFacets newFacet oldFacets =
    if List.member newFacet oldFacets then
        LE.remove newFacet oldFacets

    else
        newFacet :: oldFacets
