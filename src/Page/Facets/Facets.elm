module Page.Facets.Facets exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, none, pointer, px, row, spacing, width)
import Element.Events exposing (onClick)
import Language exposing (Language)
import Page.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)
import Page.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)
import Page.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetData(..), FacetSorts, Facets, RangeFacetValue, SearchBody)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (facetBorderBottom, lineSpacing)
import Page.UI.Images exposing (chevronDownSvg)
import Page.UI.Style exposing (colourScheme)


type alias FacetMsgConfig msg =
    { userClickedToggleMsg : FacetAlias -> msg
    , userLostFocusRangeMsg : FacetAlias -> RangeFacetValue -> msg
    , userFocusedRangeMsg : FacetAlias -> RangeFacetValue -> msg
    , userEnteredTextRangeMsg : FacetAlias -> RangeFacetValue -> String -> msg
    , userClickedFacetExpandSelectMsg : String -> msg
    , userChangedFacetBehaviourSelectMsg : FacetAlias -> FacetBehaviours -> msg
    , userChangedSelectFacetSortSelectMsg : FacetAlias -> FacetSorts -> msg
    , userSelectedFacetItemSelectMsg : FacetAlias -> String -> Bool -> msg
    , userInteractedWithPianoKeyboard : KeyboardMsg -> msg
    , userRemovedQueryMsg : String -> String -> msg
    , userEnteredTextQueryMsg : FacetAlias -> String -> String -> msg
    , userChangedBehaviourQueryMsg : FacetAlias -> FacetBehaviours -> msg
    , userChoseOptionQueryMsg : FacetAlias -> String -> FacetBehaviours -> msg
    }


type alias FacetConfig a =
    { alias : FacetAlias
    , language : Language
    , activeSearch : ActiveSearch
    , body : { a | facets : Facets }
    }


viewFacet :
    FacetConfig a
    -> FacetMsgConfig msg
    -> Element msg
viewFacet cfg msg =
    case Dict.get cfg.alias (.facets cfg.body) of
        Just (ToggleFacetData facet) ->
            let
                toggleFacetConfig : ToggleFacetConfig msg
                toggleFacetConfig =
                    { language = cfg.language
                    , activeSearch = cfg.activeSearch
                    , toggleFacet = facet
                    , userClickedFacetToggleMsg = msg.userClickedToggleMsg
                    }
            in
            viewToggleFacet toggleFacetConfig

        Just (RangeFacetData facet) ->
            let
                rangeFacetConfig : RangeFacetConfig msg
                rangeFacetConfig =
                    { language = cfg.language
                    , activeSearch = cfg.activeSearch
                    , rangeFacet = facet
                    , userEnteredTextMsg = msg.userEnteredTextRangeMsg
                    , userFocusedMsg = msg.userFocusedRangeMsg
                    , userLostFocusMsg = msg.userLostFocusRangeMsg
                    }
            in
            viewRangeFacet rangeFacetConfig

        Just (SelectFacetData facet) ->
            let
                selectFacetConfig : SelectFacetConfig msg
                selectFacetConfig =
                    { language = cfg.language
                    , activeSearch = cfg.activeSearch
                    , selectFacet = facet
                    , numberOfColumns = 3
                    , userClickedFacetExpandMsg = msg.userClickedFacetExpandSelectMsg
                    , userChangedFacetBehaviourMsg = msg.userChangedFacetBehaviourSelectMsg
                    , userChangedSelectFacetSortMsg = msg.userChangedSelectFacetSortSelectMsg
                    , userSelectedFacetItemMsg = msg.userSelectedFacetItemSelectMsg
                    }
            in
            viewSelectFacet selectFacetConfig

        Just (NotationFacetData facet) ->
            let
                notationFacetConfig : NotationFacetConfig msg
                notationFacetConfig =
                    { language = cfg.language
                    , keyboardModel = .keyboard cfg.activeSearch
                    , notationFacet = facet
                    , userInteractedWithKeyboardMsg = msg.userInteractedWithPianoKeyboard
                    }
            in
            viewKeyboardControl notationFacetConfig

        Just (QueryFacetData facet) ->
            let
                queryFacetConfig : QueryFacetConfig msg
                queryFacetConfig =
                    { language = cfg.language
                    , queryFacet = facet
                    , activeSearch = cfg.activeSearch
                    , userRemovedMsg = msg.userRemovedQueryMsg
                    , userEnteredTextMsg = msg.userEnteredTextQueryMsg
                    , userChangedBehaviourMsg = msg.userChangedBehaviourQueryMsg
                    , userChoseOptionMsg = msg.userChoseOptionQueryMsg
                    }
            in
            viewQueryFacet queryFacetConfig

        _ ->
            none


viewFacetSection :
    Language
    -> msg
    -> List (Element msg)
    -> Element msg
viewFacetSection language clickMsg facets =
    let
        allEmpty =
            List.all (\a -> a == none) facets
    in
    if allEmpty then
        none

    else
        row
            ([ width fill
             , height fill
             , alignTop
             ]
                ++ facetBorderBottom
            )
            [ column
                [ spacing lineSpacing
                , alignTop
                , width fill
                , height fill
                , alignTop
                ]
                [ row
                    [ spacing lineSpacing
                    , width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        [ alignLeft ]
                        [ el
                            [ alignLeft
                            , width (px 10)
                            , pointer
                            , onClick clickMsg -- TODO: Implement collapsing behaviour!
                            ]
                            (chevronDownSvg colourScheme.lightBlue)
                        ]
                    ]
                , row
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        [ spacing lineSpacing
                        , width fill
                        , height fill
                        , alignTop
                        ]
                        facets
                    ]
                ]
            ]
