module Page.UI.Facets.Toggle exposing (Toggle, render, setLabel, view)

{-
   Taken from https://github.com/bluedogtraining/bdt-elm/blob/master/src/Toggle/Css.elm
   and https://github.com/bluedogtraining/bdt-elm/blob/master/src/Toggle.elm
-}

import Css exposing (Color, absolute, after, alignItems, backgroundColor, before, block, border3, borderBox, borderRadius, bottom, boxShadow4, boxSizing, center, cursor, display, height, hex, inlineBlock, inlineFlex, left, marginLeft, notAllowed, pointer, position, property, px, relative, rem, rgb, rgba, right, solid, top, width)
import Css.Transitions as Transitions exposing (transition)
import Element exposing (Element)
import Html.Styled as HS
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Utilities exposing (choose)


type Toggle msg
    = Toggle (Config msg)


{-| Render the toggle
-}
render : Toggle msg -> Element msg
render (Toggle config) =
    let
        control =
            HS.div
                [ labelContainer ]
                [ HS.div
                    [ toggle config.isToggled config.isDisabled config.isError
                    , onClick config.toggleMsg
                    ]
                    []
                , HS.span
                    [ label ]
                    [ HS.text config.label ]
                ]
    in
    control
        |> HS.toUnstyled
        |> Element.html


{-| Set the text
-}
setLabel : String -> Toggle msg -> Toggle msg
setLabel label_ (Toggle config) =
    Toggle { config | label = label_ }



-- VIEW / SETTERS --


{-| Init a toggle
-}
view : Bool -> msg -> Toggle msg
view toggled msg =
    Toggle (initialConfig toggled msg)


type alias Config msg =
    { isError : Bool
    , isDisabled : Bool
    , label : String
    , isToggled : Bool
    , toggleMsg : msg
    }


initialConfig : Bool -> msg -> Config msg
initialConfig toggled toggleMsg =
    { isError = False
    , isDisabled = False
    , label = ""
    , isToggled = toggled
    , toggleMsg = toggleMsg
    }


label : HS.Attribute msg
label =
    css
        [ marginLeft (px 5)
        ]


labelContainer : HS.Attribute msg
labelContainer =
    css
        [ display inlineFlex
        , alignItems center
        ]


toggle : Bool -> Bool -> Bool -> HS.Attribute msg
toggle toggle_ isDisabled isError =
    css
        [ position relative
        , display inlineBlock
        , cursor (choose isDisabled (\() -> notAllowed) (\() -> pointer))
        , width (rem 2)
        , height (rem 1)
        , boxSizing borderBox
        , backgroundColor (toggleColor toggle_ isDisabled isError)
        , border3 (px 1) solid (toggleColor toggle_ isDisabled isError)
        , borderRadius (rem 1.2)
        , transition
            [ Transitions.backgroundColor 400
            , Transitions.borderColor 400
            ]
        , before
            [ display block
            , position absolute
            , top (px 1)
            , right (px 1)
            , left (px 1)
            , bottom (px 1)
            , property "content" ""
            , backgroundColor (choose toggle_ (\() -> hex "8ce196") (\() -> hex "f1f1f1"))
            , borderRadius (rem 1)
            ]
        , after
            [ display block
            , position absolute
            , top (px 1)
            , left (px 1)
            , bottom (px 1)
            , property "content" "''"
            , width (rem 0.8)
            , backgroundColor (choose isDisabled (\() -> hex "eee") (\() -> hex "fff"))
            , borderRadius (rem 1)
            , boxShadow4 (px 0) (px 2) (px 5) (rgba 0 0 0 0.3)
            , transition
                [ Transitions.margin 300
                ]
            , marginLeft (choose toggle_ (\() -> rem 0.9) (\() -> rem 0.1))
            ]
        ]


toggleColor : Bool -> Bool -> Bool -> Color
toggleColor toggle_ isDisabled isError =
    case ( toggle_, isDisabled, isError ) of
        ( True, False, False ) ->
            rgb 81 163 81

        ( False, False, False ) ->
            hex "ddd"

        ( _, True, _ ) ->
            hex "efefef"

        ( _, False, True ) ->
            rgb 163 81 81
