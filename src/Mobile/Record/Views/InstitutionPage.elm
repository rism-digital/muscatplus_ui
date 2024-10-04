module Mobile.Record.Views.InstitutionPage exposing (viewFullMobileInstitutionPage)

import Element exposing (Element, none)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Session exposing (Session)


viewFullMobileInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullMobileInstitutionPage _ _ _ =
    none
