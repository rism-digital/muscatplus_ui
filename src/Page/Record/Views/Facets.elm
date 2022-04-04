module Page.Record.Views.Facets exposing (..)

import Page.Facets.Facets exposing (FacetMsgConfig)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)


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
    , userInteractedWithPianoKeyboard = RecordMsg.UserInteractedWithPianoKeyboard
    , userRemovedQueryMsg = RecordMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = RecordMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = RecordMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = RecordMsg.UserChoseOptionForQueryFacet
    }
