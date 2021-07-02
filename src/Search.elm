module Search exposing (..)

import Dict exposing (Dict)
import Page.Model exposing (Response(..))
import Page.Query exposing (Filter, QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.Route exposing (Route(..))
import Page.UI.Facets.RangeSlider exposing (RangeSlider)
import Search.ActiveFacet exposing (ActiveFacet)


type alias ActiveSearch =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
    , activeFacets : List ActiveFacet
    , sliders : Dict String RangeSlider
    , preview : Response
    , selectedResult : Maybe String
    }


init : Route -> ActiveSearch
init initialRoute =
    let
        qargs =
            case initialRoute of
                SearchPageRoute q ->
                    q

                _ ->
                    Page.Query.defaultQueryArgs

        initialMode =
            qargs.mode
    in
    { query = qargs
    , selectedMode = initialMode
    , expandedFacets = []
    , activeFacets = []
    , sliders = Dict.empty
    , preview = NoResponseToShow
    , selectedResult = Nothing
    }
