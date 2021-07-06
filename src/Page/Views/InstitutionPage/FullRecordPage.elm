module Page.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg(..))
import Page
import Page.Model exposing (CurrentRecordViewTab(..))
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.InstitutionPage.SourcesTab exposing (viewInstitutionSourcesTab)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Views.Relationship exposing (viewRelationshipsSection)


viewFullInstitutionPage :
    Page.Model
    -> Language
    -> InstitutionBody
    -> Element Msg
viewFullInstitutionPage page language body =
    let
        currentTab =
            page.currentTab

        searchData =
            page.searchResults

        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ linkColour ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

        pageBodyView =
            case currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab language body

                InstitutionSourcesRecordSearchTab _ ->
                    viewInstitutionSourcesTab language searchData

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
            [ row
                [ width fill
                , htmlAttribute (HTA.id body.sectionToc)
                ]
                [ h4 language body.label ]
            , recordUri
            , viewTabSwitcher language body
            , pageBodyView
            ]
        ]


viewTabSwitcher : Language -> InstitutionBody -> Element Msg
viewTabSwitcher language body =
    let
        sourcesTab =
            case body.sources of
                Just sources ->
                    column
                        [ Border.width 1
                        , padding 12
                        , onClick (UserClickedRecordViewTab (InstitutionSourcesRecordSearchTab sources.url))
                        ]
                        [ el
                            []
                            (text "Sources")
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill
        , height (px 60)
        , spacing 20
        ]
        [ column
            [ Border.width 1
            , padding 12
            , onClick (UserClickedRecordViewTab DefaultRecordViewTab)
            ]
            [ text "Description" ]
        , sourcesTab
        ]


viewDescriptionTab : Language -> InstitutionBody -> Element Msg
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
