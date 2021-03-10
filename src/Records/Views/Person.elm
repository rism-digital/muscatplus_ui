module Records.Views.Person exposing (..)

import Api.Records exposing (PersonBody)
import Element exposing (Element, alignTop, centerY, column, el, fill, fillPortion, height, paddingEach, paddingXY, px, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Msg)
import UI.Components exposing (h2)


viewPersonRecord : PersonBody -> Language -> Element Msg
viewPersonRecord body language =
    row
        [ alignTop
        , width fill
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , height (px 120)
                ]
                [ h2 language body.label ]
            ]
        ]
