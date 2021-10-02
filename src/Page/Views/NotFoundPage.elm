module Page.Views.NotFoundPage exposing (..)

import Element exposing (Element, column, fill, height, padding, row, text, width)
import Element.Background as Background
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


view : Model -> Element Msg
view model =
    let
        page =
            model.page

        resp =
            page.response

        message =
            case resp of
                Error msg ->
                    msg

                _ ->
                    "Unknown error"
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
            [ text message ]
        ]
