module Page.Record.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, alignBottom, alignRight, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.InstitutionPage.SourcesTab exposing (viewInstitutionSourcesTab)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h1, h4, viewRecordHistory, viewSummaryField)
import Page.UI.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Notes exposing (viewNotesSection)
import Page.UI.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate)
import Page.UI.Relationship exposing (viewRelationshipsSection)
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

        searchData =
            page.searchResults

        searchParams =
            page.activeSearch

        pageBodyView =
            case currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab language body

                InstitutionSourcesRecordSearchTab sourcesUrl ->
                    viewInstitutionSourcesTab language sourcesUrl searchParams searchData

                _ ->
                    none
    in
    row
        [ width (fill |> minimum 800 |> maximum 1400)
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 5
            ]
            [ pageHeaderTemplate language body
            , pageUriTemplate language body
            , viewTabSwitcher language currentTab body
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
                            formatNumberByLanguage (toFloat sources.totalItems) language
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
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewSummaryField language) body.summary
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
