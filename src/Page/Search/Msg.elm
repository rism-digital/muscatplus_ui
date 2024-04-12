module Page.Search.Msg exposing (SearchMsg(..))

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import KeyCodes exposing (ArrowDirection)
import Language exposing (LanguageMap)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetItem, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Response exposing (ServerData)
import Set exposing (Set)


type SearchMsg
    = ServerRespondedWithSearchData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithSearchPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | ClientCompletedViewportReset
    | ClientCompletedViewportJump
    | DebouncerCapturedProbeRequest (Debouncer.Msg SearchMsg)
    | DebouncerSettledToSendProbeRequest
    | DebouncerCapturedQueryFacetSuggestionRequest (Debouncer.Msg SearchMsg)
    | DebouncerSettledToSendQueryFacetSuggestionRequest String
    | UserClickedModeItem FacetItem
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
    | UserRemovedActiveFilter FacetAlias String
    | UserInteractedWithPianoKeyboard KeyboardMsg
    | UserTriggeredSearchSubmit
    | UserResetAllFilters
    | UserChangedResultSorting String
    | UserChangedResultsPerPage String
    | UserClickedSearchResultsPagination String
    | UserClickedSearchResultForPreview String
    | UserClickedExpandSourceItemsSectionInPreview
    | UserClickedExpandIncipitInfoSectionInPreview String
    | UserClickedExpandDigitalCopiesCallout
    | UserClickedClosePreviewWindow
    | UserPressedAnArrowKey ArrowDirection
    | NothingHappened
