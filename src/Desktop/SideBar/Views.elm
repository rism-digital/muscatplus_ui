module Desktop.SideBar.Views exposing (view)

import Debouncer.Messages exposing (provideInput)
import Desktop.SideBar.Views.AboutMenu as AboutMenu
import Desktop.SideBar.Views.LanguageChooser exposing (viewLanguageChooserMenuOption)
import Desktop.SideBar.Views.MenuOption exposing (menuOption)
import Desktop.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, moveUp, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Lazy exposing (lazy3)
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), showSideBarLabels)
import Page.UI.Animations exposing (animatedColumn, animatedEl)
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme, headerHeight, recordTitleHeight, tabBarHeight)
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P


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
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 1 }
            , Border.color colourScheme.white
            ]
            []
        ]


isCurrentlyHovered : Maybe SideBarOption -> SideBarOption -> Bool
isCurrentlyHovered hoveredOption thisOption =
    ME.unwrap False (\opt -> opt == thisOption) hoveredOption


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
                , isHovered = checkHover IncipitSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.incipits)
                , showLabel = showLabels
                }
                IncipitSearchOption
                (checkHover IncipitSearchOption)

        -- If a national collection is chosen this will return
        -- false, indicating that the menu option should not
        -- be shown when a national collection is selected.
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
        , Border.shadow { blur = 4, color = colourScheme.darkBlueTranslucent, offset = ( 2, 1 ), size = 1 }
        ]
        [ row
            [ width fill
            , height (px (tabBarHeight + recordTitleHeight))
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
        , viewLanguageChooserMenuOption session
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
                [ AboutMenu.view session ]
            ]
        ]
