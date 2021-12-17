module Page.Search.Views.Facets.ToggleFacet exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, column, el, paddingXY, row)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Query exposing (Filter(..))
import Page.RecordTypes.Search exposing (ToggleFacet)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Facets.Toggle as Toggle


viewToggleFacet : Language -> Dict FacetAlias (List String) -> ToggleFacet -> Element SearchMsg
viewToggleFacet language activeFilters facet =
    let
        facetAlias =
            facet.alias

        isActive =
            Dict.member facetAlias activeFilters
    in
    row
        []
        [ column
            []
            [ row
                [ paddingXY 10 0 ]
                [ el []
                    (Toggle.view isActive (UserClickedFacetToggle facet.alias)
                        |> Toggle.setLabel (extractLabelFromLanguageMap language facet.label)
                        |> Toggle.render
                    )
                ]
            ]
        ]
