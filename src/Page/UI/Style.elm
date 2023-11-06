module Page.UI.Style exposing
    ( colourScheme
    , headerHeight
    , recordTitleHeight
    , rgbaFloatToInt
    , tabBarHeight
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
--    , midGrey : Element.Color
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
--    , midGrey = convertRGBAToColor colours.midGrey
--    , translucentBlack = convertRGBAToColor colours.translucentBlack
--    , translucentGrey = convertRGBAToColor colours.translucentGrey
--    , turquoise = convertRGBAToColor colours.turquoise
--    , white = convertRGBAToColor colours.white
--    , yellow = convertRGBAToColor colours.yellow
--    }


colourScheme :
    { black : Element.Color
    , darkBlue : Element.Color
    , darkBlueTranslucent : Element.Color
    , darkOrange : Element.Color
    , lightBlue : Element.Color
    , lightestBlue : Element.Color
    , translucentBlue : Element.Color
    , lightGreen : Element.Color
    , lightOrange : Element.Color
    , lightGrey : Element.Color
    , midGrey : Element.Color
    , darkGrey : Element.Color
    , red : Element.Color
    , translucentBlack : Element.Color
    , translucentGrey : Element.Color
    , turquoise : Element.Color
    , white : Element.Color
    , yellow : Element.Color
    , puce : Element.Color
    , olive : Element.Color
    , transparent : Element.Color
    }
colourScheme =
    { black =
        Element.fromRgb255
            { red = 52
            , green = 62
            , blue = 61
            , alpha = 1
            }
    , darkBlue =
        Element.fromRgb255
            { red = 29
            , green = 53
            , blue = 87
            , alpha = 1
            }
    , darkBlueTranslucent =
        Element.fromRgb255
            { red = 29
            , green = 53
            , blue = 87
            , alpha = 0.4
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
            { red = 242
            , green = 143
            , blue = 59
            , alpha = 1
            }
    , lightBlue =
        Element.fromRgb255
            { red = 0
            , green = 103
            , blue = 163
            , alpha = 1
            }
    , lightestBlue =
        Element.fromRgb255
            { red = 241
            , green = 246
            , blue = 249
            , alpha = 1
            }
    , lightGreen =
        Element.fromRgb255
            { red = 144
            , green = 190
            , blue = 109
            , alpha = 1
            }
    , lightOrange =
        Element.fromRgb255
            { red = 248
            , green = 150
            , blue = 30
            , alpha = 1
            }
    , lightGrey =
        Element.fromRgb255
            { red = 241
            , green = 244
            , blue = 249
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
            { red = 173
            , green = 52
            , blue = 62
            , alpha = 1
            }

    --, midGrey =
    --    { red = 119
    --    , green = 136
    --    , blue = 153
    --    , alpha = 1
    --    }
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
    , translucentBlue =
        Element.fromRgb255
            { red = 0
            , green = 115
            , blue = 181
            , alpha = 0.3
            }
    , turquoise =
        Element.fromRgb255
            { red = 67
            , green = 154
            , blue = 134
            , alpha = 1
            }
    , white =
        Element.fromRgb255
            { red = 255
            , green = 255
            , blue = 255
            , alpha = 255
            }
    , yellow =
        Element.fromRgb255
            { red = 224
            , green = 153
            , blue = 0
            , alpha = 1
            }
    , puce =
        Element.fromRgb255
            { red = 184
            , green = 140
            , blue = 158
            , alpha = 1
            }
    , olive =
        Element.fromRgb255
            { red = 132
            , green = 147
            , blue = 36
            , alpha = 1
            }
    , transparent =
        Element.fromRgb255
            { red = 255
            , green = 255
            , blue = 255
            , alpha = 0
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


tabBarHeight : Int
tabBarHeight =
    50


recordTitleHeight : Int
recordTitleHeight =
    50
