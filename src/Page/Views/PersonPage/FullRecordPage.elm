module Page.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, htmlAttribute, link, none, padding, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg(..))
import Page
import Page.Model exposing (CurrentRecordViewTab(..), Response(..))
import Page.RecordTypes.Person exposing (PersonBody)
import Page.Response exposing (ServerData(..))
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Views.PersonPage.SourcesTab exposing (viewPersonSourcesTab)
import Page.Views.Relationship exposing (viewRelationshipsSection)
import Page.Views.SearchPage exposing (viewSearchResultsList, viewSearchResultsListSection)


viewFullPersonPage :
    Page.Model
    -> Language
    -> PersonBody
    -> Element Msg
viewFullPersonPage page language body =
    let
        currentTab =
            page.currentTab

        searchData =
            page.pageSearch

        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

        pageBodyView =
            case currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab language body

                PersonSourcesRecordSearchTab _ ->
                    viewPersonSourcesTab language searchData
    in
    row
        [ width fill
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


viewTabSwitcher : Language -> PersonBody -> Element Msg
viewTabSwitcher language body =
    let
        sourcesTab =
            case body.sources of
                Just sources ->
                    column
                        [ Border.width 1
                        , padding 12
                        , onClick (UserClickedRecordViewTab (PersonSourcesRecordSearchTab sources.url))
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


viewDescriptionTab : Language -> PersonBody -> Element Msg
viewDescriptionTab language body =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewSummaryField language) body.summary
            , viewMaybe (viewNameVariantsSection language) body.nameVariants
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
