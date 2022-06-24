module Page.Front.Views.Facets exposing (facetFrontMsgConfig)

import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.UI.Facets.Facets exposing (FacetMsgConfig)


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
    , nothingHappenedMsg = FrontMsg.NothingHappened
    }
