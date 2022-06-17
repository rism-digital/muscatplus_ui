module Page.UI.Search.Controls.SourcesControls exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, none, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (FacetMsgConfig, viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


viewFacetToggleSection : Language -> ActiveSearch msg -> SearchBody -> FacetMsgConfig msg -> Element msg
viewFacetToggleSection language activeSearch body facetSearchMsgConfig =
    let
        allAreEmpty =
            List.all (\a -> a == none) allToggles

        allToggles =
            [ sourceCollectionsToggle
            , sourceContentsToggle
            , compositeVolumesToggle
            , hasDigitizationToggle
            , hasIiifToggle
            , isArrangementToggle
            , hasIncipitsToggle
            ]

        compositeVolumesToggle =
            viewFacet (facetConfig "hide-composite-volumes") facetSearchMsgConfig

        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , selectColumns = 3
            , body = body
            }

        hasDigitizationToggle =
            viewFacet (facetConfig "has-digitization") facetSearchMsgConfig

        hasIiifToggle =
            viewFacet (facetConfig "has-iiif") facetSearchMsgConfig

        hasIncipitsToggle =
            viewFacet (facetConfig "has-incipits") facetSearchMsgConfig

        isArrangementToggle =
            viewFacet (facetConfig "is-arrangement") facetSearchMsgConfig

        sourceCollectionsToggle =
            viewFacet (facetConfig "hide-source-collections") facetSearchMsgConfig

        sourceContentsToggle =
            viewFacet (facetConfig "hide-source-contents") facetSearchMsgConfig
    in
    if allAreEmpty then
        none

    else
        row
            [ width fill
            , alignTop
            ]
            [ column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ sourceContentsToggle
                , sourceCollectionsToggle
                , compositeVolumesToggle
                ]
            , column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ hasDigitizationToggle
                , hasIiifToggle
                ]
            , column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ isArrangementToggle
                , hasIncipitsToggle
                ]
            ]


viewFacetsForSourcesMode : ControlsConfig msg -> Element msg
viewFacetsForSourcesMode { language, activeSearch, body, sectionToggleMsg, userTriggeredSearchSubmitMsg, userEnteredTextInKeywordQueryBoxMsg, facetMsgConfig } =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , selectColumns = 3
            , body = body
            }

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""
    in
    row
        [ padding 10
        , scrollbarY
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
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetSection language
                sectionToggleMsg
                [ row
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "composer") facetMsgConfig ]
                    , column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "people") facetMsgConfig ]
                    ]
                ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "date-range") facetMsgConfig
                ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacetToggleSection language activeSearch body facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "source-type") facetMsgConfig
                , viewFacet (facetConfig "content-types") facetMsgConfig
                , viewFacet (facetConfig "material-group-types") facetMsgConfig
                ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "text-language") facetMsgConfig
                , viewFacet (facetConfig "format-extent") facetMsgConfig
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "subjects") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "scoring") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "sigla") facetMsgConfig ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]
