module Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)

import Element exposing (Element, column, none, paddingEach, row, spacing)
import Element.Border as Border
import Language.LocalTranslations exposing (facetPanelTitles, localTranslations)
import Language.Tooltips exposing (tooltips)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.FacetsConfig exposing (createFacetConfig)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig, PanelConfig)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


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
        , label = facetPanelTitles.sourceRelationships
        }
    , holdingInstitutionPanel =
        { alias = "holding-institutions-panel"
        , label = facetPanelTitles.holdingInstitutions
        }
    , sourceContentsPanel =
        { alias = "source-contents-panel"
        , label = facetPanelTitles.sourceContents
        }
    , publicationProductionPanel =
        { alias = "source-production-panel"
        , label = facetPanelTitles.publicationDetails
        }
    }


viewFacetsForSourcesMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForSourcesMode cfg =
    let
        hasIncipitsToggle =
            viewFacet (createFacetConfig cfg "has-incipits" tooltips.hasIncipits) cfg.facetMsgConfig

        institutionSigla =
            viewFacet (createFacetConfig cfg "sigla" tooltips.institutionSigla) cfg.facetMsgConfig

        institutionNumHoldings =
            viewFacet (createFacetConfig cfg "num-holdings" tooltips.institutionNumHoldings) cfg.facetMsgConfig

        composerRelationships =
            viewFacet (createFacetConfig cfg "composer" tooltips.composerAuthor) cfg.facetMsgConfig

        otherPeopleRelationships =
            viewFacet (createFacetConfig cfg "people" tooltips.otherPeople) cfg.facetMsgConfig

        subjects =
            viewFacet (createFacetConfig cfg "subjects" tooltips.subjects) cfg.facetMsgConfig

        {-
           -- disabled until the 593 issue has been sorted out.
           contentType =
               viewFacet (createFacetConfig cfg "content-types" []) cfg.facetMsgConfig

           recordType =
               viewFacet (createFacetConfig cfg "record-type" []) cfg.facetMsgConfig
        -}
        dateRange =
            viewFacet (createFacetConfig cfg "date-range" tooltips.dateRange) cfg.facetMsgConfig

        formatExtent =
            viewFacet (createFacetConfig cfg "format-extent" tooltips.formatExtent) cfg.facetMsgConfig

        textLanguage =
            viewFacet (createFacetConfig cfg "text-language" tooltips.textLanguage) cfg.facetMsgConfig

        scoring =
            viewFacet (createFacetConfig cfg "scoring" tooltips.scoring) cfg.facetMsgConfig

        sourceResultsPanel =
            let
                sourceType =
                    viewFacet (createFacetConfig cfg "source-type" []) cfg.facetMsgConfig

                materialSourceType =
                    viewFacet (createFacetConfig cfg "material-source-types" []) cfg.facetMsgConfig

                materialContentType =
                    viewFacet (createFacetConfig cfg "material-content-types" []) cfg.facetMsgConfig

                sourceContentsToggle =
                    viewFacet (createFacetConfig cfg "hide-source-contents" tooltips.sourceContents) cfg.facetMsgConfig

                sourceCollectionsToggle =
                    viewFacet (createFacetConfig cfg "hide-source-collections" tooltips.sourceCollections) cfg.facetMsgConfig

                compositeVolumesToggle =
                    viewFacet (createFacetConfig cfg "hide-composite-volumes" tooltips.compositeVolume) cfg.facetMsgConfig

                allAreEmpty =
                    List.all
                        (\a -> a == none)
                        [ sourceType, sourceContentsToggle, sourceCollectionsToggle, compositeVolumesToggle, materialSourceType, materialContentType ]
            in
            if allAreEmpty then
                none

            else
                viewFacetsControlPanel
                    (.alias sourceFacetPanels.sourceResultsPanel)
                    (.label sourceFacetPanels.sourceResultsPanel)
                    cfg
                    [ row
                        [ paddingEach { top = 0, bottom = 10, left = 0, right = 0 }
                        ]
                        [ column
                            [ Border.widthEach { top = 0, bottom = 0, left = 2, right = 0 }
                            , Border.color (colourScheme.midGrey |> convertColorToElementColor)
                            ]
                            [ row [] [ sourceContentsToggle ]
                            , row [] [ sourceCollectionsToggle ]
                            , row [] [ compositeVolumesToggle ]
                            ]
                        ]
                    , sourceType
                    , materialSourceType
                    , materialContentType

                    --, contentType
                    --, recordType
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
                        []
                        [ hasDigitizationToggle
                        , hasIiifToggle
                        ]
                    ]
    in
    [ sourceResultsPanel
    , viewFacetsControlPanel
        (.alias sourceFacetPanels.peopleRelationshipsPanel)
        (.label sourceFacetPanels.peopleRelationshipsPanel)
        cfg
        [ composerRelationships
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
