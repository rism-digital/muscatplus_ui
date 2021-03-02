module UI.Layout exposing (..)

import Element exposing (..)
import Element.Font as Font
import Html
import UI.Components exposing (languageSelect)
import UI.Style as Style exposing (blueBackground, bodyFont, darkBlue, greyBackground, minMaxFillDesktop)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


layoutTopBar : (String -> msg) -> Element msg
layoutTopBar message =
    row [ width fill, height (px 60), greyBackground ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row
                [ width fill, height fill ]
                [ column
                    [ width (fillPortion 10), Font.color darkBlue, Font.semiBold ]
                    [ text "RISM Online" ]
                , column
                    [ width (fillPortion 2) ]
                    [ languageSelect message ]
                ]
            ]
        ]


layoutFooter : Element msg
layoutFooter =
    row [ width fill, height (px 120), blueBackground ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row [ width fill, height fill, Font.color (rgb255 255 255 255), Font.semiBold ] [ text "Footer" ]
            ]
        ]


layoutBody : (String -> msg) -> Element msg -> Device -> List (Html.Html msg)
layoutBody message bodyView device =
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
            [ layoutTopBar message
            , bodyView
            , layoutFooter
            ]
        )
    ]
