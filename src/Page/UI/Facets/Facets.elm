module Page.UI.Facets.Facets exposing (FacetConfig, FacetMsgConfig, viewFacet, viewFacetSection)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, none, pointer, px, row, spacing, width)
import Element.Events exposing (onClick)
import Language exposing (Language)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetData(..), FacetSorts, Facets, RangeFacetValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (facetBorderBottom, lineSpacing)
import Page.UI.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)
import Page.UI.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.UI.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.UI.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)
import Page.UI.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)
import Page.UI.Images exposing (chevronDownSvg)
import Page.UI.Style exposing (colourScheme)


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
    }


viewFacet :
    FacetConfig a msg
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
                    , rangeFacet = facet
                    , activeSearch = cfg.activeSearch
                    , userLostFocusMsg = msg.userLostFocusRangeMsg
                    , userFocusedMsg = msg.userFocusedRangeMsg
                    , userEnteredTextMsg = msg.userEnteredTextRangeMsg
                    }
            in
            viewRangeFacet rangeFacetConfig

        Just (SelectFacetData facet) ->
            let
                selectFacetConfig : SelectFacetConfig msg
                selectFacetConfig =
                    { language = cfg.language
                    , selectFacet = facet
                    , activeSearch = cfg.activeSearch
                    , numberOfColumns = cfg.selectColumns
                    , userClickedFacetExpandMsg = msg.userClickedFacetExpandSelectMsg
                    , userChangedFacetBehaviourMsg = msg.userChangedFacetBehaviourSelectMsg
                    , userChangedSelectFacetSortMsg = msg.userChangedSelectFacetSortSelectMsg
                    , userSelectedFacetItemMsg = msg.userSelectedFacetItemSelectMsg
                    }
            in
            viewSelectFacet selectFacetConfig

        Just (NotationFacetData facet) ->
            case .keyboard cfg.activeSearch of
                Just keyboardModel ->
                    let
                        notationFacetConfig : NotationFacetConfig msg
                        notationFacetConfig =
                            { language = cfg.language
                            , keyboardModel = keyboardModel
                            , notationFacet = facet
                            , userInteractedWithKeyboardMsg = msg.userInteractedWithPianoKeyboard
                            }
                    in
                    viewKeyboardControl notationFacetConfig

                Nothing ->
                    none

        Just (QueryFacetData facet) ->
            let
                queryFacetConfig : QueryFacetConfig msg
                queryFacetConfig =
                    { language = cfg.language
                    , activeSearch = cfg.activeSearch
                    , queryFacet = facet
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
            (width fill
                :: height fill
                :: alignTop
                :: facetBorderBottom
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
