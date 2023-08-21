module Page.UI.Search.SearchView exposing (SearchResultRouterConfig, SearchResultsListPanelConfig, SearchResultsSectionConfig, viewSearchResultsSection)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignLeft, alignTop, column, fill, height, htmlAttribute, inFront, maximum, none, padding, paddingEach, paddingXY, row, scrollbarY, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Error.Views exposing (createErrorMessage)
import Page.Query exposing (toKeywordQuery, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.UI.Attributes exposing (controlsColumnWidth, responsiveCheckboxColumns, resultColumnWidth)
import Page.UI.Components exposing (dividerWithText, viewBlankBottomBar)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Record.Previews exposing (viewPreviewError, viewPreviewRouter)
import Page.UI.Search.Controls.ControlsConfig exposing (SearchControlsConfig)
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
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData)
import Session exposing (Session)
import Set exposing (Set)


type alias SearchResultsSectionConfig a msg =
    { session : Session
    , model :
        { a
            | preview : Response ServerData
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
    , userToggledIncipitInfo : String -> msg
    , panelToggleMsg : String -> Set String -> msg
    , facetMsgConfig : FacetMsgConfig msg
    }


viewSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewSearchResultsSection cfg resultsLoading body =
    let
        renderedPreview =
            case .preview cfg.model of
                Loading oldData ->
                    viewPreviewRouter (.language cfg.session)
                        { closeMsg = cfg.userClosedPreviewWindowMsg
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        }
                        oldData

                Response resp ->
                    viewPreviewRouter (.language cfg.session)
                        { closeMsg = cfg.userClosedPreviewWindowMsg
                        , sourceItemExpandMsg = cfg.userClickedSourceItemsExpandMsg
                        , sourceItemsExpanded = .sourceItemsExpanded cfg.model
                        , incipitInfoSectionsExpanded = cfg.expandedIncipitInfoSections
                        , incipitInfoToggleMsg = cfg.userToggledIncipitInfo
                        }
                        (Just resp)

                Error errMsg ->
                    createErrorMessage (.language cfg.session) errMsg
                        |> Tuple.first
                        |> viewPreviewError (.language cfg.session) cfg.userClosedPreviewWindowMsg

                NoResponseToShow ->
                    none

        language =
            .language cfg.session
    in
    row
        [ width fill
        , height fill
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ resultColumnWidth (.device cfg.session)
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
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
            , viewBlankBottomBar
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

                -- [ viewFacetsForIncipitsMode facetConfig ]
                LiturgicalFestivalsMode ->
                    [ none ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
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
                        :: row
                            [ width fill
                            , paddingEach { bottom = 0, left = 0, right = 0, top = 10 }
                            ]
                            [ dividerWithText (extractLabelFromLanguageMap language localTranslations.additionalFilters)
                            ]
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
            (List.map
                (\result ->
                    viewSearchResultRouter
                        { language = language
                        , selectedResult = selectedResult
                        , searchResult = result
                        , clickForPreviewMsg = clickMsg
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
    }


viewSearchResultRouter : SearchResultRouterConfig msg -> Element msg
viewSearchResultRouter cfg =
    let
        resultConfig =
            { clickForPreviewMsg = cfg.clickForPreviewMsg
            , language = cfg.language
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
