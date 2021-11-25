module Page.Record.Views.SourcePage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)
import Page.UI.Attributes exposing (sectionSpacing, widthFillHeightFill)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Response (SourceData body) ->
                    viewFullSourcePage session.language body

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
