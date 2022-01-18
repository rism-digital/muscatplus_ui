module Page.Front.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (Facets)
import Response exposing (Response)


type alias FrontPageModel =
    { response : Response
    , activeSearch : ActiveSearch
    , facets : Facets
    , probeResponse : Maybe ProbeData
    , applyFilterPrompt : Bool
    }
