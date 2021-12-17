module Page.Search.Msg exposing (SearchMsg(..))

import Http
import Http.Detailed
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetItem, FacetSorts)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.UI.Facets.RangeSlider as RangeSlider
import Page.UI.Keyboard as Keyboard
import Response exposing (ServerData)


type SearchMsg
    = ServerRespondedWithSearchData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ServerRespondedWithSearchPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSuggestionData (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ))
    | ClientJumpedToId
    | ClientResetViewport
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserChangedFacetSort FacetAlias FacetSorts
    | UserClickedFacetExpand String
    | UserClickedFacetItem FacetAlias String Bool
    | UserClickedFacetToggle FacetAlias
    | UserClickedFacetPanelToggle
    | UserEnteredTextInQueryFacet FacetAlias String
    | UserHitEnterInQueryFacet FacetAlias FacetBehaviours
    | UserMovedRangeSlider String RangeSlider.Msg
    | UserChangedResultSorting String
    | UserClickedModeItem String FacetItem Bool
    | UserClickedRemoveActiveFilter String String
    | UserClickedClearSearchQueryBox
    | UserClickedSearchResultsPagination String
    | UserTriggeredSearchSubmit
    | UserInputTextInQueryBox String
    | UserClickedClosePreviewWindow
    | UserClickedSearchResultForPreview String
    | UserInteractedWithPianoKeyboard Keyboard.Msg
    | UserClickedPianoKeyboardSearchSubmitButton
    | UserClickedPianoKeyboardSearchClearButton
    | NothingHappened
