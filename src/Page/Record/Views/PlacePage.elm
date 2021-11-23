module Page.Record.Views.PlacePage exposing (..)

import Element exposing (Element, fill, row, width)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Session exposing (Session)


view : Session -> RecordPageModel -> Element RecordMsg
view session model =
    row
        [ width fill ]
        []
