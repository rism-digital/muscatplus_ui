module Page.Record.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, padding, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


viewFullInstitutionPage :
    Session
    -> RecordPageModel
    -> InstitutionBody
    -> Element RecordMsg
viewFullInstitutionPage session page body =
    let
        pageBodyView =
            case page.currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab session.language body

                _ ->
                    none
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
                ]
                [ column
                    [ spacing lineSpacing
                    , width fill
                    , height fill
                    , alignTop
                    , padding 20
                    , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                    , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
                    , Background.color (colourScheme.cream |> convertColorToElementColor)
                    ]
                    [ pageHeaderTemplate session.language body
                    , pageUriTemplate session.language body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewDescriptionTab : Language -> InstitutionBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                (List.append
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    sectionBorderStyles
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
            , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
