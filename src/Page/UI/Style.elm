module Page.UI.Style exposing
    ( colourScheme
    , headerHeight
    , rgbaFloatToInt
    , searchHeaderHeight
    )

import Element


type alias RGBA =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }



--colourScheme :
--    { black : Element.Color
--    , cream : Element.Color
--    , darkBlue : Element.Color
--    , darkGrey : Element.Color
--    , darkOrange : Element.Color
--    , lightBlue : Element.Color
--    , lightGreen : Element.Color
--    , lightGrey : Element.Color
--    , lightOrange : Element.Color
--    , midGrey : Element.Color
--    , red : Element.Color
--    , slateGrey : Element.Color
--    , translucentBlack : Element.Color
--    , translucentGrey : Element.Color
--    , turquoise : Element.Color
--    , white : Element.Color
--    , yellow : Element.Color
--    }
--colourScheme =
--    { black = convertRGBAToColor colours.black
--    , cream = convertRGBAToColor colours.cream
--    , darkBlue = convertRGBAToColor colours.darkBlue
--    , darkGrey = convertRGBAToColor colours.darkGrey
--    , darkOrange = convertRGBAToColor colours.darkOrange
--    , lightBlue = convertRGBAToColor colours.lightBlue
--    , lightGreen = convertRGBAToColor colours.lightGreen
--    , lightGrey = convertRGBAToColor colours.lightGrey
--    , lightOrange = convertRGBAToColor colours.lightOrange
--    , midGrey = convertRGBAToColor colours.midGrey
--    , red = convertRGBAToColor colours.red
--    , slateGrey = convertRGBAToColor colours.slateGrey
--    , translucentBlack = convertRGBAToColor colours.translucentBlack
--    , translucentGrey = convertRGBAToColor colours.translucentGrey
--    , turquoise = convertRGBAToColor colours.turquoise
--    , white = convertRGBAToColor colours.white
--    , yellow = convertRGBAToColor colours.yellow
--    }


colourScheme :
    { black : Element.Color
    , cream : Element.Color
    , darkBlue : Element.Color
    , darkGrey : Element.Color
    , darkOrange : Element.Color
    , lightBlue : Element.Color
    , lightGreen : Element.Color
    , lightGrey : Element.Color
    , lightOrange : Element.Color
    , midGrey : Element.Color
    , red : Element.Color
    , slateGrey : Element.Color
    , translucentBlack : Element.Color
    , translucentGrey : Element.Color
    , turquoise : Element.Color
    , white : Element.Color
    , yellow : Element.Color
    }
colourScheme =
    { black =
        Element.fromRgb255
            { red = 34
            , green = 38
            , blue = 42
            , alpha = 1
            }
    , cream =
        Element.fromRgb255
            { red = 252
            , green = 250
            , blue = 248
            , alpha = 1
            }
    , darkBlue =
        Element.fromRgb255
            { red = 0
            , green = 59
            , blue = 92
            , alpha = 1
            }
    , darkGrey =
        Element.fromRgb255
            { red = 143
            , green = 143
            , blue = 143
            , alpha = 1
            }
    , darkOrange =
        Element.fromRgb255
            { red = 243
            , green = 114
            , blue = 44
            , alpha = 1
            }
    , lightBlue =
        Element.fromRgb255
            { red = 0
            , green = 115
            , blue = 181
            , alpha = 1
            }
    , lightGreen =
        Element.fromRgb255
            { red = 144
            , green = 190
            , blue = 109
            , alpha = 1
            }
    , lightGrey =
        Element.fromRgb255
            { red = 241
            , green = 244
            , blue = 249
            , alpha = 1
            }
    , lightOrange =
        Element.fromRgb255
            { red = 248
            , green = 150
            , blue = 30
            , alpha = 1
            }
    , midGrey =
        Element.fromRgb255
            { red = 170
            , green = 170
            , blue = 170
            , alpha = 1
            }
    , red =
        Element.fromRgb255
            { red = 249
            , green = 57
            , blue = 67
            , alpha = 1
            }

    --, slateGrey =
    --    { red = 119
    --    , green = 136
    --    , blue = 153
    --    , alpha = 1
    --    }
    , slateGrey =
        Element.fromRgb255
            { red = 170
            , green = 170
            , blue = 170
            , alpha = 1
            }
    , translucentBlack =
        Element.fromRgb255
            { red = 34
            , green = 38
            , blue = 42
            , alpha = 0.8
            }
    , translucentGrey =
        Element.fromRgb255
            { red = 119
            , green = 136
            , blue = 153
            , alpha = 0.5
            }
    , turquoise =
        Element.fromRgb255
            { red = 67
            , green = 170
            , blue = 139
            , alpha = 1
            }
    , white =
        Element.fromRgb255
            { red = 250
            , green = 252
            , blue = 255
            , alpha = 255
            }
    , yellow =
        Element.fromRgb255
            { red = 249
            , green = 199
            , blue = 79
            , alpha = 1
            }
    }


{-| Converts a RGBA of Integers to a Color value.
-}
rgbaFloatToInt : Element.Color -> { red : Int, green : Int, blue : Int, alpha : Float }
rgbaFloatToInt colour =
    let
        { red, green, blue, alpha } =
            Element.toRgb colour
    in
    { red = round (red * 255)
    , green = round (green * 255)
    , blue = round (blue * 255)
    , alpha = alpha
    }


headerHeight : Int
headerHeight =
    60


searchHeaderHeight : Int
searchHeaderHeight =
    95
