module Desktop.Record.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)

import Desktop.Record.Views.SourceSearch exposing (viewRecordSearchSourcesLink, viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, none, padding, paddingXY, paragraph, px, row, scrollbarY, spacing, text, textColumn, width, wrappedRow)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (CoordinatesSection, InstitutionBody, LocationAddressSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, pageHeaderBackground, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes)
import Page.UI.Components exposing (mapViewer, pageBodyOrEmpty, renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (circleSvg, institutionSvg, mapMarkerSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)
import Url.Builder as QB exposing (absolute)


viewDescriptionTab : Language -> ( Int, Int ) -> InstitutionBody -> Element msg
viewDescriptionTab language ( windowWidth, windowHeight ) body =
    let
        isEmpty =
            ME.isNothing body.organizationDetails
                && ME.isNothing body.location
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities
                && ME.isNothing body.location

        pageBody =
            pageBodyOrEmpty language
                isEmpty
                [ viewMaybe (viewOrganizationDetailsSection language) body.organizationDetails
                , viewMaybe (viewLocationAddressSection language) body.location
                , viewMaybe (viewRelationshipsSection language) body.relationships
                , viewMaybe (viewNotesSection language) body.notes
                , viewMaybe (viewExternalResourcesSection language) body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                , viewMaybe (viewLocationMapSection language ( windowWidth, windowHeight )) body.location
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            pageBody
        ]


viewFullInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullInstitutionPage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab session.language session.window body

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTabBody session model

                PrintHoldingsTab _ ->
                    none

        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

            else
                px (tabBarHeight + recordTitleHeight)

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (institutionSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body

        tabBar =
            if session.isFramed then
                viewMaybe (viewRecordSearchSourcesLink session.language localTranslations.sources) body.sources

            else
                viewRecordTopBar session.language model body
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.darkBlue
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , pageHeaderBackground
                    ]
                    [ pageHeader
                    , tabBar
                    ]
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewRecordTopBar :
    Language
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewRecordTopBar language model body =
    viewRecordSourceSearchTabBar
        { body = body.sources
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sources
        }


mapSection : Language -> ( Int, Int ) -> CoordinatesSection -> Element msg
mapSection language ( windowWidth, windowHeight ) coords =
    let
        coordsValue =
            List.map String.fromFloat coords.coordinates
                |> String.join ", "

        coordsQ =
            List.map2 (\dim val -> QB.string dim (String.fromFloat val)) [ "lon", "lat" ] coords.coordinates

        geoJsonQ =
            QB.string "geo" coords.id

        mapsUrl =
            (geoJsonQ :: coordsQ)
                |> absolute [ "maps.html" ]

        sectionTmpl =
            sectionTemplate language coords
    in
    sectionTmpl
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                [ wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        labelFieldColumnAttributes
                        [ renderLabel language coords.coordinatesLabel ]
                    , column
                        valueFieldColumnAttributes
                        [ textColumn
                            [ spacing lineSpacing ]
                            [ text coordsValue ]
                        ]
                    ]
                , row
                    [ width fill ]
                    [ mapViewer ( min windowWidth 900, min windowHeight 400 ) mapsUrl ]
                , row
                    [ width fill ]
                    [ column
                        [ width fill
                        , spacing lineSpacing
                        ]
                        [ paragraph
                            [ width fill
                            , spacing 5
                            ]
                            [ el [ width (px 15), height (px 15) ] (mapMarkerSvg colourScheme.lightBlue)
                            , el [ paddingXY 5 0 ] (text (extractLabelFromLanguageMap language localTranslations.location))
                            ]
                        , paragraph
                            [ width fill
                            , spacing 5
                            ]
                            [ el [ width (px 15), height (px 15) ] (circleSvg colourScheme.darkOrange)
                            , el [ paddingXY 5 0 ] (text (extractLabelFromLanguageMap language localTranslations.nearbyInstitutions))
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewLocationMapSection : Language -> ( Int, Int ) -> LocationAddressSectionBody -> Element msg
viewLocationMapSection language ( windowWidth, windowHeight ) location =
    viewMaybe (mapSection language ( windowWidth, windowHeight )) location.coordinates
