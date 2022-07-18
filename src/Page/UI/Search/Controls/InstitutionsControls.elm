module Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Language.Tooltips exposing (tooltips)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


institutionFacetPanels : { locationPanel : PanelConfig }
institutionFacetPanels =
    { locationPanel =
        { alias = "institution-location-panel"
        , label = facetPanelTitles.location
        }
    }


viewFacetsForInstitutionsMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForInstitutionsMode cfg =
    let
        city =
            viewFacet (createFacetConfig cfg "city" tooltips.city) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias institutionFacetPanels.locationPanel)
        (.label institutionFacetPanels.locationPanel)
        cfg
        [ city
        ]
    ]
