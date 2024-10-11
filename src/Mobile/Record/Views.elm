module Mobile.Record.Views exposing (view)

import Element exposing (Element, none)
import Mobile.Error.Views
import Mobile.Record.InstitutionPage exposing (viewFullMobileInstitutionPage)
import Mobile.Record.PersonPage exposing (viewFullMobilePersonPage)
import Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewChooser : Session -> RecordPageModel RecordMsg -> ServerData -> Element RecordMsg
viewChooser session model dataType =
    case dataType of
        SourceData body ->
            viewFullMobileSourcePage session model body

        PersonData body ->
            viewFullMobilePersonPage session model body

        InstitutionData body ->
            viewFullMobileInstitutionPage session model body

        _ ->
            none


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    case model.response of
        Loading (Just dataType) ->
            viewChooser session model dataType

        Response dataType ->
            viewChooser session model dataType

        Error _ ->
            Mobile.Error.Views.view session model

        _ ->
            none
