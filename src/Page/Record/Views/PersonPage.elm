module Page.Record.Views.PersonPage exposing (view)

import Element exposing (Element, alignTop, clipY, column, fill, height, none, row, width)
import Element.Background as Background
import Page.Error.Views
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Loading (Just (PersonData oldData)) ->
                    viewFullPersonPage session model oldData

                Response (PersonData body) ->
                    viewFullPersonPage session model body

                Error _ ->
                    Page.Error.Views.view session model

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        , alignTop
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
