module Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)

import Dict
import Element exposing (Element, centerY, column, el, fill, height, none, paddingXY, pointer, px, row, spacing, spacingXY, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (LanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.Search exposing (FacetData(..))
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Components exposing (h5)
import Page.UI.Facets.FacetsConfig exposing (FacetConfig, FacetMsgConfig)
import Page.UI.Facets.NotationFacet exposing (viewKeyboardControl)
import Page.UI.Facets.QueryFacet exposing (viewQueryFacet)
import Page.UI.Facets.RangeFacet exposing (viewRangeFacet)
import Page.UI.Facets.SelectFacet exposing (viewSelectFacet)
import Page.UI.Facets.ToggleFacet exposing (viewToggleFacet)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (caretCircleDownSvg, caretCircleRightSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)
import Page.UI.Style exposing (colourScheme)
import Set


viewFacet :
    FacetConfig a msg
    -> FacetMsgConfig msg
    -> Element msg
viewFacet cfg msg =
    case Dict.get cfg.alias (.facets cfg.body) of
        Just (ToggleFacetData facet) ->
            viewToggleFacet
                { language = cfg.language
                , tooltip = cfg.tooltip
                , activeSearch = cfg.activeSearch
                , toggleFacet = facet
                , userClickedFacetToggleMsg = msg.userClickedToggleMsg
                }

        Just (RangeFacetData facet) ->
            viewRangeFacet
                { language = cfg.language
                , tooltip = cfg.tooltip
                , rangeFacet = facet
                , activeSearch = cfg.activeSearch
                , userLostFocusMsg = msg.userLostFocusRangeMsg
                , userFocusedMsg = msg.userFocusedRangeMsg
                , userEnteredTextMsg = msg.userEnteredTextRangeMsg
                }

        Just (SelectFacetData facet) ->
            viewSelectFacet
                { language = cfg.language
                , tooltip = cfg.tooltip
                , selectFacet = facet
                , activeSearch = cfg.activeSearch
                , userClickedFacetExpandMsg = msg.userClickedFacetExpandSelectMsg
                , userChangedFacetBehaviourMsg = msg.userChangedFacetBehaviourSelectMsg
                , userChangedSelectFacetSortMsg = msg.userChangedSelectFacetSortSelectMsg
                , userSelectedFacetItemMsg = msg.userSelectedFacetItemSelectMsg
                }

        Just (NotationFacetData facet) ->
            ME.unpack
                (\() -> none)
                (\keyboardModel ->
                    viewKeyboardControl
                        { language = cfg.language
                        , tooltip = cfg.tooltip
                        , keyboardModel = keyboardModel
                        , notationFacet = facet
                        , userInteractedWithKeyboardMsg = msg.userInteractedWithPianoKeyboard
                        , searchPreferences = cfg.searchPreferences
                        }
                )
                (.keyboard cfg.activeSearch)

        Just (QueryFacetData facet) ->
            viewQueryFacet
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

        Nothing ->
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
                viewIf
                    (row
                        [ width fill
                        ]
                        [ column
                            [ width fill
                            , spacingXY 10 20
                            ]
                            body
                        ]
                    )
                    panelIsVisible
        in
        row
            [ width fill
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color colourScheme.lightGrey
            , paddingXY 0 10
            ]
            [ column
                [ width fill
                ]
                [ row
                    [ width fill
                    , Font.color colourScheme.black
                    , Border.dotted
                    , paddingXY 0 8
                    , spacing 5
                    , headingMD
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
                        , width fill
                        , onClick (cfg.panelToggleMsg alias cfg.expandedFacetPanels)
                        ]
                        (h5 cfg.language header)
                    ]
                , panelBody
                ]
            ]
