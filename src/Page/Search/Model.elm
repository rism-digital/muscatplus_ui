module Page.Search.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response)


{-|

    Only one suggestion is (maybe) available at a time.

-}
type alias SearchPageModel =
    { response : Response
    , activeSearch : ActiveSearch
    , preview : Response
    , selectedResult : Maybe String
    , showFacetPanel : Bool
    , probeResponse : Maybe ProbeData
    }


setProbeResponse : Maybe ProbeData -> { a | probeResponse : Maybe ProbeData } -> { a | probeResponse : Maybe ProbeData }
setProbeResponse newValue oldRecord =
    { oldRecord | probeResponse = newValue }
