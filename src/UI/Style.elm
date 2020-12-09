module UI.Style exposing (..)

import Element exposing (..)
import Element.Font as Font


heading : List (Attribute msg)
heading =
    [ Font.family
        [ Font.typeface "Roboto Slab"
        , Font.sansSerif
        ]
    , Font.size 24
    , paddingEach
        { top = 0
        , right = 0
        , bottom = 20
        , left = 0
        }
    ]
