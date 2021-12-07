module Page.Search.Views.SearchControls.People exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, column, row)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet)
import Page.UI.Attributes exposing (widthFillHeightFill)


viewFacetsForPeopleMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForPeopleMode language model body =
    let
        activeSearch =
            toActiveSearch model
    in
    row
        widthFillHeightFill
        [ column
            widthFillHeightFill
            [ viewFacet "person-role" language activeSearch body
            , viewFacet "date-range" language activeSearch body
            ]
        ]
