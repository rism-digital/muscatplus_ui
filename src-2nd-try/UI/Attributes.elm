module UI.Attributes exposing (..)

import Element exposing (Attr, Attribute, htmlAttribute, width)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes exposing (style)
import UI.Style exposing (colourScheme, minMaxFillDesktop)


bodyFont : Attribute msg
bodyFont =
    Font.family [ Font.typeface "Inter", Font.sansSerif ]


bodyFontColour : Attribute msg
bodyFontColour =
    Font.color colourScheme.black


pageBackground : Attribute msg
pageBackground =
    Background.color colourScheme.cream


headerBottomBorder : Attribute msg
headerBottomBorder =
    htmlAttribute (style "border-bottom" "4px double #aaa")


footerBackground : Attribute msg
footerBackground =
    Background.color colourScheme.darkBlue


desktopResponsiveWidth : Attribute msg
desktopResponsiveWidth =
    width minMaxFillDesktop



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
