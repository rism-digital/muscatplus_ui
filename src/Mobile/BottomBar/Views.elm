module Mobile.BottomBar.Views exposing (view)

import Element exposing (DeviceClass(..), Element, alignBottom, alignLeft, centerX, centerY, column, el, fill, height, htmlAttribute, paddingEach, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Page.BottomBar.Msg exposing (BottomBarMsg(..))
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Images exposing (globeSvg, institutionSvg, musicNotationSvg, peopleSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


type alias ResponsiveSizes =
    { iconSize : Int
    , iconSpacing : Int
    , fontSize : Int
    }


view : Session -> Element BottomBarMsg
view session =
    let
        sizes =
            case .class session.device of
                Phone ->
                    ResponsiveSizes 24 20 12

                _ ->
                    ResponsiveSizes 32 42 14
    in
    row
        [ width fill
        , htmlAttribute (HA.style "height" "8vh")
        , Background.color colourScheme.darkBlue
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , Border.color colourScheme.darkGrey
        , paddingEach { top = 12, bottom = 20, left = 20, right = 20 }
        , alignBottom
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
                        [ width (px sizes.iconSize)
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
                        , spacing sizes.iconSpacing
                        ]
                        [ column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage SourceSearchOption)
                            ]
                            [ el
                                [ width (px sizes.iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (sourcesSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size sizes.fontSize ] (text "Sources")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage InstitutionSearchOption)
                            ]
                            [ el
                                [ width (px sizes.iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (institutionSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size sizes.fontSize ] (text "Institutions")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage PeopleSearchOption)
                            ]
                            [ el
                                [ width (px sizes.iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (peopleSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size sizes.fontSize ] (text "People")
                            ]
                        , column
                            [ height fill
                            , centerY
                            , centerX
                            , onClick (UserTouchedBottomBarOptionForFrontPage IncipitSearchOption)
                            ]
                            [ el
                                [ width (px sizes.iconSize)
                                , alignLeft
                                , centerY
                                , centerX
                                ]
                                (musicNotationSvg colourScheme.white)
                            , el [ Font.color colourScheme.white, Font.size sizes.fontSize ] (text "Incipits")
                            ]
                        ]
                    ]
                ]
            ]
        ]
