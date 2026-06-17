module Page.UI.Record.Bodies.Institution exposing (viewInstitutionSections)

import Element exposing (Element)
import Language exposing (Language, LanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Components exposing (pageBodyOrEmpty)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ContributionsSection exposing (viewContributionsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection, viewLocationMapSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)


isEmptyInstitutionBody : InstitutionBody -> Bool
isEmptyInstitutionBody body =
    ME.isNothing body.organizationDetails
        && ME.isNothing body.location
        && ME.isNothing body.relationships
        && ME.isNothing body.notes
        && ME.isNothing body.externalResources
        && ME.isNothing body.externalAuthorities


viewInstitutionSections :
    { includeContributions : Bool
    , includeDigitalObjects : Bool
    , includeLocationMap : Bool
    , language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , recordId : String
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    , window : ( Int, Int )
    }
    -> InstitutionBody
    -> List (Element msg)
viewInstitutionSections { includeContributions, includeDigitalObjects, includeLocationMap, language, paragraphFormatter, recordId, relationshipFormatter, summaryFormatter, window } body =
    pageBodyOrEmpty
        language
        (isEmptyInstitutionBody body)
        (viewMaybe
            (viewOrganizationDetailsSection
                { language = language
                , summaryFormatter = summaryFormatter
                }
            )
            body.organizationDetails
            :: viewMaybe
                (viewLocationAddressSection
                    { language = language
                    , summaryFormatter = summaryFormatter
                    }
                )
                body.location
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
            :: (if includeContributions then
                    [ viewMaybe (viewContributionsSection { language = language }) body.contributions ]

                else
                    []
               )
            ++ (if includeLocationMap then
                    [ viewMaybe
                        (viewLocationMapSection
                            { language = language
                            , summaryFormatter = summaryFormatter
                            }
                            window
                        )
                        body.location
                    ]

                else
                    []
               )
            ++ (if includeDigitalObjects then
                    [ viewMaybe (viewDigitalObjectsSection language) body.digitalObjects ]

                else
                    []
               )
        )
