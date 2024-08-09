module Mobile.BottomBar.Views exposing (..)

import Element exposing (Element, alignLeft, centerX, centerY, column, el, fill, height, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


view : Session -> Element msg
view session =
    row
        [ height (px 90)
        , width fill
        , Background.color colourScheme.white
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , Border.color colourScheme.darkGrey
        , paddingXY 20 10
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                , spacing 40
                ]
                [ column
                    [ height fill
                    , centerY
                    , centerX
                    ]
                    [ el
                        [ width (px 42)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (sourcesSvg colourScheme.black)
                    , el [] (text "Sources")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    ]
                    [ el
                        [ width (px 42)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (institutionSvg colourScheme.black)
                    , el [] (text "Institutions")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    ]
                    [ el
                        [ width (px 42)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (peopleSvg colourScheme.black)
                    , el [] (text "People")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    ]
                    [ el
                        [ width (px 42)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (musicNotationSvg colourScheme.black)
                    , el [] (text "Incipits")
                    ]
                ]
            ]
        ]
