module Desktop.Record.WorkPage exposing (viewFullWorkPage)

import Desktop.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, none, padding, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Work exposing (FormOfWorkSectionBody, WorkBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (userMusicSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewWorkPartOfCatalogueSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)
import Set exposing (Set)
import Url


viewFullWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullWorkPage session model body =
    let
        language =
            session.language

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (userMusicSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate language (Just icon) body

            else
                pageHeaderTemplate language (Just icon) body

        ( pageBodyView, showBottomShadow ) =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    ( viewDescriptionTab
                        { expandedIncipits = model.incipitInfoExpanded
                        , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , language = language
                        , currentUrl = Url.toString session.url
                        }
                        body
                    , True
                    )

                ContentsSearchDisplayTab _ ->
                    ( viewSourceSearchTabBody session model, False )

        tabBar =
            if session.isFramed then
                none

            else
                viewRecordSourceSearchTabBar
                    { body = body.sources
                    , language = language
                    , model = model
                    , recordId = body.id
                    , tabLabel = localTranslations.sources
                    }
    in
    row
        [ width fill
        , height fill
        , Region.mainContent
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ recordHeaderTemplate showBottomShadow
                [ pageHeader
                , tabBar
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewFormOfWorkSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> FormOfWorkSectionBody
    -> Element msg
viewFormOfWorkSection { language, preRenderedFormatter } formOfWorkSection =
    preRenderedFormatter language
        [ { label = formOfWorkSection.label
          , value = List.map (\it -> text (extractLabelFromLanguageMap language it.label)) formOfWorkSection.items
          }
        ]


viewDescriptionTab :
    { expandedIncipits : Set String
    , incipitInfoToggleMsg : String -> msg
    , language : Language
    , currentUrl : String
    }
    -> WorkBody
    -> Element RecordMsg
viewDescriptionTab { expandedIncipits, incipitInfoToggleMsg, language, currentUrl } body =
    let
        pageBody =
            pageBodyOrEmpty
                language
                False
                [ viewMaybe (viewWorkPartOfCatalogueSection language) body.partOf
                , viewMaybe
                    (viewCreator
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.creator
                , Maybe.withDefault [] body.summary
                    |> viewSummaryField language
                , viewMaybe
                    (viewFormOfWorkSection
                        { language = language
                        , preRenderedFormatter = viewPreRenderedSummaryField
                        }
                    )
                    body.formOfWork
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewIncipitsSection
                        { language = language
                        , infoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedIncipits = expandedIncipits
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.incipits
                , viewMaybe
                    (viewReferencesNotesSection
                        { language = language
                        , paragraphFormatter = viewParagraphField
                        , preRenderedFormatter = viewPreRenderedSummaryField
                        }
                    )
                    body.referencesNotes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = language
                        , currentUrl = currentUrl
                        }
                    )
                    body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , spacing sectionSpacing
            , alignTop
            , padding 20
            ]
            pageBody
        ]
