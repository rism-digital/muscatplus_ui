module Page.Search.Views.SearchControls.Institutions exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (dividerWithText)


facetsForInstitutionsModeView : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
facetsForInstitutionsModeView language model body =
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
                [ viewFacet "has-siglum" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "city" language activeSearch body
                ]
            ]
        ]
