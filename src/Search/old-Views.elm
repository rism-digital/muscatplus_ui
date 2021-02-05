module Search.OldViews exposing (..)

import Api.Search exposing (ApiResponse(..), SearchResult)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes
import Language exposing (Language(..), LanguageMap, LanguageValues(..), extractLabelFromLanguageMap)
import Search.DataTypes exposing (Model, Msg(..))
import UI.Layout exposing (renderBody)
import UI.Style exposing (bodyFont, minMaxFill)


renderSearchBarArea : Model -> List (Element Msg)
renderSearchBarArea model =
    [ column [ width fill, height fill ]
        [ row [ width fill, height fill ]
            [ column [ width (fillPortion 8) ]
                [ Input.search [ width fill, htmlAttribute (Html.Attributes.autocomplete False) ]
                    { label = Input.labelHidden "Search"
                    , onChange = SearchInput
                    , placeholder = Just (Input.placeholder [] (text "Search"))
                    , text = model.keywordQuery
                    }
                ]
            , column [ width (fillPortion 2), height fill ]
                [ Input.button [ centerX, centerY, padding 20, Font.bold ]
                    { onPress = Just SearchSubmit
                    , label = text "Submit"
                    }
                ]
            ]
        ]
    ]


renderSearchBody : Model -> List (Html.Html Msg)
renderSearchBody model =
    renderBody (renderContents model)


renderSearchBar : Model -> Element Msg
renderSearchBar model =
    row [ width minMaxFill, height (fillPortion 2), centerX, paddingEach { top = 0, bottom = 30, left = 0, right = 0 } ]
        [ column [ width fill, height fill ]
            [ row [ width fill, height fill ] (renderSearchBarArea model)
            ]
        ]


renderContents : Model -> Element Msg
renderContents model =
    column [ width fill, height fill ]
        [ renderSearchBar model ]


renderSideBar : Model -> Element Msg
renderSideBar model =
    el [] (text "Sidebar")


renderSearchResults : Model -> Element Msg
renderSearchResults model =
    let
        responseItems =
            case model.response of
                Response resp ->
                    List.map (renderSearchResult model.language) resp.items

                Loading ->
                    [ el [] (text "Loading") ]

                NoResponseToShow ->
                    [ el [] (text "No results") ]

                ApiError ->
                    [ el [] (text model.errorMessage) ]
    in
    row [ width fill, height fill ]
        [ column [] responseItems ]


renderSearchResult : Language -> SearchResult -> Element Msg
renderSearchResult lang result =
    let
        recordType =
            extractLabelFromLanguageMap lang result.typeLabel
    in
    row [ width fill, paddingXY 0 10 ]
        [ column [ width fill, height fill ]
            [ row [ width fill ]
                [ link [ Font.size 24 ]
                    { label = text (extractLabelFromLanguageMap lang result.label)
                    , url = result.id
                    }
                ]
            , row [ width fill ]
                [ el [ Font.size 18 ] (text recordType) ]
            ]
        ]


renderResponsePaginator : Model -> Element Msg
renderResponsePaginator model =
    case model.response of
        Response resp ->
            let
                respPaginator =
                    resp.view
            in
            row [ width fill ]
                [ column [ centerX, centerY, paddingXY 0 20 ]
                    [ paginatorFirstLink respPaginator.first
                    , paginatorPreviousLink respPaginator.previous
                    , paginatorTotalPages respPaginator.totalPages
                    , paginatorNextLink respPaginator.next
                    , paginatorLastLink respPaginator.last
                    ]
                ]

        _ ->
            none


paginatorNextLink : Maybe String -> Element Msg
paginatorNextLink nextLink =
    case nextLink of
        Just url ->
            link [] { url = url, label = text "Next" }

        Nothing ->
            none


paginatorLastLink : Maybe String -> Element Msg
paginatorLastLink lastLink =
    case lastLink of
        Just url ->
            link [] { url = url, label = text "Last" }

        Nothing ->
            none


paginatorPreviousLink : Maybe String -> Element Msg
paginatorPreviousLink prevLink =
    case prevLink of
        Just url ->
            link [] { url = url, label = text "Previous" }

        Nothing ->
            none


paginatorFirstLink : String -> Element Msg
paginatorFirstLink firstLink =
    link [] { url = firstLink, label = text "First!" }


paginatorTotalPages : Int -> Element Msg
paginatorTotalPages pages =
    el []
        (String.fromInt pages
            |> text
        )
