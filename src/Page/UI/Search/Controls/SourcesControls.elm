module Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)

import Element exposing (Element, alignTop, column, none, row, spacing)
import Element.Lazy exposing (lazy2)
import Language.LocalTranslations exposing (facetPanelTitles, localTranslations)
import Language.Tooltips exposing (tooltips)
import Page.UI.Components exposing (verticalLine)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)


sourceFacetPanels :
    { digitizationPanel : PanelConfig
    , holdingInstitutionPanel : PanelConfig
    , incipitPanel : PanelConfig
    , peopleRelationshipsPanel : PanelConfig
    , publicationProductionPanel : PanelConfig
    , sourceContentsPanel : PanelConfig
    , sourceResultsPanel : PanelConfig
    }
sourceFacetPanels =
    { digitizationPanel =
        { alias = "source-digitizations-panel"
        , label = facetPanelTitles.digitizations -- TODO: Change to an actual label
        }
    , holdingInstitutionPanel =
        { alias = "holding-institutions-panel"
        , label = facetPanelTitles.holdingInstitutions
        }
    , incipitPanel =
        { alias = "source-incipits-panel"
        , label = localTranslations.incipits
        }
    , peopleRelationshipsPanel =
        { alias = "source-people-relationships-panel"
        , label = facetPanelTitles.sourceRelationships
        }
    , publicationProductionPanel =
        { alias = "source-production-panel"
        , label = facetPanelTitles.publicationDetails
        }
    , sourceContentsPanel =
        { alias = "source-contents-panel"
        , label = facetPanelTitles.sourceContents
        }
    , sourceResultsPanel =
        { alias = "source-results-panel"
        , label = facetPanelTitles.results -- TODO: Change to an actual label
        }
    }


viewFacetsForSourcesMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForSourcesMode cfg =
    let
        hasIncipitsToggle =
            lazy2 viewFacet (createFacetConfig cfg "has-incipits" tooltips.hasIncipits) cfg.facetMsgConfig

        institutionSigla =
            lazy2 viewFacet (createFacetConfig cfg "sigla" tooltips.institutionSigla) cfg.facetMsgConfig

        institutionNumHoldings =
            lazy2 viewFacet (createFacetConfig cfg "num-holdings" tooltips.institutionNumHoldings) cfg.facetMsgConfig

        composerRelationships =
            lazy2 viewFacet (createFacetConfig cfg "composer" tooltips.composerAuthor) cfg.facetMsgConfig

        otherPeopleRelationships =
            lazy2 viewFacet (createFacetConfig cfg "people" tooltips.otherPeople) cfg.facetMsgConfig

        hasAnonymousCreator =
            lazy2 viewFacet (createFacetConfig cfg "has-anonymous-creator" tooltips.anonymousCreator) cfg.facetMsgConfig

        subjects =
            lazy2 viewFacet (createFacetConfig cfg "subjects" tooltips.subjects) cfg.facetMsgConfig

        dateRange =
            lazy2 viewFacet (createFacetConfig cfg "date-range" tooltips.dateRange) cfg.facetMsgConfig

        formatExtent =
            lazy2 viewFacet (createFacetConfig cfg "format-extent" tooltips.formatExtent) cfg.facetMsgConfig

        textLanguage =
            lazy2 viewFacet (createFacetConfig cfg "text-language" tooltips.textLanguage) cfg.facetMsgConfig

        scoring =
            lazy2 viewFacet (createFacetConfig cfg "scoring" tooltips.scoring) cfg.facetMsgConfig

        sourceResultsPanel =
            let
                sourceType =
                    lazy2 viewFacet (createFacetConfig cfg "source-type" []) cfg.facetMsgConfig

                materialSourceType =
                    lazy2 viewFacet (createFacetConfig cfg "material-source-types" []) cfg.facetMsgConfig

                materialContentType =
                    lazy2 viewFacet (createFacetConfig cfg "material-content-types" []) cfg.facetMsgConfig

                sourceContentsToggle =
                    lazy2 viewFacet (createFacetConfig cfg "hide-source-contents" tooltips.sourceContents) cfg.facetMsgConfig

                sourceCollectionsToggle =
                    lazy2 viewFacet (createFacetConfig cfg "hide-source-collections" tooltips.sourceCollections) cfg.facetMsgConfig

                compositeVolumesToggle =
                    lazy2 viewFacet (createFacetConfig cfg "hide-composite-volumes" tooltips.compositeVolume) cfg.facetMsgConfig

                diammRecordsToggle =
                    lazy2 viewFacet (createFacetConfig cfg "hide-diamm-records" tooltips.diammProject) cfg.facetMsgConfig

                cantusRecordsToggle =
                    lazy2 viewFacet (createFacetConfig cfg "hide-cantus-records" tooltips.cantusProject) cfg.facetMsgConfig

                allAreEmpty =
                    List.all
                        (\a -> a == none)
                        [ sourceType
                        , sourceContentsToggle
                        , sourceCollectionsToggle
                        , compositeVolumesToggle
                        , materialSourceType
                        , materialContentType
                        , diammRecordsToggle
                        , cantusRecordsToggle
                        ]
            in
            if allAreEmpty then
                none

            else
                viewFacetsControlPanel
                    (.alias sourceFacetPanels.sourceResultsPanel)
                    (.label sourceFacetPanels.sourceResultsPanel)
                    cfg
                    [ row
                        [ spacing 8
                        ]
                        [ column
                            []
                            [ row [] [ sourceContentsToggle ]
                            , row [] [ sourceCollectionsToggle ]
                            , row [] [ compositeVolumesToggle ]
                            ]
                        , verticalLine
                        , column
                            [ alignTop ]
                            [ row [] [ diammRecordsToggle ]
                            , row [] [ cantusRecordsToggle ]
                            ]
                        ]
                    , sourceType
                    , materialContentType
                    , materialSourceType
                    ]

        digitizationResultsPanel =
            let
                hasIiifToggle =
                    viewFacet (createFacetConfig cfg "has-iiif" tooltips.hasIiif) cfg.facetMsgConfig

                hasDigitizationToggle =
                    viewFacet (createFacetConfig cfg "has-digitization" tooltips.hasDigitization) cfg.facetMsgConfig

                allAreEmpty =
                    List.all
                        (\a -> a == none)
                        [ hasDigitizationToggle, hasIiifToggle ]
            in
            if allAreEmpty then
                none

            else
                viewFacetsControlPanel
                    (.alias sourceFacetPanels.digitizationPanel)
                    (.label sourceFacetPanels.digitizationPanel)
                    cfg
                    [ row
                        [ spacing 8 ]
                        [ hasDigitizationToggle
                        , verticalLine
                        , hasIiifToggle
                        ]
                    ]
    in
    [ sourceResultsPanel
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.peopleRelationshipsPanel)
        (.label sourceFacetPanels.peopleRelationshipsPanel)
        cfg
        [ hasAnonymousCreator
        , composerRelationships
        , otherPeopleRelationships
        ]
    , digitizationResultsPanel
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
