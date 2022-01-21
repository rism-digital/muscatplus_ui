module Page.Front.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response, ServerData)


type alias FrontPageModel =
    { response : Response ServerData
    , activeSearch : ActiveSearch
    , probeResponse : Response ProbeData
    , applyFilterPrompt : Bool
    }
