module Desktop.Record.PublicationListPage exposing (viewPublicationListPage)

import Element exposing (Element, el, text)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.PublicationList exposing (PublicationListBody)
import Session exposing (Session)


viewPublicationListPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationListBody
    -> Element RecordMsg
viewPublicationListPage session model body =
    el [] (text "Publication list page")
