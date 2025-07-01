module Desktop.Record.SourcePage exposing (viewFullSourcePage)

import Desktop.Record.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Dict
import Element exposing (Element, alignLeft, alignTop, centerY, clipY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewSourceWorksSection)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, tabBarHeight)
import Session exposing (Session)
import Set exposing (Set)


viewFullSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullSourcePage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab
                        { expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                        , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                        , expandedIncipits = model.incipitInfoExpanded
                        , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , language = session.language
                        }
                        body

                ContentsSearchDisplayTab _ ->
                    viewSourceSearchTabBody session model

        headerHeight =
            if session.isFramed then
                px recordTitleHeight

            else
                px (tabBarHeight + recordTitleHeight)

        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconChooser

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (sourceIcon colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just sourceIconView) body

            else
                pageHeaderTemplate session.language (Just sourceIconView) body

        tabBar =
            if session.isFramed then
                none

            else
                viewRecordTopBarRouter session.language model body
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
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , minimalDropShadow
                    ]
                    [ pageHeader
                    , tabBar
                    ]
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewDescriptionTab :
    { expandedDigitizedCopiesCallout : Bool
    , expandedDigitizedCopiesMsg : msg
    , expandedIncipits : Set String
    , incipitInfoToggleMsg : String -> msg
    , language : Language
    }
    -> FullSourceBody
    -> Element msg
viewDescriptionTab { expandedDigitizedCopiesCallout, expandedDigitizedCopiesMsg, expandedIncipits, incipitInfoToggleMsg, language } body =
    let
        allExternals =
            gatherAllDigitizationLinksForCallout language body
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
            [ viewMaybe (viewPartOfSection language) body.partOf
            , viewIf
                (viewDigitizedCopiesCalloutSection
                    { expandMsg = expandedDigitizedCopiesMsg
                    , expanded = expandedDigitizedCopiesCallout
                    , language = language
                    }
                    allExternals
                )
                (Dict.size allExternals > 0)
            , viewMaybe
                (viewContentsSection
                    { creator = body.creator
                    , language = language
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    , relationshipFormatter = viewRelationshipBody
                    , summaryFormatter = viewSummaryField
                    }
                )
                body.contents
            , viewMaybe
                (viewIncipitsSection
                    { language = language
                    , infoToggleMsg = incipitInfoToggleMsg
                    , expandedIncipits = expandedIncipits
                    , summaryFormatter = viewSummaryField
                    }
                )
                body.incipits
            , viewMaybe
                (viewMaterialGroupsSection
                    { language = language
                    , paragraphFormatter = viewParagraphField
                    , relationshipFormatter = viewRelationshipBody
                    , summaryFormatter = viewSummaryField
                    }
                )
                body.materialGroups
            , viewMaybe
                (viewRelationshipsSection
                    { language = language
                    , relationshipFormatter = viewRelationshipBody
                    }
                )
                body.relationships
            , viewMaybe
                (viewSourceWorksSection
                    { language = language
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    }
                )
                body.works
            , viewMaybe
                (viewReferencesNotesSection
                    { language = language
                    , paragraphFormatter = viewParagraphField
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    }
                )
                body.referencesNotes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe
                (viewExemplarsSection
                    { language = language
                    , paragraphFormatter = viewParagraphField
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    , relationshipFormatter = viewRelationshipBody
                    , summaryFormatter = viewSummaryField
                    }
                )
                body.exemplars
            , viewMaybe (viewDigitalObjectsSection language) body.digitalObjects
            ]
        ]


viewRecordTopBarRouter :
    Language
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewRecordTopBarRouter language model body =
    viewRecordSourceSearchTabBar
        { body = body.sourceItems
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sourceContents
        }
