module Page.Record.Msg exposing (RecordMsg(..))

import Debouncer.Basic as Debouncer
import Http
import Http.Detailed
import KeyCodes exposing (ArrowDirection)
import Language exposing (LanguageMap)
import Page.Record.Model exposing (CurrentRecordViewTab)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Response exposing (ServerData)
import Set exposing (Set)


type RecordMsg
    = ServerRespondedWithPageSearch (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithRecordData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | ClientCompletedViewportJump
    | ClientCompletedViewportReset
    | DebouncerCapturedProbeRequest (Debouncer.Msg RecordMsg)
    | DebouncerSettledToSendProbeRequest
    | DebouncerCapturedQueryFacetSuggestionRequest (Debouncer.Msg RecordMsg)
    | DebouncerSettledToSendQueryFacetSuggestionRequest String
    | UserClickedFacetPanelToggle String (Set String)
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedToggleFacet FacetAlias
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserEnteredTextInQueryFacet FacetAlias String String
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserChoseOptionForQueryFacet FacetAlias String FacetBehaviours
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserFocusedRangeFacet FacetAlias
    | UserLostFocusRangeFacet FacetAlias
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetExpand FacetAlias
    | UserClickedSelectFacetItem FacetAlias String LanguageMap
    | UserTriggeredSearchSubmit
    | UserRemovedActiveFilter FacetAlias String
    | UserResetAllFilters
    | UserChangedResultSorting String
    | UserChangedResultsPerPage String
    | UserClickedSearchResultsPagination String
    | UserClickedSearchResultForPreview String
    | UserClickedExpandSourceItemsSectionInPreview
    | UserClickedExpandIncipitInfoSectionInPreview String
    | UserClickedClosePreviewWindow
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserPressedAnArrowKey ArrowDirection
    | NothingHappened
