module Page.Views.SearchPage.Pagination exposing (..)

import Element exposing (Element, alignBottom, el, fill, link, none, row, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Search exposing (SearchPagination)


viewSearchResultsPagination : SearchPagination -> Language -> Element Msg
viewSearchResultsPagination pagination language =
    row
        [ width fill
        , alignBottom
        ]
        [ viewPaginationFirstLink (Just pagination.first) language
        , viewPaginationPreviousLink pagination.previous language
        , pageInfo pagination language
        , viewPaginationNextLink pagination.next language
        , viewPaginationLastLink pagination.last language
        ]


pageInfo : SearchPagination -> Language -> Element Msg
pageInfo pagination language =
    let
        thisPage =
            String.fromInt pagination.thisPage

        totalPages =
            String.fromInt pagination.totalPages

        label =
            extractLabelFromLanguageMap language localTranslations.page
    in
    el
        []
        (text (label ++ " " ++ thisPage ++ " / " ++ totalPages))


viewPaginationLink : Maybe String -> String -> Element Msg
viewPaginationLink url linkText =
    Maybe.map (\l -> el [] (link [] { url = l, label = text linkText })) url
        |> Maybe.withDefault none


viewPaginationNextLink : Maybe String -> Language -> Element Msg
viewPaginationNextLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.next
    in
    viewPaginationLink url label


viewPaginationLastLink : Maybe String -> Language -> Element Msg
viewPaginationLastLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.last
    in
    viewPaginationLink url label


viewPaginationPreviousLink : Maybe String -> Language -> Element Msg
viewPaginationPreviousLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.previous
    in
    viewPaginationLink url label


viewPaginationFirstLink : Maybe String -> Language -> Element Msg
viewPaginationFirstLink url language =
    let
        label =
            extractLabelFromLanguageMap language localTranslations.first
    in
    viewPaginationLink url label
