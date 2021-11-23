module Page.NotFound.Views exposing (view)

import Element exposing (Element, column, fill, height, padding, row, text, width)
import Element.Background as Background
import Page.NotFound.Model exposing (NotFoundPageModel)
import Response exposing (Response(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


view : Session -> NotFoundPageModel -> Element msg
view session model =
    let
        pageView =
            case model.response of
                Error msg ->
                    text msg

                _ ->
                    text "Unknown error"
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
