module Desktop.Record.InventoryItemsTable exposing (viewInventoryItemsTabBody)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, htmlAttribute, indexedTable, link, none, padding, paragraph, row, scrollbarY, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Inventory exposing (InventoryItemSummary, InventoryItemsBody)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, tableHeaderStyles)
import Page.UI.Errors exposing (errorMessageString)
import Page.UI.Style exposing (colourScheme, tableCellPadding)
import Response exposing (Response(..))
import Session exposing (Session)


viewInventoryItemsTabBody : Session -> Response InventoryItemsBody -> Element RecordMsg
viewInventoryItemsTabBody session inventoryItems =
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
            ]
            [ inventoryItemsBodyView session inventoryItems ]
        ]


inventoryItemsBodyView : Session -> Response InventoryItemsBody -> Element RecordMsg
inventoryItemsBodyView session inventoryItems =
    case inventoryItems of
        Loading _ ->
            none

        Response body ->
            indexedTable
                [ Border.width 1
                , Border.color colourScheme.midGrey
                ]
                { columns =
                    [ { header = el tableHeaderStyles (text "Inventory section")
                      , width = fillPortion 1
                      , view = \rowNum item -> viewInventorySectionCell session.language rowNum item
                      }
                    , { header = el tableHeaderStyles (text "Inventory number")
                      , width = fillPortion 1
                      , view = \rowNum item -> viewInventoryCell session.language rowNum item
                      }
                    , { header = el tableHeaderStyles (text (extractLabelFromLanguageMap session.language localTranslations.label))
                      , width = fillPortion 3
                      , view = \rowNum item -> viewLabelCell session.language rowNum item
                      }
                    , { header = el tableHeaderStyles (text (extractLabelFromLanguageMap session.language localTranslations.creator))
                      , width = fillPortion 2
                      , view = \rowNum item -> viewCreatorCell session.language rowNum item
                      }
                    ]
                , data = body.items
                }

        Error err ->
            text (errorMessageString session.language err)

        NoResponseToShow ->
            none


viewLabelCell : Language -> Int -> InventoryItemSummary -> Element RecordMsg
viewLabelCell language rowNum item =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    link
        [ cellBg, linkColour, padding tableCellPadding, height fill ]
        { label =
            paragraph []
                [ text (extractLabelFromLanguageMap language item.label) ]
        , url = item.id
        }


viewCreatorCell : Language -> Int -> InventoryItemSummary -> Element RecordMsg
viewCreatorCell language rowNum item =
    let
        cellBg =
            cycleTableBackground rowNum

        creatorLabel =
            item.creator
                |> Maybe.andThen .relatedTo
                |> Maybe.map (.label >> extractLabelFromLanguageMap language)
                |> Maybe.withDefault ""
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [] [ text creatorLabel ])


viewInventoryCell : Language -> Int -> InventoryItemSummary -> Element RecordMsg
viewInventoryCell language rowNum item =
    let
        cellBg =
            cycleTableBackground rowNum

        inventoryLabel =
            item.inventory
                |> Maybe.andThen .number
                |> Maybe.withDefault ""
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [] [ text inventoryLabel ])


viewInventorySectionCell : Language -> Int -> InventoryItemSummary -> Element RecordMsg
viewInventorySectionCell language rowNum item =
    let
        cellBg =
            cycleTableBackground rowNum

        inventoryLabel =
            item.inventory
                |> Maybe.andThen .section
                |> Maybe.withDefault ""
    in
    el
        [ cellBg, padding tableCellPadding, height fill ]
        (paragraph [] [ text inventoryLabel ])
