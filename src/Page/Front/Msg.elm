module Page.Front.Msg exposing (..)

import Http
import Http.Detailed
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.UI.Keyboard as Keyboard
import Response exposing (ServerData)


type FrontMsg
    = ServerRespondedWithFrontData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | UserTriggeredSearchSubmit
    | UserResetAllFilters
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedToggleFacet FacetAlias
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInQueryFacet FacetAlias String String
    | UserChoseOptionFromQueryFacetSuggest FacetAlias String FacetBehaviours
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserFocusedRangeFacet FacetAlias RangeFacetValue
    | UserLostFocusRangeFacet FacetAlias RangeFacetValue
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetExpand FacetAlias
    | UserClickedSelectFacetItem FacetAlias String Bool
    | UserInteractedWithPianoKeyboard Keyboard.Msg
    | NothingHappened
