module Page.Views.SearchPage exposing (view)

import Element exposing (Element, alignBottom, alignTop, centerX, clipY, column, el, fill, height, link, maximum, minimum, none, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchPagination, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (minimalDropShadow, searchColumnVerticalSize)
import Page.UI.Components exposing (h4, h5, searchKeywordInput)
import Page.UI.Style exposing (colourScheme, searchHeaderHeight)
import Page.Views.SearchPage.Pagination exposing (viewSearchResultsPagination)
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
            { submitMsg = Msg.SearchSubmit
            , changeMsg = Msg.SearchInput
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
        , Border.color colourScheme.slateGrey
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
                    []
                ]
            , searchModeSelectorSection model
            ]
        ]


searchModeSelectorSection : Model -> Element Msg
searchModeSelectorSection model =
    row
        [ width fill ]
        [ column
            [ width fill
            , paddingXY 20 10
            ]
            [ text "Result type" ]
        ]


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
                    viewSearchResultsSection body activeSearch language

                Error e ->
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


viewSearchResultsSection : SearchBody -> ActiveSearch -> Language -> Element Msg
viewSearchResultsSection body searchParams language =
    row
        [ width fill
        ]
        [ column
            [ width (fill |> minimum 600 |> maximum 800)
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsListSection body language
            ]
        , column
            [ Border.widthEach { top = 0, left = 2, right = 0, bottom = 0 }
            , Border.color colourScheme.slateGrey
            , Background.color colourScheme.white
            , width fill
            , padding 20
            , searchColumnVerticalSize
            , scrollbarY
            , alignTop
            ]
            [ viewSearchResultsPreviewSection searchParams language
            ]
        ]


viewSearchResultsListSection : SearchBody -> Language -> Element Msg
viewSearchResultsListSection body language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewSearchResultsList body language
            , viewSearchResultsPagination body.pagination language
            ]
        ]


viewSearchResultsList : SearchBody -> Language -> Element Msg
viewSearchResultsList body language =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map (\i -> viewSearchResult i language) body.items)
        ]


viewSearchResultsPreviewSection : ActiveSearch -> Language -> Element Msg
viewSearchResultsPreviewSection searchParams language =
    let
        preview =
            searchParams.preview

        showText =
            case preview of
                Loading ->
                    "Loading"

                Response _ ->
                    "Response"

                Error _ ->
                    "Error"

                NoResponseToShow ->
                    "Nothing to see here"
    in
    row
        [ width fill
        , height (px 2000)
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ text showText ]
        ]


viewSearchResult : SearchResult -> Language -> Element Msg
viewSearchResult result language =
    let
        resultTitle =
            el
                [ Font.color colourScheme.lightBlue
                , width fill
                , onClick (PreviewSearchResult result.id)
                , pointer
                ]
                (h5 language result.label)
    in
    row
        [ width fill
        , height (px 60)
        ]
        [ resultTitle ]


viewSearchResultsLoading : Model -> Element Msg
viewSearchResultsLoading model =
    text "Loading"


viewSearchResultsError : Model -> Element Msg
viewSearchResultsError model =
    text "Error"
