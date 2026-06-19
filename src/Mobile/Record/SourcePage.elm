module Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)

import Dict exposing (Dict)
import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, link, none, padding, paddingEach, paragraph, px, row, scrollbarY, spacing, text, width)
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Search exposing (InventoryItemResultBody, SearchBody, SearchResult(..))
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (FullSourceBody, InventoryItemsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (Tab(..), h3s, sourceIconChooser, tabView, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.PublicationWorksSearch exposing (Layout(..), viewPublicationWorksSearchControls)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordSearchResults)
import Page.UI.Record.TabShell exposing (TabSpec, descriptionTab, searchTab, selectBody, viewMobileTabBar)
import Page.UI.Search.MobileResults exposing (viewMobilePagedResults)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.SearchTemplate exposing (viewMobileSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
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
    in
    { body =
        Just
            { bodyView = viewMobileInventoryItemsTabBody session model
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
            , tab = CountTab localTranslations.inventoryItems (Just inventoryItems.totalItems)
            }
    }


viewMobileInventoryItemsTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewMobileInventoryItemsTabBody session model =
    column
        [ width fill
        , height fill
        , alignTop
        , padding 20
        , spacing sectionSpacing
        ]
        [ viewPublicationWorksSearchControls
            { activeSearch = model.activeSearch
            , clearMsg = RecordMsg.UserClickedClearKeywordSearch
            , changeMsg = RecordMsg.UserEnteredTextInKeywordQueryBox
            , disabledSubmitMsg = RecordMsg.NothingHappened
            , enabledSubmitMsg = RecordMsg.UserTriggeredSearchSubmit
            , language = session.language
            , layout = Stacked
            , probeResponse = model.probeResponse
            , userClickedOpenQueryBuilderMsg = RecordMsg.UserClickedOpenQueryBuilder
            }
        , el [ width fill, height fill ]
            (viewRecordSearchResults
                { language = session.language
                , loadingView = viewMobileSearchResultsLoadingTmpl
                , loadedView = viewInventoryItemsResultsSection session.language
                , response = model.searchResults
                }
            )
        ]


viewInventoryItemsResultsSection : Language -> SearchBody -> Element RecordMsg
viewInventoryItemsResultsSection language body =
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

        cards =
            if List.isEmpty items then
                [ text (extractLabelFromLanguageMap language localTranslations.noResultsHeader) ]

            else
                List.map (viewInventoryItemCard language) items
    in
    viewMobilePagedResults
        { bodyAttributes =
            [ paddingEach { bottom = 90, left = 0, right = 0, top = 0 }
            , spacing sectionSpacing
            ]
        , cards = cards
        , pagination = viewPagination language body.pagination RecordMsg.UserClickedSearchResultsPagination
        }


viewInventoryItemCard : Language -> InventoryItemResultBody -> Element RecordMsg
viewInventoryItemCard language item =
    let
        inventoryLabel =
            [ item.flags |> Maybe.andThen .inventorySection
            , extractSummaryValue language "inventoryNumber" item.summary
                |> (\value ->
                        if String.isEmpty value then
                            Nothing

                        else
                            Just value
                   )
            ]
                |> List.filterMap identity
                |> String.join " "

        creatorLabel =
            extractSummaryValue language "creator" item.summary
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


extractSummaryValue : Language -> String -> Maybe (Dict String LabelValue) -> String
extractSummaryValue language summaryKey summary =
    summary
        |> Maybe.andThen (Dict.get summaryKey)
        |> Maybe.map (.value >> extractLabelFromLanguageMap language)
        |> Maybe.withDefault ""
