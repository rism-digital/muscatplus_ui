module Mobile.Search.Views exposing (view)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, centerX, clipY, column, fill, height, htmlAttribute, inFront, row, scrollbarY, text, width)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Error.Views
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Facets exposing (facetSearchMsgConfig)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Page.UI.Components exposing (viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Record.Previews exposing (viewMobilePreviewForResponse)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.SearchTemplate exposing (viewSearchResultsLoadingForWindow)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, buildSearchResultsConfig, viewSearchResultRouter)
import Page.UI.Search.SortAndRows exposing (viewSearchPageSort)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Url


view : Session -> SearchPageModel SearchMsg -> Element SearchMsg
view session model =
    let
        renderedPreview =
            viewMobilePreviewForResponse
                { language = session.language
                , currentUrl = Url.toString session.url
                , windowSize = session.window
                , closeMsg = SearchMsg.UserClickedClosePreviewWindow
                , hideAnimationStartedMsg = SearchMsg.ClientStartedAnimatingPreviewWindowClose
                , showAnimationFinishedMsg = SearchMsg.ClientFinishedAnimatingPreviewWindowShow
                , animationStatus = model.previewAnimationStatus
                , sourceItemExpandMsg = SearchMsg.UserClickedExpandSourceItemsSectionInPreview
                , sourceItemsExpanded = model.sourceItemsExpanded
                , incipitInfoSectionsExpanded = model.incipitInfoExpanded
                , incipitInfoToggleMsg = SearchMsg.UserClickedExpandIncipitInfoSectionInPreview
                , expandedDigitizedCopiesMsg = SearchMsg.UserClickedExpandDigitalCopiesCallout
                , expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                , summaryFormatter = viewMobileSummaryField
                , preRenderedFormatter = viewPreRenderedMobileSummaryField
                , relationshipFormatter = viewMobileRelationshipBody
                , paragraphFormatter = viewMobileParagraphField
                }
                (.preview model)
    in
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

            -- placing the preview at this level means that it is always in view.
            -- otherwise, it gets rendered at the top of a scrolling list, which
            -- can result in it being invisible.
            , inFront renderedPreview
            ]
            [ searchResultsViewRouter session model
            ]
        ]


searchResultsViewRouter : Session -> SearchPageModel SearchMsg -> Element SearchMsg
searchResultsViewRouter session model =
    let
        resultsConfig =
            buildSearchResultsConfig
                { expandedIncipitInfoSections = model.incipitInfoExpanded
                , model = model
                , searchResponse = model.response
                , session = session
                }
                { userInteractedWithQueryBuilderMsg = SearchMsg.UserInteractedWithQueryBuilder
                , userClickedOpenQueryBuilderMsg = SearchMsg.NothingHappened
                , userClickedCloseQueryBuilderMsg = SearchMsg.NothingHappened
                , userInteractedWithDownloaderMsg = \_ -> SearchMsg.NothingHappened
                , userClickedOpenDownloaderMsg = SearchMsg.NothingHappened
                , userClickedCloseDownloaderMsg = SearchMsg.NothingHappened
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
                , summaryFormatter = viewMobileSummaryField
                , preRenderedFormatter = viewPreRenderedMobileSummaryField
                , relationshipFormatter = viewMobileRelationshipBody
                , paragraphFormatter = viewMobileParagraphField
                }
    in
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewMobileSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingForWindow session.window 0 session.language

        Response (SearchData body) ->
            viewMobileSearchResultsSection resultsConfig False body

        Error _ ->
            Mobile.Error.Views.view session model

        NoResponseToShow ->
            viewSearchResultsLoadingForWindow session.window 0 session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> text


viewMobileSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewMobileSearchResultsSection cfg _ body =
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
            [ viewMobileSearchResultsList
                { body = body
                , clickMsg = cfg.userClickedResultForPreviewMsg
                , language = .language cfg.session
                , model = cfg.model
                , searchResponse = cfg.searchResponse
                , selectedResult = .selectedResult cfg.model
                , userChangedResultSortingMsg = cfg.userChangedResultSortingMsg
                , userChangedResultsPerPageMsg = cfg.userChangedResultsPerPageMsg
                , userClickedResultsPaginationMsg = cfg.userClickedResultsPaginationMsg
                }
            ]
        ]


viewMobileSearchResultsList :
    { body : SearchBody
    , clickMsg : String -> msg
    , language : Language
    , model :
        { a
            | response : Response ServerData
            , activeSearch : ActiveSearch msg
            , preview : Response ServerData
            , sourceItemsExpanded : Bool
            , selectedResult : Maybe String
            , probeResponse : ProbeStatus
            , applyFilterPrompt : Bool
            , previewAnimationStatus : PreviewAnimationStatus
        }
    , searchResponse : Response ServerData
    , selectedResult : Maybe String
    , userChangedResultSortingMsg : String -> msg
    , userChangedResultsPerPageMsg : String -> msg
    , userClickedResultsPaginationMsg : String -> msg
    }
    -> Element msg
viewMobileSearchResultsList cfg =
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
            [ viewSearchPageSort
                { language = cfg.language
                , activeSearch = .activeSearch cfg.model
                , body = cfg.body
                , changedResultSortingMsg = cfg.userChangedResultSortingMsg
                , changedResultRowsPerPageMsg = cfg.userChangedResultsPerPageMsg
                , isMobile = True
                }
                cfg.searchResponse
            , row
                [ alignTop
                , width fill
                , height fill
                , clipY
                ]
                [ column
                    [ alignTop
                    , width fill
                    , height fill
                    , scrollbarY
                    , htmlAttribute (HA.style "min-height" "unset")
                    , htmlAttribute (HA.id "search-results-list")
                    ]
                    (List.indexedMap
                        (\idx result ->
                            viewSearchResultRouter
                                { language = cfg.language
                                , selectedResult = cfg.selectedResult
                                , searchResult = result
                                , clickForPreviewMsg = cfg.clickMsg
                                , resultIdx = idx
                                }
                        )
                        (.items cfg.body)
                    )
                ]
            , viewPagination cfg.language (.pagination cfg.body) cfg.userClickedResultsPaginationMsg
            ]
        ]
