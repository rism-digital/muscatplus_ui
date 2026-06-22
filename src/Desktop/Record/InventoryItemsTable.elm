module Desktop.Record.InventoryItemsTable exposing (viewInventoryItemsTabBody)

import Dict exposing (Dict)
import Element exposing (Element, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, inFront, indexedTable, link, padding, paragraph, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Search exposing (InventoryItemResultBody, SearchBody, SearchResult(..))
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, tableHeaderStyles)
import Page.UI.Record.PublicationWorksSearch exposing (Layout(..), viewPublicationWorksSearchControls)
import Page.UI.Record.SearchTabs exposing (viewRecordSearchResults)
import Page.UI.Search.Pagination exposing (viewTablePagination)
import Page.UI.Search.SearchTemplate exposing (viewRelatedWorksSearchResultsLoadingTmpl, viewResultsListLoadingScreenTmpl)
import Page.UI.Style exposing (colourScheme, tableCellPadding)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


viewInventoryItemsTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewInventoryItemsTabBody session model =
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
            , htmlAttribute (HA.id "search-results-list")
            , padding 20
            , spacing 20
            ]
            [ viewPublicationWorksSearchControls
                { activeSearch = model.activeSearch
                , clearMsg = RecordMsg.UserClickedClearKeywordSearch
                , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
                , disabledSubmitMsg = RecordMsg.NothingHappened
                , enabledSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
                , language = session.language
                , layout = Inline
                , probeResponse = model.probeResponse
                , userClickedOpenQueryBuilderMsg = RecordMsg.UserClickedOpenQueryBuilder
                }
            , viewInventoryItemsSearchResults session model
            ]
        ]


viewInventoryItemsSearchResults : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewInventoryItemsSearchResults session model =
    viewRecordSearchResults
        { language = session.language
        , loadingView = viewRelatedWorksSearchResultsLoadingTmpl session.language
        , loadedView =
            \body ->
                case model.searchResults of
                    Loading (Just (SearchData _)) ->
                        viewInventoryItemsResultsSection True session.language body

                    _ ->
                        viewInventoryItemsResultsSection False session.language body
        , response = model.searchResults
        }


viewInventoryItemsResultsSection : Bool -> Language -> SearchBody -> Element RecordMsg
viewInventoryItemsResultsSection isLoading language body =
    let
        items =
            List.filterMap
                (\result ->
                    case result of
                        InventoryItemResult item ->
                            Just item

                        _ ->
                            Nothing
                )
                body.items
    in
    row
        [ width fill
        , height fill
        , Background.color colourScheme.white
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ viewTablePagination language body.pagination RecordMsg.UserClickedSearchResultsPagination ]
            , row
                [ width fill
                , inFront (viewResultsListLoadingScreenTmpl 0 isLoading)
                ]
                [ indexedTable
                    [ Border.width 1
                    , Border.color colourScheme.midGrey
                    ]
                    { columns =
                        [ { header = el tableHeaderStyles (text "Inventory section")
                          , width = fillPortion 1
                          , view = \rowNum item -> viewInventorySectionCell rowNum item
                          }
                        , { header = el tableHeaderStyles (text "Inventory number")
                          , width = fillPortion 1
                          , view = \rowNum item -> viewInventoryNumberCell language rowNum item
                          }
                        , { header = el tableHeaderStyles (text (extractLabelFromLanguageMap language localTranslations.label))
                          , width = fillPortion 3
                          , view = \rowNum item -> viewLabelCell language rowNum item
                          }
                        , { header = el tableHeaderStyles (text (extractLabelFromLanguageMap language localTranslations.creator))
                          , width = fillPortion 2
                          , view = \rowNum item -> viewCreatorCell language rowNum item
                          }
                        ]
                    , data = items
                    }
                ]
            , row
                [ width fill ]
                [ viewTablePagination language body.pagination RecordMsg.UserClickedSearchResultsPagination ]
            ]
        ]


viewInventorySectionCell : Int -> InventoryItemResultBody -> Element RecordMsg
viewInventorySectionCell rowNum item =
    el
        [ cycleTableBackground rowNum
        , padding tableCellPadding
        , height fill
        ]
        (paragraph []
            [ item.flags
                |> Maybe.andThen .inventorySection
                |> Maybe.withDefault ""
                |> text
            ]
        )


viewInventoryNumberCell : Language -> Int -> InventoryItemResultBody -> Element RecordMsg
viewInventoryNumberCell language rowNum item =
    el
        [ cycleTableBackground rowNum
        , padding tableCellPadding
        , height fill
        ]
        (paragraph []
            [ extractSummaryValue language "inventoryNumber" item.summary
                |> text
            ]
        )


viewLabelCell : Language -> Int -> InventoryItemResultBody -> Element RecordMsg
viewLabelCell language rowNum item =
    link
        [ cycleTableBackground rowNum
        , linkColour
        , padding tableCellPadding
        , height fill
        ]
        { label =
            paragraph [ centerY ]
                [ text (extractLabelFromLanguageMap language item.label) ]
        , url = item.id
        }


viewCreatorCell : Language -> Int -> InventoryItemResultBody -> Element RecordMsg
viewCreatorCell language rowNum item =
    el
        [ cycleTableBackground rowNum
        , padding tableCellPadding
        , height fill
        ]
        (paragraph []
            [ extractSummaryValue language "inventoryComposer" item.summary
                |> text
            ]
        )


extractSummaryValue : Language -> String -> Maybe (Dict String LabelValue) -> String
extractSummaryValue language summaryKey summary =
    summary
        |> Maybe.andThen (Dict.get summaryKey)
        |> Maybe.map (.value >> extractLabelFromLanguageMap language)
        |> Maybe.withDefault ""
