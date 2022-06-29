module Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


incipitFacetPanels :
    { musicalFeaturesPanel : PanelConfig
    , composerPanel : PanelConfig
    }
incipitFacetPanels =
    { musicalFeaturesPanel =
        { alias = "incipit-musical-features-panel"
        , label = facetPanelTitles.clefKeyTime
        }
    , composerPanel =
        { alias = "incipit-composer-panel"
        , label = facetPanelTitles.composerComposition
        }
    }


viewFacetsForIncipitsMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForIncipitsMode cfg =
    let
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        composer =
            viewFacet (facetConfig "composer") cfg.facetMsgConfig

        clef =
            viewFacet (facetConfig "clef") cfg.facetMsgConfig

        keysig =
            viewFacet (facetConfig "key-signature") cfg.facetMsgConfig

        timesig =
            viewFacet (facetConfig "time-signature") cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias incipitFacetPanels.musicalFeaturesPanel)
        (.label incipitFacetPanels.musicalFeaturesPanel)
        cfg
        [ clef
        , keysig
        , timesig
        ]
    , viewFacetsControlPanel
        (.alias incipitFacetPanels.composerPanel)
        (.label incipitFacetPanels.composerPanel)
        cfg
        [ composer ]
    ]



--viewFacetsForIncipitsMode : ControlsConfig body msg -> Element msg
--viewFacetsForIncipitsMode cfg =
--    let
--        facetConfig alias =
--            { alias = alias
--            , language = language
--            , activeSearch = activeSearch
--            , selectColumns = numberOfSelectColumns
--            , body = body
--            }
--
--        qText =
--            toNextQuery activeSearch
--                |> toKeywordQuery
--                |> Maybe.withDefault ""
--    in
--    row
--        [ padding 10
--        , width fill
--        , alignTop
--        , height fill
--        ]
--        [ column
--            [ spacing lineSpacing
--            , width fill
--            , alignTop
--            ]
--            [ row
--                [ width fill ]
--                [ column
--                    [ alignTop
--                    , alignLeft
--                    , width fill
--                    ]
--                    [
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , height fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill
--                        , alignTop
--                        ]
--                        [ searchKeywordInput
--                            { language = language
--                            , submitMsg = userTriggeredSearchSubmitMsg
--                            , changeMsg = userEnteredTextInKeywordQueryBoxMsg
--                            , queryText = qText
--                            }
--                        ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    , spacing sectionSpacing
--                    ]
--                    [ column
--                        [ width fill
--                        , alignTop
--                        ]
--                        [ viewFacet (facetConfig "composer") facetMsgConfig
--                        ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill ]
--                        [ viewFacet (facetConfig "date-range") facetMsgConfig ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill
--                        , alignTop
--                        , spacing lineSpacing
--                        ]
--                        [ viewFacet (facetConfig "is-mensural") facetMsgConfig
--                        , viewFacet (facetConfig "has-notation") facetMsgConfig
--                        ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill ]
--                        [ viewFacet (facetConfig "clef") facetMsgConfig
--                        ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill ]
--                        [ viewFacet (facetConfig "key-signature") facetMsgConfig
--                        ]
--                    ]
--                ]
--            , viewFacetSection language
--                panelToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ column
--                        [ width fill ]
--                        [ viewFacet (facetConfig "time-signature") facetMsgConfig
--                        ]
--                    ]
--                ]
--            ]
--        ]
