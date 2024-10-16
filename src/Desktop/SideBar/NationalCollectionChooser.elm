module Desktop.SideBar.NationalCollectionChooser exposing (viewNationalCollectionChooserMenuOption)

import Config
import Desktop.SideBar.MenuOption exposing (sidebarChooserAnimations)
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, image, maximum, minimum, mouseOver, moveLeft, moveRight, none, onRight, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Maybe.Extra as ME
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels)
import Page.SideBar.Options exposing (SideBarOptions)
import Page.UI.Animations exposing (animatedLabel, animatedRow)
import Page.UI.Attributes exposing (bodyRegular, emptyAttribute, sectionSpacing)
import Page.UI.Components exposing (h2, h3)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (globeSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)
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
        [ width (px 18) ]
        { description = countryCode
        , src = countryFlagPath
        }


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
    List.sortBy
        (\( _, label ) ->
            extractLabelFromLanguageMap language label
                |> SE.removeDiacritics
        )
        countryList


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
        , height (px 80)
        , moveLeft 250
        ]
        [ animatedRow
            sidebarChooserAnimations
            [ width (px 500)
            , alignRight
            , Background.color colourScheme.white
            , height (shrink |> minimum 600 |> maximum 800)
            , Font.color colourScheme.black
            , onMouseEnter UserMouseEnteredCountryChooser
            , onMouseLeave UserMouseExitedCountryChooser
            , Border.width 1
            , Border.color colourScheme.darkBlue
            , Border.shadow { blur = 6, color = colourScheme.darkGrey, offset = ( 2, 1 ), size = 1 }
            , htmlAttribute (HA.style "clip-path" "inset(-10px -15px -10px 0px)")
            ]
            [ column
                [ width fill
                , height fill
                , spacing sectionSpacing
                , padding 30
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ row
                    [ width fill ]
                    [ h2 session.language localTranslations.chooseCollection ]
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
                            , mouseOver [ Background.color colourScheme.lightGrey ]
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
                                , bodyRegular
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
                            [ h3 session.language localTranslations.orChooseCollection ]
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


viewNationalCollectionChooserMenuOption : Session -> SideBarOptions -> Element SideBarMsg
viewNationalCollectionChooserMenuOption session options =
    let
        isRestrictedToNationalCollection =
            ME.isJust session.restrictedToNationalCollection

        labelFontColour =
            if isRestrictedToNationalCollection || options.currentlyHoveredNationalCollectionSidebarOption then
                colourScheme.darkBlue

            else
                colourScheme.white

        hoverStyles =
            if options.currentlyHoveredNationalCollectionSidebarOption then
                Background.color colourScheme.white

            else
                emptyAttribute

        iconBackgroundColor =
            if isRestrictedToNationalCollection then
                Background.color colourScheme.white

            else
                emptyAttribute

        globalCollectionLabel =
            extractLabelFromLanguageMap session.language localTranslations.globalCollection

        iconLabel =
            Maybe.map
                (\countryCode ->
                    Maybe.map (\m -> extractLabelFromLanguageMap session.language m) (Dict.get countryCode session.allNationalCollections)
                )
                session.restrictedToNationalCollection
                |> ME.join
                |> Maybe.withDefault globalCollectionLabel

        labelEl =
            el
                [ Font.color labelFontColour
                , Font.alignLeft
                , bodyRegular
                , alignLeft
                ]
                (text (SE.softEllipsis 20 iconLabel))

        showLabels =
            showSideBarLabels options.expandedSideBar

        sidebarIcon =
            case session.restrictedToNationalCollection of
                Just countryCode ->
                    let
                        countryFlagImage =
                            imageForCountryCode countryCode
                    in
                    column
                        [ width (px 35)
                        , Border.width 2
                        , padding 2
                        , spacing 2
                        ]
                        [ el
                            [ width (px 18)
                            , centerX
                            , centerY
                            ]
                            countryFlagImage
                        , el
                            [ centerX
                            , centerY
                            , Font.bold
                            , bodyRegular
                            , Font.color labelFontColour
                            ]
                            (text countryCode)
                        ]

                Nothing ->
                    column
                        [ width (px 35)
                        , Border.width 2
                        , padding 2
                        ]
                        [ el
                            [ width (px 18)
                            , centerX
                            , centerY
                            ]
                            (globeSvg labelFontColour)
                        ]

        viewChooser =
            if options.currentlyHoveredNationalCollectionSidebarOption && options.expandedSideBar == Expanded then
                viewNationalCollectionChooser session

            else
                none

        ( iconCentering, iconAlignment ) =
            if options.expandedSideBar /= Expanded then
                ( centerX, 0 )

            else
                ( alignLeft, 15 )
    in
    row
        [ width fill
        , height (px 60)
        , alignTop
        , alignLeft
        , pointer
        , onRight viewChooser
        , onMouseEnter UserMouseEnteredNationalCollectionSidebarOption
        , onMouseLeave UserMouseExitedNationalCollectionSidebarOption
        , iconBackgroundColor
        , hoverStyles
        , Font.color labelFontColour
        ]
        [ column
            [ width fill
            , alignLeft
            ]
            [ row
                [ width shrink
                , iconCentering
                , spacing 10
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
            [ Background.color colourScheme.lightGrey ]
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
                    , bodyRegular
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
