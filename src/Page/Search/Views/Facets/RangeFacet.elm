module Page.Search.Views.Facets.RangeFacet exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, alignTop, column, fill, paddingXY, row, text, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (RangeFacet)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Msg exposing (SearchMsg)
import Page.UI.Components exposing (h5)


viewRangeFacet : Language -> Dict FacetAlias (List String) -> RangeFacet -> Element SearchMsg
viewRangeFacet language activeFilters body =
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ h5 language body.label ]
            , row
                [ width fill
                , paddingXY 20 10
                ]
                [ text "TODO: Implement range behaviour" ]
            ]
        ]
