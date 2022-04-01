module Page.Record.Msg exposing (..)

import Http
import Http.Detailed
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Record.Model exposing (CurrentRecordViewTab)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Response exposing (ServerData)


type RecordMsg
    = ServerRespondedWithPageSearch (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordData (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | ServerRespondedWithRecordPreview (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ))
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserClickedToCItem String
    | UserClickedSearchResultsPagination String
    | UserClickedSearchResultForPreview String
    | UserClickedClosePreviewWindow
    | UserTriggeredSearchSubmit
    | UserEnteredTextInKeywordQueryBox String
    | UserClickedToggleFacet FacetAlias
    | UserLostFocusRangeFacet FacetAlias RangeFacetValue
    | UserFocusedRangeFacet FacetAlias RangeFacetValue
    | UserEnteredTextInRangeFacet FacetAlias RangeFacetValue String
    | UserClickedSelectFacetExpand FacetAlias
    | UserChangedFacetBehaviour FacetAlias FacetBehaviours
    | UserChangedSelectFacetSort FacetAlias FacetSorts
    | UserClickedSelectFacetItem FacetAlias String Bool
    | UserInteractedWithPianoKeyboard KeyboardMsg
    | UserRemovedItemFromQueryFacet FacetAlias String
    | UserEnteredTextInQueryFacet FacetAlias String String
    | UserChoseOptionForQueryFacet FacetAlias String FacetBehaviours
    | UserResetAllFilters
    | NothingHappened
