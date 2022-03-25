module Page.Search.Views.SearchControls.People exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (lineSpacing, widthFillHeightFill)
import Page.UI.Components exposing (dividerWithText)


facetsForPeopleModeView : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
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
                [ viewFacet "roles" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "date-range" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "associated-place" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "gender" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "profession" language activeSearch body ]
            ]
        ]
