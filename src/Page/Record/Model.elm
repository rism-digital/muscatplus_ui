module Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.Route exposing (Route(..))
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Response exposing (Response, ServerData)
import Set exposing (Set)



{- | PrintHoldingsTab String -}


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | ContentsSearchDisplayTab String


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
    , probeResponse : ProbeStatus
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    , previewAnimationStatus : PreviewAnimationStatus
    }


routeToCurrentRecordViewTab : Route -> (String -> CurrentRecordViewTab)
routeToCurrentRecordViewTab route =
    case route of
        SourceContentsPageRoute _ _ ->
            ContentsSearchDisplayTab

        PersonSourcePageRoute _ _ ->
            ContentsSearchDisplayTab

        InstitutionSourcePageRoute _ _ ->
            ContentsSearchDisplayTab

        PublicationWorksPageRoute _ _ ->
            ContentsSearchDisplayTab

        WorkSourcePageRoute _ _ ->
            ContentsSearchDisplayTab

        _ ->
            DefaultRecordViewTab
