module Page.Search.Msg exposing (SearchMsg(..))

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
    | ClientJumpedToId
    | ClientResetViewport
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetExpand FacetAlias
    | UserClickedSelectFacetItem FacetAlias String Bool
    | UserClickedToggleFacet FacetAlias
    | UserClickedFacetPanelToggle
    | UserEnteredTextInQueryFacet FacetAlias String String
    | UserChoseOptionForQueryFacet FacetAlias String FacetBehaviours
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserFocusedRangeFacet FacetAlias RangeFacetValue
    | UserLostFocusRangeFacet FacetAlias RangeFacetValue
    | UserChangedResultSorting String
    | UserClickedModeItem String FacetItem
    | UserClickedRemoveActiveFilter String String
    | UserClickedClearSearchQueryBox
    | UserClickedSearchResultsPagination String
    | UserTriggeredSearchSubmit
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedClosePreviewWindow
    | UserClickedSearchResultForPreview String
    | UserInteractedWithPianoKeyboard KeyboardMsg
    | UserClickedPianoKeyboardSearchClearButton
    | UserResetAllFilters
    | NothingHappened
