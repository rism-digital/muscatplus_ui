module Page.UI.Tooltip exposing (facetHelp, facetTooltip, tooltip, tooltipStyle)

import Element exposing (Attribute, Element, el, fill, height, htmlAttribute, inFront, minimum, mouseOver, none, padding, paragraph, px, shrink, spacing, text, transparent, width)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes as HA
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Images exposing (assistanceSvg, infoCircleSvg)
import Page.UI.Style exposing (colourScheme)


facetHelp : (Element msg -> Attribute msg) -> String -> Element msg
facetHelp position helpText =
    el
        [ width (px 16)
        , height (px 16)
        , tooltip position (helpBubble helpText)
        ]
        (assistanceSvg colourScheme.midGrey)


facetTooltip : (Element msg -> Attribute msg) -> String -> Element msg
facetTooltip position tttext =
    el
        [ width (px 16)
        , height (px 16)
        , tooltip position (tooltipBubble tttext)
        ]
        (infoCircleSvg colourScheme.lightBlue)


helpBubble : String -> Element msg
helpBubble str =
    el
        tooltipStyle
        (paragraph [ width (px 350) ] [ text str ])


tooltipBubble : String -> Element msg
tooltipBubble str =
    el
        tooltipStyle2
        (paragraph [ width (px 350) ] [ text str ])


tooltip : (Element msg -> Attribute msg) -> Element Never -> Attribute msg
tooltip position tooltip_ =
    inFront
        (el
            [ width fill
            , height fill
            , transparent True
            , mouseOver [ transparent False ]
            , (position << Element.map never)
                (el [ htmlAttribute (HA.style "pointerEvents" "none") ]
                    tooltip_
                )
            ]
            none
        )


tooltipStyle : List (Attribute msg)
tooltipStyle =
    [ Background.color colourScheme.black
    , Font.color colourScheme.white
    , width (shrink |> minimum 140)
    , padding 12
    , spacing 5
    , bodyRegular
    ]


tooltipStyle2 : List (Attribute msg)
tooltipStyle2 =
    [ Background.color colourScheme.black
    , Font.color colourScheme.white
    , width (shrink |> minimum 120)
    , padding 12
    , spacing 5
    , bodyRegular
    ]
