module Page.UI.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)

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
        activeFilters =
            toNextQuery config.activeSearch
                |> toFilters

        facetAlias =
            .alias config.toggleFacet

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
