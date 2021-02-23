module UI.Style exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


desktopMaxWidth : Int
desktopMaxWidth =
    1440


desktopMinWidth : Int
desktopMinWidth =
    800


phoneMaxWidth : Int
phoneMaxWidth =
    375


darkBlue : Color
darkBlue =
    rgb255 68 94 147


lightBlue : Color
lightBlue =
    rgb255 126 178 221


red : Color
red =
    rgb255 249 57 67


pink : Color
pink =
    rgb255 252 176 179


lightYellow : Color
lightYellow =
    rgb255 252 236 201


lightGrey : Color
lightGrey =
    rgb255 241 244 249


roundedBorder : Attribute msg
roundedBorder =
    Border.rounded 5


roundedButton : List (Attribute msg)
roundedButton =
    [ Border.width 1
    , roundedBorder
    , Border.color darkBlue
    , paddingXY 10 10
    ]


minMaxFillDesktop : Length
minMaxFillDesktop =
    fill |> minimum 800 |> maximum 1200


minMaxFillMobile : Length
minMaxFillMobile =
    fill |> minimum 400 |> maximum 800


bodyFont : Attribute msg
bodyFont =
    Font.family [ Font.typeface "Inter UI", Font.sansSerif ]


blueBackground : Attr decorative msg
blueBackground =
    Background.color darkBlue


greyBackground : Attr decorative msg
greyBackground =
    Background.color lightGrey


headingXXL : Attr decorative msg
headingXXL =
    Font.size 64


headingXL : Attr decorative msg
headingXL =
    Font.size 56


headingLG : Attr decorative msg
headingLG =
    Font.size 48


headingMD : Attr decorative msg
headingMD =
    Font.size 40


headingSM : Attr decorative msg
headingSM =
    Font.size 32


headingXS : Attr decorative msg
headingXS =
    Font.size 24
