module Search exposing (..)

import Page.Model exposing (Response(..))
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.Route exposing (Route(..))


type alias ActiveSearch =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
    , preview : Response
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
    , preview = NoResponseToShow
    }
