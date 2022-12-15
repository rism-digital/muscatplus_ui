module Page.SideBar.Views exposing (view)

import Color exposing (Color)
import Config
import Debouncer.Messages exposing (provideInput)
import Element exposing (Attribute, Element, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, link, moveUp, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Lazy exposing (lazy3)
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, parseLocaleToLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), showSideBarLabels)
import Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Page.UI.Animations exposing (animatedColumn, animatedLabel)
import Page.UI.Attributes exposing (emptyAttribute, minimalDropShadow)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (infoCircleSvg, institutionSvg, languagesSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
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
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            []
        ]


isCurrentlyHovered : Maybe SideBarOption -> SideBarOption -> Bool
isCurrentlyHovered hoveredOption thisOption =
    case hoveredOption of
        Just opt ->
            opt == thisOption

        Nothing ->
            False


menuOption :
    { icon : Color -> Element SideBarMsg
    , isCurrent : Bool
    , label : Element SideBarMsg
    , showLabel : Bool
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

        icon =
            cfg.icon fontColour

        newCfg =
            { icon = icon
            , isCurrent = cfg.isCurrent
            , label = cfg.label
            , showLabel = cfg.showLabel
            }

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
    in
    menuOptionTemplate newCfg additionalOptions


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
            :: spacing 10
            :: paddingXY 30 10
            :: pointer
            :: additionalAttributes
        )
        [ el
            [ width (px 25)
            , alignLeft
            , centerY
            ]
            cfg.icon
        , viewIf (animatedLabel cfg.label) cfg.showLabel
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
        , isCurrent = False
        , label = cfg.label
        , showLabel = cfg.showLabel
        }
        []


view : Session -> Element SideBarMsg
view session =
    let
        currentlyHoveredOption =
            session.currentlyHoveredOption

        checkHover opt =
            isCurrentlyHovered currentlyHoveredOption opt

        currentlySelectedOption =
            session.showFrontSearchInterface

        checkSelected opt =
            case session.route of
                FrontPageRoute _ ->
                    opt == currentlySelectedOption

                _ ->
                    False

        -- only show the selected option if we're on the front page.
        sideBarAnimation =
            session.expandedSideBar

        incipitsInterfaceMenuOption =
            menuOption
                { icon = musicNotationSvg
                , isCurrent = checkSelected IncipitSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.incipits)
                , showLabel = showLabels
                }
                IncipitSearchOption
                (checkHover IncipitSearchOption)

        institutionInterfaceMenuOption =
            menuOption
                { icon = institutionSvg
                , isCurrent = checkSelected InstitutionSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.institutions)
                , showLabel = showLabels
                }
                InstitutionSearchOption
                (checkHover InstitutionSearchOption)

        -- If a national collection is chosen this will return
        -- false, indicating that the menu option should not
        -- be shown when a national collection is selected.
        showWhenChoosingNationalCollection =
            case session.restrictedToNationalCollection of
                Just _ ->
                    False

                Nothing ->
                    True

        peopleInterfaceMenuOption =
            viewIf
                (lazy3 menuOption
                    { icon = peopleSvg
                    , isCurrent = checkSelected PeopleSearchOption
                    , label = text (extractLabelFromLanguageMap session.language localTranslations.people)
                    , showLabel = showLabels
                    }
                    PeopleSearchOption
                    (checkHover PeopleSearchOption)
                )
                showWhenChoosingNationalCollection

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
                        [ P.property "width" "280px" ]

                Collapsed ->
                    Animation.fromTo
                        { duration = 200
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.property "width" "280px" ]
                        [ P.property "width" "90px" ]

                NoAnimation ->
                    Animation.empty

        sourcesInterfaceMenuOption =
            menuOption
                { icon = sourcesSvg
                , isCurrent = checkSelected SourceSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.sources)
                , showLabel = showLabels
                }
                SourceSearchOption
                (checkHover SourceSearchOption)

        sideBarShadow =
            case sideBarAnimation of
                Expanded ->
                    minimalDropShadow

                _ ->
                    emptyAttribute
    in
    animatedColumn
        sideAnimation
        [ width (px 90)
        , height fill
        , alignTop
        , alignLeft
        , htmlAttribute (HA.style "z-index" "20")
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , onMouseEnter (UserMouseEnteredSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , onMouseLeave (UserMouseExitedSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , sideBarShadow
        ]
        [ row
            [ width fill
            , height (px 80)
            , paddingXY 15 10
            , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
            ]
            [ column
                [ alignTop
                , alignLeft
                , width fill
                ]
                [ row
                    [ width shrink
                    , spacing 8
                    ]
                    [ el
                        [ alignTop
                        , width fill
                        , pointer
                        , onClick (UserClickedSideBarOptionForFrontPage SourceSearchOption)
                        ]
                        (rismLogo colourScheme.white headerHeight)
                    , viewIf
                        (el
                            [ width (px 120)
                            , height (px 20)
                            , centerY
                            , moveUp 0.5
                            , pointer
                            , onClick (UserClickedSideBarOptionForFrontPage SourceSearchOption)
                            ]
                            (onlineTextSvg colourScheme.white)
                        )
                        showLabels
                    ]
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
        , row
            [ width fill
            , height shrink
            , alignLeft
            , alignBottom
            , paddingXY 0 20
            ]
            [ column
                [ alignLeft
                , alignTop
                , spacing 10
                ]
                [ menuOptionTemplate
                    { icon =
                        link
                            []
                            { label =
                                el
                                    [ width (px 25) ]
                                    (infoCircleSvg colourScheme.black)
                            , url = Config.serverUrl ++ "/about"
                            }
                    , isCurrent = False
                    , label =
                        link
                            []
                            { label = text (extractLabelFromLanguageMap session.language localTranslations.about)
                            , url = Config.serverUrl ++ "/about"
                            }
                    , showLabel = showLabels
                    }
                    []
                ]
            ]
        ]
