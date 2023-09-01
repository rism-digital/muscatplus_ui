module Page.UI.Style exposing
    ( RGBA
    , colourScheme
    , colours
    , convertColorToElementColor
    , headerHeight
    , searchHeaderHeight
    )

import Color exposing (Color, rgba)
import Element


type alias RGBA =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


colourScheme :
    { black : Color
    , cream : Color
    , darkBlue : Color
    , darkGrey : Color
    , darkOrange : Color
    , lightBlue : Color
    , lightGreen : Color
    , lightGrey : Color
    , lightOrange : Color
    , midGrey : Color
    , red : Color
    , slateGrey : Color
    , translucentBlack : Color
    , translucentGrey : Color
    , turquoise : Color
    , white : Color
    , yellow : Color
    }
colourScheme =
    { black = convertRGBAToColor colours.black
    , cream = convertRGBAToColor colours.cream
    , darkBlue = convertRGBAToColor colours.darkBlue
    , darkGrey = convertRGBAToColor colours.darkGrey
    , darkOrange = convertRGBAToColor colours.darkOrange
    , lightBlue = convertRGBAToColor colours.lightBlue
    , lightGreen = convertRGBAToColor colours.lightGreen
    , lightGrey = convertRGBAToColor colours.lightGrey
    , lightOrange = convertRGBAToColor colours.lightOrange
    , midGrey = convertRGBAToColor colours.midGrey
    , red = convertRGBAToColor colours.red
    , slateGrey = convertRGBAToColor colours.slateGrey
    , translucentBlack = convertRGBAToColor colours.translucentBlack
    , translucentGrey = convertRGBAToColor colours.translucentGrey
    , turquoise = convertRGBAToColor colours.turquoise
    , white = convertRGBAToColor colours.white
    , yellow = convertRGBAToColor colours.yellow
    }


colours :
    { black : RGBA
    , cream : RGBA
    , darkBlue : RGBA
    , darkGrey : RGBA
    , darkOrange : RGBA
    , lightBlue : RGBA
    , lightGreen : RGBA
    , lightGrey : RGBA
    , lightOrange : RGBA
    , midGrey : RGBA
    , red : RGBA
    , slateGrey : RGBA
    , translucentBlack : RGBA
    , translucentGrey : RGBA
    , turquoise : RGBA
    , white : RGBA
    , yellow : RGBA
    }
colours =
    { black =
        { red = 34
        , green = 38
        , blue = 42
        , alpha = 1
        }
    , cream =
        { red = 252
        , green = 250
        , blue = 248
        , alpha = 1
        }
    , darkBlue =
        { red = 0
        , green = 59
        , blue = 92
        , alpha = 1
        }
    , darkGrey =
        { red = 143
        , green = 143
        , blue = 143
        , alpha = 1
        }
    , darkOrange =
        { red = 243
        , green = 114
        , blue = 44
        , alpha = 1
        }
    , lightBlue =
        { red = 0
        , green = 115
        , blue = 181
        , alpha = 1
        }
    , lightGreen =
        { red = 144
        , green = 190
        , blue = 109
        , alpha = 1
        }
    , lightGrey =
        { red = 241
        , green = 244
        , blue = 249
        , alpha = 1
        }
    , lightOrange =
        { red = 248
        , green = 150
        , blue = 30
        , alpha = 1
        }
    , midGrey =
        { red = 170
        , green = 170
        , blue = 170
        , alpha = 1
        }
    , red =
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
        { red = 170
        , green = 170
        , blue = 170
        , alpha = 1
        }
    , translucentBlack =
        { red = 34
        , green = 38
        , blue = 42
        , alpha = 0.8
        }
    , translucentGrey =
        { red = 119
        , green = 136
        , blue = 153
        , alpha = 0.5
        }
    , turquoise =
        { red = 67
        , green = 170
        , blue = 139
        , alpha = 1
        }
    , white =
        { red = 250
        , green = 252
        , blue = 255
        , alpha = 255
        }
    , yellow =
        { red = 249
        , green = 199
        , blue = 79
        , alpha = 1
        }
    }


convertColorToElementColor : Color -> Element.Color
convertColorToElementColor color =
    Color.toRgba color
        |> Element.fromRgb


convertRGBAToColor : RGBA -> Color
convertRGBAToColor { red, green, blue, alpha } =
    rgba (scaleFrom255 red) (scaleFrom255 green) (scaleFrom255 blue) alpha


headerHeight : Int
headerHeight =
    60


{-| Converts a RGBA of Integers to a Color value.
-}
scaleFrom255 : Int -> Float
scaleFrom255 c =
    toFloat c / 255


searchHeaderHeight : Int
searchHeaderHeight =
    95
