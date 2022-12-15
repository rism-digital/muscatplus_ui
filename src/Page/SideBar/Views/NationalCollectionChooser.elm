module Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)

import Config
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, image, maximum, minimum, mouseOver, moveLeft, moveRight, none, onRight, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels)
import Page.UI.Animations exposing (animatedLabel, animatedRow)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, headingMD, lineSpacing, minimalDropShadow, sectionSpacing)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (globeSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P
import String.Extra as SE


imageForCountryCode : String -> Element msg
imageForCountryCode countryCode =
    let
        countryFlagImageName =
            Dict.get countryCode nationalCollectionPrefixToFlagMap
                |> Maybe.withDefault "xx.svg"

        countryFlagPath =
            Config.flagsPath ++ countryFlagImageName
    in
    image
        [ width (px 25) ]
        { description = countryCode
        , src = countryFlagPath
        }


nationalCollectionChooserAnimations =
    Animation.fromTo
        { duration = 150
        , options = [ Animation.delay 150 ]
        }
        [ P.opacity 0 ]
        [ P.opacity 1 ]


nationalCollectionPrefixToFlagMap : Dict String String
nationalCollectionPrefixToFlagMap =
    Dict.fromList
        [ ( "A", "at.svg" )
        , ( "AND", "ad.svg" )
        , ( "AUS", "au.svg" )
        , ( "B", "be.svg" )
        , ( "BOL", "bo.svg" )
        , ( "BR", "br.svg" )
        , ( "BY", "by.svg" )
        , ( "CDN", "ca.svg" )
        , ( "CH", "ch.svg" )
        , ( "CN", "cn.svg" )
        , ( "CO", "co.svg" )
        , ( "CZ", "cz.svg" )
        , ( "D", "de.svg" )
        , ( "DK", "dk.svg" )
        , ( "E", "es.svg" )
        , ( "EV", "ee.svg" )
        , ( "F", "fr.svg" )
        , ( "FIN", "fi.svg" )
        , ( "GB", "gb.svg" )
        , ( "GCA", "gt.svg" )
        , ( "GR", "gr.svg" )
        , ( "H", "hu.svg" )
        , ( "HK", "hk.svg" )
        , ( "HR", "hr.svg" )
        , ( "I", "it.svg" )
        , ( "IL", "il.svg" )
        , ( "IRL", "ie.svg" )
        , ( "J", "jp.svg" )
        , ( "LT", "lt.svg" )
        , ( "LV", "lv.svg" )
        , ( "M", "mt.svg" )
        , ( "MEX", "mx.svg" )
        , ( "N", "no.svg" )
        , ( "NL", "nl.svg" )
        , ( "NZ", "nz.svg" )
        , ( "P", "pt.svg" )
        , ( "PE", "pe.svg" )
        , ( "PL", "pl.svg" )
        , ( "RA", "ar.svg" )
        , ( "RC", "tw.svg" )
        , ( "RCH", "cl.svg" )
        , ( "RO", "ro.svg" )
        , ( "ROK", "kr.svg" )
        , ( "ROU", "uy.svg" )
        , ( "RP", "ph.svg" )
        , ( "RUS", "ru.svg" )
        , ( "S", "se.svg" )
        , ( "SI", "si.svg" )
        , ( "SK", "sk.svg" )
        , ( "UA", "ua.svg" )
        , ( "US", "us.svg" )
        , ( "V", "va.svg" )
        , ( "VE", "ve.svg" )
        , ( "XX", "xx.svg" )
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
        [ width (px 750)
        , height (px 200)
        , moveLeft 300
        ]
        [ animatedRow
            nationalCollectionChooserAnimations
            [ width (px 500)
            , alignRight
            , Background.color (colourScheme.white |> convertColorToElementColor)
            , height (shrink |> minimum 600 |> maximum 800)
            , minimalDropShadow
            , Font.color (colourScheme.black |> convertColorToElementColor)
            ]
            [ column
                [ width fill
                , height fill
                , spacing sectionSpacing
                , padding 30
                , scrollbarY
                ]
                [ row
                    [ width fill ]
                    [ el
                        [ alignTop
                        , headingLG
                        ]
                        (text (extractLabelFromLanguageMap session.language localTranslations.chooseCollection))
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
                                (globeSvg colourScheme.black)
                            , el
                                [ width fill
                                , headingMD
                                ]
                                (text (extractLabelFromLanguageMap session.language localTranslations.globalCollection))
                            ]
                        ]
                    ]
                , row
                    [ width fill ]
                    [ column
                        [ width fill ]
                        [ row
                            [ width fill ]
                            [ paragraph [] [ text (extractLabelFromLanguageMap session.language localTranslations.orChooseCollection) ] ]
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
                        (List.map (viewNationalCollectionRow session.language) groupedList)
                    ]
                ]
            ]
        ]


viewNationalCollectionChooserMenuOption : Session -> Element SideBarMsg
viewNationalCollectionChooserMenuOption session =
    let
        isRestrictedToNationalCollection =
            case session.restrictedToNationalCollection of
                Just _ ->
                    True

                Nothing ->
                    False

        labelFontColour =
            if isRestrictedToNationalCollection || session.currentlyHoveredNationalCollectionChooser then
                colourScheme.white

            else
                colourScheme.black

        hoverStyles =
            if session.currentlyHoveredNationalCollectionChooser then
                Background.color (colourScheme.lightBlue |> convertColorToElementColor)

            else
                emptyAttribute

        iconBackgroundColor =
            if isRestrictedToNationalCollection then
                Background.color (colourScheme.lightBlue |> convertColorToElementColor)

            else
                emptyAttribute

        iconLabel =
            case session.restrictedToNationalCollection of
                Just countryCode ->
                    case Dict.get countryCode session.allNationalCollections of
                        Just m ->
                            extractLabelFromLanguageMap session.language m

                        Nothing ->
                            extractLabelFromLanguageMap session.language localTranslations.globalCollection

                Nothing ->
                    extractLabelFromLanguageMap session.language localTranslations.globalCollection

        labelEl =
            el
                [ Font.color (labelFontColour |> convertColorToElementColor)
                , Font.alignLeft
                , headingLG
                , alignLeft
                ]
                (text (SE.softEllipsis 18 iconLabel))

        showLabels =
            showSideBarLabels session.expandedSideBar

        sidebarIcon =
            case session.restrictedToNationalCollection of
                Just countryCode ->
                    let
                        countryFlagImage =
                            imageForCountryCode countryCode
                    in
                    column
                        [ spacingXY 0 4
                        , width (px 45)
                        , Border.width 2
                        , padding 2
                        ]
                        [ el
                            [ width (px 25)
                            , centerX
                            , centerY
                            ]
                            countryFlagImage
                        , el
                            [ centerX
                            , centerY
                            , Font.bold
                            , headingMD
                            , Font.color (labelFontColour |> convertColorToElementColor)
                            ]
                            (text countryCode)
                        ]

                Nothing ->
                    column
                        [ width (px 45)
                        , Border.width 2
                        , padding 2
                        ]
                        [ el
                            [ width (px 25)
                            , centerX
                            , centerY
                            ]
                            (globeSvg labelFontColour)
                        ]

        viewChooser =
            if session.currentlyHoveredNationalCollectionChooser && session.expandedSideBar == Expanded then
                viewNationalCollectionChooser session

            else
                none

        ( iconCentering, iconAlignment ) =
            if session.expandedSideBar /= Expanded then
                ( centerX, 0 )

            else
                ( alignLeft, 21 )
    in
    row
        [ width fill
        , height (px 60)
        , alignTop
        , alignLeft
        , pointer
        , onRight viewChooser
        , onMouseEnter UserMouseEnteredCountryChooser
        , onMouseLeave UserMouseExitedCountryChooser
        , iconBackgroundColor
        , hoverStyles
        , Font.color (labelFontColour |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , alignLeft
            ]
            [ row
                [ width shrink
                , iconCentering
                , spacing lineSpacing
                , moveRight iconAlignment
                ]
                [ sidebarIcon
                , viewIf (animatedLabel labelEl) showLabels
                ]
            ]
        ]


viewNationalCollectionColumn : Language -> ( String, LanguageMap ) -> Element SideBarMsg
viewNationalCollectionColumn language ( abbr, label ) =
    column
        [ width fill
        , padding 10
        , mouseOver
            [ Background.color (colourScheme.lightGrey |> convertColorToElementColor) ]
        , onClick (UserChoseNationalCollection (Just abbr))
        ]
        [ row
            [ width fill ]
            [ column
                [ width (px 40) ]
                [ imageForCountryCode abbr ]
            , column
                [ width fill ]
                [ paragraph
                    [ spacing 1
                    , headingMD
                    ]
                    [ text (extractLabelFromLanguageMap language label ++ " (" ++ abbr ++ ")") ]
                ]
            ]
        ]


viewNationalCollectionRow : Language -> List ( String, LanguageMap ) -> Element SideBarMsg
viewNationalCollectionRow language collectionRow =
    row
        [ width fill
        ]
        (List.map (viewNationalCollectionColumn language) collectionRow)
