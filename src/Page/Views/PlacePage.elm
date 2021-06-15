module Page.Views.PlacePage exposing (..)

import Element exposing (Element, fill, row, width)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Element Msg
view model =
    row
        [ width fill ]
        []
