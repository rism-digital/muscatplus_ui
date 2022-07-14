module Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)

import Element exposing (Element, paddingEach, row)
import Language.LocalTranslations exposing (facetPanelTitles, localTranslations)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


sourceFacetPanels :
    { sourceResultsPanel : PanelConfig
    , digitizationPanel : PanelConfig
    , incipitPanel : PanelConfig
    , peopleRelationshipsPanel : PanelConfig
    , holdingInstitutionPanel : PanelConfig
    , sourceContentsPanel : PanelConfig
    , publicationProductionPanel : PanelConfig
    }
sourceFacetPanels =
    { sourceResultsPanel =
        { alias = "source-results-panel"
        , label = facetPanelTitles.results -- TODO: Change to an actual label
        }
    , digitizationPanel =
        { alias = "source-digitizations-panel"
        , label = facetPanelTitles.digitizations -- TODO: Change to an actual label
        }
    , incipitPanel =
        { alias = "source-incipits-panel"
        , label = localTranslations.incipits
        }
    , peopleRelationshipsPanel =
        { alias = "source-people-relationships-panel"
        , label = facetPanelTitles.peopleRelationships
        }
    , holdingInstitutionPanel =
        { alias = "holding-institutions-panel"
        , label = facetPanelTitles.institutionRelationships
        }
    , sourceContentsPanel =
        { alias = "source-contents-panel"
        , label = facetPanelTitles.sourceContents
        }
    , publicationProductionPanel =
        { alias = "source-production-panel"
        , label = facetPanelTitles.publicationProduction
        }
    }


viewFacetsForSourcesMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForSourcesMode cfg =
    let
        compositeVolumesToggle =
            viewFacet (createFacetConfig cfg "hide-composite-volumes" []) cfg.facetMsgConfig

        sourceCollectionsToggle =
            viewFacet (createFacetConfig cfg "hide-source-collections" []) cfg.facetMsgConfig

        sourceContentsToggle =
            viewFacet (createFacetConfig cfg "hide-source-contents" []) cfg.facetMsgConfig

        hasDigitizationToggle =
            viewFacet (createFacetConfig cfg "has-digitization" []) cfg.facetMsgConfig

        hasIiifToggle =
            viewFacet (createFacetConfig cfg "has-iiif" []) cfg.facetMsgConfig

        hasIncipitsToggle =
            viewFacet (createFacetConfig cfg "has-incipits" []) cfg.facetMsgConfig

        institutionSigla =
            viewFacet (createFacetConfig cfg "sigla" []) cfg.facetMsgConfig

        institutionNumHoldings =
            viewFacet (createFacetConfig cfg "num-holdings" []) cfg.facetMsgConfig

        composerRelationships =
            viewFacet (createFacetConfig cfg "composer" []) cfg.facetMsgConfig

        otherPeopleRelationships =
            viewFacet (createFacetConfig cfg "people" []) cfg.facetMsgConfig

        subjects =
            viewFacet (createFacetConfig cfg "subjects" []) cfg.facetMsgConfig

        materialType =
            viewFacet (createFacetConfig cfg "material-types" []) cfg.facetMsgConfig

        contentType =
            viewFacet (createFacetConfig cfg "content-types" []) cfg.facetMsgConfig

        recordType =
            viewFacet (createFacetConfig cfg "record-type" []) cfg.facetMsgConfig

        dateRange =
            viewFacet (createFacetConfig cfg "date-range" []) cfg.facetMsgConfig

        formatExtent =
            viewFacet (createFacetConfig cfg "format-extent" []) cfg.facetMsgConfig

        textLanguage =
            viewFacet (createFacetConfig cfg "text-language" []) cfg.facetMsgConfig

        scoring =
            viewFacet (createFacetConfig cfg "scoring" []) cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias sourceFacetPanels.sourceResultsPanel)
        (.label sourceFacetPanels.sourceResultsPanel)
        cfg
        [ row
            [ paddingEach { top = 0, bottom = 10, left = 0, right = 0 } ]
            [ sourceContentsToggle
            , sourceCollectionsToggle
            , compositeVolumesToggle
            ]
        , materialType
        , contentType
        , recordType
        ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.peopleRelationshipsPanel)
        (.label sourceFacetPanels.peopleRelationshipsPanel)
        cfg
        [ composerRelationships
        , otherPeopleRelationships
        ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.digitizationPanel)
        (.label sourceFacetPanels.digitizationPanel)
        cfg
        [ row
            []
            [ hasDigitizationToggle
            , hasIiifToggle
            ]
        ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.incipitPanel)
        (.label sourceFacetPanels.incipitPanel)
        cfg
        [ hasIncipitsToggle ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.sourceContentsPanel)
        (.label sourceFacetPanels.sourceContentsPanel)
        cfg
        [ scoring
        , subjects
        , textLanguage
        ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.publicationProductionPanel)
        (.label sourceFacetPanels.publicationProductionPanel)
        cfg
        [ dateRange
        , formatExtent
        ]
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.holdingInstitutionPanel)
        (.label sourceFacetPanels.holdingInstitutionPanel)
        cfg
        [ institutionSigla
        , institutionNumHoldings
        ]
    ]
