module UI.View exposing (..)

import Api.Search exposing (ApiResponse(..), SearchRecordType(..), SearchResult)
import DataTypes exposing (Model, Msg(..))
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Language exposing (Language(..), LanguageMap, LanguageValues(..), extractLabelFromLanguageMap)


renderSearchBarArea : Model -> List (Element Msg)
renderSearchBarArea model =
    [ column [ width fill, height fill ]
        [ row [ width fill, height fill ]
            [ column [ width (fillPortion 8) ]
                [ Input.text [ width fill ]
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


renderBody : Model -> List (Html.Html Msg)
renderBody model =
    [ layout [ paddingXY 10 10, Font.family [ Font.typeface "Inter UI" ] ]
        (column [ width fill, height fill ]
            [ row [ width fill, height <| fillPortion 1, paddingEach { top = 0, bottom = 30, left = 0, right = 0 } ]
                [ column [ width <| fillPortion 5, height fill ]
                    [ row [ width fill, height fill ]
                        [ el [ centerX, centerY, Font.family [ Font.typeface "Roboto Slab" ], Font.size 24, Font.bold ] (text "RISM Online") ]
                    ]
                , column [ width <| fillPortion 20, height fill ]
                    [ row [ width fill, height fill ] (renderSearchBarArea model)
                    ]
                ]
            , row [ width fill, height <| fillPortion 10 ]
                [ column [ width (fillPortion 5), height fill, alignLeft, alignTop ]
                    [ el [] (text "sidebar") ]
                , column [ width (fillPortion 20), height fill ] (renderSearchResults model)
                ]
            , responsePaginator model
            ]
        )
    ]


renderSearchResults : Model -> List (Element Msg)
renderSearchResults model =
    let
        responseItems =
            case model.response of
                Response resp ->
                    resp.items

                _ ->
                    []
    in
    [ row []
        [ column [] (List.map (renderSearchResult model.language) responseItems) ]
    ]


renderSearchResult : Language -> SearchResult -> Element Msg
renderSearchResult lang result =
    let
        recordType =
            extractLabelFromLanguageMap lang result.typeLabel
    in
    row [ width fill, height fill, paddingXY 0 10 ]
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


responsePaginator : Model -> Element Msg
responsePaginator model =
    case model.response of
        Response resp ->
            let
                respPaginator =
                    resp.view
            in
            row [ width fill, height <| fillPortion 1 ]
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
            link [] { url = url, label = text "Next!" }

        Nothing ->
            none


paginatorLastLink : Maybe String -> Element Msg
paginatorLastLink lastLink =
    case lastLink of
        Just url ->
            link [] { url = url, label = text "Last!" }

        Nothing ->
            none


paginatorPreviousLink : Maybe String -> Element Msg
paginatorPreviousLink prevLink =
    case prevLink of
        Just url ->
            link [] { url = url, label = text "Previous!" }

        Nothing ->
            none


paginatorFirstLink : String -> Element Msg
paginatorFirstLink firstLink =
    link [] { url = firstLink, label = text "First" }


paginatorTotalPages : Int -> Element Msg
paginatorTotalPages pages =
    el []
        (String.fromInt pages
            |> text
        )
