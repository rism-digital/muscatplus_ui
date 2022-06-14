module Page.Record.Model exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.Route exposing (Route(..))
import Response exposing (Response, ServerData)


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | RelatedSourcesSearchTab String


type alias RecordPageModel msg =
    { response : Response ServerData
    , currentTab : CurrentRecordViewTab
    , searchResults : Response ServerData
    , preview : Response ServerData
    , selectedResult : Maybe String
    , activeSearch : ActiveSearch msg
    , probeResponse : Response ProbeData
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    }


routeToCurrentRecordViewTab : Route -> (String -> CurrentRecordViewTab)
routeToCurrentRecordViewTab route =
    case route of
        InstitutionSourcePageRoute _ _ ->
            RelatedSourcesSearchTab

        PersonSourcePageRoute _ _ ->
            RelatedSourcesSearchTab

        SourceContentsPageRoute _ _ ->
            RelatedSourcesSearchTab

        _ ->
            DefaultRecordViewTab
