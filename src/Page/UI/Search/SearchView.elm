module Page.UI.Search.SearchView exposing (SearchResultRouterConfig, SearchResultsHandlers, SearchResultsListPanelConfig, SearchResultsSectionConfig, buildSearchResultsConfig, viewSearchResultRouter, viewSearchResultsSection)

import ActiveSearch exposing (toResultsNotInCurrentMode)
import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, htmlAttribute, inFront, none, padding, paddingXY, pointer, px, row, scrollbarY, shrink, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Maybe.Extra as ME
import Page.Downloader
import Page.Downloader.Msg exposing (DownloaderMsg)
import Page.Query exposing (toKeywordQuery)
import Page.QueryBuilder
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg)
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.RecordTypes.SearchControl exposing (SearchControlOptions(..))
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Page.UI.Attributes exposing (blurredBackground, bodyRegular, lineSpacing, minimalDropShadow, sidebarWidth)
import Page.UI.Components exposing (h3)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (viewKeywordQueryInput)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Layout as Layout
import Page.UI.Record.Previews exposing (viewPreviewError, viewPreviewRouter)
import Page.UI.Search.Controls.ControlsConfig exposing (ActiveFiltersCfg, SearchControlsConfig)
import Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)
import Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)
import Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)
import Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)
import Page.UI.Search.ControlsPanel exposing (viewSearchControlsPanel)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)
import Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)
import Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)
import Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)
import Page.UI.Search.SearchComponents exposing (queryValidationState)
import Page.UI.Search.SearchTemplate exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsNotFoundTmpl)
import Page.UI.Search.SortAndRows exposing (viewSearchPageSort)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Set exposing (Set)
import Url


type alias SearchResultsSectionConfig a msg =
    { session : Session
    , model :
        { a
            | preview : Response ServerData
            , previewAnimationStatus : PreviewAnimationStatus
            , sourceItemsExpanded : Bool
            , activeSearch : ActiveSearch msg
            , selectedResult : Maybe String
            , probeResponse : ProbeStatus
            , applyFilterPrompt : Bool
            , response : Response ServerData
            , showSearchControls : SearchControlOptions
        }
    , searchResponse : Response ServerData
    , expandedIncipitInfoSections : Set String
    , userInteractedWithQueryBuilderMsg : QueryBuilderMsg -> msg
    , userClickedOpenQueryBuilderMsg : msg
    , userClickedCloseQueryBuilderMsg : msg
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    , userClickedOpenDownloaderMsg : msg
    , userClickedCloseDownloaderMsg : msg
    , userClosedPreviewWindowMsg : msg
    , userClickedSourceItemsExpandMsg : msg
    , userClickedResultForPreviewMsg : String -> msg
    , userChangedResultSortingMsg : String -> msg
    , userChangedResultsPerPageMsg : String -> msg
    , userClickedResultsPaginationMsg : String -> msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    , userResetAllFiltersMsg : msg
    , userRemovedActiveFilterMsg : String -> String -> msg
    , userToggledIncipitInfo : String -> msg
    , panelToggleMsg : String -> Set String -> msg
    , facetMsgConfig : FacetMsgConfig msg
    , expandedDigitizedCopiesMsg : msg
    , expandedDigitizedCopiesCallout : Bool
    , clientStartedAnimatingPreviewWindowClose : msg
    , clientFinishedAnimatingPreviewWindowShow : msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }


type alias SearchResultsHandlers msg =
    { userInteractedWithQueryBuilderMsg : QueryBuilderMsg -> msg
    , userClickedOpenQueryBuilderMsg : msg
    , userClickedCloseQueryBuilderMsg : msg
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    , userClickedOpenDownloaderMsg : msg
    , userClickedCloseDownloaderMsg : msg
    , userClosedPreviewWindowMsg : msg
    , userClickedSourceItemsExpandMsg : msg
    , userClickedResultForPreviewMsg : String -> msg
    , userChangedResultSortingMsg : String -> msg
    , userChangedResultsPerPageMsg : String -> msg
    , userClickedResultsPaginationMsg : String -> msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    , userResetAllFiltersMsg : msg
    , userRemovedActiveFilterMsg : String -> String -> msg
    , userToggledIncipitInfo : String -> msg
    , panelToggleMsg : String -> Set String -> msg
    , facetMsgConfig : FacetMsgConfig msg
    , expandedDigitizedCopiesMsg : msg
    , expandedDigitizedCopiesCallout : Bool
    , clientStartedAnimatingPreviewWindowClose : msg
    , clientFinishedAnimatingPreviewWindowShow : msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }


buildSearchResultsConfig :
    { expandedIncipitInfoSections : Set String
    , model :
        { a
            | activeSearch : ActiveSearch msg
            , applyFilterPrompt : Bool
            , preview : Response ServerData
            , previewAnimationStatus : PreviewAnimationStatus
            , probeResponse : ProbeStatus
            , response : Response ServerData
            , selectedResult : Maybe String
            , showSearchControls : SearchControlOptions
            , sourceItemsExpanded : Bool
        }
    , searchResponse : Response ServerData
    , session : Session
    }
    -> SearchResultsHandlers msg
    -> SearchResultsSectionConfig a msg
buildSearchResultsConfig base handlers =
    { session = base.session
    , model = base.model
    , searchResponse = base.searchResponse
    , expandedIncipitInfoSections = base.expandedIncipitInfoSections
    , userInteractedWithQueryBuilderMsg = handlers.userInteractedWithQueryBuilderMsg
    , userClickedOpenQueryBuilderMsg = handlers.userClickedOpenQueryBuilderMsg
    , userClickedCloseQueryBuilderMsg = handlers.userClickedCloseQueryBuilderMsg
    , userInteractedWithDownloaderMsg = handlers.userInteractedWithDownloaderMsg
    , userClickedOpenDownloaderMsg = handlers.userClickedOpenDownloaderMsg
    , userClickedCloseDownloaderMsg = handlers.userClickedCloseDownloaderMsg
    , userClosedPreviewWindowMsg = handlers.userClosedPreviewWindowMsg
    , userClickedSourceItemsExpandMsg = handlers.userClickedSourceItemsExpandMsg
    , userClickedResultForPreviewMsg = handlers.userClickedResultForPreviewMsg
    , userChangedResultSortingMsg = handlers.userChangedResultSortingMsg
    , userChangedResultsPerPageMsg = handlers.userChangedResultsPerPageMsg
    , userClickedResultsPaginationMsg = handlers.userClickedResultsPaginationMsg
    , userTriggeredSearchSubmitMsg = handlers.userTriggeredSearchSubmitMsg
    , userEnteredTextInKeywordQueryBoxMsg = handlers.userEnteredTextInKeywordQueryBoxMsg
    , userResetAllFiltersMsg = handlers.userResetAllFiltersMsg
    , userRemovedActiveFilterMsg = handlers.userRemovedActiveFilterMsg
    , userToggledIncipitInfo = handlers.userToggledIncipitInfo
    , panelToggleMsg = handlers.panelToggleMsg
    , facetMsgConfig = handlers.facetMsgConfig
    , expandedDigitizedCopiesMsg = handlers.expandedDigitizedCopiesMsg
    , expandedDigitizedCopiesCallout = handlers.expandedDigitizedCopiesCallout
    , clientStartedAnimatingPreviewWindowClose = handlers.clientStartedAnimatingPreviewWindowClose
    , clientFinishedAnimatingPreviewWindowShow = handlers.clientFinishedAnimatingPreviewWindowShow
    , summaryFormatter = handlers.summaryFormatter
    , preRenderedFormatter = handlers.preRenderedFormatter
    , relationshipFormatter = handlers.relationshipFormatter
    , paragraphFormatter = handlers.paragraphFormatter
    }


viewSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewSearchResultsSection cfg resultsLoading body =
    let
        windowWidth =
            cfg.session.window
                |> Tuple.first

        resultsPanelWidth =
            Layout.resultsPanelWidth windowWidth sidebarWidth

        background =
            el
                [ width fill
                , height fill
                , blurredBackground
                ]

        renderedPreview =
            case .preview cfg.model of
                Loading oldData ->
                    viewPreviewRouter
                        { language = .language cfg.session
                        , currentUrl = Url.toString cfg.session.url
                        , windowSize = .window cfg.session
                        , closeMsg = cfg.userClosedPreviewWindowMsg
                        , hideAnimationStartedMsg = cfg.clientStartedAnimatingPreviewWindowClose
                        , showAnimationFinishedMsg = cfg.clientFinishedAnimatingPreviewWindowShow
                        , animationStatus = .previewAnimationStatus cfg.model
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        , summaryFormatter = cfg.summaryFormatter
                        , preRenderedFormatter = cfg.preRenderedFormatter
                        , relationshipFormatter = cfg.relationshipFormatter
                        , paragraphFormatter = cfg.paragraphFormatter
                        }
                        oldData
                        |> background

                Response resp ->
                    viewPreviewRouter
                        { language = .language cfg.session
                        , currentUrl = Url.toString cfg.session.url
                        , windowSize = .window cfg.session
                        , closeMsg = cfg.userClosedPreviewWindowMsg
                        , hideAnimationStartedMsg = cfg.clientStartedAnimatingPreviewWindowClose
                        , showAnimationFinishedMsg = cfg.clientFinishedAnimatingPreviewWindowShow
                        , animationStatus = .previewAnimationStatus cfg.model
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        , summaryFormatter = cfg.summaryFormatter
                        , preRenderedFormatter = cfg.preRenderedFormatter
                        , relationshipFormatter = cfg.relationshipFormatter
                        , paragraphFormatter = cfg.paragraphFormatter
                        }
                        (Just resp)
                        |> background

                Error errMsg ->
                    viewPreviewError
                        { closeMsg = cfg.userClosedPreviewWindowMsg
                        , errorMessage = errMsg
                        , language = .language cfg.session
                        , windowSize = .window cfg.session
                        }
                        |> background

                NoResponseToShow ->
                    none

        language =
            .language cfg.session

        hasActiveFilters =
            .activeSearch cfg.model
                |> .nextQuery
                |> .filters
                |> Dict.isEmpty
                |> not

        activeFilters =
            viewIf
                (viewActiveFilters
                    { session = cfg.session
                    , model = cfg.model
                    , body = body
                    , userRemovedActiveFilterMsg = cfg.userRemovedActiveFilterMsg
                    }
                )
                hasActiveFilters

        queryBuilderWindow =
            .activeSearch cfg.model
                |> .queryBuilder
                |> viewMaybe
                    (\_ ->
                        Page.QueryBuilder.view
                            { closeMsg = cfg.userClickedCloseQueryBuilderMsg
                            , language = language
                            , model = cfg.model
                            , searchResponse = cfg.searchResponse
                            , userInteractedWithQueryBuilderMsg = cfg.userInteractedWithQueryBuilderMsg
                            }
                    )

        downloaderWindow =
            .activeSearch cfg.model
                |> .downloader
                |> viewMaybe
                    (\downloaderModel ->
                        Page.Downloader.view
                            { closeMsg = cfg.userClickedCloseDownloaderMsg
                            , language = language
                            , model = downloaderModel
                            , userInteractedWithDownloaderMsg = cfg.userInteractedWithDownloaderMsg
                            }
                    )
    in
    row
        [ width fill
        , height fill
        , Background.color colourScheme.white
        , inFront queryBuilderWindow
        , inFront downloaderWindow
        , inFront (viewResultsListLoadingScreenTmpl resultsLoading)
        ]
        [ column
            [ width (px resultsPanelWidth)
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
            , Border.color colourScheme.midGrey
            ]
            [ viewSearchPageSort
                { language = language
                , activeSearch = .activeSearch cfg.model
                , body = body
                , changedResultSortingMsg = cfg.userChangedResultSortingMsg
                , changedResultRowsPerPageMsg = cfg.userChangedResultsPerPageMsg
                , isMobile = False
                }
                cfg.searchResponse
            , viewSearchResultsListPanel
                { language = language
                , model = cfg.model
                , body = body
                , resultsLoading = resultsLoading
                , clickForPreviewMsg = cfg.userClickedResultForPreviewMsg
                , nationalCollectionFilterIsSet = ME.isJust (.restrictedToNationalCollection cfg.session)
                }
            , viewPagination language body.pagination cfg.userClickedResultsPaginationMsg
            ]
        , column
            [ width fill
            , height fill
            , alignTop
            , minimalDropShadow
            , inFront renderedPreview
            ]
            [ viewSearchControlsPanel
                { activeFilters = activeFilters
                , body =
                    viewSearchControls
                        { session = cfg.session
                        , model = cfg.model
                        , body = body
                        , facetMsgConfig = cfg.facetMsgConfig
                        , panelToggleMsg = cfg.panelToggleMsg
                        , userTriggeredSearchSubmitMsg = cfg.userTriggeredSearchSubmitMsg
                        , userEnteredTextInKeywordQueryBoxMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                        , userClickedOpenQueryBuilderMsg = cfg.userClickedOpenQueryBuilderMsg
                        }
                , buttonsConfig =
                    { language = language
                    , model = cfg.model
                    , isFrontPage = False
                    , submitLabel = localTranslations.showResults
                    , submitMsg = cfg.userTriggeredSearchSubmitMsg
                    , resetMsg = cfg.userResetAllFiltersMsg
                    , userClickedOpenDownloaderMsg = cfg.userClickedOpenDownloaderMsg
                    , userClickedCloseDownloaderMsg = cfg.userClickedCloseDownloaderMsg
                    }
                }
            ]
        ]


viewActiveFilters : ActiveFiltersCfg a b msg -> Element msg
viewActiveFilters { session, model, userRemovedActiveFilterMsg } =
    let
        filters =
            .nextQuery model.activeSearch
                |> .filters
                |> Dict.toList

        asfTmpl : ( String, List ( String, LanguageMap ) ) -> List (Element msg)
        asfTmpl ( alias, values ) =
            LE.reverseMap
                (\( value, valueLabel ) ->
                    let
                        label =
                            Dict.get alias (.aliasLabelMap model.activeSearch)
                                |> ME.unwrap alias (\l -> extractLabelFromLanguageMap session.language l)
                    in
                    row
                        [ spacing 5
                        , padding 4
                        , Background.color colourScheme.darkBlue
                        , Font.color colourScheme.white
                        , Font.semiBold
                        , bodyRegular
                        ]
                        [ column []
                            [ text (label ++ ": " ++ extractLabelFromLanguageMap session.language valueLabel) ]
                        , column []
                            [ el
                                [ width (px 20)
                                , height (px 20)
                                , pointer
                                , onClick (userRemovedActiveFilterMsg alias value)
                                ]
                                (closeWindowSvg colourScheme.white)
                            ]
                        ]
                )
                values
    in
    wrappedRow
        [ width fill
        , height shrink
        , paddingXY 20 10
        , Background.color colourScheme.lightestBlue
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.midGrey
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ toLanguageMap "Selected filters"
                    |> h3 session.language
                ]
            , wrappedRow
                [ width fill
                , height fill
                , alignLeft
                , spacing 10
                ]
                (List.concatMap asfTmpl filters)
            ]
        ]


viewSearchControls : SearchControlsConfig a b msg -> Element msg
viewSearchControls cfg =
    let
        searchInterface =
            .showSearchControls cfg.model

        language =
            .language cfg.session

        queryValidation =
            .probeResponse cfg.model
                |> queryValidationState

        suppressBecauseEmpty =
            case .response cfg.model of
                Response (SearchData body) ->
                    List.isEmpty body.queryFields

                Response (FrontData body) ->
                    List.isEmpty body.queryFields

                _ ->
                    True

        qText =
            .activeSearch cfg.model
                |> .nextQuery
                |> toKeywordQuery
                |> Maybe.withDefault ""

        keywordInputField =
            row
                [ width fill
                , paddingXY 0 10
                ]
                [ viewKeywordQueryInput
                    { language = language
                    , submitMsg = cfg.userTriggeredSearchSubmitMsg
                    , changeMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                    , queryText = qText
                    , queryIsValid = queryValidation
                    , userClickedOpenQueryBuilderMsg = cfg.userClickedOpenQueryBuilderMsg
                    , suppressQueryBuilderButton = suppressBecauseEmpty
                    }
                ]

        ( mainSearchField, secondaryQueryField ) =
            case searchInterface of
                SourceSearchOption ->
                    ( keywordInputField, none )

                PeopleSearchOption ->
                    ( keywordInputField, none )

                InstitutionSearchOption ->
                    ( keywordInputField, none )

                IncipitSearchOption ->
                    ( viewFacet
                        { alias = "notation"
                        , language = language
                        , activeSearch = .activeSearch cfg.model
                        , body = cfg.body
                        , tooltip = []
                        , searchPreferences = .searchPreferences cfg.session
                        , suppressKeyboardElementsForMobile = False
                        }
                        cfg.facetMsgConfig
                    , keywordInputField
                    )

                _ ->
                    ( none, none )

        expandedFacetPanels =
            .searchPreferences cfg.session
                |> ME.unwrap Set.empty .expandedFacetPanels

        facetConfig =
            { language = language
            , activeSearch = .activeSearch cfg.model
            , body = cfg.body
            , expandedFacetPanels = expandedFacetPanels
            , panelToggleMsg = cfg.panelToggleMsg
            , facetMsgConfig = cfg.facetMsgConfig
            }

        facetLayout =
            case searchInterface of
                SourceSearchOption ->
                    viewFacetsForSourcesMode facetConfig

                PeopleSearchOption ->
                    viewFacetsForPeopleMode facetConfig

                InstitutionSearchOption ->
                    viewFacetsForInstitutionsMode facetConfig

                IncipitSearchOption ->
                    viewFacetsForIncipitsMode facetConfig

                _ ->
                    []
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
            , height fill
            , alignTop
            , alignLeft
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                , paddingXY 30 10
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    (mainSearchField
                        :: secondaryQueryField
                        :: facetLayout
                    )
                ]
            ]
        ]


type alias SearchResultsListPanelConfig a msg =
    { language : Language
    , model :
        { a
            | activeSearch : ActiveSearch msg
            , selectedResult : Maybe String
        }
    , body : SearchBody
    , resultsLoading : Bool
    , clickForPreviewMsg : String -> msg
    , nationalCollectionFilterIsSet : Bool
    }


viewSearchResultsListPanel : SearchResultsListPanelConfig a msg -> Element msg
viewSearchResultsListPanel cfg =
    if .totalItems cfg.body == 0 then
        let
            activeSearch =
                .activeSearch cfg.model

            otherResultsFound =
                toResultsNotInCurrentMode activeSearch
        in
        viewSearchResultsNotFoundTmpl
            { currentQuery = activeSearch.nextQuery
            , language = cfg.language
            , nationalCollectionFilterIsSet = cfg.nationalCollectionFilterIsSet
            , otherResultsFound = otherResultsFound
            }

    else
        row
            [ width fill
            , height fill
            , alignTop
            , scrollbarY
            , htmlAttribute (HA.style "min-height" "unset")
            , htmlAttribute (HA.id "search-results-list")
            ]
            [ column
                [ width fill
                , height fill
                , alignTop
                ]
                [ viewSearchResultsList cfg.language (.selectedResult cfg.model) cfg.body cfg.clickForPreviewMsg
                ]
            ]


viewSearchResultsList :
    Language
    -> Maybe String
    -> SearchBody
    -> (String -> msg)
    -> Element msg
viewSearchResultsList language selectedResult body clickMsg =
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


type alias SearchResultRouterConfig msg =
    { language : Language
    , selectedResult : Maybe String
    , searchResult : SearchResult
    , clickForPreviewMsg : String -> msg
    , resultIdx : Int
    }


viewSearchResultRouter : SearchResultRouterConfig msg -> Element msg
viewSearchResultRouter cfg =
    let
        resultConfig =
            { clickForPreviewMsg = cfg.clickForPreviewMsg
            , language = cfg.language
            , resultIdx = cfg.resultIdx
            , selectedResult = cfg.selectedResult
            }
    in
    case cfg.searchResult of
        SourceResult body ->
            viewSourceSearchResult resultConfig body

        PersonResult body ->
            viewPersonSearchResult resultConfig body

        InstitutionResult body ->
            viewInstitutionSearchResult resultConfig body

        IncipitResult body ->
            viewIncipitSearchResult resultConfig body

        WorkResult _ ->
            none



--viewWorkSearchResult resultConfig body
