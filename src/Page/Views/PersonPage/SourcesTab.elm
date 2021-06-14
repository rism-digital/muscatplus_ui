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
import Page.Views.Pagination exposing (viewRecordSourceResultsPagination)
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
            (List.map (\result -> viewSearchResult language result) body.items)
        ]
