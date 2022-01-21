module Page.Search.Views.SearchControls.Institutions exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, column, padding, row, scrollbarY, spacing)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewFacet)
import Page.UI.Attributes exposing (lineSpacing, widthFillHeightFill)


facetsForInstitutionsModeView : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
facetsForInstitutionsModeView language model body =
    let
        activeSearch =
            toActiveSearch model
    in
    row
        (List.append
            [ padding 10
            , scrollbarY
            ]
            widthFillHeightFill
        )
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ viewFacet "city" language activeSearch body
            ]
        ]
