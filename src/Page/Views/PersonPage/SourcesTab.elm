module Page.Views.PersonPage.SourcesTab exposing (..)

import Element exposing (Element, none)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Response exposing (ServerData(..))
import Page.Views.SearchPage exposing (viewSearchResultsListSection)


viewPersonSourcesTab : Language -> Response -> Element Msg
viewPersonSourcesTab language searchData =
    let
        resultsView =
            case searchData of
                Response (SearchData body) ->
                    viewSearchResultsListSection language body

                _ ->
                    none
    in
    resultsView
