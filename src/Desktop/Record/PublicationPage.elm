module Desktop.Record.PublicationPage exposing (viewFullPublicationPage)

import Desktop.Record.Facets exposing (facetRecordMsgConfig)
import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, indexedTable, link, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.RecordTypes.Publication exposing (PublicationBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), WorkResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, minimalDropShadow, sectionSpacing, tableHeaderStyles)
import Page.UI.Components exposing (Tab(..), pageBodyOrEmpty, tabView, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Errors exposing (createErrorMessage, errorMessageString)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (folderMusicSvg, peopleSvg)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig)
import Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewFullPublicationPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewFullPublicationPage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab session.language body

                ContentsSearchDisplayTab _ ->
                    viewRelatedWorksListTabBody session model

        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

            else
                px (tabBarHeight + recordTitleHeight)

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
                viewRecordTopBar session.language model body
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , minimalDropShadow
                    ]
                    [ pageHeader
                    , tabBar
                    ]
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewDescriptionTab : Language -> PublicationBody -> Element msg
viewDescriptionTab language body =
    viewPublicationBody
        { language = language
        , paragraphFormatter = viewParagraphField
        , preRenderedFormatter = viewPreRenderedSummaryField
        , relationshipFormatter = viewRelationshipBody
        , summaryFormatter = viewSummaryField
        }
        body


viewPublicationBody :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> PublicationBody
    -> Element msg
viewPublicationBody { language, paragraphFormatter, preRenderedFormatter, relationshipFormatter, summaryFormatter } publicationBody =
    let
        pageBody =
            pageBodyOrEmpty language
                False
                [ viewMaybe
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


viewCreatorImpl :
    (Language -> LanguageMap -> List RelationshipBody -> Element msg)
    -> Language
    -> RelationshipBody
    -> Element msg
viewCreatorImpl formatter language creator =
    gatherRelationshipItems [ creator ]
        |> List.map (\( label, items ) -> formatter language label items)
        |> List.head
        |> Maybe.withDefault none


viewCreator :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> RelationshipBody
    -> Element msg
viewCreator { language, relationshipFormatter } creator =
    viewCreatorImpl relationshipFormatter language creator


viewRecordTopBar :
    Language
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewRecordTopBar language model body =
    let
        worksDisplayTab =
            viewMaybe
                (\s ->
                    viewWorksDisplayTab
                        { language = language
                        , model = model
                        , searchUrl = s.url
                        , tabLabel = localTranslations.works
                        , worksCount = s.totalItems
                        }
                )
                body.works

        publicationDescriptionTab =
            viewPublicationDescriptionTab
                { language = language
                , model = model
                , recordId = body.id
                }
    in
    row
        [ width fill
        , height (px 30)
        , alignLeft
        , alignBottom
        , spacing 10
        ]
        [ publicationDescriptionTab
        , worksDisplayTab
        ]


viewWorksDisplayTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , searchUrl : String
    , tabLabel : LanguageMap
    , worksCount : Int
    }
    -> Element RecordMsg
viewWorksDisplayTab { language, model, searchUrl, tabLabel, worksCount } =
    let
        isSelected =
            case model.currentTab of
                ContentsSearchDisplayTab _ ->
                    True

                _ ->
                    False

        thisTab =
            CountTab tabLabel (Just worksCount)
    in
    tabView
        { clickMsg = UserClickedRecordViewTab (ContentsSearchDisplayTab searchUrl)
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = thisTab
        }


viewPublicationDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewPublicationDescriptionTab { language, model, recordId } =
    let
        isSelected =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False

        thisTab =
            BareTab localTranslations.description
    in
    tabView
        { clickMsg = UserClickedRecordViewTab (DefaultRecordViewTab recordId)
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = thisTab
        }


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
            ]
            [ viewRelatedWorksSectionRouter session model ]
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
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewWorksResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewWorksResultsSection resultsConfig False body

        Error err ->
            errorMessageString session.language err
                |> text

        NoResponseToShow ->
            viewSearchResultsLoadingTmpl session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


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
            , padding 20
            ]
            [ row
                [ width fill
                , inFront (viewResultsListLoadingScreenTmpl isLoading)
                ]
                [ indexedTable
                    [ Border.width 1, Border.color colourScheme.midGrey ]
                    { columns =
                        [ { header = el tableHeaderStyles (text "Catalog number")
                          , width = fillPortion 1
                          , view = \i w -> viewCatalogNumberCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Title")
                          , width = fillPortion 2
                          , view = \i w -> viewWorkTitleCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Key")
                          , width = fillPortion 1
                          , view = \i w -> viewKeyModeCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Scoring")
                          , width = fillPortion 1
                          , view = \i w -> viewScoringSummaryCell language i w
                          }
                        , { header = el tableHeaderStyles (text "Sources")
                          , width = fillPortion 1
                          , view = \i w -> viewNumberOfSourcesCell language i w
                          }
                        ]
                    , data = results
                    }
                ]
            , row
                [ width fill ]
                [ viewPagination language body.pagination cfg.userClickedResultsPaginationMsg ]
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
                    text ident

                Nothing ->
                    none
    in
    el [ cellBg, padding 10 ] catalogNum


viewWorkTitleCell : Language -> Int -> WorkResultBody -> Element msg
viewWorkTitleCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    link
        [ cellBg, linkColour, padding 10 ]
        { label =
            extractLabelFromLanguageMap language result.label
                |> text
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
        [ cellBg, padding 10, width fill, height fill ]
        (text keyModeFlagValue)


viewScoringSummaryCell : Language -> Int -> WorkResultBody -> Element msg
viewScoringSummaryCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        scoringSummaryFlagValue =
            Maybe.withDefault "" (.scoringSummary result.flags)
    in
    el
        [ cellBg, padding 10, width fill, height fill ]
        (text scoringSummaryFlagValue)


viewNumberOfSourcesCell : Language -> Int -> WorkResultBody -> Element msg
viewNumberOfSourcesCell language rowNum result =
    let
        cellBg =
            cycleTableBackground rowNum

        numSourcesFlagValue =
            case .numberOfSources result.flags of
                Just v ->
                    String.fromInt v

                Nothing ->
                    ""

        viewSourcesLink =
            case .numberOfSources result.flags of
                Just v ->
                    if v > 0 then
                        let
                            workId =
                                String.split "/" result.id
                                    |> LE.last
                                    |> Maybe.withDefault ""
                                    |> String.append "work_"
                        in
                        link
                            [ linkColour
                            , alignLeft
                            ]
                            { label = text "View Linked Sources", url = "/search?fq=works:" ++ workId }

                    else
                        none

                Nothing ->
                    none
    in
    row
        [ width fill
        , height fill
        , cellBg
        , padding 10
        , spacing 10
        , alignLeft
        ]
        [ el
            []
            (text numSourcesFlagValue)
        , viewSourcesLink
        ]
