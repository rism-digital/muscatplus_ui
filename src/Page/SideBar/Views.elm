module Page.SideBar.Views exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, paddingXY, px, row, shrink, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Model exposing (Model)
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, peopleSvg, roLogoSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, headerHeight)


view : Model -> Element msg
view model =
    column
        [ width (px 100)
        , height fill
        , alignTop
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.widthEach { left = 0, right = 2, top = 0, bottom = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        ]
        [ row
            [ width (px 60)
            , height (px 100)
            , centerX
            , paddingXY 0 20
            , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            , Border.color (colourScheme.midGrey |> convertColorToElementColor)
            ]
            [ column
                [ alignTop
                , centerX
                ]
                [ el
                    [ centerY
                    , alignTop
                    ]
                    (roLogoSvg headerHeight)

                --, el
                --    [ width (px 20)
                --    , centerX
                --    , centerY
                --    ]
                --    (menuHamburgerSvg colourScheme.slateGrey)
                ]
            ]
        , row
            [ width (px 60)
            , height shrink
            , centerX
            , paddingXY 0 10
            , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            , Border.color (colourScheme.midGrey |> convertColorToElementColor)
            ]
            [ column
                [ width fill
                , height fill
                , centerX
                , alignTop
                , spacing 40
                ]
                [ row
                    [ width fill
                    , alignTop
                    ]
                    [ el
                        [ width (px 25)
                        , centerX
                        , centerY
                        ]
                        (sourcesSvg colourScheme.slateGrey)
                    ]
                , row
                    [ width fill
                    , alignTop
                    ]
                    [ el
                        [ width (px 25)
                        , centerX
                        , centerY
                        ]
                        (peopleSvg colourScheme.slateGrey)
                    ]
                , row
                    [ width fill
                    , alignTop
                    ]
                    [ el
                        [ width (px 25)
                        , centerX
                        , centerY
                        ]
                        (institutionSvg colourScheme.slateGrey)
                    ]
                , row
                    [ width fill
                    , alignTop
                    ]
                    [ el
                        [ width (px 25)
                        , centerX
                        , centerY
                        ]
                        (musicNotationSvg colourScheme.slateGrey)
                    ]
                ]
            ]
        ]
