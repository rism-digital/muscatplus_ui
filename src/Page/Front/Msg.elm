module Page.Front.Msg exposing (FrontMsg(..))

import Debouncer.Messages as Debouncer
import Http
import Http.Detailed
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Response exposing (ServerData)
import Set exposing (Set)


type FrontMsg
    = ServerRespondedWithFrontData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | DebouncerCapturedProbeRequest (Debouncer.Msg FrontMsg)
    | DebouncerSettledToSendProbeRequest
    | DebouncerCapturedQueryFacetSuggestionRequest (Debouncer.Msg FrontMsg)
    | DebouncerSettledToSendQueryFacetSuggestionRequest String
    | UserClickedFacetPanelToggle String (Set String)
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedToggleFacet FacetAlias
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInQueryFacet FacetAlias String String
    | UserChoseOptionFromQueryFacetSuggest FacetAlias String FacetBehaviours
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserFocusedRangeFacet FacetAlias
    | UserLostFocusRangeFacet FacetAlias
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetExpand FacetAlias
    | UserClickedSelectFacetItem FacetAlias String
    | UserInteractedWithPianoKeyboard KeyboardMsg
    | UserTriggeredSearchSubmit
    | UserResetAllFilters
    | NothingHappened
