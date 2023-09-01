module Page.Record.Views.InstitutionPage.FullRecordPage exposing (viewFullInstitutionPage)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTab)
import Page.RecordTypes.Institution exposing (CoordinatesSection, InstitutionBody, LocationAddressSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h2, mapViewer, viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)
import Url.Builder as QB exposing (absolute)


viewDescriptionTab : Language -> InstitutionBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , spacing lineSpacing
                    ]
                    [ viewSummaryField language labels ]
                ]
    in
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
            [ viewMaybe summaryBody body.summary
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
                    viewSourceSearchTab session model
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
                , alignTop
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color (colourScheme.midGrey |> convertColorToElementColor)
                , Background.color (colourScheme.cream |> convertColorToElementColor)
                ]
                [ column
                    [ width (px 80) ]
                    [ el
                        [ width (px 50)
                        , height (px 50)
                        , centerX
                        , centerY
                        ]
                        (institutionSvg colourScheme.slateGrey)
                    ]
                , column
                    [ spacingXY 0 lineSpacing
                    , width fill
                    , height fill
                    , alignTop
                    , paddingXY 5 20
                    ]
                    [ pageHeaderTemplate session.language Nothing body
                    , viewRecordTopBarRouter session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBarRouter :
    Language
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewRecordTopBarRouter language model body =
    viewMaybe
        (\sourceBlock ->
            viewIf
                (viewRecordSourceSearchTabBar
                    { language = language
                    , model = model
                    , recordId = body.id
                    , searchUrl = sourceBlock.url
                    , tabLabel = localTranslations.sources
                    }
                )
                (sourceBlock.totalItems /= 0)
        )
        body.sources


viewLocationMapSection : Language -> LocationAddressSectionBody -> Element msg
viewLocationMapSection language location =
    let
        mapSection : Language -> CoordinatesSection -> Element msg
        mapSection lang coords =
            let
                coordsQ =
                    List.map2 (\dim val -> QB.string dim (String.fromFloat val)) [ "lon", "lat" ] coords.coordinates

                geoJsonQ =
                    QB.string "geo" coords.id

                mapsUrl =
                    (geoJsonQ :: coordsQ)
                        |> absolute [ "maps.html" ]
            in
            row
                [ width fill
                , height fill
                , paddingXY 0 20
                ]
                [ column
                    [ width fill
                    , height fill
                    , spacing 20
                    , alignTop
                    ]
                    [ row
                        [ width fill ]
                        [ h2 language coords.label ]
                    , row
                        [ width fill ]
                        [ mapViewer ( 900, 400 ) mapsUrl ]
                    ]
                ]
    in
    viewMaybe (mapSection language) location.coordinates
