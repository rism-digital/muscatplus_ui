module Page.Search.Views.SearchControls.People exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, el, fill, height, padding, row, scrollbarY, spacing, text, width)
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Attributes exposing (facetBorderBottom, headingMD, lineSpacing, widthFillHeightFill)
import Page.UI.Components exposing (searchKeywordInput)


viewFacetsForPeopleMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForPeopleMode language model body =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserInputTextInKeywordQueryBox
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
                        (text "Person record filters")
                    ]
                ]
            , viewFacetSection language
                [ viewFacet "person-role" language activeSearch body ]
            , viewFacetSection language
                [ viewFacet "date-range" language activeSearch body ]
            ]
        ]
