module Page.Record.Views.SourcePage exposing (view)

import Element exposing (Element, alignTop, clipY, column, fill, height, none, row, width)
import Element.Background as Background
import Page.Error.Views
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Session -> RecordPageModel RecordMsg -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Loading (Just (SourceData oldData)) ->
                    viewFullSourcePage session model oldData

                Response (SourceData body) ->
                    viewFullSourcePage session model body

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
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ pageView ]
        ]
