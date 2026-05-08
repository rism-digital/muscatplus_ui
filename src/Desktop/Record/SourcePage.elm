module Desktop.Record.SourcePage exposing (viewFullSourcePage)

import Desktop.Record.InventoryItemsTable exposing (viewInventoryItemsTabBody)
import Desktop.Record.SourceSearch exposing (viewSourceSearchTab, viewSourceSearchTabBody)
import Dict
import Element exposing (Element, alignTop, centerY, clipY, column, el, fill, height, htmlAttribute, none, padding, px, row, scrollbarY, spacing, width)
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody, InventoryItemsSectionBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (Tab(..), sourceIconChooser, tabView, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.DigitalObjectsSection exposing (viewDigitalObjectsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewSourceWorksSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)
import Set exposing (Set)


viewFullSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullSourcePage session model body =
    let
        ( pageBodyView, showBottomShadow ) =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    ( viewDescriptionTab
                        { expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                        , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                        , expandedIncipits = model.incipitInfoExpanded
                        , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , language = session.language
                        }
                        body
                    , True
                    )

                ContentsSearchDisplayTab _ ->
                    ( viewSourceSearchTabBody session model, False )

                InventoryItemsDisplayTab _ ->
                    ( viewInventoryItemsTabBody session model.inventoryItems, False )

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
            ]
            [ recordHeaderTemplate showBottomShadow
                [ pageHeader
                , tabBar
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
                    , recordId = body.id
                    }
                    allExternals
                )
                (not (Dict.isEmpty allExternals))
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
                    , recordId = body.id
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
            , viewMaybe
                (viewExternalResourcesSection
                    { language = language
                    , recordId = body.id
                    }
                )
                body.externalResources
            , viewMaybe
                (viewExemplarsSection
                    { language = language
                    , paragraphFormatter = viewParagraphField
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    , recordId = body.id
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
    let
        inventoryTab =
            viewMaybe (viewInventoryItemsTab language model) body.inventoryItems
    in
    row
        [ width fill
        , height (px 35)
        , spacing 10
        ]
        [ viewRecordDescriptionTab language model body.id
        , viewMaybe
            (\s ->
                viewSourceSearchTab
                    { language = language
                    , model = model
                    , recordId = body.id
                    , searchUrl = s.url
                    , tabLabel = localTranslations.sourceContents
                    , totalItems = s.totalItems
                    }
            )
            body.sourceItems
        , inventoryTab
        ]


viewRecordDescriptionTab : Language -> RecordPageModel RecordMsg -> String -> Element RecordMsg
viewRecordDescriptionTab language model recordId =
    let
        isSelected =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    True

                _ ->
                    False
    in
    tabView
        { clickMsg =
            if isSelected then
                RecordMsg.NothingHappened

            else
                RecordMsg.UserClickedRecordViewTab (DefaultRecordViewTab recordId)
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = BareTab localTranslations.description
        }


viewInventoryItemsTab : Language -> RecordPageModel RecordMsg -> InventoryItemsSectionBody -> Element RecordMsg
viewInventoryItemsTab language model inventoryItems =
    let
        isSelected =
            case model.currentTab of
                InventoryItemsDisplayTab _ ->
                    True

                _ ->
                    False

        count =
            Just inventoryItems.totalItems
    in
    tabView
        { clickMsg =
            if isSelected then
                RecordMsg.NothingHappened

            else
                RecordMsg.UserClickedRecordViewTab (InventoryItemsDisplayTab inventoryItems.id)
        , icon = none
        , isSelected = isSelected
        , language = language
        , tab = CountTab localTranslations.inventoryItems count
        }
