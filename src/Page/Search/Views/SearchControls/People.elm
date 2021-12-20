module Page.Search.Views.SearchControls.People exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, el, fill, height, padding, row, scrollbarY, spacing, text, width)
import Element.Border as Border
import Language exposing (Language)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Attributes exposing (facetBorderBottom, headingMD, lineSpacing, widthFillHeightFill)
import Page.UI.Components exposing (searchKeywordInput)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewFacetsForPeopleMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForPeopleMode language model body =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserInputTextInQueryBox
            }

        activeSearch =
            toActiveSearch model

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""
    in
    row
        (List.append
            [ padding 10
            , scrollbarY
            ]
            widthFillHeightFill
        )
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
                (List.append
                    [ width fill
                    , alignTop
                    ]
                    []
                 --facetBorderBottom
                )
                [ column
                    (List.append
                        []
                        widthFillHeightFill
                    )
                    [ el
                        [ width fill
                        , headingMD
                        ]
                        (text "Record type refinements")
                    ]
                ]
            , viewFacetSection language
                "Roles"
                [ viewFacet "person-role" language activeSearch body ]
            , viewFacetSection language
                "Dates"
                [ viewFacet "date-range" language activeSearch body ]
            ]
        ]
