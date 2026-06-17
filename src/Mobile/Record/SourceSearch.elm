module Mobile.Record.SourceSearch exposing
    ( viewRecordSourceSearchTabBar
    , viewSourceSearchTabBody
    )

import Element exposing (Element, alignBottom, alignLeft, column, fill, height, htmlAttribute, link, padding, paddingEach, px, row, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.PartOf exposing (extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SearchTabs exposing (resolveSearchTabInfo, viewRecordDescriptionTab, viewRecordSearchResults, viewRecordSearchTab)
import Page.UI.Search.MobileResults exposing (viewMobilePagedResults)
import Page.UI.Search.Pagination exposing (viewPagination)
import Page.UI.Search.SearchTemplate exposing (viewMobileSearchResultsLoadingTmpl)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewSourceSearchTabBody : Session -> RecordPageModel RecordMsg -> Element RecordMsg
viewSourceSearchTabBody session model =
    viewRecordSearchResults
        { language = session.language
        , loadingView = viewMobileSearchResultsLoadingTmpl
        , loadedView = viewSourcesSearchResultsSection session
        , response = model.searchResults
        }


viewRecordSourceSearchTabBar :
    { body : Maybe { a | url : String, totalItems : Int }
    , language : Language
    , model : RecordPageModel RecordMsg
    , recordId : String
    , tabLabel : LanguageMap
    }
    -> Element RecordMsg
viewRecordSourceSearchTabBar { body, language, model, recordId, tabLabel } =
    row
        [ width fill
        , height (px 35)
        , alignLeft
        , alignBottom
        , spacing 10
        , Element.paddingXY 10 0
        ]
        [ viewRecordDescriptionTab
            { language = language
            , currentTab = model.currentTab
            , recordId = recordId
            }
        , viewMaybe
            (\searchInfo ->
                viewRecordSearchTab
                    { language = language
                    , currentTab = model.currentTab
                    , searchUrl = searchInfo.searchUrl
                    , tabLabel = tabLabel
                    , totalItems = searchInfo.totalItems
                    }
            )
            (resolveSearchTabInfo model.searchResults body)
        ]


viewSourcesSearchResultsSection : Session -> SearchBody -> Element RecordMsg
viewSourcesSearchResultsSection session body =
    let
        sources =
            List.filterMap
                (\result ->
                    case result of
                        SourceResult source ->
                            Just source

                        _ ->
                            Nothing
                )
                body.items

        cards =
            if List.isEmpty sources then
                [ text (extractLabelFromLanguageMap session.language localTranslations.noResultsHeader) ]

            else
                List.map (viewSourceSearchResultCard session.language) sources
    in
    viewMobilePagedResults
        { bodyAttributes =
            [ paddingEach { bottom = 90, left = 20, right = 20, top = 20 }
            , spacing sectionSpacing
            ]
        , cards = cards
        , pagination = viewPagination session.language body.pagination RecordMsg.UserClickedSearchResultsPagination
        }


viewSourceSearchResultCard : Language -> SourceResultBody -> Element msg
viewSourceSearchResultCard language source =
    let
        partOfLabel =
            case source.partOf of
                Just partOf ->
                    partOf.items
                        |> List.head
                        |> Maybe.map (\it -> extractUrlAndLabelFromPartOf it.relatedTo |> Tuple.second)
                        |> Maybe.map (extractLabelFromLanguageMap language)
                        |> Maybe.withDefault ""

                Nothing ->
                    ""

        sourceTypeLabel =
            Maybe.map (\flags -> extractLabelFromLanguageMap language flags.sourceType.label) source.flags
                |> Maybe.withDefault ""
    in
    row
        [ width fill
        , Border.width 1
        , Border.color colourScheme.midGrey
        , Border.rounded 4
        , padding 12
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ link
                [ linkColour
                , width fill
                , htmlAttribute (HA.style "overflow-wrap" "anywhere")
                ]
                { label = text (extractLabelFromLanguageMap language source.label)
                , url = source.id
                }
            , text sourceTypeLabel
            , text partOfLabel
            ]
        ]
