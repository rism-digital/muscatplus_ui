module Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.Route exposing (Route(..))
import Response exposing (Response, ServerData)
import Set exposing (Set)


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | RelatedSourcesSearchTab String
    | PrintHoldingsTab String


type alias RecordPageModel msg =
    { response : Response ServerData
    , currentTab : CurrentRecordViewTab
    , searchResults : Response ServerData
    , preview : Response ServerData
    , sourceItemsExpanded : Bool
    , incipitInfoExpanded : Set String
    , digitizedCopiesCalloutExpanded : Bool
    , selectedResult : Maybe String
    , activeSearch : ActiveSearch msg
    , probeResponse : Response ProbeData
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    }


routeToCurrentRecordViewTab : Route -> (String -> CurrentRecordViewTab)
routeToCurrentRecordViewTab route =
    case route of
        SourceContentsPageRoute _ _ ->
            RelatedSourcesSearchTab

        PersonSourcePageRoute _ _ ->
            RelatedSourcesSearchTab

        InstitutionSourcePageRoute _ _ ->
            RelatedSourcesSearchTab

        _ ->
            DefaultRecordViewTab
