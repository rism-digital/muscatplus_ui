module Desktop.SideBar.Views.LanguageChooser exposing (viewLanguageChooserMenuOption)

import Desktop.SideBar.Views.MenuOption exposing (sidebarChooserAnimations)
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fill, height, htmlAttribute, mouseOver, none, onRight, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language(..), languageOptions, parseLanguageToLabel)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels)
import Page.SideBar.Options exposing (SideBarOptions)
import Page.UI.Animations exposing (animatedLabel, animatedRow)
import Page.UI.Attributes exposing (bodyRegular, emptyAttribute)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (languagesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewLanguageChooser : Session -> Element SideBarMsg
viewLanguageChooser session =
    row
        [ width (px 80)
        , height (px 80)
        ]
        [ animatedRow
            sidebarChooserAnimations
            [ width (px 200)
            , alignRight
            , Background.color colourScheme.white
            , Font.color colourScheme.black
            , Events.onMouseEnter UserMouseEnteredCountryChooser
            , Events.onMouseLeave UserMouseExitedCountryChooser
            , Border.width 1
            , Border.color colourScheme.darkBlue
            , Border.shadow { blur = 6, color = colourScheme.darkGrey, offset = ( 2, 1 ), size = 1 }
            , htmlAttribute (HA.style "clip-path" "inset(-10px -15px -10px 0px)")
            ]
            [ column
                [ width fill
                , height fill
                ]
                languageCodeOptions
            ]
        ]


languageCodeOptions : List (Element SideBarMsg)
languageCodeOptions =
    List.map
        (\( c, _, l ) ->
            row
                [ width fill
                , spacing 10
                , padding 10
                , mouseOver
                    [ Background.color colourScheme.lightGrey
                    ]
                , Font.color colourScheme.black
                , Background.color colourScheme.white
                , Events.onClick (UserChoseLanguage l)
                ]
                [ el
                    [ Border.width 2
                    , Border.color colourScheme.darkGrey
                    , width (px 30)
                    , centerX
                    , centerY
                    , Font.center
                    , Font.bold
                    , Font.size 16
                    ]
                    (text (String.toUpper c))
                , el
                    [ width fill
                    ]
                    (text (parseLanguageToLabel l))
                ]
        )
        (List.filter (\( _, _, c ) -> c /= None) languageOptions)


viewLanguageChooserMenuOption : Session -> SideBarOptions -> Element SideBarMsg
viewLanguageChooserMenuOption session options =
    let
        viewChooser =
            if options.currentlyHoveredLanguageChooserSidebarOption && options.expandedSideBar == Expanded then
                viewLanguageChooser session

            else
                none

        showLabels =
            showSideBarLabels options.expandedSideBar

        hoverSyles =
            if options.currentlyHoveredLanguageChooserSidebarOption then
                Background.color colourScheme.white

            else
                emptyAttribute

        hoveredColour =
            if options.currentlyHoveredLanguageChooserSidebarOption then
                colourScheme.darkBlue

            else
                colourScheme.white

        labelEl =
            el
                [ Font.color hoveredColour
                , Font.alignLeft
                , bodyRegular
                , alignLeft
                ]
                (text (parseLanguageToLabel session.language))
    in
    row
        [ width fill
        , height (px 60)
        , alignLeft
        , centerY
        , Events.onMouseEnter UserMouseEnteredLanguageChooserSidebarOption
        , Events.onMouseLeave UserMouseExitedLanguageChooserSidebarOption
        , Background.color colourScheme.darkBlue
        ]
        [ column
            [ alignLeft
            , centerY
            , spacing 10
            , width fill
            ]
            [ row
                [ width fill
                , centerY
                , paddingXY 22 10
                , spacing 10
                , pointer
                , onRight viewChooser
                , hoverSyles
                , Font.color hoveredColour
                ]
                [ column
                    [ width fill
                    , alignLeft
                    ]
                    [ row
                        [ width fill
                        , spacing 10
                        ]
                        [ el
                            [ width (px 24)
                            , alignLeft
                            , centerY
                            ]
                            (languagesSvg hoveredColour)
                        , viewIf (animatedLabel labelEl) showLabels
                        ]
                    ]
                ]
            ]
        ]
