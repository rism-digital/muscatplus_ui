module Mobile.Record.Views.PersonPage exposing (view)

import Element exposing (Element, none)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Session exposing (Session)


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    none
