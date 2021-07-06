module Page.Views.SearchPage exposing (..)

import Color exposing (Color)
import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, inFront, maximum, minimum, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language)
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Query exposing (Filter(..))
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.RecordTypes.Search exposing (ModeFacet, SearchBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (bodySM, headerBottomBorder, minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (searchKeywordInput)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.SearchPage.Facets exposing (viewFacet, viewModeItems)
import Page.Views.SearchPage.Loading exposing (searchModeSelectorLoading, viewSearchResultsLoading)
import Page.Views.SearchPage.Pagination exposing (viewSearchResultsPagination)
import Page.Views.SearchPage.Previews exposing (viewPreviewLoading, viewPreviewRouter)
import Page.Views.SearchPage.Results exposing (viewSearchResult)
import Search exposing (ActiveSearch)


view : Model -> Element Msg
view model =
    row
        [ width fill
        , height fill
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewTopBar model
            , viewSearchBody model
            ]
        ]


viewSearchBody : Model -> Element Msg
viewSearchBody model =
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ alignTop
            , width fill
            , height fill
            ]
            [ searchResultsViewRouter model ]
        ]


viewTopBar : Model -> Element Msg
viewTopBar model =
    let
        msgs =
            { submitMsg = Msg.UserClickedSearchSubmitButton
            , changeMsg = Msg.UserInputTextInQueryBox
            }

        activeSearch =
            model.activeSearch

        activeQuery =
            activeSearch.query

        qText =
            Maybe.withDefault "" activeQuery.query
    in
    row
        [ width fill
        , height (px searchHeaderHeight)
        , Border.widthEach { top = 0, left = 0, bottom = 2, right = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , minimalDropShadow
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ column
                    [ width (fill |> minimum 800 |> maximum 1100)
                    , alignTop
                    , paddingXY 20 10
                    ]
                    [ searchKeywordInput msgs qText model.language ]
                ]
            , searchModeSelectorRouter model
            ]
        ]


searchModeSelectorRouter : Model -> Element Msg
searchModeSelectorRouter model =
    let
        activeSearch =
            model.activeSearch

        selectedMode =
            activeSearch.selectedMode

        page =
            model.page

        response =
            page.response

        modeView =
            case response of
                Response (SearchData data) ->
                    searchModeSelectorView selectedMode model.language data.modes

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : ResultMode -> Language -> Maybe ModeFacet -> Element Msg
searchModeSelectorView currentMode language modeFacet =
    row
        [ width fill ]
        [ column
            [ width fill
            ]
            [ viewMaybe (viewModeItems currentMode language) modeFacet
            ]
        ]


searchResultsViewRouter : Model -> Element Msg
searchResultsViewRouter model =
    let
        page =
            model.page

        resp =
            page.response

        sectionView =
            case resp of
                Loading ->
                    viewSearchResultsLoading model

                Response (SearchData body) ->
                    viewSearchResultsSection model body

                Error _ ->
                    viewSearchResultsError model

                NoResponseToShow ->
                    -- In case we're just booting the app up, show
                    -- the loading message.
                    viewSearchResultsLoading model

                _ ->
                    -- For any other responses, show the error.
                    viewSearchResultsError model
    in
    sectionView


viewSearchResultsSection : Model -> SearchBody -> Element Msg
viewSearchResultsSection model body =
    let
        language =
            model.language

        searchParams =
            model.activeSearch
    in
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 600 |> maximum 1100)
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsListPanel language searchParams body
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            , Background.color (colourScheme.cream |> convertColorToElementColor)
            , width (fill |> minimum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsControlPanel model
            ]
        ]


viewSearchResultsListPanel : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsListPanel language searchParams body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList language searchParams body
            , viewSearchResultsPagination language body.pagination
            ]
        ]


viewSearchResultsList : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsList language searchParams body =
    let
        selectedResult =
            searchParams.selectedResult
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 20
            , htmlAttribute (HA.id "search-results-list")
            ]
            (List.map (\result -> viewSearchResult language selectedResult result) body.items)
        ]


viewSearchResultsControlPanel : Model -> Element Msg
viewSearchResultsControlPanel model =
    let
        searchParams =
            model.activeSearch

        language =
            model.language

        preview =
            searchParams.preview

        renderedPreview =
            case preview of
                Loading ->
                    -- TODO: Make a preview loading view
                    viewPreviewLoading

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
        ]
        [ column
            [ width fill
            , height fill
            , inFront renderedPreview
            ]
            [ viewSearchControls model ]
        ]


viewSearchResultsError : Model -> Element Msg
viewSearchResultsError model =
    let
        page =
            model.page

        errorMessage =
            case page.response of
                Error msg ->
                    text msg

                _ ->
                    none
    in
    errorMessage


viewSearchControls : Model -> Element Msg
viewSearchControls model =
    let
        page =
            model.page

        resp =
            page.response

        language =
            model.language

        activeSearch =
            model.activeSearch

        controlView =
            case resp of
                Response (SearchData body) ->
                    viewFacetControls language activeSearch body

                _ ->
                    none

        activeFilters =
            case resp of
                Response (SearchData body) ->
                    viewActiveFilters language activeSearch

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            ]
            [ row
                [ width fill
                , height (px 120)
                , headerBottomBorder
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ row
                        [ width fill ]
                        [ el
                            [ Font.size 16
                            , Font.semiBold
                            , alignTop
                            ]
                            (text "Active search parameters")
                        ]
                    , activeFilters
                    ]
                ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    , height fill
                    , spacing 20
                    , alignTop
                    ]
                    [ row
                        [ width fill ]
                        [ el
                            [ Font.size 16
                            , Font.semiBold
                            , alignTop
                            ]
                            (text "Facet controls")
                        ]
                    , controlView
                    ]
                ]
            ]
        ]


viewFacetControls : Language -> ActiveSearch -> SearchBody -> Element Msg
viewFacetControls language activeSearch body =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            ]
            [ viewFacet "hide-source-contents" language activeSearch body
            , viewFacet "hide-source-collections" language activeSearch body
            , viewFacet "hide-composite-volumes" language activeSearch body
            , viewFacet "has-incipits" language activeSearch body
            , viewFacet "has-digitization" language activeSearch body
            , viewFacet "date-range" language activeSearch body
            , viewFacet "num-holdings" language activeSearch body
            , viewFacet "holding-institution" language activeSearch body
            , viewFacet "source-type" language activeSearch body
            , viewFacet "person-role" language activeSearch body
            ]
        ]


viewActiveFilters : Language -> ActiveSearch -> Element Msg
viewActiveFilters language activeSearch =
    let
        query =
            activeSearch.query

        activeFilters =
            query.filters
    in
    row
        []
        [ column
            []
            (List.map viewActiveFilter activeFilters)
        ]


viewActiveFilter : Filter -> Element Msg
viewActiveFilter filt =
    let
        (Filter alias value) =
            filt

        label =
            alias ++ ": " ++ value
    in
    row
        []
        [ el [] (text label) ]
