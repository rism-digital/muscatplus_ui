module Desktop.Record.PersonPage exposing (viewFullPersonPage)

import Desktop.Record.PageShell exposing (TabBody, viewDesktopRecordPage)
import Desktop.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewPersonWorksSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewDescriptionTab : { language : Language } -> PersonBody -> Element msg
viewDescriptionTab { language } body =
    let
        isEmpty =
            ME.isNothing body.biographicalDetails
                && ME.isNothing body.nameVariants
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities

        pageBody =
            pageBodyOrEmpty
                language
                isEmpty
                [ viewMaybe
                    (viewBiographicalDetailsSection
                        { language = language
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.biographicalDetails
                , viewMaybe
                    (viewNameVariantsSection
                        { language = language
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.nameVariants
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = language
                        , paragraphFormatter = viewParagraphField
                        }
                    )
                    body.notes
                , viewMaybe
                    (viewExternalResourcesSection
                        { language = language
                        , recordId = body.id
                        }
                    )
                    body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                , viewMaybe (viewPersonWorksSection language) body.works
                , viewMaybe (viewDigitalObjectsSection language) body.digitalObjects
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


viewFullPersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullPersonPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)
    in
    viewDesktopRecordPage
        { session = session
        , body = body
        , icon = icon
        , chooseBody = chooseBody session model body
        , currentTab = model.currentTab
        , tabBar = viewRecordTopBarRouter session.language model body
        }


chooseBody : Session -> RecordPageModel RecordMsg -> PersonBody -> CurrentRecordViewTab -> TabBody RecordMsg
chooseBody session model body currentTab =
    case currentTab of
        DefaultRecordViewTab _ ->
            { bodyView =
                viewDescriptionTab
                    { language = session.language }
                    body
            , showBottomShadow = True
            }

        ContentsSearchDisplayTab _ ->
            { bodyView = viewSourceSearchTabBody session model
            , showBottomShadow = False
            }

        _ ->
            { bodyView =
                viewDescriptionTab
                    { language = session.language }
                    body
            , showBottomShadow = True
            }


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> PersonBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    viewRecordSourceSearchTabBar
        { body = body.sources
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sources
        }
