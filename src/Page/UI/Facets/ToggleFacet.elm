module Page.UI.Facets.ToggleFacet exposing (ToggleFacetConfig, viewToggleFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, centerX, centerY, column, el, height, paddingXY, row, shrink, spacing, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.Query exposing (toFilters, toNextQuery)
import Page.RecordTypes.Search exposing (ToggleFacet)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (bodySM)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Tooltip exposing (facetTooltip)


type alias ToggleFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
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
        [ spacing 8
        , paddingXY 0 8
        ]
        [ column
            []
            [ row
                []
                [ el [ bodySM ]
                    (Toggle.view isActive (config.userClickedFacetToggleMsg facetAlias)
                        |> Toggle.setLabel (extractLabelFromLanguageMap config.language (.label config.toggleFacet))
                        |> Toggle.render
                    )
                ]
            ]
        , column
            [ width shrink
            , height shrink
            , centerX
            , centerY
            ]
            [ facetTooltip above (extractLabelFromLanguageMap config.language config.tooltip)
            ]
        ]
