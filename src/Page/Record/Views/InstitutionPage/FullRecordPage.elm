module Page.Record.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, none, padding, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, formatNumberByLanguage)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewFullInstitutionPage :
    Language
    -> RecordPageModel
    -> InstitutionBody
    -> Element RecordMsg
viewFullInstitutionPage language page body =
    let
        currentTab =
            page.currentTab

        pageBodyView =
            case currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab language body

                _ ->
                    none
    in
    row
        widthFillHeightFill
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
                    ]
                ]

            --, viewTabSwitcher language currentTab body
            , pageBodyView
            , pageFooterTemplate language body
            ]
        ]


viewTabSwitcher :
    Language
    -> CurrentRecordViewTab
    -> InstitutionBody
    -> Element RecordMsg
viewTabSwitcher language currentTab body =
    let
        descriptionTab =
            let
                ( backgroundColour, fontColour ) =
                    case currentTab of
                        DefaultRecordViewTab ->
                            ( colourScheme.lightBlue, colourScheme.white )

                        _ ->
                            ( colourScheme.white, colourScheme.black )
            in
            column
                [ Border.width 1
                , padding 12
                , onClick (UserClickedRecordViewTab DefaultRecordViewTab)
                , pointer
                , Background.color (backgroundColour |> convertColorToElementColor)
                , Font.color (fontColour |> convertColorToElementColor)
                ]
                [ el
                    []
                    (text "Description")
                ]

        sourcesTab =
            case body.sources of
                Just sources ->
                    let
                        ( backgroundColour, fontColour ) =
                            case currentTab of
                                InstitutionSourcesRecordSearchTab _ ->
                                    ( colourScheme.lightBlue, colourScheme.white )

                                _ ->
                                    ( colourScheme.white, colourScheme.black )

                        sourceCount =
                            toFloat sources.totalItems
                                |> formatNumberByLanguage language
                    in
                    column
                        [ Border.width 1
                        , padding 12
                        , onClick (UserClickedRecordViewTab (InstitutionSourcesRecordSearchTab sources.url))
                        , pointer
                        , Background.color (backgroundColour |> convertColorToElementColor)
                        , Font.color (fontColour |> convertColorToElementColor)
                        ]
                        [ el
                            []
                            (text ("Sources (" ++ sourceCount ++ ")"))
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill
        , height (px 60)
        , spacing 20
        ]
        [ descriptionTab
        , sourcesTab
        ]


viewDescriptionTab : Language -> InstitutionBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ viewSummaryField language labels ]
                ]
    in
    row
        widthFillHeightFill
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ viewMaybe summaryBody body.summary
            , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
