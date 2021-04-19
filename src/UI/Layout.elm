module UI.Layout exposing (..)

import Element exposing (..)
import Element.Font as Font
import Html
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import UI.Components exposing (languageSelect)
import UI.Style exposing (blueBackground, bodyFont, darkBlue, greyBackground, minMaxFillDesktop)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


layoutTopBar :
    (String -> msg)
    -> List ( String, String )
    -> Language
    -> Element msg
layoutTopBar message langOptions currentLanguage =
    row [ width fill, height (px 60), greyBackground ]
        [ column [ width minMaxFillDesktop, height fill, centerX ]
            [ row
                [ width fill, height fill ]
                [ column
                    [ width (fillPortion 2)
                    , Font.color darkBlue
                    , Font.semiBold
                    ]
                    [ text "RISM Online" ]
                , column
                    [ width (fillPortion 8) ]
                    [ link [] { url = "/", label = text (extractLabelFromLanguageMap currentLanguage localTranslations.home) } ]
                , column
                    [ width (fillPortion 2) ]
                    [ languageSelect message langOptions ]
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


layoutBody :
    (String -> msg)
    -> List ( String, String )
    -> Element msg
    -> Device
    -> Language
    -> List (Html.Html msg)
layoutBody message langOptions bodyView device currentLanguage =
    [ layout [ width fill, bodyFont ]
        (column [ centerX, width fill, height fill ]
            [ layoutTopBar message langOptions currentLanguage
            , bodyView
            , layoutFooter
            ]
        )
    ]
