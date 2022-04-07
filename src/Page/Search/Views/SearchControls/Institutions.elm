module Page.Search.Views.SearchControls.Institutions exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, width)
import Language exposing (Language)
import Page.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig)
import Page.UI.Components exposing (dividerWithText)


facetsForInstitutionsModeView : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
facetsForInstitutionsModeView language model body =
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
            , selectColumns = 3
            }
    in
    row
        [ width fill
        , height fill
        , alignTop
        , padding 10
        , scrollbarY
        ]
        [ column
            [ width fill
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
                [ viewFacet (facetConfig "has-siglum") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "city") facetSearchMsgConfig
                ]
            ]
        ]
