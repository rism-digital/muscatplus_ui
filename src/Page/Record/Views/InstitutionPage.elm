module Page.Record.Views.InstitutionPage exposing (..)

import Element exposing (Element, column, fill, height, none, padding, row, width)
import Element.Background as Background
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Response exposing (Response(..), ServerData(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Record.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)
import Session exposing (Session)


view : Session -> RecordPageModel -> Element RecordMsg
view session model =
    let
        pageView =
            case model.response of
                Response (InstitutionData body) ->
                    viewFullInstitutionPage session.language model body

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
            , padding 20
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ pageView ]
        ]
