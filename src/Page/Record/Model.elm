module Page.Record.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Page.RecordTypes.Probe exposing (ProbeData)
import Response exposing (Response, ServerData)


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | RelatedSourcesSearchTab String


type alias RecordPageModel =
    { response : Response ServerData
    , currentTab : CurrentRecordViewTab
    , searchResults : Response ServerData
    , preview : Response ServerData
    , selectedResult : Maybe String
    , activeSearch : ActiveSearch
    , probeResponse : Response ProbeData
    , applyFilterPrompt : Bool
    }
