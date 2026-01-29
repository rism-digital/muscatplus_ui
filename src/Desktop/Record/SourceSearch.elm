module Desktop.Record.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Desktop.Record.Facets exposing (facetRecordMsgConfig)
import Element exposing (Element, alignLeft, alignTop, centerY, clipY, column, fill, height, none, px, row, spacing, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Components exposing (Tab(..), tabView, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
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
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingForWindow session.window sidebarWidth session.language

        Response (SearchData body) ->
            viewSearchResultsSection resultsConfig False body

        Error err ->
            errorMessageString session.language err
                |> text

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingForWindow session.window sidebarWidth session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


viewSourceSearchTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , searchUrl : String
    , tabLabel : LanguageMap
    , totalItems : Int
    }
    -> Element RecordMsg
viewSourceSearchTab { language, model, searchUrl, tabLabel, totalItems } =
    let
        isSelected =
            case model.currentTab of
                ContentsSearchDisplayTab _ ->
                    True

                _ ->
                    False

        -- if the tab is already selected, do not emit a message.
        clickMsg =
            if isSelected then
                NothingHappened

            else
                UserClickedRecordViewTab (ContentsSearchDisplayTab searchUrl)

        thisTab =
            CountTab tabLabel (Just totalItems)
    in
    tabView
        { clickMsg = clickMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = thisTab
        }


viewRecordDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewRecordDescriptionTab { language, model, recordId } =
    let
        isSelected =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False

        thisTab =
            BareTab localTranslations.description

        tabSelectMsg =
            if isSelected then
                NothingHappened

            else
                UserClickedRecordViewTab (DefaultRecordViewTab recordId)
    in
    tabView
        { clickMsg = tabSelectMsg
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = thisTab
        }


viewRecordSourceSearchTabBar :
    { body : Maybe { a | totalItems : Int, url : String }
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
                (\s ->
                    let
                        ( searchUrl, itemCount ) =
                            case model.searchResults of
                                Loading (Just (SearchData d)) ->
                                    ( d.id, d.totalItems )

                                Response (SearchData d) ->
                                    ( d.id, d.totalItems )

                                _ ->
                                    ( s.url, s.totalItems )
                    in
                    viewSourceSearchTab
                        { language = language
                        , model = model
                        , recordId = recordId
                        , searchUrl = searchUrl
                        , tabLabel = tabLabel
                        , totalItems = itemCount
                        }
                )
                body

        recordDescriptionTab =
            viewRecordDescriptionTab
                { language = language
                , model = model
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
