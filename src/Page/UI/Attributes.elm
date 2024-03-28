module Page.UI.Attributes exposing
    ( bodyFont
    , bodyFontColour
    , bodyMonospaceFont
    , bodyRegular
    , bodySM
    , bodySerifFont
    , controlsColumnWidth
    , emptyAttribute
    , emptyHtmlAttribute
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
    , pageHeaderBackground
    , responsiveCheckboxColumns
    , resultsColumnWidth
    , sectionBorderStyles
    , sectionSpacing
    , sidebarWidth
    , tabShadowClip
    , valueFieldColumnAttributes
    )

import Element
    exposing
        ( Attr
        , Attribute
        , Device
        , DeviceClass(..)
        , Orientation(..)
        , alignTop
        , fill
        , htmlAttribute
        , maximum
        , minimum
        , paddingEach
        , paddingXY
        , px
        , spacing
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html as HT
import Html.Attributes as HA
import Page.UI.Style exposing (colourScheme)


baseSize : Float
baseSize =
    12.0


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


emptyHtmlAttribute : HT.Attribute msg
emptyHtmlAttribute =
    HA.classList []


fontBaseSize : Attr decorative msg
fontBaseSize =
    Font.size 14


headingHero : Attr decorative msg
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
    [ width (fill |> maximum 250 |> minimum 200)
    , alignTop
    , spacing lineSpacing
    , paddingEach { bottom = 5, left = 0, right = 0, top = 0 }
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


tabShadowClip : Attribute msg
tabShadowClip =
    -- applied clipping to the shadow so that we don't get a bottom
    -- shadow on tabs.
    htmlAttribute (HA.style "clip-path" "inset(-5px -5px 0px -5px)")


pageHeaderBackground : Attribute msg
pageHeaderBackground =
    Background.gradient
        { angle = 90
        , steps =
            [ colourScheme.white
            , colourScheme.white
            , colourScheme.white
            , colourScheme.darkBlueTranslucent
            ]
        }


{-| <https://spencermortensen.com/articles/typographic-scale/>
-}
ratioCalc : Float -> Int
ratioCalc size =
    round (baseSize * (2.0 ^ (size / 6.0)))


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
    ]


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


sidebarWidth : Int
sidebarWidth =
    70


resultsColumnWidth : Int
resultsColumnWidth =
    600
