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
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo)
import Page.UI.Record.TabShell exposing (TabSpec, descriptionTab, searchTab, selectBody, viewMobileTabBar)
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
        descriptionBody =
            viewDescriptionTab session model body

        tabs =
            viewRecordTabs session model body descriptionBody

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
        , topBar = viewMobileTabBar tabs
        , bodyView = (selectBody { bodyView = descriptionBody, showBottomShadow = True } tabs).bodyView
        }


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
                |> Maybe.map (viewInventoryItemsTab session session.language model.inventoryItems model)
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
           )


viewInventoryItemsTab :
    Session
    -> Language
    -> Response InventoryItemsBody
    -> RecordPageModel RecordMsg
    -> InventoryItemsSectionBody
    -> TabSpec RecordMsg
viewInventoryItemsTab session language inventoryItemsResponse model inventoryItems =
    let
        isSelected =
            case model.currentTab of
                InventoryItemsDisplayTab _ ->
                    True

                _ ->
                    False
    in
    { body =
        Just
            { bodyView = viewMobileInventoryItemsTabBody session inventoryItemsResponse
            , showBottomShadow = False
            }
    , isSelected = isSelected
    , view =
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
