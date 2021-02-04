module UI.Style exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


renderTopBar : Element msg
renderTopBar =
    row [ width fill, height (fillPortion 1), rismBlue ]
        [ column [ width minMaxFill, height fill, centerX ]
            [ row [ width fill, height fill, Font.color (rgb255 255 255 255), Font.semiBold ] [ text "RISM Online" ]
            ]
        ]


minMaxFill : Length
minMaxFill =
    fill |> minimum 800 |> maximum 1200


bodyFont : Attribute msg
bodyFont =
    Font.family [ Font.typeface "Inter UI", Font.sansSerif ]


rismBlue : Attr decorative msg
rismBlue =
    Background.color (rgb255 27 78 125)
