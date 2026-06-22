module Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)

import ActiveSearch.Model exposing (ActiveSearch)
import Debouncer.Messages exposing (Debouncer)
import Page.RecordTypes.Inventory exposing (InventoryItemsBody)
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.RecordTypes.SearchControl exposing (SearchControlOptions)
import Page.Route exposing (Route(..))
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Response exposing (Response, ServerData)
import Set exposing (Set)



{- | PrintHoldingsTab String -}


type CurrentRecordViewTab
    = DefaultRecordViewTab String
    | ContentsSearchDisplayTab String
    | InventoryItemsDisplayTab String


type alias RecordPageModel msg =
    { response : Response ServerData
    , currentTab : CurrentRecordViewTab
    , searchResults : Response ServerData
    , inventoryItems : Response InventoryItemsBody
    , preview : Response ServerData
    , resultsPanelWidth : Maybe Int
    , resultsPanelResize : Maybe { startClientX : Int, startResultsWidth : Int, currentResultsWidth : Int }
    , pendingResultsScrollReset : Bool
    , sourceItemsExpanded : Bool
    , inventoryItemsExpanded : Bool
    , incipitInfoExpanded : Set String
    , digitizedCopiesCalloutExpanded : Bool
    , selectedResult : Maybe String
    , activeSearch : ActiveSearch msg
    , probeResponse : ProbeStatus
    , probeDebouncer : Debouncer msg
    , applyFilterPrompt : Bool
    , previewAnimationStatus : PreviewAnimationStatus
    , showSearchControls : SearchControlOptions
    }


routeToCurrentRecordViewTab : Route -> (String -> CurrentRecordViewTab)
routeToCurrentRecordViewTab route =
    case route of
        SourceContentsPageRoute _ _ ->
            ContentsSearchDisplayTab

        SourceInventoryItemsPageRoute _ _ ->
            InventoryItemsDisplayTab

        SourceInventoryItemPageRoute _ _ ->
            DefaultRecordViewTab

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
