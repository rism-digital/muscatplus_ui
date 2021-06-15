module Page.Views.PersonPage.SourcesTab exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, row, spacing, width)
import Language exposing (Language)
import Msg exposing (Msg(..))
import Page.Model exposing (Response(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchPagination, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.Views.Pagination exposing (viewRecordSourceResultsPagination)
import Page.Views.SearchPage.Results exposing (viewSearchResult)


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
            , viewRecordSourceResultsPagination language body.pagination
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
            (List.map (\result -> viewSearchResult language Nothing result) body.items)
        ]
