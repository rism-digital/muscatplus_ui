module Page.UI.Animations exposing
    ( animatedColumn
    , animatedLabel
    , animatedLoader
    , animatedRow
    , progressBar
    )

import Element exposing (Element, fill, htmlAttribute, none)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes as HA
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Simple.Animation.Property as P


animatedLoader : List (Element.Attribute msg) -> Element msg -> Element msg
animatedLoader attrs loaderImage =
    animatedEl
        (Animation.fromTo
            { duration = 500
            , options =
                [ Animation.loop ]
            }
            [ P.rotate -360 ]
            []
        )
        attrs
        loaderImage


animatedLabel : Element msg -> Element msg
animatedLabel labelText =
    animatedEl
        (Animation.fromTo
            { duration = 220
            , options =
                [ Animation.easeInOutSine
                ]
            }
            [ P.property "width" "90px"
            , P.opacity 0.0
            ]
            [ P.property "width" "150px"
            , P.opacity 1.0
            ]
        )
        [ headingMD
        , Font.medium
        , Element.width fill
        , Element.alignLeft
        ]
        labelText


progressBarAnimation : Animation
progressBarAnimation =
    Animation.fromTo
        { duration = 800
        , options = [ Animation.easeInQuart ]
        }
        [ P.property "width" "0" ]
        [ P.property "width" "80%" ]


progressBar : Element msg
progressBar =
    animatedEl progressBarAnimation
        [ Element.height (Element.px 10)
        , Element.width (Element.px 0)
        , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
        , htmlAttribute (HA.style "position" "fixed")
        , htmlAttribute (HA.style "top" "0")
        , htmlAttribute (HA.style "left" "0")
        , htmlAttribute (HA.style "right" "0")
        ]
        none


animatedEl : Animation -> List (Element.Attribute msg) -> Element msg -> Element msg
animatedEl =
    animatedUi Element.el


animatedRow : Animation -> List (Element.Attribute msg) -> List (Element msg) -> Element msg
animatedRow =
    animatedUi Element.row


animatedColumn : Animation -> List (Element.Attribute msg) -> List (Element msg) -> Element msg
animatedColumn =
    animatedUi Element.column


animatedUi =
    Animated.ui
        { behindContent = Element.behindContent
        , htmlAttribute = Element.htmlAttribute
        , html = Element.html
        }
