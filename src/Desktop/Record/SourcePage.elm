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
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo)
import Page.UI.Record.TabShell exposing (TabSpec, descriptionTab, searchTab, selectBody, viewDesktopTabBar)
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
        descriptionBody =
            viewDescriptionTab
                { expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                , expandedIncipits = model.incipitInfoExpanded
                , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                , language = session.language
                }
                body

        tabs =
            viewRecordTabs session model body descriptionBody

        selectedBody =
            selectBody
                { bodyView = descriptionBody
                , showBottomShadow = True
                }
                tabs

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
                viewDesktopTabBar tabs
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
            [ recordHeaderTemplate selectedBody.showBottomShadow
                [ pageHeader
                , tabBar
                ]
            , selectedBody.bodyView
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


viewRecordTabs :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
    -> List (TabSpec RecordMsg)
viewRecordTabs session model body descriptionBody =
    descriptionTab
        { bodyView = descriptionBody
        , currentTab = model.currentTab
        , language = session.language
        , recordId = body.id
        , showBottomShadow = True
        }
        :: (resolveSearchTabInfo model.searchResults body.sourceItems
                |> Maybe.andThen
                    (\searchInfo ->
                        if searchInfo.totalItems > 0 then
                            Just
                                (searchTab
                                    { bodyView = viewSourceSearchTabBody session model
                                    , currentTab = model.currentTab
                                    , language = session.language
                                    , searchUrl = searchInfo.searchUrl
                                    , showBottomShadow = False
                                    , tabLabel = localTranslations.sourceContents
                                    , totalItems = searchInfo.totalItems
                                    }
                                )

                        else
                            Nothing
                    )
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )
        ++ (body.inventoryItems
                |> Maybe.map (viewInventoryItemsTab session session.language model)
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )


viewInventoryItemsTab :
    Session
    -> Language
    -> RecordPageModel RecordMsg
    -> InventoryItemsSectionBody
    -> TabSpec RecordMsg
viewInventoryItemsTab session language model inventoryItems =
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
    { body =
        Just
            { bodyView = viewInventoryItemsTabBody session model
            , showBottomShadow = False
            }
    , isSelected = isSelected
    , view =
        tabView
            { clickMsg =
                if isSelected then
                    RecordMsg.NothingHappened

                else
                    RecordMsg.UserClickedRecordViewTab (InventoryItemsDisplayTab inventoryItems.url)
            , icon = none
            , isSelected = isSelected
            , language = language
            , tab = CountTab localTranslations.inventoryItems count
            }
    }
