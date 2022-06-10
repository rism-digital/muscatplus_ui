module Page.Search.Views exposing (..)

import ActiveSearch exposing (toActiveSearch)
import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (DeviceClass(..), Element, Orientation(..), alignBottom, alignLeft, alignRight, alignTop, centerX, clipY, column, el, fill, fillPortion, height, htmlAttribute, inFront, minimum, none, padding, paddingXY, px, row, scrollbarY, shrink, spacing, text, width)
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
import Page.UI.Record.Previews exposing (viewPreviewRouter)
import Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)
import Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)
import Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)
import Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)
import Page.UI.Search.Templates.SearchTmpl exposing (viewResultsListLoadingScreenTmpl, viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl, viewSearchResultsNotFoundTmpl)
import Page.UI.SortAndRows exposing (viewSearchPageSort)
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


searchResultsViewRouter : Session -> SearchPageModel SearchMsg -> Element SearchMsg
searchResultsViewRouter session model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection session model oldData True

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewSearchResultsSection session model body False

        Error err ->
            viewSearchResultsErrorTmpl session.language err

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            -- For any other responses, show the error.
            viewSearchResultsErrorTmpl session.language "An unknown error occurred."


viewSearchResultsSection : Session -> SearchPageModel SearchMsg -> SearchBody -> Bool -> Element SearchMsg
viewSearchResultsSection session model body isLoading =
    let
        renderedPreview =
            case model.preview of
                Loading oldData ->
                    viewPreviewRouter session.language SearchMsg.UserClickedClosePreviewWindow oldData

                Response resp ->
                    viewPreviewRouter session.language SearchMsg.UserClickedClosePreviewWindow (Just resp)

                Error _ ->
                    none

                NoResponseToShow ->
                    none

        ( resultColumnWidth, controlsColumnWidth ) =
            let
                { class, orientation } =
                    session.device
            in
            case ( class, orientation ) of
                ( Phone, Portrait ) ->
                    ( width fill, width (px 0) )

                ( Desktop, Landscape ) ->
                    ( width (fill |> minimum 600), width (px 900) )

                ( BigDesktop, Landscape ) ->
                    ( width (fill |> minimum 600), width (px 900) )

                _ ->
                    ( width (fill |> minimum 600), width fill )
    in
    row
        [ width fill
        , height fill
        , Background.color (colourScheme.white |> convertColorToElementColor)
        ]
        [ column
            [ resultColumnWidth
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, top = 0, left = 0, right = 2 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchPageSort
                { language = session.language
                , activeSearch = model.activeSearch
                , body = body
                , changedResultSortingMsg = SearchMsg.UserChangedResultSorting
                , changedResultRowsPerPageMsg = SearchMsg.UserChangedResultsPerPage
                }
                model.response
            , viewSearchResultsListPanel session.language model body isLoading
            , viewPagination session.language body.pagination SearchMsg.UserClickedSearchResultsPagination
            ]
        , column
            [ controlsColumnWidth
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ viewSearchControls session.language model body ]
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
                , height fill
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
        , height fill
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
