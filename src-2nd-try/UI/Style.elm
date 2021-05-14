module UI.Style exposing (colourScheme, desktopMaxWidth, desktopMinWidth, minMaxFillDesktop)

import Element exposing (Attribute, Color, Length, fill, maximum, minimum, rgb255)


colourScheme :
    { darkBlue : Color
    , lightBlue : Color
    , red : Color
    , lightGrey : Color
    , darkGrey : Color
    , cream : Color
    , white : Color
    , black : Color
    }
colourScheme =
    { darkBlue = rgb255 0 59 92
    , lightBlue = rgb255 0 115 181
    , red = rgb255 249 57 67
    , lightGrey = rgb255 241 244 249
    , darkGrey = rgb255 143 143 143
    , cream = rgb255 248 244 238
    , white = rgb255 255 255 255
    , black = rgb255 12 16 21
    }


desktopMaxWidth : Int
desktopMaxWidth =
    1440


desktopMinWidth : Int
desktopMinWidth =
    800


phoneMaxWidth : Int
phoneMaxWidth =
    375


minMaxFillDesktop : Length
minMaxFillDesktop =
    fill
        |> minimum desktopMinWidth
        |> maximum desktopMaxWidth
