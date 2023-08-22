module Page.UI.Attributes exposing
    ( bodyFont
    , bodyFontColour
    , bodyRegular
    , bodySM
    , controlsColumnWidth
    , emptyAttribute
    , fontBaseSize
    , headingHero
    , headingLG
    , headingMD
    , headingSM
    , headingXL
    , headingXS
    , headingXXL
    , labelFieldColumnAttributes
    , lineSpacing
    , linkColour
    , minimalDropShadow
    , pageBackground
    , responsiveCheckboxColumns
    , resultColumnWidth
    , sectionBorderStyles
    , sectionSpacing
    , valueFieldColumnAttributes
    )

import Element exposing (Attr, Attribute, Device, DeviceClass(..), Orientation(..), alignTop, fill, fillPortion, htmlAttribute, minimum, paddingXY, px, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


baseSize : Float
baseSize =
    12.0


bodyFont : Attribute msg
bodyFont =
    Font.family
        [ Font.typeface "Noto Sans Display"
        , Font.sansSerif
        ]


bodyFontColour : Attribute msg
bodyFontColour =
    Font.color (colourScheme.black |> convertColorToElementColor)


bodyRegular : Attr decorative msg
bodyRegular =
    fontBaseSize


bodySM : Attr decorative msg
bodySM =
    Font.size 13


bodyXS : Attr decorative msg
bodyXS =
    Font.size 11


bodyXXS : Attr decorative msg
bodyXXS =
    Font.size 10


{-|

    The attribute equivalent of Element.none.
    Returns a no-op attribute, which is useful for
    conditionally applying something-or-nothing for attributes.

-}
emptyAttribute : Attribute msg
emptyAttribute =
    htmlAttribute (HA.classList [])


facetBorderBottom : List (Attribute msg)
facetBorderBottom =
    [ Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
    , Border.color (colourScheme.lightGrey |> convertColorToElementColor)
    , paddingXY 0 lineSpacing
    ]


fontBaseSize : Attr decorative msg
fontBaseSize =
    Font.size 14


headingHero : Attr decoative msg
headingHero =
    Font.size (ratioCalc 8.0)


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


headingXL : Attr decorative msg
headingXL =
    -- 14*(2^(4/6))
    Font.size (ratioCalc 4.0)


headingXS : Attr decorative msg
headingXS =
    -- 14*(2^(0/6))
    Font.size (ratioCalc 0.0)


headingXXL : Attr decorative msg
headingXXL =
    -- 14*(2^(5/6))
    Font.size (ratioCalc 5.0)


labelFieldColumnAttributes : List (Attribute msg)
labelFieldColumnAttributes =
    [ width (fillPortion 1)
    , alignTop
    , spacing lineSpacing
    ]


lineSpacing : Int
lineSpacing =
    round (baseSize * 0.8)


linkColour : Attribute msg
linkColour =
    colourScheme.lightBlue
        |> convertColorToElementColor
        |> Font.color


minimalDropShadow : Attribute msg
minimalDropShadow =
    Border.shadow
        { blur = 4
        , color =
            colourScheme.darkGrey
                |> convertColorToElementColor
        , offset = ( 0, 0 )
        , size = 0
        }


pageBackground : Attribute msg
pageBackground =
    Background.color (colourScheme.cream |> convertColorToElementColor)


{-| <https://spencermortensen.com/articles/typographic-scale/>
-}
ratioCalc : Float -> Int
ratioCalc size =
    round (baseSize * (2.0 ^ (size / 6.0)))


sectionBorderStyles : List (Attribute msg)
sectionBorderStyles =
    [ Border.widthEach { bottom = 0, left = 2, right = 0, top = 0 }
    , Border.color (colourScheme.midGrey |> convertColorToElementColor)
    , paddingXY lineSpacing 0
    ]


sectionSpacing : Int
sectionSpacing =
    round (baseSize * 1.8)


valueFieldColumnAttributes : List (Attribute msg)
valueFieldColumnAttributes =
    [ width (fillPortion 3)
    , alignTop
    ]


resultColumnWidth : Device -> Attribute msg
resultColumnWidth { class, orientation } =
    case ( class, orientation ) of
        ( BigDesktop, Landscape ) ->
            width (px 600 |> minimum 600)

        ( Desktop, Landscape ) ->
            width (px 600)

        _ ->
            -- TODO: Figure out what else goes here.
            width (px 640 |> minimum 640)


controlsColumnWidth : Device -> Attribute msg
controlsColumnWidth { class, orientation } =
    case ( class, orientation ) of
        ( Phone, Portrait ) ->
            width (px 0)

        ( Desktop, Landscape ) ->
            width fill

        ( BigDesktop, Landscape ) ->
            width fill

        _ ->
            width fill


responsiveCheckboxColumns : Device -> Int
responsiveCheckboxColumns { class, orientation } =
    case ( class, orientation ) of
        ( Phone, Portrait ) ->
            3

        ( Desktop, Landscape ) ->
            3

        ( BigDesktop, Landscape ) ->
            4

        _ ->
            3
