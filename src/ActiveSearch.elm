module ActiveSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import Page.Query exposing (Filter, QueryArgs)
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

        initialMode =
            qargs.mode

        initialSort =
            qargs.sort

        initialKeyboardModel =
            Keyboard.initModel

        updatedKeyboardModel =
            { initialKeyboardModel | query = kqargs }
    in
    { query = qargs
    , selectedMode = initialMode
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


toKeyboard : { a | keyboard : Keyboard.Model } -> Keyboard.Model
toKeyboard model =
    model.keyboard
