module Desktop.Record.SourcePage exposing (viewFullSourcePage)

import Desktop.Record.InventoryItemsTable exposing (viewInventoryItemsTabBody)
import Desktop.Record.SourceSearch exposing (viewSourceSearchTabBody)
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
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordDescriptionTab, viewRecordSearchTab)
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
            (viewSourceSections
                { expandedDigitizedCopiesCallout = expandedDigitizedCopiesCallout
                , expandedDigitizedCopiesMsg = expandedDigitizedCopiesMsg
                , expandedIncipits = expandedIncipits
                , extraSectionsAfterReferencesNotes = []
                , includeDigitalObjects = True
                , incipitInfoToggleMsg = incipitInfoToggleMsg
                , language = language
                , paragraphFormatter = viewParagraphField
                , preRenderedFormatter = viewPreRenderedSummaryField
                , recordId = body.id
                , relationshipFormatter = viewRelationshipBody
                , summaryFormatter = viewSummaryField
                }
                body
            )
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
        [ viewRecordDescriptionTab
            { language = language
            , currentTab = model.currentTab
            , recordId = body.id
            }
        , viewMaybe
            (\searchInfo ->
                viewRecordSearchTab
                    { language = language
                    , currentTab = model.currentTab
                    , searchUrl = searchInfo.searchUrl
                    , tabLabel = localTranslations.sourceContents
                    , totalItems = searchInfo.totalItems
                    }
            )
            (resolveSearchTabInfo model.searchResults body.sourceItems)
        , inventoryTab
        ]


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
