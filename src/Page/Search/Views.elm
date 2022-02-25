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
import Page.Search.Views.Loading exposing (searchModeSelectorLoading, viewSearchResultsLoading)
import Page.Search.Views.Previews exposing (viewPreviewRouter, viewUnknownPreview)
import Page.Search.Views.Results.IncipitResult exposing (viewIncipitSearchResult)
import Page.Search.Views.Results.InstitutionResult exposing (viewInstitutionSearchResult)
import Page.Search.Views.Results.PersonResult exposing (viewPersonSearchResult)
import Page.Search.Views.Results.SourceResult exposing (viewSourceSearchResult)
import Page.Search.Views.SearchControls exposing (viewSearchControls)
import Page.UI.Attributes exposing (searchColumnVerticalSize, widthFillHeightFill)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> SearchPageModel -> Element SearchMsg
view session model =
    row
        (List.append [ centerX ] widthFillHeightFill)
        [ column
            widthFillHeightFill
            [ viewTopBar session.language model
            , viewSearchBody session.language model
            ]
        ]


viewSearchBody : Language -> SearchPageModel -> Element SearchMsg
viewSearchBody language model =
    row
        (List.append [ clipY ] widthFillHeightFill)
        [ column
            widthFillHeightFill
            [ searchResultsViewRouter language model ]
        ]


viewTopBar : Language -> SearchPageModel -> Element SearchMsg
viewTopBar lang model =
    row
        [ width fill
        , height (px searchHeaderHeight)
        , Border.widthEach { top = 0, left = 0, bottom = 2, right = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        ]
        [ column
            widthFillHeightFill
            [ searchModeSelectorRouter lang model
            ]
        ]


searchModeSelectorRouter : Language -> SearchPageModel -> Element SearchMsg
searchModeSelectorRouter language model =
    let
        response =
            model.response

        modeView =
            case response of
                Response (SearchData data) ->
                    searchModeSelectorView language model data.modes

                Loading (Just (SearchData oldData)) ->
                    searchModeSelectorView language model oldData.modes

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : Language -> SearchPageModel -> Maybe ModeFacet -> Element SearchMsg
searchModeSelectorView lang model modeFacet =
    let
        currentMode =
            toActiveSearch model
                |> toNextQuery
                |> toMode
    in
    row
        widthFillHeightFill
        [ column
            widthFillHeightFill
            [ viewMaybe (viewModeItems currentMode lang) modeFacet
            ]
        ]


searchResultsViewRouter : Language -> SearchPageModel -> Element SearchMsg
searchResultsViewRouter language model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData

        Loading _ ->
            viewSearchResultsLoading language model

        Response (SearchData body) ->
            viewSearchResultsSection language model body

        Error _ ->
            viewSearchResultsError language model

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoading language model

        _ ->
            -- For any other responses, show the error.
            viewSearchResultsError language model


viewSearchResultsSection : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsSection language model body =
    let
        renderedPreview =
            case model.preview of
                Loading Nothing ->
                    -- TODO: Make a preview loading view
                    viewUnknownPreview

                Loading (Just oldData) ->
                    viewPreviewRouter language oldData

                Response resp ->
                    viewPreviewRouter language resp

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
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            , htmlAttribute (HA.id "search-results-list")
            , Border.widthEach { bottom = 0, top = 0, left = 0, right = 2 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchResultsListPanel language model body
            ]
        , column
            [ width fill
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ viewSearchControls language model body ]
        ]


viewSearchResultsListPanel : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsListPanel language model body =
    row
        widthFillHeightFill
        [ column
            widthFillHeightFill
            [ viewSearchResultsList language model body
            , viewPagination language body.pagination SearchMsg.UserClickedSearchResultsPagination
            ]
        ]


viewSearchResultsList : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewSearchResultsList language model body =
    row
        widthFillHeightFill
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
            viewSourceSearchResult language selectedResult body

        PersonResult body ->
            viewPersonSearchResult language selectedResult body

        InstitutionResult body ->
            viewInstitutionSearchResult language selectedResult body

        IncipitResult body ->
            viewIncipitSearchResult language selectedResult body


viewSearchPageSort : Language -> SearchPageModel -> Element SearchMsg
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


viewPaginationSortSelector : Language -> ActiveSearch -> SearchBody -> Element SearchMsg
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
                            (\inp -> SearchMsg.UserChangedResultSorting inp)
                            listOfLabelsForResultSort
                            (\inp -> inp)
                            chosenSort
                        )
                    ]
                ]
            ]
        ]


viewSearchResultsError : Language -> SearchPageModel -> Element msg
viewSearchResultsError language model =
    case model.response of
        Error msg ->
            text msg

        _ ->
            none
