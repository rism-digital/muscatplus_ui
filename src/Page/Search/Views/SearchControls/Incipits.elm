module Page.Search.Views.SearchControls.Incipits exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, column, fill, height, row, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet)
import Page.UI.Attributes exposing (widthFillHeightFill)


viewFacetsForIncipitsMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForIncipitsMode language model body =
    let
        activeSearch =
            toActiveSearch model
    in
    row
        widthFillHeightFill
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ column [ width fill ]
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
