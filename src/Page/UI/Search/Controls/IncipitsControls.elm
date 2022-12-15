module Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


incipitFacetPanels :
    { composerPanel : PanelConfig
    , musicalFeaturesPanel : PanelConfig
    }
incipitFacetPanels =
    { composerPanel =
        { alias = "incipit-composer-panel"
        , label = facetPanelTitles.composerComposition
        }
    , musicalFeaturesPanel =
        { alias = "incipit-musical-features-panel"
        , label = facetPanelTitles.clefKeyTime
        }
    }


viewFacetsForIncipitsMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForIncipitsMode cfg =
    let
        composer =
            viewFacet (createFacetConfig cfg "composer" []) cfg.facetMsgConfig

        clef =
            viewFacet (createFacetConfig cfg "clef" []) cfg.facetMsgConfig

        keysig =
            viewFacet (createFacetConfig cfg "key-signature" []) cfg.facetMsgConfig

        timesig =
            viewFacet (createFacetConfig cfg "time-signature" []) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias incipitFacetPanels.musicalFeaturesPanel)
        (.label incipitFacetPanels.musicalFeaturesPanel)
        cfg
        [ clef
        , keysig
        , timesig
        ]
    , viewFacetsControlPanel
        (.alias incipitFacetPanels.composerPanel)
        (.label incipitFacetPanels.composerPanel)
        cfg
        [ composer ]
    ]
