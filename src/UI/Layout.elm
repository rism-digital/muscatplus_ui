module UI.Layout exposing (..)

import Element exposing (..)
import Element.Font as Font
import Html
import UI.Style as Style exposing (blueBackground, bodyFont, minMaxFillDesktop)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


layoutTopBar : Element msg
layoutTopBar =
    row [ width fill, height (px 60), blueBackground ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row [ width fill, height fill, Font.color (rgb255 255 255 255), Font.semiBold ] [ text "RISM Online" ]
            ]
        ]


layoutFooter : Element msg
layoutFooter =
    row [ width fill, height (px 120), blueBackground ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row [ width fill, height fill, Font.color (rgb255 255 255 255), Font.semiBold ] [ text "Footer" ]
            ]
        ]


layoutBody : Element msg -> Device -> List (Html.Html msg)
layoutBody bodyView device =
    let
        maxWidth =
            case device.class of
                Phone ->
                    Style.phoneMaxWidth

                _ ->
                    Style.desktopMaxWidth
    in
    [ layout [ width fill, bodyFont ]
        (column [ centerX, width fill, height fill ]
            [ layoutTopBar
            , bodyView
            , layoutFooter
            ]
        )
    ]
