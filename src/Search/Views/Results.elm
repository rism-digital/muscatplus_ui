module Search.Views.Results exposing (..)

import Api.Search exposing (ApiResponse(..), SearchPagination, SearchResult)
import Element exposing (Element, centerX, centerY, column, el, fill, link, none, paddingXY, row, spacingXY, text, width)
import Language exposing (Language)
import Search.DataTypes exposing (Model, Msg)
import UI.Components exposing (h4)


viewResult : SearchResult -> Language -> Element Msg
viewResult result language =
    row
        [ width fill ]
        [ link
            []
            { url = result.id
            , label = h4 language result.label
            }
        ]


viewResultList : Model -> Language -> Element Msg
viewResultList model language =
    let
        templatedResults =
            case model.response of
                Response results ->
                    row
                        [ width fill ]
                        [ column
                            [ width fill ]
                            (List.map (\r -> viewResult r language) results.items)
                        ]

                ApiError ->
                    row [ width fill ] [ text model.errorMessage ]

                Loading ->
                    row [ width fill ] [ text "Loading results..." ]

                _ ->
                    row [ width fill ] [ text "No results to show." ]

        paginator =
            case model.response of
                Response resp ->
                    viewResponsePaginator resp.view

                _ ->
                    none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ templatedResults
            , paginator
            ]
        ]


viewResponsePaginator : SearchPagination -> Element Msg
viewResponsePaginator pagination =
    row [ width fill ]
        [ column
            [ centerX
            , centerY
            , paddingXY 0 20
            ]
            [ row
                [ spacingXY 20 20 ]
                [ viewPaginatorFirstLink pagination.first
                , viewPaginatorPreviousLink pagination.previous
                , viewPaginatorTotalPages pagination.totalPages
                , viewPaginatorNextLink pagination.next
                , viewPaginatorLastLink pagination.last
                ]
            ]
        ]


viewPaginatorNextLink : Maybe String -> Element Msg
viewPaginatorNextLink nextLink =
    case nextLink of
        Just url ->
            el [] (link [] { url = url, label = text "Next" })

        Nothing ->
            none


viewPaginatorLastLink : Maybe String -> Element Msg
viewPaginatorLastLink lastLink =
    case lastLink of
        Just url ->
            el [] (link [] { url = url, label = text "Last" })

        Nothing ->
            none


viewPaginatorPreviousLink : Maybe String -> Element Msg
viewPaginatorPreviousLink prevLink =
    case prevLink of
        Just url ->
            el [] (link [] { url = url, label = text "Previous" })

        Nothing ->
            none


viewPaginatorFirstLink : String -> Element Msg
viewPaginatorFirstLink firstLink =
    el [] (link [] { url = firstLink, label = text "First" })


viewPaginatorTotalPages : Int -> Element Msg
viewPaginatorTotalPages pages =
    el []
        (String.fromInt pages
            |> text
        )
