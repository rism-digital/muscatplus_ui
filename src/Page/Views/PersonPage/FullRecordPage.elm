module Page.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, htmlAttribute, link, none, padding, px, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.Model exposing (CurrentTab(..))
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Views.Relationship exposing (viewRelationshipsSection)


viewFullPersonPage : CurrentTab -> Language -> PersonBody -> Element Msg
viewFullPersonPage currentTab language body =
    let
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
                DefaultTab ->
                    viewDescriptionTab language body

                PersonSourcesTab ->
                    viewPersonSourcesTab language body
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
            , viewTabSwitcher language
            , pageBodyView
            ]
        ]


viewTabSwitcher : Language -> Element Msg
viewTabSwitcher language =
    row
        [ width fill
        , height (px 60)
        , spacing 20
        ]
        [ column
            [ Border.width 1
            , padding 12
            ]
            [ text "Description" ]
        , column
            [ Border.width 1
            , padding 12
            ]
            [ text "Sources" ]
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


viewPersonSourcesTab : Language -> PersonBody -> Element Msg
viewPersonSourcesTab language body =
    none
