module Page.Views.SourcePage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Response exposing (ServerData(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)


view : Model -> Element Msg
view model =
    let
        page =
            model.page

        response =
            page.response

        pageView =
            case response of
                Loading _ ->
                    -- TODO: Show source loading page
                    none

                Response (SourceData body) ->
                    viewFullSourcePage body model.language

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
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ pageView ]
        ]
