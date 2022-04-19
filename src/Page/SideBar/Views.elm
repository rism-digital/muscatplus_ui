module Page.SideBar.Views exposing (..)

import Color exposing (Color)
import Config
import Debouncer.Messages exposing (provideInput)
import Element exposing (Attribute, Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, link, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Lazy exposing (lazy3)
import Html.Attributes as HTA
import Language exposing (Language, languageOptionsForDisplay, parseLocaleToLanguage)
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), showSideBarLabels)
import Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Page.UI.Animations exposing (animatedColumn, animatedLabel)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (institutionSvg, languagesSvg, musicNotationSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, headerHeight)
import Session exposing (Session)
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
        { icon = cfg.icon colourScheme.black
        , label = cfg.label
        , showLabel = cfg.showLabel
        , isCurrent = False
        }
        []


menuOption :
    { icon : Color -> Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    , isCurrent : Bool
    }
    -> SideBarOption
    -> Bool
    -> Element SideBarMsg
menuOption cfg option currentlyHovered =
    let
        fontColour =
            if cfg.isCurrent then
                colourScheme.white

            else
                colourScheme.black

        hoverStyles =
            if currentlyHovered then
                [ Background.color (colourScheme.lightGrey |> convertColorToElementColor)
                ]

            else
                []

        selectedStyle =
            if cfg.isCurrent then
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
                , selectedStyle
                ]

        newCfg =
            { icon = icon
            , label = cfg.label
            , showLabel = cfg.showLabel
            , isCurrent = cfg.isCurrent
            }
    in
    menuOptionTemplate newCfg additionalOptions


menuOptionTemplate :
    { icon : Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    , isCurrent : Bool
    }
    -> List (Attribute SideBarMsg)
    -> Element SideBarMsg
menuOptionTemplate cfg additionalAttributes =
    row
        ([ width fill
         , alignTop
         , spacing 10
         , paddingXY 30 10
         , pointer
         ]
            ++ additionalAttributes
        )
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

        currentlySelectedOption =
            session.showFrontSearchInterface

        checkHover opt =
            isCurrentlyHovered currentlyHoveredOption opt

        -- only show the selected option if we're on the front page.
        checkSelected opt =
            case session.route of
                FrontPageRoute _ ->
                    opt == currentlySelectedOption

                _ ->
                    False

        showLabels =
            showSideBarLabels session.expandedSideBar

        sideAnimation =
            case sideBarAnimation of
                Expanded ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.property "width" "90px" ]
                        [ P.property "width" "250px" ]

                Collapsed ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.property "width" "250px" ]
                        [ P.property "width" "90px" ]

                NoAnimation ->
                    Animation.empty

        -- If a national collection is chosen this will return
        -- false, indicating that the menu option should not
        -- be shown when a national collection is selected.
        showWhenChoosingNationalCollection =
            case session.restrictedToNationalCollection of
                Just _ ->
                    False

                Nothing ->
                    True

        sourcesInterfaceMenuOption =
            menuOption
                { icon = sourcesSvg
                , label = text "Sources"
                , showLabel = showLabels
                , isCurrent = checkSelected SourceSearchOption
                }
                SourceSearchOption
                (checkHover SourceSearchOption)

        peopleInterfaceMenuOption =
            viewIf
                (lazy3 menuOption
                    { icon = peopleSvg
                    , label = text "People"
                    , showLabel = showLabels
                    , isCurrent = checkSelected PeopleSearchOption
                    }
                    PeopleSearchOption
                    (checkHover PeopleSearchOption)
                )
                showWhenChoosingNationalCollection

        institutionInterfaceMenuOption =
            menuOption
                { icon = institutionSvg
                , label = text "Institutions"
                , showLabel = showLabels
                , isCurrent = checkSelected InstitutionSearchOption
                }
                InstitutionSearchOption
                (checkHover InstitutionSearchOption)

        incipitsInterfaceMenuOption =
            viewIf
                (lazy3 menuOption
                    { icon = musicNotationSvg
                    , label = text "Incipits"
                    , showLabel = showLabels
                    , isCurrent = checkSelected IncipitSearchOption
                    }
                    IncipitSearchOption
                    (checkHover IncipitSearchOption)
                )
                showWhenChoosingNationalCollection
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
            , paddingXY 15 10
            ]
            [ column
                [ alignTop
                , alignLeft
                , width fill
                ]
                [ link
                    [ width fill
                    ]
                    { url = Config.serverUrl
                    , label =
                        el
                            [ alignTop
                            , width fill
                            ]
                            (rismLogo colourScheme.lightBlue headerHeight)
                    }
                ]
            ]
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
                            [ width fill
                            ]
                            (dropdownSelect
                                { selectedMsg = UserChangedLanguageSelect
                                , mouseDownMsg = Just UserMouseDownOnLanguageChooser
                                , mouseUpMsg = Just UserMouseUpOnLanguageChooser
                                , choices = languageOptionsForDisplay
                                , choiceFn = parseLocaleToLanguage
                                , currentChoice = session.language
                                , selectIdent = "site-language-select"
                                , label = Nothing
                                , language = session.language
                                }
                            )
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
                [ sourcesInterfaceMenuOption
                , peopleInterfaceMenuOption
                , institutionInterfaceMenuOption
                , incipitsInterfaceMenuOption
                ]
            ]
        , dividingLine
        ]
