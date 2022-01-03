module Page.SideBar.Views exposing (..)

import Color exposing (Color)
import Debouncer.Messages exposing (provideInput)
import Element exposing (Attribute, Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (languageOptionsForDisplay, parseLocaleToLanguage)
import Page.SideBar.Msg exposing (SideBarMsg(..), SideBarOption(..))
import Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Page.UI.Animations exposing (animatedColumn, animatedLabel)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (institutionSvg, languagesSvg, musicNotationSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, headerHeight)
import Session exposing (Session, SideBarAnimationStatus(..))
import Simple.Animation as Animation
import Simple.Animation.Property as P


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


unlinkedMenuOption :
    { icon : Color -> Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> Element SideBarMsg
unlinkedMenuOption cfg =
    menuOptionTemplate
        { icon = cfg.icon colourScheme.slateGrey
        , label = cfg.label
        , showLabel = cfg.showLabel
        }
        []


menuOption :
    { icon : Color -> Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> SideBarOption
    -> Bool
    -> Element SideBarMsg
menuOption cfg option currentlyHovered =
    let
        fontColour =
            if currentlyHovered == True then
                colourScheme.white

            else
                colourScheme.slateGrey

        hoverStyles =
            if currentlyHovered == True then
                [ Background.color (colourScheme.lightBlue |> convertColorToElementColor)
                ]

            else
                []

        icon =
            cfg.icon fontColour

        additionalOptions =
            List.concat
                [ [ onClick (UserClickedSideBarOptionForFrontPage option)
                  , onMouseEnter (UserMouseEnteredSideBarOption option)
                  , onMouseLeave (UserMouseExitedSideBarOption option)
                  , Font.color (fontColour |> convertColorToElementColor)
                  ]
                , hoverStyles
                ]

        newCfg =
            { icon = icon
            , label = cfg.label
            , showLabel = cfg.showLabel
            }
    in
    menuOptionTemplate newCfg additionalOptions


menuOptionTemplate :
    { icon : Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> List (Attribute SideBarMsg)
    -> Element SideBarMsg
menuOptionTemplate cfg additionalAttributes =
    let
        rowAttributes =
            [ width fill
            , alignTop
            , spacing 10
            , paddingXY 30 10
            , pointer
            ]
    in
    row
        (List.concat [ rowAttributes, additionalAttributes ])
        [ el
            [ width (px 25)
            , alignLeft
            , centerY
            ]
            cfg.icon
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
                        [ P.property "width" "250px" ]
                    , True
                    )

                Collapsing ->
                    ( Animation.fromTo
                        { duration = 200
                        , options = []
                        }
                        [ P.property "width" "250px" ]
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
        , htmlAttribute <| HTA.style "z-index" "20"
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.widthEach { left = 0, right = 2, top = 0, bottom = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , onMouseEnter (UserMouseEnteredSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , onMouseLeave (UserMouseExitedSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        ]
        [ row
            [ width (px 60)
            , height (px 80)
            , centerX
            , paddingXY 0 10
            ]
            [ column
                [ alignTop
                , centerX
                ]
                [ el
                    [ centerY
                    , alignTop
                    ]
                    (rismLogo colourScheme.lightBlue headerHeight)
                ]
            ]
        , row
            [ width fill
            , height shrink
            , alignLeft
            , paddingXY 0 10
            ]
            [ column
                [ width fill
                , height fill
                , centerX
                , alignTop
                , spacing 10
                ]
                [ viewNationalCollectionChooserMenuOption session ]
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
                [ unlinkedMenuOption
                    { icon = languagesSvg
                    , label =
                        el
                            [ width fill ]
                            (dropdownSelect UserChangedLanguageSelect languageOptionsForDisplay parseLocaleToLanguage session.language)
                    , showLabel = showLabels
                    }
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
                    { icon = sourcesSvg
                    , label = text "Sources"
                    , showLabel = showLabels
                    }
                    SourceSearchOption
                    (checkHover SourceSearchOption)
                , menuOption
                    { icon = peopleSvg
                    , label = text "People"
                    , showLabel = showLabels
                    }
                    PeopleSearchOption
                    (checkHover PeopleSearchOption)
                , menuOption
                    { icon = institutionSvg
                    , label = text "Institutions"
                    , showLabel = showLabels
                    }
                    InstitutionSearchOption
                    (checkHover InstitutionSearchOption)
                , menuOption
                    { icon = musicNotationSvg
                    , label = text "Incipits"
                    , showLabel = showLabels
                    }
                    IncipitSearchOption
                    (checkHover IncipitSearchOption)
                ]
            ]
        , dividingLine
        ]
