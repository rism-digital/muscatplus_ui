module ActiveSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query exposing (Filter, QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode)
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
    { query = qargs
    , expandedFacets = []
    , activeFacets = []
    , sliders = Dict.empty
    , keyboard = updatedKeyboardModel
    , selectedResultSort = initialSort
    }


toActiveSearch : { a | activeSearch : ActiveSearch } -> ActiveSearch
toActiveSearch model =
    model.activeSearch


setActiveSearch : ActiveSearch -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
setActiveSearch newSearch oldRecord =
    { oldRecord | activeSearch = newSearch }


toSelectedMode : { a | selectedMode : ResultMode } -> ResultMode
toSelectedMode model =
    model.selectedMode


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
