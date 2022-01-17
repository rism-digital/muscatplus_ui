module ActiveSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Route exposing (Route(..))
import Page.UI.Keyboard as Keyboard


init : Route -> ActiveSearch
init initialRoute =
    let
        ( qargs, kqargs ) =
            case initialRoute of
                SearchPageRoute q kq ->
                    ( q, kq )

                _ ->
                    ( Page.Query.defaultQueryArgs, Keyboard.defaultKeyboardQuery )

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
    , rangeFacetValues = Dict.empty
    }


empty : ActiveSearch
empty =
    { nextQuery = Page.Query.defaultQueryArgs
    , expandedFacets = []
    , keyboard = Keyboard.initModel
    , selectedResultSort = Nothing
    , activeSuggestion = Nothing
    , rangeFacetValues = Dict.empty
    }


toActiveSearch : { a | activeSearch : ActiveSearch } -> ActiveSearch
toActiveSearch model =
    model.activeSearch


setActiveSearch : ActiveSearch -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
setActiveSearch newSearch oldRecord =
    { oldRecord | activeSearch = newSearch }


toKeyboard : { a | keyboard : Keyboard.Model } -> Keyboard.Model
toKeyboard model =
    model.keyboard


setKeyboard : Keyboard.Model -> { a | keyboard : Keyboard.Model } -> { a | keyboard : Keyboard.Model }
setKeyboard newKeyboard oldRecord =
    { oldRecord | keyboard = newKeyboard }


toExpandedFacets : { a | expandedFacets : List String } -> List String
toExpandedFacets model =
    model.expandedFacets


setExpandedFacets : List String -> { a | expandedFacets : List String } -> { a | expandedFacets : List String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


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
