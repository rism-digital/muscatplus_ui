module Desktop.Record.Views.SourcePage.FullRecordPage exposing (viewFullSourcePage)

import Desktop.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)
import Desktop.Record.Views.SourceSearch exposing (viewRecordSearchSourcesLink, viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Dict
import Element exposing (Element, alignLeft, alignTop, centerY, column, el, fill, height, none, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (pageHeaderBackground, sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser)
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
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
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

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTabBody session model

                PrintHoldingsTab _ ->
                    none

        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

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
                viewMaybe (viewRecordSearchSourcesLink session.language localTranslations.sourceContents) body.sourceItems

            else
                viewRecordTopBarRouter session.language model body
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.darkBlue
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , pageHeaderBackground
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
            , viewMaybe (viewContentsSection language body.creator) body.contents
            , viewMaybe
                (viewIncipitsSection
                    { language = language
                    , infoToggleMsg = incipitInfoToggleMsg
                    , expandedIncipits = expandedIncipits
                    }
                )
                body.incipits
            , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe (viewExemplarsSection language) body.exemplars
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
