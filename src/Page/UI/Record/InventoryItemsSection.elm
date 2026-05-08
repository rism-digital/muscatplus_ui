module Page.UI.Record.InventoryItemsSection exposing (viewInventoryItemsSection)

import Element exposing (Element, alignBottom, alignLeft, alignTop, column, el, fill, height, htmlAttribute, link, paragraph, pointer, row, spacing, text, width)
import Element.Events as Events
import Html.Attributes as HA
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Inventory exposing (InventoryItemSummary, InventoryItemsBody)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h2s, h3s)


viewInventoryItemsSection :
    { expandMsg : msg
    , expanded : Bool
    , language : Language
    }
    -> InventoryItemsBody
    -> Element msg
viewInventoryItemsSection { expandMsg, expanded, language } inventoryItems =
    let
        tocId =
            if String.isEmpty inventoryItems.id then
                emptyAttribute

            else
                htmlAttribute (HA.id "inventory-items-section")

        sectionBody =
            if expanded then
                List.map (viewInventoryItem language) inventoryItems.items

            else
                []

        linkLabel =
            if expanded then
                text (extractLabelFromLanguageMap language localTranslations.collapse)

            else
                extractLabelFromLanguageMapWithVariables language
                    [ LanguageMapReplacementVariable "numItems" (String.fromInt (List.length inventoryItems.items)) ]
                    localTranslations.showNumItems
                    |> text
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            ]
            [ row
                [ width fill
                , alignLeft
                , alignBottom
                , spacing 5
                , tocId
                ]
                [ h2s language localTranslations.inventoryItems
                , el
                    [ linkColour
                    , pointer
                    , Events.onClick expandMsg
                    ]
                    linkLabel
                ]
            , column
                [ spacing sectionSpacing
                , width fill
                ]
                sectionBody
            ]
        ]


viewInventoryItem : Language -> InventoryItemSummary -> Element msg
viewInventoryItem language item =
    let
        creatorLabel =
            item.creator
                |> Maybe.andThen .relatedTo
                |> Maybe.map (.label >> extractLabelFromLanguageMap language)
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
                paragraph []
                    [ text (extractLabelFromLanguageMap language localTranslations.creator ++ ": " ++ creatorLabel) ]
            ]
        ]
