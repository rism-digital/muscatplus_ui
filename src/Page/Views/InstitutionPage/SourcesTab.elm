module Page.Views.InstitutionPage.SourcesTab exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, row, spacing, width)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Response exposing (ServerData(..))
import Page.Views.Pagination exposing (viewRecordSourceResultsPagination)
import Page.Views.SearchPage.Results exposing (viewSearchResult)


viewInstitutionSourcesTab : Language -> Response -> Element Msg
viewInstitutionSourcesTab language searchData =
    let
        resultsView =
            case searchData of
                Response (SearchData body) ->
                    viewInstitutionSourceResultsSection language body

                _ ->
                    none
    in
    resultsView


viewInstitutionSourceResultsSection : Language -> SearchBody -> Element Msg
viewInstitutionSourceResultsSection language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ viewInstitutionSourceResultsList language body
            , viewRecordSourceResultsPagination language body.pagination
            ]
        ]


viewInstitutionSourceResultsList : Language -> SearchBody -> Element Msg
viewInstitutionSourceResultsList language body =
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
