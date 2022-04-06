module Page.Search.Views exposing (..)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, none, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.Search exposing (ModeFacet, SearchBody, SearchResult(..))
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (viewModeItems)
import Page.Search.Views.SearchControls exposing (viewSearchControls)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Record.Previews exposing (viewPreviewRouter, viewUnknownPreview)
import Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)
import Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)
import Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)
import Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)
import Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl, viewSearchResultsNotFoundTmpl)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


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
            [ viewTopBar session.language model
            , viewSearchBody session.language model
            ]
        ]


viewSearchBody : Language -> SearchPageModel SearchMsg -> Element SearchMsg
viewSearchBody language model =
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
            [ searchResultsViewRouter language model ]
        ]


viewTopBar : Language -> SearchPageModel SearchMsg -> Element SearchMsg
viewTopBar lang model =
    row
        [ width fill
        , height (px searchHeaderHeight)
        , Border.widthEach { top = 0, left = 0, bottom = 2, right = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ searchModeSelectorRouter lang model
            ]
        ]


searchModeSelectorRouter : Language -> SearchPageModel SearchMsg -> Element SearchMsg
searchModeSelectorRouter language model =
    case model.response of
        Response (SearchData data) ->
            searchModeSelectorView language model data.modes

        Loading (Just (SearchData oldData)) ->
            searchModeSelectorView language model oldData.modes

        _ ->
            none


searchModeSelectorView : Language -> SearchPageModel SearchMsg -> Maybe ModeFacet -> Element SearchMsg
searchModeSelectorView lang model modeFacet =
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
            [ viewMaybe (viewModeItems currentMode lang) modeFacet
            ]
        ]


searchResultsViewRouter : Language -> SearchPageModel SearchMsg -> Element SearchMsg
searchResultsViewRouter language model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData True

        Loading _ ->
            viewSearchResultsLoadingTmpl language

        Response (SearchData body) ->
            viewSearchResultsSection language model body False

        Error err ->
            viewSearchResultsErrorTmpl language err

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl language

        _ ->
            -- For any other responses, show the error.
            viewSearchResultsErrorTmpl language "An unknown error occurred."


viewSearchResultsSection : Language -> SearchPageModel SearchMsg -> SearchBody -> Bool -> Element SearchMsg
viewSearchResultsSection language model body isLoading =
    let
        renderedPreview =
            case model.preview of
                Loading Nothing ->
                    -- TODO: Make a preview loading view
                    viewUnknownPreview

                Loading (Just oldData) ->
                    viewPreviewRouter language SearchMsg.UserClickedClosePreviewWindow oldData

                Response resp ->
                    viewPreviewRouter language SearchMsg.UserClickedClosePreviewWindow resp

                Error _ ->
                    none

                NoResponseToShow ->
                    none
    in
    row
        [ width fill
        , height fill
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, top = 0, left = 0, right = 2 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchResultsListPanel language model body isLoading
            , viewPagination language body.pagination SearchMsg.UserClickedSearchResultsPagination
            ]
        , column
            [ width fill
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ viewSearchControls language model body ]
        ]


viewSearchResultsListPanel : Language -> SearchPageModel SearchMsg -> SearchBody -> Bool -> Element SearchMsg
viewSearchResultsListPanel language model body isLoading =
    if body.totalItems == 0 then
        viewSearchResultsNotFoundTmpl language

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
                , height shrink
                , alignTop
                , inFront <| viewResultsListLoadingScreenTmpl isLoading
                ]
                [ viewSearchResultsList language model body
                ]
            ]


viewSearchResultsList : Language -> SearchPageModel SearchMsg -> SearchBody -> Element SearchMsg
viewSearchResultsList language model body =
    row
        [ width fill
        , height shrink
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map (\result -> viewSearchResultRouter language model.selectedResult result) body.items)
        ]


viewSearchResultRouter : Language -> Maybe String -> SearchResult -> Element SearchMsg
viewSearchResultRouter language selectedResult res =
    case res of
        SourceResult body ->
            viewSourceSearchResult
                { language = language
                , selectedResult = selectedResult
                , body = body
                , clickForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
                }

        PersonResult body ->
            viewPersonSearchResult
                { language = language
                , selectedResult = selectedResult
                , body = body
                , clickForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
                }

        InstitutionResult body ->
            viewInstitutionSearchResult
                { language = language
                , selectedResult = selectedResult
                , body = body
                , clickForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
                }

        IncipitResult body ->
            viewIncipitSearchResult
                { language = language
                , selectedResult = selectedResult
                , body = body
                , clickForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
                }


viewSearchPageSort : Language -> SearchPageModel SearchMsg -> Element SearchMsg
viewSearchPageSort language model =
    let
        activeSearch =
            model.activeSearch
    in
    case model.response of
        Response (SearchData body) ->
            viewPaginationSortSelector language activeSearch body

        Loading (Just (SearchData body)) ->
            viewPaginationSortSelector language activeSearch body

        _ ->
            none


viewPaginationSortSelector : Language -> ActiveSearch SearchMsg -> SearchBody -> Element SearchMsg
viewPaginationSortSelector language activeSearch body =
    let
        pagination =
            body.pagination

        thisPage =
            formatNumberByLanguage language (toFloat pagination.thisPage)

        totalPages =
            formatNumberByLanguage language (toFloat pagination.totalPages)

        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages

        sorting =
            body.sorts

        listOfLabelsForResultSort =
            List.map
                (\d -> ( d.alias, extractLabelFromLanguageMap language d.label ))
                sorting

        chosenSort =
            Maybe.withDefault "relevance" activeSearch.selectedResultSort
    in
    row
        [ width fill ]
        [ column
            [ width (fillPortion 2) ]
            [ text pageInfo ]
        , column
            [ width (fillPortion 3) ]
            [ row
                [ width fill
                , spacing 10
                ]
                [ column
                    [ width shrink ]
                    [ text "Sort by" ]
                , column
                    [ width fill ]
                    [ el
                        []
                        (dropdownSelect
                            { selectedMsg = \inp -> SearchMsg.UserChangedResultSorting inp
                            , choices = listOfLabelsForResultSort
                            , choiceFn = \inp -> inp
                            , currentChoice = chosenSort
                            , selectIdent = "pagination-sort-select" -- TODO: Check that this is unique!
                            , label = Nothing
                            , language = language
                            }
                        )
                    ]
                ]
            ]
        ]
