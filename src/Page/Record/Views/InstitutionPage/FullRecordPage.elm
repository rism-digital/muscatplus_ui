module Page.Record.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, none, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTab)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


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
                    viewSourceSearchTab session.language model
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
                , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
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
                    [ pageHeaderTemplate session.language body
                    , viewRecordTopBarRouter session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> InstitutionBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    case body.sources of
        Just sourceBlock ->
            if sourceBlock.totalItems == 0 then
                none

            else
                viewRecordSourceSearchTabBar
                    { language = language
                    , searchUrl = sourceBlock.url
                    , model = model
                    , recordId = body.id
                    }

        Nothing ->
            none


viewDescriptionTab : Language -> InstitutionBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
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
            ]
        ]
