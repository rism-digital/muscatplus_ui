module Page.UI.Search.SearchView exposing (SearchResultRouterConfig, SearchResultsListPanelConfig, SearchResultsSectionConfig, viewSearchResultRouter, viewSearchResultsSection)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, htmlAttribute, inFront, maximum, none, padding, paddingXY, pointer, px, row, scrollbarY, shrink, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Maybe.Extra as ME
import Page.Query exposing (toKeywordQuery, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.UI.Animations exposing (PreviewAnimationStatus)
import Page.UI.Attributes exposing (bodyRegular, controlsColumnWidth, lineSpacing, responsiveCheckboxColumns, resultsColumnWidth)
import Page.UI.Components exposing (h3)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (closeWindowSvg)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Record.Previews exposing (viewPreviewError, viewPreviewRouter)
import Page.UI.Search.Controls.ControlsConfig exposing (ActiveFiltersCfg, SearchControlsConfig)
import Page.UI.Search.Controls.IncipitsControls exposing (viewFacetsForIncipitsMode)
import Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)
import Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)
import Page.UI.Search.Controls.SourcesControls exposing (viewFacetsForSourcesMode)
import Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)
import Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)
import Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)
import Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)
import Page.UI.Search.SearchComponents exposing (viewSearchButtons)
import Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsNotFoundTmpl)
import Page.UI.SortAndRows exposing (viewSearchPageSort)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData)
import Session exposing (Session)
import Set exposing (Set)


type alias SearchResultsSectionConfig a msg =
    { session : Session
    , model :
        { a
            | preview : Response ServerData
            , previewAnimationStatus : PreviewAnimationStatus
            , sourceItemsExpanded : Bool
            , activeSearch : ActiveSearch msg
            , selectedResult : Maybe String
            , probeResponse : Response ProbeData
            , applyFilterPrompt : Bool
        }
    , searchResponse : Response ServerData
    , expandedIncipitInfoSections : Set String
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
    }


viewSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewSearchResultsSection cfg resultsLoading body =
    let
        background =
            el
                [ width fill
                , height fill
                , Background.color colourScheme.translucentGrey
                , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
                ]

        renderedPreview =
            case .preview cfg.model of
                Loading oldData ->
                    viewPreviewRouter
                        { language = .language cfg.session
                        , windowSize = .window cfg.session
                        , closeMsg = cfg.userClosedPreviewWindowMsg
                        , showAnimationFinishedMsg = cfg.clientFinishedAnimatingPreviewWindowShow
                        , hideAnimationStartedMsg = cfg.clientStartedAnimatingPreviewWindowClose
                        , animationStatus = .previewAnimationStatus cfg.model
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        }
                        oldData
                        |> background

                Response resp ->
                    viewPreviewRouter
                        { language = .language cfg.session
                        , windowSize = .window cfg.session
                        , closeMsg = cfg.userClosedPreviewWindowMsg
                        , showAnimationFinishedMsg = cfg.clientFinishedAnimatingPreviewWindowShow
                        , hideAnimationStartedMsg = cfg.clientStartedAnimatingPreviewWindowClose
                        , animationStatus = .previewAnimationStatus cfg.model
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
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
    in
    row
        [ width fill
        , height fill
        , Background.color colourScheme.white
        ]
        [ column
            [ width (px resultsColumnWidth)
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
            , Border.color colourScheme.darkBlue
            , inFront (viewResultsListLoadingScreenTmpl resultsLoading)
            ]
            [ viewSearchPageSort
                { language = language
                , activeSearch = .activeSearch cfg.model
                , body = body
                , changedResultSortingMsg = cfg.userChangedResultSortingMsg
                , changedResultRowsPerPageMsg = cfg.userChangedResultsPerPageMsg
                }
                cfg.searchResponse
            , viewSearchResultsListPanel
                { language = language
                , model = cfg.model
                , body = body
                , resultsLoading = resultsLoading
                , clickForPreviewMsg = cfg.userClickedResultForPreviewMsg
                }
            , viewPagination language body.pagination cfg.userClickedResultsPaginationMsg
            ]
        , column
            [ controlsColumnWidth (.device cfg.session)
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ viewSearchButtons
                { language = language
                , model = cfg.model
                , isFrontPage = False
                , submitLabel = localTranslations.updateResults
                , submitMsg = cfg.userTriggeredSearchSubmitMsg
                , resetMsg = cfg.userResetAllFiltersMsg
                }
            , activeFilters
            , viewSearchControls
                { session = cfg.session
                , model = cfg.model
                , body = body
                , checkboxColumns = responsiveCheckboxColumns (.device cfg.session)
                , facetMsgConfig = cfg.facetMsgConfig
                , panelToggleMsg = cfg.panelToggleMsg
                , userTriggeredSearchSubmitMsg = cfg.userTriggeredSearchSubmitMsg
                , userEnteredTextInKeywordQueryBoxMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                }
            ]
        ]


viewActiveFilters : ActiveFiltersCfg a b msg -> Element msg
viewActiveFilters { session, model, userRemovedActiveFilterMsg } =
    let
        nextQuery =
            .nextQuery model.activeSearch

        filters =
            nextQuery.filters
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
        , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.darkGrey
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
        currentMode =
            toActiveSearch cfg.model
                |> toNextQuery
                |> toMode

        language =
            .language cfg.session

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        keywordInputField =
            row
                [ width fill
                , paddingXY 0 10
                ]
                [ searchKeywordInput
                    { language = language
                    , submitMsg = cfg.userTriggeredSearchSubmitMsg
                    , changeMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                    , queryText = qText
                    }
                ]

        ( mainSearchField, secondaryQueryField ) =
            case currentMode of
                IncipitsMode ->
                    ( viewFacet
                        { alias = "notation"
                        , language = language
                        , activeSearch = .activeSearch cfg.model
                        , selectColumns = cfg.checkboxColumns
                        , body = cfg.body
                        , tooltip = []
                        , searchPreferences = .searchPreferences cfg.session
                        }
                        cfg.facetMsgConfig
                    , keywordInputField
                    )

                _ ->
                    ( keywordInputField, none )

        expandedFacetPanels =
            .searchPreferences cfg.session
                |> ME.unwrap Set.empty .expandedFacetPanels

        facetConfig =
            { language = language
            , activeSearch = .activeSearch cfg.model
            , body = cfg.body
            , numberOfSelectColumns = cfg.checkboxColumns
            , expandedFacetPanels = expandedFacetPanels
            , panelToggleMsg = cfg.panelToggleMsg
            , facetMsgConfig = cfg.facetMsgConfig
            }

        facetLayout =
            case currentMode of
                SourcesMode ->
                    viewFacetsForSourcesMode facetConfig

                PeopleMode ->
                    viewFacetsForPeopleMode facetConfig

                InstitutionsMode ->
                    viewFacetsForInstitutionsMode facetConfig

                IncipitsMode ->
                    viewFacetsForIncipitsMode facetConfig

                LiturgicalFestivalsMode ->
                    [ none ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width (fill |> maximum 1100)
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
    }


viewSearchResultsListPanel : SearchResultsListPanelConfig a msg -> Element msg
viewSearchResultsListPanel cfg =
    if .totalItems cfg.body == 0 then
        viewSearchResultsNotFoundTmpl cfg.language

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
            { language = cfg.language
            , selectedResult = cfg.selectedResult
            , clickForPreviewMsg = cfg.clickForPreviewMsg
            , resultIdx = cfg.resultIdx
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
