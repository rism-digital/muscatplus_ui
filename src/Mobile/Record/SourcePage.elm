module Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, column, el, fill, height, htmlAttribute, link, none, padding, paragraph, px, row, scrollbarY, spacing, text, width)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Inventory exposing (InventoryItemSummary, InventoryItemsBody)
import Page.RecordTypes.Source exposing (FullSourceBody, InventoryItemsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (Tab(..), h3s, sourceIconChooser, tabView, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordDescriptionTab, viewRecordSearchTab)
import Page.UI.Search.SearchTemplate exposing (viewMobileSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))
import Session exposing (Session)


viewFullMobileSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullMobileSourcePage session model body =
    let
        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconChooser

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (sourceIcon colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = sourceIconView
        , topBar = viewRecordTopBar session.language model body
        , bodyView = chooseBody session model body
        }


chooseBody : Session -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
chooseBody session model body =
    case model.currentTab of
        ContentsSearchDisplayTab _ ->
            viewSourceSearchTabBody session model

        InventoryItemsDisplayTab _ ->
            viewMobileInventoryItemsTabBody session model.inventoryItems

        _ ->
            viewDescriptionTab session model body


viewDescriptionTab : Session -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
viewDescriptionTab session model body =
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
            (viewSourceSections
                { expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                , expandedIncipits = model.incipitInfoExpanded
                , extraSectionsAfterReferencesNotes = []
                , includeDigitalObjects = True
                , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                , language = session.language
                , paragraphFormatter = viewMobileParagraphField
                , preRenderedFormatter = viewPreRenderedMobileSummaryField
                , recordId = body.id
                , relationshipFormatter = viewMobileRelationshipBody
                , summaryFormatter = viewMobileSummaryField
                }
                body
            )
        ]


viewRecordTopBar : Language -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
viewRecordTopBar language model body =
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , Element.paddingXY 10 0
        ]
        (viewRecordDescriptionTab
            { language = language
            , currentTab = model.currentTab
            , recordId = body.id
            }
            :: (resolveSearchTabInfo model.searchResults body.sourceItems
                    |> Maybe.andThen
                        (\searchInfo ->
                            if searchInfo.totalItems > 0 then
                                Just
                                    (viewRecordSearchTab
                                        { language = language
                                        , currentTab = model.currentTab
                                        , searchUrl = searchInfo.searchUrl
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
                    |> Maybe.map (viewInventoryItemsTab language model)
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
               )
        )


viewInventoryItemsTab : Language -> RecordPageModel RecordMsg -> InventoryItemsSectionBody -> Element RecordMsg
viewInventoryItemsTab language model inventoryItems =
    let
        isSelected =
            case model.currentTab of
                InventoryItemsDisplayTab _ ->
                    True

                _ ->
                    False
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
        , tab = CountTab localTranslations.inventoryItems (Just inventoryItems.totalItems)
        }


viewMobileInventoryItemsTabBody : Session -> Response InventoryItemsBody -> Element RecordMsg
viewMobileInventoryItemsTabBody session inventoryItems =
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
            [ inventoryItemsBodyView session inventoryItems ]
        ]


inventoryItemsBodyView : Session -> Response InventoryItemsBody -> Element RecordMsg
inventoryItemsBodyView session inventoryItems =
    case inventoryItems of
        Loading _ ->
            viewMobileSearchResultsLoadingTmpl

        Response inventoryBody ->
            viewInventoryItemsList session.language inventoryBody

        Error err ->
            text (errorMessageString session.language err)

        NoResponseToShow ->
            viewMobileSearchResultsLoadingTmpl


viewInventoryItemsList : Language -> InventoryItemsBody -> Element RecordMsg
viewInventoryItemsList language inventoryBody =
    column
        [ width fill
        , spacing sectionSpacing
        ]
        (List.map (viewInventoryItemCard language) inventoryBody.items)


viewInventoryItemCard : Language -> InventoryItemSummary -> Element RecordMsg
viewInventoryItemCard language item =
    let
        creatorLabel =
            item.creator
                |> Maybe.andThen .relatedTo
                |> Maybe.map (.label >> extractLabelFromLanguageMap language)
                |> Maybe.withDefault ""

        inventoryLabel =
            item.inventory
                |> Maybe.map
                    (\inventory ->
                        [ inventory.section, inventory.number ]
                            |> List.filterMap identity
                            |> String.join " "
                    )
                |> Maybe.withDefault ""
    in
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ paragraph [ width fill ]
                [ link
                    [ linkColour ]
                    { label = h3s language item.label
                    , url = item.id
                    }
                ]
            , if String.isEmpty creatorLabel then
                text ""

              else
                paragraph [] [ text (extractLabelFromLanguageMap language localTranslations.creator ++ ": " ++ creatorLabel) ]
            , if String.isEmpty inventoryLabel then
                text ""

              else
                paragraph [] [ text inventoryLabel ]
            ]
        ]
