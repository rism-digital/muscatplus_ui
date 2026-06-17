module Page.UI.Record.Bodies.Source exposing (viewSourceSections)

import Dict
import Element exposing (Element)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewSourceWorksSection)
import Set exposing (Set)


viewSourceSections :
    { expandedDigitizedCopiesCallout : Bool
    , expandedDigitizedCopiesMsg : msg
    , expandedIncipits : Set String
    , extraSectionsAfterReferencesNotes : List (Element msg)
    , includeDigitalObjects : Bool
    , incipitInfoToggleMsg : String -> msg
    , language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , recordId : String
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> FullSourceBody
    -> List (Element msg)
viewSourceSections { expandedDigitizedCopiesCallout, expandedDigitizedCopiesMsg, expandedIncipits, extraSectionsAfterReferencesNotes, includeDigitalObjects, incipitInfoToggleMsg, language, paragraphFormatter, preRenderedFormatter, recordId, relationshipFormatter, summaryFormatter } body =
    let
        allExternals =
            gatherAllDigitizationLinksForCallout language body
    in
    viewMaybe (viewPartOfSection language) body.partOf
        :: viewIf
            (viewDigitizedCopiesCalloutSection
                { expandMsg = expandedDigitizedCopiesMsg
                , expanded = expandedDigitizedCopiesCallout
                , language = language
                , recordId = recordId
                }
                allExternals
            )
            (not (Dict.isEmpty allExternals))
        :: viewMaybe
            (viewContentsSection
                { creator = body.creator
                , language = language
                , preRenderedFormatter = preRenderedFormatter
                , relationshipFormatter = relationshipFormatter
                , summaryFormatter = summaryFormatter
                }
            )
            body.contents
        :: viewMaybe
            (viewIncipitsSection
                { language = language
                , infoToggleMsg = incipitInfoToggleMsg
                , expandedIncipits = expandedIncipits
                , summaryFormatter = summaryFormatter
                }
            )
            body.incipits
        :: viewMaybe
            (viewMaterialGroupsSection
                { language = language
                , paragraphFormatter = paragraphFormatter
                , recordId = recordId
                , relationshipFormatter = relationshipFormatter
                , summaryFormatter = summaryFormatter
                }
            )
            body.materialGroups
        :: viewMaybe
            (viewRelationshipsSection
                { language = language
                , relationshipFormatter = relationshipFormatter
                }
            )
            body.relationships
        :: viewMaybe
            (viewSourceWorksSection
                { language = language
                , preRenderedFormatter = preRenderedFormatter
                }
            )
            body.works
        :: viewMaybe
            (viewReferencesNotesSection
                { language = language
                , paragraphFormatter = paragraphFormatter
                , preRenderedFormatter = preRenderedFormatter
                }
            )
            body.referencesNotes
        :: extraSectionsAfterReferencesNotes
        ++ viewMaybe
            (viewExternalResourcesSection
                { language = language
                , recordId = recordId
                }
            )
            body.externalResources
        :: viewMaybe
            (viewExemplarsSection
                { language = language
                , paragraphFormatter = paragraphFormatter
                , preRenderedFormatter = preRenderedFormatter
                , recordId = recordId
                , relationshipFormatter = relationshipFormatter
                , summaryFormatter = summaryFormatter
                }
            )
            body.exemplars
        :: (if includeDigitalObjects then
                [ viewMaybe (viewDigitalObjectsSection language) body.digitalObjects ]

            else
                []
           )
