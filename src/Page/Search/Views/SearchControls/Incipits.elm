module Page.Search.Views.SearchControls.Incipits exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignLeft, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing, widthFillHeightFill)


viewFacetsForIncipitsMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForIncipitsMode language model body =
    let
        activeSearch =
            toActiveSearch model

        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
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
                [ width fill ]
                [ column
                    [ alignTop
                    , alignLeft
                    , width fill
                    ]
                    [ viewFacet "notation" language activeSearch body
                    ]
                ]
            , viewFacetSection language
                [ row
                    widthFillHeightFill
                    [ column
                        [ width fill
                        , alignTop
                        ]
                        [ searchKeywordInput language msgs qText ]
                    ]
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
                        [ viewFacet "composer" language model.activeSearch body
                        ]
                    ]
                ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet "date-range" language model.activeSearch body ]
                    ]
                ]
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
                        [ viewFacet "is-mensural" language activeSearch body
                        , viewFacet "has-notation" language activeSearch body
                        ]
                    ]
                ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet "clef" language activeSearch body
                        ]
                    ]
                ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet "key-signature" language activeSearch body
                        ]
                    ]
                ]
            , viewFacetSection language
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet "time-signature" language activeSearch body
                        ]
                    ]
                ]
            ]
        ]
