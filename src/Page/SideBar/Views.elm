module Page.SideBar.Views exposing (..)

import Color exposing (Color)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, mouseOver, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Page.SideBar.Msg exposing (SideBarMsg(..), SideBarOption(..))
import Page.UI.Animations exposing (animatedColumn, animatedEl)
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (institutionSvg, languagesSvg, musicNotationSvg, peopleSvg, roLogoSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, headerHeight)
import Session exposing (AnimatedSideBar(..), Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P


animatedLabel : String -> Element msg
animatedLabel labelText =
    animatedEl
        (Animation.fromTo
            { duration = 300, options = [] }
            [ P.opacity 0.0 ]
            [ P.opacity 1.0 ]
        )
        [ headingMD
        , Font.medium
        ]
        (text labelText)


dividingLine : Element msg
dividingLine =
    row
        [ width fill
        , height shrink
        , paddingXY 15 0
        ]
        [ column
            [ width fill
            , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            []
        ]


menuOption :
    { option : SideBarOption
    , icon : Color -> Element SideBarMsg
    , label : String
    , showLabel : Bool
    , currentlyHovered : Bool
    }
    -> Element SideBarMsg
menuOption cfg =
    let
        fontColour =
            if cfg.currentlyHovered == True then
                colourScheme.white

            else
                colourScheme.slateGrey

        hoverStyles =
            if cfg.currentlyHovered == True then
                [ Background.color (colourScheme.lightBlue |> convertColorToElementColor)
                ]

            else
                []
    in
    row
        (List.append
            [ width fill
            , alignTop
            , spacing 10
            , paddingXY 30 10
            , Font.color (fontColour |> convertColorToElementColor)
            , onMouseEnter (UserMouseEnteredSideBarOption cfg.option)
            , onMouseLeave (UserMouseExitedSideBarOption cfg.option)
            , pointer
            , onClick (UserClickedSideBarOptionForFrontPage cfg.option)
            ]
            hoverStyles
        )
        [ el
            [ width (px 25)
            , alignLeft
            , centerY
            ]
            (cfg.icon fontColour)
        , viewIf (animatedLabel cfg.label) cfg.showLabel
        ]


isCurrentlyHovered : Maybe SideBarOption -> SideBarOption -> Bool
isCurrentlyHovered hoveredOption thisOption =
    case hoveredOption of
        Just opt ->
            opt == thisOption

        Nothing ->
            False


view : Session -> Element SideBarMsg
view session =
    let
        sideBarAnimation =
            session.expandedSideBar

        currentlyHoveredOption =
            session.currentlyHoveredOption

        checkHover opt =
            isCurrentlyHovered currentlyHoveredOption opt

        ( sideAnimation, showLabels ) =
            case sideBarAnimation of
                Expanding ->
                    ( Animation.fromTo
                        { duration = 200
                        , options = []
                        }
                        [ P.property "width" "90px" ]
                        [ P.property "width" "200px" ]
                    , True
                    )

                Collapsing ->
                    ( Animation.fromTo
                        { duration = 200
                        , options = []
                        }
                        [ P.property "width" "200px" ]
                        [ P.property "width" "90px" ]
                    , False
                    )

                NoAnimation ->
                    ( Animation.fromTo
                        { duration = 0
                        , options = []
                        }
                        []
                        []
                    , False
                    )
    in
    animatedColumn
        sideAnimation
        [ width (px 90)
        , height fill
        , alignTop
        , alignLeft
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.widthEach { left = 0, right = 2, top = 0, bottom = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , onMouseEnter UserMouseEnteredSideBar
        , onMouseLeave UserMouseExitedSideBar
        ]
        [ row
            [ width (px 60)
            , height (px 100)
            , alignLeft
            , paddingXY 0 20
            ]
            [ column
                [ alignTop
                , centerX
                ]
                [ el
                    [ centerY
                    , alignTop
                    , paddingXY 10 0
                    ]
                    (roLogoSvg (headerHeight + 10))
                ]
            ]
        , dividingLine
        , row
            [ width fill
            , height shrink
            , alignLeft
            , paddingXY 0 20
            ]
            [ column
                [ width fill
                , height fill
                , centerX
                , alignTop
                , spacing 10
                ]
                [ row
                    [ width fill
                    , alignTop
                    , spacing 10
                    , paddingXY 30 10
                    , Font.color (colourScheme.slateGrey |> convertColorToElementColor)
                    , mouseOver
                        [ Background.color (colourScheme.lightBlue |> convertColorToElementColor)
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        ]
                    , pointer
                    ]
                    [ el
                        [ width (px 25)
                        , alignLeft
                        , centerY
                        ]
                        (languagesSvg colourScheme.slateGrey)
                    ]
                ]
            ]
        , dividingLine
        , row
            [ width fill
            , height shrink
            , alignLeft
            , paddingXY 0 20
            ]
            [ column
                [ width fill
                , height fill
                , centerX
                , alignTop
                , spacing 10
                ]
                [ menuOption
                    { option = SourceSearchOption
                    , icon = sourcesSvg
                    , label = "Sources"
                    , showLabel = showLabels
                    , currentlyHovered = checkHover SourceSearchOption
                    }
                , menuOption
                    { option = PeopleSearchOption
                    , icon = peopleSvg
                    , label = "People"
                    , showLabel = showLabels
                    , currentlyHovered = checkHover PeopleSearchOption
                    }
                , menuOption
                    { option = InstitutionSearchOption
                    , icon = institutionSvg
                    , label = "Institutions"
                    , showLabel = showLabels
                    , currentlyHovered = checkHover InstitutionSearchOption
                    }
                , menuOption
                    { option = IncipitSearchOption
                    , icon = musicNotationSvg
                    , label = "Incipits"
                    , showLabel = showLabels
                    , currentlyHovered = checkHover IncipitSearchOption
                    }
                ]
            ]
        , dividingLine
        ]
