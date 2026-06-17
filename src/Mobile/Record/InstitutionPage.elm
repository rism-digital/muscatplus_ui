module Mobile.Record.InstitutionPage exposing (viewFullMobileInstitutionPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection, viewLocationMapSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullMobileInstitutionPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (institutionSvg colourScheme.darkBlue)
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


chooseBody : Session -> RecordPageModel RecordMsg -> InstitutionBody -> Element RecordMsg
chooseBody session model body =
    case model.currentTab of
        ContentsSearchDisplayTab _ ->
            viewSourceSearchTabBody session model

        _ ->
            viewDescriptionTab session body


viewDescriptionTab : Session -> InstitutionBody -> Element RecordMsg
viewDescriptionTab session body =
    let
        isEmpty =
            ME.isNothing body.organizationDetails
                && ME.isNothing body.location
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities
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
            , height fill
            , alignTop
            , padding 20
            , spacing sectionSpacing
            ]
            (pageBodyOrEmpty session.language
                isEmpty
                [ viewMaybe
                    (viewOrganizationDetailsSection
                        { language = session.language
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.organizationDetails
                , viewMaybe
                    (viewLocationAddressSection
                        { language = session.language
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.location
                , viewMaybe
                    (viewRelationshipsSection
                        { language = session.language
                        , relationshipFormatter = viewMobileRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = session.language
                        , paragraphFormatter = viewMobileParagraphField
                        }
                    )
                    body.notes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = session.language
                        , recordId = body.id
                        }
                    )
                    body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection session.language) body.externalAuthorities
                , viewMaybe
                    (viewLocationMapSection
                        { language = session.language
                        , summaryFormatter = viewMobileSummaryField
                        }
                        session.window
                    )
                    body.location
                ]
            )
        ]
