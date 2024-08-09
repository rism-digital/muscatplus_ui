module Desktop.Record.Views.PlacePage exposing (view)

import Desktop.Error.Views
import Desktop.Record.Views.PlacePage.FullRecordPage exposing (viewFullPlacePage)
import Element exposing (Element, alignTop, clipY, column, fill, height, none, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Response (PlaceData body) ->
                    viewFullPlacePage session model body

                Error _ ->
                    Desktop.Error.Views.view session model

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
