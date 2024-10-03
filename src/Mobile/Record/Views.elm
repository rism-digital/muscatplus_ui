module Mobile.Record.Views exposing (..)

import Element exposing (Element, alignTop, clipY, column, fill, height, none, row, width)
import Element.Background as Background
import Mobile.Error.Views
import Mobile.Record.Views.PersonPage.FullRecordPage exposing (viewFullMobilePersonPage)
import Mobile.Record.Views.SourcePage.FullRecordPage exposing (viewFullMobileSourcePage)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.UI.Style exposing (colourScheme)
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
            none

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
                    Mobile.Error.Views.view session model

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
