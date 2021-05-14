module UI.Animations exposing (loadingBox)

import Css exposing (absolute, animationDuration, animationName, backgroundColor, backgroundImage, before, block, display, height, hidden, left, linearGradient2, overflow, pct, position, property, px, relative, rgb, rgba, sec, stop2, toRight, top, width)
import Css.Animations as Animations exposing (keyframes)
import Element exposing (Element)
import Html.Styled exposing (Attribute, div, toUnstyled)
import Html.Styled.Attributes exposing (css)


{-|

    Implements a loading animation that can act as a placeholder for
    the contents.

-}
loadingBox : Float -> Float -> Element msg
loadingBox boxWidth boxHeight =
    Element.html
        (div [ loadingStyles boxWidth boxHeight ] []
            |> toUnstyled
        )


loadingStyles : Float -> Float -> Attribute msg
loadingStyles whooshWidth whooshHeight =
    css
        [ height (px whooshHeight)
        , width (px whooshWidth)

        --, boxShadow5 (px 0) (px 2) (px 4) (px 0) (rgba 33 33 33 0.15)
        , backgroundColor (rgb 250 250 250)

        --, borderRadius (px 4)
        , position relative
        , overflow hidden
        , before
            [ property "content" "''"
            , display block
            , position absolute
            , left (px -150)
            , top (px 0)
            , height (pct 100)
            , width (px 150)
            , backgroundImage (linearGradient2 toRight (stop2 (rgba 255 255 255 0) (pct 0)) (stop2 (rgba 241 244 249 1) (pct 50)) [ stop2 (rgba 255 255 255 0) (pct 100) ])
            , animationName
                (keyframes
                    [ ( 0, [ Animations.property "left" "-150px" ] )
                    , ( 100, [ Animations.property "left" "100%" ] )
                    ]
                )
            , animationDuration (sec 1.0)
            , property "animation-iteration-count" "infinite"
            , property "animation-timing-function" "cubic-bezier(0.4, 0.0, 0.2, 1)"
            ]
        ]
