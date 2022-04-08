module Page.Search.Views.SearchControls.Incipits exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignLeft, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)


viewFacetsForIncipitsMode : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
viewFacetsForIncipitsMode language model body =
    let
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
                [ width fill ]
                [ column
                    [ alignTop
                    , alignLeft
                    , width fill
                    ]
                    [ viewFacet (facetConfig "notation") facetSearchMsgConfig
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
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
                        [ viewFacet (facetConfig "composer") facetSearchMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "date-range") facetSearchMsgConfig ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill
                        , alignTop
                        , spacing lineSpacing
                        ]
                        [ viewFacet (facetConfig "is-mensural") facetSearchMsgConfig
                        , viewFacet (facetConfig "has-notation") facetSearchMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "clef") facetSearchMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "key-signature") facetSearchMsgConfig
                        ]
                    ]
                ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ column
                        [ width fill ]
                        [ viewFacet (facetConfig "time-signature") facetSearchMsgConfig
                        ]
                    ]
                ]
            ]
        ]
