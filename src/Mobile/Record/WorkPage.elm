module Mobile.Record.WorkPage exposing (viewFullMobileWorkPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, paddingEach, px, row, scrollbarY, spacing, text, width)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Work exposing (FormOfWorkSectionBody, WorkBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (userMusicSvg)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.PartOfSection exposing (viewWorkPartOfCatalogueSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileWorkPage :
    Session
    -> RecordPageModel RecordMsg
    -> WorkBody
    -> Element RecordMsg
viewFullMobileWorkPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (userMusicSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar =
            viewRecordSourceSearchTabBar
                { body = body.sources
                , language = session.language
                , model = model
                , recordId = body.id
                , tabLabel = localTranslations.sources
                }
        , bodyView = chooseBody session model body
        }


chooseBody : Session -> RecordPageModel RecordMsg -> WorkBody -> Element RecordMsg
chooseBody session model body =
    case model.currentTab of
        ContentsSearchDisplayTab _ ->
            viewSourceSearchTabBody session model

        _ ->
            viewDescriptionTab session model body


viewDescriptionTab : Session -> RecordPageModel RecordMsg -> WorkBody -> Element RecordMsg
viewDescriptionTab session model body =
    row
        [ width fill
        , height fill
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
            , spacing sectionSpacing
            ]
            (pageBodyOrEmpty
                session.language
                False
                [ viewMaybe (viewWorkPartOfCatalogueSection session.language) body.partOf
                , viewMaybe
                    (viewCreator
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.creator
                , Maybe.withDefault [] body.summary
                    |> viewMobileSummaryField session.language
                , viewMaybe
                    (viewFormOfWorkSection
                        { language = session.language
                        , preRenderedFormatter = viewPreRenderedMobileSummaryField
                        }
                    )
                    body.formOfWork
                , viewMaybe
                    (viewRelationshipsSection
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewIncipitsSection
                        { language = session.language
                        , infoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , expandedIncipits = model.incipitInfoExpanded
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.incipits
                , viewMaybe
                    (viewReferencesNotesSection
                        { language = session.language
                        , paragraphFormatter = viewMobileParagraphField
                        , preRenderedFormatter = viewPreRenderedMobileSummaryField
                        }
                    )
                    body.referencesNotes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = session.language
                        , recordId = body.id
                        }
                    )
                    body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection session.language) body.externalAuthorities
                ]
            )
        ]


viewFormOfWorkSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : Language.LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> FormOfWorkSectionBody
    -> Element msg
viewFormOfWorkSection { language, preRenderedFormatter } formOfWorkSection =
    preRenderedFormatter language
        [ { label = formOfWorkSection.label
          , value = List.map (\it -> text (extractLabelFromLanguageMap language it.label)) formOfWorkSection.items
          }
        ]
