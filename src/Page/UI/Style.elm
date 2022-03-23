module Page.UI.Style exposing (..)

import Color exposing (Color, rgba)
import Element exposing (Length, fill, maximum, minimum)


type alias RGBA =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


colours :
    { darkBlue : RGBA
    , lightBlue : RGBA
    , red : RGBA
    , darkOrange : RGBA
    , lightOrange : RGBA
    , yellow : RGBA
    , lightGreen : RGBA
    , turquoise : RGBA
    , lightGrey : RGBA
    , darkGrey : RGBA
    , midGrey : RGBA
    , slateGrey : RGBA
    , cream : RGBA
    , white : RGBA
    , black : RGBA
    , translucentGrey : RGBA
    }
colours =
    { darkBlue =
        { red = 0
        , green = 59
        , blue = 92
        , alpha = 1
        }
    , lightBlue =
        { red = 0
        , green = 115
        , blue = 181
        , alpha = 1
        }
    , red =
        { red = 249
        , green = 57
        , blue = 67
        , alpha = 1
        }
    , darkOrange =
        { red = 243
        , green = 114
        , blue = 44
        , alpha = 1
        }
    , lightOrange =
        { red = 248
        , green = 150
        , blue = 30
        , alpha = 1
        }
    , yellow =
        { red = 249
        , green = 199
        , blue = 79
        , alpha = 1
        }
    , lightGreen =
        { red = 144
        , green = 190
        , blue = 109
        , alpha = 1
        }
    , turquoise =
        { red = 67
        , green = 170
        , blue = 139
        , alpha = 1
        }
    , lightGrey =
        { red = 241
        , green = 244
        , blue = 249
        , alpha = 1
        }
    , darkGrey =
        { red = 143
        , green = 143
        , blue = 143
        , alpha = 1
        }
    , midGrey =
        { red = 170
        , green = 170
        , blue = 170
        , alpha = 1
        }
    , slateGrey =
        { red = 119
        , green = 136
        , blue = 153
        , alpha = 1
        }
    , cream =
        { red = 252
        , green = 250
        , blue = 248
        , alpha = 1
        }
    , white =
        { red = 255
        , green = 255
        , blue = 255
        , alpha = 255
        }
    , black =
        { red = 34
        , green = 38
        , blue = 42
        , alpha = 1
        }
    , translucentGrey =
        { red = 119
        , green = 136
        , blue = 153
        , alpha = 0.5
        }
    }


colourScheme :
    { darkBlue : Color
    , lightBlue : Color
    , red : Color
    , darkOrange : Color
    , lightOrange : Color
    , yellow : Color
    , lightGreen : Color
    , turquoise : Color
    , lightGrey : Color
    , darkGrey : Color
    , midGrey : Color
    , slateGrey : Color
    , cream : Color
    , white : Color
    , black : Color
    , translucentGrey : Color
    }
colourScheme =
    { darkBlue = convertRGBAToColor colours.darkBlue
    , lightBlue = convertRGBAToColor colours.lightBlue
    , red = convertRGBAToColor colours.red
    , darkOrange = convertRGBAToColor colours.darkOrange
    , lightOrange = convertRGBAToColor colours.lightOrange
    , yellow = convertRGBAToColor colours.yellow
    , lightGreen = convertRGBAToColor colours.lightGreen
    , turquoise = convertRGBAToColor colours.turquoise
    , lightGrey = convertRGBAToColor colours.lightGrey
    , darkGrey = convertRGBAToColor colours.darkGrey
    , midGrey = convertRGBAToColor colours.midGrey
    , slateGrey = convertRGBAToColor colours.slateGrey
    , cream = convertRGBAToColor colours.cream
    , white = convertRGBAToColor colours.white
    , black = convertRGBAToColor colours.black
    , translucentGrey = convertRGBAToColor colours.translucentGrey
    }


{-| Converts a RGBA of Integers to a Color value.
-}
scaleFrom255 : Int -> Float
scaleFrom255 c =
    toFloat c / 255


convertRGBAToColor : RGBA -> Color
convertRGBAToColor { red, green, blue, alpha } =
    rgba (scaleFrom255 red) (scaleFrom255 green) (scaleFrom255 blue) alpha


convertColorToElementColor : Color -> Element.Color
convertColorToElementColor color =
    Color.toRgba color
        |> Element.fromRgb


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
    80
