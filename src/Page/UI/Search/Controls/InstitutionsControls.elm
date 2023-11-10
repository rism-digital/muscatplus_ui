module Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)

import Element exposing (Element, alignTop, column, paddingEach, row, spacingXY)
import Language.LocalTranslations exposing (facetPanelTitles)
import Language.Tooltips exposing (tooltips)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


institutionFacetPanels :
    { institutionResultsPanel : PanelConfig
    , locationPanel : PanelConfig
    , relationshipPanel : PanelConfig
    }
institutionFacetPanels =
    { institutionResultsPanel =
        { alias = "institution-results-panel"
        , label = facetPanelTitles.results
        }
    , locationPanel =
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
            viewFacet (createFacetConfig cfg "has-siglum" tooltips.institutionHasSigla) cfg.facetMsgConfig

        roles =
            viewFacet (createFacetConfig cfg "roles" tooltips.institutionRoles) cfg.facetMsgConfig

        numberSources =
            viewFacet (createFacetConfig cfg "number-sources" tooltips.institutionNumHoldings) cfg.facetMsgConfig

        diammRecordsToggle =
            viewFacet (createFacetConfig cfg "hide-diamm-records" tooltips.diammProject) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias institutionFacetPanels.institutionResultsPanel)
        (.label institutionFacetPanels.institutionResultsPanel)
        cfg
        [ row
            [ paddingEach { bottom = 10, left = 0, right = 0, top = 0 }
            , spacingXY 20 0
            ]
            [ column
                [ alignTop ]
                [ row [] [ diammRecordsToggle ]
                ]
            ]
        ]
    , viewFacetsControlPanel
        (.alias institutionFacetPanels.locationPanel)
        (.label institutionFacetPanels.locationPanel)
        cfg
        [ hasSigla
        , city
        , sigla
        ]
    , viewFacetsControlPanel
        (.alias institutionFacetPanels.relationshipPanel)
        (.label institutionFacetPanels.relationshipPanel)
        cfg
        [ roles
        , numberSources
        ]
    ]
