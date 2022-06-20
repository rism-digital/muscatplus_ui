module Page.UI.Search.SearchView exposing (SearchControlsConfig, SearchResultRouterConfig, SearchResultsListPanelConfig, SearchResultsSectionConfig, viewSearchResultsSection)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Attribute, Device, DeviceClass(..), Element, Orientation(..), alignTop, centerX, column, fill, height, htmlAttribute, inFront, maximum, minimum, none, px, row, scrollbarY, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..))
import Page.UI.Attributes exposing (controlsColumnWidth, responsiveCheckboxColumns, resultColumnWidth)
import Page.UI.Components exposing (viewBlankBottomBar)
import Page.UI.Facets.Facets exposing (FacetMsgConfig)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Record.Previews exposing (viewPreviewError, viewPreviewRouter)
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


type alias SearchResultsSectionConfig a msg =
    { session : Session
    , model :
        { a
            | preview : Response ServerData
            , activeSearch : ActiveSearch msg
            , response : Response ServerData
            , selectedResult : Maybe String
            , probeResponse : Response ProbeData
            , applyFilterPrompt : Bool
        }
    , userClosedPreviewWindowMsg : msg
    , userClickedResultForPreviewMsg : String -> msg
    , userChangedResultSortingMsg : String -> msg
    , userChangedResultsPerPageMsg : String -> msg
    , userClickedResultsPaginationMsg : String -> msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    , userResetAllFiltersMsg : msg
    , sectionToggleMsg : msg
    , facetMsgConfig : FacetMsgConfig msg
    }


viewSearchResultsSection : SearchResultsSectionConfig a msg -> Bool -> SearchBody -> Element msg
viewSearchResultsSection cfg resultsLoading body =
    let
        renderedPreview =
            case .preview cfg.model of
                Loading oldData ->
                    viewPreviewRouter (.language cfg.session) cfg.userClosedPreviewWindowMsg oldData

                Response resp ->
                    viewPreviewRouter (.language cfg.session) cfg.userClosedPreviewWindowMsg (Just resp)

                Error errMsg ->
                    viewPreviewError (.language cfg.session) cfg.userClosedPreviewWindowMsg errMsg

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
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchPageSort
                { language = language
                , activeSearch = .activeSearch cfg.model
                , body = body
                , changedResultSortingMsg = cfg.userChangedResultSortingMsg
                , changedResultRowsPerPageMsg = cfg.userChangedResultsPerPageMsg
                }
                (.response cfg.model)
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
                { language = language
                , model = cfg.model
                , body = body
                , checkboxColumns = responsiveCheckboxColumns (.device cfg.session)
                , facetMsgConfig = cfg.facetMsgConfig
                , sectionToggleMsg = cfg.sectionToggleMsg
                , userTriggeredSearchSubmitMsg = cfg.userTriggeredSearchSubmitMsg
                , userEnteredTextInKeywordQueryBoxMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                }
            , viewBlankBottomBar
            ]
        ]


type alias SearchControlsConfig a msg =
    { language : Language
    , model : { a | activeSearch : ActiveSearch msg }
    , body : SearchBody
    , checkboxColumns : Int
    , facetMsgConfig : FacetMsgConfig msg
    , sectionToggleMsg : msg
    , userTriggeredSearchSubmitMsg : msg
    , userEnteredTextInKeywordQueryBoxMsg : String -> msg
    }


viewSearchControls : SearchControlsConfig a msg -> Element msg
viewSearchControls cfg =
    let
        currentMode =
            toActiveSearch cfg.model
                |> toNextQuery
                |> toMode

        facetConfig =
            { language = cfg.language
            , activeSearch = .activeSearch cfg.model
            , body = cfg.body
            , numberOfSelectColumns = cfg.checkboxColumns
            , sectionToggleMsg = cfg.sectionToggleMsg
            , userTriggeredSearchSubmitMsg = cfg.userTriggeredSearchSubmitMsg
            , userEnteredTextInKeywordQueryBoxMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
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
                    none
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        ]
        [ column
            [ width (fill |> maximum 1100)
            , centerX
            , height fill
            , alignTop
            ]
            [ facetLayout
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
                , inFront (viewResultsListLoadingScreenTmpl cfg.resultsLoading)
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
            { language = cfg.language
            , selectedResult = cfg.selectedResult
            , clickForPreviewMsg = cfg.clickForPreviewMsg
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
