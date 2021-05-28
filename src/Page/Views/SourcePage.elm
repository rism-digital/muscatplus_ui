module Page.Views.SourcePage exposing (..)

import Element exposing (Element, fill, height, none, row, width)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Element Msg
view model =
    row
        [ width fill
        , height fill
        ]
        []
