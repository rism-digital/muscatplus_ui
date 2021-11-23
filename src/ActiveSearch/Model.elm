module ActiveSearch.Model exposing (..)

import ActiveSearch.ActiveFacet exposing (ActiveFacet)
import Dict exposing (Dict)
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.UI.Facets.RangeSlider exposing (RangeSlider)
import Page.UI.Keyboard as Keyboard
import Response exposing (Response)


type alias ActiveSearch =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
    , activeFacets : List ActiveFacet
    , sliders : Dict String RangeSlider
    , keyboard : Keyboard.Model
    , selectedResultSort : Maybe String
    }
