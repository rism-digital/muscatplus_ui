module Page.UI.Attributes exposing (..)

import Color exposing (toCssString)
import Element exposing (Attr, Attribute, alignTop, fill, fillPortion, height, htmlAttribute, paddingXY, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA exposing (style)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, footerHeight, minMaxFillDesktop, searchHeaderHeight)


bodyFont : Attribute msg
bodyFont =
    Font.family
        [ Font.typeface "Noto Sans Display"
        , Font.sansSerif
        ]


bodyFontColour : Attribute msg
bodyFontColour =
    Font.color (colourScheme.black |> convertColorToElementColor)


bodyFontAlternateGlyphs : Attribute msg
bodyFontAlternateGlyphs =
    htmlAttribute (style "" "")


pageBackground : Attribute msg
pageBackground =
    Background.color (colourScheme.cream |> convertColorToElementColor)


headerBottomBorder : Attribute msg
headerBottomBorder =
    htmlAttribute (style "border-bottom" ("4px double " ++ toCssString colourScheme.darkGrey))


footerBackground : Attribute msg
footerBackground =
    Background.color (colourScheme.darkBlue |> convertColorToElementColor)


desktopResponsiveWidth : Attribute msg
desktopResponsiveWidth =
    width minMaxFillDesktop


searchColumnVerticalSize : Attribute msg
searchColumnVerticalSize =
    let
        otherElementsHeight =
            footerHeight + searchHeaderHeight
    in
    htmlAttribute (HA.style "height" ("calc(100vh - " ++ String.fromInt otherElementsHeight ++ "px)"))


labelFieldColumnAttributes : List (Attribute msg)
labelFieldColumnAttributes =
    [ width (fillPortion 1)
    , alignTop
    ]


valueFieldColumnAttributes : List (Attribute msg)
valueFieldColumnAttributes =
    [ width (fillPortion 3)
    , alignTop
    ]


sectionBorderStyles : List (Attribute msg)
sectionBorderStyles =
    [ Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
    , Border.color (colourScheme.midGrey |> convertColorToElementColor)
    , paddingXY lineSpacing 0
    ]


widthFillHeightFill : List (Attribute msg)
widthFillHeightFill =
    [ width fill
    , height fill
    , alignTop
    ]


facetBorderBottom : List (Attribute msg)
facetBorderBottom =
    [ Border.widthEach { left = 0, right = 0, top = 0, bottom = 1 }
    , Border.color (colourScheme.lightGrey |> convertColorToElementColor)
    , paddingXY 0 lineSpacing
    ]


{-|

    The attribute equivalent of Element.none.
    Returns a no-op attribute, which is useful for
    conditionally applying something-or-nothing for attributes.

-}
emptyAttribute : Attribute msg
emptyAttribute =
    htmlAttribute (HA.classList [])


minimalDropShadow : Attribute msg
minimalDropShadow =
    Border.shadow
        { offset = ( 2, 0 )
        , size = 1
        , blur = 2
        , color =
            colourScheme.darkGrey
                |> convertColorToElementColor
        }


linkColour : Attribute msg
linkColour =
    colourScheme.lightBlue
        |> convertColorToElementColor
        |> Font.color


baseSize : Float
baseSize =
    14.0


lineSpacing : Int
lineSpacing =
    round (baseSize * 0.8)


sectionSpacing : Int
sectionSpacing =
    round (baseSize * 1.8)


{-| <https://spencermortensen.com/articles/typographic-scale/>
-}
ratioCalc : Float -> Int
ratioCalc size =
    round (baseSize * (2.0 ^ (size / 6.0)))


fontBaseSize : Attr decorative msg
fontBaseSize =
    Font.size (ratioCalc 1.0)


headingHero : Attr decoative msg
headingHero =
    Font.size (ratioCalc 8.0)


headingXXL : Attr decorative msg
headingXXL =
    -- 14*(2^(5/6))
    Font.size (ratioCalc 5.0)


headingXL : Attr decorative msg
headingXL =
    -- 14*(2^(4/6))
    Font.size (ratioCalc 4.0)


headingLG : Attr decorative msg
headingLG =
    -- 14*(2^(3/6))
    Font.size (ratioCalc 3.0)


headingMD : Attr decorative msg
headingMD =
    -- 14*(2^(2/6))
    Font.size (ratioCalc 2.0)


headingSM : Attr decorative msg
headingSM =
    -- 14*(2^(1/6))
    Font.size (ratioCalc 1.0)


headingXS : Attr decorative msg
headingXS =
    -- 14*(2^(0/6))
    Font.size (ratioCalc 0.0)


bodyRegular : Attr decorative msg
bodyRegular =
    fontBaseSize


bodySM : Attr decorative msg
bodySM =
    Font.size 12


bodyXS : Attr decorative msg
bodyXS =
    Font.size 11


bodyXXS : Attr decorative msg
bodyXXS =
    Font.size 10
