module Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)

import Dict
import Element exposing (Element, centerY, column, el, fill, height, none, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Search exposing (FacetData(..))
import Page.UI.Attributes exposing (headingLG, lineSpacing)
import Page.UI.Facets.FacetsConfig exposing (FacetConfig, FacetMsgConfig)
import Page.UI.Facets.NotationFacet exposing (NotationFacetConfig, viewKeyboardControl)
import Page.UI.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.UI.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.UI.Facets.SelectFacet exposing (SelectFacetConfig, viewSelectFacet)
import Page.UI.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)
import Page.UI.Images exposing (caretCircleDownSvg, caretCircleRightSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Set


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
                    , tooltip = cfg.tooltip
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
                    , tooltip = cfg.tooltip
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
                    , tooltip = cfg.tooltip
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
                            , tooltip = cfg.tooltip
                            , keyboardModel = keyboardModel
                            , notationFacet = facet
                            , userInteractedWithKeyboardMsg = msg.userInteractedWithPianoKeyboard
                            , searchPreferences = cfg.searchPreferences
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
                    , tooltip = cfg.tooltip
                    , activeSearch = cfg.activeSearch
                    , queryFacet = facet
                    , userRemovedMsg = msg.userRemovedQueryMsg
                    , userEnteredTextMsg = msg.userEnteredTextQueryMsg
                    , userChangedBehaviourMsg = msg.userChangedBehaviourQueryMsg
                    , userChoseOptionMsg = msg.userChoseOptionQueryMsg
                    , nothingHappenedMsg = msg.nothingHappenedMsg
                    }
            in
            viewQueryFacet queryFacetConfig

        _ ->
            none


viewFacetsControlPanel : String -> LanguageMap -> ControlsConfig body msg -> List (Element msg) -> Element msg
viewFacetsControlPanel alias header cfg body =
    let
        -- if all of the body values are empty, skip showing this panel altogether.
        allAreEmpty =
            List.all (\a -> a == none) body
    in
    if allAreEmpty then
        none

    else
        let
            panelIsVisible =
                Set.member alias cfg.expandedFacetPanels

            toggleIcon =
                if panelIsVisible then
                    caretCircleDownSvg colourScheme.lightBlue

                else
                    caretCircleRightSvg colourScheme.lightBlue

            panelBody =
                if panelIsVisible then
                    row
                        [ width fill
                        , paddingXY 0 8
                        ]
                        [ column
                            [ width fill
                            , spacing lineSpacing
                            ]
                            body
                        ]

                else
                    none
        in
        row
            [ width fill
            , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
            , Border.color (colourScheme.lightGrey |> convertColorToElementColor)
            , paddingXY 0 10
            ]
            [ column
                [ width fill
                ]
                [ row
                    [ width fill
                    , Font.color (colourScheme.black |> convertColorToElementColor)
                    , Border.dotted
                    , paddingXY 0 8
                    , spacing 5
                    , Font.medium
                    , headingLG
                    ]
                    [ el
                        [ width (px 16)
                        , height (px 16)
                        , centerY
                        , pointer
                        , onClick (cfg.panelToggleMsg alias cfg.expandedFacetPanels)
                        ]
                        toggleIcon
                    , el
                        [ centerY
                        , pointer
                        , onClick (cfg.panelToggleMsg alias cfg.expandedFacetPanels)
                        ]
                        (text (extractLabelFromLanguageMap cfg.language header))
                    ]
                , panelBody
                ]
            ]
