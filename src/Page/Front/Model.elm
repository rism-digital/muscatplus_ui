module Page.Front.Model exposing (FrontPageModel)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response, ServerData)


type alias FrontPageModel msg =
    { response : Response ServerData
    , activeSearch : ActiveSearch msg
    , probeResponse : Response ProbeData
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    }
