module Page.Front.Views.Facets exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, none)
import Language exposing (Language)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.RecordTypes.Search exposing (FacetData(..), Facets)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Views.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)
import Page.Search.Views.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.Search.Views.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.Search.Views.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)
import Page.Search.Views.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)


viewFrontFacet :
    FacetAlias
    -> Language
    -> ActiveSearch
    -> { a | facets : Facets }
    -> Element FrontMsg
viewFrontFacet alias language activeSearch body =
    case Dict.get alias body.facets of
        Just (ToggleFacetData facet) ->
            let
                toggleFacetConfig : ToggleFacetConfig FrontMsg
                toggleFacetConfig =
                    { language = language
                    , activeSearch = activeSearch
                    , toggleFacet = facet
                    , userClickedFacetToggleMsg = FrontMsg.UserClickedToggleFacet
                    }
            in
            viewToggleFacet toggleFacetConfig

        Just (QueryFacetData facet) ->
            let
                queryFacetConfig : QueryFacetConfig FrontMsg
                queryFacetConfig =
                    { language = language
                    , queryFacet = facet
                    , activeSearch = activeSearch
                    , userRemovedMsg = FrontMsg.UserRemovedItemFromQueryFacet
                    , userEnteredTextMsg = FrontMsg.UserEnteredTextInQueryFacet
                    , userChangedBehaviourMsg = FrontMsg.UserChangedFacetBehaviour
                    , userChoseOptionMsg = FrontMsg.UserChoseOptionFromQueryFacetSuggest
                    }
            in
            viewQueryFacet queryFacetConfig

        Just (RangeFacetData facet) ->
            let
                rangeFacetConfig : RangeFacetConfig FrontMsg
                rangeFacetConfig =
                    { language = language
                    , rangeFacet = facet
                    , activeSearch = activeSearch
                    , userLostFocusMsg = FrontMsg.UserLostFocusRangeFacet
                    , userFocusedMsg = FrontMsg.UserFocusedRangeFacet
                    , userEnteredTextMsg = FrontMsg.UserEnteredTextInRangeFacet
                    }
            in
            viewRangeFacet rangeFacetConfig

        Just (SelectFacetData facet) ->
            let
                selectFacetConfig : SelectFacetConfig FrontMsg
                selectFacetConfig =
                    { language = language
                    , activeSearch = activeSearch
                    , selectFacet = facet
                    , numberOfColumns = 4
                    , userClickedFacetExpandMsg = FrontMsg.UserClickedSelectFacetExpand
                    , userChangedFacetBehaviourMsg = FrontMsg.UserChangedFacetBehaviour
                    , userChangedSelectFacetSortMsg = FrontMsg.UserChangedSelectFacetSort
                    , userSelectedFacetItemMsg = FrontMsg.UserClickedSelectFacetItem
                    }
            in
            viewSelectFacet selectFacetConfig

        Just (NotationFacetData facet) ->
            let
                notationFacetConfig : NotationFacetConfig FrontMsg
                notationFacetConfig =
                    { language = language
                    , keyboardFacet = activeSearch.keyboard
                    , userInteractedWithKeyboardMsg = FrontMsg.UserInteractedWithPianoKeyboard
                    }
            in
            viewKeyboardControl notationFacetConfig

        _ ->
            none
