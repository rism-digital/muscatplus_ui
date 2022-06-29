module Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)

import Element exposing (Element, paddingEach, row)
import Language.LocalTranslations exposing (facetPanelTitles, localTranslations)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
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
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        compositeVolumesToggle =
            viewFacet (facetConfig "hide-composite-volumes") cfg.facetMsgConfig

        sourceCollectionsToggle =
            viewFacet (facetConfig "hide-source-collections") cfg.facetMsgConfig

        sourceContentsToggle =
            viewFacet (facetConfig "hide-source-contents") cfg.facetMsgConfig

        hasDigitizationToggle =
            viewFacet (facetConfig "has-digitization") cfg.facetMsgConfig

        hasIiifToggle =
            viewFacet (facetConfig "has-iiif") cfg.facetMsgConfig

        hasIncipitsToggle =
            viewFacet (facetConfig "has-incipits") cfg.facetMsgConfig

        institutionSigla =
            viewFacet (facetConfig "sigla") cfg.facetMsgConfig

        institutionNumHoldings =
            viewFacet (facetConfig "num-holdings") cfg.facetMsgConfig

        composerRelationships =
            viewFacet (facetConfig "composer") cfg.facetMsgConfig

        otherPeopleRelationships =
            viewFacet (facetConfig "people") cfg.facetMsgConfig

        subjects =
            viewFacet (facetConfig "subjects") cfg.facetMsgConfig

        materialType =
            viewFacet (facetConfig "material-types") cfg.facetMsgConfig

        contentType =
            viewFacet (facetConfig "content-types") cfg.facetMsgConfig

        recordType =
            viewFacet (facetConfig "record-type") cfg.facetMsgConfig

        dateRange =
            viewFacet (facetConfig "date-range") cfg.facetMsgConfig

        formatExtent =
            viewFacet (facetConfig "format-extent") cfg.facetMsgConfig

        textLanguage =
            viewFacet (facetConfig "text-language") cfg.facetMsgConfig

        scoring =
            viewFacet (facetConfig "scoring") cfg.facetMsgConfig
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
