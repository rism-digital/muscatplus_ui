module Search exposing (..)

import Page.Query exposing (QueryArgs)
import Page.Response exposing (ResultMode(..))
import Page.Route exposing (Route(..))


type alias ActiveSearch =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
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
    in
    { query = qargs
    , selectedMode = SourcesMode
    , expandedFacets = []
    }
