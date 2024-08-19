module Mobile.Search.Views exposing (view)

import Desktop.Search.Views.Facets exposing (facetSearchMsgConfig)
import Element exposing (Element, alignTop, centerX, centerY, column, fill, height, htmlAttribute, inFront, none, px, row, scrollbarY, text, width)
import Element.Background as Background
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Error.Views
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.UI.Animations exposing (PreviewAnimationStatus(..), animatedRow)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Events exposing (onComplete)
import Page.UI.Record.Previews exposing (viewMobileRecordPreviewTitleBar, viewRecordPreviewTitleBar)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultRouter)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P


view : Session -> SearchPageModel SearchMsg -> Element SearchMsg
view session model =
    let
        windowWidth =
            session.window
                |> Tuple.first
                |> toFloat

        previewAnimation =
            case .previewAnimationStatus model of
                MovingIn ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.x windowWidth ]
                        [ P.x 0 ]

                MovingOut ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.x 0 ]
                        [ P.x windowWidth ]

                NoAnimation ->
                    Animation.empty

        onCompleteMsg =
            case model.previewAnimationStatus of
                MovingIn ->
                    SearchMsg.NothingHappened

                _ ->
                    SearchMsg.UserClickedClosePreviewWindow

        renderedPreview =
            case .preview model of
                Loading oldData ->
                    none

                Response resp ->
                    animatedRow
                        previewAnimation
                        [ width fill
                        , height fill
                        , Background.color colourScheme.white
                        , htmlAttribute (HA.style "z-index" "10")
                        , minimalDropShadow
                        , onComplete onCompleteMsg
                        ]
                        [ column
                            [ width fill
                            , height fill
                            , alignTop
                            , Background.color colourScheme.white
                            , htmlAttribute (HA.style "z-index" "10") -- the incipit piano keyboard sits on top without this.
                            ]
                            [ viewMobileRecordPreviewTitleBar session.language SearchMsg.ClientStartedAnimatingPreviewWindowClose
                            , text "Preview"
                            ]
                        ]

                Error errMsg ->
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
            , inFront renderedPreview
            ]
            [ searchPageTopBar
            , searchResultsViewRouter session model
            ]
        ]


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
            , nothingHappened = SearchMsg.NothingHappened
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
viewMobileSearchResultsSection cfg resultsLoading body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
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
