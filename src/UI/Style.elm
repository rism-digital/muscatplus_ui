module UI.Style exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


minMaxFillDesktop : Length
minMaxFillDesktop =
    fill |> minimum 800 |> maximum 1200


minMaxFillMobile : Length
minMaxFillMobile =
    fill |> minimum 400 |> maximum 800


bodyFont : Attribute msg
bodyFont =
    Font.family [ Font.typeface "Inter UI", Font.sansSerif ]


rismBlue : Attr decorative msg
rismBlue =
    Background.color (rgb255 27 78 125)
