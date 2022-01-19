module Page.Front.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response)


type alias FrontPageModel =
    { response : Response
    , activeSearch : ActiveSearch
    , probeResponse : Maybe ProbeData
    , applyFilterPrompt : Bool
    }
