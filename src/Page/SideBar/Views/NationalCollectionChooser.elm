module Page.SideBar.Views.NationalCollectionChooser exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, image, maximum, minimum, mouseOver, moveLeft, none, onRight, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Page.UI.Animations exposing (animatedLabel)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, headingMD, lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (globeSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session, SideBarAnimationStatus(..))


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


imageForCountryCode : String -> Element msg
imageForCountryCode countryCode =
    let
        countryFlagImageName =
            Dict.get countryCode nationalCollectionPrefixToFlagMap
                |> Maybe.withDefault "xx.svg"

        countryFlagPath =
            "/static/images/flags/" ++ countryFlagImageName
    in
    image
        [ width (px 25) ]
        { src = countryFlagPath
        , description = countryCode
        }


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
                    let
                        countryFlagImage =
                            imageForCountryCode countryCode
                    in
                    column
                        [ width (px 30)
                        , centerX
                        , centerY
                        , spacing lineSpacing
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
                    Background.color (colourScheme.midGrey |> convertColorToElementColor)

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
