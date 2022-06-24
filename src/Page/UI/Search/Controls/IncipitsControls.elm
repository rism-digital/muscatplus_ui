module Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


viewFacetsForIncipitsMode : ControlsConfig msg -> Element msg
viewFacetsForIncipitsMode { language, activeSearch, body, panelToggleMsg, userTriggeredSearchSubmitMsg, userEnteredTextInKeywordQueryBoxMsg, facetMsgConfig, numberOfSelectColumns } =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , selectColumns = numberOfSelectColumns
            , body = body
            }

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""
    in
    row
        [ padding 10
        , width fill
        , alignTop
        , height fill
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ column
                    [ alignTop
                    , alignLeft
                    , width fill
                    ]
                    [ viewFacet (facetConfig "notation") facetMsgConfig
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ searchKeywordInput
                            { language = language
                            , submitMsg = userTriggeredSearchSubmitMsg
                            , changeMsg = userEnteredTextInKeywordQueryBoxMsg
                            , queryText = qText
                            }
                        ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "composer") facetMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "date-range") facetMsgConfig ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        , spacing lineSpacing
                        ]
                        [ viewFacet (facetConfig "is-mensural") facetMsgConfig
                        , viewFacet (facetConfig "has-notation") facetMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "clef") facetMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "key-signature") facetMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                panelToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "time-signature") facetMsgConfig
                        ]
                    ]
                ]
            ]
        ]
