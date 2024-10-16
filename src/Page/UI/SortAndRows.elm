module Page.UI.SortAndRows exposing (SortAndRowsConfig, viewSearchPageSort)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))


type alias SortAndRowsConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , body : SearchBody
    , changedResultSortingMsg : String -> msg
    , changedResultRowsPerPageMsg : String -> msg
    }


viewRowSelectAndSortSelector : SortAndRowsConfig msg -> Element msg
viewRowSelectAndSortSelector cfg =
    let
        nextQuery =
            .nextQuery cfg.activeSearch

        chosenRows =
            nextQuery.rows
                |> String.fromInt

        -- Choose the alias that is marked as the default sort
        -- option in the sorts block.
        chosenSort =
            Maybe.withDefault
                (.sorts cfg.body
                    |> .default
                )
                nextQuery.sort

        sorting =
            .sorts cfg.body
                |> .options

        listOfLabelsForResultSort =
            List.map
                (\d -> ( d.alias, extractLabelFromLanguageMap cfg.language d.label ))
                sorting

        listOfPageSizes =
            List.map (\d -> ( d, d )) (.pageSizes cfg.body)
    in
    row
        [ alignTop
        , Background.color colourScheme.lightGrey
        , Border.color colourScheme.midGrey
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , minimalDropShadow
        , htmlAttribute (HA.style "clip-path" "inset(0px 0px -5px 0px)")
        , width fill
        , height (px 50)
        , paddingXY 20 0
        , centerY
        , htmlAttribute (HA.style "z-index" "10")
        ]
        [ column
            [ width fill
            , height fill
            , centerY
            ]
            [ row
                [ width fill
                , height fill
                , spacing 20
                , centerY
                ]
                [ column
                    [ width shrink ]
                    [ row
                        [ width fill
                        , height fill
                        , alignLeft
                        , centerY
                        , spacing 5
                        , padding 5
                        , Border.rounded 3
                        , Border.width 1
                        , Border.color colourScheme.midGrey
                        , Background.color colourScheme.white
                        ]
                        [ el
                            [ alignLeft
                            , centerY
                            ]
                            (text (extractLabelFromLanguageMap cfg.language localTranslations.sortBy))
                        , el
                            [ alignLeft
                            , centerY
                            ]
                            (dropdownSelect
                                { selectedMsg = \inp -> cfg.changedResultSortingMsg inp
                                , mouseDownMsg = Nothing
                                , mouseUpMsg = Nothing
                                , choices = listOfLabelsForResultSort
                                , choiceFn = \inp -> inp
                                , currentChoice = chosenSort
                                , selectIdent = "pagination-sort-select" -- TODO: Check that this is unique!
                                , label = Nothing
                                , language = cfg.language
                                , inverted = False
                                }
                            )
                        ]
                    ]
                , column
                    [ width fill ]
                    [ row
                        [ width shrink
                        , alignLeft
                        , centerY
                        , spacing 5
                        , padding 5
                        , Border.rounded 3
                        , Border.width 1
                        , Border.color colourScheme.midGrey
                        , Background.color colourScheme.white
                        ]
                        [ el
                            [ alignLeft
                            , centerY
                            ]
                            (text (extractLabelFromLanguageMap cfg.language localTranslations.rowsPerPage))
                        , el
                            [ alignLeft
                            , centerY
                            ]
                            (dropdownSelect
                                { selectedMsg = \inp -> cfg.changedResultRowsPerPageMsg inp
                                , mouseDownMsg = Nothing
                                , mouseUpMsg = Nothing
                                , choices = listOfPageSizes
                                , choiceFn = \inp -> inp
                                , currentChoice = chosenRows
                                , selectIdent = "pagination-rows-select"
                                , label = Nothing
                                , language = cfg.language
                                , inverted = False
                                }
                            )
                        ]
                    ]
                ]
            ]
        ]


viewSearchPageSort : SortAndRowsConfig msg -> Response ServerData -> Element msg
viewSearchPageSort cfg response =
    case response of
        Loading (Just (SearchData _)) ->
            viewRowSelectAndSortSelector cfg

        Response (SearchData _) ->
            viewRowSelectAndSortSelector cfg

        _ ->
            none
