module Page.Facets.ToggleFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, column, el, paddingXY, row)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Query exposing (toFilters, toNextQuery)
import Page.RecordTypes.Search exposing (ToggleFacet)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Facets.Toggle as Toggle


type alias ToggleFacetConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , toggleFacet : ToggleFacet
    , userClickedFacetToggleMsg : FacetAlias -> msg
    }


viewToggleFacet : ToggleFacetConfig msg -> Element msg
viewToggleFacet config =
    let
        facetAlias =
            .alias config.toggleFacet

        activeFilters =
            toNextQuery config.activeSearch
                |> toFilters

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
                    (Toggle.view isActive (config.userClickedFacetToggleMsg facetAlias)
                        |> Toggle.setLabel (extractLabelFromLanguageMap config.language (.label config.toggleFacet))
                        |> Toggle.render
                    )
                ]
            ]
        ]