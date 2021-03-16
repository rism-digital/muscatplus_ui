module Search.Views exposing (viewSearchBody)

import Api.Search exposing (ApiResponse(..), SearchPagination, SearchQueryArgs, SearchResult)
import Element exposing (..)
import Element.Input as Input
import Html
import Html.Attributes
import Language exposing (Language, extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations)
import Search.DataTypes exposing (Model, Msg(..), Route(..))
import UI.Components exposing (h4)
import UI.Layout exposing (layoutBody)
import UI.Style as Style exposing (greyBackground, minMaxFillDesktop, minMaxFillMobile, roundedBorder, roundedButton)


viewSearchDesktop : Model -> Element Msg
viewSearchDesktop model =
    case model.currentRoute of
        FrontPageRoute ->
            viewSearchFrontDesktop model

        SearchPageRoute _ ->
            viewSearchResultsDesktop model

        NotFound ->
            viewNotFound


viewNotFound : Element Msg
viewNotFound =
    row [] [ text "Route not found" ]


viewSearchFrontDesktop : Model -> Element Msg
viewSearchFrontDesktop model =
    row
        [ width fill
        , height fill
        , centerX
        , centerY
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , centerY
            ]
            [ row
                [ width fill
                , height (px 60)
                , centerX
                , centerY
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    , centerY
                    ]
                    [ row
                        [ width fill
                        , height fill
                        , centerX
                        , centerY
                        ]
                        [ text "Search RISM Online" ]
                    ]
                ]
            , row
                [ width fill
                , height (px 120)
                , greyBackground
                , centerX
                , centerY
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    ]
                    [ viewSearchKeywordInput model ]
                ]
            ]
        ]


viewSearchKeywordInput : Model -> Element Msg
viewSearchKeywordInput model =
    let
        queryObj =
            model.query

        qText =
            Maybe.withDefault "" queryObj.query

        currentLanguage =
            model.language
    in
    row
        [ centerX
        , height shrink
        , width
            (fill
                |> maximum Style.desktopMaxWidth
                |> minimum Style.desktopMinWidth
            )
        ]
        [ column
            [ width (fillPortion 10)
            , height shrink
            ]
            [ Input.text
                [ width fill
                , height shrink
                , spacingXY 0 4
                , roundedBorder
                , htmlAttribute (Html.Attributes.autocomplete False)
                ]
                { onChange = \inp -> SearchInput inp
                , placeholder = Just (Input.placeholder [] (text "Enter your query"))
                , text = qText
                , label = Input.labelHidden (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        , column
            [ width (fillPortion 2) ]
            [ Input.button (List.concat [ roundedButton, [] ])
                { onPress = Just SearchSubmit
                , label = text (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        ]


viewSearchResultsDesktop : Model -> Element Msg
viewSearchResultsDesktop model =
    let
        language =
            model.language
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            ]
            [ row
                [ width fill
                , height (px 120)
                , greyBackground
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    ]
                    [ viewSearchKeywordInput model ]
                ]
            , row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width minMaxFillDesktop
                    , height fill
                    , centerX
                    , alignTop
                    ]
                    [ row
                        [ width fill
                        , alignTop
                        , paddingXY 0 20
                        ]
                        [ column
                            [ width (fillPortion 3)
                            , alignTop
                            ]
                            [ text "Sidebar" ]
                        , column
                            [ width (fillPortion 9) ]
                            [ viewResultList model language ]
                        ]
                    ]
                ]
            ]
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


viewSearchContentMobile : Model -> Element Msg
viewSearchContentMobile model =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width minMaxFillMobile
            , height fill
            , centerX
            ]
            [ row
                [ width fill
                , height (px 60)
                ]
                [ text "Search Top mobile!" ]
            ]
        ]


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


viewSearchBody : Model -> List (Html.Html Msg)
viewSearchBody model =
    let
        device =
            model.viewingDevice

        deviceView =
            case device.class of
                Phone ->
                    viewSearchContentMobile

                _ ->
                    viewSearchDesktop

        message =
            LanguageSelectChanged

        langOptions =
            languageOptionsForDisplay

        currentLanguage =
            model.language
    in
    layoutBody message langOptions (deviceView model) device currentLanguage


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
