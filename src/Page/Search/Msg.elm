module Page.Search.Msg exposing (SearchMsg(..))

import Http
import Http.Detailed
import Page.Query exposing (FacetBehaviour, FacetMode, FacetSort)
import Page.RecordTypes.Search exposing (FacetItem)
import Page.UI.Facets.RangeSlider as RangeSlider
import Page.UI.Keyboard as Keyboard
import Response exposing (ServerData)


type SearchMsg
    = ServerRespondedWithSearchData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithSearchPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ClientJumpedToId
    | ClientResetViewport
    | UserChangedFacetBehaviour FacetBehaviour
    | UserChangedFacetSort FacetSort
    | UserChangedFacetMode FacetMode
    | UserClickedFacetExpand String
    | UserClickedFacetItem String FacetItem Bool
    | UserClickedFacetToggle String
    | UserClickedFacetPanelToggle
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
