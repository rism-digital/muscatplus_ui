module Mobile.Search.Views exposing (view)

import Desktop.Search.Views.Facets exposing (facetSearchMsgConfig)
import Element exposing (Element, alignTop, centerX, column, fill, height, htmlAttribute, inFront, none, px, row, scrollbarY, width)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Error.Views
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.UI.Record.Previews exposing (viewMobilePreviewRouter)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultRouter)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> SearchPageModel SearchMsg -> Element SearchMsg
view session model =
    let
        renderedPreview =
            case .preview model of
                Loading oldData ->
                    viewMobilePreviewRouter
                        { language = session.language
                        , windowSize = session.window
                        , closeMsg = SearchMsg.UserClickedClosePreviewWindow
                        , showAnimationFinishedMsg = SearchMsg.ClientFinishedAnimatingPreviewWindowShow
                        , hideAnimationStartedMsg = SearchMsg.ClientStartedAnimatingPreviewWindowClose
                        , animationStatus = model.previewAnimationStatus
                        , sourceItemExpandMsg = SearchMsg.UserClickedExpandSourceItemsSectionInPreview
                        , sourceItemsExpanded = model.sourceItemsExpanded
                        , incipitInfoSectionsExpanded = model.incipitInfoExpanded
                        , incipitInfoToggleMsg = SearchMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedDigitizedCopiesMsg = SearchMsg.UserClickedExpandDigitalCopiesCallout
                        , expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                        }
                        oldData

                Response resp ->
                    viewMobilePreviewRouter
                        { language = session.language
                        , windowSize = session.window
                        , closeMsg = SearchMsg.UserClickedClosePreviewWindow
                        , showAnimationFinishedMsg = SearchMsg.ClientFinishedAnimatingPreviewWindowShow
                        , hideAnimationStartedMsg = SearchMsg.ClientStartedAnimatingPreviewWindowClose
                        , animationStatus = model.previewAnimationStatus
                        , sourceItemExpandMsg = SearchMsg.UserClickedExpandSourceItemsSectionInPreview
                        , sourceItemsExpanded = model.sourceItemsExpanded
                        , incipitInfoSectionsExpanded = model.incipitInfoExpanded
                        , incipitInfoToggleMsg = SearchMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedDigitizedCopiesMsg = SearchMsg.UserClickedExpandDigitalCopiesCallout
                        , expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                        }
                        (Just resp)

                Error _ ->
                    none

                NoResponseToShow ->
                    none
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
            [ searchPageTopBar
            , searchResultsViewRouter session model
            ]
        ]


searchPageTopBar : Element SearchMsg
searchPageTopBar =
    row
        [ width fill
        , height (px 40)
        ]
        []


searchResultsViewRouter : Session -> SearchPageModel SearchMsg -> Element SearchMsg
searchResultsViewRouter session model =
    let
        resultsConfig : SearchResultsSectionConfig (SearchPageModel SearchMsg) SearchMsg
        resultsConfig =
            { session = session
            , model = model
            , searchResponse = model.response
            , expandedIncipitInfoSections = model.incipitInfoExpanded
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
            }
    in
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewMobileSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewMobileSearchResultsSection resultsConfig False body

        Error _ ->
            Mobile.Error.Views.view session model

        NoResponseToShow ->
            viewSearchResultsLoadingTmpl session.language

        _ ->
            extractLabelFromLanguageMap session.language localTranslations.unknownError
                |> viewSearchResultsErrorTmpl session.language


viewMobileSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewMobileSearchResultsSection cfg _ body =
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
            [ viewMobileSearchResultsList (.language cfg.session) (.selectedResult cfg.model) body cfg.userClickedResultForPreviewMsg
            ]
        ]


viewMobileSearchResultsList :
    Language
    -> Maybe String
    -> SearchBody
    -> (String -> msg)
    -> Element msg
viewMobileSearchResultsList language selectedResult body clickMsg =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.indexedMap
                (\idx result ->
                    viewSearchResultRouter
                        { language = language
                        , selectedResult = selectedResult
                        , searchResult = result
                        , clickForPreviewMsg = clickMsg
                        , resultIdx = idx
                        }
                )
                body.items
            )
        ]
