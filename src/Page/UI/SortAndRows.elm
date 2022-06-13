module Page.UI.SortAndRows exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignLeft, alignRight, column, el, fill, height, none, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


type alias SortAndRowsConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , body : SearchBody
    , changedResultSortingMsg : String -> msg
    , changedResultRowsPerPageMsg : String -> msg
    }


viewSearchPageSort : SortAndRowsConfig msg -> Response ServerData -> Element msg
viewSearchPageSort cfg response =
    case response of
        Response (SearchData body) ->
            viewRowSelectAndSortSelector cfg

        Loading (Just (SearchData body)) ->
            viewRowSelectAndSortSelector cfg

        _ ->
            none


viewRowSelectAndSortSelector : SortAndRowsConfig msg -> Element msg
viewRowSelectAndSortSelector cfg =
    let
        sorting =
            .sorts cfg.body

        nextQuery =
            .nextQuery cfg.activeSearch

        listOfLabelsForResultSort =
            List.map
                (\d -> ( d.alias, extractLabelFromLanguageMap cfg.language d.label ))
                sorting

        listOfPageSizes =
            List.map (\d -> ( d, d )) (.pageSizes cfg.body)

        chosenSort =
            Maybe.withDefault "relevance" nextQuery.sort

        chosenRows =
            nextQuery.rows
                |> String.fromInt
    in
    row
        [ width fill
        , height (px 50)
        , paddingXY 10 0
        , Background.color (colourScheme.lightGrey |> convertColorToElementColor)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , spacing 10
                ]
                [ column
                    [ width fill ]
                    [ row
                        [ width fill
                        , alignLeft
                        , spacing 5
                        ]
                        [ el
                            [ alignLeft ]
                            (text "Sort by")
                        , el
                            [ alignLeft ]
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
                                }
                            )
                        ]
                    ]
                , column
                    [ width fill ]
                    [ row
                        [ width fill
                        , alignRight
                        , spacing 5
                        ]
                        [ el
                            [ alignRight ]
                            (text "Rows per page")
                        , el
                            [ alignRight ]
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
                                }
                            )
                        ]
                    ]
                ]
            ]
        ]
