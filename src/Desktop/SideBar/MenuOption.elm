module Desktop.SideBar.MenuOption exposing (menuOption, sidebarChooserAnimations)

import Desktop.SideBar.Icons exposing (sidebarIcon)
import Element exposing (Color, Element, alignLeft, alignTop, centerX, column, el, fill, height, moveRight, pointer, px, row, shrink, spacing, width)
import Element.Background as Background
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Page.RecordTypes.ResultMode exposing (ResultMode)
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Page.UI.Animations exposing (animatedLabel)
import Page.UI.Attributes exposing (emptyAttribute)
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


menuOption :
    { icon : Color -> Element SideBarMsg
    , isCurrent : Bool
    , isExpanded : Bool
    , isHovered : Bool
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> ResultMode
    -> Element SideBarMsg
menuOption cfg option =
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

        hoverStyles =
            choose cfg.isHovered
                (\() -> Background.color colourScheme.white)
                (\() -> emptyAttribute)

        selectedStyle =
            choose cfg.isCurrent
                (\() -> Background.color colourScheme.white)
                (\() -> emptyAttribute)

        optionLabel =
            el [ Font.alignLeft, alignLeft ] cfg.label

        menuOptionIcon =
            sidebarIcon [] icon

        ( iconCentering, iconAlignment ) =
            if cfg.isExpanded then
                ( alignLeft, 15 )

            else
                ( centerX, 0 )
    in
    row
        [ width fill
        , height (px 30)
        , alignTop
        , alignLeft
        , pointer
        , hoverStyles
        , selectedStyle
        , onClick (UserClickedSideBarOptionForFrontPage option)
        , onMouseEnter (UserMouseEnteredSideBarOption option)
        , onMouseLeave UserMouseExitedSideBarOption
        , Font.color fontColour
        ]
        [ column
            [ width fill
            , alignLeft
            ]
            [ row
                [ width shrink
                , iconCentering
                , spacing 10
                , moveRight iconAlignment
                ]
                [ menuOptionIcon
                , viewIf (animatedLabel optionLabel) cfg.showLabel
                ]
            ]
        ]
