module Page.Views.PersonPage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Response exposing (ServerData(..))
import Page.UI.Style exposing (colourScheme)
import Page.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)


view : Model -> Element Msg
view model =
    let
        page =
            model.page

        response =
            page.response

        currentTab =
            page.currentTab

        pageView =
            case response of
                Loading ->
                    none

                Response (PersonData body) ->
                    viewFullPersonPage currentTab model.language body

                Error _ ->
                    -- TODO: Show error page
                    none

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color colourScheme.white
            ]
            [ pageView ]
        ]
