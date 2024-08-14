module Mobile.BottomBar.Views exposing (..)

import Element exposing (DeviceClass(..), Element, alignLeft, centerX, centerY, column, el, fill, fillPortion, height, htmlAttribute, padding, paddingEach, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Page.BottomBar.Msg exposing (BottomBarMsg(..))
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Images exposing (globeSvg, institutionSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


view : Session -> Element BottomBarMsg
view session =
    let
        ( iconSize, iconSpacing, fontSize ) =
            case .class session.device of
                Phone ->
                    ( 20, 30, 12 )

                _ ->
                    ( 36, 42, 14 )
    in
    row
        [ width fill
        , htmlAttribute (HA.style "height" "20vh")
        , Background.color colourScheme.darkBlue
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , Border.color colourScheme.darkGrey
        , paddingEach { top = 12, bottom = 20, left = 20, right = 20 }
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ alignLeft ]
                    [ el
                        [ width (px iconSize)
                        ]
                        (globeSvg colourScheme.white)
                    , el [] (text " ")
                    ]
                , column
                    [ centerX
                    ]
                    [ row
                        [ centerX
                        , centerY
                        , width fill
                        , spacing iconSpacing
                        ]
                        [ column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage SourceSearchOption)
                            ]
                            [ el
                                [ width (px iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (sourcesSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size fontSize ] (text "Sources")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage InstitutionSearchOption)
                            ]
                            [ el
                                [ width (px iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (institutionSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size fontSize ] (text "Institutions")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage PeopleSearchOption)
                            ]
                            [ el
                                [ width (px iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (peopleSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size fontSize ] (text "People")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage IncipitSearchOption)
                            ]
                            [ el
                                [ width (px iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (musicNotationSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size fontSize ] (text "Incipits")
                            ]
                        ]
                    ]
                ]
            ]
        ]
