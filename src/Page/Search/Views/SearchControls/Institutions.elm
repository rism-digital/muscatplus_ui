module Page.Search.Views.SearchControls.Institutions exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, column, row)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet)
import Page.UI.Attributes exposing (widthFillHeightFill)


viewFacetsForInstitutionsMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForInstitutionsMode language model body =
    let
        activeSearch =
            toActiveSearch model
    in
    row
        widthFillHeightFill
        [ column
            widthFillHeightFill
            [ viewFacet "date-range" language activeSearch body
            , viewFacet "city" language activeSearch body
            ]
        ]
