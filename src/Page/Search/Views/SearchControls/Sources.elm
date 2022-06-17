module Page.Search.Views.SearchControls.Sources exposing (viewFacetToggleSection, viewFacetsForSourcesMode)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, none, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)


viewFacetToggleSection : Language -> ActiveSearch SearchMsg -> SearchBody -> Element SearchMsg
viewFacetToggleSection language activeSearch body =
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


viewFacetsForSourcesMode : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
viewFacetsForSourcesMode language model body =
    let
        activeSearch =
            toActiveSearch model

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
                        , submitMsg = SearchMsg.UserTriggeredSearchSubmit
                        , changeMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
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
