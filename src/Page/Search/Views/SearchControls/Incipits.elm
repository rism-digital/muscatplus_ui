module Page.Search.Views.SearchControls.Incipits exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet)
import Page.UI.Attributes exposing (lineSpacing, widthFillHeightFill)


viewFacetsForIncipitsMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForIncipitsMode language model body =
    let
        activeSearch =
            toActiveSearch model
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
                    [ viewFacet "notation" language activeSearch body
                    ]
                ]
            , row
                widthFillHeightFill
                [ column
                    widthFillHeightFill
                    [ viewFacet "is-mensural" language activeSearch body
                    , viewFacet "has-notation" language activeSearch body
                    ]
                ]
            , row
                widthFillHeightFill
                [ column
                    widthFillHeightFill
                    [ viewFacet "composer" language activeSearch body
                    , viewFacet "clef" language activeSearch body
                    ]
                , column
                    widthFillHeightFill
                    [ viewFacet "date-range" language activeSearch body
                    ]
                ]
            ]
        ]
