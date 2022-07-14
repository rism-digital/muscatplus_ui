module Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


personFacetPanels :
    { biographicalInfoPanel : PanelConfig
    , roleAndProfession : PanelConfig
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
    }


viewFacetsForPeopleMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForPeopleMode cfg =
    let
        dates =
            viewFacet (createFacetConfig cfg "date-range" []) cfg.facetMsgConfig

        gender =
            viewFacet (createFacetConfig cfg "gender" []) cfg.facetMsgConfig

        places =
            viewFacet (createFacetConfig cfg "associated-place" []) cfg.facetMsgConfig

        role =
            viewFacet (createFacetConfig cfg "roles" []) cfg.facetMsgConfig

        profession =
            viewFacet (createFacetConfig cfg "profession" []) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
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
