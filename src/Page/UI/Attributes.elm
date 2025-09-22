module Page.UI.Attributes exposing
    ( blurredBackground
    , bodyFont
    , bodyFontColour
    , bodyMonospaceFont
    , bodyRegular
    , bodySM
    , bodySerifFont
    , buttonBaseStyles
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
    , sidebarWidth
    , tableHeaderStyles
    , valueFieldColumnAttributes
    )

import Element exposing (Attr, Attribute, alignTop, centerY, fill, height, htmlAttribute, maximum, modular, padding, paddingEach, paddingXY, pointer, px, shrink, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html as HT
import Html.Attributes as HA
import Page.UI.Style exposing (colourScheme)


baseSize : Float
baseSize =
    14.0


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
    htmlAttribute emptyHtmlAttribute


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
    round (baseSize * 0.6)


linkColour : Attribute msg
linkColour =
    colourScheme.lightBlue
        |> Font.color


minimalDropShadow : Attribute msg
minimalDropShadow =
    Border.shadow
        { blur = 4
        , color = colourScheme.translucentGrey
        , offset = ( 0, 1 )
        , size = 0.5
        }


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
    , height fill
    ]


blurredBackground : Attribute msg
blurredBackground =
    htmlAttribute (HA.attribute "style" "background: rgba(255, 255, 255, 0); backdrop-filter: blur(5px); -webkit-backdrop-filter: blur(5px); z-index:200;")


buttonBaseStyles : List (Attribute msg)
buttonBaseStyles =
    [ Border.rounded 6
    , height (px 35)
    , width shrink
    , Font.center
    , centerY
    , paddingXY 10 0
    , headingMD
    , minimalDropShadow
    ]
