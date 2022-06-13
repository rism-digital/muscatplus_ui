module Page.Record.Msg exposing (..)

import Debouncer.Basic as Debouncer
import Http
import Http.Detailed
import Page.Record.Model exposing (CurrentRecordViewTab)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Response exposing (ServerData)


type RecordMsg
    = ServerRespondedWithPageSearch (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithRecordData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | DebouncerCapturedProbeRequest (Debouncer.Msg RecordMsg)
    | DebouncerSettledToSendProbeRequest
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserClickedSearchResultsPagination String
    | UserClickedSearchResultForPreview String
    | UserClickedClosePreviewWindow
    | UserTriggeredSearchSubmit
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedToggleFacet FacetAlias
    | UserLostFocusRangeFacet FacetAlias
    | UserFocusedRangeFacet FacetAlias
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserClickedSelectFacetExpand FacetAlias
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetItem FacetAlias String
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInQueryFacet FacetAlias String String
    | DebouncerCapturedQueryFacetSuggestionRequest (Debouncer.Msg RecordMsg)
    | DebouncerSettledToSendQueryFacetSuggestionRequest String
    | UserChoseOptionForQueryFacet FacetAlias String FacetBehaviours
    | UserChangedResultSorting String
    | UserChangedResultsPerPage String
    | UserResetAllFilters
    | ClientCompletedViewportJump
    | ClientCompletedViewportReset
    | NothingHappened
