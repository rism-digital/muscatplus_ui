module Desktop.SideBar.Views exposing (viewRouter)

import Debouncer.Messages exposing (provideInput)
import Desktop.SideBar.AboutMenu as AboutMenu
import Desktop.SideBar.Icons exposing (sidebarRowBaseOptions, sidebarRowColumnBaseOptions)
import Desktop.SideBar.LanguageChooser exposing (viewLanguageChooserMenuOption)
import Desktop.SideBar.MenuOption exposing (menuOption)
import Desktop.SideBar.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, moveUp, none, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Lazy exposing (lazy2)
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.NavigationBar exposing (NavigationBar(..))
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels)
import Page.SideBar.Options exposing (SideBarOptions)
import Page.UI.Animations exposing (animatedColumn, animatedEl)
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (folderMusicSvg, institutionSvg, musicNotationSvg, onlineTextSvg, peopleSvg, rismLogo, sourcesSvg)
import Page.UI.Style exposing (colourScheme, headerHeight)
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P


dividingLine : Element msg
dividingLine =
    row
        [ width fill
        , height shrink
        , paddingXY 12 0
        , Background.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color colourScheme.white
            ]
            []
        ]


isCurrentlyHovered : Maybe NavigationBarOption -> NavigationBarOption -> Bool
isCurrentlyHovered hoveredOption thisOption =
    ME.unwrap False (\opt -> opt == thisOption) hoveredOption


viewRouter : Session -> Element SideBarMsg
viewRouter session =
    case session.navigationBar of
        SideBar options ->
            view session options

        BottomBar _ ->
            none


view : Session -> SideBarOptions -> Element SideBarMsg
view session options =
    let
        currentlyHoveredOption =
            options.currentlyHoveredOption

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
            options.expandedSideBar

        isExpanded =
            case sideBarAnimation of
                Expanded ->
                    True

                _ ->
                    False

        incipitsInterfaceMenuOption =
            menuOption
                { icon = musicNotationSvg
                , isCurrent = checkSelected IncipitSearchOption
                , isExpanded = isExpanded
                , isHovered = checkHover IncipitSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.incipits)
                , showLabel = showLabels
                }
                IncipitSearchOption

        -- If a national collection is chosen this will return
        -- false, indicating that the menu option should not
        -- be shown when a national collection is selected.
        institutionInterfaceMenuOption =
            menuOption
                { icon = institutionSvg
                , isCurrent = checkSelected InstitutionSearchOption
                , isExpanded = isExpanded
                , isHovered = checkHover InstitutionSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.institutions)
                , showLabel = showLabels
                }
                InstitutionSearchOption

        showWhenChoosingNationalCollection =
            ME.isNothing session.restrictedToNationalCollection

        peopleInterfaceMenuOption =
            viewIf
                (lazy2 menuOption
                    { icon = peopleSvg
                    , isCurrent = checkSelected PeopleSearchOption
                    , isExpanded = isExpanded
                    , isHovered = checkHover PeopleSearchOption
                    , label = text (extractLabelFromLanguageMap session.language localTranslations.people)
                    , showLabel = showLabels
                    }
                    PeopleSearchOption
                )
                showWhenChoosingNationalCollection

        showLabels =
            showSideBarLabels options.expandedSideBar

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
                , isExpanded = isExpanded
                , isHovered = checkHover SourceSearchOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.sources)
                , showLabel = showLabels
                }
                SourceSearchOption

        workCataloguesInterfaceMenuOption =
            menuOption
                { icon = folderMusicSvg
                , isCurrent = checkSelected WorkCatalogueNavigateOption
                , isExpanded = isExpanded
                , isHovered = checkHover WorkCatalogueNavigateOption
                , label = text (extractLabelFromLanguageMap session.language localTranslations.workCatalogues)
                , showLabel = showLabels
                }
                WorkCatalogueNavigateOption
    in
    animatedColumn
        sideAnimation
        [ width (px sidebarWidth)
        , height fill
        , alignTop
        , alignLeft
        , htmlAttribute (HA.style "z-index" "300")
        , Background.color colourScheme.white
        , onMouseEnter (UserMouseEnteredSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , onMouseLeave (UserMouseExitedSideBar |> provideInput |> ClientDebouncedSideBarMessages)
        , Border.shadow { blur = 4, color = colourScheme.translucentGrey, offset = ( 2, 1 ), size = 1 }
        , Region.navigation
        ]
        [ row
            [ width fill
            , height (px 80)
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
            sidebarRowBaseOptions
            [ column
                sidebarRowColumnBaseOptions
                [ viewNationalCollectionChooserMenuOption session options
                ]
            ]
        , dividingLine
        , viewLanguageChooserMenuOption session options
        , dividingLine
        , row
            sidebarRowBaseOptions
            [ column
                sidebarRowColumnBaseOptions
                [ sourcesInterfaceMenuOption
                , peopleInterfaceMenuOption
                , institutionInterfaceMenuOption
                , incipitsInterfaceMenuOption
                ]
            ]
        , dividingLine
        , row
            sidebarRowBaseOptions
            [ column
                sidebarRowColumnBaseOptions
                [ workCataloguesInterfaceMenuOption ]
            ]
        , row
            (sidebarRowBaseOptions ++ [ height fill ])
            [ column
                sidebarRowColumnBaseOptions
                [ AboutMenu.view session.language options ]
            ]
        ]
