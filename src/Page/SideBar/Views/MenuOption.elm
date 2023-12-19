module Page.SideBar.Views.MenuOption exposing (menuOption, sidebarChooserAnimations)

import Element exposing (Attribute, Color, Element, alignLeft, alignTop, centerY, el, fill, paddingXY, pointer, px, row, spacing, width)
import Element.Background as Background
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Page.SideBar.Msg exposing (SideBarMsg(..), SideBarOption)
import Page.UI.Animations exposing (animatedLabel)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Style exposing (colourScheme)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utilities exposing (choose)


sidebarChooserAnimations : Animation
sidebarChooserAnimations =
    Animation.fromTo
        { duration = 150
        , options = [ Animation.delay 150 ]
        }
        [ P.opacity 0 ]
        [ P.opacity 1 ]


menuOptionTemplate :
    { icon : Element SideBarMsg
    , isCurrent : Bool
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> List (Attribute SideBarMsg)
    -> Element SideBarMsg
menuOptionTemplate cfg additionalAttributes =
    row
        (width fill
            :: alignTop
            :: paddingXY 22 10
            :: spacing 10
            :: pointer
            :: additionalAttributes
        )
        [ el
            [ width (px 24)
            , alignLeft
            , centerY
            ]
            cfg.icon
        , viewIf (animatedLabel cfg.label) cfg.showLabel
        ]


menuOption :
    { icon : Color -> Element SideBarMsg
    , isCurrent : Bool
    , isHovered : Bool
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> SideBarOption
    -> Bool
    -> Element SideBarMsg
menuOption cfg option currentlyHovered =
    let
        fontColour =
            if cfg.isCurrent && cfg.isHovered then
                colourScheme.darkBlue

            else if cfg.isCurrent || cfg.isHovered then
                colourScheme.darkBlue

            else
                colourScheme.white

        icon =
            cfg.icon fontColour

        newCfg =
            { icon = icon
            , isCurrent = cfg.isCurrent
            , label = cfg.label
            , showLabel = cfg.showLabel
            }

        hoverStyles =
            choose currentlyHovered
                (\() -> [ Background.color colourScheme.white ])
                (\() -> [])

        selectedStyle =
            choose cfg.isCurrent
                (\() -> [ Background.color colourScheme.white ])
                (\() -> [])

        additionalOptions =
            List.concat
                [ [ onClick (UserClickedSideBarOptionForFrontPage option)
                  , onMouseEnter (UserMouseEnteredSideBarOption option)
                  , onMouseLeave UserMouseExitedSideBarOption
                  , Font.color fontColour
                  ]
                , hoverStyles
                , selectedStyle
                ]
    in
    menuOptionTemplate newCfg additionalOptions
