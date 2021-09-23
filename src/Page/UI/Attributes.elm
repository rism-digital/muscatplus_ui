module Page.UI.Attributes exposing (..)

import Color exposing (toCssString)
import Element exposing (Attr, Attribute, htmlAttribute, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA exposing (style)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, footerHeight, headerHeight, minMaxFillDesktop, searchHeaderHeight)


bodyFont : Attribute msg
bodyFont =
    Font.family [ Font.typeface "Inter UI", Font.sansSerif ]


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
            headerHeight + footerHeight + searchHeaderHeight
    in
    htmlAttribute (HA.style "height" ("calc(100vh - " ++ String.fromInt otherElementsHeight ++ "px)"))


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
    Font.color
        (colourScheme.lightBlue
            |> convertColorToElementColor
        )



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
