module Page.Record.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, paragraph, px, row, scrollbarY, spacing, text, textColumn, width, wrappedRow)
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Page.RecordTypes.Institution exposing (CoordinatesSection, InstitutionBody, LocationAddressSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, pageHeaderBackground, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes)
import Page.UI.Components exposing (mapViewer, renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (circleSvg, institutionSvg, mapMarkerSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, tabBarHeight)
import Session exposing (Session)
import Url.Builder as QB exposing (absolute)


viewDescriptionTab : Language -> InstitutionBody -> Element msg
viewDescriptionTab language body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            [ viewMaybe (viewOrganizationDetailsSection language) body.organizationDetails
            , viewMaybe (viewLocationAddressSection language) body.location
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewLocationMapSection language) body.location
            ]
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
                    viewDescriptionTab session.language body

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTabBody session model

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (institutionSvg colourScheme.darkBlue)
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
                , height (px (tabBarHeight + recordTitleHeight))
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
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
                    [ pageHeaderTemplate session.language (Just icon) body
                    , viewRecordTopBar session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBar :
    Language
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewRecordTopBar language model body =
    viewRecordSourceSearchTabBar
        { language = language
        , model = model
        , recordId = body.id
        , body = body.sources
        , tabLabel = localTranslations.sources
        }


mapSection : Language -> CoordinatesSection -> Element msg
mapSection language coords =
    let
        coordsQ =
            List.map2 (\dim val -> QB.string dim (String.fromFloat val)) [ "lon", "lat" ] coords.coordinates

        geoJsonQ =
            QB.string "geo" coords.id

        coordsValue =
            List.map String.fromFloat coords.coordinates
                |> String.join ", "

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
                    [ mapViewer ( 900, 400 ) mapsUrl ]
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


viewLocationMapSection : Language -> LocationAddressSectionBody -> Element msg
viewLocationMapSection language location =
    viewMaybe (mapSection language) location.coordinates
