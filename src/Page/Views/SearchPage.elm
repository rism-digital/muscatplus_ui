module Page.Views.SearchPage exposing (..)

import Element exposing (Color, Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, maximum, minimum, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.RecordTypes.Search exposing (Facet, SearchBody, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (bodySM, minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (searchKeywordInput)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Page.Views.SearchPage.Facets exposing (viewModeItems)
import Page.Views.SearchPage.Pagination exposing (viewSearchResultsPagination)
import Page.Views.SearchPage.Previews exposing (viewPreviewRouter)
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
                , column
                    [ width fill ]
                    [ text "Hide item records"
                    ]
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
                    searchModeSelectorView selectedMode data.modes model.language

                _ ->
                    searchModeSelectorLoading
    in
    modeView


searchModeSelectorView : ResultMode -> Facet -> Language -> Element Msg
searchModeSelectorView currentMode modeFacet language =
    row
        [ width fill ]
        [ column
            [ width fill
            ]
            [ viewModeItems currentMode modeFacet language
            ]
        ]


searchModeSelectorLoading : Element Msg
searchModeSelectorLoading =
    none


searchResultsViewRouter : Model -> Element Msg
searchResultsViewRouter model =
    let
        page =
            model.page

        resp =
            page.response

        language =
            model.language

        activeSearch =
            model.activeSearch

        sectionView =
            case resp of
                Loading ->
                    viewSearchResultsLoading model

                Response (SearchData body) ->
                    viewSearchResultsSection language activeSearch body

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


viewSearchResultsSection : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsSection language searchParams body =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsListSection language searchParams body
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)

            --, Background.color colourScheme.white
            , width (fill |> minimum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsPreviewSection searchParams language
            ]
        ]


viewSearchResultsListSection : Language -> ActiveSearch -> SearchBody -> Element Msg
viewSearchResultsListSection language searchParams body =
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


viewSearchResultsPreviewSection : ActiveSearch -> Language -> Element Msg
viewSearchResultsPreviewSection searchParams language =
    let
        preview =
            searchParams.preview

        renderedPreview =
            case preview of
                Loading ->
                    el [] (text "Loading")

                Response resp ->
                    viewPreviewRouter language resp

                Error _ ->
                    el [] (text "Error")

                NoResponseToShow ->
                    el [] (text "Nothing to see here")
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ renderedPreview ]
        ]


makeFlagIcon : Color -> Element msg -> String -> Element msg
makeFlagIcon borderColour iconImage iconLabel =
    column
        [ bodySM
        , padding 4
        , Border.width 1
        , Border.color borderColour
        , Border.rounded 4
        ]
        [ row
            [ spacing 5
            ]
            [ el
                [ width (px 20)
                , height (px 20)
                ]
                iconImage
            , text iconLabel
            ]
        ]


viewSearchResultsLoading : Model -> Element Msg
viewSearchResultsLoading model =
    text "Loading"


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
