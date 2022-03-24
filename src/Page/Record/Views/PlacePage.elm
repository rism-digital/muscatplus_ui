module Page.Record.Views.PlacePage exposing (..)

import Element exposing (Element, alignTop, clipY, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.PlacePage.FullRecordPage exposing (viewFullPlacePage)
import Page.UI.Attributes exposing (sectionSpacing, widthFillHeightFill)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Response (PlaceData body) ->
                    viewFullPlacePage session model body

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
            , Background.color <| convertColorToElementColor colourScheme.white
            ]
            [ pageView ]
        ]
