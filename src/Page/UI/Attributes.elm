module Page.UI.Attributes exposing
    ( bodyFont
    , bodyFontColour
    , bodyMonospaceFont
    , bodyRegular
    , bodySM
    , bodySerifFont
    , desktopDisplayWidth
    , emptyAttribute
    , emptyHtmlAttribute
    , fontBaseSize
    , headingHero
    , headingLG
    , headingMD
    , headingSM
    , headingXL
    , headingXXL
    , labelFieldColumnAttributes
    , lineSpacing
    , linkColour
    , minimalDropShadow
    , resultsColumnWidth
    , sectionBorderStyles
    , sectionSpacing
    , sidebarWidth
    , valueFieldColumnAttributes
    )

import Element exposing (Attr, Attribute, Device, DeviceClass(..), Orientation(..), alignTop, fill, htmlAttribute, maximum, modular, paddingEach, paddingXY, px, spacing, width)
import Element.Border as Border
import Element.Font as Font
import Html as HT
import Html.Attributes as HA
import Page.UI.Style exposing (colourScheme)


baseSize : Float
baseSize =
    16.0


bodyFont : Attribute msg
bodyFont =
    Font.family
        [ Font.typeface "Noto Sans Display"
        , Font.sansSerif
        ]


bodySerifFont : Attribute msg
bodySerifFont =
    Font.family
        [ Font.typeface "Noto Serif"
        , Font.sansSerif
        ]


bodyMonospaceFont : Attribute msg
bodyMonospaceFont =
    Font.family
        [ Font.typeface "Noto Sans Mono"
        , Font.monospace
        ]


bodyFontColour : Attribute msg
bodyFontColour =
    Font.color colourScheme.black


scaled : Int -> Float
scaled =
    modular baseSize 1.12


bodyRegular : Attr decorative msg
bodyRegular =
    fontBaseSize


bodySM : Attr decorative msg
bodySM =
    scaled -1
        |> round
        |> Font.size


{-|

    The attribute equivalent of Element.none.
    Returns a no-op attribute, which is useful for
    conditionally applying something-or-nothing for attributes.

-}
emptyAttribute : Attribute msg
emptyAttribute =
    htmlAttribute (HA.classList [])


emptyHtmlAttribute : HT.Attribute msg
emptyHtmlAttribute =
    HA.classList []


fontBaseSize : Attr decorative msg
fontBaseSize =
    scaled 1
        |> round
        |> Font.size


headingHero : Attr decorative msg
headingHero =
    scaled 6
        |> round
        |> Font.size


headingLG : Attr decorative msg
headingLG =
    -- 14*(2^(3/6))
    scaled 3
        |> round
        |> Font.size


headingMD : Attr decorative msg
headingMD =
    -- 14*(2^(2/6))
    scaled 2
        |> round
        |> Font.size


headingSM : Attr decorative msg
headingSM =
    -- 14*(2^(1/6))
    scaled 1
        |> round
        |> Font.size


headingXL : Attr decorative msg
headingXL =
    -- 14*(2^(4/6))
    scaled 4
        |> round
        |> Font.size


headingXXL : Attr decorative msg
headingXXL =
    -- 14*(2^(5/6))
    scaled 5
        |> round
        |> Font.size


labelFieldColumnAttributes : List (Attribute msg)
labelFieldColumnAttributes =
    [ width (fill |> maximum 180)
    , alignTop
    , spacing lineSpacing
    , paddingEach { bottom = 5, left = 0, right = 5, top = 0 }
    ]


lineSpacing : Int
lineSpacing =
    round (baseSize * 0.8)


linkColour : Attribute msg
linkColour =
    colourScheme.lightBlue
        |> Font.color


minimalDropShadow : Attribute msg
minimalDropShadow =
    Border.shadow
        { blur = 2
        , color = colourScheme.darkBlueTranslucent
        , offset = ( 1, 1 )
        , size = 1
        }


sectionBorderStyles : List (Attribute msg)
sectionBorderStyles =
    [ paddingXY lineSpacing 0
    ]


sectionSpacing : Int
sectionSpacing =
    round (baseSize * 1.8)


valueFieldColumnAttributes : List (Attribute msg)
valueFieldColumnAttributes =
    [ width fill
    , alignTop
    , spacing lineSpacing
    ]


sidebarWidth : Int
sidebarWidth =
    70


resultsColumnWidth : Int
resultsColumnWidth =
    600


desktopDisplayWidth : Int
desktopDisplayWidth =
    1000
