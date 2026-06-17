module Page.UI.Record.Bodies.Work exposing (viewWorkSections)

import Element exposing (Element, text)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Work exposing (FormOfWorkSectionBody, WorkBody)
import Page.UI.Components exposing (pageBodyOrEmpty)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewCreator)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.PartOfSection exposing (viewWorkPartOfCatalogueSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Set exposing (Set)


viewWorkSections :
    { expandedIncipits : Set String
    , incipitInfoToggleMsg : String -> msg
    , language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , recordId : String
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> WorkBody
    -> List (Element msg)
viewWorkSections { expandedIncipits, incipitInfoToggleMsg, language, paragraphFormatter, preRenderedFormatter, recordId, relationshipFormatter, summaryFormatter } body =
    pageBodyOrEmpty
        language
        False
        [ viewMaybe (viewWorkPartOfCatalogueSection language) body.partOf
        , viewMaybe
            (viewCreator
                { language = language
                , relationshipFormatter = relationshipFormatter
                }
            )
            body.creator
        , Maybe.withDefault [] body.summary
            |> summaryFormatter language
        , viewMaybe
            (viewFormOfWorkSection
                { language = language
                , preRenderedFormatter = preRenderedFormatter
                }
            )
            body.formOfWork
        , viewMaybe
            (viewRelationshipsSection
                { language = language
                , relationshipFormatter = relationshipFormatter
                }
            )
            body.relationships
        , viewMaybe
            (viewIncipitsSection
                { language = language
                , infoToggleMsg = incipitInfoToggleMsg
                , expandedIncipits = expandedIncipits
                , summaryFormatter = summaryFormatter
                }
            )
            body.incipits
        , viewMaybe
            (viewReferencesNotesSection
                { language = language
                , paragraphFormatter = paragraphFormatter
                , preRenderedFormatter = preRenderedFormatter
                }
            )
            body.referencesNotes
        , viewMaybe
            (viewExternalResourcesSection
                { language = language
                , recordId = recordId
                }
            )
            body.externalResources
        , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
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
