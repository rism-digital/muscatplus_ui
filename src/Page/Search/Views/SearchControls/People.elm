module Page.Search.Views.SearchControls.People exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Facets.Facets exposing (FacetConfig, viewFacet, viewFacetSection)
import Page.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (dividerWithText)


facetsForPeopleModeView : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
facetsForPeopleModeView language model body =
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

        facetConfig : String -> FacetConfig SearchBody
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = body
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
                [ viewFacet (facetConfig "roles") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "date-range") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "associated-place") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "gender") facetSearchMsgConfig ]
            , viewFacetSection language
                SearchMsg.NothingHappened
                [ viewFacet (facetConfig "profession") facetSearchMsgConfig ]
            ]
        ]
