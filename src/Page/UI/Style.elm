module Page.UI.Style exposing
    ( colourScheme
    , headerHeight
    , recordTitleHeight
    , rgbaFloatToInt
    , searchSourcesLinkHeight
    , tabBarHeight
    )

import Element


colourScheme :
    { black : Element.Color
    , darkBlue : Element.Color
    , darkBlueTranslucent : Element.Color
    , darkGrey : Element.Color
    , darkOrange : Element.Color
    , lightBlue : Element.Color
    , lightGreen : Element.Color
    , lightGrey : Element.Color
    , lightOrange : Element.Color
    , lightestBlue : Element.Color
    , midGrey : Element.Color
    , olive : Element.Color
    , puce : Element.Color
    , red : Element.Color
    , translucentBlack : Element.Color
    , translucentBlue : Element.Color
    , translucentGrey : Element.Color
    , transparent : Element.Color
    , turquoise : Element.Color
    , white : Element.Color
    , yellow : Element.Color
    }
colourScheme =
    { black =
        Element.fromRgb255
            { alpha = 1
            , blue = 61
            , green = 62
            , red = 52
            }
    , darkBlue =
        Element.fromRgb255
            { alpha = 1
            , blue = 87
            , green = 53
            , red = 29
            }
    , darkBlueTranslucent =
        Element.fromRgb255
            { alpha = 0.4
            , blue = 87
            , green = 53
            , red = 29
            }
    , darkGrey =
        Element.fromRgb255
            { alpha = 1
            , blue = 143
            , green = 143
            , red = 143
            }
    , darkOrange =
        Element.fromRgb255
            { alpha = 1
            , blue = 59
            , green = 143
            , red = 242
            }
    , lightBlue =
        Element.fromRgb255
            { alpha = 1
            , blue = 163
            , green = 103
            , red = 0
            }
    , lightGreen =
        Element.fromRgb255
            { alpha = 1
            , blue = 109
            , green = 190
            , red = 144
            }
    , lightGrey =
        Element.fromRgb255
            { alpha = 1
            , blue = 249
            , green = 244
            , red = 241
            }
    , lightOrange =
        Element.fromRgb255
            { alpha = 1
            , blue = 30
            , green = 150
            , red = 248
            }
    , lightestBlue =
        Element.fromRgb255
            { alpha = 1
            , blue = 255
            , green = 246
            , red = 241
            }
    , midGrey =
        Element.fromRgb255
            { alpha = 1
            , blue = 170
            , green = 170
            , red = 170
            }
    , olive =
        Element.fromRgb255
            { alpha = 1
            , blue = 36
            , green = 147
            , red = 132
            }
    , puce =
        Element.fromRgb255
            { alpha = 1
            , blue = 158
            , green = 140
            , red = 184
            }
    , red =
        Element.fromRgb255
            { alpha = 1
            , blue = 62
            , green = 52
            , red = 173
            }

    --, midGrey =
    --    { red = 119
    --    , green = 136
    --    , blue = 153
    --    , alpha = 1
    --    }
    , translucentBlack =
        Element.fromRgb255
            { alpha = 0.8
            , blue = 42
            , green = 38
            , red = 34
            }
    , translucentBlue =
        Element.fromRgb255
            { alpha = 0.3
            , blue = 181
            , green = 115
            , red = 0
            }
    , translucentGrey =
        Element.fromRgb255
            { alpha = 0.5
            , blue = 153
            , green = 136
            , red = 119
            }
    , transparent =
        Element.fromRgb255
            { alpha = 0
            , blue = 255
            , green = 255
            , red = 255
            }
    , turquoise =
        Element.fromRgb255
            { alpha = 1
            , blue = 134
            , green = 154
            , red = 67
            }
    , white =
        Element.fromRgb255
            { alpha = 255
            , blue = 255
            , green = 255
            , red = 255
            }
    , yellow =
        Element.fromRgb255
            { alpha = 1
            , blue = 0
            , green = 153
            , red = 224
            }
    }


{-| Converts a RGBA of Integers to a Color value.
-}
rgbaFloatToInt : Element.Color -> { alpha : Float, blue : Int, green : Int, red : Int }
rgbaFloatToInt colour =
    let
        { alpha, blue, green, red } =
            Element.toRgb colour
    in
    { alpha = alpha
    , blue = round (blue * 255)
    , green = round (green * 255)
    , red = round (red * 255)
    }


headerHeight : Int
headerHeight =
    60


tabBarHeight : Int
tabBarHeight =
    50


searchSourcesLinkHeight : Int
searchSourcesLinkHeight =
    20


recordTitleHeight : Int
recordTitleHeight =
    50
