module Page.SideBar.Views.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)

import Config
import Debouncer.Messages exposing (provideInput)
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, image, maximum, minimum, mouseOver, moveLeft, none, onRight, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.SideBar.Msg exposing (SideBarMsg(..), showSideBarLabels)
import Page.UI.Animations exposing (animatedLabel, animatedRow)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, headingMD, sectionSpacing)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (globeSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)
import Simple.Animation as Animation
import Simple.Animation.Property as P


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
    animatedRow
        nationalCollectionChooserAnimations
        [ width (px 500)
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , height (shrink |> minimum 600 |> maximum 800)
        , Border.width 1
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , moveLeft 20
        , Border.shadow
            { blur = 10
            , color =
                colourScheme.darkGrey
                    |> convertColorToElementColor
            , offset = ( 1, 1 )
            , size = 1
            }
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
            if isRestrictedToNationalCollection && session.currentlyHoveredNationalCollectionChooser /= True then
                colourScheme.white

            else
                colourScheme.black

        hoverStyles =
            if session.currentlyHoveredNationalCollectionChooser then
                Background.color (colourScheme.lightGrey |> convertColorToElementColor)

            else
                emptyAttribute

        iconBackgroundColor =
            if isRestrictedToNationalCollection then
                Background.color (colourScheme.darkGrey |> convertColorToElementColor)

            else
                emptyAttribute

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
            el
                [ Font.color (labelFontColour |> convertColorToElementColor)
                , headingLG
                ]
                (text iconLabel)

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
                        [ width (px 30)
                        , alignLeft
                        , centerY
                        ]
                        [ el
                            [ width (px 25)
                            , centerX
                            , centerY
                            ]
                            countryFlagImage
                        , el
                            [ width (px 40)
                            , centerX
                            , centerY
                            , Font.center
                            , Font.bold
                            , headingMD
                            , Font.color (labelFontColour |> convertColorToElementColor)
                            ]
                            (text countryCode)
                        ]

                Nothing ->
                    column
                        [ width (px 30)
                        , alignLeft
                        , centerY
                        ]
                        [ el
                            [ width (px 25)
                            , alignLeft
                            , centerY
                            ]
                            (globeSvg colourScheme.black)
                        ]

        viewChooser =
            if session.currentlyHoveredNationalCollectionChooser then
                viewNationalCollectionChooser session

            else
                none
    in
    row
        [ width fill
        , alignTop
        , spacing 10
        , paddingXY 30 10
        , pointer
        , onRight viewChooser
        , onMouseEnter (UserMouseEnteredCountryChooser |> provideInput |> ClientDebouncedNationalCollectionChooserMessages)
        , onMouseLeave UserMouseExitedCountryChooser
        , iconBackgroundColor
        , hoverStyles
        ]
        [ sidebarIcon
        , viewIf (animatedLabel labelEl) showLabels
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
        (List.map (\r -> viewNationalCollectionColumn language r) collectionRow)
