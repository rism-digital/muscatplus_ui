module Page.Record.Views.PersonPage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)
import Page.UI.Attributes exposing (sectionSpacing, widthFillHeightFill)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Response (PersonData body) ->
                    viewFullPersonPage session.language model body

                _ ->
                    none
    in
    row
        widthFillHeightFill
        [ column
            (List.append
                [ padding sectionSpacing
                , Background.color (colourScheme.white |> convertColorToElementColor)
                ]
                widthFillHeightFill
            )
            [ pageView ]
        ]
