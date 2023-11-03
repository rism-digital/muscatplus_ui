module Page.SideBar.Views exposing (view)

import Config
import Debouncer.Messages exposing (provideInput)
import Element exposing (Attribute, Color, Element, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, link, moveUp, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Lazy exposing (lazy3)
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, parseLocaleToLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), showSideBarLabels)
import Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Page.UI.Animations exposing (animatedColumn, animatedEl, animatedLabel)
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (infoCircleSvg, institutionSvg, languagesSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme, headerHeight, searchHeaderHeight)
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P
import Utilities exposing (choose)


dividingLine : Element msg
dividingLine =
    row
        [ width fill
        , height shrink
        , paddingXY 15 0
        , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
        , Border.color colourScheme.darkBlue
        , Background.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
            , Border.color colourScheme.white
            ]
            []
        ]


isCurrentlyHovered : Maybe SideBarOption -> SideBarOption -> Bool
isCurrentlyHovered hoveredOption thisOption =
    ME.unwrap False (\opt -> opt == thisOption) hoveredOption


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


unlinkedMenuOption :
    { icon : Color -> Element SideBarMsg
    , label : Element SideBarMsg
    , showLabel : Bool
    }
    -> Element SideBarMsg
unlinkedMenuOption cfg =
    menuOptionTemplate
        { icon = cfg.icon colourScheme.white
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
        incipitsInterfaceMenuOption =
            menuOption
                { icon = musicNotationSvg
                , isCurrent = checkSelected IncipitSearchOption
                , isHovered = checkHover IncipitSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.incipits)
                , showLabel = showLabels
                }
                IncipitSearchOption
                (checkHover IncipitSearchOption)

        institutionInterfaceMenuOption =
            menuOption
                { icon = institutionSvg
                , isCurrent = checkSelected InstitutionSearchOption
                , isHovered = checkHover InstitutionSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.institutions)
                , showLabel = showLabels
                }
                InstitutionSearchOption
                (checkHover InstitutionSearchOption)

        -- If a national collection is chosen this will return
        -- false, indicating that the menu option should not
        -- be shown when a national collection is selected.
        showWhenChoosingNationalCollection =
            ME.isNothing session.restrictedToNationalCollection

        peopleInterfaceMenuOption =
            viewIf
                (lazy3 menuOption
                    { icon = peopleSvg
                    , isCurrent = checkSelected PeopleSearchOption
                    , isHovered = checkHover PeopleSearchOption
                    , label = text (extractLabelFromLanguageMap session.language localTranslations.people)
                    , showLabel = showLabels
                    }
                    PeopleSearchOption
                    (checkHover PeopleSearchOption)
                )
                showWhenChoosingNationalCollection

        showLabels =
            showSideBarLabels session.expandedSideBar

        sideBarAnimation =
            session.expandedSideBar

        sideAnimation =
            case sideBarAnimation of
                Expanded ->
                    Animation.fromTo
                        { duration = 60
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.property "width" "70px" ]
                        [ P.property "width" "210px" ]

                Collapsed ->
                    Animation.fromTo
                        { duration = 60
                        , options = [ Animation.easeInOutSine ]
                        }
                        [ P.property "width" "210px" ]
                        [ P.property "width" "70px" ]

                NoAnimation ->
                    Animation.empty

        logoAnimation =
            case sideBarAnimation of
                Expanded ->
                    Animation.fromTo
                        { duration = 300
                        , options =
                            [ Animation.easeInSine
                            ]
                        }
                        [ P.opacity 0.0
                        ]
                        [ P.opacity 1.0
                        ]

                Collapsed ->
                    Animation.fromTo
                        { duration = 50
                        , options =
                            [ Animation.easeOutSine
                            ]
                        }
                        [ P.opacity 1.0
                        ]
                        [ P.opacity 0.0
                        ]

                NoAnimation ->
                    Animation.empty

        sourcesInterfaceMenuOption =
            menuOption
                { icon = sourcesSvg
                , isCurrent = checkSelected SourceSearchOption
                , isHovered = checkHover SourceSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.sources)
                , showLabel = showLabels
                }
                SourceSearchOption
                (checkHover SourceSearchOption)
    in
    animatedColumn
        sideAnimation
        [ width (px sidebarWidth)
        , height fill
        , alignTop
        , alignLeft
        , htmlAttribute (HA.style "z-index" "20")
        , Background.color colourScheme.white
        , onMouseEnter (UserMouseEnteredSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , onMouseLeave (UserMouseExitedSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , Border.shadow { offset = ( 2, 1 ), size = 1, blur = 4, color = colourScheme.darkBlueTranslucent }
        ]
        [ row
            [ width fill
            , height (px searchHeaderHeight)
            , Background.color colourScheme.darkBlue
            ]
            [ column
                [ centerY
                , centerX
                ]
                [ row
                    [ width shrink
                    , spacing 10
                    ]
                    [ el
                        [ alignTop
                        , width fill
                        , pointer
                        , onClick (UserClickedSideBarOptionForFrontPage SourceSearchOption)
                        ]
                        (rismLogo colourScheme.white (headerHeight - 10))
                    , viewIf
                        (animatedEl
                            logoAnimation
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
            , paddingXY 0 10
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color colourScheme.darkBlue
            , Background.color colourScheme.darkBlue
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
            , paddingXY 0 10
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color colourScheme.darkBlue
            , Background.color colourScheme.darkBlue
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
                                , inverted = True
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
            , paddingXY 0 10
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color colourScheme.darkBlue
            , Background.color colourScheme.darkBlue
            ]
            [ column
                [ width fill
                , height fill
                , centerX
                , alignTop
                , spacing 2
                ]
                [ sourcesInterfaceMenuOption
                , peopleInterfaceMenuOption
                , institutionInterfaceMenuOption
                , incipitsInterfaceMenuOption
                ]
            ]
        , dividingLine
        , row
            [ height fill
            , width fill
            , Border.widthEach { bottom = 0, left = 0, right = 2, top = 0 }
            , Border.color colourScheme.darkBlue
            , Background.color colourScheme.darkBlue
            ]
            [ column
                [ height fill
                , width fill
                , paddingXY 0 10
                ]
                [ row
                    [ width fill
                    , height shrink
                    , alignLeft
                    , alignBottom
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
                                            [ width (px 20) ]
                                            (infoCircleSvg colourScheme.white)
                                    , url = Config.serverUrl ++ "/about"
                                    }
                            , isCurrent = session.route == AboutPageRoute
                            , label =
                                link
                                    [ Font.color colourScheme.white ]
                                    { label = text (extractLabelFromLanguageMap session.language localTranslations.about)
                                    , url = Config.serverUrl ++ "/about"
                                    }
                            , showLabel = showLabels
                            }
                            []
                        ]
                    ]
                ]
            ]
        ]
