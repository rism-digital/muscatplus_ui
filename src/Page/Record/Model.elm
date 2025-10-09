module Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, TabRecordTypeContents(..), routeToCurrentRecordViewTab)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.Route exposing (Route(..))
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Response exposing (Response, ServerData)
import Set exposing (Set)


type TabRecordTypeContents
    = SourceContents
    | HoldingContents
    | WorksContents
    | InventoryItemsContents


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | ContentsSearchDisplayTab TabRecordTypeContents String


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
            ContentsSearchDisplayTab SourceContents

        SourceInventoryItemsPageRoute _ _ ->
            ContentsSearchDisplayTab InventoryItemsContents

        PersonSourcePageRoute _ _ ->
            ContentsSearchDisplayTab SourceContents

        InstitutionSourcePageRoute _ _ ->
            ContentsSearchDisplayTab SourceContents

        PublicationWorksPageRoute _ _ ->
            ContentsSearchDisplayTab SourceContents

        WorkSourcePageRoute _ _ ->
            ContentsSearchDisplayTab SourceContents

        _ ->
            DefaultRecordViewTab
