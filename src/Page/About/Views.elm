module Page.About.Views exposing (view)

import Config as C
import Element exposing (Element, column, fill, height, none, padding, row, spacing, text, width)
import Element.Background as Background
import Page.About.Model exposing (AboutPageModel)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Time exposing (Month(..), Posix)


view : Session -> AboutPageModel -> Element msg
view session model =
    let
        indexedTimestamp =
            case model.response of
                Response (AboutData body) ->
                    viewLastIndexed body.lastIndexed

                _ ->
                    none

        indexerVersion =
            case model.response of
                Response (AboutData body) ->
                    text ("Indexer Version: " ++ body.indexerVersion)

                _ ->
                    none

        serverVersion =
            case model.response of
                Response (AboutData body) ->
                    text ("Server Version: " ++ body.serverVersion)

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
            , spacing lineSpacing
            ]
            [ text ("UI Version: " ++ C.uiVersion)
            , serverVersion
            , indexerVersion
            , indexedTimestamp
            ]
        ]


viewLastIndexed : Posix -> Element msg
viewLastIndexed timestamp =
    let
        day =
            Time.toDay Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        hour =
            Time.toHour Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        minute =
            Time.toMinute Time.utc timestamp
                |> String.fromInt
                |> String.padLeft 2 '0'

        month =
            case Time.toMonth Time.utc timestamp of
                Jan ->
                    "01"

                Feb ->
                    "02"

                Mar ->
                    "03"

                Apr ->
                    "04"

                May ->
                    "05"

                Jun ->
                    "06"

                Jul ->
                    "07"

                Aug ->
                    "08"

                Sep ->
                    "09"

                Oct ->
                    "10"

                Nov ->
                    "11"

                Dec ->
                    "12"

        year =
            String.fromInt (Time.toYear Time.utc timestamp)
    in
    text ("Last indexed: " ++ year ++ "-" ++ month ++ "-" ++ day ++ " " ++ hour ++ ":" ++ minute)
