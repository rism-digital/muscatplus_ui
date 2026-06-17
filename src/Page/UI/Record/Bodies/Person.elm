module Page.UI.Record.Bodies.Person exposing (viewPersonSections)

import Element exposing (Element)
import Language exposing (Language, LanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Components exposing (pageBodyOrEmpty)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewPersonWorksSection)


isEmptyPersonBody : PersonBody -> Bool
isEmptyPersonBody body =
    ME.isNothing body.biographicalDetails
        && ME.isNothing body.nameVariants
        && ME.isNothing body.relationships
        && ME.isNothing body.notes
        && ME.isNothing body.externalResources
        && ME.isNothing body.externalAuthorities


viewPersonSections :
    { language : Language
    , includeDigitalObjects : Bool
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , recordId : String
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> PersonBody
    -> List (Element msg)
viewPersonSections { language, includeDigitalObjects, paragraphFormatter, recordId, relationshipFormatter, summaryFormatter } body =
    pageBodyOrEmpty
        language
        (isEmptyPersonBody body)
        (viewMaybe
            (viewBiographicalDetailsSection
                { language = language
                , summaryFormatter = summaryFormatter
                }
            )
            body.biographicalDetails
            :: viewMaybe
                (viewNameVariantsSection
                    { language = language
                    , summaryFormatter = summaryFormatter
                    }
                )
                body.nameVariants
            :: viewMaybe
                (viewRelationshipsSection
                    { language = language
                    , relationshipFormatter = relationshipFormatter
                    }
                )
                body.relationships
            :: viewMaybe
                (viewNotesSection
                    { language = language
                    , paragraphFormatter = paragraphFormatter
                    }
                )
                body.notes
            :: viewMaybe
                (viewExternalResourcesSection
                    { language = language
                    , recordId = recordId
                    }
                )
                body.externalResources
            :: viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            :: viewMaybe (viewPersonWorksSection language) body.works
            :: (if includeDigitalObjects then
                    [ viewMaybe (viewDigitalObjectsSection language) body.digitalObjects ]

                else
                    []
               )
        )
