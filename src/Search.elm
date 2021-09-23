module Search exposing (..)

import Dict exposing (Dict)
import Page.Model exposing (Response(..))
import Page.Query exposing (Filter, QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.Route exposing (Route(..))
import Page.UI.Facets.RangeSlider exposing (RangeSlider)
import Page.UI.Keyboard as Keyboard
import Search.ActiveFacet exposing (ActiveFacet)


type alias ActiveSearch =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
    , activeFacets : List ActiveFacet
    , sliders : Dict String RangeSlider
    , preview : Response
    , selectedResult : Maybe String
    , keyboard : Keyboard.Model
    , selectedResultSort : Maybe String
    }


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
    , preview = NoResponseToShow
    , selectedResult = Nothing
    , keyboard = updatedKeyboardModel
    , selectedResultSort = initialSort
    }
