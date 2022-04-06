module Page.Record.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, none, padding, pointer, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Language exposing (Language, formatNumberByLanguage)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)
import Page.Record.Views.InstitutionPage.SourceSearch exposing (viewSourceSearchTab)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (headingSM, lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
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
                    viewSourceSearchTab session.language model body
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
                viewRecordTabBar language sourceBlock.url model body

        Nothing ->
            none


viewRecordTabBar : Language -> String -> RecordPageModel RecordMsg -> InstitutionBody -> Element RecordMsg
viewRecordTabBar language searchUrl model body =
    let
        currentMode =
            model.currentTab

        sourceLabel =
            case model.searchResults of
                Response (SearchData searchData) ->
                    let
                        sourceCount =
                            toFloat searchData.totalItems
                                |> formatNumberByLanguage language
                    in
                    "Sources (" ++ sourceCount ++ ")"

                _ ->
                    "Sources"

        descriptionTabBorder =
            case currentMode of
                DefaultRecordViewTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor

        searchTabBorder =
            case currentMode of
                RelatedSourcesSearchTab _ ->
                    colourScheme.lightBlue |> convertColorToElementColor

                _ ->
                    colourScheme.cream |> convertColorToElementColor
    in
    row
        [ centerX
        , width fill
        , height (px 25)
        , spacing 15
        ]
        [ el
            [ width shrink
            , height fill
            , Font.center
            , alignLeft
            , pointer
            , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
            , Border.color descriptionTabBorder
            ]
            (button
                []
                { onPress = Just <| UserClickedRecordViewTab (DefaultRecordViewTab body.id)
                , label = text "Description"
                }
            )
        , el
            [ width shrink
            , height fill
            , alignLeft
            , centerY
            , pointer
            , headingSM
            , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
            , Border.color searchTabBorder
            ]
            (button
                []
                { onPress = Just <| UserClickedRecordViewTab (RelatedSourcesSearchTab searchUrl)
                , label = text sourceLabel
                }
            )
        ]


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
