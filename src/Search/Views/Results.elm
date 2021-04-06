module Search.Views.Results exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, link, none, paddingEach, paddingXY, paragraph, px, row, spacingXY, text, width)
import Element.Font as Font
import Search.DataTypes exposing (ApiResponse(..), Model, Msg, SearchPagination, SearchResponse, SearchResult)
import Shared.Language exposing (Language)
import UI.Components exposing (h5)
import UI.Style exposing (bodySM, darkBlue, darkGrey, red)


viewResult : SearchResult -> Language -> Element Msg
viewResult result language =
    row
        [ width fill
        , height (px 120)
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ paragraph
                [ width fill
                , alignTop
                ]
                [ link
                    [ alignTop
                    , paddingEach { top = 0, left = 0, right = 10, bottom = 0 }
                    , Font.color darkBlue
                    , Font.underline
                    ]
                    { url = result.id
                    , label = h5 language result.label
                    }
                , paragraph
                    [ width fill
                    , Font.color red
                    ]
                    [ h5 language result.typeLabel ]
                ]
            ]
        ]


viewResultList : Model -> Element Msg
viewResultList model =
    let
        language =
            model.language

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
    let
        paginator =
            if pagination.totalPages > 1 then
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

            else
                none
    in
    paginator


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
            |> (++) "Page "
            |> text
        )


viewResultCount : SearchResponse -> Language -> Element Msg
viewResultCount response language =
    row
        [ width fill
        , height (px 30)
        , bodySM
        , Font.color darkGrey
        ]
        [ text ("Found " ++ String.fromInt response.totalItems ++ " results") ]
