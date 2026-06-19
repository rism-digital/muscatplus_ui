module Desktop.Record.PublicationPage exposing (viewFullPublicationPage)

import Desktop.Record.Facets exposing (facetRecordMsgConfig)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, indexedTable, link, none, padding, paragraph, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Incipit exposing (IncipitFormat(..), RenderedIncipit(..))
import Page.RecordTypes.Publication exposing (PublicationBody, WorkCatalogueStatus)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), WorkResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, sectionSpacing, tableHeaderStyles)
import Page.UI.Components exposing (formatPublicationStatusBadge, pageBodyOrEmpty, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe, viewSVGRenderedIncipit)
import Page.UI.Images exposing (folderMusicSvg)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.PublicationWorksSearch exposing (Layout(..), viewPublicationWorksSearchControls)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordSearchResults)
import Page.UI.Record.TabShell exposing (TabSpec, descriptionTab, searchTab, selectBody, viewDesktopTabBar)
import Page.UI.Search.Pagination exposing (viewTablePagination)
import Page.UI.Search.SearchTemplate exposing (viewRelatedWorksSearchResultsLoadingTmpl, viewResultsListLoadingScreenTmpl)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig)
import Page.UI.Style exposing (colourScheme, tableCellPadding)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewFullPublicationPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewFullPublicationPage session model body =
    let
        descriptionBody =
            viewDescriptionTab
                { language = session.language }
                body

        tabs =
            viewRecordTabs session model body descriptionBody

        selectedBody =
            selectBody
                { bodyView = descriptionBody
                , showBottomShadow = True
                }
                tabs

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (folderMusicSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body

        tabBar =
            if session.isFramed then
                none

            else
                viewDesktopTabBar tabs
    in
    row
        [ width fill
        , height fill
        , Region.mainContent
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ recordHeaderTemplate selectedBody.showBottomShadow
                [ pageHeader
                , tabBar
                ]
            , selectedBody.bodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewRecordTabs :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
    -> List (TabSpec RecordMsg)
viewRecordTabs session model body descriptionBody =
    descriptionTab
        { bodyView = descriptionBody
        , currentTab = model.currentTab
        , language = session.language
        , recordId = body.id
        , showBottomShadow = True
        }
        :: (resolveSearchTabInfo model.searchResults body.works
                |> Maybe.map
                    (\searchInfo ->
                        searchTab
                            { bodyView = viewRelatedWorksListTabBody session model
                            , currentTab = model.currentTab
                            , language = session.language
                            , searchUrl = searchInfo.searchUrl
                            , showBottomShadow = False
                            , tabLabel = localTranslations.works
                            , totalItems = searchInfo.totalItems
                            }
                    )
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )


viewDescriptionTab : { language : Language } -> PublicationBody -> Element msg
viewDescriptionTab { language } body =
    viewPublicationBody
        { language = language
        , paragraphFormatter = viewParagraphField
        , preRenderedFormatter = viewPreRenderedSummaryField
        , recordId = body.id
        , relationshipFormatter = viewRelationshipBody
        , summaryFormatter = viewSummaryField
        }
        body


viewPublicationBody :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , recordId : String
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> PublicationBody
    -> Element msg
viewPublicationBody { language, paragraphFormatter, preRenderedFormatter, recordId, relationshipFormatter, summaryFormatter } publicationBody =
    let
        pageBody =
            pageBodyOrEmpty language
                False
                [ viewWorkCatalogueStatus
                    { language = language
                    , preRenderedFormatter = preRenderedFormatter
                    }
                    publicationBody.status
                , viewMaybe
                    (viewCreator
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    publicationBody.creator
                , Maybe.withDefault [] publicationBody.summary
                    |> summaryFormatter language
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    publicationBody.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = language
                        , paragraphFormatter = viewParagraphField
                        }
                    )
                    publicationBody.notes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = language
                        , recordId = recordId
                        }
                    )
                    publicationBody.externalResources

                -- WIP
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            pageBody
        ]


viewWorkCatalogueStatus :
    { language : Language
    , preRenderedFormatter :
        Language
        ->
            List
                { label : LanguageMap
                , value : List (Element msg)
                }
        -> Element msg
    }
    -> WorkCatalogueStatus
    -> Element msg
viewWorkCatalogueStatus { language, preRenderedFormatter } status =
    preRenderedFormatter language
        [ { label = toLanguageMap "Status"
          , value = [ el [ alignTop ] (formatPublicationStatusBadge language status) ]
          }
        ]


viewCreatorImpl :
    (Language -> LanguageMap -> List RelationshipBody -> Element msg)
    -> Language
    -> RelationshipBody
    -> Element msg
viewCreatorImpl formatter language creator =
    gatherRelationshipItems [ creator ]
        |> List.head
        |> Maybe.map (\( label, items ) -> formatter language label items)
        |> Maybe.withDefault none


viewCreator :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> RelationshipBody
    -> Element msg
viewCreator { language, relationshipFormatter } creator =
    viewCreatorImpl relationshipFormatter language creator


viewRelatedWorksListTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewRelatedWorksListTabBody session model =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , htmlAttribute (HA.id "search-results-list")
            , padding 20
            , spacing 20
            ]
            [ viewPublicationWorksSearchControls
                { activeSearch = model.activeSearch
                , clearMsg = RecordMsg.UserClickedClearKeywordSearch
                , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
                , disabledSubmitMsg = RecordMsg.NothingHappened
                , enabledSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
                , language = session.language
                , layout = Inline
                , probeResponse = model.probeResponse
                , userClickedOpenQueryBuilderMsg = RecordMsg.UserClickedOpenQueryBuilder
                }
            , viewRelatedWorksSectionRouter session model
            ]
        ]


viewRelatedWorksSectionRouter : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewRelatedWorksSectionRouter session model =
    let
        resultsConfig : SearchResultsSectionConfig (RecordPageModel RecordMsg) RecordMsg
        resultsConfig =
            { session = session
            , model = model
            , searchResponse = model.searchResults
            , expandedIncipitInfoSections = model.incipitInfoExpanded
            , userInteractedWithQueryBuilderMsg = RecordMsg.UserInteractedWithQueryBuilder
            , userClickedOpenQueryBuilderMsg = RecordMsg.UserClickedOpenQueryBuilder
            , userClickedCloseQueryBuilderMsg = RecordMsg.UserClickedCloseQueryBuilder
            , userInteractedWithDownloaderMsg = RecordMsg.UserInteractedWithDownloader
            , userClickedOpenDownloaderMsg = RecordMsg.UserClickedOpenDownloader
            , userClickedCloseDownloaderMsg = RecordMsg.UserClickedCloseDownloader
            , userClosedPreviewWindowMsg = RecordMsg.UserClickedClosePreviewWindow
            , userClickedSourceItemsExpandMsg = RecordMsg.UserClickedExpandSourceItemsSectionInPreview
            , userClickedResultForPreviewMsg = RecordMsg.UserClickedSearchResultForPreview
            , userChangedResultSortingMsg = RecordMsg.UserChangedResultSorting
            , userChangedResultsPerPageMsg = RecordMsg.UserChangedResultsPerPage
            , userClickedResultsPaginationMsg = RecordMsg.UserClickedSearchResultsPagination
            , userTriggeredSearchSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
            , userEnteredTextInKeywordQueryBoxMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            , userResetAllFiltersMsg = RecordMsg.UserResetAllFilters
            , userRemovedActiveFilterMsg = RecordMsg.UserRemovedActiveFilter
            , userToggledIncipitInfo = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
            , panelToggleMsg = RecordMsg.UserClickedFacetPanelToggle
            , facetMsgConfig = facetRecordMsgConfig
            , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
            , expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
            , clientStartedAnimatingPreviewWindowClose = RecordMsg.ClientStartedAnimatingPreviewWindowClose
            , clientFinishedAnimatingPreviewWindowShow = RecordMsg.ClientFinishedAnimatingPreviewWindowShow
            , summaryFormatter = viewSummaryField
            , preRenderedFormatter = viewPreRenderedSummaryField
            , relationshipFormatter = viewRelationshipBody
            , paragraphFormatter = viewParagraphField
            }
    in
    viewRecordSearchResults
        { language = session.language
        , loadingView = viewRelatedWorksSearchResultsLoadingTmpl session.language
        , loadedView =
            \body ->
                case model.searchResults of
                    Loading (Just (SearchData _)) ->
                        viewWorksResultsSection resultsConfig True body

                    _ ->
                        viewWorksResultsSection resultsConfig False body
        , response = model.searchResults
        }


viewWorksResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewWorksResultsSection cfg isLoading body =
    let
        language =
            .language cfg.session

        results =
            List.filterMap
                (\r ->
                    case r of
                        WorkResult wb ->
                            Just wb

                        _ ->
                            Nothing
                )
                body.items
    in
    row
        [ width fill
        , height fill
        , Background.color colourScheme.white
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ viewTablePagination language body.pagination cfg.userClickedResultsPaginationMsg ]
            , row
                [ width fill
                , inFront (viewResultsListLoadingScreenTmpl isLoading)
                ]
                [ indexedTable
                    [ Border.width 1, Border.color colourScheme.midGrey ]
                    { columns =
                        [ { header = column (tableHeaderStyles ++ [ spacing 6 ]) [ el [] (text "Catalog number"), el [ Font.italic, Font.regular ] (text "Alternative numbers") ]
                          , width = fillPortion 1
                          , view = \i w -> viewCatalogNumberCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Title")
                          , width = fillPortion 3
                          , view = \i w -> viewWorkTitleCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Incipit")
                          , width = fillPortion 3
                          , view = \i w -> viewIncipitCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Key")
                          , width = fillPortion 1
                          , view = \i w -> viewKeyModeCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Scoring")
                          , width = fillPortion 1
                          , view = \i w -> viewScoringSummaryCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Appears in")
                          , width = fillPortion 2
                          , view = \i w -> viewNumberOfSourcesCell language i w
                          }
                        ]
                    , data = results
                    }
                ]
            , row
                [ width fill ]
                [ viewTablePagination language body.pagination cfg.userClickedResultsPaginationMsg ]
            ]
        ]


viewCatalogNumberCell : Language -> Int -> WorkResultBody -> Element msg
viewCatalogNumberCell language rowNum body =
    let
        cellBg =
            cycleTableBackground rowNum

        catalogNum =
            case .catalogueIdentifier body.flags of
                Just ident ->
                    paragraph [ centerY, Font.bold ] [ text ident ]

                Nothing ->
                    none

        alternateNums =
            case .secondaryCatalogueIdentifiers body.flags of
                Just idents ->
                    paragraph
                        [ centerY
                        , Font.italic
                        , Font.regular
                        ]
                        [ text (String.join "; " idents) ]

                Nothing ->
                    none
    in
    column
        [ cellBg
        , padding tableCellPadding
        , width shrink
        , height fill
        , spacing 6
        ]
        [ catalogNum
        , alternateNums
        ]


viewWorkTitleCell : Language -> Int -> WorkResultBody -> Element msg
viewWorkTitleCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    link
        [ cellBg, linkColour, padding tableCellPadding, width shrink, height fill ]
        { label =
            paragraph [ centerY ]
                [ extractLabelFromLanguageMap language result.label
                    |> text
                ]
        , url = result.id
        }


viewKeyModeCell : Language -> Int -> WorkResultBody -> Element msg
viewKeyModeCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        keyModeFlagValue =
            case .keyMode result.flags of
                Just v ->
                    extractLabelFromLanguageMap language v

                Nothing ->
                    ""
    in
    el
        [ cellBg, padding tableCellPadding, width shrink, height fill ]
        (paragraph [ centerY ] [ text keyModeFlagValue ])


viewScoringSummaryCell : Language -> Int -> WorkResultBody -> Element msg
viewScoringSummaryCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        scoringSummaryFlagValue =
            Maybe.withDefault "" (.scoringSummary result.flags)
    in
    el
        [ cellBg, padding tableCellPadding, width shrink, height fill ]
        (paragraph [ centerY ] [ text scoringSummaryFlagValue ])


viewNumberOfSourcesCell : Language -> Int -> WorkResultBody -> Element msg
viewNumberOfSourcesCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        viewSourcesLink =
            case result.sources of
                Just v ->
                    link
                        [ linkColour
                        , centerY
                        , alignLeft
                        ]
                        { label = text (extractLabelFromLanguageMap language v.label), url = v.url }

                Nothing ->
                    let
                        numSourcesFlagValue =
                            Maybe.map String.fromInt (.numberOfSources result.flags)
                                |> Maybe.andThen
                                    (\t ->
                                        if t == "0" then
                                            Nothing

                                        else
                                            Just t
                                    )
                                |> Maybe.withDefault "-"
                    in
                    text numSourcesFlagValue
    in
    row
        [ width fill
        , height fill
        , cellBg
        , padding tableCellPadding
        , alignLeft
        , spacing 10
        ]
        [ paragraph
            [ centerY
            ]
            [ viewSourcesLink
            ]
        ]


viewIncipitCell : Language -> Int -> WorkResultBody -> Element msg
viewIncipitCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        renderedIncipit =
            Maybe.map
                (\ri ->
                    case ri of
                        RenderedIncipit RenderedSVG svgdata ->
                            viewSVGRenderedIncipit svgdata

                        _ ->
                            el [ centerY ] (text "-")
                )
                result.renderedIncipits
                |> Maybe.withDefault (el [ centerY ] (text "-"))
    in
    el
        [ cellBg
        , padding tableCellPadding
        , width fill
        , height fill
        ]
        renderedIncipit
