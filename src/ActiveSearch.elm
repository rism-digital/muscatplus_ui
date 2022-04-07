module ActiveSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer, debounce, fromSeconds, toDebouncer)
import Dict exposing (Dict)
import List.Extra as LE
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Route exposing (Route(..))


init : Route -> ActiveSearch msg
init initialRoute =
    let
        ( qargs, kqargs ) =
            case initialRoute of
                SearchPageRoute q kq ->
                    ( q, kq )

                _ ->
                    ( Page.Query.defaultQueryArgs
                    , Keyboard.defaultKeyboardQuery
                    )

        initialSort =
            qargs.sort

        initialKeyboardModel =
            Keyboard.initModel

        updatedKeyboardModel =
            { initialKeyboardModel | query = kqargs }
    in
    { nextQuery = qargs
    , expandedFacets = []
    , keyboard = updatedKeyboardModel
    , selectedResultSort = initialSort
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    }


empty : ActiveSearch msg
empty =
    { nextQuery = Page.Query.defaultQueryArgs
    , expandedFacets = []
    , keyboard = Keyboard.initModel
    , selectedResultSort = Nothing
    , activeSuggestion = Nothing
    , activeSuggestionDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , rangeFacetValues = Dict.empty
    , queryFacetValues = Dict.empty
    }


toActiveSearch : { a | activeSearch : ActiveSearch msg } -> ActiveSearch msg
toActiveSearch model =
    model.activeSearch


setActiveSearch : ActiveSearch msg -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
setActiveSearch newSearch oldRecord =
    { oldRecord | activeSearch = newSearch }


toKeyboard : { a | keyboard : Keyboard.Model KeyboardMsg } -> Keyboard.Model KeyboardMsg
toKeyboard model =
    model.keyboard


setKeyboard : Keyboard.Model KeyboardMsg -> { a | keyboard : Keyboard.Model KeyboardMsg } -> { a | keyboard : Keyboard.Model KeyboardMsg }
setKeyboard newKeyboard oldRecord =
    { oldRecord | keyboard = newKeyboard }


toExpandedFacets : { a | expandedFacets : List String } -> List String
toExpandedFacets model =
    model.expandedFacets


setExpandedFacets : List String -> { a | expandedFacets : List String } -> { a | expandedFacets : List String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


toQueryFacetValues : { a | queryFacetValues : Dict FacetAlias String } -> Dict FacetAlias String
toQueryFacetValues model =
    model.queryFacetValues


setQueryFacetValues : Dict FacetAlias String -> { a | queryFacetValues : Dict FacetAlias String } -> { a | queryFacetValues : Dict FacetAlias String }
setQueryFacetValues newFacetValues oldRecord =
    { oldRecord | queryFacetValues = newFacetValues }


setActiveSuggestionDebouncer : Debouncer msg -> { a | activeSuggestionDebouncer : Debouncer msg } -> { a | activeSuggestionDebouncer : Debouncer msg }
setActiveSuggestionDebouncer newValue oldRecord =
    { oldRecord | activeSuggestionDebouncer = newValue }


toggleExpandedFacets : String -> List String -> List String
toggleExpandedFacets newFacet oldFacets =
    if List.member newFacet oldFacets then
        LE.remove newFacet oldFacets

    else
        newFacet :: oldFacets


toActiveSuggestion : { a | activeSuggestion : Maybe ActiveSuggestion } -> Maybe ActiveSuggestion
toActiveSuggestion model =
    model.activeSuggestion


setActiveSuggestion : Maybe ActiveSuggestion -> { a | activeSuggestion : Maybe ActiveSuggestion } -> { a | activeSuggestion : Maybe ActiveSuggestion }
setActiveSuggestion newValue oldRecord =
    { oldRecord | activeSuggestion = newValue }


toRangeFacetValues : { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> Dict FacetAlias ( String, String )
toRangeFacetValues model =
    model.rangeFacetValues


setRangeFacetValues : Dict FacetAlias ( String, String ) -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) } -> { a | rangeFacetValues : Dict FacetAlias ( String, String ) }
setRangeFacetValues newValue oldRecord =
    { oldRecord | rangeFacetValues = newValue }
