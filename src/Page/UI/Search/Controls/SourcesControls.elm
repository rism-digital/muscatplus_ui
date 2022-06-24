module Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, centerY, column, el, fill, height, none, padding, paddingEach, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (facetPanelTitles, localTranslations)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Attributes exposing (headingLG, lineSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (FacetMsgConfig, viewFacet)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Images exposing (caretCircleDownSvg, caretCircleRightSvg)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Set



--viewFacetToggleSection : Language -> ActiveSearch msg -> SearchBody -> FacetMsgConfig msg -> Element msg
--viewFacetToggleSection language activeSearch body facetSearchMsgConfig =
--    let
--        allAreEmpty =
--            List.all (\a -> a == none) allToggles
--
--        allToggles =
--            [ sourceCollectionsToggle
--            , sourceContentsToggle
--            , compositeVolumesToggle
--            , hasDigitizationToggle
--            , hasIiifToggle
--            , isArrangementToggle
--            , hasIncipitsToggle
--            ]
--
--        compositeVolumesToggle =
--            viewFacet (facetConfig "hide-composite-volumes") facetSearchMsgConfig
--
--        facetConfig alias =
--            { alias = alias
--            , language = language
--            , activeSearch = activeSearch
--            , selectColumns = 3
--            , body = body
--            }
--
--        hasDigitizationToggle =
--            viewFacet (facetConfig "has-digitization") facetSearchMsgConfig
--
--        hasIiifToggle =
--            viewFacet (facetConfig "has-iiif") facetSearchMsgConfig
--
--        hasIncipitsToggle =
--            viewFacet (facetConfig "has-incipits") facetSearchMsgConfig
--
--        isArrangementToggle =
--            viewFacet (facetConfig "is-arrangement") facetSearchMsgConfig
--
--        sourceCollectionsToggle =
--            viewFacet (facetConfig "hide-source-collections") facetSearchMsgConfig
--
--        sourceContentsToggle =
--            viewFacet (facetConfig "hide-source-contents") facetSearchMsgConfig
--    in
--    if allAreEmpty then
--        none
--
--    else
--        row
--            [ width fill
--            , alignTop
--            ]
--            [ column
--                [ width fill
--                , alignTop
--                , spacing lineSpacing
--                ]
--                [ sourceContentsToggle
--                , sourceCollectionsToggle
--                , compositeVolumesToggle
--                ]
--            , column
--                [ width fill
--                , alignTop
--                , spacing lineSpacing
--                ]
--                [ hasDigitizationToggle
--                , hasIiifToggle
--                ]
--            , column
--                [ width fill
--                , alignTop
--                , spacing lineSpacing
--                ]
--                [ isArrangementToggle
--                , hasIncipitsToggle
--                ]
--            ]


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


viewFacetsForSourcesMode : ControlsConfig msg -> Element msg
viewFacetsForSourcesMode cfg =
    let
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        qText =
            toNextQuery cfg.activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

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
    row
        [ width fill
        , height fill
        , alignTop
        , padding 10
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ searchKeywordInput
                    { language = cfg.language
                    , submitMsg = cfg.userTriggeredSearchSubmitMsg
                    , changeMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                    , queryText = qText
                    }
                ]
            , row
                [ width fill
                ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetsControlPanel
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

            --, viewFacetsControlSection
            --, viewFacetsControlSection
            --, viewFacetsControlSection
            --, viewFacetsControlSection
            --, viewFacetsControlSection
            --, viewFacetsControlSection
            ]
        ]


viewFacetsControlPanel : String -> LanguageMap -> ControlsConfig msg -> List (Element msg) -> Element msg
viewFacetsControlPanel alias header cfg body =
    let
        -- if all of the body values are empty, skip showing this panel altogether.
        allAreEmpty =
            List.all (\a -> a == none) body
    in
    if allAreEmpty then
        none

    else
        let
            panelIsVisible =
                Set.member alias (.expandedFacetPanels cfg.activeSearch)

            toggleIcon =
                if panelIsVisible then
                    caretCircleDownSvg colourScheme.lightBlue

                else
                    caretCircleRightSvg colourScheme.lightBlue

            panelBody =
                if panelIsVisible then
                    row
                        [ width fill
                        , paddingXY 0 8
                        ]
                        [ column
                            [ width fill
                            , spacing lineSpacing
                            ]
                            body
                        ]

                else
                    none
        in
        row
            [ width fill
            , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            , Border.color (colourScheme.midGrey |> convertColorToElementColor)
            , Border.dotted
            , paddingXY 0 10
            ]
            [ column
                [ width fill
                ]
                [ row
                    [ width fill
                    , Font.color (colourScheme.black |> convertColorToElementColor)
                    , Border.dotted
                    , paddingXY 0 8
                    , spacing 5
                    , Font.medium
                    , headingLG
                    ]
                    [ el
                        [ width (px 16)
                        , height (px 16)
                        , centerY
                        , pointer
                        , onClick (cfg.panelToggleMsg alias)
                        ]
                        toggleIcon
                    , el
                        [ centerY
                        , pointer
                        , onClick (cfg.panelToggleMsg alias)
                        ]
                        (text (extractLabelFromLanguageMap cfg.language header))
                    ]
                , panelBody
                ]
            ]



--viewFacetsForSourcesMode : ControlsConfig msg -> Element msg
--viewFacetsForSourcesMode { language, activeSearch, body, sectionToggleMsg, userTriggeredSearchSubmitMsg, userEnteredTextInKeywordQueryBoxMsg, facetMsgConfig, numberOfSelectColumns } =
--    let
--        facetConfig alias =
--            { alias = alias
--            , language = language
--            , activeSearch = activeSearch
--            , selectColumns = numberOfSelectColumns
--            , body = body
--            }
--
--        qText =
--            toNextQuery activeSearch
--                |> toKeywordQuery
--                |> Maybe.withDefault ""
--    in
--    row
--        [ padding 10
--        , width fill
--        , alignTop
--        , height fill
--        ]
--        [ column
--            [ spacing lineSpacing
--            , width fill
--            , alignTop
--            ]
--            [ row
--                [ width fill
--                , height fill
--                , alignTop
--                ]
--                [ column
--                    [ width fill
--                    , alignTop
--                    ]
--                    [ searchKeywordInput
--                        { language = language
--                        , submitMsg = userTriggeredSearchSubmitMsg
--                        , changeMsg = userEnteredTextInKeywordQueryBoxMsg
--                        , queryText = qText
--                        }
--                    ]
--                ]
--            , row
--                [ width fill ]
--                -- TODO: Translate
--                [ dividerWithText "Additional filters"
--                ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ row
--                    [ width fill
--                    , alignTop
--                    , spacing sectionSpacing
--                    ]
--                    [ column
--                        [ width fill
--                        , alignTop
--                        ]
--                        [ viewFacet (facetConfig "composer") facetMsgConfig ]
--                    , column
--                        [ width fill
--                        , alignTop
--                        ]
--                        [ viewFacet (facetConfig "people") facetMsgConfig ]
--                    ]
--                ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "date-range") facetMsgConfig
--                ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacetToggleSection language activeSearch body facetMsgConfig ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "source-type") facetMsgConfig
--                , viewFacet (facetConfig "content-types") facetMsgConfig
--                , viewFacet (facetConfig "material-group-types") facetMsgConfig
--                ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "text-language") facetMsgConfig
--                , viewFacet (facetConfig "format-extent") facetMsgConfig
--                ]
--
--            --, viewFacet "date-range" language activeSearch body
--            --, viewFacet "num-holdings" language activeSearch body
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "subjects") facetMsgConfig ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "scoring") facetMsgConfig ]
--            , viewFacetSection language
--                sectionToggleMsg
--                [ viewFacet (facetConfig "sigla") facetMsgConfig ]
--
--            --, viewFacet "holding-institution" language activeSearch body
--            ]
--        ]
