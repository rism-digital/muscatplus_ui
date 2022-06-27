module Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)

import Element exposing (Element)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
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
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        dates =
            viewFacet (facetConfig "date-range") cfg.facetMsgConfig

        gender =
            viewFacet (facetConfig "gender") cfg.facetMsgConfig

        places =
            viewFacet (facetConfig "associated-place") cfg.facetMsgConfig

        role =
            viewFacet (facetConfig "roles") cfg.facetMsgConfig

        profession =
            viewFacet (facetConfig "profession") cfg.facetMsgConfig
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
