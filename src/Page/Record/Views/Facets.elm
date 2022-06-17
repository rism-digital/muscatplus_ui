module Page.Record.Views.Facets exposing (facetRecordMsgConfig)

import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.UI.Facets.Facets exposing (FacetMsgConfig)


facetRecordMsgConfig : FacetMsgConfig RecordMsg
facetRecordMsgConfig =
    { userClickedToggleMsg = RecordMsg.UserClickedToggleFacet
    , userLostFocusRangeMsg = RecordMsg.UserLostFocusRangeFacet
    , userFocusedRangeMsg = RecordMsg.UserFocusedRangeFacet
    , userEnteredTextRangeMsg = RecordMsg.UserEnteredTextInRangeFacet
    , userClickedFacetExpandSelectMsg = RecordMsg.UserClickedSelectFacetExpand
    , userChangedFacetBehaviourSelectMsg = RecordMsg.UserChangedFacetBehaviour
    , userChangedSelectFacetSortSelectMsg = RecordMsg.UserChangedSelectFacetSort
    , userSelectedFacetItemSelectMsg = RecordMsg.UserClickedSelectFacetItem
    , userInteractedWithPianoKeyboard = \_ -> RecordMsg.NothingHappened -- no piano keyboard on record searches
    , userRemovedQueryMsg = RecordMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = RecordMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = RecordMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = RecordMsg.UserChoseOptionForQueryFacet
    }
