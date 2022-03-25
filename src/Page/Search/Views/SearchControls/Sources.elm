module Page.Search.Views.SearchControls.Sources exposing (..)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, none, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (dividerWithText)


viewFacetsForSourcesMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
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
                widthFillHeightFill
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
                [ row
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet "composer" language activeSearch body ]
                    , column
                        [ width fill
                        , alignTop
                        ]
                        [ viewFacet "people" language activeSearch body ]
                    ]
                ]
            , viewFacetSection language
                [ viewFacet "date-range" language activeSearch body
                ]
            , viewFacetSection language
                [ viewFacetToggleSection language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "source-type" language activeSearch body
                , viewFacet "content-types" language activeSearch body
                , viewFacet "material-group-types" language activeSearch body
                ]
            , viewFacetSection language
                [ viewFacet "text-language" language activeSearch body
                , viewFacet "format-extent" language activeSearch body
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                [ viewFacet "subjects" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "scoring" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "sigla" language activeSearch body ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]


viewFacetToggleSection : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
viewFacetToggleSection language activeSearch body =
    let
        sourceContentsToggle =
            viewFacet "hide-source-contents" language activeSearch body

        sourceCollectionsToggle =
            viewFacet "hide-source-collections" language activeSearch body

        compositeVolumesToggle =
            viewFacet "hide-composite-volumes" language activeSearch body

        hasDigitizationToggle =
            viewFacet "has-digitization" language activeSearch body

        isArrangementToggle =
            viewFacet "is-arrangement" language activeSearch body

        hasIncipitsToggle =
            viewFacet "has-incipits" language activeSearch body

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
