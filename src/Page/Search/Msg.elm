module Page.Search.Msg exposing (SearchMsg(..))

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetItem, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Response exposing (ServerData)


type SearchMsg
    = ServerRespondedWithSearchData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithSearchPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | DebouncerCapturedProbeRequest (Debouncer.Msg SearchMsg)
    | DebouncerSettledToSendProbeRequest
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetExpand FacetAlias
    | UserClickedSelectFacetItem FacetAlias String
    | UserClickedToggleFacet FacetAlias
    | UserClickedFacetPanelToggle
    | UserEnteredTextInQueryFacet FacetAlias String String
    | DebouncerCapturedQueryFacetSuggestionRequest (Debouncer.Msg SearchMsg)
    | DebouncerSettledToSendQueryFacetSuggestionRequest String
    | UserChoseOptionForQueryFacet FacetAlias String FacetBehaviours
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserFocusedRangeFacet FacetAlias
    | UserLostFocusRangeFacet FacetAlias
    | UserChangedResultSorting String
    | UserChangedResultsPerPage String
    | UserClickedModeItem FacetItem
    | UserClickedSearchResultsPagination String
    | UserTriggeredSearchSubmit
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedClosePreviewWindow
    | UserClickedSearchResultForPreview String
    | UserInteractedWithPianoKeyboard KeyboardMsg
    | UserResetAllFilters
    | NothingHappened
