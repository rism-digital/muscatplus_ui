module Desktop.Record.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Desktop.Record.Facets exposing (facetRecordMsgConfig)
import Element exposing (Element, alignBottom, alignLeft, alignTop, clipY, column, fill, height, none, px, row, spacing, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.UI.Components exposing (Tab(..), tabView, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultsSection)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
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
        resultsConfig : SearchResultsSectionConfig (RecordPageModel RecordMsg) RecordMsg
        resultsConfig =
            { session = session
            , model = model
            , searchResponse = model.searchResults
            , expandedIncipitInfoSections = model.incipitInfoExpanded
            , userInteractedWithQueryBuilderMsg = RecordMsg.UserInteractedWithQueryBuilder
            , userClickedOpenQueryBuilderMsg = RecordMsg.UserClickedOpenQueryBuilder
            , userClickedCloseQueryBuilderMsg = RecordMsg.UserClickedCloseQueryBuilder
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
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewSearchResultsSection resultsConfig False body

        Error err ->
            createErrorMessage session.language err
                |> Tuple.first
                |> viewSearchResultsErrorTmpl session.language

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> viewSearchResultsErrorTmpl session.language


viewSourceSearchTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , searchUrl : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewSourceSearchTab { language, model, searchUrl, tabLabel } =
    let
        currentMode =
            model.currentTab

        isSelected =
            case currentMode of
                RelatedSourcesSearchTab _ ->
                    True

                _ ->
                    False

        sourceCount =
            case model.searchResults of
                Response (SearchData searchData) ->
                    Just searchData.totalItems

                _ ->
                    Nothing

        thisTab =
            CountTab tabLabel sourceCount
    in
    tabView
        { clickMsg = UserClickedRecordViewTab (RelatedSourcesSearchTab searchUrl)
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = thisTab
        }


viewSourceDescriptionTab :
    { language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    }
    -> Element RecordMsg
viewSourceDescriptionTab { language, model, recordId } =
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


viewRecordSourceSearchTabBar :
    { body : Maybe { a | url : String }
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
                    viewSourceSearchTab
                        { language = language
                        , model = model
                        , recordId = recordId
                        , searchUrl = s.url
                        , tabLabel = tabLabel
                        }
                )
                body

        sourceDescriptionTab =
            viewSourceDescriptionTab
                { language = language
                , model = model
                , recordId = recordId
                }
    in
    row
        [ width fill
        , height (px 30)
        , alignLeft
        , alignBottom
        , spacing 10
        ]
        [ sourceDescriptionTab
        , sourceSearchTab
        ]
