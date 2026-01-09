module Desktop.Search.Views exposing (view)

import ActiveSearch exposing (toActiveSearch)
import Desktop.Error.Views
import Element exposing (Element, alignTop, centerX, clipY, column, fill, height, none, row, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.Search exposing (ModeFacet)
import Page.Search.Facets exposing (facetSearchMsgConfig, viewModeItems)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.UI.Components exposing (viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.PageTemplate exposing (recordHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Search.SearchTemplate exposing (viewSearchResultsLoadingTmpl)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultsSection)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


searchModeSelectorRouter : Session -> SearchPageModel SearchMsg -> Element SearchMsg
searchModeSelectorRouter session model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            searchModeSelectorView session model oldData.modes

        Response (SearchData data) ->
            searchModeSelectorView session model data.modes

        _ ->
            none


searchModeSelectorView : Session -> SearchPageModel SearchMsg -> Maybe ModeFacet -> Element SearchMsg
searchModeSelectorView session model modeFacet =
    let
        currentMode =
            toActiveSearch model
                |> toNextQuery
                |> toMode
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ viewMaybe (viewModeItems currentMode session) modeFacet
            ]
        ]


searchResultsViewRouter : Session -> SearchPageModel SearchMsg -> Element SearchMsg
searchResultsViewRouter session model =
    let
        resultsConfig : SearchResultsSectionConfig (SearchPageModel SearchMsg) SearchMsg
        resultsConfig =
            { session = session
            , model = model
            , searchResponse = model.response
            , expandedIncipitInfoSections = model.incipitInfoExpanded
            , userInteractedWithQueryBuilderMsg = SearchMsg.UserInteractedWithQueryBuilder
            , userClickedOpenQueryBuilderMsg = SearchMsg.UserClickedOpenQueryBuilder
            , userClickedCloseQueryBuilderMsg = SearchMsg.UserClickedCloseQueryBuilder
            , userInteractedWithDownloaderMsg = SearchMsg.UserInteractedWithDownloader
            , userClickedOpenDownloaderMsg = SearchMsg.UserClickedOpenDownloader
            , userClickedCloseDownloaderMsg = SearchMsg.UserClickedCloseDownloader
            , userClosedPreviewWindowMsg = SearchMsg.UserClickedClosePreviewWindow
            , userClickedSourceItemsExpandMsg = SearchMsg.UserClickedExpandSourceItemsSectionInPreview
            , userClickedResultForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
            , userChangedResultSortingMsg = SearchMsg.UserChangedResultSorting
            , userChangedResultsPerPageMsg = SearchMsg.UserChangedResultsPerPage
            , userClickedResultsPaginationMsg = SearchMsg.UserClickedSearchResultsPagination
            , userTriggeredSearchSubmitMsg = SearchMsg.UserTriggeredSearchSubmit
            , userEnteredTextInKeywordQueryBoxMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
            , userResetAllFiltersMsg = SearchMsg.UserResetAllFilters
            , userRemovedActiveFilterMsg = SearchMsg.UserRemovedActiveFilter
            , userToggledIncipitInfo = SearchMsg.UserClickedExpandIncipitInfoSectionInPreview
            , panelToggleMsg = SearchMsg.UserClickedFacetPanelToggle
            , facetMsgConfig = facetSearchMsgConfig
            , expandedDigitizedCopiesMsg = SearchMsg.UserClickedExpandDigitalCopiesCallout
            , expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
            , clientStartedAnimatingPreviewWindowClose = SearchMsg.ClientStartedAnimatingPreviewWindowClose
            , clientFinishedAnimatingPreviewWindowShow = SearchMsg.ClientFinishedAnimatingPreviewWindowShow
            , summaryFormatter = viewSummaryField
            , preRenderedFormatter = viewPreRenderedSummaryField
            , relationshipFormatter = viewRelationshipBody
            , paragraphFormatter = viewParagraphField
            }
    in
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewSearchResultsSection resultsConfig False body

        Error _ ->
            Desktop.Error.Views.view session model

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            -- For any other responses, show the error.
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


view : Session -> SearchPageModel SearchMsg -> Element SearchMsg
view session model =
    row
        [ width fill
        , height fill
        , alignTop
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ viewTopBar session model
            , viewSearchBody session model
            ]
        ]


viewSearchBody : Session -> SearchPageModel SearchMsg -> Element SearchMsg
viewSearchBody session model =
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


viewTopBar : Session -> SearchPageModel SearchMsg -> Element SearchMsg
viewTopBar session model =
    recordHeaderTemplate False
        [ searchModeSelectorRouter session model
        ]
