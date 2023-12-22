module Page.SideBar.Views.AboutMenu exposing (view)

import Config
import Element exposing (Element, alignBottom, alignLeft, alignRight, alignTop, centerY, column, el, fill, height, htmlAttribute, link, mouseOver, moveUp, none, onRight, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onMouseEnter, onMouseLeave)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language(..), LanguageMap, extractLabelFromLanguageMap, toLanguageMapWithLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels)
import Page.SideBar.Views.MenuOption exposing (sidebarChooserAnimations)
import Page.UI.Animations exposing (animatedLabel, animatedRow)
import Page.UI.Attributes exposing (bodyRegular, emptyAttribute)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (infoCircleSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


view : Session -> Element SideBarMsg
view session =
    let
        viewChooser =
            if session.currentlyHoveredAboutMenuSidebarOption && session.expandedSideBar == Expanded then
                viewAboutMenuChooser session

            else
                none

        showLabels =
            showSideBarLabels session.expandedSideBar

        hoverSyles =
            if session.currentlyHoveredAboutMenuSidebarOption then
                Background.color colourScheme.white

            else
                emptyAttribute

        hoveredColour =
            if session.currentlyHoveredAboutMenuSidebarOption then
                colourScheme.darkBlue

            else
                colourScheme.white

        labelEl =
            el
                [ Font.color hoveredColour
                , Font.alignLeft
                , bodyRegular
                , alignLeft
                ]
                (text (extractLabelFromLanguageMap session.language localTranslations.aboutAndHelp))
    in
    row
        [ width fill
        , height shrink
        , alignLeft
        , alignBottom
        ]
        [ column
            [ alignLeft
            , alignTop
            , spacing 10
            , width fill
            ]
            [ row
                [ width fill
                , alignTop
                , paddingXY 22 10
                , spacing 10
                , pointer
                , onMouseEnter UserMouseEnteredAboutMenuSidebarOption
                , onMouseLeave UserMouseExitedAboutMenuSidebarOption
                , onRight viewChooser
                , hoverSyles
                , Font.color hoveredColour
                ]
                [ column
                    [ width fill
                    , alignLeft
                    ]
                    [ row
                        [ width fill
                        , spacing 10
                        ]
                        [ el
                            [ width (px 24)
                            , alignLeft
                            , centerY
                            ]
                            (infoCircleSvg hoveredColour)
                        , viewIf (animatedLabel labelEl) showLabels
                        ]
                    ]
                ]
            ]
        ]


viewAboutMenuChooser : Session -> Element SideBarMsg
viewAboutMenuChooser session =
    row
        [ width (px 80)
        , height (px 80)
        , moveUp 105
        ]
        [ animatedRow
            sidebarChooserAnimations
            [ width (px 250)

            --, height (px 150)
            , alignRight
            , Background.color colourScheme.white
            , Border.width 1
            , Border.color colourScheme.darkBlue
            , Border.shadow { blur = 6, color = colourScheme.darkGrey, offset = ( 2, 1 ), size = 1 }
            , htmlAttribute (HA.style "clip-path" "inset(-10px -15px -10px 0px)")
            ]
            [ column
                [ width fill
                , spacing 5
                ]
                [ aboutMenuChooserOption
                    { label = localTranslations.about
                    , session = session
                    , url = "/about"
                    }
                , aboutMenuChooserOption
                    { label = toLanguageMapWithLanguage English "Help"
                    , session = session
                    , url = "/about/help"
                    }
                , aboutMenuChooserOption
                    { label = toLanguageMapWithLanguage English "Viewing options"
                    , session = session
                    , url = "/about/options"
                    }
                ]
            ]
        ]


aboutMenuChooserOption :
    { label : LanguageMap
    , session : Session
    , url : String
    }
    -> Element SideBarMsg
aboutMenuChooserOption cfg =
    link
        [ width fill
        ]
        { label =
            row
                [ width fill

                --, paddingXY 30 10
                , spacing 10
                , paddingXY 10 15
                , pointer
                , Font.medium
                , mouseOver
                    [ Background.color colourScheme.lightGrey
                    ]
                , Font.color colourScheme.black
                , Background.color colourScheme.white
                ]
                [ text (extractLabelFromLanguageMap (.language cfg.session) cfg.label) ]
        , url = Config.serverUrl ++ cfg.url
        }
