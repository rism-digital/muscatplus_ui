module Page.Search.Views.SearchControls.Sources exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, maximum, minimum, padding, row, spacing, width)
import Language exposing (Language)
import Page.Query exposing (toQuery, toQueryArgs)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Attributes exposing (sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (searchKeywordInput)


viewFacetsForSourcesMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForSourcesMode language model body =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserInputTextInQueryBox
            }

        activeSearch =
            toActiveSearch model

        qText =
            toQueryArgs activeSearch
                |> toQuery
                |> Maybe.withDefault ""
    in
    row
        (List.append [ padding 20, alignTop ] widthFillHeightFill)
        [ column
            (List.append [ spacing sectionSpacing, alignTop ] widthFillHeightFill)
            [ row
                (List.append [ alignTop ] widthFillHeightFill)
                [ column
                    [ width (fill |> minimum 800 |> maximum 1100)
                    , alignTop
                    ]
                    [ searchKeywordInput language msgs qText ]
                ]
            , viewFacetSection language
                "Digitization"
                [ viewFacet "has-digitization" language activeSearch body ]
            , viewFacetSection language
                "Incipits"
                [ viewFacet "has-incipits" language activeSearch body ]
            , viewFacetSection language
                "Record types"
                [ viewFacet "hide-source-contents" language activeSearch body
                , viewFacet "hide-source-collections" language activeSearch body
                , viewFacet "hide-composite-volumes" language activeSearch body
                , viewFacet "source-type" language activeSearch body
                , viewFacet "content-types" language activeSearch body
                , viewFacet "material-group-types" language activeSearch body
                ]
            , viewFacetSection language
                "Format, Extent, Language"
                [ viewFacet "text-language" language activeSearch body
                , viewFacet "format-extent" language activeSearch body
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                "Subjects"
                [ viewFacet "subjects" language activeSearch body ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]
