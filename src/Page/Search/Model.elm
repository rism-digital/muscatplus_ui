module Page.Search.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
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
    , activeSuggestion : Maybe ActiveSuggestion
    , probeResponse : Maybe ProbeData
    }


setActiveSuggestion : Maybe ActiveSuggestion -> { a | activeSuggestion : Maybe ActiveSuggestion } -> { a | activeSuggestion : Maybe ActiveSuggestion }
setActiveSuggestion newValue oldRecord =
    { oldRecord | activeSuggestion = newValue }


setProbeResponse : Maybe ProbeData -> { a | probeResponse : Maybe ProbeData } -> { a | probeResponse : Maybe ProbeData }
setProbeResponse newValue oldRecord =
    { oldRecord | probeResponse = newValue }
