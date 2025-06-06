module Desktop.SideBar.MenuOption exposing (menuOption, sidebarChooserAnimations)

import Element exposing (Attribute, Color, Element, alignLeft, alignTop, centerY, el, fill, none, paddingXY, pointer, px, row, spacing, width)
import Element.Background as Background
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Page.RecordTypes.Navigation exposing (NavigationBarOption)
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
    , isHovered : Bool
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> NavigationBarOption
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
    in
    row
        [ width fill
        , alignTop
        , paddingXY 22 10
        , spacing 10
        , pointer
        , hoverStyles
        , selectedStyle
        , onClick (UserClickedSideBarOptionForFrontPage option)
        , onMouseEnter (UserMouseEnteredSideBarOption option)
        , onMouseLeave UserMouseExitedSideBarOption
        , Font.color fontColour
        ]
        [ el
            [ width (px 24)
            , alignLeft
            , centerY
            ]
            icon
        , viewIf (animatedLabel cfg.label) cfg.showLabel
        ]
