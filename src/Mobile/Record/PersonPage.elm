module Mobile.Record.PersonPage exposing (viewFullMobilePersonPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Maybe.Extra as ME
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewMobileParagraphField, viewMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewPersonWorksSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobilePersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullMobilePersonPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (peopleSvg colourScheme.darkBlue)
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


chooseBody : Session -> RecordPageModel RecordMsg -> PersonBody -> Element RecordMsg
chooseBody session model body =
    case model.currentTab of
        ContentsSearchDisplayTab _ ->
            viewSourceSearchTabBody session model

        _ ->
            viewDescriptionTab session body


viewDescriptionTab : Session -> PersonBody -> Element RecordMsg
viewDescriptionTab session body =
    let
        isEmpty =
            ME.isNothing body.biographicalDetails
                && ME.isNothing body.nameVariants
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities
    in
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
            , padding 20
            , spacing sectionSpacing
            ]
            (pageBodyOrEmpty
                session.language
                isEmpty
                [ viewMaybe
                    (viewBiographicalDetailsSection
                        { language = session.language
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.biographicalDetails
                , viewMaybe
                    (viewNameVariantsSection
                        { language = session.language
                        , summaryFormatter = viewMobileSummaryField
                        }
                    )
                    body.nameVariants
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
                , viewMaybe (viewPersonWorksSection session.language) body.works
                , viewMaybe (viewDigitalObjectsSection session.language) body.digitalObjects
                ]
            )
        ]
