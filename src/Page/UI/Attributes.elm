module Page.UI.Attributes exposing
    ( blurredBackground
    , bodyFont
    , bodyFontColour
    , bodyMonospaceFont
    , bodyRegular
    , bodySM
    , bodySerifFont
    , cycleTableBackground
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
    , minimalInsetShadow
    , sectionBorderStyles
    , sectionSpacing
    , shadowHighElevation
    , shadowMediumElevation
    , sidebarWidth
    , tableHeaderStyles
    , valueFieldColumnAttributes
    )

import Element exposing (Attr, Attribute, alignTop, centerY, fill, htmlAttribute, maximum, modular, padding, paddingEach, paddingXY, spacing, width)
import Element.Background as Background
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
    , paddingEach { bottom = 5, left = 0, right = 8, top = 0 }
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
        { blur = 4
        , color = colourScheme.translucentGrey
        , offset = ( -1, 1 )
        , size = 1
        }


shadowLowElevation : Attribute msg
shadowLowElevation =
    htmlAttribute (HA.attribute "style" "")


shadowMediumElevation : Attribute msg
shadowMediumElevation =
    htmlAttribute (HA.attribute "style" """box-shadow: 0px 1px 0.9px hsl(0deg 0% 73% / 0.39),
0px 2.2px 2px -1.3px hsl(0deg 0% 73% / 0.32),
0px 6.3px 5.8px -2.6px hsl(0deg 0% 73% / 0.25),
0px 17px 15.6px -3.9px hsl(0deg 0% 73% / 0.18);""")


shadowHighElevation : Attribute msg
shadowHighElevation =
    htmlAttribute (HA.attribute "style" """box-shadow: 0px 1px 0.9px hsl(0deg 0% 73% / 0.36),
0px 2.6px 2.4px -0.6px hsl(0deg 0% 73% / 0.33),
0px 4.9px 4.5px -1.1px hsl(0deg 0% 73% / 0.3),
0px 9.2px 8.4px -1.7px hsl(0deg 0% 73% / 0.26),
0px 16.7px 15.3px -2.2px hsl(0deg 0% 73% / 0.23),
-0.1px 28.5px 26.1px -2.8px hsl(0deg 0% 73% / 0.2),
-0.1px 45.8px 41.9px -3.3px hsl(0deg 0% 73% / 0.17),
-0.1px 70px 64.1px -3.9px hsl(0deg 0% 73% / 0.13);""")


minimalInsetShadow : Attribute msg
minimalInsetShadow =
    Border.innerShadow
        { blur = 2
        , color = colourScheme.translucentGrey
        , offset = ( -1, 1 )
        , size = 0
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


cycleTableBackground : Int -> Attribute msg
cycleTableBackground i =
    if modBy 2 i == 0 then
        Background.color colourScheme.lightestBlue

    else
        Background.color colourScheme.white


tableHeaderStyles : List (Attribute msg)
tableHeaderStyles =
    [ Font.semiBold
    , padding 10
    , Border.widthEach { bottom = 1, left = 0, right = 1, top = 0 }
    , Border.color colourScheme.midGrey
    , Background.color colourScheme.lightGrey
    ]


blurredBackground : Attribute msg
blurredBackground =
    htmlAttribute (HA.attribute "style" "background: rgba(255, 255, 255, 0); backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px); z-index:200;")
