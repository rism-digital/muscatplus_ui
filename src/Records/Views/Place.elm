module Records.Views.Place exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, px, row, width)
import Records.DataTypes exposing (Msg, PlaceBody)
import Shared.Language exposing (Language)
import UI.Components exposing (h2)


viewPlaceRecord : PlaceBody -> Language -> Element Msg
viewPlaceRecord body language =
    row
        [ width fill
        , alignTop
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
