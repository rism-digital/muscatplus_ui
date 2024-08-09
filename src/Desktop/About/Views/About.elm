module Desktop.About.Views.About exposing (view)

import Config as C
import Desktop.About.Views.AboutTexts exposing (aboutTextEnglish, aboutTextFrench, aboutTextGerman, aboutTextItalian)
import Element exposing (Element, clipY, column, el, fill, height, maximum, none, padding, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Font as Font
import Language exposing (Language(..), LanguageMap, LanguageValue(..))
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg)
import Page.UI.Attributes exposing (headingXL, lineSpacing, sectionSpacing)
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Time exposing (Month(..), Posix)


aboutText : LanguageMap
aboutText =
    [ LanguageValue English [ aboutTextEnglish ]
    , LanguageValue German [ aboutTextGerman ]
    , LanguageValue Italian [ aboutTextItalian ]
    , LanguageValue French [ aboutTextFrench ]
    ]


view : Session -> AboutPageModel -> Element AboutMsg
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

        renderedAboutText =
            Markdown.view session.language aboutText
    in
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color colourScheme.white
            , spacing sectionSpacing
            , scrollbarY
            ]
            [ row
                [ width (fill |> maximum 900)
                , Font.size 16
                ]
                [ renderedAboutText ]
            , row
                [ width (fill |> maximum 900) ]
                [ el
                    [ headingXL ]
                    (text "Current version")
                ]
            , row
                [ width fill ]
                [ column
                    [ spacing lineSpacing ]
                    [ text ("UI Version: " ++ C.uiVersion)
                    , serverVersion
                    , indexerVersion
                    , indexedTimestamp
                    ]
                ]
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
