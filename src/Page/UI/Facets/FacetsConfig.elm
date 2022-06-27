module Page.UI.Facets.FacetsConfig exposing (FacetConfig, FacetMsgConfig)

import ActiveSearch.Model exposing (ActiveSearch)
import Language exposing (Language)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, Facets, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)


type alias FacetConfig a msg =
    { alias : FacetAlias
    , language : Language
    , activeSearch : ActiveSearch msg
    , selectColumns : Int
    , body : { a | facets : Facets }
    }


type alias FacetMsgConfig msg =
    { userClickedToggleMsg : FacetAlias -> msg
    , userLostFocusRangeMsg : FacetAlias -> msg
    , userFocusedRangeMsg : FacetAlias -> msg
    , userEnteredTextRangeMsg : FacetAlias -> RangeFacetValue -> String -> msg
    , userClickedFacetExpandSelectMsg : String -> msg
    , userChangedFacetBehaviourSelectMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortSelectMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemSelectMsg : FacetAlias -> String -> msg
    , userInteractedWithPianoKeyboard : KeyboardMsg -> msg
    , userRemovedQueryMsg : String -> String -> msg
    , userEnteredTextQueryMsg : FacetAlias -> String -> String -> msg
    , userChangedBehaviourQueryMsg : FacetAlias -> FacetBehaviours -> msg
    , userChoseOptionQueryMsg : FacetAlias -> String -> FacetBehaviours -> msg
    , nothingHappenedMsg : msg
    }
