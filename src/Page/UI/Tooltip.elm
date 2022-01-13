module Page.UI.Tooltip exposing (..)

import Element exposing (Attribute, Element, above, el, fill, height, htmlAttribute, inFront, mouseOver, none, padding, paragraph, px, rgb, rgba, text, transparent, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Page.UI.Images exposing (assistanceSvg)
import Page.UI.Style exposing (colourScheme)


facetHelp : String -> Element msg
facetHelp helpText =
    el
        [ width (px 12)
        , tooltip above (helpBubble helpText)
        ]
        (assistanceSvg colourScheme.slateGrey)


helpBubble : String -> Element msg
helpBubble str =
    el
        [ Background.color (rgb 0 0 0)
        , Font.color (rgb 1 1 1)
        , width (px 350)
        , padding 12
        , Border.rounded 5
        , Font.size 14
        , Border.shadow
            { offset = ( 0, 3 ), blur = 6, size = 0, color = rgba 0 0 0 0.32 }
        ]
        (paragraph [] [ text str ])


tooltip : (Element msg -> Attribute msg) -> Element Never -> Attribute msg
tooltip usher tooltip_ =
    inFront <|
        el
            [ width fill
            , height fill
            , transparent True
            , mouseOver [ transparent False ]
            , (usher << Element.map never) <|
                el [ htmlAttribute (Html.Attributes.style "pointerEvents" "none") ]
                    tooltip_
            ]
            none
