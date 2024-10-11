module Desktop.Record.Views exposing (view)

import Desktop.Error.Views
import Desktop.Record.InstitutionPage exposing (viewFullInstitutionPage)
import Desktop.Record.PersonPage exposing (viewFullPersonPage)
import Desktop.Record.SourcePage exposing (viewFullSourcePage)
import Element exposing (Element, none)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewChooser : Session -> RecordPageModel RecordMsg -> ServerData -> Element RecordMsg
viewChooser session model dataType =
    case dataType of
        SourceData body ->
            viewFullSourcePage session model body

        PersonData body ->
            viewFullPersonPage session model body

        InstitutionData body ->
            viewFullInstitutionPage session model body

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
            Desktop.Error.Views.view session model

        _ ->
            none
