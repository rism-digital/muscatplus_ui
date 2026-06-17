module Desktop.Record.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Desktop.Record.Facets exposing (facetRecordMsgConfig)
import Element exposing (Element, alignLeft, alignTop, centerY, clipY, column, fill, height, px, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Components exposing (viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordDescriptionTab, viewRecordSearchResults, viewRecordSearchTab)
import Page.UI.Search.SearchTemplate exposing (viewSearchResultsLoadingForWindow)
import Page.UI.Search.SearchView exposing (buildSearchResultsConfig, viewSearchResultsSection)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewSourceSearchTabBody :
    Session
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
viewSourceSearchTabBody session model =
    row
        [ width fill
        , height fill
        , alignTop
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ searchResultsViewRouter session model ]
        ]


searchResultsViewRouter :
    Session
    -> RecordPageModel RecordMsg
    -> Element RecordMsg
searchResultsViewRouter session model =
    let
        resultsConfig =
            buildSearchResultsConfig
                { expandedIncipitInfoSections = model.incipitInfoExpanded
                , model = model
                , searchResponse = model.searchResults
                , session = session
                }
                { userInteractedWithQueryBuilderMsg = RecordMsg.UserInteractedWithQueryBuilder
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
        , loadingView = viewSearchResultsLoadingForWindow session.window sidebarWidth session.language
        , loadedView =
            \body ->
                case model.searchResults of
                    Loading (Just (SearchData _)) ->
                        viewSearchResultsSection resultsConfig True body

                    _ ->
                        viewSearchResultsSection resultsConfig False body
        , response = model.searchResults
        }


viewRecordSourceSearchTabBar :
    { body : Maybe { a | url : String, totalItems : Int }
    , language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { body, language, model, recordId, tabLabel } =
    let
        sourceSearchTab =
            viewMaybe
                (\searchInfo ->
                    viewRecordSearchTab
                        { language = language
                        , currentTab = model.currentTab
                        , searchUrl = searchInfo.searchUrl
                        , tabLabel = tabLabel
                        , totalItems = searchInfo.totalItems
                        }
                )
                (resolveSearchTabInfo model.searchResults body)

        recordDescriptionTab =
            viewRecordDescriptionTab
                { language = language
                , currentTab = model.currentTab
                , recordId = recordId
                }
    in
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , centerY
        , spacing 10
        ]
        [ recordDescriptionTab
        , sourceSearchTab
        ]
