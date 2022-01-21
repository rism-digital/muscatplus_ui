module Page.Search.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response, ServerData)


{-|

    Only one suggestion is (maybe) available at a time.

-}
type alias SearchPageModel =
    { response : Response ServerData
    , activeSearch : ActiveSearch
    , preview : Response ServerData
    , selectedResult : Maybe String
    , showFacetPanel : Bool
    , probeResponse : Response ProbeData
    , applyFilterPrompt : Bool
    }


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newValue oldRecord =
    { oldRecord | probeResponse = newValue }
