module Page.Views.PersonPage.SourcesTab exposing (..)

import Element exposing (Element, alignBottom, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, maximum, minimum, none, padding, px, row, shrink, spacing, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchPagination, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.SearchPage exposing (viewSearchResult)


viewPersonSourcesTab : Language -> Response -> Element Msg
viewPersonSourcesTab language searchData =
    let
        resultsView =
            case searchData of
                Response (SearchData body) ->
                    viewPersonSourceResultsSection language body

                _ ->
                    none
    in
    resultsView


viewPersonSourceResultsSection : Language -> SearchBody -> Element Msg
viewPersonSourceResultsSection language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewPersonSourceResultsList language body
            , viewPersonSourceResultsPagination language body.pagination
            ]
        ]


viewPersonSourceResultsList : Language -> SearchBody -> Element Msg
viewPersonSourceResultsList language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 40
            ]
            (List.map (\result -> viewSearchResult language result) body.items)
        ]


viewPersonSourceResultsPagination : Language -> SearchPagination -> Element Msg
viewPersonSourceResultsPagination language pagination =
    let
        firstLabel =
            extractLabelFromLanguageMap language localTranslations.first

        previousLabel =
            extractLabelFromLanguageMap language localTranslations.previous

        nextLabel =
            extractLabelFromLanguageMap language localTranslations.next

        lastLabel =
            extractLabelFromLanguageMap language localTranslations.last

        thisPage =
            formatNumberByLanguage (toFloat pagination.thisPage) language

        totalPages =
            formatNumberByLanguage (toFloat pagination.totalPages) language

        pageLabel =
            extractLabelFromLanguageMap language localTranslations.page

        pageInfo =
            pageLabel ++ " " ++ thisPage ++ " / " ++ totalPages
    in
    row
        [ width fill
        , alignBottom
        ]
        [ column
            [ alignLeft
            , width fill
            ]
            [ row
                [ width shrink
                , alignLeft
                ]
                [ viewMaybe (paginationLink chevronDoubleLeftSvg firstLabel) (Just pagination.first)
                , viewMaybe (paginationLink chevronLeftSvg previousLabel) pagination.previous
                ]
            ]
        , column
            [ centerX
            , width fill
            ]
            [ row
                [ width shrink
                , height shrink
                , centerX
                , centerY
                ]
                [ el
                    [ Font.medium ]
                    (text pageInfo)
                ]
            ]
        , column
            [ alignRight
            , width fill
            ]
            [ row
                [ width shrink
                , alignRight
                ]
                [ viewMaybe (paginationLink chevronRightSvg nextLabel) pagination.next
                , viewMaybe (paginationLink chevronDoubleRightSvg lastLabel) pagination.last
                ]
            ]
        ]


paginationLink : Element Msg -> String -> String -> Element Msg
paginationLink icon iconLabel url =
    el
        [ padding 5
        , height (px 20)
        , width (px 20)
        , onClick (UserClickedRecordViewTabPagination url)
        ]
        icon
