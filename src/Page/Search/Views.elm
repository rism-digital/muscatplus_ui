module Page.Search.Views exposing (view)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (DeviceClass(..), Element, Orientation(..), alignTop, centerX, clipY, column, fill, height, none, px, row, width)
import Element.Border as Border
import Language exposing (Language)
import Page.Query exposing (toMode, toNextQuery)
import Page.RecordTypes.Search exposing (ModeFacet, SearchBody, SearchResult(..))
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Facets exposing (facetSearchMsgConfig, viewModeItems)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Search.SearchView exposing (SearchResultsSectionConfig, viewSearchResultsSection)
import Page.UI.Search.Templates.SearchTmpl exposing (viewSearchResultsErrorTmpl, viewSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


searchModeSelectorRouter : Language -> SearchPageModel SearchMsg -> Element SearchMsg
searchModeSelectorRouter language model =
    case model.response of
        Loading (Just (SearchData oldData)) ->
            searchModeSelectorView language model oldData.modes

        Response (SearchData data) ->
            searchModeSelectorView language model data.modes

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
    let
        resultsConfig : SearchResultsSectionConfig (SearchPageModel SearchMsg) SearchMsg
        resultsConfig =
            { session = session
            , model = model
            , userClosedPreviewWindowMsg = SearchMsg.UserClickedClosePreviewWindow
            , userClickedResultForPreviewMsg = SearchMsg.UserClickedSearchResultForPreview
            , userChangedResultSortingMsg = SearchMsg.UserChangedResultSorting
            , userChangedResultsPerPageMsg = SearchMsg.UserChangedResultsPerPage
            , userClickedResultsPaginationMsg = SearchMsg.UserClickedSearchResultsPagination
            , userTriggeredSearchSubmitMsg = SearchMsg.UserTriggeredSearchSubmit
            , userEnteredTextInKeywordQueryBoxMsg = SearchMsg.UserEnteredTextInKeywordQueryBox
            , userResetAllFiltersMsg = SearchMsg.UserResetAllFilters
            , facetMsgConfig = facetSearchMsgConfig
            , sectionToggleMsg = SearchMsg.UserClickedFacetPanelToggle
            }
    in
    case model.response of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection resultsConfig True oldData

        Loading _ ->
            viewSearchResultsLoadingTmpl session.language

        Response (SearchData body) ->
            viewSearchResultsSection resultsConfig False body

        Error err ->
            viewSearchResultsErrorTmpl session.language err

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoadingTmpl session.language

        _ ->
            -- For any other responses, show the error.
            viewSearchResultsErrorTmpl session.language "An unknown error occurred."


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
        , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
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
