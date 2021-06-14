module Page.UI.Style exposing (..)

import Element exposing (Color, Length, fill, fromRgb255, maximum, minimum, rgb255, rgba255)
import Hex


type alias RGBColour =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


colours :
    { darkBlue : RGBColour
    , lightBlue : RGBColour
    , red : RGBColour
    , lightGrey : RGBColour
    , darkGrey : RGBColour
    , midGrey : RGBColour
    , slateGrey : RGBColour
    , cream : RGBColour
    , white : RGBColour
    , black : RGBColour
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
        { red = 248
        , green = 244
        , blue = 238
        , alpha = 1
        }
    , white =
        { red = 255
        , green = 255
        , blue = 255
        , alpha = 255
        }
    , black =
        { red = 12
        , green = 16
        , blue = 21
        , alpha = 1
        }
    }


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
    { darkBlue = fromRgb255 colours.darkBlue
    , lightBlue = fromRgb255 colours.lightBlue
    , red = fromRgb255 colours.red
    , lightGrey = fromRgb255 colours.lightGrey
    , darkGrey = fromRgb255 colours.darkGrey
    , midGrey = fromRgb255 colours.midGrey
    , slateGrey = fromRgb255 colours.slateGrey
    , cream = fromRgb255 colours.cream
    , white = fromRgb255 colours.white
    , black = fromRgb255 colours.black
    }


colourToHexString : RGBColour -> String
colourToHexString colour =
    let
        values =
            [ Hex.toString colour.red
            , Hex.toString colour.green
            , Hex.toString colour.blue
            ]

        hexString =
            String.join "" values
    in
    "#" ++ hexString


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
