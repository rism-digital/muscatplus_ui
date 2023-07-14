module Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Language.Tooltips exposing (tooltips)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


institutionFacetPanels :
    { locationPanel : PanelConfig
    , relationshipPanel : PanelConfig
    }
institutionFacetPanels =
    { locationPanel =
        { alias = "institution-location-panel"
        , label = facetPanelTitles.location
        }
    , relationshipPanel =
        { alias = "institution-relationship-panel"
        , label = facetPanelTitles.sourceRelationships
        }
    }


viewFacetsForInstitutionsMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForInstitutionsMode cfg =
    let
        city =
            viewFacet (createFacetConfig cfg "city" tooltips.city) cfg.facetMsgConfig

        sigla =
            viewFacet (createFacetConfig cfg "sigla" tooltips.institutionSigla) cfg.facetMsgConfig

        hasSigla =
            viewFacet (createFacetConfig cfg "has-siglum" tooltips.institutionSigla) cfg.facetMsgConfig

        roles =
            viewFacet (createFacetConfig cfg "roles" tooltips.roles) cfg.facetMsgConfig

        numberSources =
            viewFacet (createFacetConfig cfg "number-sources" tooltips.institutionNumHoldings) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias institutionFacetPanels.locationPanel)
        (.label institutionFacetPanels.locationPanel)
        cfg
        [ city
        , sigla
        , hasSigla
        ]
    , viewFacetsControlPanel
        (.alias institutionFacetPanels.relationshipPanel)
        (.label institutionFacetPanels.relationshipPanel)
        cfg
        [ roles
        , numberSources
        ]
    ]
