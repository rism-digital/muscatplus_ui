module Page.Search.Views.SearchControls.Sources exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, el, fill, height, padding, row, scrollbarY, spacing, text, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (Facets, SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (facetBorderBottom, headingMD, lineSpacing, widthFillHeightFill)


viewFacetsForSourcesMode : Language -> SearchPageModel -> { a | facets : Facets } -> Element SearchMsg
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
                (List.append [ width fill ] facetBorderBottom)
                [ column
                    widthFillHeightFill
                    [ el
                        [ width fill
                        , headingMD
                        ]
                        (text "Source record filters")
                    ]
                ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet "composer" language activeSearch body ]
                    , column
                        [ width fill ]
                        [ viewFacet "people" language activeSearch body ]
                    ]
                ]
            , viewFacetSection language
                [ viewFacet "date-range" language activeSearch body ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        , spacing lineSpacing
                        ]
                        [ viewFacet "hide-source-contents" language activeSearch body
                        , viewFacet "hide-source-collections" language activeSearch body
                        , viewFacet "hide-composite-volumes" language activeSearch body
                        ]
                    , column
                        [ width fill
                        , alignTop
                        , spacing lineSpacing
                        ]
                        [ viewFacet "has-digitization" language activeSearch body ]
                    , column
                        [ width fill
                        , alignTop
                        , spacing lineSpacing
                        ]
                        [ viewFacet "is-arrangement" language activeSearch body
                        , viewFacet "has-incipits" language activeSearch body
                        ]
                    ]
                ]
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

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]
