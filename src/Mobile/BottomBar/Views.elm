module Mobile.BottomBar.Views exposing (view)

import Element exposing (Element, alignBottom, alignLeft, centerX, centerY, column, el, fill, height, htmlAttribute, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Page.BottomBar.Msg exposing (BottomBarMsg(..))
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, peopleSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


view : Session -> Element BottomBarMsg
view session =
    row
        [ width fill
        , htmlAttribute (HA.style "height" "8vh")
        , Background.color colourScheme.darkBlue
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.color colourScheme.darkGrey
        , alignBottom
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ centerX
                , centerY
                , spacing 20
                ]
                [ column
                    [ height fill
                    , centerY
                    , centerX
                    , onClick (UserTouchedBottomBarOptionForFrontPage SourceSearchOption)
                    ]
                    [ el
                        [ width (px 24)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (sourcesSvg colourScheme.white)
                    , el [ Font.color colourScheme.white ] (text "Sources")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    , onClick (UserTouchedBottomBarOptionForFrontPage InstitutionSearchOption)
                    ]
                    [ el
                        [ width (px 24)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (institutionSvg colourScheme.white)
                    , el [ Font.color colourScheme.white ] (text "Institutions")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    , onClick (UserTouchedBottomBarOptionForFrontPage PeopleSearchOption)
                    ]
                    [ el
                        [ width (px 24)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (peopleSvg colourScheme.white)
                    , el [ Font.color colourScheme.white ] (text "People")
                    ]
                , column
                    [ height fill
                    , centerY
                    , centerX
                    , onClick (UserTouchedBottomBarOptionForFrontPage IncipitSearchOption)
                    ]
                    [ el
                        [ width (px 24)
                        , alignLeft
                        , centerY
                        , centerX
                        ]
                        (musicNotationSvg colourScheme.white)
                    , el
                        [ Font.color colourScheme.white ]
                        (text "Incipits")
                    ]
                ]
            ]
        ]
