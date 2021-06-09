module Page.UI.Style exposing (..)

import Element exposing (Color, Length, fill, maximum, minimum, rgb255, rgba255)


colourScheme :
    { darkBlue : Color
    , lightBlue : Color
    , red : Color
    , lightGrey : Color
    , darkGrey : Color
    , midGrey : Color
    , slateGrey : Color
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
    , midGrey = rgb255 170 170 170
    , slateGrey = rgb255 119 136 153
    , cream = rgb255 248 244 238
    , white = rgb255 255 255 255
    , black = rgb255 12 16 21
    }


translucentBlue : Color
translucentBlue =
    rgba255 0 59 92 0.6


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


footerHeight : Int
footerHeight =
    70


headerHeight : Int
headerHeight =
    60


searchHeaderHeight : Int
searchHeaderHeight =
    120
