module Desktop.Record.Views exposing (..)

import Desktop.Error.Views
import Desktop.Record.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)
import Desktop.Record.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)
import Desktop.Record.Views.PlacePage.FullRecordPage exposing (viewFullPlacePage)
import Desktop.Record.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)
import Element exposing (Element, alignTop, clipY, column, fill, height, none, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.UI.Style exposing (colourScheme)
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

        PlaceData body ->
            viewFullPlacePage session model body

        _ ->
            none


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Loading (Just dataType) ->
                    viewChooser session model dataType

                Response dataType ->
                    viewChooser session model dataType

                Error _ ->
                    Desktop.Error.Views.view session model

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ pageView ]
        ]
