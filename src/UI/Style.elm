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


{-|

    https://coolors.co/445e93-7eb2dd-f93943-fcb0b3-fcecc9-f1f4f9

-}
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


darkGrey : Color
darkGrey =
    rgb255 143 143 143


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


borderBottom : List (Attribute msg)
borderBottom =
    [ Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
    , Border.color red
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



-- Based on the 'Major Third' scales given at https://type-scale.com/


fontBaseSize : Attr decorative msg
fontBaseSize =
    Font.size 16


headingXXL : Attr decorative msg
headingXXL =
    Font.size 49


headingXL : Attr decorative msg
headingXL =
    Font.size 39


headingLG : Attr decorative msg
headingLG =
    Font.size 31


headingMD : Attr decorative msg
headingMD =
    Font.size 25


headingSM : Attr decorative msg
headingSM =
    Font.size 20


headingXS : Attr decorative msg
headingXS =
    Font.size 16


bodyRegular : Attr decorative msg
bodyRegular =
    fontBaseSize


bodySM : Attr decorative msg
bodySM =
    Font.size 13


bodyXS : Attr decorative msg
bodyXS =
    Font.size 10


bodyXXS : Attr decorative msg
bodyXXS =
    Font.size 8
