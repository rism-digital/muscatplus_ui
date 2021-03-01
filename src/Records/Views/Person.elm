module Records.Views.Person exposing (..)

import Api.Records exposing (PersonBody)
import Element exposing (Element, alignTop, centerY, column, el, fill, fillPortion, height, paddingEach, paddingXY, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Msg)


viewPersonRecord : PersonBody -> Language -> Element Msg
viewPersonRecord body language =
    column [ alignTop, width fill, height fill ]
        [ row [ width fill, height (fillPortion 2), centerY, Border.color (rgb255 193 125 65), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ centerY, Font.size 24, Font.semiBold ] (text (extractLabelFromLanguageMap language body.label))
            ]
        , row [ width fill, height (fillPortion 1), centerY, Border.color (rgb255 255 198 110), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Biographical Details")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Sources")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Secondary Literature")
            ]
        , row [ width fill, height (fillPortion 13), alignTop, paddingEach { bottom = 0, left = 0, right = 0, top = 20 } ]
            [ column []
                [ row [] []
                , row [] []
                ]
            ]
        ]
