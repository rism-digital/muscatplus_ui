module Page.Views.SearchPage.Pagination exposing (..)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, link, none, padding, px, row, shrink, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Search exposing (SearchPagination)
import Page.UI.Images exposing (chevronDoubleLeftSvg, chevronDoubleRightSvg, chevronLeftSvg, chevronRightSvg)
import Page.UI.Style exposing (colourScheme, colours)


viewSearchResultsPagination : Language -> SearchPagination -> Element Msg
viewSearchResultsPagination language pagination =
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
                [ viewPaginationFirstLink (Just pagination.first) language
                , viewPaginationPreviousLink pagination.previous language
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
                [ pageInfo pagination language ]
            ]
        , column
            [ alignRight
            , width fill
            ]
            [ row
                [ width shrink
                , alignRight
                ]
                [ viewPaginationNextLink pagination.next language
                , viewPaginationLastLink pagination.last language
                ]
            ]
        ]


pageInfo : SearchPagination -> Language -> Element Msg
pageInfo pagination language =
    let
        thisPage =
            formatNumberByLanguage (toFloat pagination.thisPage) language

        totalPages =
            formatNumberByLanguage (toFloat pagination.totalPages) language

        label =
            extractLabelFromLanguageMap language localTranslations.page
    in
    el
        [ Font.medium ]
        (text (label ++ " " ++ thisPage ++ " / " ++ totalPages))


{-|

    Maybe.map handles the case where the URL is `Nothing` and returns
    the empty element `none`. So if there is a URL, this will return a
    formatted pagination element; if there isn't, it will return an
    empty element.

-}
viewPaginationLink : Element Msg -> Maybe String -> String -> Element Msg
viewPaginationLink icon url linkText =
    Maybe.map (\l -> formatPaginationLink icon l linkText) url
        |> Maybe.withDefault none


formatPaginationLink : Element Msg -> String -> String -> Element Msg
formatPaginationLink icon url linkText =
    el
        [ padding 5
        ]
        (link
            [ height (px 20)
            , width (px 20)
            ]
            { url = url
            , label = icon
            }
        )


viewPaginationNextLink : Maybe String -> Language -> Element Msg
viewPaginationNextLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.next
    in
    viewPaginationLink (chevronRightSvg colourScheme.slateGrey) url label


viewPaginationLastLink : Maybe String -> Language -> Element Msg
viewPaginationLastLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.last
    in
    viewPaginationLink (chevronDoubleRightSvg colourScheme.slateGrey) url label


viewPaginationPreviousLink : Maybe String -> Language -> Element Msg
viewPaginationPreviousLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.previous
    in
    viewPaginationLink (chevronLeftSvg colourScheme.slateGrey) url label


viewPaginationFirstLink : Maybe String -> Language -> Element Msg
viewPaginationFirstLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.first
    in
    viewPaginationLink (chevronDoubleLeftSvg colourScheme.slateGrey) url label
