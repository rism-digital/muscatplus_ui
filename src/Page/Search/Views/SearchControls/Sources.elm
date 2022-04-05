module Page.Search.Views.SearchControls.Sources exposing (..)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, none, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)


viewFacetsForSourcesMode : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
viewFacetsForSourcesMode language model body =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
            }

        activeSearch =
            toActiveSearch model

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = body
            , selectColumns = 4
            }
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
                    [ searchKeywordInput language msgs qText ]
                ]
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "composer") facetSearchMsgConfig ]
                    , column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet (facetConfig "people") facetSearchMsgConfig ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "date-range") facetSearchMsgConfig
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacetToggleSection language activeSearch body ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "source-type") facetSearchMsgConfig
                , viewFacet (facetConfig "content-types") facetSearchMsgConfig
                , viewFacet (facetConfig "material-group-types") facetSearchMsgConfig
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "text-language") facetSearchMsgConfig
                , viewFacet (facetConfig "format-extent") facetSearchMsgConfig
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "subjects") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "scoring") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "sigla") facetSearchMsgConfig ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]


viewFacetToggleSection : Language -> ActiveSearch SearchMsg -> SearchBody -> Element SearchMsg
viewFacetToggleSection language activeSearch body =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = body
            , selectColumns = 3
            }

        sourceContentsToggle =
            viewFacet (facetConfig "hide-source-contents") facetSearchMsgConfig

        sourceCollectionsToggle =
            viewFacet (facetConfig "hide-source-collections") facetSearchMsgConfig

        compositeVolumesToggle =
            viewFacet (facetConfig "hide-composite-volumes") facetSearchMsgConfig

        hasDigitizationToggle =
            viewFacet (facetConfig "has-digitization") facetSearchMsgConfig

        isArrangementToggle =
            viewFacet (facetConfig "is-arrangement") facetSearchMsgConfig

        hasIncipitsToggle =
            viewFacet (facetConfig "has-incipits") facetSearchMsgConfig

        allToggles =
            [ sourceCollectionsToggle
            , sourceContentsToggle
            , compositeVolumesToggle
            , hasDigitizationToggle
            , isArrangementToggle
            , hasIncipitsToggle
            ]

        allAreEmpty =
            List.all (\a -> a == none) allToggles
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
                [ hasDigitizationToggle ]
            , column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ isArrangementToggle
                , hasIncipitsToggle
                ]
            ]
