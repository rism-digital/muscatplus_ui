module Page.SideBar.Views.NationalCollectionChooser exposing (..)

import Dict
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, maximum, minimum, mouseOver, moveLeft, none, onRight, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Page.UI.Animations exposing (animatedLabel)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, headingMD, sectionSpacing)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (flagSvg, globeSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session, SideBarAnimationStatus(..))


viewNationalCollectionChooserMenuOption : Session -> Element SideBarMsg
viewNationalCollectionChooserMenuOption session =
    let
        viewChooser =
            if session.currentlyHoveredNationalCollectionChooser == True then
                viewNationalCollectionChooser session

            else
                none

        sidebarIcon =
            case session.restrictedToNationalCollection of
                Just countryCode ->
                    column
                        [ width (px 30)
                        , centerX
                        , centerY
                        ]
                        [ el
                            [ width (px 25)
                            , centerX
                            , centerY
                            ]
                            (flagSvg colourScheme.white)
                        , el
                            [ width (px 25)
                            , centerX
                            , centerY
                            , Font.bold
                            , headingMD
                            , Font.color (colourScheme.white |> convertColorToElementColor)
                            ]
                            (text countryCode)
                        ]

                Nothing ->
                    column
                        [ width (px 30)
                        , centerX
                        , centerY
                        ]
                        [ el
                            [ width (px 25)
                            , centerX
                            , centerY
                            ]
                            (globeSvg colourScheme.slateGrey)
                        ]

        iconBackgroundColor =
            case session.restrictedToNationalCollection of
                Just _ ->
                    Background.color (colourScheme.turquoise |> convertColorToElementColor)

                Nothing ->
                    emptyAttribute

        showLabels =
            case session.expandedSideBar of
                Expanding ->
                    True

                Collapsing ->
                    False

                NoAnimation ->
                    False

        iconLabel =
            case session.restrictedToNationalCollection of
                Just countryCode ->
                    let
                        lmap =
                            Dict.get countryCode session.allNationalCollections
                    in
                    case lmap of
                        Just m ->
                            extractLabelFromLanguageMap session.language m

                        Nothing ->
                            extractLabelFromLanguageMap session.language localTranslations.globalCollection

                Nothing ->
                    extractLabelFromLanguageMap session.language localTranslations.globalCollection

        labelEl =
            case session.restrictedToNationalCollection of
                Just _ ->
                    el
                        [ Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingLG
                        ]
                        (text iconLabel)

                Nothing ->
                    el
                        [ Font.color (colourScheme.slateGrey |> convertColorToElementColor)
                        , headingLG
                        ]
                        (text iconLabel)
    in
    row
        [ width fill
        , alignTop
        , spacing 20
        , paddingXY 30 10
        , pointer
        , onRight viewChooser
        , onMouseEnter UserMouseEnteredCountryChooser
        , onMouseLeave UserMouseExitedCountryChooser
        , iconBackgroundColor
        ]
        [ sidebarIcon
        , viewIf (animatedLabel labelEl) showLabels
        ]


sortedByLocalizedCountryName : Language -> List ( String, LanguageMap ) -> List ( String, LanguageMap )
sortedByLocalizedCountryName language countryList =
    List.sortBy (\( _, label ) -> extractLabelFromLanguageMap language label) countryList


viewNationalCollectionChooser : Session -> Element SideBarMsg
viewNationalCollectionChooser session =
    let
        countryList =
            Dict.toList session.allNationalCollections

        sortedList =
            sortedByLocalizedCountryName session.language countryList

        groupedList =
            LE.greedyGroupsOf 2 sortedList
    in
    row
        [ width (px 500)
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , height (shrink |> minimum 600 |> maximum 800)
        , Border.width 1
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , moveLeft 20
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , spacing sectionSpacing
            , scrollbarY
            ]
            [ row
                [ width fill ]
                [ el
                    [ alignTop
                    , headingLG
                    ]
                    (text "Choose a collection to search")
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ row
                        [ width fill
                        , alignTop
                        , spacing 10
                        , paddingXY 10 10
                        , pointer
                        , mouseOver [ Background.color (colourScheme.lightGrey |> convertColorToElementColor) ]
                        , onClick (UserChoseNationalCollection Nothing)
                        ]
                        [ el
                            [ width (px 25)
                            , alignLeft
                            , centerY
                            ]
                            (globeSvg colourScheme.darkGrey)
                        , el
                            [ width fill
                            , headingMD
                            ]
                            (text "Global collection")
                        ]
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ row
                        [ width fill ]
                        [ paragraph [] [ text "Or choose a national collection" ] ]
                    ]
                ]
            , row
                [ width fill
                , height fill
                ]
                [ column
                    [ width fill
                    , height fill
                    ]
                    (List.map (\r -> viewNationalCollectionRow session.language r) groupedList)
                ]
            ]
        ]


viewNationalCollectionRow : Language -> List ( String, LanguageMap ) -> Element SideBarMsg
viewNationalCollectionRow language collectionRow =
    row
        [ width fill
        ]
        (List.map (\r -> viewNationalCollectionColumn language r) collectionRow)


viewNationalCollectionColumn : Language -> ( String, LanguageMap ) -> Element SideBarMsg
viewNationalCollectionColumn language ( abbr, label ) =
    column
        [ width fill
        , padding 10
        , mouseOver
            [ Background.color (colourScheme.lightGrey |> convertColorToElementColor) ]
        , onClick (UserChoseNationalCollection (Just abbr))
        ]
        [ paragraph
            [ spacing 1
            , headingMD
            ]
            [ text (extractLabelFromLanguageMap language label ++ " (" ++ abbr ++ ")") ]
        ]
