module Page.UI.Tooltip exposing (..)

import Element exposing (Attribute, Element, centerX, centerY, el, fill, height, htmlAttribute, inFront, minimum, mouseOver, none, padding, paragraph, px, rgb, rgba, shrink, spacing, text, transparent, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Page.UI.Images exposing (assistanceSvg)
import Page.UI.Style exposing (colourScheme)


tooltipStyle : List (Attribute msg)
tooltipStyle =
    [ Background.color (rgb 0 0 0)
    , Font.color (rgb 1 1 1)
    , width (shrink |> minimum 120)
    , padding 12
    , spacing 5

    --, Border.rounded 5
    , Font.size 14
    , Border.shadow
        { offset = ( 0, 3 ), blur = 6, size = 0, color = rgba 0 0 0 0.32 }
    ]


facetHelp : (Element msg -> Attribute msg) -> String -> Element msg
facetHelp position helpText =
    el
        [ width (px 12)
        , height (px 12)
        , tooltip position (helpBubble helpText)
        ]
        (assistanceSvg colourScheme.slateGrey)


helpBubble : String -> Element msg
helpBubble str =
    el
        tooltipStyle
        (paragraph [ width <| px 350 ] [ text str ])


tooltip : (Element msg -> Attribute msg) -> Element Never -> Attribute msg
tooltip position tooltip_ =
    inFront <|
        el
            [ width fill
            , height fill
            , transparent True
            , mouseOver [ transparent False ]
            , (position << Element.map never) <|
                el [ htmlAttribute (Html.Attributes.style "pointerEvents" "none") ]
                    tooltip_
            ]
            none
