module Page.Front.Views.Facets exposing (..)

import Page.Facets.Facets exposing (FacetMsgConfig)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)


facetFrontMsgConfig : FacetMsgConfig FrontMsg
facetFrontMsgConfig =
    { userClickedToggleMsg = FrontMsg.UserClickedToggleFacet
    , userLostFocusRangeMsg = FrontMsg.UserLostFocusRangeFacet
    , userFocusedRangeMsg = FrontMsg.UserFocusedRangeFacet
    , userEnteredTextRangeMsg = FrontMsg.UserEnteredTextInRangeFacet
    , userClickedFacetExpandSelectMsg = FrontMsg.UserClickedSelectFacetExpand
    , userChangedFacetBehaviourSelectMsg = FrontMsg.UserChangedFacetBehaviour
    , userChangedSelectFacetSortSelectMsg = FrontMsg.UserChangedSelectFacetSort
    , userSelectedFacetItemSelectMsg = FrontMsg.UserClickedSelectFacetItem
    , userInteractedWithPianoKeyboard = FrontMsg.UserInteractedWithPianoKeyboard
    , userRemovedQueryMsg = FrontMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = FrontMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = FrontMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = FrontMsg.UserChoseOptionFromQueryFacetSuggest
    }
