module Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)

import Element exposing (Element, alignTop, column, paddingEach, row, spacingXY)
import Element.Border as Border
import Language.LocalTranslations exposing (facetPanelTitles)
import Language.Tooltips exposing (tooltips)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)
import Page.UI.Style exposing (colourScheme)


personFacetPanels :
    { biographicalInfoPanel : PanelConfig
    , roleAndProfession : PanelConfig
    , personResultsPanel : PanelConfig
    }
personFacetPanels =
    { biographicalInfoPanel =
        { alias = "person-biography-panel"
        , label = facetPanelTitles.biographicalDetails
        }
    , roleAndProfession =
        { alias = "person-role-profession-panel"
        , label = facetPanelTitles.roleAndProfession
        }
    , personResultsPanel =
        { alias = "person-results-panel"
        , label = facetPanelTitles.results
        }
    }


viewFacetsForPeopleMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForPeopleMode cfg =
    let
        dates =
            viewFacet (createFacetConfig cfg "date-range" tooltips.dateRange) cfg.facetMsgConfig

        gender =
            viewFacet (createFacetConfig cfg "gender" tooltips.gender) cfg.facetMsgConfig

        places =
            viewFacet (createFacetConfig cfg "associated-place" tooltips.associatedPlace) cfg.facetMsgConfig

        role =
            viewFacet (createFacetConfig cfg "roles" tooltips.roles) cfg.facetMsgConfig

        profession =
            viewFacet (createFacetConfig cfg "profession" tooltips.profession) cfg.facetMsgConfig

        diammRecordsToggle =
            viewFacet (createFacetConfig cfg "hide-diamm-records" tooltips.diammProject) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias personFacetPanels.personResultsPanel)
        (.label personFacetPanels.personResultsPanel)
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
        (.alias personFacetPanels.biographicalInfoPanel)
        (.label personFacetPanels.biographicalInfoPanel)
        cfg
        [ dates
        , gender
        , places
        ]
    , viewFacetsControlPanel
        (.alias personFacetPanels.roleAndProfession)
        (.label personFacetPanels.roleAndProfession)
        cfg
        [ role
        , profession
        ]
    ]
