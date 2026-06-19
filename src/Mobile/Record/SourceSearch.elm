module Mobile.Record.SourceSearch exposing (viewSourceSearchTabBody)

import Element exposing (Element, column, fill, htmlAttribute, link, padding, paddingEach, row, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.PartOf exposing (extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Record.SearchTabs exposing (viewRecordSearchResults)
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
